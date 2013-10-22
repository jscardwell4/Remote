//
//  MSJSONAssembler.m
//  MSKit
//
//  Created by Jason Cardwell on 10/20/13.
//  Copyright (c) 2013 Jason Cardwell. All rights reserved.
//

#import "MSJSONAssembler.h"
#import <ParseKit/ParseKit.h>
#import "MSStack.h"
#import "MSDictionary.h"
#import "NSArray+MSKitAdditions.h"
#import "PKAssembly+MSKitAdditions.h"
#import "MSJSONParser.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@interface MSJSONAssembler ()

@property (nonatomic, strong, readwrite) id assembledObject;

@end

@implementation MSJSONAssembler
{
    MSStack         * _activeObjects;
    MSStack         * _pendingKeys;
    NSString        * _pendingKey;
    id                _pendingValue;
    BOOL              _splitKeyPaths;
}

+ (MSJSONAssembler *)assemblerWithOptions:(MSJSONFormatOptions)options
{
    MSJSONAssembler * assembler = [self new];
    assembler.options = options;
    return assembler;
}

- (id)init { if (self = [super init]) _splitKeyPaths = YES; return self; }

- (void)setOptions:(MSJSONFormatOptions)options
{
    _options = options;
    _splitKeyPaths = !((options & MSJSONFormatKeepKeyPaths) == MSJSONFormatKeepKeyPaths);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Helpers
////////////////////////////////////////////////////////////////////////////////

- (void)resolveKeyPathsForPendingValue
{
//    assert(![_pendingKeys isEmpty]);
    assert(_pendingKey);

    if ([_pendingValue isKindOfClass:[NSMutableArray class]])
        [(NSMutableArray *)_pendingValue mapToBlock:^id(id obj, NSUInteger idx) {
            return [MSDictionary dictionaryWithObject:obj forKey:_pendingKey];
        }];

    else
        _pendingValue = [MSDictionary dictionaryWithObject:_pendingValue forKey:_pendingKey];

    _pendingKey = [_pendingKeys pop];
//    _pendingValue = value;


    while (![_pendingKeys isEmpty])
    {
        _pendingValue = [MSDictionary dictionaryWithObject:_pendingValue forKey:_pendingKey];
        _pendingKey = [_pendingKeys pop];
        assert(_pendingKey);
    }

    assert(_pendingKey);

    [self addObjectToActiveObject:_pendingValue];
    _pendingValue = nil;
}

- (void)addObjectToActiveObject:(id)object
{
    id activeObject = [_activeObjects peek];

    if ([activeObject isKindOfClass:[MSDictionary class]])
    {
        assert(_pendingKey);

        if ([_pendingKeys isEmpty])
        {
            [activeObject setObject:object forKey:_pendingKey];
            _pendingKey = nil;
        }

        else
        {
            assert(!_pendingValue);
            _pendingValue = object;
            [self resolveKeyPathsForPendingValue];
        }
    }

    else if ([activeObject isKindOfClass:[NSMutableArray class]])
             [activeObject addObject:object];

    else
        assert(NO);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Matching top level object
////////////////////////////////////////////////////////////////////////////////

- (void)parser:(PKSParser *)parser willStart:(PKSTokenAssembly *)assembly
{
    self.assembledObject = nil;
    _activeObjects   = [MSStack stack];
    _pendingKeys     = [MSStack stack];
    _pendingKey      = nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Matching object keys and keypaths
////////////////////////////////////////////////////////////////////////////////


- (void)parser:(PKSParser *)parser didMatchKeyPath:(PKSTokenAssembly *)assembly
{
    if (!_splitKeyPaths)
        _pendingKey = ((PKToken *)[assembly MS_peek]).quotedStringValue;

    else
    {
        NSString * keyPath = ((PKToken *)[assembly MS_peek]).quotedStringValue;
        NSArray * keys = [keyPath componentsSeparatedByString:@"."];
        [_pendingKeys pushObjectsFromArray:keys];
        _pendingKey = [_pendingKeys pop];
    }

    assert(_pendingKey);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Matching string, number, and boolean terminals
////////////////////////////////////////////////////////////////////////////////

- (void)parser:(PKSParser *)parser didMatchString:(PKSTokenAssembly *)assembly
{
    [self addObjectToActiveObject:((PKToken *)[assembly MS_peek]).quotedStringValue];
}

- (void)parser:(PKSParser *)parser didMatchNumber:(PKSTokenAssembly *)assembly
{
    [self addObjectToActiveObject:((PKToken *)[assembly MS_peek]).value];
}

- (void)parser:(PKSParser *)parser didMatchNullLiteral:(PKSTokenAssembly *)assembly
{
    [self addObjectToActiveObject:[NSNull null]];
}

- (void)parser:(PKSParser *)parser didMatchTrueLiteral:(PKSTokenAssembly *)assembly
{
    [self addObjectToActiveObject:@YES];
}

- (void)parser:(PKSParser *)parser didMatchFalseLiteral:(PKSTokenAssembly *)assembly
{
    [self addObjectToActiveObject:@NO];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Matching punction terminals - {}[],:
////////////////////////////////////////////////////////////////////////////////

- (void)parser:(PKSParser *)parser didMatchOpenCurly:(PKSTokenAssembly *)assembly
{
    MSDictionary * dictionary = [MSDictionary dictionary];

    if (!_assembledObject)
        self.assembledObject = dictionary;

    else if ([_pendingKeys isEmpty])
        [self addObjectToActiveObject:dictionary];

    else if (!_pendingValue)
        _pendingValue = dictionary;

    [_activeObjects push:dictionary];
}

- (void)parser:(PKSParser *)parser didMatchCloseCurly:(PKSTokenAssembly *)assembly
{
    if (_pendingValue == [_activeObjects pop]) [self resolveKeyPathsForPendingValue];

}

- (void)parser:(PKSParser *)parser didMatchOpenBracket:(PKSTokenAssembly *)assembly
{
    NSMutableArray * array = [@[] mutableCopy];

    if (!_assembledObject)
        self.assembledObject = array;

    else if ([_pendingKeys isEmpty])
        [self addObjectToActiveObject:array];

    else if (!_pendingValue)
        _pendingValue = array;

    [_activeObjects push:array];
}

- (void)parser:(PKSParser *)parser didMatchCloseBracket:(PKSTokenAssembly *)assembly
{
    if (_pendingValue == [_activeObjects pop]) [self resolveKeyPathsForPendingValue];
}

@end
