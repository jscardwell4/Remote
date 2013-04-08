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
    NSManagedObjectContext * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup          * buttonGroup = nil;
    buttonGroup =
        MakeToolbarButtonGroup(@"type"            : @(REButtonGroupTypeToolbar),
                               @"displayName"     : @"Top Toolbar",
                               @"key"             : MSRemoteControllerTopToolbarKeyName,
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
    NSManagedObjectContext * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup          * buttonGroup = nil;
    buttonGroup = MakeButtonGroup(@"displayName" : @"Activity Buttons",
                                  @"key"         : @"activityButtons");

    REActivityButton * dvrActivityButton = [REButtonBuilder
                                            launchActivityButtonWithTitle:@"Comcast\nDVR"
                                                                 activity:1];
    REActivityButton * ps3ActivityButton = [REButtonBuilder
                                            launchActivityButtonWithTitle:@"Playstation"
                                                                 activity:2];
    REActivityButton * appleTVActivityButton = [REButtonBuilder
                                                launchActivityButtonWithTitle:@" TV"
                                                                     activity:3];
    REActivityButton * sonosActivityButton = [REButtonBuilder
                                              launchActivityButtonWithTitle:@"Sonos"
                                                                   activity:4];
    [buttonGroup addSubelements:[@[dvrActivityButton,
                                   ps3ActivityButton,
                                   appleTVActivityButton,
                                   sonosActivityButton] orderedSet]];

    SetConstraints(buttonGroup,
                   @"buttonGroup.width = 300\n"
                   "buttonGroup.height = buttonGroup.width\n"
                   "dvrActivityButton.width = buttonGroup.width * 0.5\n"
                   "dvrActivityButton.centerX = buttonGroup.centerX * 0.5\n"
                   "dvrActivityButton.centerY = buttonGroup.centerY * 0.5\n"
                   "ps3ActivityButton.width = dvrActivityButton.width\n"
                   "ps3ActivityButton.centerX = buttonGroup.centerX * 1.5\n"
                   "ps3ActivityButton.centerY = buttonGroup.centerY * 0.5\n"
                   "appleTVActivityButton.width = dvrActivityButton.width\n"
                   "appleTVActivityButton.centerX = buttonGroup.centerX * 0.5\n"
                   "appleTVActivityButton.centerY = buttonGroup.centerY * 1.5\n"
                   "sonosActivityButton.width = dvrActivityButton.width\n"
                   "sonosActivityButton.centerX = buttonGroup.centerX * 1.5\n"
                   "sonosActivityButton.centerY = buttonGroup.centerY * 1.5",
                   dvrActivityButton,
                   ps3ActivityButton,
                   appleTVActivityButton,
                   sonosActivityButton);

    SetConstraints(dvrActivityButton,     @"dvrActivityButton.height = dvrActivityButton.width");
    SetConstraints(ps3ActivityButton,     @"ps3ActivityButton.height = ps3ActivityButton.width");
    SetConstraints(appleTVActivityButton, @"appleTVActivityButton.height = appleTVActivityButton.width");
    SetConstraints(sonosActivityButton,   @"sonosActivityButton.height = sonosActivityButton.width");

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}


+ (REButtonGroup *)constructLightControls
{
    NSManagedObjectContext * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup          * buttonGroup = nil;
    buttonGroup =
        MakeButtonGroup(@"displayName"     : @"Light Controls",
                        @"key"             : @"lightControls",
                        @"backgroundColor" : FlipsideColor);

    REButton * lightsOnButton =
        MakeButton(@"icons"       : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                         @"highlighted" : kHighlightColor }),
                                                     @{ @"normal"      : MakeIconImage(1) }),
                   @"command"     : MakeHTTPCommand(@"http://10.0.1.27/0?1201=I=0"),
                   @"key"         : @"lightsOn",
                   @"displayName" : @"Lights On");

    REButton * lightsOffButton =
        MakeButton(@"icons"       : MakeIconImageSet((@{ @"normal"      : GrayColor,
                                                         @"highlighted" : kHighlightColor }),
                                                     (@{ @"normal"      : MakeIconImage(1) })),
                   @"command"     : MakeHTTPCommand(@"http://10.0.1.27/0?1401=I=0"),
                   @"key"         : @"lightsOff",
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
    NSManagedObjectContext * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup          * buttonGroup = nil;
    buttonGroup =
        MakeButtonGroup(@"key"             : @"dpad",
                        @"displayName"     : @"dpad",
                        @"backgroundColor" : defaultBGColor(),
                        @"shape"           : @(REShapeOval),
                        @"style"           : @(REStyleApplyGloss|REStyleDrawBorder));

    NSMutableDictionary * attrHigh = [@{} mutableCopy];
    NSDictionary        * attr     = [REButtonBuilder
                           buttonTitleAttributesWithFontName:kDefaultFontName
                                                    fontSize:32.0
                                                 highlighted:attrHigh];

    // Create center "OK" button and add to button group
    NSAttributedString * label = [NSAttributedString
                                      attributedStringWithString:@"OK"
                                                      attributes:attr];
    NSAttributedString * labelHigh = [NSAttributedString
                                      attributedStringWithString:@"OK"
                                                      attributes:attrHigh];

    REButton * ok =
        MakeButton(@"key"         : REDPadOkButtonKey,
                   @"displayName" : @"OK",
                   @"titles"      : MakeTitleSet(@{ @"normal"      : label,
                                                    @"highlighted" : labelHigh }));

    [buttonGroup addSubelementsObject:ok];

    // Create _up button and add to button group
    attr = [REButtonBuilder             buttonTitleAttributesWithFontName:kArrowFontName
                                                                 fontSize:32.0
                                                              highlighted:attrHigh];
    label     = [NSAttributedString attributedStringWithString:kUpArrow attributes:attr];
    labelHigh = [NSAttributedString attributedStringWithString:kUpArrow
                                                    attributes:attrHigh];

    REButton * _up =
        MakeButton(@"key"         : REDPadUpButtonKey,
                   @"displayName" : @"Up",
                   @"titles"      : MakeTitleSet(@{ @"normal"      : label,
                                                    @"highlighted" : labelHigh }),
                   @"style"       : @(REButtonSubtypeButtonGroupPiece));

    // Create down button and add to button group
    label     = [NSAttributedString attributedStringWithString:kDownArrow attributes:attr];
    labelHigh = [NSAttributedString attributedStringWithString:kDownArrow
                                                    attributes:attrHigh];

    REButton * down =
        MakeButton(@"subtype"     : @(REButtonSubtypeButtonGroupPiece),
                   @"key"         : REDPadDownButtonKey,
                   @"displayName" : @"Down",
                   @"titles"      : MakeTitleSet(@{ @"normal"      : label,
                                                    @"highlighted" : labelHigh }));

    // Create right button and add to button group
    label     = [NSAttributedString attributedStringWithString:kRightArrow attributes:attr];
    labelHigh = [NSAttributedString attributedStringWithString:kRightArrow
                                                    attributes:attrHigh];

    REButton * _right =
        MakeButton(@"style"       : @(REButtonSubtypeButtonGroupPiece),
                   @"key"         : REDPadRightButtonKey,
                   @"displayName" : @"Right",
                   @"titles"      : MakeTitleSet(@{ @"normal"      : label,
                                                    @"highlighted" : labelHigh }));

    // Create left button and add to button group
    label     = [NSAttributedString attributedStringWithString:kLeftArrow attributes:attr];
    labelHigh = [NSAttributedString attributedStringWithString:kLeftArrow
                                                    attributes:attrHigh];

    REButton * _left =
        MakeButton(@"subtype"     : @(REButtonSubtypeButtonGroupPiece),
                   @"key"         : REDPadLeftButtonKey,
                   @"displayName" : @"Left",
                   @"titles"      : MakeTitleSet(@{ @"normal"      : label,
                                                    @"highlighted" : labelHigh }));

    [buttonGroup addSubelements:[@[ok, _up, down, _left, _right] orderedSet]];

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
    NSManagedObjectContext * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup          * buttonGroup = nil;
    BOComponentDevice      * comcastDVR  = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                          context:context];
    BOComponentDevice * samsungTV = [BOComponentDevice   fetchDeviceWithName:@"Samsung TV"
                                                                     context:context];

    buttonGroup             = [self rawDPad];
    buttonGroup.displayName = @"DVR DPad";

    // Create default DPad command set
    RECommandSet * dvrDPad = [RECommandSet commandSetInContext:context type:RECommandSetTypeDPad];
    dvrDPad[REDPadOkButtonKey]    = MakeIRCommand(comcastDVR, @"OK");
    dvrDPad[REDPadUpButtonKey]    = MakeIRCommand(comcastDVR, @"Up");
    dvrDPad[REDPadDownButtonKey]  = MakeIRCommand(comcastDVR, @"Down");
    dvrDPad[REDPadRightButtonKey] = MakeIRCommand(comcastDVR, @"Right");
    dvrDPad[REDPadLeftButtonKey]  = MakeIRCommand(comcastDVR, @"Left");

    [buttonGroup.configurationDelegate setCommandSet:dvrDPad forConfiguration:REDefaultConfiguration];

    // Create tv DPad command set
    RECommandSet * tvDPad = [RECommandSet commandSetInContext:context type:RECommandSetTypeDPad];
    tvDPad[REDPadOkButtonKey]    = MakeIRCommand(samsungTV, @"Enter");
    tvDPad[REDPadUpButtonKey]    = MakeIRCommand(samsungTV, @"Up");
    tvDPad[REDPadDownButtonKey]  = MakeIRCommand(samsungTV, @"Down");
    tvDPad[REDPadRightButtonKey] = MakeIRCommand(samsungTV, @"Right");
    tvDPad[REDPadLeftButtonKey]  = MakeIRCommand(samsungTV, @"Left");

    [buttonGroup.configurationDelegate setCommandSet:tvDPad forConfiguration:kTVConfiguration];

    return buttonGroup;
}


+ (REButtonGroup *)constructPS3DPad
{
    NSManagedObjectContext * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup          * buttonGroup = nil;
    BOComponentDevice      * ps3         = [BOComponentDevice fetchDeviceWithName:@"PS3" context:context];

    buttonGroup             = [self rawDPad];
    buttonGroup.displayName = @"Playstation DPad";

    // Create default DPad command set
    RECommandSet * ps3DPad = [RECommandSet commandSetInContext:context type:RECommandSetTypeDPad];
    ps3DPad[REDPadOkButtonKey]    = MakeIRCommand(ps3, @"Enter");
    ps3DPad[REDPadUpButtonKey]    = MakeIRCommand(ps3, @"Up");
    ps3DPad[REDPadDownButtonKey]  = MakeIRCommand(ps3, @"Down");
    ps3DPad[REDPadRightButtonKey] = MakeIRCommand(ps3, @"Right");
    ps3DPad[REDPadLeftButtonKey]  = MakeIRCommand(ps3, @"Left");

    buttonGroup.commandSet = ps3DPad;

    return buttonGroup;
}


+ (REButtonGroup *)rawNumberPad
{
    NSManagedObjectContext * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup          * buttonGroup = nil;
    buttonGroup =
        MakeButtonGroup(@"key"             : @"numberpad",
                        @"displayName"     : @"numberpad",
                        @"backgroundColor" :[kPanelBackgroundColor colorWithAlphaComponent:0.75]);

    NSNumber * style = @(REShapeRoundedRectangle | REStyleApplyGloss | REStyleDrawBorder);

    NSMutableDictionary * attrHigh = [@{} mutableCopy];

    NSMutableDictionary * attr = [REButtonBuilder
                                  buttonTitleAttributesWithFontName:kDefaultFontName
                                                           fontSize:64.0
                                                        highlighted:attrHigh];

    NSAttributedString * label = [NSAttributedString attributedStringWithString:@"1"
                                                                     attributes:attr];
    NSAttributedString * labelHigh = [NSAttributedString attributedStringWithString:@"1"
                                                                         attributes:attrHigh];

    REButton * one =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"style"           : style,
                   @"key"             : REDigitOneButtonKey,
                   @"displayName"     : @"Digit 1",
                   @"titles"          : MakeTitleSet(@{ @"normal" : label, @"highlighted" : labelHigh }));

    label     = [NSAttributedString attributedStringWithString:@"2" attributes:attr];
    labelHigh = [NSAttributedString attributedStringWithString:@"2" attributes:attrHigh];

    REButton * two =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"style"           : style,
                   @"key"             : REDigitTwoButtonKey,
                   @"displayName"     : @"Digit 2",
                   @"titles"          : MakeTitleSet(@{ @"normal" : label, @"highlighted" : labelHigh }));

    label     = [NSAttributedString attributedStringWithString:@"3" attributes:attr];
    labelHigh = [NSAttributedString attributedStringWithString:@"3" attributes:attrHigh];

    REButton * three =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"style"           : style,
                   @"key"             : REDigitThreeButtonKey,
                   @"displayName"     : @"Digit 3",
                   @"titles"          : MakeTitleSet(@{ @"normal" : label, @"highlighted" : labelHigh }));

    label     = [NSAttributedString attributedStringWithString:@"4" attributes:attr];
    labelHigh = [NSAttributedString attributedStringWithString:@"4" attributes:attrHigh];

    REButton * four =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"style"           : style,
                   @"key"             : REDigitFourButtonKey,
                   @"displayName"     : @"Digit 4",
                   @"titles"          : MakeTitleSet(@{ @"normal" : label, @"highlighted" : labelHigh }));

    label     = [NSAttributedString attributedStringWithString:@"5" attributes:attr];
    labelHigh = [NSAttributedString attributedStringWithString:@"5" attributes:attrHigh];

    REButton * five =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"style"           : style,
                   @"key"             : REDigitFiveButtonKey,
                   @"displayName"     : @"Digit 5",
                   @"titles"          : MakeTitleSet(@{ @"normal" : label, @"highlighted" : labelHigh }));

    label     = [NSAttributedString attributedStringWithString:@"6" attributes:attr];
    labelHigh = [NSAttributedString attributedStringWithString:@"6" attributes:attrHigh];

    REButton * six =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"style"           : style,
                   @"key"             : REDigitSixButtonKey,
                   @"displayName"     : @"Digit 6",
                   @"titles"          : MakeTitleSet(@{ @"normal" : label, @"highlighted" : labelHigh }));

    label     = [NSAttributedString attributedStringWithString:@"7" attributes:attr];
    labelHigh = [NSAttributedString attributedStringWithString:@"7" attributes:attrHigh];

    REButton * seven =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"style"           : style,
                   @"key"             : REDigitSevenButtonKey,
                   @"displayName"     : @"Digit 7",
                   @"titles"          : MakeTitleSet(@{ @"normal" : label, @"highlighted" : labelHigh }));

    label     = [NSAttributedString attributedStringWithString:@"8" attributes:attr];
    labelHigh = [NSAttributedString attributedStringWithString:@"8" attributes:attrHigh];

    REButton * _eight =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"style"           : style,
                   @"key"             : REDigitEightButtonKey,
                   @"displayName"     : @"Digit 8",
                   @"titles"          : MakeTitleSet(@{ @"normal" : label, @"highlighted" : labelHigh }));

    label     = [NSAttributedString attributedStringWithString:@"9" attributes:attr];
    labelHigh = [NSAttributedString attributedStringWithString:@"9" attributes:attrHigh];

    REButton * nine =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"style"           : style,
                   @"key"             : REDigitNineButtonKey,
                   @"displayName"     : @"Digit 9",
                   @"titles"          : MakeTitleSet(@{ @"normal" : label, @"highlighted" : labelHigh }));

    label     = [NSAttributedString attributedStringWithString:@"0" attributes:attr];
    labelHigh = [NSAttributedString attributedStringWithString:@"0" attributes:attrHigh];

    REButton * zero =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"style"           : style,
                   @"key"             : REDigitZeroButtonKey,
                   @"displayName"     : @"Digit 0",
                   @"titles"          : MakeTitleSet(@{ @"normal" : label, @"highlighted" : labelHigh }));

    attr[NSForegroundColorAttributeName] = [UIColor colorWithWhite:0.0 alpha:0.5];
    attr[NSStrokeWidthAttributeName]     = @"normal";

    label = [NSAttributedString attributedStringWithString:kUpArrow attributes:attr];

    attrHigh[NSStrokeWidthAttributeName] = @"normal";
    labelHigh                            = [NSAttributedString attributedStringWithString:kUpArrow attributes:attrHigh];

    REButton * tuck =
        MakeButton(@"key"         : REButtonGroupTuckButtonKey,
                   @"displayName" : @"Tuck Panel",
                   @"titles"      : MakeTitleSet(@{ @"normal" : label, @"highlighted" : labelHigh }));

    [attrHigh removeAllObjects];
    attr = [REButtonBuilder      buttonTitleAttributesWithFontName:kDefaultFontName
                                                          fontSize:32.0
                                                       highlighted:attrHigh];
    label     = [NSAttributedString attributedStringWithString:@"Exit" attributes:attr];
    labelHigh = [NSAttributedString attributedStringWithString:@"Exit" attributes:attrHigh];

    REButton * aux1 =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"style"           : style,
                   @"key"             : REAuxOneButtonKey,
                   @"displayName"     : @"Exit",
                   @"titles"          : MakeTitleSet(@{ @"normal" : label, @"highlighted" : labelHigh }));

    label     = [NSAttributedString attributedStringWithString:@"Enter" attributes:attr];
    labelHigh = [NSAttributedString attributedStringWithString:@"Enter" attributes:attrHigh];

    REButton * aux2 =
        MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                   @"style"           : style,
                   @"key"             : REAuxTwoButtonKey,
                   @"displayName"     : @"Enter",
                   @"titles"          : MakeTitleSet(@{ @"normal" : label, @"highlighted" : labelHigh }));

    [buttonGroup addSubelements:[@[one, two, three, four, five, six,
                                   seven, _eight, nine, zero, aux1, aux2, tuck] orderedSet]];

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
    NSManagedObjectContext * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup          * buttonGroup = nil;
    BOComponentDevice      * comcastDVR  = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                          context:context];

    // Create number pad button and add to button group
    RECommandSet * dvrNumberPad = [RECommandSet commandSetInContext:context type:RECommandSetTypeNumberPad];
    dvrNumberPad[REDigitOneButtonKey]   = MakeIRCommand(comcastDVR, @"One");
    dvrNumberPad[REDigitTwoButtonKey]   = MakeIRCommand(comcastDVR, @"Two");
    dvrNumberPad[REDigitThreeButtonKey] = MakeIRCommand(comcastDVR, @"Three");
    dvrNumberPad[REDigitFourButtonKey]  = MakeIRCommand(comcastDVR, @"Four");
    dvrNumberPad[REDigitFiveButtonKey]  = MakeIRCommand(comcastDVR, @"Five");
    dvrNumberPad[REDigitSixButtonKey]   = MakeIRCommand(comcastDVR, @"Six");
    dvrNumberPad[REDigitSevenButtonKey] = MakeIRCommand(comcastDVR, @"Seven");
    dvrNumberPad[REDigitEightButtonKey] = MakeIRCommand(comcastDVR, @"Eight");
    dvrNumberPad[REDigitNineButtonKey]  = MakeIRCommand(comcastDVR, @"Nine");
    dvrNumberPad[REDigitZeroButtonKey]  = MakeIRCommand(comcastDVR, @"Zero");
    dvrNumberPad[REAuxOneButtonKey]     = MakeIRCommand(comcastDVR, @"Exit");
    dvrNumberPad[REAuxTwoButtonKey]     = MakeIRCommand(comcastDVR, @"OK");

    buttonGroup               = [self rawNumberPad];
    buttonGroup.displayName   = @"DVR Number Pad";
    buttonGroup.commandSet    = dvrNumberPad;
    buttonGroup.key           = RERemoteTopPanel1Key;
    buttonGroup.panelLocation = REPanelLocationTop;
    buttonGroup.commandSet    = dvrNumberPad;

    return buttonGroup;
}


+ (REButtonGroup *)constructPS3NumberPad
{
    NSManagedObjectContext * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup          * buttonGroup = nil;
    BOComponentDevice      * ps3         = [BOComponentDevice fetchDeviceWithName:@"PS3" context:context];

    // Create number pad button and add to button group
    RECommandSet * ps3NumberPad = [RECommandSet commandSetInContext:context
                                                               type:RECommandSetTypeNumberPad];
    ps3NumberPad[REDigitOneButtonKey]   = MakeIRCommand(ps3, @"1");
    ps3NumberPad[REDigitTwoButtonKey]   = MakeIRCommand(ps3, @"2");
    ps3NumberPad[REDigitThreeButtonKey] = MakeIRCommand(ps3, @"3");
    ps3NumberPad[REDigitFourButtonKey]  = MakeIRCommand(ps3, @"4");
    ps3NumberPad[REDigitFiveButtonKey]  = MakeIRCommand(ps3, @"5");
    ps3NumberPad[REDigitSixButtonKey]   = MakeIRCommand(ps3, @"6");
    ps3NumberPad[REDigitSevenButtonKey] = MakeIRCommand(ps3, @"7");
    ps3NumberPad[REDigitEightButtonKey] = MakeIRCommand(ps3, @"8");
    ps3NumberPad[REDigitNineButtonKey]  = MakeIRCommand(ps3, @"9");
    ps3NumberPad[REDigitZeroButtonKey]  = MakeIRCommand(ps3, @"0");

    buttonGroup               = [self rawNumberPad];
    buttonGroup.displayName   = @"Playstation Number Pad";
    buttonGroup.key           = RERemoteTopPanel1Key;
    buttonGroup.panelLocation = REPanelLocationTop;
    buttonGroup.commandSet    = ps3NumberPad;

    return buttonGroup;
}


+ (REButtonGroup *)rawTransport
{
    NSManagedObjectContext * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup          * buttonGroup = nil;
    buttonGroup =
        MakeButtonGroup(@"key"             : @"transport",
                        @"displayName"     : @"transport",
                        @"backgroundColor" :[kPanelBackgroundColor colorWithAlphaComponent:0.75]);

    // Create "rewind" button and add to button group
    REButton * rewind =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"style"           : @(REStyleApplyGloss | REStyleDrawBorder),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportRewindButtonKey,
                   @"displayName"     : @"Rewind",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4004) })));

    // Create "pause" button and add to button group
    REButton * pause =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"style"           : @(REStyleApplyGloss | REStyleDrawBorder),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportPauseButtonKey,
                   @"displayName"     : @"Pause",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4001) })));

    // Create "fast forward" button and add to button group
    REButton * fastForward =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"style"           : @(REStyleApplyGloss | REStyleDrawBorder),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportFastForwardButtonKey,
                   @"displayName"     : @"Fast Forward",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4000) })));

    // Create "previous" button and add to button group
    REButton * previous =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"style"           : @(REStyleApplyGloss | REStyleDrawBorder),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportPreviousButtonKey,
                   @"displayName"     : @"Previous",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4005) })));

    // Create "play" button and add to button group
    REButton * play =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"style"           : @(REStyleApplyGloss | REStyleDrawBorder),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportPlayButtonKey,
                   @"displayName"     : @"Play",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4002) })));

    // Create "next" button and add to button group
    REButton * next =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"style"           : @(REStyleApplyGloss | REStyleDrawBorder),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportNextButtonKey,
                   @"displayName"     : @"Next",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4006) })));

    // Create "record" button and add to button group
    REButton * record =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"style"           : @(REStyleApplyGloss | REStyleDrawBorder),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportRecordButtonKey,
                   @"displayName"     : @"Record",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4003) })));

    // Create "stop" button and add to button group
    REButton * stop =
        MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                   @"style"           : @(REStyleApplyGloss | REStyleDrawBorder),
                   @"shape"           : @(REShapeRoundedRectangle),
                   @"key"             : RETransportStopButtonKey,
                   @"displayName"     : @"Stop",
                   @"icons"           : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                             @"highlighted" : kHighlightColor }),
                                                         (@{ @"normal"      : MakeIconImage(4007) })));

    NSMutableDictionary * attrHigh = [@{} mutableCopy];
    NSMutableDictionary * attr     = [REButtonBuilder buttonTitleAttributesWithFontName:kDefaultFontName
                                                                               fontSize:64.0
                                                                            highlighted:attrHigh];

    attr[NSForegroundColorAttributeName] = [UIColor colorWithWhite:0.0 alpha:0.5];
    attr[NSStrokeWidthAttributeName]     = @"normal";

    NSAttributedString * label = [NSAttributedString attributedStringWithString:kDownArrow
                                                                     attributes:attr];

    attrHigh[NSStrokeWidthAttributeName] = @"normal";

    NSAttributedString * labelHigh = [NSAttributedString attributedStringWithString:kDownArrow
                                                                         attributes:attrHigh];

    REButton * tuck =
        MakeButton(@"key"         : REButtonGroupTuckButtonKey,
                   @"displayName" : @"Tuck Panel",
                   @"titles"      : MakeTitleSet(@{ @"normal" : label, @"highlighted" : labelHigh }));

    [buttonGroup addSubelements:[@[play, pause, rewind, fastForward, stop,
                                   previous, tuck, next, record] orderedSet]];

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
    NSManagedObjectContext * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup          * buttonGroup = nil;
    BOComponentDevice      * comcastDVR  = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                          context:context];
    BOComponentDevice * samsungTV = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                   context:context];
    buttonGroup = [self rawTransport];

    // Create default transport command set
    RECommandSet * dvrTransport = [RECommandSet commandSetInContext:context type:RECommandSetTypeTransport];
    dvrTransport[RETransportPreviousButtonKey]    = MakeIRCommand(comcastDVR, @"Prev");
    dvrTransport[RETransportStopButtonKey]        = MakeIRCommand(comcastDVR, @"Stop");
    dvrTransport[RETransportPlayButtonKey]        = MakeIRCommand(comcastDVR, @"Play");
    dvrTransport[RETransportPauseButtonKey]       = MakeIRCommand(comcastDVR, @"Pause");
    dvrTransport[RETransportNextButtonKey]        = MakeIRCommand(comcastDVR, @"Next");
    dvrTransport[RETransportFastForwardButtonKey] = MakeIRCommand(comcastDVR, @"Fast Forward");
    dvrTransport[RETransportRewindButtonKey]      = MakeIRCommand(comcastDVR, @"Rewind");
    dvrTransport[RETransportRecordButtonKey]      = MakeIRCommand(comcastDVR, @"Record");

    [buttonGroup.configurationDelegate setCommandSet:dvrTransport
                                    forConfiguration:REDefaultConfiguration];

    // Create TV transport command set
    RECommandSet * tvTransport = [RECommandSet commandSetInContext:context
                                                              type:RECommandSetTypeTransport];
    tvTransport[RETransportPlayButtonKey]        = MakeIRCommand(samsungTV, @"Play");
    tvTransport[RETransportPauseButtonKey]       = MakeIRCommand(samsungTV, @"Pause");
    tvTransport[RETransportFastForwardButtonKey] = MakeIRCommand(samsungTV, @"Fast Forward");
    tvTransport[RETransportRewindButtonKey]      = MakeIRCommand(samsungTV, @"Rewind");
    tvTransport[RETransportRecordButtonKey]      = MakeIRCommand(samsungTV, @"Record");

    [buttonGroup.configurationDelegate setCommandSet:tvTransport
                                    forConfiguration:kTVConfiguration];

    buttonGroup.displayName   = @"DVR Transport";
    buttonGroup.key           = RERemoteBottomPanel1Key;
    buttonGroup.panelLocation = REPanelLocationBottom;

    return buttonGroup;
}


+ (REButtonGroup *)constructPS3Transport
{
    NSManagedObjectContext * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup          * buttonGroup = nil;
    BOComponentDevice      * ps3         = [BOComponentDevice fetchDeviceWithName:@"PS3"
                                                                          context:context];

    // Create default transport command set
    RECommandSet * ps3Transport = [RECommandSet commandSetInContext:context
                                                               type:RECommandSetTypeTransport];
    ps3Transport[RETransportPreviousButtonKey]    = MakeIRCommand(ps3, @"Previous");
    ps3Transport[RETransportStopButtonKey]        = MakeIRCommand(ps3, @"Stop");
    ps3Transport[RETransportPlayButtonKey]        = MakeIRCommand(ps3, @"Play");
    ps3Transport[RETransportPauseButtonKey]       = MakeIRCommand(ps3, @"Pause");
    ps3Transport[RETransportNextButtonKey]        = MakeIRCommand(ps3, @"Next");
    ps3Transport[RETransportFastForwardButtonKey] = MakeIRCommand(ps3, @"Scan Forward");
    ps3Transport[RETransportRewindButtonKey]      = MakeIRCommand(ps3, @"Scan Reverse");

    buttonGroup               = [self rawTransport];
    buttonGroup.displayName   = @"Playstation Transport";
    buttonGroup.key           = RERemoteBottomPanel1Key;
    buttonGroup.panelLocation = REPanelLocationBottom;
    buttonGroup.commandSet    = ps3Transport;

    return buttonGroup;
}


+ (REPickerLabelButtonGroup *)rawRocker
{
    NSManagedObjectContext   * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REPickerLabelButtonGroup * buttonGroup = nil;
    buttonGroup =
        MakePickerLabelButtonGroup(@"backgroundColor" : defaultBGColor(),
                                   @"shape"           : @(REShapeRoundedRectangle),
                                   @"key"             : @"rocker",
                                   @"displayName"     : @"rocker",
                                   @"style"           : @(REStyleApplyGloss | REStyleDrawBorder));

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
    NSManagedObjectContext   * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REPickerLabelButtonGroup * buttonGroup = nil;
    BOComponentDevice        * comcastDVR  = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                            context:context];
    RECommandSet * channelsCommandSet = [RECommandSet commandSetInContext:context
                                                                     type:RECommandSetTypeRocker];
    channelsCommandSet.name                          = @"DVR Channels";
    channelsCommandSet[RERockerButtonPlusButtonKey]  = MakeIRCommand(comcastDVR, @"Channel Up");
    channelsCommandSet[RERockerButtonMinusButtonKey] = MakeIRCommand(comcastDVR, @"Channel Down");

    RECommandSet * pageUpDownCommandSet = [RECommandSet commandSetInContext:context
                                                                       type:RECommandSetTypeRocker];
    pageUpDownCommandSet.name                          = @"DVR Paging";
    pageUpDownCommandSet[RERockerButtonPlusButtonKey]  = MakeIRCommand(comcastDVR, @"Page Up");
    pageUpDownCommandSet[RERockerButtonMinusButtonKey] = MakeIRCommand(comcastDVR, @"Page Down");

    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:context];
    RECommandSet * volumeCommandSet = [RECommandSet commandSetInContext:context
                                                                   type:RECommandSetTypeRocker];
    volumeCommandSet.name                          = @"Receiver Volume";
    volumeCommandSet[RERockerButtonPlusButtonKey]  = MakeIRCommand(avReceiver, @"Volume Up");
    volumeCommandSet[RERockerButtonMinusButtonKey] = MakeIRCommand(avReceiver, @"Volume Down");

    buttonGroup             = [self rawRocker];
    buttonGroup.displayName = @"DVR Rocker";

    [buttonGroup
          addCommandSet:channelsCommandSet
              withLabel:[NSAttributedString
                     attributedStringWithString:@"CH"
                                     attributes:[REButtonBuilder
                                 buttonTitleAttributesWithFontName:nil
                                                          fontSize:0
                                                       highlighted:NO]]];

    [buttonGroup
          addCommandSet:pageUpDownCommandSet
              withLabel:[NSAttributedString
                     attributedStringWithString:@"PAGE"
                                     attributes:[REButtonBuilder
                                 buttonTitleAttributesWithFontName:nil
                                                          fontSize:0
                                                       highlighted:NO]]];

    [buttonGroup
          addCommandSet:volumeCommandSet
              withLabel:[NSAttributedString
                     attributedStringWithString:@"VOL"
                                     attributes:[REButtonBuilder
                                 buttonTitleAttributesWithFontName:nil
                                                          fontSize:0
                                                       highlighted:NO]]];

    return buttonGroup;
}


+ (REPickerLabelButtonGroup *)constructPS3Rocker
{
    NSManagedObjectContext   * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REPickerLabelButtonGroup * buttonGroup = nil;
    BOComponentDevice        * avReceiver  = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                            context:context];
    RECommandSet * volumeCommandSet = [RECommandSet commandSetInContext:context
                                                                   type:RECommandSetTypeRocker];
    volumeCommandSet.name                          = @"Receiver Volume";
    volumeCommandSet[RERockerButtonPlusButtonKey]  = MakeIRCommand(avReceiver, @"Volume Up");
    volumeCommandSet[RERockerButtonMinusButtonKey] = MakeIRCommand(avReceiver, @"Volume Down");

    buttonGroup             = [self rawRocker];
    buttonGroup.displayName = @"Playstation Rocker";

    [buttonGroup
     addCommandSet:volumeCommandSet
         withLabel:[NSAttributedString
                attributedStringWithString:@"VOL"
                                attributes:[REButtonBuilder
                            buttonTitleAttributesWithFontName:nil
                                                     fontSize:0
                                                  highlighted:NO]]];

    return buttonGroup;
}


+ (REPickerLabelButtonGroup *)constructSonosRocker
{
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
    REPickerLabelButtonGroup * buttonGroup = nil;
    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:context];
    RECommandSet * volumeCommandSet = [RECommandSet commandSetInContext:context
                                                                   type:RECommandSetTypeRocker];
    volumeCommandSet.name = @"Receiver Volume";
    volumeCommandSet[RERockerButtonPlusButtonKey] = MakeIRCommand(avReceiver, @"Volume Up");
    volumeCommandSet[RERockerButtonMinusButtonKey] = MakeIRCommand(avReceiver, @"Volume Down");

    buttonGroup = [self rawRocker];
    buttonGroup.displayName = @"Sonos Rocker";

    [buttonGroup
     addCommandSet:volumeCommandSet
     withLabel:[NSAttributedString attributedStringWithString:@"VOL"
                                                   attributes:[REButtonBuilder
                                                               buttonTitleAttributesWithFontName:nil
                                                               fontSize:0
                                                               highlighted:NO]]];

    return buttonGroup;
}

+ (REButtonGroup *)constructSonosMuteButtonGroup
{
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup * buttonGroup = nil;
    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:context];
    buttonGroup = MakeButtonGroup(@"displayName" : @"Mute Button",
                                  @"key"         : @"mute");

    NSMutableDictionary * attrHigh = [@{} mutableCopy];
    NSDictionary       * attr = [REButtonBuilder buttonTitleAttributesWithFontName:kDefaultFontName
                                                                          fontSize:16.0
                                                                       highlighted:attrHigh];
    NSAttributedString * label    = [NSAttributedString attributedStringWithString:@"Mute"
                                                                        attributes:attr];
    NSAttributedString * labelHigh = [NSAttributedString attributedStringWithString:@"Mute"
                                                                         attributes:attrHigh];
    REButton * mute =
    MakeButton(@"command"     : MakeIRCommand(avReceiver, @"Mute"),
               @"shape"       : @(REShapeRoundedRectangle),
               @"style"       : @(REStyleApplyGloss | REStyleDrawBorder),
               @"displayName" : @"Mute",
               @"titles"      : MakeTitleSet(@{ @"normal" : label, @"highlighted" : labelHigh }),
               @"key"         : @"muteButton");

    [buttonGroup addSubelementsObject:mute];

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
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup * buttonGroup = nil;
    /* Create selection panel button group */
    buttonGroup =
    MakeSelectionPanelButtonGroup(@"displayName" : @"Configuration Selection Panel",
                                  @"subtype" : @(REButtonGroupRightPanel),
                                  @"backgroundColor" : FlipsideColor,
                                  @"key" : RERemoteRightPanel1Key);

    NSMutableDictionary * attrSelected = [@{} mutableCopy];

    NSDictionary * attr = [REButtonBuilder buttonTitleAttributesWithFontName:kDefaultFontName
                                                                    fontSize:48
                                                                 highlighted:attrSelected];
    NSAttributedString * label = [NSAttributedString attributedStringWithString:@"STB"
                                                                     attributes:attr];
    NSAttributedString * labelSelected = [NSAttributedString attributedStringWithString:@"STB"
                                                                             attributes:attrSelected];
    REButton * stbButton =
    MakeButton(@"displayName" : @"Select Set Top Box",
               @"titles"      : MakeTitleSet(@{ @"normal"      : label,
                                             @"selected"    : labelSelected,
                                             @"highlighted" : labelSelected }),
               @"key"         : REDefaultConfiguration);

    label = [NSAttributedString attributedStringWithString:@"TV" attributes:attr];
    labelSelected = [NSAttributedString attributedStringWithString:@"TV" attributes:attrSelected];

    REButton * tvButton =
    MakeButton(@"displayName" : @"Select Samsung TV",
               @"titles"      : MakeTitleSet(@{ @"normal"      : label,
                                             @"selected"    : labelSelected,
                                             @"highlighted" : labelSelected }),
               @"key"         : kTVConfiguration);

    [buttonGroup addSubelements:[@[stbButton, tvButton] orderedSet]];

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
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup * buttonGroup = nil;
    // Create button group with three vertically aligned buttons
    buttonGroup = MakeButtonGroup(@"key" : @"oneByThree", @"displayName" : @"1x3");

    // Create first button
    REButton * button1 =
    MakeButton(@"style"       : @(REStyleApplyGloss | REStyleDrawBorder),
               @"shape"       : @(REShapeRoundedRectangle),
               @"key"         : @"button1",
               @"displayName" : @"button1");

    // Create second button
    REButton * button2 =
    MakeButton(@"style"       : @(REStyleApplyGloss | REStyleDrawBorder),
               @"shape"       : @(REShapeRoundedRectangle),
               @"key"         : @"button2",
               @"displayName" : @"button2");

    // Create third button
    REButton * button3 =
    MakeButton(@"style"       : @(REStyleApplyGloss | REStyleDrawBorder),
               @"shape"       : @(REShapeRoundedRectangle),
               @"key"         : @"button3",
               @"displayName" : @"button3");

    [buttonGroup addSubelements:[@[button1, button2, button3] orderedSet]];

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
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup * buttonGroup = nil;
    BOComponentDevice * comcastDVR = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                    context:context];
    BOComponentDevice * samsungTV = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                   context:context];
    buttonGroup = [self rawGroupOfThreeButtons];

    buttonGroup.displayName = @"One x Three Button Group";

    // Configure "Guide" button and its delegate
    REButton * guideButton = buttonGroup[@"button1"];

    guideButton.key         = @"guide/tools";
    guideButton.displayName = @"Guide / Tools";

    NSMutableDictionary * attrHigh = [@{} mutableCopy];
    NSDictionary * attr = [REButtonBuilder buttonTitleAttributesWithFontName:kDefaultFontName
                                                                    fontSize:18.0
                                                                 highlighted:attrHigh];

    REControlStateTitleSet * titles = [REControlStateTitleSet controlStateSetInContext:context];

    titles[UIControlStateNormal]      = [NSAttributedString attributedStringWithString:@"Guide"
                                                                            attributes:attr];
    titles[UIControlStateHighlighted] = [NSAttributedString attributedStringWithString:@"Guide"
                                                                            attributes:attrHigh];

    [guideButton.configurationDelegate setTitleSet:titles forConfiguration:REDefaultConfiguration];

    [guideButton.configurationDelegate setCommand:MakeIRCommand(comcastDVR, @"Guide")
                                 forConfiguration:REDefaultConfiguration];

    titles                       = [REControlStateTitleSet controlStateSetInContext:context];
    titles[UIControlStateNormal] = [NSAttributedString attributedStringWithString:@"Tools"
                                                                       attributes:attr];
    titles[UIControlStateHighlighted] = [NSAttributedString attributedStringWithString:@"Tools"
                                                                            attributes:attrHigh];
    [guideButton.configurationDelegate setTitleSet:titles forConfiguration:kTVConfiguration];

    [guideButton.configurationDelegate setCommand:MakeIRCommand(samsungTV, @"Tools")
                                 forConfiguration:kTVConfiguration];

    // Configure "DVR" button and add its delegate
    REButton * dvrButton = buttonGroup[@"button2"];

    dvrButton.key         = @"dvr/internet@tv";
    dvrButton.displayName = @"DVR / Internet@TV";

    titles                       = [REControlStateTitleSet controlStateSetInContext:context];
    titles[UIControlStateNormal] = [NSAttributedString attributedStringWithString:@"DVR"
                                                                       attributes:attr];
    titles[UIControlStateHighlighted] = [NSAttributedString attributedStringWithString:@"DVR"
                                                                            attributes:attrHigh];
    [dvrButton.configurationDelegate setTitleSet:titles forConfiguration:REDefaultConfiguration];

    [dvrButton.configurationDelegate setCommand:MakeIRCommand(comcastDVR, @"DVR")
                               forConfiguration:REDefaultConfiguration];

    titles                       = [REControlStateTitleSet controlStateSetInContext:context];
    titles[UIControlStateNormal] = [NSAttributedString attributedStringWithString:@"Internet@TV"
                                                                       attributes:attr];
    titles[UIControlStateHighlighted] = [NSAttributedString attributedStringWithString:@"Internet@TV"
                                                                            attributes:attrHigh];
    [dvrButton.configurationDelegate setTitleSet:titles forConfiguration:kTVConfiguration];

    [dvrButton.configurationDelegate setCommand:MakeIRCommand(samsungTV, @"Internet@TV")
                               forConfiguration:kTVConfiguration];

    // Configure "Info" button and its delegate
    REButton * infoButton = buttonGroup[@"button3"];

    infoButton.key         = @"info";
    infoButton.displayName = @"Info";

    titles                       = [REControlStateTitleSet controlStateSetInContext:context];
    titles[UIControlStateNormal] = [NSAttributedString attributedStringWithString:@"Info"
                                                                       attributes:attr];
    titles[UIControlStateHighlighted] = [NSAttributedString attributedStringWithString:@"Info"
                                                                            attributes:attrHigh];
    [infoButton.configurationDelegate setTitleSet:titles forConfiguration:REDefaultConfiguration];

    [infoButton.configurationDelegate setCommand:MakeIRCommand(comcastDVR, @"Info")
                                forConfiguration:REDefaultConfiguration];

    [infoButton.configurationDelegate setTitleSet:titles forConfiguration:kTVConfiguration];

    [infoButton.configurationDelegate setCommand:MakeIRCommand(samsungTV, @"Info")
                                forConfiguration:kTVConfiguration];

    return buttonGroup;
}

+ (REButtonGroup *)constructPS3GroupOfThreeButtons
{
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup * buttonGroup = nil;
    BOComponentDevice * ps3 = [BOComponentDevice fetchDeviceWithName:@"PS3"
                                                             context:context];
    buttonGroup   = [self rawGroupOfThreeButtons];
    REButton      * displayButton = buttonGroup[@"button1"];

    displayButton.key         = @"display";
    displayButton.displayName = @"Display";

    NSMutableDictionary * attrHigh = [@{}  mutableCopy];
    NSDictionary * attr = [REButtonBuilder
                           buttonTitleAttributesWithFontName:kDefaultFontName
                           fontSize:18.0
                           highlighted:attrHigh];

    displayButton.titles[UIControlStateNormal] = [NSAttributedString
                                                  attributedStringWithString:@"Display"
                                                  attributes:attr];

    RESendIRCommand * sendIR = [RESendIRCommand commandWithIRCode:ps3[@"Display"]];

    displayButton.command = sendIR;

    REButton * topMenuButton = buttonGroup[@"button2"];

    topMenuButton.key                          = @"topMenu";
    topMenuButton.displayName                  = @"Top Menu";
    topMenuButton.titles[UIControlStateNormal] = [NSAttributedString
                                                  attributedStringWithString:@"Top Menu"
                                                  attributes:attr];
    sendIR                = [RESendIRCommand commandWithIRCode:ps3[@"Top Menu"]];
    topMenuButton.command = sendIR;

    REButton * popupMenuButton = buttonGroup[@"button3"];

    popupMenuButton.key                          = @"popupMenu";
    popupMenuButton.displayName                  = @"Popup Menu";
    popupMenuButton.titles[UIControlStateNormal] = [NSAttributedString
                                                    attributedStringWithString:@"Popup Menu"
                                                    attributes:attr];
    sendIR                  = [RESendIRCommand commandWithIRCode:ps3[@"Popup Menu"]];
    popupMenuButton.command = sendIR;

    return buttonGroup;
}

+ (REButtonGroup *)rawButtonPanel
{
    NSManagedObjectContext * context     = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup          * buttonGroup = nil;
    buttonGroup =
    MakeButtonGroup(@"key"             : @"buttons",
                    @"displayName"     : @"buttons",
                    @"backgroundColor" :[kPanelBackgroundColor colorWithAlphaComponent:0.75]);
    REButton * button1 =
    MakeButton(@"style"       : @(REStyleApplyGloss | REStyleDrawBorder),
               @"shape"       : @(REShapeRoundedRectangle),
               @"key"         : @"button1",
               @"displayName" : @"button1");
    REButton * button2 =
    MakeButton(@"style"       : @(REStyleApplyGloss | REStyleDrawBorder),
               @"shape"       : @(REShapeRoundedRectangle),
               @"key"         : @"button2",
               @"displayName" : @"button2");
    REButton * button3 =
    MakeButton(@"style"       : @(REStyleApplyGloss | REStyleDrawBorder),
               @"shape"       : @(REShapeRoundedRectangle),
               @"key"         : @"button3",
               @"displayName" : @"button3");
    REButton * button4 =
    MakeButton(@"style"       : @(REStyleApplyGloss | REStyleDrawBorder),
               @"shape"       : @(REShapeRoundedRectangle),
               @"key"         : @"button4",
               @"displayName" : @"button4");
    REButton * button5 =
    MakeButton(@"style"       : @(REStyleApplyGloss | REStyleDrawBorder),
               @"shape"       : @(REShapeRoundedRectangle),
               @"key"         : @"button5",
               @"displayName" : @"button5");
    REButton * button6 =
    MakeButton(@"style"       : @(REStyleApplyGloss | REStyleDrawBorder),
               @"shape"       : @(REShapeRoundedRectangle),
               @"key"         : @"button6",
               @"displayName" : @"button6");
    REButton * button7 =
    MakeButton(@"style"       : @(REStyleApplyGloss | REStyleDrawBorder),
               @"shape"       : @(REShapeRoundedRectangle),
               @"key"         : @"button7",
               @"displayName" : @"button7");
    REButton * button8 =
    MakeButton(@"key"         : @"button8",
               @"displayName" : @"button8");

    [buttonGroup addSubelements:[@[button1, button2, button3, button4,
                                 button5, button6, button7, button8] orderedSet]];

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
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup * buttonGroup = nil;
     buttonGroup =
         MakeButtonGroup(@"displayName" : @"Home and Power Buttons",
                         @"key"         : @"homeAndPowerButtonGroup");
     REButton * homeButton =
         MakeButton(@"shape" : @(REShapeOval),
                    @"style" : @(REStyleApplyGloss | REStyleDrawBorder),
                    @"displayName" : @"Home Button",
                    @"key"         : @"homeButton",
                    @"icons"       : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                          @"highlighted" : kHighlightColor }),
                                                      (@{ @"normal"      : MakeIconImage(140) })),
                    @"command" : MakeSwitchCommand(MSRemoteControllerHomeRemoteKeyName));
     REActivityButton * powerButton =
         MakeActivityOffButton(@"shape"       : @(REShapeOval),
                               @"style"       : @(REStyleApplyGloss | REStyleDrawBorder),
                               @"displayName" : @"Power Off and Exit Activity",
                               @"key"         : $(@"activity%i", activity),
                               @"icons"       : MakeIconImageSet((@{ @"normal"      : WhiteColor,
                                                                     @"highlighted" : kHighlightColor }),
                                                                 (@{ @"normal"      : MakeIconImage(168) })),
                               @"command"     :[REMacroBuilder activityMacroForActivity:activity
                                                                        toInitiateState:NO
                                                                            switchIndex:NULL]);

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
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
    REButtonGroup * buttonGroup = nil;
    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:context];
    BOComponentDevice * samsungTV = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                   context:context];
    BOComponentDevice * comcastDVR = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                    context:context];

    buttonGroup = [self rawButtonPanel];

    buttonGroup.panelLocation = REPanelLocationLeft;
    buttonGroup.key           = RERemoteLeftPanel1Key;
    buttonGroup.displayName   = @"Left Overlay Panel";

    NSMutableDictionary * attrHigh = [@{} mutableCopy];
    NSMutableDictionary * attr     = [REButtonBuilder
                                   buttonTitleAttributesWithFontName:kDefaultFontName
                                                            fontSize:15.0
                                                         highlighted:attrHigh];

    REButton * button = buttonGroup[@"button1"];

    button.displayName = @"On Demand / Source";

    REControlStateTitleSet * titles = [REControlStateTitleSet controlStateSetInContext:context];

    titles[UIControlStateNormal] = [NSAttributedString attributedStringWithString:@"On Demand"
                                                                       attributes:attr];
    titles[UIControlStateHighlighted] = [NSAttributedString attributedStringWithString:@"On Demand"
                                                                            attributes:attrHigh];

    [button.configurationDelegate setTitleSet:titles forConfiguration:REDefaultConfiguration];

    [button.configurationDelegate setCommand:MakeIRCommand(comcastDVR, @"On Demand")
                         forConfiguration:REDefaultConfiguration];

    titles                       = [REControlStateTitleSet controlStateSetInContext:context];
    titles[UIControlStateNormal] = [NSAttributedString attributedStringWithString:@"Source"
                                                                       attributes:attr];
    titles[UIControlStateHighlighted] = [NSAttributedString attributedStringWithString:@"Source"
                                                                         attributes:attrHigh];
    [button.configurationDelegate setTitleSet:titles forConfiguration:kTVConfiguration];

    [button.configurationDelegate setCommand:MakeIRCommand(samsungTV, @"Source")
                         forConfiguration:kTVConfiguration];

    button             = buttonGroup[@"button2"];
    button.displayName = @"Menu";

    titles                       = [REControlStateTitleSet controlStateSetInContext:context];
    titles[UIControlStateNormal] = [NSAttributedString attributedStringWithString:@"Menu"
                                                                       attributes:attr];
    titles[UIControlStateHighlighted] = [NSAttributedString attributedStringWithString:@"Menu"
                                                                            attributes:attrHigh];
    [button.configurationDelegate setTitleSet:titles forConfiguration:REDefaultConfiguration];

    [button.configurationDelegate setCommand:MakeIRCommand(comcastDVR, @"Menu")
                         forConfiguration:REDefaultConfiguration];

    [button.configurationDelegate setTitleSet:titles forConfiguration:kTVConfiguration];
    [button.configurationDelegate setCommand:MakeIRCommand(samsungTV, @"Menu")
                         forConfiguration:kTVConfiguration];

    button             = buttonGroup[@"button3"];
    button.displayName = @"Last / Return";

    titles                       = [REControlStateTitleSet controlStateSetInContext:context];
    titles[UIControlStateNormal] = [NSAttributedString attributedStringWithString:@"Last"
                                                                       attributes:attr];
    titles[UIControlStateHighlighted] = [NSAttributedString attributedStringWithString:@"Last"
                                                                            attributes:attrHigh];
    [button.configurationDelegate setTitleSet:titles forConfiguration:REDefaultConfiguration];

    [button.configurationDelegate setCommand:MakeIRCommand(comcastDVR, @"Last")
                         forConfiguration:REDefaultConfiguration];

    titles                       = [REControlStateTitleSet controlStateSetInContext:context];
    titles[UIControlStateNormal] = [NSAttributedString attributedStringWithString:@"Return"
                                                                       attributes:attr];
    titles[UIControlStateHighlighted] = [NSAttributedString attributedStringWithString:@"Return"
                                                                            attributes:attrHigh];
    [button.configurationDelegate setTitleSet:titles forConfiguration:kTVConfiguration];

    [button.configurationDelegate setCommand:MakeIRCommand(samsungTV, @"Return")
                         forConfiguration:kTVConfiguration];

    button             = buttonGroup[@"button4"];
    button.displayName = @"Exit";

    titles                       = [REControlStateTitleSet controlStateSetInContext:context];
    titles[UIControlStateNormal] = [NSAttributedString attributedStringWithString:@"Exit"
                                                                       attributes:attr];
    titles[UIControlStateHighlighted] = [NSAttributedString attributedStringWithString:@"Exit"
                                                                            attributes:attrHigh];
    [button.configurationDelegate setTitleSet:titles forConfiguration:REDefaultConfiguration];

    [button.configurationDelegate setCommand:MakeIRCommand(comcastDVR, @"Exit")
                         forConfiguration:REDefaultConfiguration];

    [button.configurationDelegate setTitleSet:titles forConfiguration:kTVConfiguration];

    [button.configurationDelegate setCommand:MakeIRCommand(samsungTV, @"Exit")
                         forConfiguration:kTVConfiguration];

    button                       = buttonGroup[@"button5"];
    button.displayName           = @"DVR Audio Input";
    button.titles[UIControlStateNormal] = [NSAttributedString attributedStringWithString:@"DVR Audio"
                                                                              attributes:attr];
    button.titles[UIControlStateHighlighted] = [NSAttributedString
                                             attributedStringWithString:@"DVR Audio"
                                                             attributes:attrHigh];
    button.command = MakeIRCommand(avReceiver, @"TV/SAT");

    button                       = buttonGroup[@"button6"];
    button.displayName           = @"TV Audio Input";
    button.titles[UIControlStateNormal] = [NSAttributedString
                                        attributedStringWithString:@"TV Audio"
                                                        attributes:attr];
    button.titles[UIControlStateHighlighted] = [NSAttributedString
                                             attributedStringWithString:@"TV Audio"
                                                             attributes:attrHigh];
    button.command = MakeIRCommand(avReceiver, @"Video 3");

    button                       = buttonGroup[@"button7"];
    button.displayName           = @"Mute";
    button.titles[UIControlStateNormal] = [NSAttributedString attributedStringWithString:@"Mute"
                                                                           attributes:attr];
    button.titles[UIControlStateHighlighted] = [NSAttributedString attributedStringWithString:@"Mute"
                                                                                attributes:attrHigh];
    button.command = MakeIRCommand(avReceiver, @"Mute");

    button             = buttonGroup[@"button8"];
    button.displayName = @"Tuck Panel";
    attr               = [REButtonBuilder buttonTitleAttributesWithFontName:kArrowFontName
                                                               fontSize:32.0
                                                            highlighted:attrHigh];
    attr[NSForegroundColorAttributeName] = [UIColor colorWithWhite:0.0 alpha:0.5];
    attr[NSStrokeWidthAttributeName]     = @"normal";
    attrHigh[NSStrokeWidthAttributeName] = @"normal";

    button.titles[UIControlStateNormal] = [NSAttributedString attributedStringWithString:kLeftArrow
                                                                           attributes:attr];
    button.titles[UIControlStateHighlighted] = [NSAttributedString
                                             attributedStringWithString:kLeftArrow
                                                             attributes:attrHigh];
    button.key   = REButtonGroupTuckButtonKey;
    button.style = 0;

    return buttonGroup;
}

@end
