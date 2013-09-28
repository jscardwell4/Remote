//
// BankGroup.h
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
@interface BankGroup : ModelObject <NamedModelObject>

+ (instancetype)groupWithName:(NSString *)name context:(NSManagedObjectContext *)context;
+ (instancetype)fetchGroupWithName:(NSString *)name context:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSString * name;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Images
////////////////////////////////////////////////////////////////////////////////
@interface ImageGroup : BankGroup

@property (nonatomic, strong) NSSet * images;

@end

@interface ImageGroup (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Codesets
////////////////////////////////////////////////////////////////////////////////
@interface IRCodeset : BankGroup

@property (nonatomic, strong) Manufacturer * manufacturer;
@property (nonatomic, strong) NSSet          * codes;

@end

@interface IRCodeset (CoreDataGeneratedAccessors)

- (void)addCodesObject:(IRCode *)value;
- (void)removeCodesObject:(IRCode *)value;
- (void)addCodes:(NSSet *)values;
- (void)removeCodes:(NSSet *)values;

@end
