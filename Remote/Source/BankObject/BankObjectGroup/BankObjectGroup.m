//
// BankObjectGroup.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "BankObjectGroup.h"
#import "BankObject.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@interface BankObjectGroup (CoreDataGeneratedAccessors)

- (NSMutableSet *)primitiveImages;
- (NSMutableSet *)primitivePresets;

@end

@implementation BankObjectGroup
@dynamic name;

+ (instancetype)defaultGroupInContext:(NSManagedObjectContext *)context
{
    assert(context);

    __block BankObjectGroup * group = nil;

    [context performBlockAndWait:
     ^{
         group = [self MR_findFirstByAttribute:@"name" withValue:@"Default"];
         if (!group) group = [self groupWithName:@"Default" context:context];
    }];

    return group;
}

+ (instancetype)groupWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    __block BankObjectGroup * group = nil;

    [context performBlockAndWait:
     ^{
         group = NSManagedObjectFromClass(context);
         group.name = name;
     }];

    return group;
}

+ (instancetype)fetchGroupWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    return [self MR_findFirstByAttribute:@"name" withValue:name inContext:context];
}

@end

@implementation BOImageGroup

@dynamic images;

- (void)addImagesObject:(BOImage *)value {
    NSSet * changedObjects = [[NSSet alloc] initWithObjects:&value count:1];

    [self willChangeValueForKey:@"images"
                withSetMutation:NSKeyValueUnionSetMutation
                   usingObjects:changedObjects];
    [self.primitiveImages addObject:value];
    [self didChangeValueForKey:@"images"
               withSetMutation:NSKeyValueUnionSetMutation
                  usingObjects:changedObjects];
}

- (void)removeImagesObject:(BOImage *)value {
    NSSet * changedObjects = [[NSSet alloc] initWithObjects:&value count:1];

    [self willChangeValueForKey:@"images"
                withSetMutation:NSKeyValueMinusSetMutation
                   usingObjects:changedObjects];
    [self.primitiveImages removeObject:value];
    [self didChangeValueForKey:@"images"
               withSetMutation:NSKeyValueMinusSetMutation
                  usingObjects:changedObjects];
}

- (void)addImages:(NSSet *)value {
    [self willChangeValueForKey:@"images"
                withSetMutation:NSKeyValueUnionSetMutation
                   usingObjects:value];
    [self.primitiveImages unionSet:value];
    [self didChangeValueForKey:@"images"
               withSetMutation:NSKeyValueUnionSetMutation
                  usingObjects:value];
}

- (void)removeImages:(NSSet *)value {
    [self willChangeValueForKey:@"images"
                withSetMutation:NSKeyValueMinusSetMutation
                   usingObjects:value];
    [self.primitiveImages minusSet:value];
    [self didChangeValueForKey:@"images"
               withSetMutation:NSKeyValueMinusSetMutation
                  usingObjects:value];
}

@end

@implementation BOPresetsGroup @end

@implementation BOIRCodeset

@dynamic manufacturer;
@dynamic codes;

@end

