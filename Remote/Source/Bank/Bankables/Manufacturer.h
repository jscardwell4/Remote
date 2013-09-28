//
// Manufacturer.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BankableModelObject.h"

@class IRCodeset, ComponentDevice;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Manufacturer
////////////////////////////////////////////////////////////////////////////////

@interface Manufacturer : BankableModelObject

+ (instancetype)manufacturerWithName:(NSString *)name context:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSSet * codesets;
@property (nonatomic, strong) NSSet * devices;

@end

@interface Manufacturer (CoreDataGeneratedAccessors)

- (void)addCodesetsObject:(IRCodeset *)codeset;
- (void)removeCodesetsObject:(IRCodeset *)codeset;
- (void)addCodesets:(NSSet *)codesets;
- (void)removeCodesets:(NSSet *)codesets;

@end
