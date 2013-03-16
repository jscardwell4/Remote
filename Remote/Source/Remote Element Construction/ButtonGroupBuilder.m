//
// ButtonGroupBuilder.m
// iPhonto
//
// Created by Jason Cardwell on 10/6/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteConstruction.h"
#import "MSRemoteConstants.h"

static const int   ddLogLevel = LOG_LEVEL_DEBUG;

@interface ButtonGroupBuilder ()
@property (nonatomic, strong) ButtonBuilder * buttonBuilder;
@property (nonatomic, strong) MacroBuilder  * macroBuilder;
@end

@implementation ButtonGroupBuilder

+ (ButtonGroupBuilder *)buttonGroupBuilderWithContext:(NSManagedObjectContext *)context {
    ButtonGroupBuilder * bgb = [self new];

    bgb.buildContext = context;

    return bgb;
}

- (ButtonGroup *)constructRemoteViewControllerTopBarButtonGroup {
    ButtonGroup * toolbar = MakeToolbarButtonGroup(@"type" : @(ButtonGroupTypeToolbar),
                                                   @"displayName" : @"Top Toolbar",
                                                   @"key" : MSRemoteControllerTopToolbarKeyName,
                                                   @"backgroundColor" : FlipsideColor);
    Button * home = MakeButton(@"displayName" : @"Home Button",
                               @"command" : MakeSystemCommand(SystemCommandReturnToLaunchScreen),
                               @"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor}
                                                                        ), @{@0 : MakeIconImage(140)}
                                                           ));
    Button * settings = MakeButton(@"displayName" : @"Settings Button",
                                   @"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor}
                                                                            ), @{@0 : MakeIconImage(83)}
                                                               ),
                                   @"command" : MakeSystemCommand(SystemCommandOpenSettings));
    Button * editRemote = MakeButton(@"displayName" : @"Edit Remote Button",
                                     @"command" : MakeSystemCommand(SystemCommandOpenEditor),
                                     @"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor}
                                                                              ), @{@0 : MakeIconImage(224)}
                                                                 ));
    Button * battery    = MakeBatteryStatusButton;
    Button * connection = MakeConnectionStatusButton;

    [toolbar addSubelements:[@[home, settings, editRemote, battery, connection] orderedSet]];

    NSString * constraints =
        @"home.left = toolbar.left + 4\n"
        "settings.left = home.right + 20\n"
        "editRemote.left = settings.right + 20\n"
        "battery.left = editRemote.right + 20\n"
        "connection.left = battery.right + 20\n"
        "settings.width = home.width\n"
        "editRemote.width = home.width\n"
        "battery.width = home.width\n"
        "connection.width = home.width\n"
        "home.height = toolbar.height\n"
        "settings.height = toolbar.height\n"
        "editRemote.height = toolbar.height\n"
        "battery.height = toolbar.height\n"
        "connection.height = toolbar.height\n"
        "home.centerY = toolbar.centerY\n"
        "settings.centerY = toolbar.centerY\n"
        "editRemote.centerY = toolbar.centerY\n"
        "battery.centerY = toolbar.centerY\n"
        "connection.centerY = toolbar.centerY";
    NSDictionary * identifiers = NSDictionaryOfVariableBindingsToIdentifiers(toolbar, home, settings, editRemote, battery, connection);

    [toolbar.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    constraints = @"home.width ≥ 44";
    [home.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    return toolbar;
}  /* constructRemoteViewControllerTopBarButtonGroup */

#pragma mark - Activities construction
- (ButtonGroup *)constructActivities {
    ButtonGroup * activityButtons = MakeButtonGroup(@"displayName" : @"Activity Buttons",
                                                    @"key" : @"activityButtons");
    ActivityButton * dvrActivityButton     = [self.buttonBuilder launchActivityButtonWithTitle:@"Comcast\nDVR" activity:1];
    ActivityButton * ps3ActivityButton     = [self.buttonBuilder launchActivityButtonWithTitle:@"Playstation" activity:2];
    ActivityButton * appleTVActivityButton = [self.buttonBuilder launchActivityButtonWithTitle:@" TV" activity:3];
    ActivityButton * sonosActivityButton   = [self.buttonBuilder launchActivityButtonWithTitle:@"Sonos" activity:4];
    NSString       * constraints           =
        @"activityButtons.width = 300\n"
        "activityButtons.height = activityButtons.width\n"
        "dvrActivityButton.width = activityButtons.width * 0.5\n"
        "dvrActivityButton.centerX = activityButtons.centerX * 0.5\n"
        "dvrActivityButton.centerY = activityButtons.centerY * 0.5\n"
        "ps3ActivityButton.width = dvrActivityButton.width\n"
        "ps3ActivityButton.centerX = activityButtons.centerX * 1.5\n"
        "ps3ActivityButton.centerY = activityButtons.centerY * 0.5\n"
        "appleTVActivityButton.width = dvrActivityButton.width\n"
        "appleTVActivityButton.centerX = activityButtons.centerX * 0.5\n"
        "appleTVActivityButton.centerY = activityButtons.centerY * 1.5\n"
        "sonosActivityButton.width = dvrActivityButton.width\n"
        "sonosActivityButton.centerX = activityButtons.centerX * 1.5\n"
        "sonosActivityButton.centerY = activityButtons.centerY * 1.5";
    NSDictionary * identifiers = NSDictionaryOfVariableBindingsToIdentifiers(activityButtons, dvrActivityButton, ps3ActivityButton, appleTVActivityButton, sonosActivityButton);

    [activityButtons addSubelements:[@[dvrActivityButton, ps3ActivityButton, appleTVActivityButton, sonosActivityButton] orderedSet]];
    [activityButtons.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    constraints = @"dvrActivityButton.height = dvrActivityButton.width";
    [dvrActivityButton.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];
    constraints = @"ps3ActivityButton.height = ps3ActivityButton.width";
    [ps3ActivityButton.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];
    constraints = @"appleTVActivityButton.height = appleTVActivityButton.width";
    [appleTVActivityButton.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];
    constraints = @"sonosActivityButton.height = sonosActivityButton.width";
    [sonosActivityButton.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    return activityButtons;
}

- (ButtonGroup *)constructLightControls {
    ButtonGroup * lightControls = MakeButtonGroup(@"displayName" : @"Light Controls",
                                                  @"key" : @"lightControls",
                                                  @"backgroundColor" : FlipsideColor);
    Button * lightsOnButton = MakeButton(@"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor, @1 : kHighlightColor}
                                                                                  ), @{@0 : MakeIconImage(1)}
                                                                     ),
                                         @"command" : MakeHTTPCommand(@"http://10.0.1.27/0?1201=I=0"),
                                         @"key" : @"lightsOn",
                                         @"displayName" : @"Lights On");
    Button * lightsOffButton = MakeButton(@"icons" : MakeIconImageSet(MakeColorSet(@{@0 : GrayColor, @1 : kHighlightColor}
                                                                                   ), @{@0 : MakeIconImage(1)}
                                                                      ),
                                          @"command" : MakeHTTPCommand(@"http://10.0.1.27/0?1401=I=0"),
                                          @"key" : @"lightsOff",
                                          @"displayName" : @"Lights Off");

    [lightControls addSubelements:[@[lightsOnButton, lightsOffButton] orderedSet]];

    NSString * constraints = @"lightControls.height = 44\n"
                             "lightsOnButton.left = lightControls.left + 20\n"
                             "lightsOffButton.left = lightsOnButton.right + 40\n"
                             "lightsOffButton.width = lightsOnButton.width\n"
                             "lightsOnButton.top = lightControls.top\n"
                             "lightsOnButton.bottom = lightControls.bottom\n"
                             "lightsOffButton.top = lightControls.top\n"
                             "lightsOffButton.bottom = lightControls.bottom";
    NSDictionary * identifiers = NSDictionaryOfVariableBindingsToIdentifiers(lightControls, lightsOnButton, lightsOffButton);

    [lightControls.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    constraints = @"lightsOnButton.width = 44";
    [lightsOnButton.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    return lightControls;
}

#pragma mark - DPad construction
/// @name ￼DPad construction

- (ButtonGroup *)rawDPad {
    ButtonGroup * buttonGroup = MakeButtonGroup(@"key" : @"dpad",
                                                @"displayName" : @"dpad",
                                                @"backgroundColor" : defaultBGColor(),
                                                @"shape" : @(ButtonGroupShapeDPad),
                                                @"style" : @(ButtonGroupStyleApplyGloss | ButtonGroupStyleDrawBorder));
    NSMutableDictionary * attributesHighlighted = [@{}
                                                   mutableCopy];
    NSDictionary * attributes = [self.buttonBuilder buttonTitleAttributesWithFontName:kDefaultFontName fontSize:32.0 highlighted:attributesHighlighted];

    // Create center "OK" button and add to button group
    NSAttributedString * attributedString            = [[NSAttributedString alloc] initWithString:@"OK" attributes:attributes];
    NSAttributedString * attributedStringHighlighted = [[NSAttributedString alloc] initWithString:@"OK" attributes:attributesHighlighted];
    Button             * ok                          = MakeButton(@"key" : kDPadOkButtonKey,
                                                                  @"displayName" : @"OK",
                                                                  @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                                                           ));

    [buttonGroup addSubelementsObject:ok];

    // Create up button and add to button group
    attributes                  = [self.buttonBuilder buttonTitleAttributesWithFontName:kArrowFontName fontSize:32.0 highlighted:attributesHighlighted];
    attributedString            = [[NSAttributedString alloc] initWithString:kUpArrow attributes:attributes];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:kUpArrow attributes:attributesHighlighted];

    Button * up = MakeButton(@"key" : kDPadUpButtonKey,
                             @"displayName" : @"Up",
                             @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                      ),
                             @"style" : @(ButtonSubtypeButtonGroupPiece), );

    // Create down button and add to button group
    attributedString            = [[NSAttributedString alloc] initWithString:kDownArrow attributes:attributes];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:kDownArrow attributes:attributesHighlighted];

    Button * down = MakeButton(@"subtype" : @(ButtonSubtypeButtonGroupPiece),
                               @"key" : kDPadDownButtonKey,
                               @"displayName" : @"Down",
                               @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                        ));

    // Create right button and add to button group
    attributedString            = [[NSAttributedString alloc] initWithString:kRightArrow attributes:attributes];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:kRightArrow attributes:attributesHighlighted];

    Button * _right = MakeButton(@"style" : @(ButtonSubtypeButtonGroupPiece),
                                 @"key" : kDPadRightButtonKey,
                                 @"displayName" : @"Right",
                                 @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                          ));

    // Create left button and add to button group
    attributedString            = [[NSAttributedString alloc] initWithString:kLeftArrow attributes:attributes];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:kLeftArrow attributes:attributesHighlighted];

    Button * _left = MakeButton(@"subtype" : @(ButtonSubtypeButtonGroupPiece),
                                @"key" : kDPadLeftButtonKey,
                                @"displayName" : @"Left",
                                @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                         ));

    [buttonGroup addSubelements:[@[ok, up, down, _left, _right] orderedSet]];

    // TODO: Add alignment and sizing options to buttons

    NSDictionary * identifiers = NSDictionaryOfVariableBindingsToIdentifiers(buttonGroup, ok, up, down, _left, _right);
    NSString     * constraints =
        @"ok.centerX = buttonGroup.centerX\n"
        "ok.centerY = buttonGroup.centerY\n"
        "ok.width = buttonGroup.width * 0.3\n"
        "up.top = buttonGroup.top\n"
        "up.bottom = ok.top\n"
        "up.left = _left.right\n"
        "up.right = _right.left\n"
        "down.top = ok.bottom\n"
        "down.bottom = buttonGroup.bottom\n"
        "down.left = _left.right\n"
        "down.right = _right.left\n"
        "_left.left = buttonGroup.left\n"
        "_left.right = ok.left\n"
        "_left.top = up.bottom\n"
        "_left.bottom = down.top\n"
        "_right.left = ok.right\n"
        "_right.right = buttonGroup.right\n"
        "_right.top = up.bottom\n"
        "_right.bottom = down.top\n"
        "buttonGroup.width = buttonGroup.height\n"
        "buttonGroup.height = 300";

    [buttonGroup.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    constraints = @"ok.height = ok.width";
    [ok.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    return buttonGroup;
}  /* rawDPad */

- (ButtonGroup *)constructDVRDPad {
    ComponentDevice * comcastDVR  = [ComponentDevice fetchComponentDeviceWithName:@"Comcast DVR" inContext:self.buildContext];
    ComponentDevice * samsungTV   = [ComponentDevice fetchComponentDeviceWithName:@"Samsung TV" inContext:self.buildContext];
    ButtonGroup     * buttonGroup = [self rawDPad];

    buttonGroup.displayName = @"DVR DPad";

    ButtonGroupConfigurationDelegate * buttonGroupConfigurationDelegate =
        [ButtonGroupConfigurationDelegate buttonGroupConfigurationDelegateForButtonGroup:buttonGroup];

    // Create default DPad command set
    DPad   * dvrDPad = [DPad newDPadInContext:self.buildContext];
    IRCode * irCode  = [comcastDVR codeWithName:@"OK"];

    [dvrDPad setCommandFromIRCode:irCode forKey:kDPadOkButtonKey];
    irCode = [comcastDVR codeWithName:@"Up"];
    [dvrDPad setCommandFromIRCode:irCode forKey:kDPadUpButtonKey];
    irCode = [comcastDVR codeWithName:@"Down"];
    [dvrDPad setCommandFromIRCode:irCode forKey:kDPadDownButtonKey];
    irCode = [comcastDVR codeWithName:@"Right"];
    [dvrDPad setCommandFromIRCode:irCode forKey:kDPadRightButtonKey];
    irCode = [comcastDVR codeWithName:@"Left"];
    [dvrDPad setCommandFromIRCode:irCode forKey:kDPadLeftButtonKey];
    [buttonGroupConfigurationDelegate registerCommandSet:dvrDPad
                                        forConfiguration:
     kDefaultConfiguration];

    // Create tv DPad command set
    DPad * tvDPad = [DPad newDPadInContext:self.buildContext];

    irCode = [samsungTV codeWithName:@"Enter"];
    [tvDPad setCommandFromIRCode:irCode forKey:kDPadOkButtonKey];
    irCode = [samsungTV codeWithName:@"Up"];
    [tvDPad setCommandFromIRCode:irCode forKey:kDPadUpButtonKey];
    irCode = [samsungTV codeWithName:@"Down"];
    [tvDPad setCommandFromIRCode:irCode forKey:kDPadDownButtonKey];
    irCode = [samsungTV codeWithName:@"Right"];
    [tvDPad setCommandFromIRCode:irCode forKey:kDPadRightButtonKey];
    irCode = [samsungTV codeWithName:@"Left"];
    [tvDPad setCommandFromIRCode:irCode forKey:kDPadLeftButtonKey];
    [buttonGroupConfigurationDelegate registerCommandSet:tvDPad forConfiguration:kTVConfiguration];
    buttonGroup.commandSet = dvrDPad;

    return buttonGroup;
}

- (ButtonGroup *)constructPS3DPad {
    ComponentDevice * ps3         = [ComponentDevice fetchComponentDeviceWithName:@"PS3" inContext:self.buildContext];
    ButtonGroup     * buttonGroup = [self rawDPad];

    buttonGroup.displayName = @"Playstation DPad";

    // Create default DPad command set
    DPad   * ps3DPad = [DPad newDPadInContext:self.buildContext];
    IRCode * irCode  = [ps3 codeWithName:@"Enter"];

    [ps3DPad setCommandFromIRCode:irCode forKey:kDPadOkButtonKey];
    irCode = [ps3 codeWithName:@"Up"];
    [ps3DPad setCommandFromIRCode:irCode forKey:kDPadUpButtonKey];
    irCode = [ps3 codeWithName:@"Down"];
    [ps3DPad setCommandFromIRCode:irCode forKey:kDPadDownButtonKey];
    irCode = [ps3 codeWithName:@"Right"];
    [ps3DPad setCommandFromIRCode:irCode forKey:kDPadRightButtonKey];
    irCode = [ps3 codeWithName:@"Left"];
    [ps3DPad setCommandFromIRCode:irCode forKey:kDPadLeftButtonKey];
    buttonGroup.commandSet = ps3DPad;

    return buttonGroup;
}

#pragma mark - NumberPad construction
/// @name ￼NumberPad construction

- (ButtonGroup *)rawNumberPad {
    // TODO:add constraints
    ButtonGroup * numberPad = MakeButtonGroup(@"key" : @"numberpad",
                                              @"displayName" : @"numberpad",
                                              @"backgroundColor" :[kPanelBackgroundColor colorWithAlphaComponent:0.75]);
    NSNumber            * style                 = @(ButtonShapeRoundedRectangle | ButtonStyleApplyGloss | ButtonStyleDrawBorder);
    NSMutableDictionary * attributesHighlighted = [@{}
                                                   mutableCopy];
    NSMutableDictionary * attributes                  = [self.buttonBuilder buttonTitleAttributesWithFontName:kDefaultFontName fontSize:64.0 highlighted:attributesHighlighted];
    NSAttributedString  * attributedString            = [[NSAttributedString alloc] initWithString:@"1" attributes:attributes];
    NSAttributedString  * attributedStringHighlighted = [[NSAttributedString alloc] initWithString:@"1" attributes:attributesHighlighted];
    Button              * one                         = MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                                                                   @"style" : style,
                                                                   @"key" : kDigitOneButtonKey,
                                                                   @"displayName" : @"Digit 1",
                                                                   @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                                                            ));

    attributedString            = [[NSAttributedString alloc] initWithString:@"2" attributes:attributes];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:@"2" attributes:attributesHighlighted];

    Button * two = MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                              @"style" : style,
                              @"key" : kDigitTwoButtonKey,
                              @"displayName" : @"Digit 2",
                              @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                       ));

    attributedString            = [[NSAttributedString alloc] initWithString:@"3" attributes:attributes];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:@"3" attributes:attributesHighlighted];

    Button * three = MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                                @"style" : style,
                                @"key" : kDigitThreeButtonKey,
                                @"displayName" : @"Digit 3",
                                @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                         ));

    attributedString            = [[NSAttributedString alloc] initWithString:@"4" attributes:attributes];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:@"4" attributes:attributesHighlighted];

    Button * four = MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                               @"style" : style,
                               @"key" : kDigitFourButtonKey,
                               @"displayName" : @"Digit 4",
                               @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                        ));

    attributedString            = [[NSAttributedString alloc] initWithString:@"5" attributes:attributes];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:@"5" attributes:attributesHighlighted];

    Button * five = MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                               @"style" : style,
                               @"key" : kDigitFiveButtonKey,
                               @"displayName" : @"Digit 5",
                               @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                        ));

    attributedString            = [[NSAttributedString alloc] initWithString:@"6" attributes:attributes];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:@"6" attributes:attributesHighlighted];

    Button * six = MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                              @"style" : style,
                              @"key" : kDigitSixButtonKey,
                              @"displayName" : @"Digit 6",
                              @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                       ));

    attributedString            = [[NSAttributedString alloc] initWithString:@"7" attributes:attributes];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:@"7" attributes:attributesHighlighted];

    Button * seven = MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                                @"style" : style,
                                @"key" : kDigitSevenButtonKey,
                                @"displayName" : @"Digit 7",
                                @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                         ));

    attributedString            = [[NSAttributedString alloc] initWithString:@"8" attributes:attributes];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:@"8" attributes:attributesHighlighted];

    Button * _eight = MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                                 @"style" : style,
                                 @"key" : kDigitEightButtonKey,
                                 @"displayName" : @"Digit 8",
                                 @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                          ));

    attributedString            = [[NSAttributedString alloc] initWithString:@"9" attributes:attributes];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:@"9" attributes:attributesHighlighted];

    Button * nine = MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                               @"style" : style,
                               @"key" : kDigitNineButtonKey,
                               @"displayName" : @"Digit 9",
                               @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                        ));

    attributedString            = [[NSAttributedString alloc] initWithString:@"0" attributes:attributes];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:@"0" attributes:attributesHighlighted];

    Button * zero = MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                               @"style" : style,
                               @"key" : kDigitZeroButtonKey,
                               @"displayName" : @"Digit 0",
                               @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                        ));

    attributes[NSForegroundColorAttributeName]        = [UIColor colorWithWhite:0.0 alpha:0.5];
    attributes[NSStrokeWidthAttributeName]            = @0;
    attributedString                                  = [[NSAttributedString alloc] initWithString:kUpArrow attributes:attributes];
    attributesHighlighted[NSStrokeWidthAttributeName] = @0;
// attributes[NSForegroundColorAttributeName] = [UIColor colorWithWhite:0.0 alpha:0.75];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:kUpArrow attributes:attributesHighlighted];

    Button * tuck = MakeButton(@"key" : kTuckButtonKey,
                               @"displayName" : @"Tuck Panel",
                               @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                        ));

    [attributesHighlighted removeAllObjects];
    attributes                  = [self.buttonBuilder buttonTitleAttributesWithFontName:kDefaultFontName fontSize:32.0 highlighted:attributesHighlighted];
    attributedString            = [[NSAttributedString alloc] initWithString:@"Exit" attributes:attributes];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:@"Exit" attributes:attributesHighlighted];

    Button * aux1 = MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                               @"style" : style,
                               @"key" : kAuxOneButtonKey,
                               @"displayName" : @"Exit",
                               @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                        ));

    attributedString            = [[NSAttributedString alloc] initWithString:@"Enter" attributes:attributes];
    attributedStringHighlighted = [[NSAttributedString alloc] initWithString:@"Enter" attributes:attributesHighlighted];

    Button * aux2 = MakeButton(@"titleEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsZero),
                               @"style" : style,
                               @"key" : kAuxTwoButtonKey,
                               @"displayName" : @"Enter",
                               @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                        ));

    [numberPad addSubelements:[@[one, two, three, four, five, six, seven, _eight, nine, zero, aux1, aux2, tuck] orderedSet]];

    NSString * constraints =
        @"one.left = numberPad.left\n"
        "one.top = numberPad.top\n"
        "one.bottom = two.bottom\n"

        "two.left = one.right\n"
        "two.top = numberPad.top\n"
        "two.width = one.width\n"

        "three.left = two.right\n"
        "three.right = numberPad.right\n"
        "three.top = numberPad.top\n"
        "three.bottom = two.bottom\n"
        "three.width = one.width\n"

        "four.left = numberPad.left\n"
        "four.top = one.bottom\n"
        "four.right = one.right\n"
        "four.bottom = five.bottom\n"

        "five.left = two.left\n"
        "five.top = two.bottom\n"
        "five.right = two.right\n"
        "five.height = two.height\n"

        "six.left = three.left\n"
        "six.right = numberPad.right\n"
        "six.top = three.bottom\n"
        "six.bottom = five.bottom\n"

        "seven.left = numberPad.left\n"
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

        "aux1.left = numberPad.left\n"
        "aux1.top = seven.bottom\n"
        "aux1.bottom = zero.bottom\n"
        "aux1.right = seven.right\n"

        "zero.left = _eight.left\n"
        "zero.top = _eight.bottom\n"
        "zero.right = _eight.right\n"
        "zero.bottom = tuck.top\n"
        "zero.height = two.height\n"

        "aux2.left = nine.left\n"
        "aux2.right = numberPad.right\n"
        "aux2.top = nine.bottom\n"
        "aux2.bottom = zero.bottom\n"

        "tuck.left = numberPad.left\n"
        "tuck.right = numberPad.right\n"
        "tuck.bottom = numberPad.bottom\n"
        "tuck.height = two.height";
    NSDictionary * identifiers =
        NSDictionaryOfVariableBindingsToIdentifiers(numberPad, one, two, three, four, five, six, seven, _eight, nine, zero, aux1, aux2, tuck);

    [numberPad.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    return numberPad;
}  /* rawNumberPad */

- (ButtonGroup *)constructDVRNumberPad {
    ComponentDevice * comcastDVR = [ComponentDevice fetchComponentDeviceWithName:@"Comcast DVR" inContext:self.buildContext];

    // Create number pad button and add to button group
    NumberPad * dvrNumberPad = [NumberPad newNumberPadInContext:self.buildContext];
    IRCode    * irCode       = [comcastDVR codeWithName:@"One"];

    [dvrNumberPad setCommandFromIRCode:irCode forKey:kDigitOneButtonKey];
    irCode = [comcastDVR codeWithName:@"Two"];
    [dvrNumberPad setCommandFromIRCode:irCode forKey:kDigitTwoButtonKey];
    irCode = [comcastDVR codeWithName:@"Three"];
    [dvrNumberPad setCommandFromIRCode:irCode forKey:kDigitThreeButtonKey];
    irCode = [comcastDVR codeWithName:@"Four"];
    [dvrNumberPad setCommandFromIRCode:irCode forKey:kDigitFourButtonKey];
    irCode = [comcastDVR codeWithName:@"Five"];
    [dvrNumberPad setCommandFromIRCode:irCode forKey:kDigitFiveButtonKey];
    irCode = [comcastDVR codeWithName:@"Six"];
    [dvrNumberPad setCommandFromIRCode:irCode forKey:kDigitSixButtonKey];
    irCode = [comcastDVR codeWithName:@"Seven"];
    [dvrNumberPad setCommandFromIRCode:irCode forKey:kDigitSevenButtonKey];
    irCode = [comcastDVR codeWithName:@"Eight"];
    [dvrNumberPad setCommandFromIRCode:irCode forKey:kDigitEightButtonKey];
    irCode = [comcastDVR codeWithName:@"Nine"];
    [dvrNumberPad setCommandFromIRCode:irCode forKey:kDigitNineButtonKey];
    irCode = [comcastDVR codeWithName:@"Zero"];
    [dvrNumberPad setCommandFromIRCode:irCode forKey:kDigitZeroButtonKey];
    irCode = [comcastDVR codeWithName:@"Exit"];
    [dvrNumberPad setCommandFromIRCode:irCode forKey:kAuxOneButtonKey];
    irCode = [comcastDVR codeWithName:@"OK"];
    [dvrNumberPad setCommandFromIRCode:irCode forKey:kAuxTwoButtonKey];

    ButtonGroup * numberPadButtonGroup = [self rawNumberPad];

    numberPadButtonGroup.displayName   = @"DVR Number Pad";
    numberPadButtonGroup.commandSet    = dvrNumberPad;
    numberPadButtonGroup.key           = kTopPanelOneKey;
    numberPadButtonGroup.panelLocation = ButtonGroupPanelLocationTop;

    ButtonGroupConfigurationDelegate * buttonGroupConfigurationDelegate =
        [ButtonGroupConfigurationDelegate
         buttonGroupConfigurationDelegateForButtonGroup:numberPadButtonGroup];

    [buttonGroupConfigurationDelegate registerCommandSet:dvrNumberPad
                                        forConfiguration:kDefaultConfiguration];

    return numberPadButtonGroup;
}

- (ButtonGroup *)constructPS3NumberPad {
    ComponentDevice * ps3 = [ComponentDevice fetchComponentDeviceWithName:@"PS3" inContext:self.buildContext];

    // Create number pad button and add to button group
    NumberPad * ps3NumberPad = [NumberPad newNumberPadInContext:self.buildContext];
    IRCode    * irCode       = [ps3 codeWithName:@"1"];

    [ps3NumberPad setCommandFromIRCode:irCode forKey:kDigitOneButtonKey];
    irCode = [ps3 codeWithName:@"2"];
    [ps3NumberPad setCommandFromIRCode:irCode forKey:kDigitTwoButtonKey];
    irCode = [ps3 codeWithName:@"3"];
    [ps3NumberPad setCommandFromIRCode:irCode forKey:kDigitThreeButtonKey];
    irCode = [ps3 codeWithName:@"4"];
    [ps3NumberPad setCommandFromIRCode:irCode forKey:kDigitFourButtonKey];
    irCode = [ps3 codeWithName:@"5"];
    [ps3NumberPad setCommandFromIRCode:irCode forKey:kDigitFiveButtonKey];
    irCode = [ps3 codeWithName:@"6"];
    [ps3NumberPad setCommandFromIRCode:irCode forKey:kDigitSixButtonKey];
    irCode = [ps3 codeWithName:@"7"];
    [ps3NumberPad setCommandFromIRCode:irCode forKey:kDigitSevenButtonKey];
    irCode = [ps3 codeWithName:@"8"];
    [ps3NumberPad setCommandFromIRCode:irCode forKey:kDigitEightButtonKey];
    irCode = [ps3 codeWithName:@"9"];
    [ps3NumberPad setCommandFromIRCode:irCode forKey:kDigitNineButtonKey];
    irCode = [ps3 codeWithName:@"0"];
    [ps3NumberPad setCommandFromIRCode:irCode forKey:kDigitZeroButtonKey];

    ButtonGroup * numberPadButtonGroup = [self rawNumberPad];

    numberPadButtonGroup.displayName   = @"Playstation Number Pad";
    numberPadButtonGroup.commandSet    = ps3NumberPad;
    numberPadButtonGroup.key           = kTopPanelOneKey;
    numberPadButtonGroup.panelLocation = ButtonGroupPanelLocationTop;

    return numberPadButtonGroup;
}

#pragma mark - Transport construction
/// @name ￼Transport construction

- (ButtonGroup *)rawTransport {
    ButtonGroup * transport = MakeButtonGroup(@"key" : @"transport",
                                              @"displayName" : @"transport",
                                              @"backgroundColor" :[kPanelBackgroundColor colorWithAlphaComponent:0.75]);

    // Create "rewind" button and add to button group
    Button * rewind = MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                                 @"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                 @"shape" : @(ButtonShapeRoundedRectangle),
                                 @"key" : kTransportRewindButtonKey,
                                 @"displayName" : @"Rewind",
                                 @"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor, @1 : kHighlightColor}
                                                                          ), @{@0 : MakeIconImage(4004)}
                                                             ));

    // Create "pause" button and add to button group
    Button * pause = MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                                @"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                @"shape" : @(ButtonShapeRoundedRectangle),
                                @"key" : kTransportPauseButtonKey,
                                @"displayName" : @"Pause",
                                @"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor, @1 : kHighlightColor}
                                                                         ), @{@0 : MakeIconImage(4001)}
                                                            ));

    // Create "fast forward" button and add to button group
    Button * fastForward = MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                                      @"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                      @"shape" : @(ButtonShapeRoundedRectangle),
                                      @"key" : kTransportFastForwardButtonKey,
                                      @"displayName" : @"Fast Forward",
                                      @"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor, @1 : kHighlightColor}
                                                                               ), @{@0 : MakeIconImage(4000)}
                                                                  ));

    // Create "previous" button and add to button group
    Button * previous = MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                                   @"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                   @"shape" : @(ButtonShapeRoundedRectangle),
                                   @"key" : kTransportPreviousButtonKey,
                                   @"displayName" : @"Previous",
                                   @"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor, @1 : kHighlightColor}
                                                                            ), @{@0 : MakeIconImage(4005)}
                                                               ));

    // Create "play" button and add to button group
    Button * play = MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                               @"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                               @"shape" : @(ButtonShapeRoundedRectangle),
                               @"key" : kTransportPlayButtonKey,
                               @"displayName" : @"Play",
                               @"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor, @1 : kHighlightColor}
                                                                        ), @{@0 : MakeIconImage(4002)}
                                                           ));

    // Create "next" button and add to button group
    Button * next = MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                               @"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                               @"shape" : @(ButtonShapeRoundedRectangle),
                               @"key" : kTransportNextButtonKey,
                               @"displayName" : @"Next",
                               @"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor, @1 : kHighlightColor}
                                                                        ), @{@0 : MakeIconImage(4006)}
                                                           ));

    // Create "record" button and add to button group
    Button * record = MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                                 @"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                 @"shape" : @(ButtonShapeRoundedRectangle),
                                 @"key" : kTransportRecordButtonKey,
                                 @"displayName" : @"Record",
                                 @"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor, @1 : kHighlightColor}
                                                                          ), @{@0 : MakeIconImage(4003)}
                                                             ));

    // Create "stop" button and add to button group
    Button * stop = MakeButton(@"imageEdgeInsets" : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                               @"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                               @"shape" : @(ButtonShapeRoundedRectangle),
                               @"key" : kTransportStopButtonKey,
                               @"displayName" : @"Stop",
                               @"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor, @1 : kHighlightColor}
                                                                        ), @{@0 : MakeIconImage(4007)}
                                                           ));
    NSMutableDictionary * attributesHighlighted = [@{}
                                                   mutableCopy];
    NSMutableDictionary * attributes = [self.buttonBuilder buttonTitleAttributesWithFontName:kDefaultFontName fontSize:64.0 highlighted:attributesHighlighted];

    attributes[NSForegroundColorAttributeName] = [UIColor colorWithWhite:0.0 alpha:0.5];
    attributes[NSStrokeWidthAttributeName]     = @0;

    NSAttributedString * attributedString =
        [[NSAttributedString alloc] initWithString:kDownArrow attributes:attributes];

// attributes[NSForegroundColorAttributeName] = [UIColor colorWithWhite:0.0 alpha:0.75];
    attributesHighlighted[NSStrokeWidthAttributeName] = @0;

    NSAttributedString * attributedStringHighlighted = [[NSAttributedString alloc] initWithString:kDownArrow attributes:attributesHighlighted];
    Button             * tuck                        = MakeButton(@"key" : kTuckButtonKey,
                                                                  @"displayName" : @"Tuck Panel",
                                                                  @"titles" : MakeTitleSet(@{@0 : attributedString, @1 : attributedStringHighlighted}
                                                                                           ));

    [transport addSubelements:[@[play, pause, rewind, fastForward, stop, previous, tuck, next, record] orderedSet]];

    // TODO:Replace visual format with extended visual format
    NSString * constraints =
        @"record.left = transport.left\n"
        "record.top = transport.top\n"

        "play.left = record.right\n"
        "play.top = transport.top\n"
        "play.bottom = record.bottom\n"
        "play.width = record.width\n"
// "play.height = record.height\n"

        "stop.left = play.right\n"
        "stop.right = transport.right\n"
        "stop.top = transport.top\n"
        "stop.bottom = play.bottom\n"
        "stop.width = record.width\n"
// "stop.height = record.height\n"

        "rewind.left = transport.left\n"
        "rewind.top = record.bottom\n"
        "rewind.right = record.right\n"
        "rewind.bottom = pause.bottom\n"
// "rewind.height = record.height\n"
// "rewind.width = record.width\n"

        "pause.left = play.left\n"
        "pause.top = play.bottom\n"
        "pause.right = play.right\n"
        "pause.height = play.height\n"
// "pause.width = record.width\n"

        "fastForward.left = stop.left\n"
        "fastForward.right = transport.right\n"
        "fastForward.top = stop.bottom\n"
        "fastForward.bottom = pause.bottom\n"
// "fastForward.width = record.width\n"
// "fastForward.height = record.height\n"

        "previous.left = transport.left\n"
        "previous.top = rewind.bottom\n"
        "previous.right = rewind.right\n"
        "previous.bottom = transport.bottom\n"
// "previous.height = record.height\n"

        "tuck.left = pause.left\n"
        "tuck.top = pause.bottom\n"
        "tuck.right = pause.right\n"
        "tuck.bottom = transport.bottom\n"
        "tuck.height = play.height\n"
// "tuck.width = record.width\n"

        "next.left = fastForward.left\n"
        "next.right = transport.right\n"
        "next.top = fastForward.bottom\n"
        "next.bottom = transport.bottom\n"
// "next.width = record.width\n"
// "next.height = record.height\n"

        "transport.height = transport.width";
    NSDictionary * identifiers =
        NSDictionaryOfVariableBindingsToIdentifiers(transport, play, pause, rewind, fastForward, stop, previous, tuck, next, record);

    [transport.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    return transport;
}  /* rawTransport */

- (ButtonGroup *)constructDVRTransport {
    ComponentDevice                  * comcastDVR                       = [ComponentDevice fetchComponentDeviceWithName:@"Comcast DVR" inContext:self.buildContext];
    ComponentDevice                  * samsungTV                        = [ComponentDevice fetchComponentDeviceWithName:@"Samsung TV" inContext:self.buildContext];
    ButtonGroup                      * transportButtonGroup             = [self rawTransport];
    ButtonGroupConfigurationDelegate * buttonGroupConfigurationDelegate =
        [ButtonGroupConfigurationDelegate
         buttonGroupConfigurationDelegateForButtonGroup:transportButtonGroup];

    // Create default transport command set
    Transport * dvrTransport = [Transport newTransportInContext:self.buildContext];
    IRCode    * irCode       = [comcastDVR codeWithName:@"Prev"];

    [dvrTransport setCommandFromIRCode:irCode forKey:kTransportPreviousButtonKey];
    irCode = [comcastDVR codeWithName:@"Stop"];
    [dvrTransport setCommandFromIRCode:irCode forKey:kTransportStopButtonKey];
    irCode = [comcastDVR codeWithName:@"Play"];
    [dvrTransport setCommandFromIRCode:irCode forKey:kTransportPlayButtonKey];
    irCode = [comcastDVR codeWithName:@"Pause"];
    [dvrTransport setCommandFromIRCode:irCode forKey:kTransportPauseButtonKey];
    irCode = [comcastDVR codeWithName:@"Next"];
    [dvrTransport setCommandFromIRCode:irCode forKey:kTransportNextButtonKey];
    irCode = [comcastDVR codeWithName:@"Fast Forward"];
    [dvrTransport setCommandFromIRCode:irCode forKey:kTransportFastForwardButtonKey];
    irCode = [comcastDVR codeWithName:@"Rewind"];
    [dvrTransport setCommandFromIRCode:irCode forKey:kTransportRewindButtonKey];
    irCode = [comcastDVR codeWithName:@"Record"];
    [dvrTransport setCommandFromIRCode:irCode forKey:kTransportRecordButtonKey];
    [buttonGroupConfigurationDelegate registerCommandSet:dvrTransport
                                        forConfiguration:kDefaultConfiguration];

    // Create TV transport command set
    Transport * tvTransport = [Transport newTransportInContext:self.buildContext];

    irCode = [samsungTV codeWithName:@"Rewind"];
    [tvTransport setCommandFromIRCode:irCode forKey:kTransportRewindButtonKey];
    irCode = [samsungTV codeWithName:@"Pause"];
    [tvTransport setCommandFromIRCode:irCode forKey:kTransportPauseButtonKey];
    irCode = [samsungTV codeWithName:@"Fast Forward"];
    [tvTransport setCommandFromIRCode:irCode forKey:kTransportFastForwardButtonKey];
    irCode = [samsungTV codeWithName:@"Record"];
    [tvTransport setCommandFromIRCode:irCode forKey:kTransportRecordButtonKey];
    irCode = [samsungTV codeWithName:@"Play"];
    [tvTransport setCommandFromIRCode:irCode forKey:kTransportPlayButtonKey];
    // Code does not exist so it has been commented out
    // irCode = [samsungTV codeWithName:@"Stop"];
    // [tvTransport setCommandFromIRCode:irCode forKey:kTransportStopButtonKey];
    [buttonGroupConfigurationDelegate registerCommandSet:tvTransport
                                        forConfiguration:kTVConfiguration];

    transportButtonGroup.displayName = @"DVR Transport";
    // transportButtonGroup.commandSet = dvrTransport;
    transportButtonGroup.key           = kBottomPanelOneKey;
    transportButtonGroup.panelLocation = ButtonGroupPanelLocationBottom;

    return transportButtonGroup;
}  /* constructDVRTransport */

- (ButtonGroup *)constructPS3Transport {
    ComponentDevice * ps3 = [ComponentDevice fetchComponentDeviceWithName:@"PS3" inContext:self.buildContext];

    // Create default transport command set
    Transport * ps3Transport = [Transport newTransportInContext:self.buildContext];
    IRCode    * irCode       = [ps3 codeWithName:@"Previous"];

    [ps3Transport setCommandFromIRCode:irCode forKey:kTransportPreviousButtonKey];
    irCode = [ps3 codeWithName:@"Stop"];
    [ps3Transport setCommandFromIRCode:irCode forKey:kTransportStopButtonKey];
    irCode = [ps3 codeWithName:@"Play"];
    [ps3Transport setCommandFromIRCode:irCode forKey:kTransportPlayButtonKey];
    irCode = [ps3 codeWithName:@"Pause"];
    [ps3Transport setCommandFromIRCode:irCode forKey:kTransportPauseButtonKey];
    irCode = [ps3 codeWithName:@"Next"];
    [ps3Transport setCommandFromIRCode:irCode forKey:kTransportNextButtonKey];
    irCode = [ps3 codeWithName:@"Scan Forward"];
    [ps3Transport setCommandFromIRCode:irCode forKey:kTransportFastForwardButtonKey];
    irCode = [ps3 codeWithName:@"Scan Reverse"];
    [ps3Transport setCommandFromIRCode:irCode forKey:kTransportRewindButtonKey];

    ButtonGroup * transportButtonGroup = [self rawTransport];

    transportButtonGroup.displayName   = @"Playstation Transport";
    transportButtonGroup.commandSet    = ps3Transport;
    transportButtonGroup.key           = kBottomPanelOneKey;
    transportButtonGroup.panelLocation = ButtonGroupPanelLocationBottom;

    return transportButtonGroup;
}

#pragma mark - Rocker construction
/// @name ￼Rocker construction

- (PickerLabelButtonGroup *)rawRocker {
    PickerLabelButtonGroup * buttonGrp = MakeElement(@"type" : @(ButtonGroupTypePickerLabel),
                                                     @"backgroundColor" : defaultBGColor(),
                                                     @"shape" : @(ButtonGroupShapeRocker),
                                                     @"key" : @"rocker",
                                                     @"displayName" : @"rocker",
                                                     @"style" : @(ButtonGroupStyleApplyGloss | ButtonGroupStyleDrawBorder));

    // Create top button and add to button group
    Button * up = MakeButton(@"subtype" : @(ButtonSubtypeButtonGroupPiece),
                             @"displayName" : @"Rocker Up",
                             @"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor, @1 : kHighlightColor}
                                                                      ), @{@0 : MakeIconImage(40)}
                                                         ),
                             @"key" : kRockerButtonPlusButtonKey);

    // Create bottom button and add to button group
    Button * down = MakeButton(@"subtype" : @(ButtonSubtypeButtonGroupPiece),
                               @"displayName" : @"Rocker Down",
                               @"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor, @1 : kHighlightColor}
                                                                        ), @{@0 : MakeIconImage(155)}
                                                           ),
                               @"key" : kRockerButtonMinusButtonKey);

    [buttonGrp addSubelements:[@[up, down] orderedSet]];

    NSString * constraints =
        @"up.top = buttonGrp.top\n"
        "down.top = up.bottom\n"
        "down.height = up.height\n"
        "up.left = buttonGrp.left\n"
        "up.right = buttonGrp.right\n"
        "down.left = buttonGrp.left\n"
        "down.right = buttonGrp.right\n"
        "up.height = buttonGrp.height * 0.5\n"
        "buttonGrp.width = 70\n"
        "buttonGrp.height ≥ 150";
    NSDictionary * identifiers = NSDictionaryOfVariableBindingsToIdentifiers(buttonGrp, up, down);

    [buttonGrp.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    return buttonGrp;
}

- (PickerLabelButtonGroup *)constructDVRRocker {
    ComponentDevice * comcastDVR                     = [ComponentDevice fetchComponentDeviceWithName:@"Comcast DVR" inContext:self.buildContext];
    RockerButton    * rockerButtonChannelsCommandSet =
        [RockerButton newRockerButtonInContext:self.buildContext];
    IRCode * irCode = [comcastDVR codeWithName:@"Channel Up"];

    [rockerButtonChannelsCommandSet setCommandFromIRCode:irCode forKey:kRockerButtonPlusButtonKey];
    irCode = [comcastDVR codeWithName:@"Channel Down"];
    [rockerButtonChannelsCommandSet setCommandFromIRCode:irCode forKey:kRockerButtonMinusButtonKey];

    RockerButton * rockerButtonPageUpDownCommandSet =
        [RockerButton newRockerButtonInContext:self.buildContext];

    irCode = [comcastDVR codeWithName:@"Page Up"];
    [rockerButtonPageUpDownCommandSet setCommandFromIRCode:irCode forKey:kRockerButtonPlusButtonKey];
    irCode = [comcastDVR codeWithName:@"Page Down"];
    [rockerButtonPageUpDownCommandSet setCommandFromIRCode:irCode forKey:kRockerButtonMinusButtonKey];

    ComponentDevice * avReceiver                   = [ComponentDevice fetchComponentDeviceWithName:@"AV Receiver" inContext:self.buildContext];
    RockerButton    * rockerButtonVolumeCommandSet =
        [RockerButton newRockerButtonInContext:self.buildContext];

    irCode = [avReceiver codeWithName:@"Volume Up"];
    [rockerButtonVolumeCommandSet setCommandFromIRCode:irCode forKey:kRockerButtonPlusButtonKey];
    irCode = [avReceiver codeWithName:@"Volume Down"];
    [rockerButtonVolumeCommandSet setCommandFromIRCode:irCode forKey:kRockerButtonMinusButtonKey];

    PickerLabelButtonGroup * pickerLabelButtonGroup = [self rawRocker];

    pickerLabelButtonGroup.displayName = @"DVR Rocker";
    [pickerLabelButtonGroup addLabel:[[NSAttributedString alloc] initWithString:@"CH"
                                                                     attributes:[self.buttonBuilder
                                                  buttonTitleAttributesWithFontName:nil
                                                                           fontSize:0
                                                                        highlighted:NO]]
                      withCommandSet:rockerButtonChannelsCommandSet];
    [pickerLabelButtonGroup addLabel:[[NSAttributedString alloc] initWithString:@"PAGE"
                                                                     attributes:[self.buttonBuilder
                                                  buttonTitleAttributesWithFontName:nil
                                                                           fontSize:0
                                                                        highlighted:NO]]
                      withCommandSet:rockerButtonPageUpDownCommandSet];
    [pickerLabelButtonGroup addLabel:[[NSAttributedString alloc] initWithString:@"VOL"
                                                                     attributes:[self.buttonBuilder
                                                  buttonTitleAttributesWithFontName:nil
                                                                           fontSize:0
                                                                        highlighted:NO]]
                      withCommandSet:rockerButtonVolumeCommandSet];

    return pickerLabelButtonGroup;
}  /* constructDVRRocker */

- (PickerLabelButtonGroup *)constructPS3Rocker {
    ComponentDevice * avReceiver                   = [ComponentDevice fetchComponentDeviceWithName:@"AV Receiver" inContext:self.buildContext];
    RockerButton    * rockerButtonVolumeCommandSet = [RockerButton newRockerButtonInContext:self.buildContext];
    IRCode          * irCode                       = [avReceiver codeWithName:@"Volume Up"];

    [rockerButtonVolumeCommandSet setCommandFromIRCode:irCode forKey:kRockerButtonPlusButtonKey];
    irCode = [avReceiver codeWithName:@"Volume Down"];
    [rockerButtonVolumeCommandSet setCommandFromIRCode:irCode forKey:kRockerButtonMinusButtonKey];

    PickerLabelButtonGroup * pickerLabelButtonGroup = [self rawRocker];

    pickerLabelButtonGroup.displayName = @"Playstation Rocker";
    [pickerLabelButtonGroup addLabel:[[NSAttributedString alloc] initWithString:@"VOL"
                                                                     attributes:[self.buttonBuilder
                                                  buttonTitleAttributesWithFontName:nil
                                                                           fontSize:0
                                                                        highlighted:NO]]
                      withCommandSet:rockerButtonVolumeCommandSet];

    return pickerLabelButtonGroup;
}

- (PickerLabelButtonGroup *)constructSonosRocker {
    ComponentDevice * avReceiver                   = [ComponentDevice fetchComponentDeviceWithName:@"AV Receiver" inContext:self.buildContext];
    RockerButton    * rockerButtonVolumeCommandSet = [RockerButton newRockerButtonInContext:self.buildContext];
    IRCode          * irCode                       = [avReceiver codeWithName:@"Volume Up"];

    [rockerButtonVolumeCommandSet setCommandFromIRCode:irCode forKey:kRockerButtonPlusButtonKey];
    irCode = [avReceiver codeWithName:@"Volume Down"];
    [rockerButtonVolumeCommandSet setCommandFromIRCode:irCode forKey:kRockerButtonMinusButtonKey];

    PickerLabelButtonGroup * pickerLabelButtonGroup = [self rawRocker];

    pickerLabelButtonGroup.displayName = @"Sonos Rocker";
    [pickerLabelButtonGroup addLabel:[[NSAttributedString alloc] initWithString:@"VOL"
                                                                     attributes:[self.buttonBuilder
                                                  buttonTitleAttributesWithFontName:nil
                                                                           fontSize:0
                                                                        highlighted:NO]]
                      withCommandSet:rockerButtonVolumeCommandSet];

    return pickerLabelButtonGroup;
}

#pragma mark - Constructing other button groups
/// @name ￼Constructing other button groups

- (ButtonGroup *)constructSonosMuteButtonGroup {
    ComponentDevice     * avReceiver            = [ComponentDevice fetchComponentDeviceWithName:@"AV Receiver" inContext:self.buildContext];
    ButtonGroup         * muteButtonGroup       = MakeButtonGroup(@"displayName" : @"Mute Button", @"key" : @"mute");
    NSMutableDictionary * attributesHighlighted = [@{}
                                                   mutableCopy];
    NSDictionary       * attributesNormal = [self.buttonBuilder buttonTitleAttributesWithFontName:kDefaultFontName fontSize:16.0 highlighted:attributesHighlighted];
    NSAttributedString * attrStrNormal    = [[NSAttributedString alloc] initWithString:@"Mute"
                                                                            attributes:attributesNormal];
    NSAttributedString * attrStrHighlighted = [[NSAttributedString alloc] initWithString:@"Mute"
                                                                              attributes:attributesHighlighted];
    Button * button = MakeButton(@"command" :[SendIRCommand sendIRCommandWithIRCode:[avReceiver codeWithName:@"Mute"]],
                                 @"shape" : @(ButtonShapeRoundedRectangle),
                                 @"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                 @"displayName" : @"Mute",
                                 @"titles" : MakeTitleSet(@{@0 : attrStrNormal, @1 : attrStrHighlighted}
                                                          ),
                                 @"key" : @"muteButton");

    [muteButtonGroup addSubelementsObject:button];

    // TODO: Add alignment and resizing options for buttons

    NSString     * constraints = @"button.centerX = muteButtonGroup.centerX\nbutton.centerY = muteButtonGroup.centerY\nbutton.width = muteButtonGroup.width\nbutton.height = muteButtonGroup.height\nmuteButtonGroup.width ≥ 132";
    NSDictionary * identifiers = NSDictionaryOfVariableBindingsToIdentifiers(muteButtonGroup, button);

    [muteButtonGroup.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    return muteButtonGroup;
}

- (ButtonGroup *)constructSelectionPanel {
    /* Create selection panel button group */
    ButtonGroup * selectionPanel = MakeElement(@"displayName" : @"Configuration Selection Panel",
                                               @"type" : @(ButtonGroupTypeSelectionPanel),
                                               @"subtype" : @(ButtonGroupPanelLocationRight),
                                               @"backgroundColor" : FlipsideColor,
                                               @"key" : kRightPanelOneKey);
    NSMutableDictionary * attributesSelected = [@{}
                                                mutableCopy];
    NSDictionary * attributesNormal = [self.buttonBuilder buttonTitleAttributesWithFontName:kDefaultFontName fontSize:48 highlighted:attributesSelected];
// attributesSelected[NSForegroundColorAttributeName] = defaultTitleHighlightColor();
    NSAttributedString * attrStrNormal = [[NSAttributedString alloc] initWithString:@"STB"
                                                                         attributes:attributesNormal];
    NSAttributedString * attrStrSelected = [[NSAttributedString alloc] initWithString:@"STB"
                                                                           attributes:attributesSelected];
    Button * stbButton = MakeButton(@"displayName" : @"Select Set Top Box",
                                    @"titles" : MakeTitleSet(@{@0 : attrStrNormal, @(UIControlStateSelected) : attrStrSelected, @1 : attrStrSelected}
                                                             ),
                                    @"key" : kDefaultConfiguration);

    attrStrNormal = [[NSAttributedString alloc] initWithString:@"TV"
                                                    attributes:attributesNormal];
    attrStrSelected = [[NSAttributedString alloc] initWithString:@"TV"
                                                      attributes:attributesSelected];

    Button * tvButton = MakeButton(@"displayName" : @"Select Samsung TV",
                                   @"titles" : MakeTitleSet(@{@0 : attrStrNormal, @(UIControlStateSelected) : attrStrSelected, @1 : attrStrSelected}
                                                            ),
                                   @"key" : kTVConfiguration);

    [selectionPanel addSubelements:[@[stbButton, tvButton] orderedSet]];

    // TODO: Add alignment and sizing options for buttons
    NSDictionary * identifiers =
        NSDictionaryOfVariableBindingsToIdentifiers(selectionPanel, tvButton, stbButton);
    NSString * constraints =
        @"selectionPanel.width = 150\n"
        "selectionPanel.height ≥ 240\n"
        "tvButton.width = selectionPanel.width\n"
        "stbButton.width = selectionPanel.width\n"
        "tvButton.centerX = selectionPanel.centerX\n"
        "stbButton.centerX = selectionPanel.centerX\n"
        "stbButton.top = selectionPanel.top\n"
        "tvButton.bottom = selectionPanel.bottom\n"
        "stbButton.bottom = tvButton.top\n"
        "tvButton.height = stbButton.height";

    [selectionPanel.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    return selectionPanel;
}  /* constructSelectionPanel */

- (ButtonGroup *)rawGroupOfThreeButtons {
    // Create button group with three vertically aligned buttons
    ButtonGroup * buttonGroup = MakeButtonGroup(@"key" : @"oneByThree",
                                                @"displayName" : @"1x3");

    // Create first button
    Button * button1 = MakeButton(@"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                  @"shape" : @(ButtonShapeRoundedRectangle),
                                  @"key" : @"button1",
                                  @"displayName" : @"button1");

    // Create second button
    Button * button2 = MakeButton(@"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                  @"shape" : @(ButtonShapeRoundedRectangle),
                                  @"key" : @"button2",
                                  @"displayName" : @"button2");

    // Create third button
    Button * button3 = MakeButton(@"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                  @"shape" : @(ButtonShapeRoundedRectangle),
                                  @"key" : @"button3",
                                  @"displayName" : @"button3");

    [buttonGroup addSubelements:[@[button1, button2, button3] orderedSet]];

    // TODO: Add alignment and sizing options for buttons

    NSDictionary * identifiers = NSDictionaryOfVariableBindingsToIdentifiers(buttonGroup, button1, button2, button3);
    NSString     * constraints =
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
        "buttonGroup.height ≥ 150";

    [buttonGroup.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    return buttonGroup;
}

- (ButtonGroup *)constructDVRGroupOfThreeButtons {
    ComponentDevice * comcastDVR  = [ComponentDevice fetchComponentDeviceWithName:@"Comcast DVR" inContext:self.buildContext];
    ComponentDevice * samsungTV   = [ComponentDevice fetchComponentDeviceWithName:@"Samsung TV" inContext:self.buildContext];
    ButtonGroup     * buttonGroup = [self rawGroupOfThreeButtons];

    buttonGroup.displayName = @"One x Three Button Group";

    // Configure "Guide" button and its delegate
    Button * guideButton = [buttonGroup buttonWithKey:@"button1"];

    guideButton.key         = @"guide/tools";
    guideButton.displayName = @"Guide / Tools";

    NSMutableDictionary * attributesHighlighted = [@{}
                                                   mutableCopy];
    NSDictionary       * attributesNormal = [self.buttonBuilder buttonTitleAttributesWithFontName:kDefaultFontName fontSize:18.0 highlighted:attributesHighlighted];
    NSAttributedString * attrStrNormal    = [[NSAttributedString alloc] initWithString:@"Guide"
                                                                            attributes:attributesNormal];
    NSAttributedString * attrStrHighlighted = [[NSAttributedString alloc] initWithString:@"Guide"
                                                                              attributes:attributesHighlighted];
    ControlStateTitleSet        * titleSet                    = [ControlStateTitleSet titleSetForButton:guideButton];
    ButtonConfigurationDelegate * buttonConfigurationDelegate =
        [ButtonConfigurationDelegate buttonConfigurationDelegateForButton:guideButton];

    [titleSet setTitle:attrStrNormal forState:UIControlStateNormal];
    [titleSet setTitle:attrStrHighlighted forState:UIControlStateHighlighted];
    [buttonConfigurationDelegate registerTitleSet:titleSet forConfiguration:kDefaultConfiguration];

    IRCode        * irCode = [comcastDVR codeWithName:@"Guide"];
    SendIRCommand * sendIR = [SendIRCommand sendIRCommandWithIRCode:irCode];

    [buttonConfigurationDelegate registerCommand:sendIR forConfiguration:kDefaultConfiguration];
    guideButton.command = sendIR;

    attrStrNormal      = [[NSAttributedString alloc] initWithString:@"Tools" attributes:attributesNormal];
    attrStrHighlighted = [[NSAttributedString alloc] initWithString:@"Tools" attributes:attributesHighlighted];
    titleSet           = [ControlStateTitleSet titleSetForButton:guideButton];
    [titleSet setTitle:attrStrNormal forState:UIControlStateNormal];
    [titleSet setTitle:attrStrHighlighted forState:UIControlStateHighlighted];
    [buttonConfigurationDelegate registerTitleSet:titleSet forConfiguration:kTVConfiguration];
    irCode = [samsungTV codeWithName:@"Tools"];
    sendIR = [SendIRCommand sendIRCommandWithIRCode:irCode];
    [buttonConfigurationDelegate registerCommand:sendIR forConfiguration:kTVConfiguration];

    // Configure "DVR" button and add its delegate
    Button * dvrButton = [buttonGroup buttonWithKey:@"button2"];

    dvrButton.key         = @"dvr/internet@tv";
    dvrButton.displayName = @"DVR / Internet@TV";

    attrStrNormal               = [[NSAttributedString alloc] initWithString:@"DVR" attributes:attributesNormal];
    attrStrHighlighted          = [[NSAttributedString alloc] initWithString:@"DVR" attributes:attributesHighlighted];
    irCode                      = [comcastDVR codeWithName:@"DVR"];
    sendIR                      = [SendIRCommand sendIRCommandWithIRCode:irCode];
    buttonConfigurationDelegate =
        [ButtonConfigurationDelegate buttonConfigurationDelegateForButton:dvrButton];
    titleSet = [ControlStateTitleSet titleSetForButton:dvrButton];
    [titleSet setTitle:attrStrNormal forState:UIControlStateNormal];
    [titleSet setTitle:attrStrHighlighted forState:UIControlStateHighlighted];
    [buttonConfigurationDelegate registerTitleSet:titleSet forConfiguration:kDefaultConfiguration];
    [buttonConfigurationDelegate registerCommand:sendIR forConfiguration:kDefaultConfiguration];
    dvrButton.command = sendIR;
    irCode            = [samsungTV codeWithName:@"Internet@TV"];
    sendIR            = [SendIRCommand sendIRCommandWithIRCode:irCode];

    attrStrNormal      = [[NSAttributedString alloc] initWithString:@"Internet@TV" attributes:attributesNormal];
    attrStrHighlighted = [[NSAttributedString alloc] initWithString:@"Internet@TV" attributes:attributesHighlighted];

    titleSet = [ControlStateTitleSet titleSetForButton:dvrButton];
    [titleSet setTitle:attrStrNormal forState:UIControlStateNormal];
    [titleSet setTitle:attrStrHighlighted forState:UIControlStateHighlighted];
    [buttonConfigurationDelegate registerTitleSet:titleSet forConfiguration:kTVConfiguration];
    [buttonConfigurationDelegate registerCommand:sendIR forConfiguration:kTVConfiguration];

    // Configure "Info" button and its delegate
    Button * infoButton = [buttonGroup buttonWithKey:@"button3"];

    infoButton.key         = @"info";
    infoButton.displayName = @"Info";

    attrStrNormal               = [[NSAttributedString alloc] initWithString:@"Info" attributes:attributesNormal];
    attrStrHighlighted          = [[NSAttributedString alloc] initWithString:@"Info" attributes:attributesHighlighted];
    buttonConfigurationDelegate =
        [ButtonConfigurationDelegate buttonConfigurationDelegateForButton:infoButton];
    irCode = [comcastDVR codeWithName:@"Info"];
    sendIR = [SendIRCommand sendIRCommandWithIRCode:irCode];

    titleSet = [ControlStateTitleSet titleSetForButton:infoButton];
    [titleSet setTitle:attrStrNormal forState:UIControlStateNormal];
    [titleSet setTitle:attrStrHighlighted forState:UIControlStateHighlighted];
    [buttonConfigurationDelegate registerTitleSet:titleSet forConfiguration:kDefaultConfiguration];
    [buttonConfigurationDelegate registerCommand:sendIR forConfiguration:kDefaultConfiguration];
    infoButton.command = sendIR;
    irCode             = [samsungTV codeWithName:@"Info"];
    sendIR             = [SendIRCommand sendIRCommandWithIRCode:irCode];

    [buttonConfigurationDelegate registerTitleSet:titleSet forConfiguration:kTVConfiguration];
    [buttonConfigurationDelegate registerCommand:sendIR forConfiguration:kTVConfiguration];

    return buttonGroup;
}  /* constructDVRGroupOfThreeButtons */

- (ButtonGroup *)constructPS3GroupOfThreeButtons {
    ComponentDevice * ps3           = [ComponentDevice fetchComponentDeviceWithName:@"PS3" inContext:self.buildContext];
    ButtonGroup     * buttonGroup   = [self rawGroupOfThreeButtons];
    Button          * displayButton = [buttonGroup buttonWithKey:@"button1"];

    displayButton.key         = @"display";
    displayButton.displayName = @"Display";

    NSMutableDictionary * attributesHighlighted = [@{}
                                                   mutableCopy];
    NSDictionary       * attributesNormal = [self.buttonBuilder buttonTitleAttributesWithFontName:kDefaultFontName fontSize:18.0 highlighted:attributesHighlighted];
    NSAttributedString * attrStrNormal    = [[NSAttributedString alloc] initWithString:@"Display"
                                                                            attributes:attributesNormal];

    [displayButton setTitle:attrStrNormal forState:UIControlStateNormal];

    IRCode        * irCode = [ps3 codeWithName:@"Display"];
    SendIRCommand * sendIR = [SendIRCommand sendIRCommandWithIRCode:irCode];

    displayButton.command = sendIR;

    Button * topMenuButton = [buttonGroup buttonWithKey:@"button2"];

    topMenuButton.key         = @"topMenu";
    topMenuButton.displayName = @"Top Menu";
    attrStrNormal             = [[NSAttributedString alloc] initWithString:@"Top Menu"
                                                                attributes:attributesNormal];
    [topMenuButton setTitle:attrStrNormal forState:UIControlStateNormal];
    irCode                = [ps3 codeWithName:@"Top Menu"];
    sendIR                = [SendIRCommand sendIRCommandWithIRCode:irCode];
    topMenuButton.command = sendIR;

    Button * popupMenuButton = [buttonGroup buttonWithKey:@"button3"];

    popupMenuButton.key         = @"popupMenu";
    popupMenuButton.displayName = @"Popup Menu";
    attrStrNormal               = [[NSAttributedString alloc] initWithString:@"Popup Menu"
                                                                  attributes:attributesNormal];
    [popupMenuButton setTitle:attrStrNormal forState:UIControlStateNormal];
    irCode                  = [ps3 codeWithName:@"Popup Menu"];
    sendIR                  = [SendIRCommand sendIRCommandWithIRCode:irCode];
    popupMenuButton.command = sendIR;

    return buttonGroup;
}

- (ButtonGroup *)rawButtonPanel {
    ButtonGroup * buttonGroup = MakeButtonGroup(@"key" : @"buttons",
                                                @"displayName" : @"buttons",
                                                @"backgroundColor" :[kPanelBackgroundColor colorWithAlphaComponent:0.75]);
    Button * button1 = MakeButton(@"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                  @"shape" : @(ButtonShapeRoundedRectangle),
                                  @"key" : @"button1", @"displayName" : @"button1");
    Button * button2 = MakeButton(@"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                  @"shape" : @(ButtonShapeRoundedRectangle),
                                  @"key" : @"button2", @"displayName" : @"button2");
    Button * button3 = MakeButton(@"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                  @"shape" : @(ButtonShapeRoundedRectangle),
                                  @"key" : @"button3", @"displayName" : @"button3");
    Button * button4 = MakeButton(@"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                  @"shape" : @(ButtonShapeRoundedRectangle),
                                  @"key" : @"button4", @"displayName" : @"button4");
    Button * button5 = MakeButton(@"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                  @"shape" : @(ButtonShapeRoundedRectangle),
                                  @"key" : @"button5", @"displayName" : @"button5");
    Button * button6 = MakeButton(@"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                  @"shape" : @(ButtonShapeRoundedRectangle),
                                  @"key" : @"button6", @"displayName" : @"button6");
    Button * button7 = MakeButton(@"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                  @"shape" : @(ButtonShapeRoundedRectangle),
                                  @"key" : @"button7", @"displayName" : @"button7");
    Button * button8 = MakeButton(@"key" : @"button8", @"displayName" : @"button8");

    [buttonGroup addSubelements:[@[button1, button2, button3, button4, button5, button6, button7, button8] orderedSet]];

    // TODO: Replace with extended visual format
    NSString * constraints =
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
        "buttonGroup.width = 150";
    NSDictionary * identifiers = NSDictionaryOfVariableBindingsToIdentifiers(buttonGroup, button1, button2, button3, button4, button5, button6, button7, button8);

    [buttonGroup.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    return buttonGroup;
}  /* rawButtonPanel */

- (ButtonGroup *)constructHomeAndPowerButtonsForActivity:(NSInteger)activity {
    ButtonGroup * buttonGroup = MakeButtonGroup(@"displayName" : @"Home and Power Buttons",
                                                @"key" : @"homeAndPowerButtonGroup");
    Button * homeButton = MakeButton(@"shape" : @(ButtonShapeOval),
                                     @"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                     @"displayName" : @"Home Button",
                                     @"key" : @"homeButton",
                                     @"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor, @1 : kHighlightColor}
                                                                              ), @{@0 : MakeIconImage(140)}
                                                                 ),
                                     @"command" : MakeSwitchCommand(MSRemoteControllerHomeRemoteKeyName));
    ActivityButton * powerButton = MakeElement(@"type" : @(ButtonTypeActivityButton),
                                               @"type" : @(ActivityButtonTypeEnd),
                                               @"shape" : @(ButtonShapeOval),
                                               @"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
                                               @"displayName" : @"Power Off and Exit Activity",
                                               @"key" :[NSString stringWithFormat:@"activity%i", activity],
                                               @"icons" : MakeIconImageSet(MakeColorSet(@{@0 : WhiteColor, @1 : kHighlightColor}
                                                                                        ), @{@0 : MakeIconImage(168)}
                                                                           ),
                                               @"command" :[self.macroBuilder activityMacroForActivity:activity toInitiateState:NO switchIndex:NULL]);

    [buttonGroup addSubelements:[@[homeButton, powerButton] orderedSet]];

    // TODO: Add alignment and sizing options for buttons

    NSString * constraints =
        @"homeButton.width = 50\n"
        "homeButton.height = homeButton.width";
    NSDictionary * identifiers = NSDictionaryOfVariableBindingsToIdentifiers(buttonGroup, powerButton, homeButton);

    [homeButton.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];
    constraints =
        @"powerButton.width = 50\n"
        "powerButton.height = powerButton.width";
    [powerButton.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];
    constraints =
        @"buttonGroup.width = 300\n"
        "buttonGroup.height = 50\n"
        "homeButton.left = buttonGroup.left\n"
        "powerButton.right = buttonGroup.right\n"
        "homeButton.centerY = buttonGroup.centerY\n"
        "powerButton.centerY = buttonGroup.centerY";
    [buttonGroup.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    return buttonGroup;
}

- (ButtonGroup *)constructAdditionalButtonsLeft {
    ComponentDevice * avReceiver  = [ComponentDevice fetchComponentDeviceWithName:@"AV Receiver" inContext:self.buildContext];
    ComponentDevice * samsungTV   = [ComponentDevice fetchComponentDeviceWithName:@"Samsung TV" inContext:self.buildContext];
    ComponentDevice * comcastDVR  = [ComponentDevice fetchComponentDeviceWithName:@"Comcast DVR" inContext:self.buildContext];
    ButtonGroup     * buttonGroup = [self rawButtonPanel];

    buttonGroup.panelLocation = ButtonGroupPanelLocationLeft;
    buttonGroup.key           = kLeftPanelOneKey;
    buttonGroup.displayName   = @"Left Overlay Panel";

    NSMutableDictionary * attributesHighlighted = [@{}
                                                   mutableCopy];
    NSMutableDictionary * attributesNormal = [self.buttonBuilder buttonTitleAttributesWithFontName:kDefaultFontName fontSize:15.0 highlighted:attributesHighlighted];
    NSAttributedString  * attrStrNormal    = [[NSAttributedString alloc] initWithString:@"On Demand"
                                                                             attributes:attributesNormal];
    NSAttributedString * attrStrHighlighted = [[NSAttributedString alloc] initWithString:@"On Demand"
                                                                              attributes:attributesHighlighted];
    Button               * button   = [buttonGroup buttonWithKey:@"button1"];
    ControlStateTitleSet * titleSet = [ControlStateTitleSet titleSetForButton:button];

    [titleSet setTitle:attrStrNormal forState:UIControlStateNormal];
    [titleSet setTitle:attrStrHighlighted forState:UIControlStateHighlighted];

    ButtonConfigurationDelegate * buttonConfigurationDelegate =
        [ButtonConfigurationDelegate buttonConfigurationDelegateForButton:button];

    button.displayName = @"On Demand / Source";

    // [button setTitle:attrStrNormal forState:UIControlStateNormal];
    IRCode        * irCode = [comcastDVR codeWithName:@"On Demand"];
    SendIRCommand * sendIR = [SendIRCommand sendIRCommandWithIRCode:irCode];

    [buttonConfigurationDelegate registerTitleSet:titleSet forConfiguration:kDefaultConfiguration];
    [buttonConfigurationDelegate registerCommand:sendIR forConfiguration:kDefaultConfiguration];
    button.command     = sendIR;
    irCode             = [samsungTV codeWithName:@"Source"];
    sendIR             = [SendIRCommand sendIRCommandWithIRCode:irCode];
    attrStrNormal      = [[NSAttributedString alloc] initWithString:@"Source" attributes:attributesNormal];
    attrStrHighlighted = [[NSAttributedString alloc] initWithString:@"Source" attributes:attributesHighlighted];
    titleSet           = [ControlStateTitleSet titleSetForButton:button];
    [titleSet setTitle:attrStrNormal forState:UIControlStateNormal];
    [titleSet setTitle:attrStrHighlighted forState:UIControlStateHighlighted];
    [buttonConfigurationDelegate registerTitleSet:titleSet forConfiguration:kTVConfiguration];
    [buttonConfigurationDelegate registerCommand:sendIR forConfiguration:kTVConfiguration];

    button                      = [buttonGroup buttonWithKey:@"button2"];
    button.displayName          = @"Menu";
    buttonConfigurationDelegate =
        [ButtonConfigurationDelegate buttonConfigurationDelegateForButton:button];
    attrStrNormal      = [[NSAttributedString alloc] initWithString:@"Menu" attributes:attributesNormal];
    attrStrHighlighted = [[NSAttributedString alloc] initWithString:@"Menu" attributes:attributesHighlighted];
    // [button setTitle:attrStrNormal forState:UIControlStateNormal];
    irCode   = [comcastDVR codeWithName:@"Menu"];
    sendIR   = [SendIRCommand sendIRCommandWithIRCode:irCode];
    titleSet = [ControlStateTitleSet titleSetForButton:button];
    [titleSet setTitle:attrStrNormal forState:UIControlStateNormal];
    [titleSet setTitle:attrStrHighlighted forState:UIControlStateHighlighted];
    [buttonConfigurationDelegate registerTitleSet:titleSet forConfiguration:kDefaultConfiguration];
    [buttonConfigurationDelegate registerCommand:sendIR forConfiguration:kDefaultConfiguration];
    button.command = sendIR;
    irCode         = [samsungTV codeWithName:@"Menu"];
    sendIR         = [SendIRCommand sendIRCommandWithIRCode:irCode];
    [buttonConfigurationDelegate registerTitleSet:titleSet forConfiguration:kTVConfiguration];
    [buttonConfigurationDelegate registerCommand:sendIR forConfiguration:kTVConfiguration];

    button                      = [buttonGroup buttonWithKey:@"button3"];
    button.displayName          = @"Last / Return";
    buttonConfigurationDelegate =
        [ButtonConfigurationDelegate buttonConfigurationDelegateForButton:button];
    attrStrNormal      = [[NSAttributedString alloc] initWithString:@"Last" attributes:attributesNormal];
    attrStrHighlighted = [[NSAttributedString alloc] initWithString:@"Last" attributes:attributesHighlighted];
    // [button setTitle:attrStrNormal forState:UIControlStateNormal];
    irCode   = [comcastDVR codeWithName:@"Last"];
    sendIR   = [SendIRCommand sendIRCommandWithIRCode:irCode];
    titleSet = [ControlStateTitleSet titleSetForButton:button];
    [titleSet setTitle:attrStrNormal forState:UIControlStateNormal];
    [titleSet setTitle:attrStrHighlighted forState:UIControlStateHighlighted];
    [buttonConfigurationDelegate registerTitleSet:titleSet forConfiguration:kDefaultConfiguration];
    [buttonConfigurationDelegate registerCommand:sendIR forConfiguration:kDefaultConfiguration];
    button.command     = sendIR;
    irCode             = [samsungTV codeWithName:@"Return"];
    sendIR             = [SendIRCommand sendIRCommandWithIRCode:irCode];
    attrStrNormal      = [[NSAttributedString alloc] initWithString:@"Return" attributes:attributesNormal];
    attrStrHighlighted = [[NSAttributedString alloc] initWithString:@"Return" attributes:attributesHighlighted];
    titleSet           = [ControlStateTitleSet titleSetForButton:button];
    [titleSet setTitle:attrStrNormal forState:UIControlStateNormal];
    [titleSet setTitle:attrStrHighlighted forState:UIControlStateHighlighted];
    [buttonConfigurationDelegate registerTitleSet:titleSet forConfiguration:kTVConfiguration];
    [buttonConfigurationDelegate registerCommand:sendIR forConfiguration:kTVConfiguration];

    button                      = [buttonGroup buttonWithKey:@"button4"];
    button.displayName          = @"Exit";
    buttonConfigurationDelegate =
        [ButtonConfigurationDelegate buttonConfigurationDelegateForButton:button];
    attrStrNormal      = [[NSAttributedString alloc] initWithString:@"Exit" attributes:attributesNormal];
    attrStrHighlighted = [[NSAttributedString alloc] initWithString:@"Exit" attributes:attributesHighlighted];
    // [button setTitle:attrStrNormal forState:UIControlStateNormal];
    irCode   = [comcastDVR codeWithName:@"Exit"];
    sendIR   = [SendIRCommand sendIRCommandWithIRCode:irCode];
    titleSet = [ControlStateTitleSet titleSetForButton:button];
    [titleSet setTitle:attrStrNormal forState:UIControlStateNormal];
    [titleSet setTitle:attrStrHighlighted forState:UIControlStateHighlighted];
    [buttonConfigurationDelegate registerTitleSet:titleSet forConfiguration:kDefaultConfiguration];
    [buttonConfigurationDelegate registerCommand:sendIR forConfiguration:kDefaultConfiguration];
    button.command = sendIR;
    irCode         = [samsungTV codeWithName:@"Exit"];
    sendIR         = [SendIRCommand sendIRCommandWithIRCode:irCode];
    [buttonConfigurationDelegate registerTitleSet:titleSet forConfiguration:kTVConfiguration];
    [buttonConfigurationDelegate registerCommand:sendIR forConfiguration:kTVConfiguration];

    button             = [buttonGroup buttonWithKey:@"button5"];
    button.displayName = @"DVR Audio Input";
    attrStrNormal      = [[NSAttributedString alloc] initWithString:@"DVR Audio" attributes:attributesNormal];
    attrStrHighlighted = [[NSAttributedString alloc] initWithString:@"DVR Audio" attributes:attributesHighlighted];
    [button setTitle:attrStrNormal forState:UIControlStateNormal];
    [button setTitle:attrStrHighlighted forState:UIControlStateHighlighted];
    irCode         = [avReceiver codeWithName:@"TV/SAT"];
    sendIR         = [SendIRCommand sendIRCommandWithIRCode:irCode];
    button.command = sendIR;

    button             = [buttonGroup buttonWithKey:@"button6"];
    button.displayName = @"TV Audio Input";
    attrStrNormal      = [[NSAttributedString alloc] initWithString:@"TV Audio" attributes:attributesNormal];
    attrStrHighlighted = [[NSAttributedString alloc] initWithString:@"TV Audio" attributes:attributesHighlighted];
    [button setTitle:attrStrNormal forState:UIControlStateNormal];
    [button setTitle:attrStrHighlighted forState:UIControlStateHighlighted];
    irCode         = [avReceiver codeWithName:@"Video 3"];
    sendIR         = [SendIRCommand sendIRCommandWithIRCode:irCode];
    button.command = sendIR;

    button             = [buttonGroup buttonWithKey:@"button7"];
    button.displayName = @"Mute";
    attrStrNormal      = [[NSAttributedString alloc] initWithString:@"Mute" attributes:attributesNormal];
    attrStrHighlighted = [[NSAttributedString alloc] initWithString:@"Mute" attributes:attributesHighlighted];
    [button setTitle:attrStrNormal forState:UIControlStateNormal];
    [button setTitle:attrStrHighlighted forState:UIControlStateHighlighted];
    irCode         = [avReceiver codeWithName:@"Mute"];
    sendIR         = [SendIRCommand sendIRCommandWithIRCode:irCode];
    button.command = sendIR;

    button             = [buttonGroup buttonWithKey:@"button8"];
    button.displayName = @"Tuck Panel";
// [attributesHighlighted removeAllObjects];
    attributesNormal                                 = [self.buttonBuilder buttonTitleAttributesWithFontName:kArrowFontName fontSize:32.0 highlighted:attributesHighlighted];
    attributesNormal[NSForegroundColorAttributeName] = [UIColor colorWithWhite:0.0 alpha:0.5];
    attributesNormal[NSStrokeWidthAttributeName]     = @0;
    attrStrNormal                                    = [[NSAttributedString alloc] initWithString:kLeftArrow
                                                                                       attributes:attributesNormal];
    attributesHighlighted[NSStrokeWidthAttributeName] = @0;
    attrStrHighlighted                                = [[NSAttributedString alloc] initWithString:kLeftArrow attributes:attributesHighlighted];
    [button setTitle:attrStrNormal forState:UIControlStateNormal];
    [button setTitle:attrStrHighlighted forState:UIControlStateHighlighted];
    button.key   = kTuckButtonKey;
    button.style = 0;

    return buttonGroup;
}  /* constructAdditionalButtonsLeft */

- (ButtonBuilder *)buttonBuilder {
    if (!_buttonBuilder) self.buttonBuilder = [ButtonBuilder buttonBuilderWithContext:self.buildContext];

    return _buttonBuilder;
}

- (MacroBuilder *)macroBuilder {
    if (!_macroBuilder) self.macroBuilder = [MacroBuilder macroBuilderWithContext:self.buildContext];

    return _macroBuilder;
}

@end
