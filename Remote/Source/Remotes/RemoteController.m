//
// RemoteController.m
// iPhonto
//
// Created by Jason Cardwell on 7/21/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "RemoteController.h"
#import "Remote.h"
#import "Button.h"
#import "ButtonGroup.h"
#import "ComponentDevice.h"
#import "DeviceConfiguration.h"
#import "Command.h"
#import "CoreDataManager.h"

#define RESET_CURRENT_REMOTE_ON_FETCH

NSString * const   MSRemoteControllerHomeRemoteKeyName = @"MSRemoteControllerHomeRemoteKeyName";
NSString * const   MSRemoteControllerTopToolbarKeyName = @"MSRemoteControllerTopToolbarKeyName";
static int         ddLogLevel                          = DefaultDDLogLevel;

@interface RemoteController ()

/**
 * Compares device configurations for the specified button  with `currentDeviceConfigurations` to
 * determine which devices are no longer needed and should be powered off.
 * @param newDevices The devices that will be utilized by the new activity.
 */
- (void)managePowerForTransitionWithActivityButton:(ActivityButton *)activityButton;

/**
 * Set containing the <ComponentDevice> objects being utilized by the current activity.
 */
@property (nonatomic, strong) NSSet * currentDeviceConfigurations;

@property (nonatomic, strong) NSSet * remoteElements;

@property (nonatomic, strong) NSString * currentRemoteKey;

@end

@implementation RemoteController {
    Remote * _currentRemote;
    Remote * _homeRemote;
}

@dynamic currentRemoteKey, currentActivity, remoteElements, topToolbar;

@synthesize currentDeviceConfigurations = _currentDeviceConfigurations;

- (void)awakeFromFetch {
    [super awakeFromFetch];
#ifdef RESET_CURRENT_REMOTE_ON_FETCH
    [self setPrimitiveValue:MSRemoteControllerHomeRemoteKeyName forKey:@"currentRemoteKey"];
#endif
}

/// @name ￼Creating a RemoteController

+ (RemoteController *)remoteController {
    return [self remoteControllerInContext:[DataManager mainObjectContext]];
}

+ (RemoteController *)remoteControllerInContext:(NSManagedObjectContext *)context {
    NSFetchRequest           * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RemoteController"];
    __block RemoteController * controller   = nil;

    [context performBlockAndWait:^{
                 NSError * error = nil;
                 NSArray * fetchedObjects = [context          executeFetchRequest:fetchRequest
                                                                   error:&error];
                 if (error)
                 DDLogError(@"%@\n\terror retrieving remote controller: %@",
                       ClassTagSelectorString, [error localizedFailureReason]);
        else if (fetchedObjects.count)
                 controller = fetchedObjects[0];
        else
                 controller = [NSEntityDescription      insertNewObjectForEntityForName:@"RemoteController"
                                                            inManagedObjectContext:context];
    }

    ];

    return controller;
}

/// @name Managing activities

- (void)managePowerForTransitionWithActivityButton:(ActivityButton *)activityButton {
    // Use set operations to derive active devices no longer in use

    NSSet * currentDevices    = [_currentDeviceConfigurations valueForKeyPath:@"device"];
    NSSet * transitionDevices = [activityButton.deviceConfigurations valueForKeyPath:@"device"];
    NSSet * unusedDevices     = [currentDevices setByRemovingObjectsFromSet:transitionDevices];

    // Inform devices they should power down
    for (ComponentDevice * device in unusedDevices) {
        [device setPowerStateToState:ComponentDevicePowerOff sender:activityButton];
    }
}

- (void)activityActionForButton:(ActivityButton *)button {
    // No button = no device configurations
    if (!button) return;

    // Manage power for devices in configuration sets
    [self managePowerForTransitionWithActivityButton:button];

    // Update current configurations
    if (button.activityButtonType == ActivityButtonTypeEnd) self.currentDeviceConfigurations = nil;
    else self.currentDeviceConfigurations = button.deviceConfigurations;
}

- (Remote *)currentRemote {
    if (_currentRemote) return _currentRemote;

    NSString * key = self.currentRemoteKey;

    if (StringIsEmpty(self.currentRemoteKey)) return self.homeRemote;

    _currentRemote = [self remoteWithKey:key];

    return _currentRemote;
}

- (Remote *)homeRemote {
    if (_homeRemote) return _homeRemote;

    _homeRemote = [self remoteWithKey:MSRemoteControllerHomeRemoteKeyName];

    return _homeRemote;
}

- (void)setHomeRemote:(Remote *)homeRemote {
    if (homeRemote && ![MSRemoteControllerHomeRemoteKeyName isEqualToString:homeRemote.key]) homeRemote.key = MSRemoteControllerHomeRemoteKeyName;

    _homeRemote = homeRemote;
}

- (Remote *)remoteWithKey:(NSString *)key {
    assert(StringIsNotEmpty(key));

    return [self.remoteElements
            firstObjectPassingTest:^BOOL (RemoteElement * obj, BOOL * stop) {
        return (  [obj isKindOfClass:[Remote class]]
               && [key isEqualToString:obj.key]
               && (*stop = YES));
    }

    ];
}

- (NSArray *)allRemotes {
    return [self.remoteElements
            firstObjectPassingTest:^BOOL (RemoteElement * obj, BOOL * stop) {
        return [obj isKindOfClass:[Remote class]];
    }

    ];
}

- (void)setCurrentRemoteKey:(NSString *)currentRemoteKey {
    [self willChangeValueForKey:@"currentRemote"];
    [self willChangeValueForKey:@"currentRemoteKey"];
    [self setPrimitiveValue:currentRemoteKey forKey:@"currentRemoteKey"];
    _currentRemote = [self remoteWithKey:currentRemoteKey];
    [self didChangeValueForKey:@"currentRemote"];
    [self didChangeValueForKey:@"currentRemoteKey"];
}

- (BOOL)switchToRemoteWithKey:(NSString *)key {
    if (![self remoteWithKey:key]) return NO;

    self.currentRemoteKey = key;

    return YES;
}

- (Remote *)objectForKeyedSubscript:(NSString *)key {
    return [self remoteWithKey:key];
}

@end
