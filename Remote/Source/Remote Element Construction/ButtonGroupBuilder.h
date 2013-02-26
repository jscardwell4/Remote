//
// ButtonGroupBuilder.h
// iPhonto
//
// Created by Jason Cardwell on 10/6/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@class   ButtonGroup, PickerLabelButtonGroup;

@interface ButtonGroupBuilder : NSObject

+ (ButtonGroupBuilder *)buttonGroupBuilderWithContext:(NSManagedObjectContext *)context;
- (ButtonGroup *)       constructRemoteViewControllerTopBarButtonGroup;

// Home screen
- (ButtonGroup *)constructActivities;
- (ButtonGroup *)constructLightControls;

// DPad construction
- (ButtonGroup *)rawDPad;
- (ButtonGroup *)constructDVRDPad;
- (ButtonGroup *)constructPS3DPad;

// ￼NumberPad construction
- (ButtonGroup *)rawNumberPad;
- (ButtonGroup *)constructDVRNumberPad;
- (ButtonGroup *)constructPS3NumberPad;

// Transport construction
- (ButtonGroup *)rawTransport;
- (ButtonGroup *)constructDVRTransport;
- (ButtonGroup *)constructPS3Transport;

// Rocker construction
- (PickerLabelButtonGroup *)rawRocker;
- (PickerLabelButtonGroup *)constructDVRRocker;
- (PickerLabelButtonGroup *)constructPS3Rocker;
- (PickerLabelButtonGroup *)constructSonosRocker;

// Constructing other button groups
- (ButtonGroup *)rawGroupOfThreeButtons;
- (ButtonGroup *)rawButtonPanel;
- (ButtonGroup *)constructSonosMuteButtonGroup;
- (ButtonGroup *)constructSelectionPanel;
- (ButtonGroup *)constructDVRGroupOfThreeButtons;
- (ButtonGroup *)constructPS3GroupOfThreeButtons;
- (ButtonGroup *)constructAdditionalButtonsLeft;
- (ButtonGroup *)constructHomeAndPowerButtonsForActivity:(NSInteger)activity;

@property (nonatomic, weak) NSManagedObjectContext * buildContext;

@end
