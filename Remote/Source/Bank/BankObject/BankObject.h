//
// BankObject.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BOTypedefs.h"
#import "RETypedefs.h"
#import "MSModelObject.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Bank Object
////////////////////////////////////////////////////////////////////////////////

@interface BankObject : MSModelObject <MSNamedModelObject>

+ (instancetype)bankObject;
+ (instancetype)bankObjectInContext:(NSManagedObjectContext *)context;
+ (instancetype)bankObjectWithName:(NSString *)name;
+ (instancetype)bankObjectWithName:(NSString *)name context:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * category;
@property (nonatomic, strong) NSString * subcategory;
@property (nonatomic, strong) NSString * exportFileFormat;
@property (nonatomic) BOOL               factoryObject;

@end

