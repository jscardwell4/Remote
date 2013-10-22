//
// ControlStateColorSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ControlStateSet.h"
#import "RemoteElementExportSupportFunctions.h"

@implementation ControlStateColorSet

@dynamic button, imageSet;

- (UIColor *)objectAtIndexedSubscript:(NSUInteger)state
{
    return (UIColor *)[super objectAtIndexedSubscript:state];
}

#pragma mark - Debugging

- (MSDictionary *)deepDescriptionDictionary
{
    ControlStateColorSet * stateSet = [self faultedObject];
    assert(stateSet);

    MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"normal"]                         = NSStringFromUIColor(stateSet[0]);
    dd[@"selected"]                       = NSStringFromUIColor(stateSet[1]);
    dd[@"highlighted"]                    = NSStringFromUIColor(stateSet[2]);
    dd[@"disabled"]                       = NSStringFromUIColor(stateSet[3]);
    dd[@"highlightedAndSelected"]         = NSStringFromUIColor(stateSet[4]);
    dd[@"highlightedAndDisabled"]         = NSStringFromUIColor(stateSet[5]);
    dd[@"disabledAndSelected"]            = NSStringFromUIColor(stateSet[6]);
    dd[@"selectedHighlightedAndDisabled"] = NSStringFromUIColor(stateSet[7]);

    return (MSDictionary *)dd;
}

- (NSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [[super JSONDictionary] mutableCopy];

    NSArray * keys = [[NSArray arrayFromRange:NSMakeRange(0, 8)] arrayByMappingToBlock:
                      ^id(id obj, NSUInteger idx)
                      {
                          return [ControlStateSet propertyForState:[obj unsignedIntegerValue]];
                      }];


    for (NSString * key in keys)
    {
        UIColor * color = [self valueForKey:key];
        if (color)
            dictionary[key] = CollectionSafeValue(normalizedColorJSONValueForColor(color));
    }

    [dictionary removeKeysWithNullObjectValues];

    return dictionary;
}


- (NSString *)debugDescription
{
    return $(@"normal:%@\n"
            "selected:%@\n"
            "highlighted:%@\n"
            "disabled:%@\n"
            "highlightedAndSelected:%@\n"
            "highlightedAndDisabled:%@\n"
            "disabledAndSelected:%@\n"
            "selectedHighlightedAndDisabled:%@",
            NSStringFromUIColor(self[0]),
            NSStringFromUIColor(self[4]),
            NSStringFromUIColor(self[1]),
            NSStringFromUIColor(self[2]),
            NSStringFromUIColor(self[5]),
            NSStringFromUIColor(self[3]),
            NSStringFromUIColor(self[6]),
            NSStringFromUIColor(self[7]));
}

@end
