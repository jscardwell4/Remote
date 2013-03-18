//
// Manufacturer.m
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "Manufacturer.h"
#import "IRCodeSet.h"

@implementation Manufacturer

@dynamic codesets;

+ (Manufacturer *)fetchManufacturerWithName:(NSString *)name
                                  inContext:(NSManagedObjectContext *)context {
    __block NSArray * fetchedObjects = nil;

    [context performBlockAndWait:^{
                 NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Manufacturer"];

                 NSPredicate * predicate =
                 [NSPredicate predicateWithFormat:@"name == %@", name];
                 [fetchRequest setPredicate:predicate];

                 NSError * error = nil;
                 fetchedObjects = [context          executeFetchRequest:fetchRequest
                                                         error:&error];
             }

    ];

    return fetchedObjects.count ?[fetchedObjects lastObject] : nil;
}

+ (Manufacturer *)manufacturerWithName:(NSString *)name inContext:(NSManagedObjectContext *)context {
    if (ValueIsNil(context) || StringIsEmpty(name)) return nil;

    Manufacturer * manufacturer = [self fetchManufacturerWithName:name inContext:context];

    if (!manufacturer) {
        manufacturer = [NSEntityDescription insertNewObjectForEntityForName:@"Manufacturer"
                                                     inManagedObjectContext:context];
        manufacturer.name = name;
    }

    return manufacturer;
}

@end
