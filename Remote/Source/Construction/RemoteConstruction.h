//
// RemoteConstruction.h
// Remote
//
// Created by Jason Cardwell on 10/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElementConstructionManager.h"
#import "RemoteElement.h"
#import "REView.h"
#import "REConfigurationDelegate.h"
#import "REDeviceConfiguration.h"
#import "BankObject.h"
#import "CoreDataManager.h"
#import "RERemoteController.h"
#import "BankObjectPreview.h"
#import "BankObject.h"
#import "REControlStateSet.h"
#import "RECommand.h"
#import "RECommandContainer.h"
#import "RETheme.h"



#define CTX [NSManagedObjectContext MR_contextForCurrentThread]

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constraints
////////////////////////////////////////////////////////////////////////////////

#define SetConstraints(ELEMENT, FORMAT, ...)             \
    [ELEMENT setConstraintsFromString:                   \
     [FORMAT stringByReplacingOccurrencesWithDictionary: \
      NSDictionaryOfVariableBindingsToIdentifiers(ELEMENT,##__VA_ARGS__)]]

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Making Remote Elements
////////////////////////////////////////////////////////////////////////////////

//#define _MakeElement(ATTRIBUTES) [RemoteElement remoteElementInContext:CTX withAttributes:ATTRIBUTES]

#define _MakeRemote(...) [RERemote remoteElementInContext:CTX withAttributes:(@{ __VA_ARGS__ })]
#define _MakeButtonGroup(...) [REButtonGroup remoteElementInContext:CTX withAttributes:(@{ __VA_ARGS__ })]
#define _MakePickerLabelButtonGroup(...) [REPickerLabelButtonGroup remoteElementInContext:CTX withAttributes:(@{ __VA_ARGS__ })]
#define _MakeButton(...) [REButton remoteElementInContext:CTX withAttributes:(@{ __VA_ARGS__ })]
#define _MakeActivityButton(...) [REActivityButton remoteElementInContext:CTX withAttributes:(@{ __VA_ARGS__ })]


//#define MakeElement(...) _MakeElement((@{ __VA_ARGS__ }))


#define MakeRemote(...)  _MakeRemote(@"type":@(RETypeRemote), __VA_ARGS__)
#define MakeButtonGroup(...) _MakeButtonGroup(@"type":@(REButtonGroupTypeDefault), __VA_ARGS__)
#define MakePickerLabelButtonGroup(...) _MakePickerLabelButtonGroup(@"type":@(REButtonGroupTypePickerLabel), __VA_ARGS__)
#define MakeToolbarButtonGroup(...)  _MakeButtonGroup(@"type":@(REButtonGroupTypeToolbar), __VA_ARGS__)
#define MakeSelectionPanelButtonGroup(...)  _MakeButtonGroup(@"type":@(REButtonGroupTypeSelectionPanel), __VA_ARGS__)
#define MakeButton(...)                                    \
    _MakeButton(@"type" : @(REButtonTypeDefault),          \
                @"subtype": @(REButtonSubtypeUnspecified), \
                __VA_ARGS__)

#define MakeBatteryStatusButton                                \
    _MakeButton(@"type"       : @(REButtonTypeBatteryStatus),  \
                @"subtype"    : @(REButtonSubtypeUnspecified), \
                @"displayName": @"Battery Status Button")

#define MakeConnectionStatusButton                               \
    _MakeButton(@"type"       : @(REButtonTypeConnectionStatus), \
                @"subtype"    : @(REButtonSubtypeUnspecified),   \
                @"displayName": @"Connection Status Button")

#define MakeActivityOnButton(...)                           \
    _MakeActivityButton(@"type"    : @(REButtonTypeActivityButton), \
                        @"options" : @(REActivityButtonTypeBegin),  \
                        __VA_ARGS__)

#define MakeActivityOffButton(...)  _MakeActivityButton(@"type":@(REButtonTypeActivityButton), __VA_ARGS__)

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Images
////////////////////////////////////////////////////////////////////////////////

#define MakeBackgroundImage(tag) [BOBackgroundImage fetchImageWithTag:tag context:CTX]
#define MakeIconImage(tag) [BOIconImage fetchImageWithTag:tag context:CTX]

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Control State Sets
////////////////////////////////////////////////////////////////////////////////

#define MakeColorSet(...) [REControlStateColorSet controlStateSetInContext:CTX withObjects:__VA_ARGS__]
#define MakeTitleSet(...) [REControlStateTitleSet controlStateSetInContext:CTX withObjects:__VA_ARGS__]
#define MakeIconImageSet(COLORS,ICONS) \
    [REControlStateIconImageSet iconSetWithColors:COLORS icons:ICONS context:CTX]

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////

#define MakeSystemCommand(TYPE) [RESystemCommand commandInContext:CTX type:TYPE]
#define MakeHTTPCommand(URL) [REHTTPCommand commandInContext:CTX withURL:URL]
#define MakeIRCommand(DEVICE,NAME) [RESendIRCommand commandWithIRCode:DEVICE[NAME]]
#define MakeSwitchToConfigCommand(CONFIGURATION) \
	[RESwitchToConfigCommand commandInContext:CTX configuration:CONFIGURATION]

#define MakeSwitchCommand(activity) \
    [RESwitchToRemoteCommand commandInContext:CTX key:activity]

#define MakePowerOnCommand(DEVICE) [REPowerCommand onCommandForDevice:DEVICE]
#define MakePowerOffCommand(DEVICE) [REPowerCommand offCommandForDevice:DEVICE]
#define MakeDelayCommand(DELAY) [REDelayCommand commandInContext:CTX duration:DELAY]

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Default Constants
////////////////////////////////////////////////////////////////////////////////

#define kDefaultFontName      @"Optima-Bold"
#define kArrowFontName        @"HiraMinProN-W6"
#define kUpArrow              @"\u25B2"
#define kDownArrow            @"\u25BC"
#define kLeftArrow            @"\u25C0"
#define kRightArrow           @"\u25B6"
#define kTVConfiguration      @"kTVConfiguration"
#define kPanelBackgroundColor DarkGrayColor
#define kHighlightColor       defaultTitleHighlightColor()
