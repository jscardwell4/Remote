//
// RemoteBuilder.m
// Remote
//
// Created by Jason Cardwell on 7/12/11.// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "RemoteElementConstructionManager.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@interface RemoteBuilder ()
@property (nonatomic, strong) ButtonGroupBuilder * buttonGroupBuilder;
@end
@implementation RemoteBuilder

+ (RemoteBuilder *)remoteBuilderWithContext:(NSManagedObjectContext *)context {
    RemoteBuilder * rb = [self new];

    rb.buildContext = context;

    return rb;
}

- (RERemote *)constructDVRRemote {
    // Create remote view that fills the screen with textured background
    RERemote * remote = MakeRemote(@"displayName" : @"Comcast DVR Activity",
                                 @"key" : @"activity1",
                                 @"backgroundImage" : MakeBackgroundImage(8),
                                 @"backgroundImageAlpha" : @1.0,
                                 @"options" : @(RERemoteOptionTopBarHiddenOnLoad));
    REButtonGroup * oneByThree = [self.buttonGroupBuilder constructDVRGroupOfThreeButtons];
    REButtonGroup * rocker     = [self.buttonGroupBuilder constructDVRRocker];
    REButtonGroup * dpad       = [self.buttonGroupBuilder constructDVRDPad];
    REButtonGroup * numberpad  = [self.buttonGroupBuilder constructDVRNumberPad];
    REButtonGroup * transport  = [self.buttonGroupBuilder constructDVRTransport];
    REButtonGroup * selection  = [self.buttonGroupBuilder constructSelectionPanel];
    REButtonGroup * leftPanel  = [self.buttonGroupBuilder constructAdditionalButtonsLeft];
    REButtonGroup * power      = [self.buttonGroupBuilder constructHomeAndPowerButtonsForActivity:1];

    [remote addSubelements:[@[oneByThree, rocker, dpad, power, numberpad, transport, selection, leftPanel] orderedSet]];

    NSDictionary * identifiers = NSDictionaryOfVariableBindingsToIdentifiers(remote, oneByThree, rocker, dpad, numberpad, selection, power, leftPanel, transport);
    NSString     * constraints =
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
        "numberpad.top = remote.top @999\n"
        "transport.left = remote.left\n"
        "transport.right = remote.right\n"
        "transport.bottom = remote.bottom @999\n"
        "leftPanel.top = remote.top\n"
        "leftPanel.bottom = remote.bottom\n"
        "leftPanel.left = remote.left @999\n"
        "selection.centerY = remote.centerY\n"
        "selection.right = remote.right @999";

    [remote.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    return remote;
}

- (RERemote *)constructHomeRemote {
    RERemote * homeRemote = MakeRemote(@"type" : @(RETypeRemote),
                                     @"displayName" : @"Home Screen",
                                     @"key" : MSRemoteControllerHomeRemoteKeyName,
                                     @"backgroundImage" : MakeBackgroundImage(8),
                                     @"backgroundImageAlpha" : @1.0);
    REButtonGroup * activityButtons = [self.buttonGroupBuilder constructActivities];
// activityButtons.sizingOptions = SizingOptions4;
// activityButtons.alignmentOptions = AlignmentOptions4;
    REButtonGroup * lightControls = [self.buttonGroupBuilder constructLightControls];

// lightControls.alignmentOptions = AlignmentOptions8;
// lightControls.sizingOptions = SizingOptions5;

    [homeRemote addSubelements:[@[activityButtons, lightControls] orderedSet]];

    NSString * childConstraints =
        @"activityButtons.centerX = homeRemote.centerX\n"
        "activityButtons.centerY = homeRemote.centerY - 22\n"
        "lightControls.left = homeRemote.left\n"
        "lightControls.right = homeRemote.right\n"
        "lightControls.bottom = homeRemote.bottom";
    NSDictionary * identifiers = NSDictionaryOfVariableBindingsToIdentifiers(activityButtons, lightControls, homeRemote);

    [homeRemote.constraintManager setConstraintsFromString:[childConstraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    return homeRemote;
}

- (RERemote *)constructPS3Remote {
    RERemote * remote = MakeRemote(@"type" : @(RETypeRemote),
                                 @"key" : @"activity2",
                                 @"options" : @(RERemoteOptionTopBarHiddenOnLoad),
                                 @"displayName" : @"Playstation Activity",
                                 @"backgroundImage" : MakeBackgroundImage(8),
                                 @"backgroundImageAlpha" : @1.0);
    REButtonGroup * bg1 = [self.buttonGroupBuilder constructPS3GroupOfThreeButtons];
    REButtonGroup * bg2 = [self.buttonGroupBuilder constructPS3Rocker];
    REButtonGroup * bg3 = [self.buttonGroupBuilder constructPS3DPad];
    REButtonGroup * bg4 = [self.buttonGroupBuilder constructPS3NumberPad];
    REButtonGroup * bg5 = [self.buttonGroupBuilder constructPS3Transport];
    REButtonGroup * bg6 = [self.buttonGroupBuilder constructHomeAndPowerButtonsForActivity:2];

    [remote addSubelements:[@[bg1, bg2, bg3, bg4, bg5, bg6] orderedSet]];

    // TODO:add constraints

    return remote;
}

- (RERemote *)constructSonosRemote {
    RERemote * remote = MakeRemote(@"type" : @(RETypeRemote),
                                 @"key" : @"activity4",
                                 @"displayName" : @"Sonos Activity",
                                 @"backgroundImage" : MakeBackgroundImage(8),
                                 @"backgroundImageAlpha" : @1.0);
    REButtonGroup * mute   = [self.buttonGroupBuilder constructSonosMuteButtonGroup];
    REButtonGroup * rocker = [self.buttonGroupBuilder constructSonosRocker];
    REButtonGroup * power  = [self.buttonGroupBuilder constructHomeAndPowerButtonsForActivity:4];

    [remote addSubelements:[@[mute, rocker, power] orderedSet]];

    NSString * constraints =
        @"power.left = remote.left + 10\n"
        "power.right = remote.right - 10\n"
        "power.bottom = remote.bottom - 20\n"
        "mute.centerX = remote.centerX - 60\n"
        "rocker.centerX = remote.centerX + 65\n"
        "mute.centerY = remote.centerY - 25\n"
        "rocker.centerY = mute.centerY\n"
        "mute.height = rocker.height * 0.33";
    NSDictionary * identifiers = NSDictionaryOfVariableBindingsToIdentifiers(mute, rocker, power, remote);

    [remote.constraintManager setConstraintsFromString:[constraints stringByReplacingOccurrencesWithDictionary:identifiers]];

    return remote;
}

- (ButtonGroupBuilder *)buttonGroupBuilder {
    if (!_buttonGroupBuilder) self.buttonGroupBuilder = [ButtonGroupBuilder buttonGroupBuilderWithContext:self.buildContext];

    return _buttonGroupBuilder;
}

@end
