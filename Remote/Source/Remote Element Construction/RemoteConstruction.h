//
// RemoteConstruction.h
// Remote
//
// Created by Jason Cardwell on 10/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "REButton.h"
#import "RERemote.h"
#import "ButtonBuilder.h"
#import "REButtonGroup.h"
#import "ButtonGroupBuilder.h"
#import "REButtonGroupView.h"
#import "REButtonView.h"
#import "ConfigurationDelegate.h"
#import "CoreDataManager.h"
#import "DPad.h"
#import "DeviceConfiguration.h"
#import "BankObjectPreview.h"
#import "REImage.h"
#import "MSRemoteConstants.h"
#import "MacroBuilder.h"
#import "NumberPad.h"
#import "RemoteBuilder.h"
#import "RERemoteController.h"
#import "RemoteElement.h"
#import "RERemoteView.h"
#import "RockerButton.h"
#import "Transport.h"
#import "MSRemoteConstants.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Making Remote Elements
////////////////////////////////////////////////////////////////////////////////

#define _MakeElement(d) [RemoteElement remoteElementInContext : _buildContext withAttributes : d]
#define MakeElement(...)         \
    _MakeElement((@{__VA_ARGS__} \
                  ))

#define MakeRemote(...) MakeElement(@"type" : @(RETypeRemote), __VA_ARGS__)

#define MakeButtonGroup(...)        MakeElement(@"type" : @(REButtonGroupTypeDefault), __VA_ARGS__)
#define MakeToolbarButtonGroup(...) MakeElement(@"type" : @(REButtonGroupTypeToolbar), __VA_ARGS__)

#define MakeButton(...) MakeElement(@"type" : @(REButtonTypeDefault), @"subtype" : @(REButtonSubtypeUnspecified), __VA_ARGS__)
#define MakeBatteryStatusButton    MakeElement(@"type" : @(REButtonTypeBatteryStatus), @"subtype" : @(REButtonSubtypeUnspecified), @"displayName" : @"Battery Status Button")
#define MakeConnectionStatusButton MakeElement(@"type" : @(REButtonTypeConnectionStatus), @"subtype" : @(REButtonSubtypeUnspecified), @"displayName" : @"Connection Status Button")

#define MakeActivityOnButton(...)  MakeElement(@"type" : @(REButtonTypeActivityButton), @"options" : @(REActivityButtonTypeBegin), __VA_ARGS__)
#define MakeActivityOffButton(...) MakeElement(@"type" : @(REButtonTypeActivityButton), __VA_ARGS__)

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Fetching Images
////////////////////////////////////////////////////////////////////////////////

#define MakeBackgroundImage(t) [REBackgroundImage fetchBackgroundImageWithTag : t context : _buildContext]
#define MakeIconImage(t)       [REIconImage fetchIconWithTag : t context : _buildContext]

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Making Control State Sets
////////////////////////////////////////////////////////////////////////////////

#define MakeColorSet(...)      [ControlStateColorSet colorSetInContext : _buildContext withColors : __VA_ARGS__]
#define MakeTitleSet(...)      [ControlStateTitleSet titleSetInContext : _buildContext withTitles : __VA_ARGS__]
#define MakeIconImageSet(c, i) [ControlStateIconImageSet iconSetWithColors : c icons : i]

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Making Commands
////////////////////////////////////////////////////////////////////////////////

#define MakeSystemCommand(k)            [SystemCommand systemCommandWithKey : k inContext : _buildContext]
#define MakeHTTPCommand(u)              [HTTPCommand HTTPCommandWithURL : u inContext : _buildContext]
#define MakeIRCommand(device, name)     [SendIRCommand sendIRCommandWithIRCode :[device codeWithName:name]]
#define MakeSwitchCommand(activity)     [SwitchToRemoteCommand switchToRemoteCommandInContext : _buildContext key : activity]
#define MakePowerCommand(device, state) [PowerCommand powerCommandForDevice : device andState : state]
#define MakeDelayCommand(delay)         [DelayCommand delayCommandWithDuration : delay inContext : _buildContext]

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Default Constants
////////////////////////////////////////////////////////////////////////////////

#define kDefaultFontName      @"Optima-Bold"
#define kArrowFontName        @"HiraMinProN-W6"
#define kUpArrow              @"▲"
#define kDownArrow            @"▼"
#define kLeftArrow            @"◀"
#define kRightArrow           @"▶"
#define kTVConfiguration      @"kTVConfiguration"
#define kPanelBackgroundColor DarkGrayColor
#define kHighlightColor       defaultTitleHighlightColor()

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Alignment and Sizing Options
////////////////////////////////////////////////////////////////////////////////

#define AlignmentOptions1 (RemoteElementAlignmentOptionBottomParent | RemoteElementAlignmentOptionLeftParent | RemoteElementAlignmentOptionTopParent)
#define AlignmentOptions2 (RemoteElementAlignmentOptionBottomParent | RemoteElementAlignmentOptionLeftFocus | RemoteElementAlignmentOptionTopParent)
#define AlignmentOptions3 (RemoteElementAlignmentOptionCenterXParent | RemoteElementAlignmentOptionCenterYParent)
#define AlignmentOptions4 (RemoteElementAlignmentOptionLeftParent | RemoteElementAlignmentOptionTopParent)
#define AlignmentOptions5 (RemoteElementAlignmentOptionTopParent | RemoteElementAlignmentOptionRightParent)
#define AlignmentOptions6 (RemoteElementAlignmentOptionCenterXParent | RemoteElementAlignmentOptionTopFocus | RemoteElementAlignmentOptionBottomFocus)
#define AlignmentOptions7 (RemoteElementAlignmentOptionCenterXParent | RemoteElementAlignmentOptionTopParent)
#define AlignmentOptions8 (RemoteElementAlignmentOptionLeftParent | RemoteElementAlignmentOptionRightParent | RemoteElementAlignmentOptionBottomParent)
#define AlignmentOptions9 (RemoteElementAlignmentOptionCenterXParent | RemoteElementAlignmentOptionRightParent)

#define SizingOptions1 (RemoteElementSizingOptionHeightParent | RemoteElementSizingOptionWidthIntrinsic)
#define SizingOptions2 (RemoteElementSizingOptionHeightParent | RemoteElementSizingOptionWidthFocus)
#define SizingOptions3 (RemoteElementSizingOptionHeightParent | RemoteElementSizingOptionWidthParent)
#define SizingOptions4 (RemoteElementSizingOptionWidthIntrinsic | RemoteElementSizingOptionHeightIntrinsic)
#define SizingOptions5 (RemoteElementSizingOptionWidthParent | RemoteElementSizingOptionHeightIntrinsic)
