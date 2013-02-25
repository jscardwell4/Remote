//
//  MSAppDelegate.h
//  Remote
//
//  Created by Jason Cardwell on 2/25/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
