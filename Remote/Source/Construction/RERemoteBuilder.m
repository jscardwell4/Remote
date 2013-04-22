//
// RemoteBuilder.m
// Remote
//
// Created by Jason Cardwell on 7/12/11.// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "RemoteConstruction.h"

static const int ddLogLevel   = LOG_LEVEL_WARN;
static const int msLogContext = 0;
#pragma unused(ddLogLevel, msLogContext)

@implementation RERemoteBuilder

+ (RERemote *)constructDVRRemoteInContext:(NSManagedObjectContext *)context
{
    RERemote * remote =
          MakeRemote(@"displayName"          : @"Comcast DVR Activity",
                     @"key"                  : @"activity1",
                     @"backgroundImage"      : MakeBackgroundImage(8),
                     @"backgroundImageAlpha" : @1.0,
                     @"options"              : @(RERemoteOptionTopBarHiddenOnLoad));

      REButtonGroup * oneByThree = [REButtonGroupBuilder constructDVRGroupOfThreeButtonsInContext:context];
      REButtonGroup * rocker     = [REButtonGroupBuilder constructDVRRockerInContext:context];
      REButtonGroup * dpad       = [REButtonGroupBuilder constructDVRDPadInContext:context];
      REButtonGroup * numberpad  = [REButtonGroupBuilder constructDVRNumberPadInContext:context];
      REButtonGroup * transport  = [REButtonGroupBuilder constructDVRTransportInContext:context];
      REButtonGroup * selection  = [REButtonGroupBuilder constructSelectionPanelInContext:context];
      REButtonGroup * leftPanel  = [REButtonGroupBuilder constructAdditionalButtonsLeftInContext:context];
      REButtonGroup * power      = [REButtonGroupBuilder constructHomeAndPowerButtonsForActivity:1 context:context];

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


+ (RERemote *)constructHomeRemoteInContext:(NSManagedObjectContext *)context
{
    RERemote * remote =
          MakeRemote(@"type"                 : @(RETypeRemote),
                     @"displayName"          : @"Home Screen",
//                     @"key"                  : MSRemoteControllerHomeRemoteKeyName,
                     @"backgroundImage"      : MakeBackgroundImage(8),
                     @"backgroundImageAlpha" : @1.0);

      REButtonGroup * activityButtons = [REButtonGroupBuilder constructActivitiesInContext:context];
      REButtonGroup * lightControls = [REButtonGroupBuilder constructLightControlsInContext:context];

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

+ (RERemote *)constructPS3RemoteInContext:(NSManagedObjectContext *)context
{
    RERemote * remote =
          MakeRemote(@"type"                 : @(RETypeRemote),
                     @"key"                  : @"activity2",
                     @"options"              : @(RERemoteOptionTopBarHiddenOnLoad),
                     @"displayName"          : @"Playstation Activity",
                     @"backgroundImage"      : MakeBackgroundImage(8),
                     @"backgroundImageAlpha" : @1.0);

    REButtonGroup * bg1 = [REButtonGroupBuilder constructPS3GroupOfThreeButtonsInContext:context];
    assert(bg1);
    REButtonGroup * bg2 = [REButtonGroupBuilder constructPS3RockerInContext:context];
    assert(bg2);
    REButtonGroup * bg3 = [REButtonGroupBuilder constructPS3DPadInContext:context];
    assert(bg3);
    REButtonGroup * bg4 = [REButtonGroupBuilder constructPS3NumberPadInContext:context];
    assert(bg4);
    REButtonGroup * bg5 = [REButtonGroupBuilder constructPS3TransportInContext:context];
    assert(bg5);
    REButtonGroup * bg6 = [REButtonGroupBuilder constructHomeAndPowerButtonsForActivity:2 context:context];
    assert(bg6);

    [remote addSubelements:[@[bg1, bg2, bg3, bg4, bg5, bg6] orderedSet]];

      // TODO:add constraints
    return remote;
}

+ (RERemote *)constructSonosRemoteInContext:(NSManagedObjectContext *)context
{
    RERemote * remote =
         MakeRemote(@"type"				   : @(RETypeRemote),
                    @"key" 				   : @"activity4",
                    @"displayName" 		   : @"Sonos Activity",
                    @"backgroundImage" 	   : MakeBackgroundImage(8),
                    @"backgroundImageAlpha" : @1.0);

     REButtonGroup * mute   = [REButtonGroupBuilder constructSonosMuteButtonGroupInContext:context];
     REButtonGroup * rocker = [REButtonGroupBuilder constructSonosRockerInContext:context];
     REButtonGroup * power  = [REButtonGroupBuilder constructHomeAndPowerButtonsForActivity:4 context:context];

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
