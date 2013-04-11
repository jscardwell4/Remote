//
// ButtonGroupBuilder.m
// Remote
//
// Created by Jason Cardwell on 10/6/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteConstruction.h"

static const int   ddLogLevel = LOG_LEVEL_DEBUG;

@implementation REButtonGroupBuilder

+ (REButtonGroup *)constructControllerTopToolbar
{
    REButtonGroup * buttonGroup =
        MakeToolbarButtonGroup(@"displayName"     : @"Top Toolbar",
                               @"backgroundColor" : FlipsideColor);

    REButton * home =
        MakeButton(@"displayName" : @"Home Button",
                   @"command"     : MakeSystemCommand(RESystemCommandReturnToLaunchScreen),
                   @"icons"       : MakeIconImageSet(@{ @"normal" : WhiteColor },
                                                     @{ @"normal" : MakeIconImage(140) }));

    REButton * settings =
        MakeButton(@"displayName" : @"Settings Button",
                   @"icons"       : MakeIconImageSet(@{ @"normal" : WhiteColor },
                                                     @{ @"normal" : MakeIconImage(83) }),
                   @"command"     : MakeSystemCommand(RESystemCommandOpenSettings));

    REButton * editRemote =
        MakeButton(@"displayName" : @"Edit Remote Button",
                   @"command"     : MakeSystemCommand(RESystemCommandOpenEditor),
                   @"icons"       : MakeIconImageSet(@{ @"normal" : WhiteColor },
                                                     @{ @"normal" : MakeIconImage(224) }));

    REButton * battery = MakeBatteryStatusButton;

    battery.icons[UIControlStateNormal]   = MakeIconImage(5);
    battery.icons[UIControlStateSelected] = MakeIconImage(4);
    battery.icons[UIControlStateDisabled] = MakeIconImage(6);

    battery.icons.iconColors[UIControlStateNormal]   = WhiteColor;
    battery.icons.iconColors[UIControlStateSelected] = LightGrayColor;
    battery.icons.iconColors[UIControlStateDisabled] = LightGrayColor;

    battery.backgroundColors[UIControlStateNormal] = LightTextColor;

    REButton * connection = MakeConnectionStatusButton;

    connection.icons[UIControlStateNormal] = MakeIconImage(182);

    connection.icons.iconColors[UIControlStateNormal]   = GrayColor;
    connection.icons.iconColors[UIControlStateSelected] = WhiteColor;

    [buttonGroup addSubelements:[@[home, settings, editRemote, battery, connection] orderedSet]];

    SetConstraints(buttonGroup,
                   @"home.left = buttonGroup.left + 4\n"
                   "settings.left = home.right + 20\n"
                   "editRemote.left = settings.right + 20\n"
                   "battery.left = editRemote.right + 20\n"
                   "connection.left = battery.right + 20\n"
                   "settings.width = home.width\n"
                   "editRemote.width = home.width\n"
                   "battery.width = home.width\n"
                   "connection.width = home.width\n"
                   "home.height = buttonGroup.height\n"
                   "settings.height = buttonGroup.height\n"
                   "editRemote.height = buttonGroup.height\n"
                   "battery.height = buttonGroup.height\n"
                   "connection.height = buttonGroup.height\n"
                   "home.centerY = buttonGroup.centerY\n"
                   "settings.centerY = buttonGroup.centerY\n"
                   "editRemote.centerY = buttonGroup.centerY\n"
                   "battery.centerY = buttonGroup.centerY\n"
                   "connection.centerY = buttonGroup.centerY",
                   home, settings, editRemote, battery, connection);

    SetConstraints(home, @"home.width ≥ 44");

    return buttonGroup;
}


+ (REButtonGroup *)constructActivities
{
    REButtonGroup * buttonGroup = MakeButtonGroup(@"displayName" : @"Activity Buttons");

    REButton * activity1 =
        MakeButton(@"title"       : @"Comcast\nDVR",
                   @"displayName" : @"Comcast DVR",
                   @"shape"       : @(REShapeRoundedRectangle),
                   @"command"     : MakeActivityCommand(@"Comcast DVR Activity"));

    //[REButtonBuilder launchActivityButtonWithTitle:@"Comcast\nDVR" activity:1];

    REButton * activity2 = //[REButtonBuilder launchActivityButtonWithTitle:@"Playstation" activity:2];
        MakeButton(@"title"       : @"Playstation",
                   @"displayName" : @"Playstation",
                   @"shape"       : @(REShapeRoundedRectangle),
                   @"command"     : MakeActivityCommand(@"Playstation Activity"));

    REButton * activity3 = //[REButtonBuilder launchActivityButtonWithTitle:@" TV" activity:3];
        MakeButton(@"title"       : @" TV",
                   @"displayName" : @" TV",
                   @"shape"       : @(REShapeRoundedRectangle),
                   @"command"     : MakeActivityCommand(@" TV Activity"));

    REButton * activity4 = //[REButtonBuilder launchActivityButtonWithTitle:@"Sonos" activity:4];
        MakeButton(@"title"       : @"Sonos",
                   @"displayName" : @"Sonos",
                   @"shape"       : @(REShapeRoundedRectangle),
                   @"command"     : MakeActivityCommand(@"Sonos Activity"));

    [buttonGroup addSubelements:[@[activity1,
                                   activity2,
                                   activity3,
                                   activity4] orderedSet]];

    [[REBuiltinTheme themeWithName:REThemeNightshadeName]
     applyThemeToElements:[buttonGroup.subelements set]];

    SetConstraints(buttonGroup,
                   @"buttonGroup.width = 300\n"
                   "buttonGroup.height = buttonGroup.width\n"
                   "activity1.width = buttonGroup.width * 0.5\n"
                   "activity1.centerX = buttonGroup.centerX * 0.5\n"
                   "activity1.centerY = buttonGroup.centerY * 0.5\n"
                   "activity2.width = activity1.width\n"
                   "activity2.centerX = buttonGroup.centerX * 1.5\n"
                   "activity2.centerY = buttonGroup.centerY * 0.5\n"
                   "activity3.width = activity1.width\n"
                   "activity3.centerX = buttonGroup.centerX * 0.5\n"
                   "activity3.centerY = buttonGroup.centerY * 1.5\n"
                   "activity4.width = activity1.width\n"
                   "activity4.centerX = buttonGroup.centerX * 1.5\n"
                   "activity4.centerY = buttonGroup.centerY * 1.5",
                   activity1,
                   activity2,
                   activity3,
                   activity4);

    SetConstraints(activity1, @"activity1.height = activity1.width");
    SetConstraints(activity2, @"activity2.height = activity2.width");
    SetConstraints(activity3, @"activity3.height = activity3.width");
    SetConstraints(activity4, @"activity4.height = activity4.width");

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}


+ (REButtonGroup *)constructLightControls
{
    REButtonGroup * buttonGroup =
        MakeButtonGroup(@"displayName"     : @"Light Controls",
                        @"backgroundColor" : FlipsideColor);

    REButton * lightsOnButton =
        MakeButton(@"icons"       : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                         @"highlighted" : kHighlightColor }),
                                                      @{ @"normal"      : MakeIconImage(1) }),
                   @"command"     : MakeHTTPCommand(@"http://10.0.1.27/0?1201=I=0"),
                   @"displayName" : @"Lights On");

    REButton * lightsOffButton =
        MakeButton(@"icons"       : MakeIconImageSet((@{ @"normal"      : GrayColor,
                                                         @"highlighted" : kHighlightColor }),
                                                     (@{ @"normal"      : MakeIconImage(1) })),
                   @"command"     : MakeHTTPCommand(@"http://10.0.1.27/0?1401=I=0"),
                   @"displayName" : @"Lights Off");

    [buttonGroup addSubelements:[@[lightsOnButton, lightsOffButton] orderedSet]];

    SetConstraints(buttonGroup,
                   @"buttonGroup.height = 44\n"
                   "lightsOnButton.left = buttonGroup.left + 20\n"
                   "lightsOffButton.left = lightsOnButton.right + 40\n"
                   "lightsOffButton.width = lightsOnButton.width\n"
                   "lightsOnButton.top = buttonGroup.top\n"
                   "lightsOnButton.bottom = buttonGroup.bottom\n"
                   "lightsOffButton.top = buttonGroup.top\n"
                   "lightsOffButton.bottom = buttonGroup.bottom",
                   lightsOnButton, lightsOffButton);

    SetConstraints(lightsOnButton, @"lightsOnButton.width = 44");

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}


+ (REButtonGroup *)rawDPad
{
    REButtonGroup * buttonGroup =
        MakeButtonGroup(@"shape"       : @(REShapeOval),
                        @"displayName" : @"Raw Direction Pad");

    // Create center "OK" button and add to button group
    REButton * ok =
        MakeButton(@"key"         : REDPadOkButtonKey,
                   @"displayName" : @"OK",
                   @"title"       : @"OK");

    // Create _up button and add to button group
    REButton * _up =
        MakeButton(@"key"         : REDPadUpButtonKey,
                   @"displayName" : @"Up",
                   @"title"       : kUpArrow,
                   @"style"       : @(REButtonSubtypeButtonGroupPiece));

    // Create down button and add to button group
    REButton * down =
        MakeButton(@"subtype"     : @(REButtonSubtypeButtonGroupPiece),
                   @"key"         : REDPadDownButtonKey,
                   @"displayName" : @"Down",
                   @"title"       : kDownArrow);

    // Create right button and add to button group
    REButton * _right =
        MakeButton(@"style"       : @(REButtonSubtypeButtonGroupPiece),
                   @"key"         : REDPadRightButtonKey,
                   @"displayName" : @"Right",
                   @"title"       : kRightArrow);

    // Create left button and add to button group
    REButton * _left =
        MakeButton(@"subtype"     : @(REButtonSubtypeButtonGroupPiece),
                   @"key"         : REDPadLeftButtonKey,
                   @"displayName" : @"Left",
                   @"title"       : kLeftArrow);

    [buttonGroup addSubelements:[@[ok, _up, down, _left, _right] orderedSet]];

//    [[REBuiltinTheme themeWithName:REThemeNightshadeName] applyThemeToElement:buttonGroup];


    SetConstraints(buttonGroup,
                   @"ok.centerX = buttonGroup.centerX\n"
                   "ok.centerY = buttonGroup.centerY\n"
                   "ok.width = buttonGroup.width * 0.3\n"
                   "_up.top = buttonGroup.top\n"
                   "_up.bottom = ok.top\n"
                   "_up.left = _left.right\n"
                   "_up.right = _right.left\n"
                   "down.top = ok.bottom\n"
                   "down.bottom = buttonGroup.bottom\n"
                   "down.left = _left.right\n"
                   "down.right = _right.left\n"
                   "_left.left = buttonGroup.left\n"
                   "_left.right = ok.left\n"
                   "_left.top = _up.bottom\n"
                   "_left.bottom = down.top\n"
                   "_right.left = ok.right\n"
                   "_right.right = buttonGroup.right\n"
                   "_right.top = _up.bottom\n"
                   "_right.bottom = down.top\n"
                   "buttonGroup.width = buttonGroup.height\n"
                   "buttonGroup.height = 300",
                   ok, _up, down, _left, _right);

    SetConstraints(ok, @"ok.height = ok.width");

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}


+ (REButtonGroup *)constructDVRDPad
{
    REButtonGroup * buttonGroup = [self rawDPad];
    buttonGroup.displayName = @"DVR Activity DPad";
    [buttonGroup addCommandSet:DPadForDevice(@"Comcast DVR") forConfiguration:REDefaultConfiguration];
    [buttonGroup addCommandSet:DPadForDevice(@"Samsung TV")  forConfiguration:kTVConfiguration];

    return buttonGroup;
}


+ (REButtonGroup *)constructPS3DPad
{
    REButtonGroup * buttonGroup = [self rawDPad];
    buttonGroup.displayName = @"Playstation Activity DPad";
    buttonGroup.commandSet  = DPadForDevice(@"PS3");

    return buttonGroup;
}


+ (REButtonGroup *)rawNumberPad
{
    REButtonGroup * buttonGroup =
        MakeButtonGroup(@"backgroundColor" : [kPanelBackgroundColor colorWithAlphaComponent:0.75],
                        @"displayName"     : @"Raw Number Pad");

    NSNumber * shape = @(REShapeRoundedRectangle);

    REButton * one =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"shape"           : shape,
                   @"key"             : REDigitOneButtonKey,
                   @"displayName"     : @"Digit 1",
                   @"title"           : @"1");



    REButton * two =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"shape"           : shape,
                   @"key"             : REDigitTwoButtonKey,
                   @"displayName"     : @"Digit 2",
                   @"title"           : @"2");


    REButton * three =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"shape"           : shape,
                   @"key"             : REDigitThreeButtonKey,
                   @"displayName"     : @"Digit 3",
                   @"title"           : @"3");


    REButton * four =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"shape"           : shape,
                   @"key"             : REDigitFourButtonKey,
                   @"displayName"     : @"Digit 4",
                   @"title"           : @"4");


    REButton * five =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"shape"           : shape,
                   @"key"             : REDigitFiveButtonKey,
                   @"displayName"     : @"Digit 5",
                   @"title"           : @"5");


    REButton * six =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"shape"           : shape,
                   @"key"             : REDigitSixButtonKey,
                   @"displayName"     : @"Digit 6",
                   @"title"           : @"6");


    REButton * seven =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"shape"           : shape,
                   @"key"             : REDigitSevenButtonKey,
                   @"displayName"     : @"Digit 7",
                   @"title"           : @"7");


    REButton * _eight =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"shape"           : shape,
                   @"key"             : REDigitEightButtonKey,
                   @"displayName"     : @"Digit 8",
                   @"title"           : @"8");


    REButton * nine =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"shape"           : shape,
                   @"key"             : REDigitNineButtonKey,
                   @"displayName"     : @"Digit 9",
                   @"title"           : @"9");


    REButton * zero =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"shape"           : shape,
                   @"key"             : REDigitZeroButtonKey,
                   @"displayName"     : @"Digit 0",
                   @"title"           : @"0");

    REButton * tuck =
        MakeButton(@"key"         : REButtonGroupTuckButtonKey,
                   @"displayName" : @"Tuck Button",
                   @"title"       : kUpArrow);


    REButton * aux1 =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"shape"           : shape,
                   @"key"             : REAuxOneButtonKey,
                   @"displayName"     : @"Exit",
                   @"title"           : @"Exit");


    REButton * aux2 =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"shape"           : shape,
                   @"key"             : REAuxTwoButtonKey,
                   @"displayName"     : @"Enter",
                   @"title"           : @"Enter");

    [buttonGroup addSubelements:[@[one, two, three, four, five, six,
                                   seven, _eight, nine, zero, aux1, aux2, tuck] orderedSet]];

    
    [[REBuiltinTheme themeWithName:REThemeNightshadeName]
     applyThemeToElements:[buttonGroup.subelements set]];

    SetConstraints(buttonGroup,
                   @"one.left = buttonGroup.left\n"
                   "one.top = buttonGroup.top\n"
                   "one.bottom = two.bottom\n"

                   "two.left = one.right\n"
                   "two.top = buttonGroup.top\n"
                   "two.width = one.width\n"

                   "three.left = two.right\n"
                   "three.right = buttonGroup.right\n"
                   "three.top = buttonGroup.top\n"
                   "three.bottom = two.bottom\n"
                   "three.width = one.width\n"

                   "four.left = buttonGroup.left\n"
                   "four.top = one.bottom\n"
                   "four.right = one.right\n"
                   "four.bottom = five.bottom\n"

                   "five.left = two.left\n"
                   "five.top = two.bottom\n"
                   "five.right = two.right\n"
                   "five.height = two.height\n"

                   "six.left = three.left\n"
                   "six.right = buttonGroup.right\n"
                   "six.top = three.bottom\n"
                   "six.bottom = five.bottom\n"

                   "seven.left = buttonGroup.left\n"
                   "seven.top = four.bottom\n"
                   "seven.right = four.right\n"
                   "seven.bottom = _eight.bottom\n"

                   "_eight.left = five.left\n"
                   "_eight.top = five.bottom\n"
                   "_eight.right = five.right\n"
                   "_eight.height = two.height\n"

                   "nine.left = six.left\n"
                   "nine.right = six.right\n"
                   "nine.top = six.bottom\n"
                   "nine.bottom = _eight.bottom\n"

                   "aux1.left = buttonGroup.left\n"
                   "aux1.top = seven.bottom\n"
                   "aux1.bottom = zero.bottom\n"
                   "aux1.right = seven.right\n"

                   "zero.left = _eight.left\n"
                   "zero.top = _eight.bottom\n"
                   "zero.right = _eight.right\n"
                   "zero.bottom = tuck.top\n"
                   "zero.height = two.height\n"

                   "aux2.left = nine.left\n"
                   "aux2.right = buttonGroup.right\n"
                   "aux2.top = nine.bottom\n"
                   "aux2.bottom = zero.bottom\n"

                   "tuck.left = buttonGroup.left\n"
                   "tuck.right = buttonGroup.right\n"
                   "tuck.bottom = buttonGroup.bottom\n"
                   "tuck.height = two.height",
                   one, two, three, four, five, six, seven, _eight, nine, zero, aux1, aux2, tuck);

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}


+ (REButtonGroup *)constructDVRNumberPad
{
    REButtonGroup * buttonGroup = [self rawNumberPad];
    buttonGroup.displayName   = @"DVR Activity Number Pad";
    buttonGroup.commandSet    = NumberPadForDevice(@"Comcast DVR");
    buttonGroup.key           = RERemoteTopPanel1Key;
    buttonGroup.panelLocation = REPanelLocationTop;

    return buttonGroup;
}


+ (REButtonGroup *)constructPS3NumberPad
{
    REButtonGroup * buttonGroup = [self rawNumberPad];
    buttonGroup.displayName   = @"Playstation Activity Number Pad";
    buttonGroup.key           = RERemoteTopPanel1Key;
    buttonGroup.panelLocation = REPanelLocationTop;
    buttonGroup.commandSet    = NumberPadForDevice(@"PS3");

    return buttonGroup;
}


+ (REButtonGroup *)rawTransport
{
    REButtonGroup * buttonGroup =
        MakeButtonGroup(@"backgroundColor" : [kPanelBackgroundColor colorWithAlphaComponent:0.75],
                        @"displayName"     : @"Raw Transport");

    // Create "rewind" button and add to button group
    REButton * rewind =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportRewindButtonKey,
                   @"displayName"     : @"Rewind",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4004) })));

    // Create "pause" button and add to button group
    REButton * pause =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportPauseButtonKey,
                   @"displayName"     : @"Pause",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4001) })));

    // Create "fast forward" button and add to button group
    REButton * fastForward =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportFastForwardButtonKey,
                   @"displayName"     : @"Fast Forward",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4000) })));

    // Create "previous" button and add to button group
    REButton * previous =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportPreviousButtonKey,
                   @"displayName"     : @"Previous",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4005) })));

    // Create "play" button and add to button group
    REButton * play =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportPlayButtonKey,
                   @"displayName"     : @"Play",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4002) })));

    // Create "next" button and add to button group
    REButton * next =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportNextButtonKey,
                   @"displayName"     : @"Next",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4006) })));

    // Create "record" button and add to button group
    REButton * record =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportRecordButtonKey,
                   @"displayName"     : @"Record",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4003) })));

    // Create "stop" button and add to button group
    REButton * stop =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportStopButtonKey,
                   @"displayName"     : @"Stop",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4007) })));

    REButton * tuck =
        MakeButton(@"key"         : REButtonGroupTuckButtonKey,
                   @"displayName" : @"Tuck Panel",
                   @"title"       : kDownArrow);

    [buttonGroup addSubelements:[@[play, pause, rewind, fastForward, stop,
                                   previous, tuck, next, record] orderedSet]];

    [[REBuiltinTheme themeWithName:REThemeNightshadeName]
     applyThemeToElements:[buttonGroup.subelements set]];

    SetConstraints(buttonGroup,
                   @"record.left = buttonGroup.left\n"
                   "record.top = buttonGroup.top\n"
                   "play.left = record.right\n"
                   "play.top = buttonGroup.top\n"
                   "play.bottom = record.bottom\n"
                   "play.width = record.width\n"
                   "stop.left = play.right\n"
                   "stop.right = buttonGroup.right\n"
                   "stop.top = buttonGroup.top\n"
                   "stop.bottom = play.bottom\n"
                   "stop.width = record.width\n"
                   "rewind.left = buttonGroup.left\n"
                   "rewind.top = record.bottom\n"
                   "rewind.right = record.right\n"
                   "rewind.bottom = pause.bottom\n"
                   "pause.left = play.left\n"
                   "pause.top = play.bottom\n"
                   "pause.right = play.right\n"
                   "pause.height = play.height\n"
                   "fastForward.left = stop.left\n"
                   "fastForward.right = buttonGroup.right\n"
                   "fastForward.top = stop.bottom\n"
                   "fastForward.bottom = pause.bottom\n"
                   "previous.left = buttonGroup.left\n"
                   "previous.top = rewind.bottom\n"
                   "previous.right = rewind.right\n"
                   "previous.bottom = buttonGroup.bottom\n"
                   "tuck.left = pause.left\n"
                   "tuck.top = pause.bottom\n"
                   "tuck.right = pause.right\n"
                   "tuck.bottom = buttonGroup.bottom\n"
                   "tuck.height = play.height\n"
                   "next.left = fastForward.left\n"
                   "next.right = buttonGroup.right\n"
                   "next.top = fastForward.bottom\n"
                   "next.bottom = buttonGroup.bottom\n"
                   "buttonGroup.height = buttonGroup.width",
                   play, pause, rewind, fastForward, stop, previous, tuck, next, record);

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}


+ (REButtonGroup *)constructDVRTransport
{
    REButtonGroup * buttonGroup = [self rawTransport];
    buttonGroup.displayName   = @"DVR Activity Transport";
    buttonGroup.key           = RERemoteBottomPanel1Key;
    buttonGroup.panelLocation = REPanelLocationBottom;
    [buttonGroup addCommandSet:TransportForDevice(@"Comcast DVR") forConfiguration:REDefaultConfiguration];
    [buttonGroup addCommandSet:TransportForDevice(@"Samsung TV")  forConfiguration:kTVConfiguration];

    return buttonGroup;
}


+ (REButtonGroup *)constructPS3Transport
{
    REButtonGroup * buttonGroup = [self rawTransport];
    buttonGroup.displayName   = @"Playstation Activity Transport";
    buttonGroup.key           = RERemoteBottomPanel1Key;
    buttonGroup.panelLocation = REPanelLocationBottom;
    buttonGroup.commandSet    = TransportForDevice(@"PS3");

    return buttonGroup;
}


+ (REPickerLabelButtonGroup *)rawRocker
{
    REPickerLabelButtonGroup * buttonGroup =
        MakePickerLabelButtonGroup(@"backgroundColor" : defaultBGColor(),
                                   @"shape"           : @(REShapeRoundedRectangle),
                                   @"displayName"     : @"Raw Rocker");

    // Create top button and add to button group
    REButton * _up =
        MakeButton(@"subtype"     : @(REButtonSubtypeButtonGroupPiece),
                   @"displayName" : @"Rocker Up",
                   @"icons"       : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                         @"highlighted" : kHighlightColor }),
                                                     (@{ @"normal"      : MakeIconImage(40) })),
                   @"key"         : RERockerButtonPlusButtonKey);

    // Create bottom button and add to button group
    REButton * down =
        MakeButton(@"subtype"     : @(REButtonSubtypeButtonGroupPiece),
                   @"displayName" : @"Rocker Down",
                   @"icons"       : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                         @"highlighted" : kHighlightColor }),
                                                     (@{ @"normal"      : MakeIconImage(155) })),
                   @"key"         : RERockerButtonMinusButtonKey);

    [buttonGroup addSubelements:[@[_up, down] orderedSet]];

//    [[REBuiltinTheme themeWithName:REThemeNightshadeName] applyThemeToElement:buttonGroup];

    SetConstraints(buttonGroup,
                   @"_up.top = buttonGroup.top\n"
                   "down.top = _up.bottom\n"
                   "down.height = _up.height\n"
                   "_up.left = buttonGroup.left\n"
                   "_up.right = buttonGroup.right\n"
                   "down.left = buttonGroup.left\n"
                   "down.right = buttonGroup.right\n"
                   "_up.height = buttonGroup.height * 0.5\n"
                   "buttonGroup.width = 70\n"
                   "buttonGroup.height ≥ 150",
                   _up, down);

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}


+ (REPickerLabelButtonGroup *)constructDVRRocker
{
    REPickerLabelButtonGroup * buttonGroup = [self rawRocker];
    buttonGroup.displayName = @"DVR Activity Rocker";
    [buttonGroup addCommandSet:DVRChannelsCommandSet      withLabel:@"CH"];
    [buttonGroup addCommandSet:DVRPagingCommandSet        withLabel:@"PAGE"];
    [buttonGroup addCommandSet:AVReceiverVolumeCommandSet withLabel:@"VOL"];

    return buttonGroup;
}


+ (REPickerLabelButtonGroup *)constructPS3Rocker
{
    REPickerLabelButtonGroup * buttonGroup = [self rawRocker];
    buttonGroup.displayName = @"Playstation Activity Rocker";
    [buttonGroup addCommandSet:AVReceiverVolumeCommandSet withLabel:@"VOL"];

    return buttonGroup;
}


+ (REPickerLabelButtonGroup *)constructSonosRocker
{
    REPickerLabelButtonGroup * buttonGroup = [self rawRocker];
    buttonGroup.displayName = @"Sonos Activity Rocker";
    [buttonGroup addCommandSet:AVReceiverVolumeCommandSet withLabel:@"VOL"];

    return buttonGroup;
}

+ (REButtonGroup *)constructSonosMuteButtonGroup
{
    REButtonGroup * buttonGroup = MakeButtonGroup(@"displayName" : @"Mute");
    REButton * mute =
        MakeButton(@"command"     : MakeIRCommand([BOComponentDevice fetchDeviceWithName:@"AV Receiver"],
                                                  @"Mute"),
                   @"shape"       : @(REShapeRoundedRectangle),
                   @"displayName" : @"Mute",
                   @"title"       : @"Mute");

    [buttonGroup addSubelementsObject:mute];

    [[REBuiltinTheme themeWithName:REThemeNightshadeName] applyThemeToElement:mute];

    SetConstraints(buttonGroup,
                   @"mute.centerX = buttonGroup.centerX\n"
                   "mute.centerY = buttonGroup.centerY\n"
                   "mute.width = buttonGroup.width\n"
                   "mute.height = buttonGroup.height\n"
                   "buttonGroup.width ≥ 132",
                   mute);

    return buttonGroup;
}

+ (REButtonGroup *)constructSelectionPanel
{
    REButtonGroup * buttonGroup =
        MakeSelectionPanelButtonGroup(@"displayName"     : @"Configuration Selection Panel",
                                      @"subtype"         : @(REButtonGroupRightPanel),
                                      @"backgroundColor" : FlipsideColor,
                                      @"key"             : RERemoteRightPanel1Key);

    REButton * stbButton =
        MakeButton(@"displayName": @"Select Set Top Box",
                   @"title"      : @"STB",
                   @"key"        : REDefaultConfiguration);

    REButton * tvButton =
        MakeButton(@"displayName" : @"Select Samsung TV",
                   @"title"       : @"TV",
                   @"key"         : kTVConfiguration);

    [buttonGroup addSubelements:[@[stbButton, tvButton] orderedSet]];

//    [[REBuiltinTheme themeWithName:REThemeNightshadeName] applyThemeToElement:buttonGroup];

    // TODO: Add alignment and sizing options for buttons
    SetConstraints(buttonGroup,
                   @"buttonGroup.width = 150\n"
                   "buttonGroup.height ≥ 240\n"
                   "tvButton.width = buttonGroup.width\n"
                   "stbButton.width = buttonGroup.width\n"
                   "tvButton.centerX = buttonGroup.centerX\n"
                   "stbButton.centerX = buttonGroup.centerX\n"
                   "stbButton.top = buttonGroup.top\n"
                   "tvButton.bottom = buttonGroup.bottom\n"
                   "stbButton.bottom = tvButton.top\n"
                   "tvButton.height = stbButton.height",
                   tvButton, stbButton);

    return buttonGroup;
}

+ (REButtonGroup *)rawGroupOfThreeButtons
{
    REButtonGroup * buttonGroup = MakeButtonGroup(@"displayName" : @"1x3");

    REButton * button1 =
        MakeButton(@"shape"       : @(REShapeRoundedRectangle),
                   @"displayName" : @"button1");

    REButton * button2 =
        MakeButton(@"shape"       : @(REShapeRoundedRectangle),
                   @"displayName" : @"button2");

    REButton * button3 =
        MakeButton(@"shape"       : @(REShapeRoundedRectangle),
                   @"displayName" : @"button3");

    [buttonGroup addSubelements:[@[button1, button2, button3] orderedSet]];

    [[REBuiltinTheme themeWithName:REThemeNightshadeName]
     applyThemeToElements:[buttonGroup.subelements set]];

    SetConstraints(buttonGroup,
                   @"button1.left = buttonGroup.left\n"
                    "button1.right = buttonGroup.right\n"
                    "button2.left = buttonGroup.left\n"
                    "button2.right = buttonGroup.right\n"
                    "button3.left = buttonGroup.left\n"
                    "button3.right = buttonGroup.right\n"
                    "button1.top = buttonGroup.top\n"
                    "button2.top = button1.bottom + 4\n"
                    "button3.top = button2.bottom + 4\n"
                    "button3.bottom = buttonGroup.bottom\n"
                    "button2.height = button1.height\n"
                    "button3.height = button1.height\n"
                    "buttonGroup.width ≥ 132\n"
                    "buttonGroup.height ≥ 150",
                    button1, button2, button3);

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}

+ (REButtonGroup *)constructDVRGroupOfThreeButtons
{
    // fetch devices
    BOComponentDevice * comcastDVR = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"];
    BOComponentDevice * samsungTV  = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"];

    // create button group
    REButtonGroup * buttonGroup = [self rawGroupOfThreeButtons];
    buttonGroup.displayName = @"DVR Activity 1x3";

    // Configure "Guide" button and its delegate
    REButton * guideButton = buttonGroup[0];
    guideButton.displayName = @"Guide / Tools";
    [guideButton setTitle:@"Guide" forConfiguration:REDefaultConfiguration];
    [guideButton setTitle:@"Tools" forConfiguration:kTVConfiguration];
    [guideButton setCommand:MakeIRCommand(comcastDVR, @"Guide") forConfiguration:REDefaultConfiguration];
    [guideButton setCommand:MakeIRCommand(samsungTV, @"Tools")  forConfiguration:kTVConfiguration];

    // Configure "DVR" button and add its delegate
    REButton * dvrButton = buttonGroup[1];
    dvrButton.displayName = @"DVR / Internet@TV";
    [dvrButton setTitle:@"DVR"         forConfiguration:REDefaultConfiguration];
    [dvrButton setTitle:@"Internet@TV" forConfiguration:kTVConfiguration];
    [dvrButton setCommand:MakeIRCommand(comcastDVR, @"DVR")        forConfiguration:REDefaultConfiguration];
    [dvrButton setCommand:MakeIRCommand(samsungTV, @"Internet@TV") forConfiguration:kTVConfiguration];

    // Configure "Info" button and its delegate
    REButton * infoButton = buttonGroup[2];
    infoButton.displayName = @"Info";
    [infoButton setTitle:@"Info" forConfiguration:REDefaultConfiguration];
    [infoButton setTitle:@"Info" forConfiguration:kTVConfiguration];
    [infoButton setCommand:MakeIRCommand(comcastDVR, @"Info") forConfiguration:REDefaultConfiguration];
    [infoButton setCommand:MakeIRCommand(samsungTV, @"Info")  forConfiguration:kTVConfiguration];

    return buttonGroup;
}

+ (REButtonGroup *)constructPS3GroupOfThreeButtons
{
    // fetch device
    BOComponentDevice * ps3 = [BOComponentDevice fetchDeviceWithName:@"PS3"];

    // create button group
    REButtonGroup * buttonGroup = [self rawGroupOfThreeButtons];
    buttonGroup.displayName = @"PS3 Activity 1x3";

    // configure buttons
    REButton * displayButton    = buttonGroup[0];
    displayButton.displayName   = @"Display";
    displayButton.title         = @"Display";
    displayButton.command       = MakeIRCommand(ps3, @"Display");

    REButton * topMenuButton    = buttonGroup[1];
    topMenuButton.displayName   = @"Top Menu";
    topMenuButton.title         = @"Top Menu";
    topMenuButton.command       = MakeIRCommand(ps3, @"Top Menu");

    REButton * popupMenuButton  = buttonGroup[2];
    popupMenuButton.displayName = @"Popup Menu";
    popupMenuButton.title       = @"Popup Menu";
    popupMenuButton.command     = MakeIRCommand(ps3, @"Popup Menu");

    return buttonGroup;
}

+ (REButtonGroup *)rawButtonPanel
{
    REButtonGroup * buttonGroup =
        MakeButtonGroup(@"backgroundColor"  : [kPanelBackgroundColor colorWithAlphaComponent:0.75],
                        @"displayName"      : @"Raw Button Panel");

    REButton * button1 =
        MakeButton(@"shape"       : @(REShapeRoundedRectangle),
                   @"displayName" : @"button1");

    REButton * button2 =
        MakeButton(@"shape"       : @(REShapeRoundedRectangle),
                   @"displayName" : @"button2");

    REButton * button3 =
        MakeButton(@"shape"       : @(REShapeRoundedRectangle),
                   @"displayName" : @"button3");

    REButton * button4 =
        MakeButton(@"shape"       : @(REShapeRoundedRectangle),
                   @"displayName" : @"button4");

    REButton * button5 =
        MakeButton(@"shape"       : @(REShapeRoundedRectangle),
                   @"displayName" : @"button5");

    REButton * button6 =
        MakeButton(@"shape"       : @(REShapeRoundedRectangle),
                   @"displayName" : @"button6");

    REButton * button7 =
        MakeButton(@"shape"       : @(REShapeRoundedRectangle),
                   @"displayName" : @"button7");

    REButton * button8 =
        MakeButton(@"key"         : REButtonGroupTuckButtonKey,
                   @"displayName" : @"tuck");

    [buttonGroup addSubelements:[@[button1, button2, button3, button4,
                                 button5, button6, button7, button8] orderedSet]];

    [[REBuiltinTheme themeWithName:REThemeNightshadeName]
     applyThemeToElements:[buttonGroup.subelements set]];

    SetConstraints(buttonGroup,
                   @"button1.left = buttonGroup.left + 4\n"
                    "button1.right = buttonGroup.right - 4\n"
                    "button2.left = buttonGroup.left + 4\n"
                    "button2.right = buttonGroup.right - 4\n"
                    "button3.left = buttonGroup.left + 4\n"
                    "button3.right = buttonGroup.right - 4\n"
                    "button4.left = buttonGroup.left + 4\n"
                    "button4.right = buttonGroup.right - 4\n"
                    "button5.left = buttonGroup.left + 4\n"
                    "button5.right = buttonGroup.right - 4\n"
                    "button6.left = buttonGroup.left + 4\n"
                    "button6.right = buttonGroup.right - 4\n"
                    "button7.left = buttonGroup.left + 4\n"
                    "button7.right = buttonGroup.right - 4\n"
                    "button8.left = buttonGroup.left + 4\n"
                    "button8.right = buttonGroup.right - 4\n"
                    "button1.top = buttonGroup.top + 4\n"
                    "button2.top = button1.bottom + 4\n"
                    "button3.top = button2.bottom + 4\n"
                    "button4.top = button3.bottom + 4\n"
                    "button5.top = button4.bottom + 4\n"
                    "button6.top = button5.bottom + 4\n"
                    "button7.top = button6.bottom + 4\n"
                    "button8.top = button7.bottom + 4\n"
                    "button8.bottom = buttonGroup.bottom - 4\n"
                    "button2.height = button1.height\n"
                    "button3.height = button1.height\n"
                    "button4.height = button1.height\n"
                    "button5.height = button1.height\n"
                    "button6.height = button1.height\n"
                    "button7.height = button1.height\n"
                    "button8.height = button1.height\n"
                    "buttonGroup.width = 150",
                    button1, button2, button3, button4, button5, button6, button7, button8);

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}

+ (REButtonGroup *)constructHomeAndPowerButtonsForActivity:(NSInteger)activity
{
    REButtonGroup * buttonGroup = MakeButtonGroup(@"displayName" : @"Home and Power Buttons");
    
     REButton * homeButton =
         MakeButton(@"shape"       : @(REShapeOval),
                    @"displayName" : @"Home Button",
                    @"icons"       : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                          @"highlighted" : kHighlightColor }),
                                                      (@{ @"normal"      : MakeIconImage(140) }))/*,
                    @"command"     : MakeSwitchCommand(@"MSRemoteControllerHomeRemoteKeyName")*/);

     REButton * powerButton =
         MakeButton(@"shape"       : @(REShapeOval),
                    @"displayName" : @"Power Off and Exit Activity",
                    @"key"         : $(@"activity%i", activity),
                    @"icons"       : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                          @"highlighted" : kHighlightColor }),
                                                      (@{ @"normal"      : MakeIconImage(168) }))//,
                    /*@"command"     : [REMacroBuilder activityMacroForActivity:activity
                                                                         toInitiateState:NO
                                                                             switchIndex:NULL]*/);

     [buttonGroup addSubelements:[@[homeButton, powerButton] orderedSet]];

     SetConstraints(homeButton,  @"homeButton.width = 50\nhomeButton.height = homeButton.width");
     SetConstraints(powerButton, @"powerButton.width = 50\npowerButton.height = powerButton.width");
     SetConstraints(buttonGroup,
                    @"buttonGroup.width = 300\n"
                     "buttonGroup.height = 50\n"
                     "homeButton.left = buttonGroup.left\n"
                     "powerButton.right = buttonGroup.right\n"
                     "homeButton.centerY = buttonGroup.centerY\n"
                     "powerButton.centerY = buttonGroup.centerY",
                     homeButton, powerButton);

    return buttonGroup;
}

+ (REButtonGroup *)constructAdditionalButtonsLeft
{
    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"];
    BOComponentDevice * samsungTV  = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"];
    BOComponentDevice * comcastDVR = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"];

    REButtonGroup * buttonGroup = [self rawButtonPanel];
    buttonGroup.panelLocation = REPanelLocationLeft;
    buttonGroup.key           = RERemoteLeftPanel1Key;
    buttonGroup.displayName   = @"Left Overlay Panel";

    REButton * button = buttonGroup[0];
    button.displayName = @"On Demand / Source";
    [button setTitle:@"On Demand" forConfiguration:REDefaultConfiguration];
    [button setTitle:@"Source"    forConfiguration:kTVConfiguration];
    [button setCommand:MakeIRCommand(comcastDVR, @"On Demand") forConfiguration:REDefaultConfiguration];
    [button setCommand:MakeIRCommand(samsungTV, @"Source")     forConfiguration:kTVConfiguration];

    button= buttonGroup[1];
    button.displayName = @"Menu";
    [button setTitle:@"Menu" forConfiguration:REDefaultConfiguration];
    [button setTitle:@"Menu" forConfiguration:kTVConfiguration];
    [button setCommand:MakeIRCommand(comcastDVR, @"Menu") forConfiguration:REDefaultConfiguration];
    [button setCommand:MakeIRCommand(samsungTV, @"Menu")  forConfiguration:kTVConfiguration];

    button= buttonGroup[2];
    button.displayName = @"Last / Return";
    [button setTitle:@"Last"   forConfiguration:REDefaultConfiguration];
    [button setTitle:@"Return" forConfiguration:kTVConfiguration];
    [button setCommand:MakeIRCommand(comcastDVR, @"Last")  forConfiguration:REDefaultConfiguration];
    [button setCommand:MakeIRCommand(samsungTV, @"Return") forConfiguration:kTVConfiguration];

    button= buttonGroup[3];
    button.displayName = @"Exit";
    [button setTitle:@"Exit" forConfiguration:REDefaultConfiguration];
    [button setTitle:@"Exit" forConfiguration:kTVConfiguration];
    [button setCommand:MakeIRCommand(comcastDVR, @"Exit") forConfiguration:REDefaultConfiguration];
    [button setCommand:MakeIRCommand(samsungTV, @"Exit")  forConfiguration:kTVConfiguration];

    button = buttonGroup[4];
    button.displayName = @"DVR Audio Input";
    button.title = @"DVR Audio";
    button.command = MakeIRCommand(avReceiver, @"TV/SAT");

    button = buttonGroup[5];
    button.displayName = @"TV Audio Input";
    button.title = @"TV Audio";
    button.command = MakeIRCommand(avReceiver, @"Video 3");

    button = buttonGroup[6];
    button.displayName = @"Mute";
    button.title = @"Mute";
    button.command = MakeIRCommand(avReceiver, @"Mute");

    button = buttonGroup[7];
    button.displayName = @"Tuck Panel";
    button.title = kLeftArrow;

    return buttonGroup;
}

@end
