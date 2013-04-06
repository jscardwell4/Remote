//
// Manufacturer.m
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "BankObject.h"
#import "BankObjectGroup.h"

@implementation BOManufacturer

@dynamic codesets;

+ (instancetype)fetchManufacturerWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    __block BOManufacturer * manufacturer = nil;

    [context performBlockAndWait:^{
        NSFetchRequest * fetchRequest = NSFetchRequestFromClassWithPredicate(@"name == %@", name);
        NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];
        manufacturer = [fetchedObjects lastObject];
    }];
    return manufacturer;
}

+ (instancetype)manufacturerWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    assert(name && context);

    __block BOManufacturer * manufacturer = [self fetchManufacturerWithName:name context:context];

    if (!manufacturer) {
        [context performBlockAndWait:
         ^{
             manufacturer = [self bankObjectInContext:context];
             manufacturer.name = name;
         }];
    }
    
    return manufacturer;
}

@end
