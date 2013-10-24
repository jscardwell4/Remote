//
//  RemoteElementConstructionManager_Private.h
//  Remote
//
//  Created by Jason Cardwell on 7/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementConstructionManager.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remotes
////////////////////////////////////////////////////////////////////////////////

@interface RemoteBuilder (Developer)

+ (Remote *)constructDVRRemoteInContext:(NSManagedObjectContext *)moc;
+ (Remote *)constructHomeRemoteInContext:(NSManagedObjectContext *)moc;
+ (Remote *)constructPS3RemoteInContext:(NSManagedObjectContext *)moc;
+ (Remote *)constructSonosRemoteInContext:(NSManagedObjectContext *)moc;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros
////////////////////////////////////////////////////////////////////////////////

@interface MacroBuilder (Developer)

+ (MacroCommand *)activityMacroForActivity:(NSUInteger)activity
                             toInitiateState:(BOOL)isOnState
                                     context:(NSManagedObjectContext *)moc;

+ (NSSet *)deviceConfigsForActivity:(NSUInteger)activity context:(NSManagedObjectContext *)moc;


@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Groups
////////////////////////////////////////////////////////////////////////////////

@interface ButtonGroupBuilder (Developer)

+ (ButtonGroup *) constructControllerTopToolbarInContext:(NSManagedObjectContext *)moc;

// Home screen
+ (ButtonGroup *)constructActivitiesInContext:(NSManagedObjectContext *)moc;
+ (ButtonGroup *)constructLightControlsInContext:(NSManagedObjectContext *)moc;

// DPad construction
+ (ButtonGroup *)constructDVRDPadInContext:(NSManagedObjectContext *)moc;
+ (ButtonGroup *)constructPS3DPadInContext:(NSManagedObjectContext *)moc;

// ￼Numberpad construction
+ (ButtonGroup *)constructDVRNumberpadInContext:(NSManagedObjectContext *)moc;
+ (ButtonGroup *)constructPS3NumberpadInContext:(NSManagedObjectContext *)moc;

// Transport construction
+ (ButtonGroup *)constructDVRTransportInContext:(NSManagedObjectContext *)moc;
+ (ButtonGroup *)constructPS3TransportInContext:(NSManagedObjectContext *)moc;

// Rocker construction
+ (ButtonGroup *)constructDVRRockerInContext:(NSManagedObjectContext *)moc;
+ (ButtonGroup *)constructPS3RockerInContext:(NSManagedObjectContext *)moc;
+ (ButtonGroup *)constructSonosRockerInContext:(NSManagedObjectContext *)moc;

// Constructing other button groups
+ (ButtonGroup *)constructSonosMuteButtonGroupInContext:(NSManagedObjectContext *)moc;
+ (ButtonGroup *)constructSelectionPanelInContext:(NSManagedObjectContext *)moc;
+ (ButtonGroup *)constructDVRGroupOfThreeButtonsInContext:(NSManagedObjectContext *)moc;
+ (ButtonGroup *)constructPS3GroupOfThreeButtonsInContext:(NSManagedObjectContext *)moc;
+ (ButtonGroup *)constructAdditionalButtonsLeftInContext:(NSManagedObjectContext *)moc;
+ (ButtonGroup *)constructHomeAndPowerButtonsForActivity:(NSInteger)activity
                                                   context:(NSManagedObjectContext *)moc;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Command Sets
////////////////////////////////////////////////////////////////////////////////
@class CommandSet;

@interface CommandSetBuilder (Developer)

+ (CommandSet *)avReceiverVolumeCommandSet:(NSManagedObjectContext *)moc;
+ (CommandSet *)hopperChannelsCommandSet:(NSManagedObjectContext *)moc;
+ (CommandSet *)hopperPagingCommandSet:(NSManagedObjectContext *)moc;
+ (CommandSet *)transportForDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)moc;
+ (CommandSet *)numberpadForDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)moc;
+ (CommandSet *)dPadForDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)moc;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Buttons
////////////////////////////////////////////////////////////////////////////////

@interface ButtonBuilder (Developer) @end
