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
@class RERemoteBuilder, REButtonGroupBuilder, REButtonBuilder, MacroBuilder;
@interface RemoteElementConstructionManager : NSObject {
    @private
    NSManagedObjectContext * _buildContext;
    RERemoteBuilder        * _remoteBuilder;
    REButtonGroupBuilder   * _buttonGroupBuilder;
    REButtonBuilder        * _buttonBuilder;
    MacroBuilder           * _macroBuilder;
}

- (BOOL)buildRemoteControllerInContext:(NSManagedObjectContext *)context;

+ (RemoteElementConstructionManager *)sharedManager;

@end

#define ConstructionManager [RemoteElementConstructionManager sharedManager]

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Builder
////////////////////////////////////////////////////////////////////////////////
@interface REBuilder : NSObject {
    @protected
    NSManagedObjectContext * _buildContext;
}

+ (instancetype)builderWithContext:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSManagedObjectContext * buildContext;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remotes
////////////////////////////////////////////////////////////////////////////////
@class RERemote, REButtonGroupBuilder;

/**
 * `RemoteBuilder` is a singleton class that, when provided with an `NSManagedObjectContext`, can
 * fetch or create a <RemoteController> object and construct a multitude of elements that together
 * form a fully realized remote control interface. Currently this class is used for testing
 * purposes.
 */
@interface RERemoteBuilder : REBuilder {
    @private
    REButtonGroupBuilder * _buttonGroupBuilder;
}

- (RERemote *)constructDVRRemote;

- (RERemote *)constructHomeRemote;

- (RERemote *)constructPS3Remote;

- (RERemote *)constructSonosRemote;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////
@class   REMacroCommand;

@interface MacroBuilder : REBuilder

- (REMacroCommand *)activityMacroForActivity:(NSUInteger)activity
                           toInitiateState:(BOOL)isOnState
                               switchIndex:(NSInteger *)switchIndex;
- (NSSet *)deviceConfigsForActivity:(NSUInteger)activity;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Groups
////////////////////////////////////////////////////////////////////////////////
@class   REButtonGroup, REPickerLabelButtonGroup, REButtonBuilder, MacroBuilder;

@interface REButtonGroupBuilder : REBuilder {
    REButtonBuilder * _buttonBuilder;
    MacroBuilder    * _macroBuilder;
}

- (REButtonGroup *) constructRemoteViewControllerTopBarButtonGroup;

// Home screen
- (REButtonGroup *)constructActivities;
- (REButtonGroup *)constructLightControls;

// DPad construction
- (REButtonGroup *)rawDPad;
- (REButtonGroup *)constructDVRDPad;
- (REButtonGroup *)constructPS3DPad;

// ￼NumberPad construction
- (REButtonGroup *)rawNumberPad;
- (REButtonGroup *)constructDVRNumberPad;
- (REButtonGroup *)constructPS3NumberPad;

// Transport construction
- (REButtonGroup *)rawTransport;
- (REButtonGroup *)constructDVRTransport;
- (REButtonGroup *)constructPS3Transport;

// Rocker construction
- (REPickerLabelButtonGroup *)rawRocker;
- (REPickerLabelButtonGroup *)constructDVRRocker;
- (REPickerLabelButtonGroup *)constructPS3Rocker;
- (REPickerLabelButtonGroup *)constructSonosRocker;

// Constructing other button groups
- (REButtonGroup *)rawGroupOfThreeButtons;
- (REButtonGroup *)rawButtonPanel;
- (REButtonGroup *)constructSonosMuteButtonGroup;
- (REButtonGroup *)constructSelectionPanel;
- (REButtonGroup *)constructDVRGroupOfThreeButtons;
- (REButtonGroup *)constructPS3GroupOfThreeButtons;
- (REButtonGroup *)constructAdditionalButtonsLeft;
- (REButtonGroup *)constructHomeAndPowerButtonsForActivity:(NSInteger)activity;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Buttons
////////////////////////////////////////////////////////////////////////////////
@class   REActivityButton, RECommand, REButton;

@interface REButtonBuilder : REBuilder {
    @private
    MacroBuilder * _macroBuilder;
}

//- (BOOL)generateButtonPreviews:(BOOL)replaceExisting;

- (REActivityButton *)launchActivityButtonWithTitle:(NSString *)title activity:(NSUInteger)activity;

- (NSMutableDictionary *)buttonTitleAttributesWithFontName:(NSString *)fontName
                                                  fontSize:(CGFloat)fontSize
                                               highlighted:(NSMutableDictionary *)highlighted;

//- (REButton *)buttonWithDefaultStyle:(REButtonStyleDefault)style
//                             context:(NSManagedObjectContext *)context;

@end
