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
#import "REActivity.h"

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

#define _MakeRemote(...) \
    [RERemote remoteElementInContext:CTX withAttributes:(@{ __VA_ARGS__ })]

#define _MakeButtonGroup(...) \
    [REButtonGroup remoteElementInContext:CTX withAttributes:(@{ __VA_ARGS__ })]

#define _MakePickerLabelButtonGroup(...) \
    [REPickerLabelButtonGroup remoteElementInContext:CTX withAttributes:(@{ __VA_ARGS__ })]

#define _MakeButton(...) [REButton remoteElementInContext:CTX withAttributes:(@{ __VA_ARGS__ })]

#define _MakeActivityButton(...) \
    [REActivityButton remoteElementInContext:CTX withAttributes:(@{ __VA_ARGS__ })]


#define MakeRemote(...)  _MakeRemote(@"type":@(RETypeRemote), __VA_ARGS__)

#define MakeButtonGroup(...) _MakeButtonGroup(@"type":@(REButtonGroupTypeDefault), __VA_ARGS__)

#define MakePickerLabelButtonGroup(...) \
    _MakePickerLabelButtonGroup(@"type":@(REButtonGroupTypePickerLabel), __VA_ARGS__)

#define MakeToolbarButtonGroup(...)  _MakeButtonGroup(@"type":@(REButtonGroupTypeToolbar), __VA_ARGS__)

#define MakeSelectionPanelButtonGroup(...)  \
    _MakeButtonGroup(@"type":@(REButtonGroupTypeSelectionPanel), __VA_ARGS__)

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

#define MakeActivityOffButton(...)  \
    _MakeActivityButton(@"type":@(REButtonTypeActivityButton), __VA_ARGS__)

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

#define MakeActivityCommand(ACTIVITY) \
    [REActivityCommand commandWithActivity:[REActivity MR_findFirstByAttribute:@"name" \
                                                                     withValue:ACTIVITY]]

#define MakeSwitchCommand(activity) NullObject  //\
//    [RESwitchToRemoteCommand commandInContext:CTX key:activity]

#define MakePowerOnCommand(DEVICE) [REPowerCommand onCommandForDevice:DEVICE]
#define MakePowerOffCommand(DEVICE) [REPowerCommand offCommandForDevice:DEVICE]
#define MakeDelayCommand(DELAY) [REDelayCommand commandInContext:CTX duration:DELAY]

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Common Command Sets
////////////////////////////////////////////////////////////////////////////////

MSKIT_STATIC_INLINE RECommandSet * avReceiverVolumeCommandSet()
{
    BOComponentDevice * av = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"];
    RECommandSet * volumeCommandSet =
        [RECommandSet
         commandSetWithType:RECommandSetTypeRocker
                       name:@"Receiver Volume"
                     values:@{ RERockerButtonPlusButtonKey  : MakeIRCommand(av, @"Volume Up"),
                               RERockerButtonMinusButtonKey : MakeIRCommand(av, @"Volume Down") }];
    return volumeCommandSet;
}
#define AVReceiverVolumeCommandSet avReceiverVolumeCommandSet()

MSKIT_STATIC_INLINE RECommandSet * dvrChannelsCommandSet()
{
    BOComponentDevice * dvr = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"];
    RECommandSet      * channelsCommandSet = [RECommandSet commandSetWithType:RECommandSetTypeRocker];
        [RECommandSet
         commandSetWithType:RECommandSetTypeRocker
                       name:@"DVR Channels"
                     values:@{ RERockerButtonPlusButtonKey  : MakeIRCommand(dvr, @"Channel Up"),
                               RERockerButtonMinusButtonKey : MakeIRCommand(dvr, @"Channel Down") }];
    return channelsCommandSet;
}
#define DVRChannelsCommandSet dvrChannelsCommandSet()

MSKIT_STATIC_INLINE RECommandSet * dvrPagingCommandSet()
{
    BOComponentDevice * dvr = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"];
    RECommandSet * pageUpDownCommandSet =
        [RECommandSet
             commandSetWithType:RECommandSetTypeRocker
                           name:@"DVR Paging"
                         values:@{ RERockerButtonPlusButtonKey  : MakeIRCommand(dvr, @"Page Up"),
                                   RERockerButtonMinusButtonKey : MakeIRCommand(dvr, @"Page Down") }];
    
    return pageUpDownCommandSet;
}
#define DVRPagingCommandSet dvrPagingCommandSet()

MSKIT_STATIC_INLINE RECommandSet * transportForDeviceWithName(NSString * name)
{
    RECommandSet * transport = nil;
    if ([name isEqualToString:@"PS3"])
    {

        BOComponentDevice * ps3 = [BOComponentDevice fetchDeviceWithName:@"PS3"];
        transport = [RECommandSet commandSetWithType:RECommandSetTypeTransport];
        transport[RETransportPreviousButtonKey]    = MakeIRCommand(ps3, @"Previous");
        transport[RETransportStopButtonKey]        = MakeIRCommand(ps3, @"Stop");
        transport[RETransportPlayButtonKey]        = MakeIRCommand(ps3, @"Play");
        transport[RETransportPauseButtonKey]       = MakeIRCommand(ps3, @"Pause");
        transport[RETransportNextButtonKey]        = MakeIRCommand(ps3, @"Next");
        transport[RETransportFastForwardButtonKey] = MakeIRCommand(ps3, @"Scan Forward");
        transport[RETransportRewindButtonKey]      = MakeIRCommand(ps3, @"Scan Reverse");
    }

    else if ([name isEqualToString:@"Comcast DVR"])
    {
        BOComponentDevice * comcastDVR  = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"];
        transport = [RECommandSet commandSetWithType:RECommandSetTypeTransport];
        transport[RETransportPreviousButtonKey]    = MakeIRCommand(comcastDVR, @"Prev");
        transport[RETransportStopButtonKey]        = MakeIRCommand(comcastDVR, @"Stop");
        transport[RETransportPlayButtonKey]        = MakeIRCommand(comcastDVR, @"Play");
        transport[RETransportPauseButtonKey]       = MakeIRCommand(comcastDVR, @"Pause");
        transport[RETransportNextButtonKey]        = MakeIRCommand(comcastDVR, @"Next");
        transport[RETransportFastForwardButtonKey] = MakeIRCommand(comcastDVR, @"Fast Forward");
        transport[RETransportRewindButtonKey]      = MakeIRCommand(comcastDVR, @"Rewind");
        transport[RETransportRecordButtonKey]      = MakeIRCommand(comcastDVR, @"Record");

    }

    else if ([name isEqualToString:@"Samsung TV"])
    {
        BOComponentDevice * samsungTV   = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"];
        transport = [RECommandSet commandSetWithType:RECommandSetTypeTransport];
        transport[RETransportPlayButtonKey]        = MakeIRCommand(samsungTV, @"Play");
        transport[RETransportPauseButtonKey]       = MakeIRCommand(samsungTV, @"Pause");
        transport[RETransportFastForwardButtonKey] = MakeIRCommand(samsungTV, @"Fast Forward");
        transport[RETransportRewindButtonKey]      = MakeIRCommand(samsungTV, @"Rewind");
        transport[RETransportRecordButtonKey]      = MakeIRCommand(samsungTV, @"Record");
    }

    return transport;
}

#define TransportForDevice(NAME) transportForDeviceWithName(NAME)

MSKIT_STATIC_INLINE RECommandSet * numberPadForDeviceWithName(NSString * name)
{
    RECommandSet * numberPad = nil;

    if ([@"Comcast DVR" isEqualToString:name])
    {
        BOComponentDevice * comcastDVR  = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"];

        numberPad = [RECommandSet commandSetWithType:RECommandSetTypeNumberPad];
        numberPad[REDigitOneButtonKey]   = MakeIRCommand(comcastDVR, @"One");
        numberPad[REDigitTwoButtonKey]   = MakeIRCommand(comcastDVR, @"Two");
        numberPad[REDigitThreeButtonKey] = MakeIRCommand(comcastDVR, @"Three");
        numberPad[REDigitFourButtonKey]  = MakeIRCommand(comcastDVR, @"Four");
        numberPad[REDigitFiveButtonKey]  = MakeIRCommand(comcastDVR, @"Five");
        numberPad[REDigitSixButtonKey]   = MakeIRCommand(comcastDVR, @"Six");
        numberPad[REDigitSevenButtonKey] = MakeIRCommand(comcastDVR, @"Seven");
        numberPad[REDigitEightButtonKey] = MakeIRCommand(comcastDVR, @"Eight");
        numberPad[REDigitNineButtonKey]  = MakeIRCommand(comcastDVR, @"Nine");
        numberPad[REDigitZeroButtonKey]  = MakeIRCommand(comcastDVR, @"Zero");
        numberPad[REAuxOneButtonKey]     = MakeIRCommand(comcastDVR, @"Exit");
        numberPad[REAuxTwoButtonKey]     = MakeIRCommand(comcastDVR, @"OK");
    }

    else if ([@"PS3" isEqualToString:name])
    {
        BOComponentDevice      * ps3         = [BOComponentDevice fetchDeviceWithName:@"PS3"];

        // Create number pad button and add to button group
        numberPad = [RECommandSet commandSetWithType:RECommandSetTypeNumberPad];
        numberPad[REDigitOneButtonKey]   = MakeIRCommand(ps3, @"1");
        numberPad[REDigitTwoButtonKey]   = MakeIRCommand(ps3, @"2");
        numberPad[REDigitThreeButtonKey] = MakeIRCommand(ps3, @"3");
        numberPad[REDigitFourButtonKey]  = MakeIRCommand(ps3, @"4");
        numberPad[REDigitFiveButtonKey]  = MakeIRCommand(ps3, @"5");
        numberPad[REDigitSixButtonKey]   = MakeIRCommand(ps3, @"6");
        numberPad[REDigitSevenButtonKey] = MakeIRCommand(ps3, @"7");
        numberPad[REDigitEightButtonKey] = MakeIRCommand(ps3, @"8");
        numberPad[REDigitNineButtonKey]  = MakeIRCommand(ps3, @"9");
        numberPad[REDigitZeroButtonKey]  = MakeIRCommand(ps3, @"0");

    }

    return numberPad;
}
#define NumberPadForDevice(NAME) numberPadForDeviceWithName(NAME)

MSKIT_STATIC_INLINE RECommandSet * dPadForDeviceWithName(NSString * name)
{
    RECommandSet * dPad = nil;

    if ([@"Comcast DVR" isEqualToString:name])
    {
        BOComponentDevice * comcastDVR  = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"];

        dPad = [RECommandSet commandSetWithType:RECommandSetTypeDPad];
        dPad[REDPadOkButtonKey]    = MakeIRCommand(comcastDVR, @"OK");
        dPad[REDPadUpButtonKey]    = MakeIRCommand(comcastDVR, @"Up");
        dPad[REDPadDownButtonKey]  = MakeIRCommand(comcastDVR, @"Down");
        dPad[REDPadRightButtonKey] = MakeIRCommand(comcastDVR, @"Right");
        dPad[REDPadLeftButtonKey]  = MakeIRCommand(comcastDVR, @"Left");
    }

    else if ([@"PS3" isEqualToString:name])
    {
        BOComponentDevice * ps3 = [BOComponentDevice fetchDeviceWithName:@"PS3"];

        dPad = [RECommandSet commandSetWithType:RECommandSetTypeDPad];
        dPad[REDPadOkButtonKey]    = MakeIRCommand(ps3, @"Enter");
        dPad[REDPadUpButtonKey]    = MakeIRCommand(ps3, @"Up");
        dPad[REDPadDownButtonKey]  = MakeIRCommand(ps3, @"Down");
        dPad[REDPadRightButtonKey] = MakeIRCommand(ps3, @"Right");
        dPad[REDPadLeftButtonKey]  = MakeIRCommand(ps3, @"Left");
    }

    else if ([@"Samsung TV" isEqualToString:name])
    {
        BOComponentDevice * samsungTV = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"];

        dPad = [RECommandSet commandSetWithType:RECommandSetTypeDPad];
        dPad[REDPadOkButtonKey]    = MakeIRCommand(samsungTV, @"Enter");
        dPad[REDPadUpButtonKey]    = MakeIRCommand(samsungTV, @"Up");
        dPad[REDPadDownButtonKey]  = MakeIRCommand(samsungTV, @"Down");
        dPad[REDPadRightButtonKey] = MakeIRCommand(samsungTV, @"Right");
        dPad[REDPadLeftButtonKey]  = MakeIRCommand(samsungTV, @"Left");
    }

    return dPad;
}
#define DPadForDevice(NAME) dPadForDeviceWithName(NAME)

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
