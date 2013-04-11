//
// BankObjectGroup.h
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "MSModelObject.h"
@class BOImage, BOIRCode, BOManufacturer;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Group
////////////////////////////////////////////////////////////////////////////////
@interface BankObjectGroup : MSModelObject

+ (instancetype)defaultGroupInContext:(NSManagedObjectContext *)context;
+ (instancetype)groupWithName:(NSString *)name context:(NSManagedObjectContext *)context;
+ (instancetype)fetchGroupWithName:(NSString *)name context:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSString * name;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Images
////////////////////////////////////////////////////////////////////////////////
@interface BOImageGroup : BankObjectGroup

@property (nonatomic, strong) NSSet * images;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Presets
////////////////////////////////////////////////////////////////////////////////
@interface BOPresetsGroup : BankObjectGroup @end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Codesets
////////////////////////////////////////////////////////////////////////////////
@interface BOIRCodeset : BankObjectGroup

@property (nonatomic, strong) BOManufacturer * manufacturer;
@property (nonatomic, strong) NSSet          * codes;

@end

@interface BOIRCodeset (CoreDataGeneratedAccessors)

- (void)addCodesObject:(BOIRCode *)value;
- (void)removeCodesObject:(BOIRCode *)value;
- (void)addCodes:(NSSet *)values;
- (void)removeCodes:(NSSet *)values;

@end
