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

+ (instancetype)bankObjectInContext:(NSManagedObjectContext *)context
{
    assert(context);
    __block BankObject * object = nil;
    [context performBlockAndWait:^{ object = NSManagedObjectFromClass(context); }];
    return object;
}

+ (instancetype)bankObjectWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    assert(name && context);
    __block BankObject * bankObject = nil;
    [context performBlockAndWait:
     ^{
         bankObject = [self bankObjectInContext:context];
         bankObject.name = name;
     }];
    return bankObject;
}

/*
- (void)willSave
{
    [super willSave];
    nsprintf(@"%@", ClassTagSelectorStringForInstance($(@"%p",self)));
}
*/

@end
