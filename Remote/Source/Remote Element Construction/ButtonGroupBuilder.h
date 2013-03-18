//
// ButtonGroupBuilder.h
// Remote
//
// Created by Jason Cardwell on 10/6/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@class   REButtonGroup, REPickerLabelButtonGroup;

@interface ButtonGroupBuilder : NSObject

+ (ButtonGroupBuilder *)buttonGroupBuilderWithContext:(NSManagedObjectContext *)context;
- (REButtonGroup *)       constructRemoteViewControllerTopBarButtonGroup;

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

@property (nonatomic, weak) NSManagedObjectContext * buildContext;

@end
