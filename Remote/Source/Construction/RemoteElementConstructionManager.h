//
// RemoteElementConstructionManager.h
// Remote
//
// Created by Jason Cardwell on 10/23/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RETypedefs.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Construction Manager
////////////////////////////////////////////////////////////////////////////////

@interface RemoteElementConstructionManager : NSObject

+ (void)buildControllerInContext:(NSManagedObjectContext *)context;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remotes
////////////////////////////////////////////////////////////////////////////////
@class RERemote;

/**
 * `RemoteBuilder` is a singleton class that, when provided with an `NSManagedObjectContext`, can
 * fetch or create a <RemoteController> object and construct a multitude of elements that together
 * form a fully realized remote control interface. Currently this class is used for testing
 * purposes.
 */
@interface RERemoteBuilder : NSObject

+ (RERemote *)constructDVRRemoteInContext:(NSManagedObjectContext *)context;
+ (RERemote *)constructHomeRemoteInContext:(NSManagedObjectContext *)context;
+ (RERemote *)constructPS3RemoteInContext:(NSManagedObjectContext *)context;
+ (RERemote *)constructSonosRemoteInContext:(NSManagedObjectContext *)context;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////
@class   REMacroCommand;

@interface REMacroBuilder : NSObject

+ (REMacroCommand *)activityMacroForActivity:(NSUInteger)activity toInitiateState:(BOOL)isOnState context:(NSManagedObjectContext *)context;

+ (NSSet *)deviceConfigsForActivity:(NSUInteger)activity context:(NSManagedObjectContext *)context;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Groups
////////////////////////////////////////////////////////////////////////////////
@class   REButtonGroup, REPickerLabelButtonGroup;

@interface REButtonGroupBuilder : NSObject

+ (REButtonGroup *) constructControllerTopToolbarInContext:(NSManagedObjectContext *)context;

// Home screen
+ (REButtonGroup *)constructActivitiesInContext:(NSManagedObjectContext *)context;
+ (REButtonGroup *)constructLightControlsInContext:(NSManagedObjectContext *)context;

// DPad construction
+ (REButtonGroup *)rawDPadInContext:(NSManagedObjectContext *)context;
+ (REButtonGroup *)constructDVRDPadInContext:(NSManagedObjectContext *)context;
+ (REButtonGroup *)constructPS3DPadInContext:(NSManagedObjectContext *)context;

// ￼NumberPad construction
+ (REButtonGroup *)rawNumberPadInContext:(NSManagedObjectContext *)context;
+ (REButtonGroup *)constructDVRNumberPadInContext:(NSManagedObjectContext *)context;
+ (REButtonGroup *)constructPS3NumberPadInContext:(NSManagedObjectContext *)context;

// Transport construction
+ (REButtonGroup *)rawTransportInContext:(NSManagedObjectContext *)context;
+ (REButtonGroup *)constructDVRTransportInContext:(NSManagedObjectContext *)context;
+ (REButtonGroup *)constructPS3TransportInContext:(NSManagedObjectContext *)context;

// Rocker construction
+ (REPickerLabelButtonGroup *)rawRockerInContext:(NSManagedObjectContext *)context;
+ (REPickerLabelButtonGroup *)constructDVRRockerInContext:(NSManagedObjectContext *)context;
+ (REPickerLabelButtonGroup *)constructPS3RockerInContext:(NSManagedObjectContext *)context;
+ (REPickerLabelButtonGroup *)constructSonosRockerInContext:(NSManagedObjectContext *)context;

// Constructing other button groups
+ (REButtonGroup *)rawGroupOfThreeButtonsInContext:(NSManagedObjectContext *)context;
+ (REButtonGroup *)rawButtonPanelInContext:(NSManagedObjectContext *)context;
+ (REButtonGroup *)constructSonosMuteButtonGroupInContext:(NSManagedObjectContext *)context;
+ (REButtonGroup *)constructSelectionPanelInContext:(NSManagedObjectContext *)context;
+ (REButtonGroup *)constructDVRGroupOfThreeButtonsInContext:(NSManagedObjectContext *)context;
+ (REButtonGroup *)constructPS3GroupOfThreeButtonsInContext:(NSManagedObjectContext *)context;
+ (REButtonGroup *)constructAdditionalButtonsLeftInContext:(NSManagedObjectContext *)context;
+ (REButtonGroup *)constructHomeAndPowerButtonsForActivity:(NSInteger)activity context:(NSManagedObjectContext *)context;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Buttons
////////////////////////////////////////////////////////////////////////////////

@interface REButtonBuilder : NSObject

@end
