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
    RemoteController * controller = [self findFirstInContext:context];
    if (!controller) controller = [self createInContext:context];
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
    if (uuid) remote = [Remote existingObjectWithUUID:uuid context:self.managedObjectContext];
    return remote;
}

- (Remote *)currentRemote
{
    Remote * remote = nil;
    NSString * uuid = self.currentRemoteUUID;
    if (uuid) remote = [Remote existingObjectWithUUID:uuid context:self.managedObjectContext];
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

- (ButtonGroup *)topToolbar {
    ButtonGroup * buttonGroup = nil;
    [self willAccessValueForKey:@"topToolbar"];
    buttonGroup = (ButtonGroup *)[self primitiveValueForKey:@"topToolbar"];
    [self didAccessValueForKey:@"topToolbar"];
/*
    if (!buttonGroup) {
        NSManagedObjectContext * moc = self.managedObjectContext;

        buttonGroup = [ButtonGroup buttonGroupWithRole:REButtonGroupRoleToolbar context:moc];
        buttonGroup.name = @"Top Toolbar";

        Button * home = [Button buttonWithRole:REButtonRoleToolbar context:moc];
        home.name = @"Home Button";
        Command * command = [SystemCommand commandWithType:SystemCommandLaunchScreen
                                                 inContext:moc];
        home.command = command;

        ControlStateImageSet * icons = [ControlStateImageSet
                                        imageSetWithImages:@{@"normal":
                                                                 @"7C7C50AF-6DD5-467C-A558-DCEB4B6A05A6"}
                                        context:moc];
        [home setIcons:icons mode:REDefaultMode];


        Button * settings = [Button buttonWithRole:REButtonRoleToolbar context:moc];
        settings.name = @"Settings Button";
        command = [SystemCommand commandWithType:SystemCommandOpenSettings inContext:moc];
        settings.command = command;
        icons = [ControlStateImageSet imageSetWithImages:@{@"normal":
                                                               @"2A778160-8A33-49B0-AE53-D9B45786FFA7"}
                                                 context:moc];
        [settings setIcons:icons mode:REDefaultMode];

        Button * editRemote = [Button buttonWithRole:REButtonRoleToolbar context:moc];
        editRemote.name = @"Edit Remote Button";
        command = [SystemCommand commandWithType:SystemCommandOpenEditor inContext:moc];
        editRemote.command = command;
        icons = [ControlStateImageSet imageSetWithImages:@{@"normal":
                                                               @"1132E160-C278-406A-A6AD-3EF817DCAA4E"}
                                                 context:moc];
        [editRemote setIcons:icons mode:REDefaultMode];

        Button * battery = [Button buttonWithRole:REButtonRoleBatteryStatus context:moc];

        Button * connection = [Button buttonWithRole:REButtonRoleConnectionStatus context:moc];

        [buttonGroup addSubelements:[@[home, settings, editRemote, battery, connection] orderedSet]];

        [buttonGroup
         setConstraintsFromString:[@"home.left = buttonGroup.left + 4\n"
                                   "settings.left = home.right + 20\n"
                                   "editRemote.left = settings.right + 20\n"
                                   "battery.left = editRemote.right + 20\n"
                                   "connection.left = battery.right + 20\n"
                                   "settings.width = home.width\n"
                                   "editRemote.width = home.width\n"
                                   "battery.width = home.width\n"
                                   "connection.width = home.width\n"
                                   "home.height = buttonGroup.height\n"
                                   "settings.height = buttonGroup.height\n"
                                   "editRemote.height = buttonGroup.height\n"
                                   "battery.height = buttonGroup.height\n"
                                   "connection.height = buttonGroup.height\n"
                                   "home.centerY = buttonGroup.centerY\n"
                                   "settings.centerY = buttonGroup.centerY\n"
                                   "editRemote.centerY = buttonGroup.centerY\n"
                                   "battery.centerY = buttonGroup.centerY\n"
                                   "connection.centerY = buttonGroup.centerY" stringByReplacingOccurrencesWithDictionary:
                                   NSDictionaryOfVariableBindingsToIdentifiers(buttonGroup,
                                                                               home,
                                                                               settings,
                                                                               editRemote,
                                                                               battery,
                                                                               connection)]];
        [home setConstraintsFromString:[@"home.width ≥ 44"
                                        stringByReplacingOccurrencesWithDictionary:
                                        NSDictionaryOfVariableBindingsToIdentifiers(home)]];

    }
*/

    return buttonGroup;
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

- (void)updateWithData:(NSDictionary *)data {
    /*
     "uuid": "01844614-744C-4664-BF8F-ABF948CE5996",
     "homeRemoteUUID": "B0EA5B35-5CF6-40E9-B302-0F164D4A7ADD", // Home Screen
     "topToolbar": { **ButtonGroup** },
     "activities": [ **Activity** ]
     */

    [super updateWithData:data];

    NSString               * homeRemoteUUID = data[@"homeRemoteUUID"];
    id                       topToolbar     = data[@"topToolbar"];
    NSArray                * activities     = data[@"activities"];
    NSManagedObjectContext * moc            = self.managedObjectContext;

    if (UUIDIsValid(homeRemoteUUID)) self.homeRemoteUUID = homeRemoteUUID;

    if (topToolbar) {

        if ([topToolbar isKindOfClass:[NSString class]] && UUIDIsValid(topToolbar)) {

            ButtonGroup * t = [ButtonGroup existingObjectWithUUID:topToolbar context:moc];
            if (!t) t = [ButtonGroup objectWithUUID:topToolbar context:moc];
            self.topToolbar = t;

        } else if ([topToolbar isKindOfClass:[NSDictionary class]]) {

            self.topToolbar = [ButtonGroup importObjectFromData:topToolbar inContext:moc];

        }

    }

    if (activities) {

        NSMutableSet * controllerActivities = [NSMutableSet set];

        for (id activity in activities) {

            if ([activity isKindOfClass:[NSString class]] && UUIDIsValid(activity)) {

                Activity * a = [Activity existingObjectWithUUID:activity context:moc];

                if (!a) a = [Activity objectWithUUID:activity context:moc];

                [controllerActivities addObject:a];

            } else if ([activity isKindOfClass:[NSDictionary class]]) {

                Activity * a = [Activity importObjectFromData:activity inContext:moc];

                if (a) [controllerActivities addObject:a];

            }

        }

        if ([controllerActivities count] > 0) self.activities = controllerActivities;
        
    }

}

@end
