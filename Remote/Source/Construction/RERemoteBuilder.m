//
// RemoteBuilder.m
// Remote
//
// Created by Jason Cardwell on 7/12/11.// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "RemoteConstruction.h"

static const int ddLogLevel = LOG_LEVEL_WARN;
static const int msLogContext = DEFAULT_LOG_CONTEXT;
#pragma unused(ddLogLevel, msLogContext)

@implementation RERemoteBuilder

+ (instancetype)builderWithContext:(NSManagedObjectContext *)context
{
    RERemoteBuilder * builder = [super builderWithContext:context];
    builder->_buttonGroupBuilder = [REButtonGroupBuilder builderWithContext:context];
    return builder;
}

- (RERemote *)constructDVRRemote
{
    __block RERemote * remote = nil;
    [_buildContext performBlockAndWait:
     ^{
         remote =
         MakeRemote(@"displayName"          : @"Comcast DVR Activity",
                    @"key"                  : @"activity1",
                    @"backgroundImage"      : MakeBackgroundImage(8),
                    @"backgroundImageAlpha" : @1.0,
                    @"options"              : @(RERemoteOptionTopBarHiddenOnLoad));

         REButtonGroup * oneByThree = [_buttonGroupBuilder constructDVRGroupOfThreeButtons];
         REButtonGroup * rocker     = [_buttonGroupBuilder constructDVRRocker];
         REButtonGroup * dpad       = [_buttonGroupBuilder constructDVRDPad];
         REButtonGroup * numberpad  = [_buttonGroupBuilder constructDVRNumberPad];
         REButtonGroup * transport  = [_buttonGroupBuilder constructDVRTransport];
         REButtonGroup * selection  = [_buttonGroupBuilder constructSelectionPanel];
         REButtonGroup * leftPanel  = [_buttonGroupBuilder constructAdditionalButtonsLeft];
         REButtonGroup * power      = [_buttonGroupBuilder constructHomeAndPowerButtonsForActivity:1];

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
     }];
    return remote;
}


- (RERemote *)constructHomeRemote
{
    __block RERemote * homeRemote = nil;
    [_buildContext performBlockAndWait:^{
        homeRemote =
        MakeRemote(@"type"                 : @(RETypeRemote),
                   @"displayName"          : @"Home Screen",
                   @"key"                  : MSRemoteControllerHomeRemoteKeyName,
                   @"backgroundImage"      : MakeBackgroundImage(8),
                   @"backgroundImageAlpha" : @1.0);

        REButtonGroup * activityButtons = [_buttonGroupBuilder constructActivities];
        REButtonGroup * lightControls = [_buttonGroupBuilder constructLightControls];

        [homeRemote addSubelements:[@[activityButtons, lightControls] orderedSet]];

        SetConstraints(homeRemote,
                       @"activityButtons.centerX = homeRemote.centerX\n"
                       "activityButtons.centerY = homeRemote.centerY - 22\n"
                       "lightControls.left = homeRemote.left\n"
                       "lightControls.right = homeRemote.right\n"
                       "lightControls.bottom = homeRemote.bottom",
                       activityButtons, lightControls);
    }];
    return homeRemote;
}

- (RERemote *)constructPS3Remote
{
    __block RERemote * remote = nil;
    [_buildContext performBlockAndWait:
     ^{
         remote =
         MakeRemote(@"type"                 : @(RETypeRemote),
                    @"key"                  : @"activity2",
                    @"options"              : @(RERemoteOptionTopBarHiddenOnLoad),
                    @"displayName"          : @"Playstation Activity",
                    @"backgroundImage"      : MakeBackgroundImage(8),
                    @"backgroundImageAlpha" : @1.0);

         REButtonGroup * bg1 = [_buttonGroupBuilder constructPS3GroupOfThreeButtons];
         assert(bg1);
         REButtonGroup * bg2 = [_buttonGroupBuilder constructPS3Rocker];
         assert(bg2);
         REButtonGroup * bg3 = [_buttonGroupBuilder constructPS3DPad];
         assert(bg3);
         REButtonGroup * bg4 = [_buttonGroupBuilder constructPS3NumberPad];
         assert(bg4);
         REButtonGroup * bg5 = [_buttonGroupBuilder constructPS3Transport];
         assert(bg5);
         REButtonGroup * bg6 = [_buttonGroupBuilder constructHomeAndPowerButtonsForActivity:2];
         assert(bg6);

         [remote addSubelements:[@[bg1, bg2, bg3, bg4, bg5, bg6] orderedSet]];

         // TODO:add constraints
    }];
    return remote;
}

- (RERemote *)constructSonosRemote
{
    __block RERemote * remote = nil;
    [_buildContext performBlockAndWait:
     ^{
         remote =
         MakeRemote(@"type"				   : @(RETypeRemote),
                    @"key" 				   : @"activity4",
                    @"displayName" 		   : @"Sonos Activity",
                    @"backgroundImage" 	   : MakeBackgroundImage(8),
                    @"backgroundImageAlpha" : @1.0);

         REButtonGroup * mute   = [_buttonGroupBuilder constructSonosMuteButtonGroup];
         REButtonGroup * rocker = [_buttonGroupBuilder constructSonosRocker];
         REButtonGroup * power  = [_buttonGroupBuilder constructHomeAndPowerButtonsForActivity:4];

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
     }];
    return remote;
}

@end
