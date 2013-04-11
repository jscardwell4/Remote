//
// BankObject.m
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "BankObject.h"

@implementation BankObject

@dynamic name;
@dynamic category;
@dynamic exportFileFormat;
@dynamic factoryObject;

+ (instancetype)bankObject
{
    return [self MR_createEntity];
}

+ (instancetype)bankObjectInContext:(NSManagedObjectContext *)context
{
    return [self MR_createInContext:context];
}

+ (instancetype)bankObjectWithName:(NSString *)name
{
    BankObject * bankObject = [self bankObject];
    bankObject.name = name;
    return bankObject;
}

+ (instancetype)bankObjectWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    BankObject * bankObject = [self bankObjectInContext:context];
    bankObject.name = name;
    return bankObject;
}

@end
