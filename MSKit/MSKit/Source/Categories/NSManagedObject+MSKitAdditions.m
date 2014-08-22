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
#import "NSDictionary+MSKitAdditions.h"
#import "NSManagedObjectContext+MSKitAdditions.h"

MSKEY_DEFINITION(MSDefaultValueForContainingClass);
MSKEY_DEFINITION(MSDefaultValueForSubentity);

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

+ (instancetype)objectForURI:(NSURL *)uri context:(NSManagedObjectContext *)moc
{
    if (!moc) ThrowInvalidNilArgument(moc);
    else if (!uri) ThrowInvalidNilArgument(uri);
    else return [moc objectForURI:uri];
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

    id defaultValue = description.defaultValue; // official default value

    NSDictionary * userInfo = description.userInfo;

    if (!className) className = self.entity.name;

    /*
     look for key in user info of attribute description for a default value to be used
     when the attribute is a member of the specified class
     */

    NSString * key = [@"." join:@[MSDefaultValueForContainingClassKey, className]];
    if ([userInfo hasKey:key]) defaultValue = NilSafe(userInfo[key]);

    return defaultValue;
}

@end
