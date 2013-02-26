//
// Manufacturer.h
// iPhonto
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BankObject.h"

@class   IRCodeSet;

@interface Manufacturer : BankObject

+ (Manufacturer *)fetchManufacturerWithName:(NSString *)name
                                  inContext:(NSManagedObjectContext *)context;
+ (Manufacturer *)manufacturerWithName:(NSString *)name inContext:(NSManagedObjectContext *)context;
@property (nonatomic, strong) NSSet * codesets;
@end

@interface Manufacturer (CoreDataGeneratedAccessors)

- (void)addCodesetsObject:(IRCodeSet *)value;
- (void)removeCodesetsObject:(IRCodeSet *)value;
- (void)addCodesets:(NSSet *)values;
- (void)removeCodesets:(NSSet *)values;

@end
