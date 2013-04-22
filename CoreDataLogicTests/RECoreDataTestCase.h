//
//  RECoreDataTestCase.h
//  Remote
//
//  Created by Jason Cardwell on 4/19/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSCoreDataTestCase.h"

/**
 * Default behavior is to create its own core data stack and performs its own save operations. 
 * Subclass `REMagicalCoreDataTestCase` can be used for testing with `MagicalRecord` framework.
 */
@interface RECoreDataTestCase : MSCoreDataTestCase @end
