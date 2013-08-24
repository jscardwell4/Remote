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

@interface RERemoteBuilder (Developer)

+ (RERemote *)constructDVRRemoteInContext:(NSManagedObjectContext *)moc;
+ (RERemote *)constructHomeRemoteInContext:(NSManagedObjectContext *)moc;
+ (RERemote *)constructPS3RemoteInContext:(NSManagedObjectContext *)moc;
+ (RERemote *)constructSonosRemoteInContext:(NSManagedObjectContext *)moc;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros
////////////////////////////////////////////////////////////////////////////////

@interface REMacroBuilder (Developer)

+ (REMacroCommand *)activityMacroForActivity:(NSUInteger)activity
                             toInitiateState:(BOOL)isOnState
                                     context:(NSManagedObjectContext *)moc;

+ (NSSet *)deviceConfigsForActivity:(NSUInteger)activity context:(NSManagedObjectContext *)moc;


@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Groups
////////////////////////////////////////////////////////////////////////////////

@interface REButtonGroupBuilder (Developer)

+ (REButtonGroup *) constructControllerTopToolbarInContext:(NSManagedObjectContext *)moc;

// Home screen
+ (REButtonGroup *)constructActivitiesInContext:(NSManagedObjectContext *)moc;
+ (REButtonGroup *)constructLightControlsInContext:(NSManagedObjectContext *)moc;

// DPad construction
+ (REButtonGroup *)constructDVRDPadInContext:(NSManagedObjectContext *)moc;
+ (REButtonGroup *)constructPS3DPadInContext:(NSManagedObjectContext *)moc;

// ￼NumberPad construction
+ (REButtonGroup *)constructDVRNumberPadInContext:(NSManagedObjectContext *)moc;
+ (REButtonGroup *)constructPS3NumberPadInContext:(NSManagedObjectContext *)moc;

// Transport construction
+ (REButtonGroup *)constructDVRTransportInContext:(NSManagedObjectContext *)moc;
+ (REButtonGroup *)constructPS3TransportInContext:(NSManagedObjectContext *)moc;

// Rocker construction
+ (REPickerLabelButtonGroup *)constructDVRRockerInContext:(NSManagedObjectContext *)moc;
+ (REPickerLabelButtonGroup *)constructPS3RockerInContext:(NSManagedObjectContext *)moc;
+ (REPickerLabelButtonGroup *)constructSonosRockerInContext:(NSManagedObjectContext *)moc;

// Constructing other button groups
+ (REButtonGroup *)constructSonosMuteButtonGroupInContext:(NSManagedObjectContext *)moc;
+ (REButtonGroup *)constructSelectionPanelInContext:(NSManagedObjectContext *)moc;
+ (REButtonGroup *)constructDVRGroupOfThreeButtonsInContext:(NSManagedObjectContext *)moc;
+ (REButtonGroup *)constructPS3GroupOfThreeButtonsInContext:(NSManagedObjectContext *)moc;
+ (REButtonGroup *)constructAdditionalButtonsLeftInContext:(NSManagedObjectContext *)moc;
+ (REButtonGroup *)constructHomeAndPowerButtonsForActivity:(NSInteger)activity
                                                   context:(NSManagedObjectContext *)moc;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Command Sets
////////////////////////////////////////////////////////////////////////////////
@class RECommandSet;

@interface RECommandSetBuilder (Developer)

+ (RECommandSet *)avReceiverVolumeCommandSet:(NSManagedObjectContext *)moc;
+ (RECommandSet *)dvrChannelsCommandSet:(NSManagedObjectContext *)moc;
+ (RECommandSet *)dvrPagingCommandSet:(NSManagedObjectContext *)moc;
+ (RECommandSet *)transportForDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)moc;
+ (RECommandSet *)numberPadForDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)moc;
+ (RECommandSet *)dPadForDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)moc;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Buttons
////////////////////////////////////////////////////////////////////////////////

@interface REButtonBuilder (Developer) @end
