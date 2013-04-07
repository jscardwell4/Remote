//
// CoreDataManager.h
// Remote
//
// Created by Jason Cardwell on 3/21/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@interface CoreDataManager : NSObject

/**
 * Sets up the core data stack using the Magical Record framework.
 * @return Whether setup was successful
 */
+ (BOOL)initializeDatabase;

@end
