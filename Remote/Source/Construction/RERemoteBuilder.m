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

@implementation RERemoteBuilder @end

@implementation RERemoteBuilder (Developer)

+ (RERemote *)constructDVRRemoteInContext:(NSManagedObjectContext *)moc
{
    RERemote * remote = [RERemote remoteElementInContext:moc];
    remote.name = @"Comcast DVR Activity";
    remote.key = @"activity1";
    remote.topBarHiddenOnLoad = YES;
    [remote registerConfiguration:kTVConfiguration];

    REButtonGroup * oneByThree = [REButtonGroupBuilder constructDVRGroupOfThreeButtonsInContext:moc];
    REButtonGroup * rocker = [REButtonGroupBuilder constructDVRRockerInContext:moc];
    REButtonGroup * dpad = [REButtonGroupBuilder constructDVRDPadInContext:moc];
    REButtonGroup * numberpad = [REButtonGroupBuilder constructDVRNumberPadInContext:moc];
    [remote assignButtonGroup:numberpad assignment:REPanelLocationTop|REPanelTrigger1];
    REButtonGroup * transport = [REButtonGroupBuilder constructDVRTransportInContext:moc];
    [remote assignButtonGroup:transport assignment:REPanelLocationBottom|REPanelTrigger1];
    REButtonGroup * selection = [REButtonGroupBuilder constructSelectionPanelInContext:moc];
    [remote assignButtonGroup:selection assignment:REPanelLocationRight|REPanelTrigger1];
    REButtonGroup * leftPanel = [REButtonGroupBuilder constructAdditionalButtonsLeftInContext:moc];
    [remote assignButtonGroup:leftPanel assignment:REPanelLocationLeft|REPanelTrigger1];
    REButtonGroup * power = [REButtonGroupBuilder constructHomeAndPowerButtonsForActivity:1
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

+ (RERemote *)constructHomeRemoteInContext:(NSManagedObjectContext *)moc
{
    RERemote * remote =  [RERemote remoteElementInContext:moc];
    remote.name = @"Home Screen";

    REButtonGroup * activityButtons = [REButtonGroupBuilder constructActivitiesInContext:moc];
    REButtonGroup * lightControls = [REButtonGroupBuilder constructLightControlsInContext:moc];

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

+ (RERemote *)constructPS3RemoteInContext:(NSManagedObjectContext *)moc
{
    RERemote * remote = [RERemote remoteElementInContext:moc];
    remote.key = @"activity2";
    remote.options = RERemoteOptionTopBarHiddenOnLoad;
    remote.name = @"Playstation Activity";

    REButtonGroup * bg1 = [REButtonGroupBuilder constructPS3GroupOfThreeButtonsInContext:moc];
    REButtonGroup * bg2 = [REButtonGroupBuilder constructPS3RockerInContext:moc];
    REButtonGroup * bg3 = [REButtonGroupBuilder constructPS3DPadInContext:moc];
    REButtonGroup * bg4 = [REButtonGroupBuilder constructPS3NumberPadInContext:moc];
    REButtonGroup * bg5 = [REButtonGroupBuilder constructPS3TransportInContext:moc];
    REButtonGroup * bg6 = [REButtonGroupBuilder constructHomeAndPowerButtonsForActivity:2
                                                                                context:moc];

    [remote addSubelements:[@[bg1, bg2, bg3, bg4, bg5, bg6] orderedSet]];

    // TODO:add constraints
    return remote;
}

+ (RERemote *)constructSonosRemoteInContext:(NSManagedObjectContext *)moc
{
    RERemote * remote = [RERemote remoteElementInContext:moc];
    remote.key = @"activity4";
    remote.name = @"Sonos Activity";

    REButtonGroup * mute   = [REButtonGroupBuilder constructSonosMuteButtonGroupInContext:moc];
    REButtonGroup * rocker = [REButtonGroupBuilder constructSonosRockerInContext:moc];
    REButtonGroup * power  = [REButtonGroupBuilder constructHomeAndPowerButtonsForActivity:4
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
