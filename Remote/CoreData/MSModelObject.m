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

@end


MSModelObject * memberOfSetWithUUID(NSSet * set, NSString * uuid)
{
    if (!set.count || StringIsEmpty(uuid)) return nil;
    else return [set objectPassingTest:^BOOL(id obj) {
        return (   [obj isKindOfClass:[MSModelObject class]]
                && [((MSModelObject *)obj).uuid isEqualToString:uuid]);
    }];
}