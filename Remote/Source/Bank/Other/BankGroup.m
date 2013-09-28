//
// BankGroup.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "BankGroup.h"
#import "Image.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation BankGroup
@dynamic name;

+ (instancetype)groupWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    __block BankGroup * group = nil;

    [context performBlockAndWait:
     ^{
         group = [self MR_findFirstByAttribute:@"name" withValue:name inContext:context];
         if (!group)
         {
             group = [self MR_createInContext:context];
             group.name = name;
         }
     }];

    return group;
}

+ (instancetype)fetchGroupWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    return [self MR_findFirstByAttribute:@"name" withValue:name inContext:context];
}

@end

@implementation ImageGroup

@dynamic images;

- (id)keySubscriptedCollection { return self.images; }

- (NSDictionary *)deepDescriptionDictionary
{
    ImageGroup * imageGroup = [self faultedObject];
    assert(imageGroup);
    
    NSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"name"  ] = (imageGroup.name ?: @"nil");
    dd[@"images"] = (imageGroup.images
                                        ? [[imageGroup.images setByMappingToBlock:
                                           ^NSString *(Image * obj)
                                           {
                                               return $(@"%@:'%@'", obj.uuid, obj.name);
                                           }] componentsJoinedByString:@"\n"]
                                        : @"nil");

    return dd;
}

@end

@implementation IRCodeset

@dynamic manufacturer, codes;

- (id)keySubscriptedCollection { return self.codes; }

@end

