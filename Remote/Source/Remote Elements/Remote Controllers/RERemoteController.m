//
// RemoteController.m
// Remote
//
// Created by Jason Cardwell on 7/21/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "RERemoteController.h"
#import "REActivity.h"
#import "RemoteElement_Private.h"
#import "REConstraint.h"


#import "BankObject.h"
#import "REDeviceConfiguration.h"
#import "RECommand.h"
#import "CoreDataManager.h"

static int   ddLogLevel   = LOG_LEVEL_DEBUG;
static int   msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)

@interface RERemoteController ()

@property (nonatomic, strong)              NSSet         * currentDeviceConfigurations;
@property (nonatomic, strong, readwrite)   NSSet         * remotes;
@property (nonatomic, strong, readwrite)   NSString      * homeRemoteUUID;
@property (nonatomic, strong, readwrite)   NSString      * currentRemoteUUID;
@property (nonatomic, strong, readwrite)   NSString      * currentActivityUUID;
@property (nonatomic, strong, readwrite)   NSSet         * activities;
@property (nonatomic, strong, readwrite)   REButtonGroup * topToolbar;

@end

@interface RERemoteController (CoreDataGeneratedAccessors)

- (void)addRemotesObject:(RERemote *)remote;
- (void)addActivitiesObject:(REActivity *)activity;

@end

@implementation RERemoteController

@dynamic currentRemoteUUID, currentActivityUUID, homeRemoteUUID;
@dynamic remotes, topToolbar, activities;
@synthesize currentDeviceConfigurations = _currentDeviceConfigurations;


+ (RERemoteController *)remoteController
{
    return [self remoteControllerInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (RERemoteController *)remoteControllerInContext:(NSManagedObjectContext *)context
{
    RERemoteController * controller = [self MR_findFirstInContext:context];
    if (!controller) controller = [self MR_createInContext:context];
    return controller;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Top Toolbar
////////////////////////////////////////////////////////////////////////////////

- (BOOL)registerTopToolbar:(REButtonGroup *)buttonGroup
{
    //TODO: Add validation
    self.topToolbar = buttonGroup;
    return YES;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remotes
////////////////////////////////////////////////////////////////////////////////

- (RERemote *)homeRemote
{
    return (RERemote *)memberOfCollectionWithUUID(self.remotes, self.homeRemoteUUID);
}

- (RERemote *)currentRemote
{
    RERemote * currentRemote = (RERemote *)memberOfCollectionWithUUID(self.remotes,
                                                                      self.currentRemoteUUID);
    return (currentRemote ? : self.homeRemote);
}

- (void)registerRemote:(RERemote *)remote
{
    assert(remote);
    //TODO: Add validation?
    [self addRemotesObject:remote];
}

- (BOOL)registerHomeRemote:(RERemote *)remote
{
    //TODO: Add validation
    [self registerRemote:remote];
    self.homeRemoteUUID = remote.uuid;
    return YES;
}

- (BOOL)switchToRemote:(RERemote *)remote
{
    if ([self.remotes containsObject:remote])
    {
        [self willChangeValueForKey:@"currentRemote"];
        self.currentRemoteUUID = remote.uuid;
        [self didChangeValueForKey:@"currentRemote"];
        
        if (remote == self.homeRemote) self.currentActivityUUID = nil;

        return YES;
    }

    else return NO;
}

- (RERemote *)objectForKeyedSubscript:(NSString *)key
{
    return [self.remotes objectPassingTest:
            ^BOOL (RERemote * remote) { return REStringIdentifiesRemoteElement(key, remote); }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Activities
////////////////////////////////////////////////////////////////////////////////

- (REActivity *)currentActivity
{
    REActivity * currentActivity = (REActivity *)memberOfCollectionWithUUID(self.activities,
                                                                            self.currentActivityUUID);
    return currentActivity;
}

- (BOOL)registerActivity:(REActivity *)activity
{
    assert(activity);
    if ([self.activities containsObject:activity])
        return YES;

    else if ([self.activities containsObjectWithValue:activity.name forKey:@"name"])
        return NO;

    else
    {
        [self addActivitiesObject:activity];
        return YES;
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Switching
////////////////////////////////////////////////////////////////////////////////

- (BOOL)switchToActivity:(REActivity *)activity
{
    if ([self.activities containsObject:activity])
    { //TODO: Need to add parameter to halt/launch to suppress uneccessary power toggling
        if (self.currentActivityUUID) [self.currentActivity haltActivity];
        self.currentActivityUUID = activity.uuid;
        return YES;
    }

    else
        return NO;
}

@end
