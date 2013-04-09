//
// FactoryIRCode.m
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BankObject.h"
#import "BankObjectGroup.h"

@implementation BOFactoryIRCode

@dynamic codeset;

+ (BOIRCode *)codeForCodeset:(BOIRCodeset *)set
{
    assert(set);
    __block BOFactoryIRCode * code = nil;
    [set.managedObjectContext performBlockAndWait:
     ^{
         code = [self bankObjectInContext:set.managedObjectContext];
         code.codeset = set;
     }];
    return code;
}

@end
