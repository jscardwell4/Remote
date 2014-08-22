
//  Created by Saul Mora on 11/15/09.
//  Copyright 2010 Magical Panda Software, LLC All rights reserved.
//

//#import "CoreData+MagicalRecord.h"
#import "MagicalRecordStack.h"
#import "MagicalRecordLogging.h"
#import "NSError+MagicalRecordErrorHandling.h"
#import "NSManagedObject+MagicalRequests.h"
#import "NSManagedObject+MagicalRecord.h"
#import "NSManagedObjectContext+MagicalRecord.h"

@implementation NSManagedObject (MagicalRecord)

+ (NSArray *) MR_executeFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context
{
    __block NSArray *results = nil;
    void (^requestBlock)(void) = ^{

        NSError *error = nil;
        results = [context executeFetchRequest:request error:&error];

        if (results == nil)
        {
            [[error MR_coreDataDescription] MR_logToConsole];
        }  
    };

    if ([context concurrencyType] == NSConfinementConcurrencyType)
    {
        requestBlock();
    }
    else
    {
        [context performBlockAndWait:requestBlock];
    }
	return results;
}

+ (NSArray *) MR_executeFetchRequest:(NSFetchRequest *)request
{
	return [self MR_executeFetchRequest:request inContext:[[MagicalRecordStack defaultStack] context]];
}

+ (id) MR_executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context
{
	[request setFetchLimit:1];
	
	NSArray *results = [self MR_executeFetchRequest:request inContext:context];
	if ([results count] == 0)
	{
		return nil;
	}
	return [results objectAtIndex:0];
}

+ (id) MR_executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request
{
	return [self MR_executeFetchRequestAndReturnFirstObject:request inContext:[[MagicalRecordStack defaultStack] context]];
}

+ (NSString *) MR_entityName;
{
    if ([self respondsToSelector:@selector(entityName)])
    {
        return [self performSelector:@selector(entityName)];
    }
    return NSStringFromClass(self);
}

+ (NSEntityDescription *) MR_entityDescriptionInContext:(NSManagedObjectContext *)context
{
    NSString *entityName = [self MR_entityName];
    return [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
}

+ (NSEntityDescription *) MR_entityDescription
{
	return [self MR_entityDescriptionInContext:[[MagicalRecordStack defaultStack] context]];
}

+ (NSArray *) MR_propertiesNamed:(NSArray *)properties
{
	NSEntityDescription *description = [self MR_entityDescription];
	NSMutableArray *propertiesWanted = [NSMutableArray array];
	
	if (properties)
	{
		NSDictionary *propDict = [description propertiesByName];
		
		for (NSString *propertyName in properties)
		{
			NSPropertyDescription *property = [propDict objectForKey:propertyName];
			if (property)
			{
				[propertiesWanted addObject:property];
			}
			else
			{
				MRLogWarn(@"Property '%@' not found in %tu properties for %@", propertyName, [propDict count], NSStringFromClass(self));
			}
		}
	}
	return propertiesWanted;
}

+ (NSArray *) MR_sortAscending:(BOOL)ascending attributes:(NSArray *)attributesToSortBy
{
	NSMutableArray *attributes = [NSMutableArray array];
    
    for (NSString *attributeName in attributesToSortBy) 
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attributeName ascending:ascending];
        [attributes addObject:sortDescriptor];
    }
    
	return attributes;
}

+ (NSArray *) MR_ascendingSortDescriptors:(NSArray *)attributesToSortBy
{
	return [self MR_sortAscending:YES attributes:attributesToSortBy];
}

+ (NSArray *) MR_descendingSortDescriptors:(NSArray *)attributesToSortBy
{
	return [self MR_sortAscending:NO attributes:attributesToSortBy];
}

#pragma mark -

+ (id) MR_createInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self MR_entityName] inManagedObjectContext:context];
}

+ (id) MR_createEntity
{	
	NSManagedObject *newEntity = [self MR_createInContext:[[MagicalRecordStack defaultStack] context]];

	return newEntity;
}

- (BOOL) MR_deleteInContext:(NSManagedObjectContext *)context
{
	[context deleteObject:self];
	return YES;
}

- (BOOL) MR_deleteEntity
{
	[self MR_deleteInContext:[self managedObjectContext]];
	return YES;
}

+ (BOOL) MR_deleteAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self MR_requestAllWithPredicate:predicate];
    [request setReturnsObjectsAsFaults:YES];
	[request setIncludesPropertyValues:NO];
    
	NSArray *objectsToTruncate = [self MR_executeFetchRequest:request inContext:context];
    
	for (id objectToTruncate in objectsToTruncate) 
    {
		[objectToTruncate MR_deleteInContext:context];
	}
    
	return YES;
}

+ (BOOL) MR_deleteAllMatchingPredicate:(NSPredicate *)predicate
{
    return [self MR_deleteAllMatchingPredicate:predicate inContext:[[MagicalRecordStack defaultStack] context]];
}

+ (BOOL) MR_truncateAllInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self MR_requestAll];
    [request setReturnsObjectsAsFaults:YES];
    [request setIncludesPropertyValues:NO];

    NSArray *objectsToDelete = [self MR_executeFetchRequest:request inContext:context];
    for (NSManagedObject *objectToDelete in objectsToDelete)
    {
        [objectToDelete MR_deleteInContext:context];
    }
    return YES;
}

+ (BOOL) MR_truncateAll
{
    [self MR_truncateAllInContext:[[MagicalRecordStack defaultStack] context]];
    return YES;
}

- (void) MR_refresh;
{
    [[self managedObjectContext] refreshObject:self mergeChanges:YES];
}

- (void) MR_obtainPermanentObjectID;
{
    if ([[self objectID] isTemporaryID])
    {
        NSError *error = nil;

        BOOL success = [[self managedObjectContext] obtainPermanentIDsForObjects:[NSArray arrayWithObject:self] error:&error];
        if (!success)
        {
            [[error MR_coreDataDescription] MR_logToConsole];
        }
    }
}

- (id) MR_inContext:(NSManagedObjectContext *)otherContext;
{
    NSManagedObject *inContext = nil;
    NSManagedObjectID *objectID = [self objectID];
    if (otherContext == [self managedObjectContext])
    {
        inContext = self;
    }
    else if ([objectID isTemporaryID])
    {
        MRTransferObjectToContextError(self);
    }
    else
    {
        inContext = [otherContext objectRegisteredForID:objectID];  //see if its already there
        if (inContext == nil)
        {
            NSError *error = nil;
            inContext = [otherContext existingObjectWithID:objectID error:&error];

            if (inContext == nil)
            {
                MRLogWarn(@"Did not find object %@ in context '%@': %@", self, [otherContext MR_description], error);
            }
        }
    }
    return inContext;
}

@end

void MRTransferObjectToContextError(NSManagedObject *object)
{
    MRLogCFatal(@"Cannot load a temporary object '%@' [%@] across Managed Object Contexts", object, [object objectID]);
    MRLogCFatal(@"Break in MRTransferObjectToContextError for more information");
}
