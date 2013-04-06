//
// RemoteController.m
// Remote
//
// Created by Jason Cardwell on 7/21/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "RERemoteController.h"

#import "RemoteElement_Private.h"
#import "REConstraint.h"


#import "BankObject.h"
#import "REDeviceConfiguration.h"
#import "RECommand.h"
#import "CoreDataManager.h"


MSKIT_STRING_CONST   MSRemoteControllerHomeRemoteKeyName = @"MSRemoteControllerHomeRemoteKeyName";
MSKIT_STRING_CONST   MSRemoteControllerTopToolbarKeyName = @"MSRemoteControllerTopToolbarKeyName";

static int   ddLogLevel   = LOG_LEVEL_DEBUG;
static int   msLogContext = REMOTE_F_C;

@interface RERemoteController ()

/**
 * Compares device configurations for the specified button  with `currentDeviceConfigurations` to
 * determine which devices are no longer needed and should be powered off.
 * @param newDevices The devices that will be utilized by the new activity.
 */
- (void)managePowerForTransitionWithActivityButton:(REActivityButton *)activityButton
                                        completion:(void (^)(BOOL finished, BOOL success))completion;

/**
 * Set containing the <ComponentDevice> objects being utilized by the current activity.
 */
@property (nonatomic, strong) NSSet * currentDeviceConfigurations;

@property (nonatomic, strong) NSSet * remoteElements;

@property (nonatomic, strong) NSString * currentRemoteKey;

@end

@interface RERemoteController (CoreDataGeneratedAccessors)

- (void)setPrimitiveCurrentRemoteKey:(NSString *)currentRemoteKey;

@end

@implementation RERemoteController {
    RERemote     * _currentRemote;
    RERemote     * _homeRemote;
}

@dynamic currentRemoteKey, currentActivity, remoteElements, topToolbar;

@synthesize currentDeviceConfigurations = _currentDeviceConfigurations;

- (void)awakeFromFetch {
    [super awakeFromFetch];
    self.currentRemoteKey = MSRemoteControllerHomeRemoteKeyName;
}

/*
- (void)willSave
{
    [super willSave];
    nsprintf(@"%@", ClassTagSelectorStringForInstance($(@"%p",self)));
}
*/


/// @name ￼Creating a RemoteController

+ (RERemoteController *)remoteController {
    return [self remoteControllerInContext:[[CoreDataManager sharedManager] mainObjectContext]];
}

+ (RERemoteController *)remoteControllerInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RERemoteController"];
    __block RERemoteController * controller = nil;

    [context performBlockAndWait:^{
                 NSError * error = nil;
                 NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest
                                                                   error:&error];
                 if (error)
                     MSLogError(@"%@\n\terror retrieving remote controller: %@",
                                ClassTagSelectorString, [error localizedFailureReason]);
                 else if (fetchedObjects.count > 1)
                     MSLogError(@"there should only be one controller");

                 else if (fetchedObjects.count)
                     controller = fetchedObjects[0];
                 else
                     controller = NSManagedObjectFromClass(context);
    }];

    return controller;
}

/// @name Managing activities

- (void)managePowerForTransitionWithActivityButton:(REActivityButton *)activityButton
                                        completion:(void (^)(BOOL, BOOL))completion
{
    // Use set operations to derive active devices no longer in use

    NSSet * currentDevices    = [_currentDeviceConfigurations valueForKeyPath:@"device"];
    NSSet * transitionDevices = [activityButton.deviceConfigurations valueForKeyPath:@"device"];
    NSSet * unusedDevices     = [currentDevices setByRemovingObjectsFromSet:transitionDevices];

    // Inform devices they should power down
    for (BOComponentDevice * device in unusedDevices) [device powerOff:nil];
}

- (void)activityActionForButton:(REActivityButton *)button completion:(void (^)(BOOL, BOOL))completion
{
    // No button = no device configurations
    if (!button) { if (completion) completion(YES,NO); return; }

    // Manage power for devices in configuration sets
    [self managePowerForTransitionWithActivityButton:button completion:completion];

    // Update current configurations
    if (button.activityButtonType == REActivityButtonTypeEnd) self.currentDeviceConfigurations = nil;
    else self.currentDeviceConfigurations = button.deviceConfigurations;

    if (completion) completion(YES, YES);
}

- (RERemote *)currentRemote {
    if (_currentRemote) return _currentRemote;

    NSString * key = self.currentRemoteKey;

    if (StringIsEmpty(self.currentRemoteKey)) return self.homeRemote;

    _currentRemote = self[key];

    return _currentRemote;
}

- (RERemote *)homeRemote {
    if (_homeRemote) return _homeRemote;

    _homeRemote = self[MSRemoteControllerHomeRemoteKeyName];

    return _homeRemote;
}

- (void)setHomeRemote:(RERemote *)homeRemote {
    if (homeRemote && ![MSRemoteControllerHomeRemoteKeyName isEqualToString:homeRemote.key])
        homeRemote.key = MSRemoteControllerHomeRemoteKeyName;

    _homeRemote = homeRemote;
}

- (NSArray *)allRemotes {
    return [[self.remoteElements objectsPassingTest:^BOOL (RemoteElement * obj, BOOL * stop)
             { return [obj isKindOfClass:[RERemote class]]; }] allObjects];
}

- (void)setCurrentRemoteKey:(NSString *)currentRemoteKey {
    [self willChangeValueForKey:@"currentRemote"];
    [self willChangeValueForKey:@"currentRemoteKey"];
    [self setPrimitiveCurrentRemoteKey:currentRemoteKey];
    _currentRemote = self[currentRemoteKey];
    [self didChangeValueForKey:@"currentRemote"];
    [self didChangeValueForKey:@"currentRemoteKey"];
}

- (BOOL)switchToRemoteWithKey:(NSString *)key {
    if (!self[key]) return NO;

    self.currentRemoteKey = key;

    return YES;
}

- (RERemote *)objectForKeyedSubscript:(NSString *)key {
    return [self.remoteElements objectPassingTest:^BOOL (RemoteElement * obj) {
        return [obj isKindOfClass:[RERemote class]] && REStringIdentifiesRemoteElement(key, obj);}];
}

@end
