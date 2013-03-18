//
// DataBaseLoader.h
// Remote
//
// Created by Jason Cardwell on 2/19/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

/**
 * `DatabaseLoader` is a singleton class that manages the loading of some of the basic elements such
 * as images, component devices, and IR codes.
 */
@interface DatabaseLoader : NSObject

/// @name ￼Loading data into the database

/**
 * Creates managed objects in the specified context from various files located in the bundle.
 * @param context `NSManagedObjectContext` in which the objects should be created.
 */
+ (BOOL)loadDataIntoContext:(NSManagedObjectContext *)context;

/// @name ￼Logging database content

/**
 * Enumerates all the codes currently in the database and logs them to the console.
 * @note Requires minimum log level of `LOG_LEVEL_INFO`.
 */
+ (void)logCodeBank;

@end
