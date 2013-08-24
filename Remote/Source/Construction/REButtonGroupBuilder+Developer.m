//
// REButtonGroupBuilder+RawButtonGroups.m
// Remote
//
// Created by Jason Cardwell on 10/6/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteConstruction.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_BUILDING;
#pragma unused(ddLogLevel, msLogContext)

@implementation REButtonGroupBuilder (Developer)
////////////////////////////////////////////////////////////////////////////////
#pragma mark Top Toolbar
////////////////////////////////////////////////////////////////////////////////
+ (REButtonGroup *)constructControllerTopToolbarInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [REButtonGroup buttonGroupWithType:REButtonGroupTypeToolbar
                                                             context:moc];
    buttonGroup.name = @"Top Toolbar";

    REButton * home = [REButton buttonWithType:REButtonTypeToolbar context:moc];
    home.name = @"Home Button";
    RECommand * command = [RESystemCommand commandWithType:RESystemCommandReturnToLaunchScreen
                                                 inContext:moc];
    home.command = command;

    REControlStateImageSet * icons = [REControlStateImageSet
                                          imageSetWithImages:@{@"normal": @"53-house"}
                                          context:moc];
    [home setIcons:icons configuration:REDefaultConfiguration];


    REButton * settings = [REButton buttonWithType:REButtonTypeToolbar context:moc];
    settings.name = @"Settings Button";
    command = [RESystemCommand commandWithType:RESystemCommandOpenSettings inContext:moc];
    settings.command = command;
    icons = [REControlStateImageSet imageSetWithImages:@{@"normal": @"19-gear"} context:moc];
    [settings setIcons:icons configuration:REDefaultConfiguration];

    REButton * editRemote = [REButton buttonWithType:REButtonTypeToolbar context:moc];
    editRemote.name = @"Edit Remote Button";
    command = [RESystemCommand commandWithType:RESystemCommandOpenEditor inContext:moc];
    editRemote.command = command;
    icons = [REControlStateImageSet imageSetWithImages:@{@"normal": @"187-pencil"} context:moc];
    [editRemote setIcons:icons configuration:REDefaultConfiguration];

    REButton * battery = [REButton buttonWithType:REButtonTypeBatteryStatus context:moc];

    REButton * connection = [REButton buttonWithType:REButtonTypeConnectionStatus context:moc];

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
+ (REButtonGroup *)constructActivitiesInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [REButtonGroup remoteElementInContext:moc];
    buttonGroup.themeFlags = REThemeNoBackground;

    REButton * activity1 = [REButton buttonWithTitle:@"Comcast\nDVR" context:moc];
    REActivity * activity = [REActivity MR_findFirstByAttribute:@"name"
                                                      withValue:@"Comcast DVR Activity"
                                                      inContext:moc];
    REActivityCommand * command = [REActivityCommand commandWithActivity:activity];
    activity1.command = command;

    REButton * activity2 = [REButton buttonWithTitle:@"Playstation" context:moc];
    activity = [REActivity MR_findFirstByAttribute:@"name"
                                         withValue:@"Playstation Activity"
                                         inContext:moc];
    command = [REActivityCommand commandWithActivity:activity];
    activity2.command = command;

    REButton * activity3 = [REButton buttonWithTitle:@" TV" context:moc];
    activity = [REActivity MR_findFirstByAttribute:@"name"
                                         withValue:@" TV Activity"
                                         inContext:moc];
    command = [REActivityCommand commandWithActivity:activity];
    activity3.command = command;

    REButton * activity4 = [REButton buttonWithTitle:@"Sonos" context:moc];
    activity = [REActivity MR_findFirstByAttribute:@"name"
                                         withValue:@"Sonos Activity"
                                         inContext:moc];
    command = [REActivityCommand commandWithActivity:activity];
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

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Light Controls
////////////////////////////////////////////////////////////////////////////////
+ (REButtonGroup *)constructLightControlsInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [REButtonGroup buttonGroupWithType:REButtonGroupTypeToolbar
                                                             context:moc];

    REHTTPCommand * command = [REHTTPCommand commandWithURL:@"http://10.0.1.27/0?1201=I=0"
                                                    context:moc];
    NSNumber * type = @(REButtonTypeToolbar);
    NSDictionary * colors = @{ @"normal" : WhiteColor, @"highlighted" : kHighlightColor };
    NSDictionary * icons = @{ @"normal" : @"306-light-switch" };
    NSNumber * flags = @(REThemeNoIcon);
    REControlStateImageSet * iconSet = [REControlStateImageSet imageSetWithColors:colors
                                                                           images:icons
                                                                          context:moc];
    REButton * lightsOnButton = [REButton remoteElementInContext:moc
                                                      attributes:@{ @"type"       : type,
                                                                    @"command"    : command,
                                                                    @"icons"      : iconSet,
                                                                    @"themeFlags" : flags,
                                                                    @"name"       : @"lights on" }];

    command = [REHTTPCommand commandWithURL:@"http://10.0.1.27/0?1401=I=0" context:moc];
    colors = @{@"normal": GrayColor, @"highlighted": kHighlightColor };
    iconSet = [REControlStateImageSet imageSetWithColors:colors images:icons context:moc];

    REButton * lightsOffButton = [REButton remoteElementInContext:moc
                                                       attributes:@{ @"type"       : type,
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

    BOButtonGroupPreset * preset = [BOButtonGroupPreset presetWithElement:buttonGroup];
    assert(preset);

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark DPad
////////////////////////////////////////////////////////////////////////////////
+ (REButtonGroup *)constructDVRDPadInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [self dPadInContext:moc];
    buttonGroup.name = @"DVR Activity DPad";
    RECommandSet * commandSet = [RECommandSetBuilder dPadForDeviceWithName:@"Comcast DVR"
                                                                   context:moc];
    [buttonGroup addCommandContainer:commandSet configuration:REDefaultConfiguration];
    commandSet = [RECommandSetBuilder dPadForDeviceWithName:@"Samsung TV" context:moc];
    [buttonGroup addCommandContainer:commandSet configuration:kTVConfiguration];

    return buttonGroup;
}

+ (REButtonGroup *)constructPS3DPadInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [self dPadInContext:moc];
    buttonGroup.name = @"Playstation Activity DPad";
    RECommandSet * commandSet = [RECommandSetBuilder dPadForDeviceWithName:@"PS3" context:moc];
    buttonGroup.commandContainer = commandSet;

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Number Pad
////////////////////////////////////////////////////////////////////////////////
+ (REButtonGroup *)constructDVRNumberPadInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [self numberPadInContext:moc];
    buttonGroup.name = @"DVR Activity Number Pad";
    RECommandSet * commandSet = [RECommandSetBuilder numberPadForDeviceWithName:@"Comcast DVR"
                                                                        context:moc];
    buttonGroup.commandContainer = commandSet;

    return buttonGroup;
}

+ (REButtonGroup *)constructPS3NumberPadInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [self numberPadInContext:moc];
    buttonGroup.name = @"Playstation Activity Number Pad";
    RECommandSet * commandSet = [RECommandSetBuilder numberPadForDeviceWithName:@"PS3"
                                                                        context:moc];
    buttonGroup.commandContainer = commandSet;

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Transport
////////////////////////////////////////////////////////////////////////////////
+ (REButtonGroup *)constructDVRTransportInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [self transportInContext:moc];
    buttonGroup.name = @"DVR Activity Transport";
    RECommandSet * commandSet = [RECommandSetBuilder transportForDeviceWithName:@"Comcast DVR"
                                                                        context:moc];
    [buttonGroup addCommandContainer:commandSet configuration:REDefaultConfiguration];
    commandSet = [RECommandSetBuilder transportForDeviceWithName:@"Samsung TV" context:moc];
    [buttonGroup addCommandContainer:commandSet configuration:kTVConfiguration];

    return buttonGroup;
}

+ (REButtonGroup *)constructPS3TransportInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [self transportInContext:moc];
    buttonGroup.name = @"Playstation Activity Transport";
    RECommandSet * commandSet = [RECommandSetBuilder transportForDeviceWithName:@"PS3"
                                                                        context:moc];
    buttonGroup.commandContainer = commandSet;

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Rocker
////////////////////////////////////////////////////////////////////////////////
+ (REPickerLabelButtonGroup *)constructDVRRockerInContext:(NSManagedObjectContext *)moc
{
    REPickerLabelButtonGroup * buttonGroup = [self rockerInContext:moc];
    buttonGroup.name = @"DVR Activity Rocker";
    RECommandSetCollection * commandSetCollection = [RECommandSetCollection commandContainerInContext:moc];
    RECommandSet * commandSet = [RECommandSetBuilder dvrChannelsCommandSet:moc];

    commandSetCollection[commandSet] = @"CH";
    commandSet = [RECommandSetBuilder dvrPagingCommandSet:moc];
    commandSetCollection[commandSet] = @"PAGE";
    commandSet = [RECommandSetBuilder avReceiverVolumeCommandSet:moc];
    commandSetCollection[commandSet] = @"VOL";

    [buttonGroup.groupConfigurationDelegate setCommandContainer:commandSetCollection configuration:REDefaultConfiguration];

    return buttonGroup;
}

+ (REPickerLabelButtonGroup *)constructPS3RockerInContext:(NSManagedObjectContext *)moc
{
    REPickerLabelButtonGroup * buttonGroup = [self rockerInContext:moc];
    buttonGroup.name = @"Playstation Activity Rocker";
    RECommandSetCollection * commandSetCollection = [RECommandSetCollection commandContainerInContext:moc];
    RECommandSet * commandSet = [RECommandSetBuilder avReceiverVolumeCommandSet:moc];
    commandSetCollection[commandSet] = @"VOL";

    [buttonGroup.groupConfigurationDelegate setCommandContainer:commandSetCollection configuration:REDefaultConfiguration];

    return buttonGroup;
}

+ (REPickerLabelButtonGroup *)constructSonosRockerInContext:(NSManagedObjectContext *)moc
{
    REPickerLabelButtonGroup * buttonGroup = [self rockerInContext:moc];
    buttonGroup.name = @"Sonos Activity Rocker";

    RECommandSetCollection * commandSetCollection = [RECommandSetCollection commandContainerInContext:moc];
    RECommandSet * commandSet = [RECommandSetBuilder avReceiverVolumeCommandSet:moc];
    commandSetCollection[commandSet] = @"VOL";

    [buttonGroup.groupConfigurationDelegate setCommandContainer:commandSetCollection configuration:REDefaultConfiguration];

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Sonos Group
////////////////////////////////////////////////////////////////////////////////
+ (REButtonGroup *)constructSonosMuteButtonGroupInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [REButtonGroup remoteElementInContext:moc];
    buttonGroup.themeFlags = REThemeNone;

    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:moc];
    REButton * mute = [REButton buttonWithTitle:@"Mute" context:moc];
    RESendIRCommand * command = [RESendIRCommand commandWithIRCode:avReceiver[@"Mute"]];
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
+ (REButtonGroup *)constructSelectionPanelInContext:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [REButtonGroup buttonGroupWithType:REButtonGroupTypeSelectionPanel
                                                             context:moc];


    REButton * stbButton = [REButton buttonWithType:REButtonTypeSelectionPanel
                                              title:@"STB"
                                            context:moc];
    stbButton.key = REDefaultConfiguration;

    REButton * tvButton = [REButton buttonWithType:REButtonTypeSelectionPanel
                                             title:@"TV"
                                           context:moc];
    tvButton.key = kTVConfiguration;

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
+ (REButtonGroup *)constructDVRGroupOfThreeButtonsInContext:(NSManagedObjectContext *)moc
{
    // fetch devices
    BOComponentDevice * comcastDVR = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                    context:moc];
    BOComponentDevice * samsungTV = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                   context:moc];

    // create button group
    REButtonGroup * buttonGroup = [self oneByThreeInContext:moc];
    buttonGroup.name = @"DVR Activity 1x3";

    // Configure "Guide" button and its delegate
    REButton * guideButton = buttonGroup[0];
    guideButton.name = @"Guide / Tools";
    REControlStateTitleSet * titleSet = [REControlStateTitleSet controlStateSetInContext:moc
                                                                             withObjects:@{@"normal" : @"Guide"}];
    [guideButton setTitles:titleSet configuration:REDefaultConfiguration];
    titleSet = [REControlStateTitleSet controlStateSetInContext:moc
                                                    withObjects:@{@"normal": @"Tools"}];
    [guideButton setTitles:titleSet configuration:kTVConfiguration];

    RECommand * command = [RESendIRCommand commandWithIRCode:comcastDVR[@"Guide"]];
    [guideButton setCommand:command configuration:REDefaultConfiguration];

    command = [RESendIRCommand commandWithIRCode:samsungTV[@"Tools"]];
    [guideButton setCommand:command configuration:kTVConfiguration];

    // Configure "DVR" button and add its delegate
    REButton * dvrButton = buttonGroup[1];
    dvrButton.name = @"DVR / Internet@TV";
    titleSet = [REControlStateTitleSet controlStateSetInContext:moc
                                                    withObjects:@{@"normal":@"DVR"}];
    [dvrButton setTitles:titleSet configuration:REDefaultConfiguration];
    titleSet = [REControlStateTitleSet controlStateSetInContext:moc
                                                    withObjects:@{@"normal":@"Internet@TV"}];
    [dvrButton setTitles:titleSet configuration:kTVConfiguration];

    command = [RESendIRCommand commandWithIRCode:comcastDVR[@"DVR"]];
    [dvrButton setCommand:command configuration:REDefaultConfiguration];

    command = [RESendIRCommand commandWithIRCode:samsungTV[@"Internet@TV"]];
    [dvrButton setCommand:command configuration:kTVConfiguration];

    // Configure "Info" button and its delegate
    REButton * infoButton = buttonGroup[2];
    infoButton.name = @"Info";

    titleSet = [REControlStateTitleSet controlStateSetInContext:moc
                                                    withObjects:@{@"normal" : @"Info"}];
    [infoButton setTitles:titleSet configuration:REDefaultConfiguration];
    [infoButton setTitles:[titleSet copy] configuration:kTVConfiguration];

    command = [RESendIRCommand commandWithIRCode:comcastDVR[@"Info"]];
    [infoButton setCommand:command configuration:REDefaultConfiguration];

    command = [RESendIRCommand commandWithIRCode:samsungTV[@"Info"]];
    [infoButton setCommand:command configuration:kTVConfiguration];

    return buttonGroup;
}

+ (REButtonGroup *)constructPS3GroupOfThreeButtonsInContext:(NSManagedObjectContext *)moc
{
    // fetch device
    BOComponentDevice * ps3 = [BOComponentDevice fetchDeviceWithName:@"PS3"
                                                             context:moc];

    // create button group
    REButtonGroup * buttonGroup = [self oneByThreeInContext:moc];
    buttonGroup.name = @"PS3 Activity 1x3";

    // configure buttons
    REButton * displayButton = buttonGroup[0];
    displayButton.name = @"Display";
    displayButton.title = [NSAttributedString attributedStringWithString:@"Display"];
    displayButton.command = [RESendIRCommand commandWithIRCode:ps3[@"Display"]];

    REButton * topMenuButton = buttonGroup[1];
    topMenuButton.name = @"Top Menu";
    topMenuButton.title = [NSAttributedString attributedStringWithString:@"Top Menu"];
    topMenuButton.command = [RESendIRCommand commandWithIRCode:ps3[@"Top Menu"]];

    REButton * popupMenuButton = buttonGroup[2];
    popupMenuButton.name = @"Popup Menu";
    popupMenuButton.title = [NSAttributedString attributedStringWithString:@"Popup Menu"];
    popupMenuButton.command = [RESendIRCommand commandWithIRCode:ps3[@"Popup Menu"]];

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Left Panel
////////////////////////////////////////////////////////////////////////////////
+ (REButtonGroup *)constructAdditionalButtonsLeftInContext:(NSManagedObjectContext *)moc
{
    BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                    context:moc];
    BOComponentDevice * samsungTV = [BOComponentDevice  fetchDeviceWithName:@"Samsung TV"
                                                                    context:moc];
    BOComponentDevice * comcastDVR = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                    context:moc];

    REButtonGroup * buttonGroup = [self verticalPanelInContext:moc];
    buttonGroup.name = @"Left Overlay Panel";

    REButton * button = buttonGroup[0];
    button.name = @"On Demand / Source";
    [button setTitle:@"On Demand" configuration:REDefaultConfiguration];
    [button setTitle:@"Source" configuration:kTVConfiguration];

    RECommand * command = [RESendIRCommand commandWithIRCode:comcastDVR[@"On Demand"]];
    [button setCommand:command configuration:REDefaultConfiguration];
    command = [RESendIRCommand commandWithIRCode:samsungTV[@"Source"]];
    [button setCommand:command configuration:kTVConfiguration];

    button = buttonGroup[1];
    button.name = @"Menu";
    [button setTitle:@"Menu" configuration:REDefaultConfiguration];

    command = [RESendIRCommand commandWithIRCode:comcastDVR[@"Menu"]];
    [button setCommand:command  configuration:REDefaultConfiguration];
    command = [RESendIRCommand commandWithIRCode:samsungTV[@"Menu"]];
    [button setCommand:command  configuration:kTVConfiguration];

    button = buttonGroup[2];
    button.name = @"Last / Return";
    [button setTitle:@"Last" configuration:REDefaultConfiguration];
    [button setTitle:@"Return" configuration:kTVConfiguration];

    command = [RESendIRCommand commandWithIRCode:comcastDVR[@"Last"]];
    [button setCommand:command  configuration:REDefaultConfiguration];
    command = [RESendIRCommand commandWithIRCode:samsungTV[@"Return"]];
    [button setCommand:command  configuration:kTVConfiguration];

    button = buttonGroup[3];
    button.name = @"Exit";
    [button setTitle:@"Exit" configuration:REDefaultConfiguration];

    command = [RESendIRCommand commandWithIRCode:comcastDVR[@"Exit"]];
    [button setCommand:command  configuration:REDefaultConfiguration];
    command = [RESendIRCommand commandWithIRCode:samsungTV[@"Exit"]];
    [button setCommand:command  configuration:kTVConfiguration];

    button = buttonGroup[4];
    button.name = @"DVR Audio Input";
    [button setTitle:@"DVR Audio" configuration:REDefaultConfiguration];

    button.command = [RESendIRCommand commandWithIRCode:avReceiver[@"TV/SAT"]];

    button = buttonGroup[5];
    button.name = @"TV Audio Input";
    [button setTitle:@"TV Audio" configuration:REDefaultConfiguration];

    button.command = [RESendIRCommand commandWithIRCode:avReceiver[@"Video 3"]];

    button = buttonGroup[6];
    button.name = @"Mute";
    [button setTitle:@"Mute" configuration:REDefaultConfiguration];

    button.command = [RESendIRCommand commandWithIRCode:avReceiver[@"Mute"]];

    button = buttonGroup[7];
    button.name = @"Tuck Panel";
    [button setTitle:kLeftArrow configuration:REDefaultConfiguration];

    return buttonGroup;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Home and Power
////////////////////////////////////////////////////////////////////////////////
+ (REButtonGroup *)constructHomeAndPowerButtonsForActivity:(NSInteger)activity
                                                   context:(NSManagedObjectContext *)moc
{
    REButtonGroup * buttonGroup = [REButtonGroup remoteElementInContext:moc];
    buttonGroup.name = @"Home and Power Buttons";
    buttonGroup.themeFlags = REThemeNoBackground|REThemeNoStyle|REThemeNoShape;

    REButton * homeButton = [REButton remoteElementInContext:moc];
    homeButton.shape = REShapeOval;
    homeButton.name = @"Home Button";
    homeButton.themeFlags = REThemeNoShape;

    REControlStateImageSet * iconSet = [REControlStateImageSet
                                            imageSetWithImages:@{@"normal": @"502-house"}
                                                     context:moc];
    [homeButton setIcons:iconSet configuration:REDefaultConfiguration];


    REButton * powerButton = [REButton remoteElementInContext:moc];
    powerButton.shape = REShapeOval;
    powerButton.name = @"Power Off and Exit Activity";
    powerButton.key = $(@"activity%i", activity);
    powerButton.themeFlags = REThemeNoShape;

    iconSet = [REControlStateImageSet imageSetWithImages:@{@"normal": @"51-power"} context:moc];
    [powerButton setIcons:iconSet configuration:REDefaultConfiguration];

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
