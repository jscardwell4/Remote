//
// RemoteBuilder.m
// Remote
//
// Created by Jason Cardwell on 7/12/11.// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "RemoteConstruction.h"

static const int   ddLogLevel   = LOG_LEVEL_WARN;
static const int   msLogContext = 0;
#pragma unused(ddLogLevel, msLogContext)

@implementation RemoteBuilder @end

@implementation RemoteBuilder (Developer)

+ (Remote *)constructDVRRemoteInContext:(NSManagedObjectContext *)moc
{
    Remote * remote = [Remote remoteElementInContext:moc];
    remote.name = @"Dish Hopper Activity";
    remote.key = @"activity1";
    remote.topBarHiddenOnLoad = YES;
    [remote registerConfiguration:kTVConfiguration];

    ButtonGroup * oneByThree = [ButtonGroupBuilder constructDVRGroupOfThreeButtonsInContext:moc];
    ButtonGroup * rocker = [ButtonGroupBuilder constructDVRRockerInContext:moc];
    ButtonGroup * dpad = [ButtonGroupBuilder constructDVRDPadInContext:moc];
    ButtonGroup * numberpad = [ButtonGroupBuilder constructDVRNumberPadInContext:moc];
    [remote assignButtonGroup:numberpad assignment:REPanelLocationTop|REPanelTrigger1];
    ButtonGroup * transport = [ButtonGroupBuilder constructDVRTransportInContext:moc];
    [remote assignButtonGroup:transport assignment:REPanelLocationBottom|REPanelTrigger1];
    ButtonGroup * selection = [ButtonGroupBuilder constructSelectionPanelInContext:moc];
    [remote assignButtonGroup:selection assignment:REPanelLocationRight|REPanelTrigger1];
    ButtonGroup * leftPanel = [ButtonGroupBuilder constructAdditionalButtonsLeftInContext:moc];
    [remote assignButtonGroup:leftPanel assignment:REPanelLocationLeft|REPanelTrigger1];
    ButtonGroup * power = [ButtonGroupBuilder constructHomeAndPowerButtonsForActivity:1
                                                                                  context:moc];

    [remote addSubelements:[@[oneByThree,
                              rocker,
                              dpad,
                              power,
                              numberpad,
                              transport,
                              selection,
                              leftPanel] orderedSet]];

    SetConstraints(remote,
                   @"oneByThree.left = remote.left + 20\n"
                   "rocker.right = remote.right - 20\n"
                   "oneByThree.top = remote.top + 20\n"
                   "power.bottom = remote.bottom - 20\n"
                   "rocker.top = remote.top + 20\n"
                   "rocker.height = oneByThree.height\n"
                   "dpad.top = oneByThree.bottom + 20\n"
                   "dpad.centerY = remote.centerY + 70 @750\n"
                   "dpad.centerX = remote.centerX\n"
                   "power.centerX = remote.centerX\n"
                   "numberpad.height = remote.height\n"
                   "numberpad.left = remote.left\n"
                   "numberpad.right = remote.right\n"
                   "numberpad.top = remote.top @998\n"
                   "transport.left = remote.left\n"
                   "transport.right = remote.right\n"
                   "transport.bottom = remote.bottom @998\n"
                   "leftPanel.top = remote.top\n"
                   "leftPanel.bottom = remote.bottom\n"
                   "leftPanel.left = remote.left @998\n"
                   "selection.centerY = remote.centerY\n"
                   "selection.right = remote.right @998",
                   oneByThree, rocker, dpad, numberpad, selection, power, leftPanel, transport);

    return remote;
}

+ (Remote *)constructHomeRemoteInContext:(NSManagedObjectContext *)moc
{
    Remote * remote =  [Remote remoteElementInContext:moc];
    remote.name = @"Home Screen";

    ButtonGroup * activityButtons = [ButtonGroupBuilder constructActivitiesInContext:moc];
    ButtonGroup * lightControls = [ButtonGroupBuilder constructLightControlsInContext:moc];

    [remote addSubelements:[@[activityButtons, lightControls] orderedSet]];

    SetConstraints(remote,
                   @"activityButtons.centerX = remote.centerX\n"
                   "activityButtons.centerY = remote.centerY - 22\n"
                   "lightControls.left = remote.left\n"
                   "lightControls.right = remote.right\n"
                   "lightControls.bottom = remote.bottom",
                   activityButtons, lightControls);

    return remote;
}

+ (Remote *)constructPS3RemoteInContext:(NSManagedObjectContext *)moc
{
    Remote * remote = [Remote remoteElementInContext:moc];
    remote.key = @"activity2";
    remote.options = RERemoteOptionTopBarHiddenOnLoad;
    remote.name = @"Playstation Activity";

    ButtonGroup * bg1 = [ButtonGroupBuilder constructPS3GroupOfThreeButtonsInContext:moc];
    ButtonGroup * bg2 = [ButtonGroupBuilder constructPS3RockerInContext:moc];
    ButtonGroup * bg3 = [ButtonGroupBuilder constructPS3DPadInContext:moc];
    ButtonGroup * bg4 = [ButtonGroupBuilder constructPS3NumberPadInContext:moc];
    ButtonGroup * bg5 = [ButtonGroupBuilder constructPS3TransportInContext:moc];
    ButtonGroup * bg6 = [ButtonGroupBuilder constructHomeAndPowerButtonsForActivity:2
                                                                                context:moc];

    [remote addSubelements:[@[bg1, bg2, bg3, bg4, bg5, bg6] orderedSet]];

    // TODO:add constraints
    return remote;
}

+ (Remote *)constructSonosRemoteInContext:(NSManagedObjectContext *)moc
{
    Remote * remote = [Remote remoteElementInContext:moc];
    remote.key = @"activity4";
    remote.name = @"Sonos Activity";

    ButtonGroup * mute   = [ButtonGroupBuilder constructSonosMuteButtonGroupInContext:moc];
    ButtonGroup * rocker = [ButtonGroupBuilder constructSonosRockerInContext:moc];
    ButtonGroup * power  = [ButtonGroupBuilder constructHomeAndPowerButtonsForActivity:4
                                                                                   context:moc];

    [remote addSubelements:[@[mute, rocker, power] orderedSet]];

    SetConstraints(remote,
                   @"power.left = remote.left + 10\n"
                   "power.right = remote.right - 10\n"
                   "power.bottom = remote.bottom - 20\n"
                   "mute.centerX = remote.centerX - 60\n"
                   "rocker.centerX = remote.centerX + 65\n"
                   "mute.centerY = remote.centerY - 25\n"
                   "rocker.centerY = mute.centerY\n"
                   "mute.height = rocker.height * 0.33",
                   mute, rocker, power);

    return remote;
}

@end
