//
// IRCodeSet.m
// iPhonto
//
// Created by Jason Cardwell on 3/19/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "IRCodeSet.h"
#import "IRCode.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation IRCodeSet

@dynamic name;
@dynamic manufacturer;
@dynamic codes;

+ (IRCodeSet *)newCodeSetInContext:(NSManagedObjectContext *)context
                          withName:(NSString *)codeSetName {
    if (ValueIsNil(context) || ValueIsNil(codeSetName)) return nil;

    IRCodeSet * codeSet = [NSEntityDescription insertNewObjectForEntityForName:@"IRCodeSet"
                                                        inManagedObjectContext:context];

    codeSet.name = codeSetName;

    return codeSet;
}

@end
