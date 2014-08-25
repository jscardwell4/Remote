//
//  NSManagedObject+MSKitAdditions.m
//  MSKit
//
//  Created by Jason Cardwell on 3/3/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "NSManagedObject+MSKitAdditions.h"
#import "MSKitMacros.h"
#import "Lumberjack/Lumberjack.h"
#import "NSSet+MSKitAdditions.h"
#import "NSArray+MSKitAdditions.h"
#import "NSDictionary+MSKitAdditions.h"
#import "NSManagedObjectContext+MSKitAdditions.h"

MSKEY_DEFINITION(MSDefaultValueForContainingClass);
MSKEY_DEFINITION(MSDefaultValueForSubentity);
static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;

#pragma unused(ddLogLevel,msLogContext)

@implementation NSManagedObject (MSKitAdditions)

+ (instancetype)createInContext:(NSManagedObjectContext *)moc {
  if (!moc)
    ThrowInvalidNilArgument(moc);

  NSEntityDescription * entity = [NSEntityDescription entityForName:NSStringFromClass(self)
                                             inManagedObjectContext:moc];

  if (entity)
    return [[self alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
  else
    return nil;
}

+ (instancetype)findFirstInContext:(NSManagedObjectContext *)moc {
  if (!moc) return nil;

  NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self)];

  request.fetchLimit = 1;
  NSError * error   = nil;
  NSArray * results = [moc executeFetchRequest:request error:&error];

  if (error) { MSHandleErrors(error); }

  if ([results count] > 0) { return results[0]; } else { return nil; }
}

- (id)committedValueForKey:(NSString *)key {
  return NilSafe([self committedValuesForKeys:@[key]][key]);
}

- (BOOL)hasChangesForKey:(NSString *)key {
  if ([self hasChanges] && [self changedValues][key])
    return YES;
  else
    return NO;
}

+ (id)findFirstByAttribute:(NSString *)attribute
                 withValue:(id)value
                 inContext:(NSManagedObjectContext *)moc
{
  NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self)];

  request.fetchLimit = 1;
  request.predicate  = [NSPredicate predicateWithFormat:@"%K == %@", attribute, value];
  NSError * error   = nil;
  NSArray * results = [moc executeFetchRequest:request error:&error];

  if ([results count] > 0) {
    return results[0];
  } else {
    if (error) {
      MSHandleErrors(error);
    }

    return nil;
  }
}

- (NSURL *)permanentURI {
  if ([self.objectID isTemporaryID])
    [self.managedObjectContext obtainPermanentIDsForObjects:@[self] error:nil];

  return [self.objectID URIRepresentation];
}

+ (instancetype)objectForURI:(NSURL *)uri context:(NSManagedObjectContext *)moc {
  if (!moc) ThrowInvalidNilArgument(moc);
  else if (!uri) ThrowInvalidNilArgument(uri);
  else return [moc objectForURI:uri];
}

- (instancetype)faultedObject {
  return [self.managedObjectContext existingObjectWithID:self.objectID error:nil];
}

- (NSAttributeDescription *)attributeDescriptionForAttribute:(NSString *)attributeName {
  return [self.entity attributesByName][attributeName];
}

- (id)defaultValueForAttribute:(NSString *)attributeName {
  return [self defaultValueForAttribute:attributeName forContainingClass:nil];
}

- (id)defaultValueForAttribute:(NSString *)attributeName forContainingClass:(NSString *)className {
  NSAttributeDescription * description = [self attributeDescriptionForAttribute:attributeName];

  if (!description) return nil;

  id defaultValue = description.defaultValue;   // official default value

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
