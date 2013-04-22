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

/**
 * Provides a detailed description of the specified managed object model suitable for logging.
 * @param model The model to describe, or nil for the default model
 * @return String containing a description of the managed object model
 */
+ (NSString *)objectModelDescription:(NSManagedObjectModel *)model;

/**
 * Makes a mutable copy of the specified managed object model and modifies various attribute description 
 * class value names and default values.
 * @param model The editable managed object model to modify
 * @return The edited model or nil if the specified model was uneditable or incompatible
 */
+ (NSManagedObjectModel *)augmentModel:(NSManagedObjectModel *)model;

+ (void)handleErrors:(NSError *)error;

@end
