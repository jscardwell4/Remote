//
// BankObjectGroup.h
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
@class Image, IRCode, Manufacturer;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Group
////////////////////////////////////////////////////////////////////////////////
@interface BankObjectGroup : ModelObject <NamedModelObject>

+ (instancetype)groupWithName:(NSString *)name context:(NSManagedObjectContext *)context;
+ (instancetype)fetchGroupWithName:(NSString *)name context:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSString * name;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Images
////////////////////////////////////////////////////////////////////////////////
@interface BOImageGroup : BankObjectGroup

- (Image *)objectAtIndexedSubscript:(NSUInteger)idx;

- (Image *)objectForKeyedSubscript:(NSString *)key;

@property (nonatomic, strong) NSSet * images;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Codesets
////////////////////////////////////////////////////////////////////////////////
@interface BOIRCodeset : BankObjectGroup

@property (nonatomic, strong) Manufacturer * manufacturer;
@property (nonatomic, strong) NSSet          * codes;

@end

@interface BOIRCodeset (CoreDataGeneratedAccessors)

- (void)addCodesObject:(IRCode *)value;
- (void)removeCodesObject:(IRCode *)value;
- (void)addCodes:(NSSet *)values;
- (void)removeCodes:(NSSet *)values;

@end
