//
//  NSManagedObject+MSKitAdditions.m
//  MSKit
//
//  Created by Jason Cardwell on 3/3/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "NSManagedObject+MSKitAdditions.h"
#import "MSKitMacros.h"
#import "NSSet+MSKitAdditions.h"
#import "NSArray+MSKitAdditions.h"

MSKEY_DEFINITION(MSDefaultValueForContainingClass);

@implementation NSManagedObject (MSKitAdditions)

- (id)committedValueForKey:(NSString *)key {
    return NilSafe([self committedValuesForKeys:@[key]][key]);
}

- (BOOL)hasChangesForKey:(NSString *)key {
    if ([self hasChanges] && [self changedValues][key])
        return YES;
    else
        return NO;
}

- (NSURL *)permanentURI
{
    if ([self.objectID isTemporaryID])
        [self.managedObjectContext obtainPermanentIDsForObjects:@[self] error:nil];

    return [self.objectID URIRepresentation];
}

- (instancetype)faultedObject
{
    return [self.managedObjectContext existingObjectWithID:self.objectID error:nil];
}

- (NSAttributeDescription *)attributeDescriptionForAttribute:(NSString *)attributeName
{
    return [self.entity attributesByName][attributeName];
}

- (id)defaultValueForAttribute:(NSString *)attributeName
{
    return [self defaultValueForAttribute:attributeName forContainingClass:nil];
}

- (id)defaultValueForAttribute:(NSString *)attributeName forContainingClass:(NSString *)className
{
    NSAttributeDescription * description = [self attributeDescriptionForAttribute:attributeName];
    if (!description) return nil;

    id defaultValue = description.defaultValue;

    if (className)
    {
        NSDictionary * userInfo = description.userInfo;
        NSSet * userInfoKeys = [[userInfo allKeys] set];

        NSSet * keys = [userInfoKeys filteredSetUsingPredicate:
                        [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",
                                                         MSDefaultValueForContainingClassKey]];

        if ([keys count])
        {
            NSString * key =
                [keys objectPassingTest:
                 ^BOOL(NSString * k)
                 {
                     return [[k stringByReplacingOccurrencesOfString:MSDefaultValueForContainingClassKey
                                                          withString:@""]
                             isEqualToString:className];
                 }];
            if (key) defaultValue = userInfo[key];
        }
    }

    return defaultValue;
}

@end
