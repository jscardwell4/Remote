//
// FactoryIRCode.m
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "FactoryIRCode.h"
#import "IRCodeSet.h"
#import "IRCode_Private.h"

@implementation FactoryIRCode

@dynamic codeSet;

+ (IRCode *)newCodeInCodeSet:(IRCodeSet *)set {
    if (ValueIsNil(set)) return nil;

    FactoryIRCode * code = [NSEntityDescription insertNewObjectForEntityForName:@"FactoryIRCode"
                                                         inManagedObjectContext:set.managedObjectContext];

    code.codeSet       = set;
    code.factoryObject = YES;

    return code;
}

+ (IRCode *)newCodeFromProntoHex:(NSString *)hex inCodeSet:(IRCodeSet *)set {
    if (ValueIsNil(set)) return nil;

    FactoryIRCode * code = [NSEntityDescription insertNewObjectForEntityForName:@"FactoryIRCode"
                                                         inManagedObjectContext:set.managedObjectContext];

    code.codeSet       = set;
    code               = [code initWithProntoHex:hex];
    code.factoryObject = YES;

    return code;
}

@end
