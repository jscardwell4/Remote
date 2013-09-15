//
// Manufacturer.m
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "Manufacturer.h"
#import "BankObjectGroup.h"

@implementation Manufacturer

@dynamic codesets, name;

+ (BOOL)isEditable { return NO; }

+ (BOOL)isPreviewable { return NO;}

+ (NSString *)directoryLabel { return @"Manufacturer"; }

+ (NSOrderedSet *)directoryItems { return nil; }

- (UIImage *)thumbnail { return nil; }

- (UIImage *)preview { return nil; }

- (NSString *)category { return nil; }

- (UIViewController *)editingViewController { return nil; }

- (NSOrderedSet *)subBankables { return nil; }

+ (instancetype)fetchManufacturerWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    __block Manufacturer * manufacturer = nil;

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

    __block Manufacturer * manufacturer = [self fetchManufacturerWithName:name context:context];

    if (!manufacturer) {
        [context performBlockAndWait:
         ^{
             manufacturer = [self MR_createInContext:context];
             manufacturer.name = name;
         }];
    }
    
    return manufacturer;
}

@end
