//
//  MSModelObject.m
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSModelObject.h"


@interface MSModelObject (CoreDataGeneratedAccessors)

@property (nonatomic, copy) NSString * primitiveUuid;

@end


@implementation MSModelObject

@dynamic uuid;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.primitiveUuid = [MSNonce() copy];
}

+ (instancetype)objectWithUUID:(NSString *)uuid
{
    return [self objectWithUUID:uuid inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (instancetype)objectWithUUID:(NSString *)uuid inContext:(NSManagedObjectContext *)context
{
    return (StringIsNotEmpty(uuid)
            ? [self MR_findFirstByAttribute:@"uuid" withValue:uuid inContext:context]
            : nil);
}

- (id)keySubscriptedCollection { return nil; }

- (id)indexSubscriptedCollection { return nil; }

- (id)objectForKeyedSubscript:(NSString *)uuid
{
    return memberOfCollectionWithUUID([self keySubscriptedCollection], uuid);
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    return memberOfCollectionAtIndex([self indexSubscriptedCollection], idx);
}

- (MSDictionary *)deepDescriptionDictionary
{
    MSMutableDictionary * descriptionDictionary = [MSMutableDictionary dictionary];
    descriptionDictionary[@"class"]   = ClassString([self class]);
    descriptionDictionary[@"address"] = $(@"%p", self);
    descriptionDictionary[@"uuid"]    = self.uuid;
    descriptionDictionary[@"context"] = $(@"%p:'%@'",
                                          self.managedObjectContext,
                                          (self.managedObjectContext.nametag ?: @""));

    return descriptionDictionary;
}

- (NSString *)deepDescription
{
    MSDictionary * descriptionDictionary = [self deepDescriptionDictionary];

    NSMutableString * description = [@"" mutableCopy];
    [descriptionDictionary enumerateKeysAndObjectsUsingBlock:
     ^(NSString * key, NSString * value, BOOL *stop)
     {
         [description appendFormat:@"%@ %@\n",
          [[key stringByAppendingString:@":"] stringByRightPaddingToLength:22 withCharacter:' '],
          value];
     }];

    return [description stringByShiftingRight:4];
}

@end

MSModelObject * memberOfCollectionWithUUID(id collection, NSString * uuid)
{
    NSSet * set = nil;
    
    if ([collection isKindOfClass:[NSSet class]])
        set = (NSSet *)collection;

    else if ([collection isKindOfClass:[NSOrderedSet class]])
        set = [(NSOrderedSet *)collection set];
    
    if (!set.count || StringIsEmpty(uuid))
        return nil;
    
    else
        return [set objectPassingTest:
                 ^BOOL(id obj)
                 {
                     return (   [obj isKindOfClass:[MSModelObject class]]
                             && [((MSModelObject *)obj).uuid isEqualToString:uuid]);
                 }];
}

MSModelObject * memberOfCollectionAtIndex(id collection, NSUInteger idx)
{
    NSArray * array = nil;
    
    if ([collection isKindOfClass:[NSArray class]])
        array = (NSArray *)collection;

    else if ([collection isKindOfClass:[NSOrderedSet class]])
        array = [(NSOrderedSet *)collection array];

    if (!array.count || ! idx < array.count)
        return nil;

    else
        return array[idx];
}

