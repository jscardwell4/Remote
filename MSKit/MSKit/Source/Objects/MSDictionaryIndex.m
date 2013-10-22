//
//  MSDictionaryIndex.m
//  MSKit
//
//  Created by Jason Cardwell on 10/3/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "MSDictionaryIndex.h"

@interface MSDictionaryIndex ()

@property (nonatomic, weak) MSDictionary * dictionary;

@end

@implementation MSDictionaryIndex
{
    NSMutableDictionary * _keyMap;
}

+ (MSDictionaryIndex *)dictionaryIndexForDictionary:(MSDictionary *)dictionary
                                            handler:(MSDictionaryIndexKeyMapHandler)handler
{
    MSDictionaryIndex * index = [self new];
    index.dictionary = dictionary;
    index.handler = handler;
    return index;
}

- (void)setDictionary:(MSDictionary *)dictionary
{
    _dictionary = dictionary;
    if (_dictionary)
        [_dictionary addObserver:self
                      forKeyPath:@"allKeys"
                         options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                         context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    assert(object == _dictionary);

    if (_handler)
    {
        switch ([change[NSKeyValueChangeKindKey] unsignedIntegerValue])
        {
            case NSKeyValueChangeInsertion:
            {
                id key = change[NSKeyValueChangeNewKey][0];
                NSArray * keyMap = _handler(_dictionary, key);
                if ([keyMap count] == 2)
                {
                    self.keyMap[key] = keyMap[0];
                    self[keyMap[0]] = keyMap[1];
                }

            } break;

            case NSKeyValueChangeRemoval:
            {
                id key = change[NSKeyValueChangeOldKey][0];
                assert(_keyMap[key]);
                [self removeObjectForKey:_keyMap[key]];
                [_keyMap removeObjectForKey:key];
            } break;

            default:
                break;
        }
    }
}

- (NSMutableDictionary *)keyMap { if (!_keyMap) _keyMap = [@{} mutableCopy]; return _keyMap; }

- (void)dealloc
{
    [_dictionary removeObserver:self forKeyPath:@"allKeys" context:NULL];
}

@end
