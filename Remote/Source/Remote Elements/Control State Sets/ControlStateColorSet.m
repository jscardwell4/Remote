//
// ControlStateColorSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ControlStateColorSet.h"
#import "RemoteElementExportSupportFunctions.h"
#import "RemoteElementImportSupportFunctions.h"
#import "RemoteElementExportSupportFunctions.h"
#import "JSONObjectKeys.h"

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
    dd[@"normal"]                         = NSStringFromUIColor([stateSet valueForKey:@"normal"]);
    dd[@"selected"]                       = NSStringFromUIColor([stateSet valueForKey:@"selected"]);
    dd[@"highlighted"]                    = NSStringFromUIColor([stateSet valueForKey:@"highlighted"]);
    dd[@"disabled"]                       = NSStringFromUIColor([stateSet valueForKey:@"disabled"]);
    dd[@"highlightedSelected"]         = NSStringFromUIColor([stateSet valueForKey:@"highlightedSelected"]);
    dd[@"highlightedDisabled"]         = NSStringFromUIColor([stateSet valueForKey:@"highlightedDisabled"]);
    dd[@"disabledSelected"]            = NSStringFromUIColor([stateSet valueForKey:@"disabledSelected"]);
    dd[@"selectedHighlightedDisabled"] = NSStringFromUIColor([stateSet valueForKey:@"selectedHighlightedDisabled"]);

    return (MSDictionary *)dd;
}


- (void)updateWithData:(NSDictionary *)data
{
    NSManagedObjectContext * moc = self.managedObjectContext;

    [(NSDictionary *)data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
         if ([ControlStateSet validState:key])
         {
             UIColor * color = colorFromImportValue(obj);
             if (color) self[key] = color;
         }
     }];
}

- (MSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];

    NSArray * keys = [[NSArray arrayFromRange:NSMakeRange(0, 8)] arrayByMappingToBlock:
                      ^id(id obj, NSUInteger idx)
                      {
                          return [ControlStateSet propertyForState:[obj unsignedIntegerValue]];
                      }];


    for (NSString * key in keys)
    {
        UIColor * color = [self valueForKey:key];
        if (color)
            dictionary[key] = CollectionSafe(normalizedColorJSONValueForColor(color));
    }

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}


- (NSString *)debugDescription
{
    return $(@"normal:%@\n"
            "selected:%@\n"
            "highlighted:%@\n"
            "disabled:%@\n"
            "highlightedSelected:%@\n"
            "highlightedDisabled:%@\n"
            "disabledSelected:%@\n"
            "selectedHighlightedDisabled:%@",
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
