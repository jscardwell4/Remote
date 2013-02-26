//
// CommandContainer.m
// iPhonto
//
// Created by Jason Cardwell on 6/29/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "CommandContainer.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation CommandContainer

/*
 * isValidKey:
 */
+ (BOOL)isValidKey:(NSString *)key {
    return NO;
}

/*
 * isValidKey:
 */
- (BOOL)isValidKey:(NSString *)key {
    return [[self class] isValidKey:key];
}

@end
