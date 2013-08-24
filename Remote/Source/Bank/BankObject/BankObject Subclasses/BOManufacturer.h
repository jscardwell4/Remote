//
// BOManufacturer.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BankObject.h"

@class BOIRCodeset;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Manufacturer
////////////////////////////////////////////////////////////////////////////////

@interface BOManufacturer : BankObject

+ (instancetype)fetchManufacturerWithName:(NSString *)name
                                  context:(NSManagedObjectContext *)context;

+ (instancetype)manufacturerWithName:(NSString *)name context:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSSet * codesets;

@end

@interface BOManufacturer (CoreDataGeneratedAccessors)

- (void)addCodesetsObject:(BOIRCodeset *)codeset;
- (void)removeCodesetsObject:(BOIRCodeset *)codeset;
- (void)addCodesets:(NSSet *)codesets;
- (void)removeCodesets:(NSSet *)codesets;

@end
