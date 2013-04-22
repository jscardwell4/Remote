//
//  REMagicalCoreDataTestCase.m
//  Remote
//
//  Created by Jason Cardwell on 4/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REMagicalCoreDataTestCase.h"

@implementation REMagicalCoreDataTestCase

/**
 * Returns options for using `MagicalRecord` to setup core data stack with in-memory store, as well 
 * as to use the `MagicalRecord` framework for save operations.
 */
+ (MSCoreDataTestOptions)options { return MSCoreDataTestMagicalSaves|MSCoreDataTestMagicalSetup; }

/// Overridden to create more specific store
+ (NSString *)storeName { return @"REMagicalCoreDataTestCase.sqlite"; }

@end
