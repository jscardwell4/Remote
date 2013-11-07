//
// ButtonGroupBuilder+RawButtonGroups.m
// Remote
//
// Created by Jason Cardwell on 10/6/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteConstruction.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_BUILDING;
#pragma unused(ddLogLevel, msLogContext)

@implementation ButtonGroupBuilder (Developer)
////////////////////////////////////////////////////////////////////////////////
#pragma mark Top Toolbar
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)constructControllerTopToolbarInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [ButtonGroup buttonGroupWithRole:REButtonGroupRoleToolbar
                                                         context:moc];
    buttonGroup.name = @"Top Toolbar";

    Button * home = [Button buttonWithRole:REButtonRoleToolbar context:moc];
    home.name = @"Home Button";
    Command * command = [SystemCommand commandWithType:SystemCommandLaunchScreen
                                                 inContext:moc];
    home.command = command;

    ControlStateImageSet * icons = [ControlStateImageSet
                                    imageSetWithImages:@{@"normal":
                                                             @"7C7C50AF-6DD5-467C-A558-DCEB4B6A05A6"}
                                               context:moc];
    [home setIcons:icons mode:REDefaultMode];


    Button * settings = [Button buttonWithRole:REButtonRoleToolbar context:moc];
    settings.name = @"Settings Button";
    command = [SystemCommand commandWithType:SystemCommandOpenSettings inContext:moc];
    settings.command = command;
    icons = [ControlStateImageSet imageSetWithImages:@{@"normal":
                                                           @"2A778160-8A33-49B0-AE53-D9B45786FFA7"}
                                             context:moc];
    [settings setIcons:icons mode:REDefaultMode];

    Button * editRemote = [Button buttonWithRole:REButtonRoleToolbar context:moc];
    editRemote.name = @"Edit Remote Button";
    command = [SystemCommand commandWithType:SystemCommandOpenEditor inContext:moc];
    editRemote.command = command;
    icons = [ControlStateImageSet imageSetWithImages:@{@"normal":
                                                           @"1132E160-C278-406A-A6AD-3EF817DCAA4E"}
                                             context:moc];
    [editRemote setIcons:icons mode:REDefaultMode];

    Button * battery = [Button buttonWithRole:REButtonRoleBatteryStatus context:moc];

    Button * connection = [Button buttonWithRole:REButtonRoleConnectionStatus context:moc];

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

////////////////////////////////////////////////////////////////////////////////
#pragma mark Activities
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)constructActivitiesInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [ButtonGroup remoteElementInContext:moc];
    buttonGroup.themeFlags = REThemeNoBackground;

    Button * activity1 = [Button buttonWithTitle:@"Comcast\nDVR" context:moc];
    Activity * activity = [Activity MR_findFirstByAttribute:@"name"
                                                      withValue:@"Dish Hopper Activity"
                                                      inContext:moc];
    ActivityCommand * command = [ActivityCommand commandWithActivity:activity];
    activity1.command = command;

    Button * activity2 = [Button buttonWithTitle:@"Playstation" context:moc];
    activity = [Activity MR_findFirstByAttribute:@"name"
                                         withValue:@"Playstation Activity"
                                         inContext:moc];
    command = [ActivityCommand commandWithActivity:activity];
    activity2.command = command;

    Button * activity3 = [Button buttonWithTitle:@" TV" context:moc];
    activity = [Activity MR_findFirstByAttribute:@"name"
                                         withValue:@" TV Activity"
                                         inContext:moc];
    command = [ActivityCommand commandWithActivity:activity];
    activity3.command = command;

    Button * activity4 = [Button buttonWithTitle:@"Sonos" context:moc];
    activity = [Activity MR_findFirstByAttribute:@"name"
                                         withValue:@"Sonos Activity"
                                         inContext:moc];
    command = [ActivityCommand commandWithActivity:activity];
    activity4.command = command;

    [buttonGroup addSubelements:[@[activity1,
                                   activity2,
                                   activity3,
                                   activity4] orderedSet]];

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

    Preset * preset = [Preset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Light Controls
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)constructLightControlsInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [ButtonGroup buttonGroupWithRole:REButtonGroupRoleToolbar
                                                         context:moc];

    HTTPCommand * command = [HTTPCommand commandWithURL:@"http://10.0.1.27/0?1201=I=0"
                                                    context:moc];
    NSNumber * role = @(REButtonRoleToolbar);
    NSDictionary * colors = @{ @"normal" : WhiteColor, @"highlighted" : kHighlightColor };
    NSDictionary * icons = @{ @"normal" : @"A3110AD7-45A7-45BE-A2B5-67F9A3953D38" };
    NSNumber * flags = @(REThemeNoIcon);
    ControlStateImageSet * iconSet = [ControlStateImageSet imageSetWithColors:colors
                                                                       images:icons
                                                                      context:moc];
    Button * lightsOnButton = [Button remoteElementInContext:moc
                                                  attributes:@{ @"role"       : role,
                                                                @"command"    : command,
                                                                @"icons"      : iconSet,
                                                                @"themeFlags" : flags,
                                                                @"name"       : @"lights on" }];

    command = [HTTPCommand commandWithURL:@"http://10.0.1.27/0?1401=I=0" context:moc];
    colors = @{@"normal": GrayColor, @"highlighted": kHighlightColor };
    iconSet = [ControlStateImageSet imageSetWithColors:colors images:icons context:moc];

    Button * lightsOffButton = [Button remoteElementInContext:moc
                                                   attributes:@{ @"role"       : role,
                                                                 @"command"    : command,
                                                                 @"icons"      : iconSet,
                                                                 @"themeFlags" : flags,
                                                                 @"name"       : @"lights off" }];

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

    Preset * preset = [Preset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark DPad
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)constructDVRDPadInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [self dPadInContext:moc];
    buttonGroup.name = @"DVR Activity DPad";
    CommandSet * commandSet = [CommandSetBuilder dPadForDeviceWithName:@"Dish Hopper"
                                                                   context:moc];
    [buttonGroup setCommandContainer:commandSet mode:REDefaultMode];
    commandSet = [CommandSetBuilder dPadForDeviceWithName:@"Samsung TV" context:moc];
    [buttonGroup setCommandContainer:commandSet mode:kTVMode];

    return buttonGroup;
}

+ (ButtonGroup *)constructPS3DPadInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [self dPadInContext:moc];
    buttonGroup.name = @"Playstation Activity DPad";
    CommandSet * commandSet = [CommandSetBuilder dPadForDeviceWithName:@"PS3" context:moc];
    buttonGroup.commandContainer = commandSet;

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Number Pad
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)constructDVRNumberpadInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [self numberpadInContext:moc];
    buttonGroup.name = @"DVR Activity Number Pad";
    CommandSet * commandSet = [CommandSetBuilder numberpadForDeviceWithName:@"Dish Hopper"
                                                                        context:moc];
    buttonGroup.commandContainer = commandSet;

    return buttonGroup;
}

+ (ButtonGroup *)constructPS3NumberpadInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [self numberpadInContext:moc];
    buttonGroup.name = @"Playstation Activity Number Pad";
    CommandSet * commandSet = [CommandSetBuilder numberpadForDeviceWithName:@"PS3"
                                                                        context:moc];
    buttonGroup.commandContainer = commandSet;

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Transport
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)constructDVRTransportInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [self transportInContext:moc];
    buttonGroup.name = @"DVR Activity Transport";
    CommandSet * commandSet = [CommandSetBuilder transportForDeviceWithName:@"Dish Hopper"
                                                                        context:moc];
    [buttonGroup setCommandContainer:commandSet mode:REDefaultMode];
    commandSet = [CommandSetBuilder transportForDeviceWithName:@"Samsung TV" context:moc];
    [buttonGroup setCommandContainer:commandSet mode:kTVMode];

    return buttonGroup;
}

+ (ButtonGroup *)constructPS3TransportInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [self transportInContext:moc];
    buttonGroup.name = @"Playstation Activity Transport";
    CommandSet * commandSet = [CommandSetBuilder transportForDeviceWithName:@"PS3"
                                                                        context:moc];
    buttonGroup.commandContainer = commandSet;

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Rocker
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)constructDVRRockerInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [self rockerInContext:moc];
    buttonGroup.name = @"DVR Activity Rocker";
    CommandSetCollection * commandSetCollection = [CommandSetCollection commandContainerInContext:moc];
    CommandSet * commandSet = [CommandSetBuilder hopperChannelsCommandSet:moc];

    commandSetCollection[commandSet] = @"CH";
    commandSet = [CommandSetBuilder hopperPagingCommandSet:moc];
    commandSetCollection[commandSet] = @"PAGE";
    commandSet = [CommandSetBuilder avReceiverVolumeCommandSet:moc];
    commandSetCollection[commandSet] = @"VOL";

    [buttonGroup.groupConfigurationDelegate setCommandContainer:commandSetCollection mode:REDefaultMode];

    return buttonGroup;
}

+ (ButtonGroup *)constructPS3RockerInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [self rockerInContext:moc];
    buttonGroup.name = @"Playstation Activity Rocker";
    CommandSetCollection * commandSetCollection = [CommandSetCollection commandContainerInContext:moc];
    CommandSet * commandSet = [CommandSetBuilder avReceiverVolumeCommandSet:moc];
    commandSetCollection[commandSet] = @"VOL";

    [buttonGroup.groupConfigurationDelegate setCommandContainer:commandSetCollection mode:REDefaultMode];

    return buttonGroup;
}

+ (ButtonGroup *)constructSonosRockerInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [self rockerInContext:moc];
    buttonGroup.name = @"Sonos Activity Rocker";

    CommandSetCollection * commandSetCollection = [CommandSetCollection commandContainerInContext:moc];
    CommandSet * commandSet = [CommandSetBuilder avReceiverVolumeCommandSet:moc];
    commandSetCollection[commandSet] = @"VOL";

    [buttonGroup.groupConfigurationDelegate setCommandContainer:commandSetCollection mode:REDefaultMode];

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Sonos Group
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)constructSonosMuteButtonGroupInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [ButtonGroup remoteElementInContext:moc];
    buttonGroup.themeFlags = REThemeAll;

    ComponentDevice * avReceiver = [ComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:moc];
    Button * mute = [Button buttonWithTitle:@"Mute" context:moc];
    SendIRCommand * command = [SendIRCommand commandWithIRCode:avReceiver[@"Mute"]];
    mute.command = command;
    mute.name = @"Mute";

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

////////////////////////////////////////////////////////////////////////////////
#pragma mark Selection Panel
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)constructSelectionPanelInContext:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [ButtonGroup buttonGroupWithRole:REButtonGroupRoleSelectionPanel
                                                             context:moc];


    Button * stbButton = [Button buttonWithRole:REButtonRoleSelectionPanel
                                              title:@"STB"
                                            context:moc];
    stbButton.key = REDefaultMode;

    Button * tvButton = [Button buttonWithRole:REButtonRoleSelectionPanel
                                             title:@"TV"
                                           context:moc];
    tvButton.key = kTVMode;

    [buttonGroup addSubelements:[@[stbButton, tvButton] orderedSet]];


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

////////////////////////////////////////////////////////////////////////////////
#pragma mark 1x3
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)constructDVRGroupOfThreeButtonsInContext:(NSManagedObjectContext *)moc
{
    // fetch devices
    ComponentDevice * hopper = [ComponentDevice fetchDeviceWithName:@"Dish Hopper"
                                                                    context:moc];
    ComponentDevice * samsungTV = [ComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                   context:moc];

    // create button group
    ButtonGroup * buttonGroup = [self oneByThreeInContext:moc];
    buttonGroup.name = @"DVR Activity 1x3";

    // Configure "Guide" button and its delegate
    Button * guideButton = buttonGroup[0];
    guideButton.name = @"Guide / Tools";
    ControlStateTitleSet * titleSet = [ControlStateTitleSet
                                       controlStateSetInContext:moc
                                                    withObjects:@{@"normal" : @"Guide"}];
    [guideButton setTitles:titleSet mode:REDefaultMode];
    titleSet = [ControlStateTitleSet controlStateSetInContext:moc
                                                  withObjects:@{@"normal": @"Tools"}];
    [guideButton setTitles:titleSet mode:kTVMode];

    Command * command = [SendIRCommand commandWithIRCode:hopper[@"Guide"]];
    [guideButton setCommand:command mode:REDefaultMode];

    command = [SendIRCommand commandWithIRCode:samsungTV[@"Tools"]];
    [guideButton setCommand:command mode:kTVMode];

    // Configure "DVR" button and add its delegate
    Button * hopperButton = buttonGroup[1];
    hopperButton.name = @"DVR / Internet@TV";
    titleSet = [ControlStateTitleSet controlStateSetInContext:moc
                                                  withObjects:@{@"normal":@"DVR"}];
    [hopperButton setTitles:titleSet mode:REDefaultMode];
    titleSet = [ControlStateTitleSet controlStateSetInContext:moc
                                                  withObjects:@{@"normal":@"Internet@TV"}];
    [hopperButton setTitles:titleSet mode:kTVMode];

    command = [SendIRCommand commandWithIRCode:hopper[@"DVR"]];
    [hopperButton setCommand:command mode:REDefaultMode];

    command = [SendIRCommand commandWithIRCode:samsungTV[@"Internet@TV"]];
    [hopperButton setCommand:command mode:kTVMode];

    // Configure "Info" button and its delegate
    Button * infoButton = buttonGroup[2];
    infoButton.name = @"Info";

    titleSet = [ControlStateTitleSet controlStateSetInContext:moc
                                                  withObjects:@{@"normal" : @"Info"}];
    [infoButton setTitles:titleSet mode:REDefaultMode];
    [infoButton setTitles:[titleSet copy] mode:kTVMode];

    command = [SendIRCommand commandWithIRCode:hopper[@"Info"]];
    [infoButton setCommand:command mode:REDefaultMode];

    command = [SendIRCommand commandWithIRCode:samsungTV[@"Info"]];
    [infoButton setCommand:command mode:kTVMode];

    return buttonGroup;
}

+ (ButtonGroup *)constructPS3GroupOfThreeButtonsInContext:(NSManagedObjectContext *)moc
{
    // fetch device
    ComponentDevice * ps3 = [ComponentDevice fetchDeviceWithName:@"PS3" context:moc];

    // create button group
    ButtonGroup * buttonGroup = [self oneByThreeInContext:moc];
    buttonGroup.name = @"PS3 Activity 1x3";

    // configure buttons
    Button * displayButton = buttonGroup[0];
    displayButton.name = @"Display";
    displayButton.title = [NSAttributedString attributedStringWithString:@"Display"];
    displayButton.command = [SendIRCommand commandWithIRCode:ps3[@"Display"]];

    Button * topMenuButton = buttonGroup[1];
    topMenuButton.name = @"Top Menu";
    topMenuButton.title = [NSAttributedString attributedStringWithString:@"Top Menu"];
    topMenuButton.command = [SendIRCommand commandWithIRCode:ps3[@"Top Menu"]];

    Button * popupMenuButton = buttonGroup[2];
    popupMenuButton.name = @"Popup Menu";
    popupMenuButton.title = [NSAttributedString attributedStringWithString:@"Popup Menu"];
    popupMenuButton.command = [SendIRCommand commandWithIRCode:ps3[@"Popup Menu"]];

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Left Panel
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)constructAdditionalButtonsLeftInContext:(NSManagedObjectContext *)moc
{
    ComponentDevice * avReceiver = [ComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                context:moc];
    ComponentDevice * samsungTV = [ComponentDevice  fetchDeviceWithName:@"Samsung TV"
                                                                context:moc];
    ComponentDevice * hopper = [ComponentDevice fetchDeviceWithName:@"Dish Hopper"
                                                            context:moc];

    ButtonGroup * buttonGroup = [self verticalPanelInContext:moc];
    buttonGroup.name = @"Left Overlay Panel";

    Button * button = buttonGroup[0];
    button.name = @"On Demand / Source";
    [button setTitle:@"On Demand" mode:REDefaultMode];
    [button setTitle:@"Source" mode:kTVMode];

    Command * command = [SendIRCommand commandWithIRCode:hopper[@"On Demand"]];
    [button setCommand:command mode:REDefaultMode];
    command = [SendIRCommand commandWithIRCode:samsungTV[@"Source"]];
    [button setCommand:command mode:kTVMode];

    button = buttonGroup[1];
    button.name = @"Menu";
    [button setTitle:@"Menu" mode:REDefaultMode];

    command = [SendIRCommand commandWithIRCode:hopper[@"Menu"]];
    [button setCommand:command  mode:REDefaultMode];
    command = [SendIRCommand commandWithIRCode:samsungTV[@"Menu"]];
    [button setCommand:command  mode:kTVMode];

    button = buttonGroup[2];
    button.name = @"Last / Return";
    [button setTitle:@"Last" mode:REDefaultMode];
    [button setTitle:@"Return" mode:kTVMode];

    command = [SendIRCommand commandWithIRCode:hopper[@"Last"]];
    [button setCommand:command  mode:REDefaultMode];
    command = [SendIRCommand commandWithIRCode:samsungTV[@"Return"]];
    [button setCommand:command  mode:kTVMode];

    button = buttonGroup[3];
    button.name = @"Exit";
    [button setTitle:@"Exit" mode:REDefaultMode];

    command = [SendIRCommand commandWithIRCode:hopper[@"Exit"]];
    [button setCommand:command  mode:REDefaultMode];
    command = [SendIRCommand commandWithIRCode:samsungTV[@"Exit"]];
    [button setCommand:command  mode:kTVMode];

    button = buttonGroup[4];
    button.name = @"DVR Audio Input";
    [button setTitle:@"DVR Audio" mode:REDefaultMode];

    button.command = [SendIRCommand commandWithIRCode:avReceiver[@"TV/SAT"]];

    button = buttonGroup[5];
    button.name = @"TV Audio Input";
    [button setTitle:@"TV Audio" mode:REDefaultMode];

    button.command = [SendIRCommand commandWithIRCode:avReceiver[@"Video 3"]];

    button = buttonGroup[6];
    button.name = @"Mute";
    [button setTitle:@"Mute" mode:REDefaultMode];

    button.command = [SendIRCommand commandWithIRCode:avReceiver[@"Mute"]];

    button = buttonGroup[7];
    button.name = @"Tuck Panel";
    [button setTitle:kLeftArrow mode:REDefaultMode];

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Home and Power
////////////////////////////////////////////////////////////////////////////////
+ (ButtonGroup *)constructHomeAndPowerButtonsForActivity:(NSInteger)activity
                                                   context:(NSManagedObjectContext *)moc
{
    ButtonGroup * buttonGroup = [ButtonGroup remoteElementInContext:moc];
    buttonGroup.name = @"Home and Power Buttons";
    buttonGroup.themeFlags = REThemeNoBackground|REThemeNoStyle|REThemeNoShape;

    Button * homeButton = [Button remoteElementInContext:moc];
    homeButton.shape = REShapeOval;
    homeButton.name = @"Home Button";
    homeButton.themeFlags = REThemeNoShape;

    ControlStateImageSet * iconSet = [ControlStateImageSet
                                      imageSetWithImages:@{@"normal":
                                                            @"DC256402-D8A9-461A-A158-F60D0EF63EF7"}
                                                     context:moc];
    [homeButton setIcons:iconSet mode:REDefaultMode];


    Button * powerButton = [Button remoteElementInContext:moc];
    powerButton.shape = REShapeOval;
    powerButton.name = @"Power Off and Exit Activity";
    powerButton.key = $(@"activity%i", activity);
    powerButton.themeFlags = REThemeNoShape;

    iconSet = [ControlStateImageSet imageSetWithImages:@{@"normal":
                                                             @"0EA0C544-F7A7-4D69-BCB2-C3E6E8346BB8"}
                                               context:moc];
    [powerButton setIcons:iconSet mode:REDefaultMode];

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

@end
