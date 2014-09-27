//
// RemoteController.h
// Remote
//
// Created by Jason Cardwell on 7/21/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
@import Lumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"
#import "ModelObject.h"
@protocol CommandDelegate;

@class Remote, ButtonGroup, Activity, RemoteViewController;

/**
 * `RemoteController` is a subclass of `NSManagedObject` that coordinates multiple <Remote>
 * objects to give the user dynamic control over their home theater system. It serves as a model
 * for a <RemoteViewController>, which acts as the primary controller for views associated with
 * actually implenting the remote control functionality within the application. One remote can be
 * designated as the 'home' remote to serve as the base for loading other remotes.
 */
@interface RemoteController : ModelObject


+ (RemoteController *)remoteController:(NSManagedObjectContext *)moc;

@property (nonatomic, strong, readonly)  RemoteViewController * viewController;
@property (nonatomic, strong, readwrite) Remote               * currentRemote;
@property (nonatomic, strong, readwrite) Remote               * homeRemote;
@property (nonatomic, strong, readwrite) Activity             * currentActivity;
@property (nonatomic, strong, readonly)  NSArray              * activities;
@property (nonatomic, strong, readwrite) ButtonGroup          * topToolbar;

@end
