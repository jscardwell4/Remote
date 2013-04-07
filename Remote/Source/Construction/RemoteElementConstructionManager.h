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

+ (BOOL)buildController;

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

+ (RERemote *)constructDVRRemote;

+ (RERemote *)constructHomeRemote;

+ (RERemote *)constructPS3Remote;

+ (RERemote *)constructSonosRemote;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////
@class   REMacroCommand;

@interface REMacroBuilder : NSObject

+ (REMacroCommand *)activityMacroForActivity:(NSUInteger)activity
                           toInitiateState:(BOOL)isOnState
                               switchIndex:(NSInteger *)switchIndex;

+ (NSSet *)deviceConfigsForActivity:(NSUInteger)activity;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Groups
////////////////////////////////////////////////////////////////////////////////
@class   REButtonGroup, REPickerLabelButtonGroup;

@interface REButtonGroupBuilder : NSObject

+ (REButtonGroup *) constructControllerTopToolbar;

// Home screen
+ (REButtonGroup *)constructActivities;
+ (REButtonGroup *)constructLightControls;

// DPad construction
+ (REButtonGroup *)rawDPad;
+ (REButtonGroup *)constructDVRDPad;
+ (REButtonGroup *)constructPS3DPad;

// ￼NumberPad construction
+ (REButtonGroup *)rawNumberPad;
+ (REButtonGroup *)constructDVRNumberPad;
+ (REButtonGroup *)constructPS3NumberPad;

// Transport construction
+ (REButtonGroup *)rawTransport;
+ (REButtonGroup *)constructDVRTransport;
+ (REButtonGroup *)constructPS3Transport;

// Rocker construction
+ (REPickerLabelButtonGroup *)rawRocker;
+ (REPickerLabelButtonGroup *)constructDVRRocker;
+ (REPickerLabelButtonGroup *)constructPS3Rocker;
+ (REPickerLabelButtonGroup *)constructSonosRocker;

// Constructing other button groups
+ (REButtonGroup *)rawGroupOfThreeButtons;
+ (REButtonGroup *)rawButtonPanel;
+ (REButtonGroup *)constructSonosMuteButtonGroup;
+ (REButtonGroup *)constructSelectionPanel;
+ (REButtonGroup *)constructDVRGroupOfThreeButtons;
+ (REButtonGroup *)constructPS3GroupOfThreeButtons;
+ (REButtonGroup *)constructAdditionalButtonsLeft;
+ (REButtonGroup *)constructHomeAndPowerButtonsForActivity:(NSInteger)activity;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Buttons
////////////////////////////////////////////////////////////////////////////////
@class   REActivityButton;

@interface REButtonBuilder : NSObject

+ (REActivityButton *)launchActivityButtonWithTitle:(NSString *)title activity:(NSUInteger)activity;

+ (NSMutableDictionary *)buttonTitleAttributesWithFontName:(NSString *)fontName
                                                  fontSize:(CGFloat)fontSize
                                               highlighted:(NSMutableDictionary *)highlighted;

@end
