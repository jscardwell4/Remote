//
// DataBaseLoader.h
// Remote
//
// Created by Jason Cardwell on 2/19/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import MoonKit;
#import "MSRemoteMacros.h"

/**
 * `DatabaseLoader` is a singleton class that manages the loading of some of the basic elements such
 * as images, component devices, and IR codes.
 */
@interface DatabaseLoader : NSObject

/**
 * Creates managed objects in the context created for the current thread of operation
 */
 + (BOOL)loadData;

@end
