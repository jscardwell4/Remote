//
// RemoteController.m
// Remote
//
// Created by Jason Cardwell on 7/21/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "RemoteController.h"
#import "Activity.h"
#import "RemoteElement_Private.h"
#import "Constraint.h"
#import "ComponentDeviceConfiguration.h"
#import "Command.h"
#import "CoreDataManager.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)

@interface RemoteController ()

@property (nonatomic, strong)              NSSet       * currentDeviceConfigurations;
@property (nonatomic, strong, readwrite)   NSString    * homeRemoteUUID;
@property (nonatomic, strong, readwrite)   NSString    * currentRemoteUUID;
@property (nonatomic, strong, readwrite)   NSString    * currentActivityUUID;
@property (nonatomic, strong, readwrite)   NSSet       * activities;
@property (nonatomic, strong, readwrite)   ButtonGroup * topToolbar;

@end

@interface RemoteController (CoreDataGeneratedAccessors)

- (void)addActivitiesObject:(Activity *)activity;

@end

@implementation RemoteController

@dynamic currentRemoteUUID, currentActivityUUID, homeRemoteUUID;
@dynamic topToolbar, activities;
@synthesize currentDeviceConfigurations = _currentDeviceConfigurations;


+ (RemoteController *)remoteController
{
    return [self remoteControllerInContext:[CoreDataManager defaultContext]];
}

+ (RemoteController *)remoteControllerInContext:(NSManagedObjectContext *)context
{
    RemoteController * controller = [self MR_findFirstInContext:context];
    if (!controller) controller = [self MR_createInContext:context];
    return controller;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Top toolbar
////////////////////////////////////////////////////////////////////////////////

- (BOOL)registerTopToolbar:(ButtonGroup *)buttonGroup
{
    //TODO: Add validation
    self.topToolbar = buttonGroup;
    return YES;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Remotes
////////////////////////////////////////////////////////////////////////////////

- (Remote *)homeRemote
{
    Remote * remote = nil;
    NSString * uuid = self.homeRemoteUUID;
    if (uuid) remote = [Remote objectWithUUID:uuid context:self.managedObjectContext];
    return remote;
}

- (Remote *)currentRemote
{
    Remote * remote = nil;
    NSString * uuid = self.currentRemoteUUID;
    if (uuid) remote = [Remote objectWithUUID:uuid context:self.managedObjectContext];
    return remote;
}

- (BOOL)switchToRemote:(Remote *)remote
{
    if (remote)
    {
        [self willChangeValueForKey:@"currentRemote"];
        self.currentRemoteUUID = remote.uuid;
        [self didChangeValueForKey:@"currentRemote"];
        
        if (remote == self.homeRemote) self.currentActivityUUID = nil;

        return YES;
    }

    else return NO;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Activities
////////////////////////////////////////////////////////////////////////////////


- (Activity *)currentActivity
{
    return (Activity *)memberOfCollectionWithUUID(self.activities, self.currentActivityUUID);
}

- (BOOL)registerActivity:(Activity *)activity
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

- (BOOL)switchToActivity:(Activity *)activity
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


////////////////////////////////////////////////////////////////////////////////
#pragma mark JSON export
////////////////////////////////////////////////////////////////////////////////

- (MSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];

    dictionary[@"homeRemoteUUID"]      = CollectionSafe(self.homeRemote.commentedUUID);
    dictionary[@"currentRemoteUUID"]   = CollectionSafe(self.currentRemote.commentedUUID);
    dictionary[@"currentActivityUUID"] = CollectionSafe(self.currentActivity.commentedUUID);
    dictionary[@"topToolbar"]          = CollectionSafe([self.topToolbar JSONDictionary]);
    id activities = CollectionSafeSelfKeyPathValue(@"activities.JSONDictionary");
    if (isSetKind(activities))
    {
        NSMutableArray * activitiesArray = [[(NSSet *)activities allObjects] mutableCopy];
        [activitiesArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                              ascending:YES]]];
        dictionary[@"activities"] = activitiesArray;
    }

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////

- (BOOL)shouldImportTopToolbar:(id)data {return YES;}
- (BOOL)shouldImportActivities:(id)data {return YES;}

@end
