//
// RemoteElementConstructionManager.m
// Remote
//
// Created by Jason Cardwell on 10/23/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteConstruction.h"

static const int ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = CONSOLE_LOG_CONTEXT;
#pragma unused(ddLogLevel, msLogContext)

@implementation RemoteElementConstructionManager

+ (void)buildController
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         // create controller
         RERemoteController * controller = [RERemoteController MR_findFirstInContext:context];
         assert(!controller);
         controller = [RERemoteController remoteControllerInContext:context];
         assert(controller);

         // create builtin themes
         REBuiltinTheme * nightshadeTheme = [REBuiltinTheme themeWithName:REThemeNightshadeName];
         assert(nightshadeTheme);

         REBuiltinTheme * powerBlueTheme = [REBuiltinTheme themeWithName:REThemePowerBlueName];
         assert(powerBlueTheme);

         // create top toolbar
         [controller registerTopToolbar:[REButtonGroupBuilder constructControllerTopToolbar]];

         // attach power on/off commands to components
         BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"];
         avReceiver.inputPowersOn       = YES;
         avReceiver.offCommand          = MakeIRCommand(avReceiver, @"Power");

         BOComponentDevice * comcastDVR = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"];
         comcastDVR.alwaysOn            = YES;

         BOComponentDevice * samsungTV  = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"];
         samsungTV.offCommand           = MakeIRCommand(samsungTV, @"Power Off");
         samsungTV.onCommand            = MakeIRCommand(samsungTV, @"Power On");

         BOComponentDevice * ps3        = [BOComponentDevice fetchDeviceWithName:@"PS3"];
         ps3.offCommand                 = MakeIRCommand(ps3, @"Discrete Off");
         ps3.onCommand                  = MakeIRCommand(ps3, @"Discrete On");

         // Comcast DVR Activity
         REActivity * dvrActivity = [REActivity activityWithName:@"Comcast DVR Activity"];
         [controller registerActivity:dvrActivity];
         dvrActivity.launchMacro = [REMacroBuilder activityMacroForActivity:1 toInitiateState:YES];
         dvrActivity.haltMacro   = [REMacroBuilder activityMacroForActivity:0 toInitiateState:YES];

         RERemote   * dvrRemote   = [RERemoteBuilder constructDVRRemote];
//         [nightshadeTheme applyThemeToElement:dvrRemote];
         dvrActivity.remote = dvrRemote;

         // Playstation Activity
         REActivity * ps3Activity = [REActivity activityWithName:@"Playstation Activity"];
         [controller registerActivity:ps3Activity];
         ps3Activity.launchMacro = [REMacroBuilder activityMacroForActivity:1 toInitiateState:YES];
         ps3Activity.haltMacro   = [REMacroBuilder activityMacroForActivity:0 toInitiateState:YES];

         RERemote   * ps3Remote   = [RERemoteBuilder constructPS3Remote];
//         [nightshadeTheme applyThemeToElement:ps3Remote];
         ps3Activity.remote = ps3Remote;

         // TV Activity
         REActivity * appleTVActivity = [REActivity activityWithName:@" TV Activity"];
         [controller registerActivity:appleTVActivity];
         appleTVActivity.launchMacro = [REMacroBuilder activityMacroForActivity:1 toInitiateState:YES];
         appleTVActivity.haltMacro   = [REMacroBuilder activityMacroForActivity:0 toInitiateState:YES];

         // Sonos Activity
         REActivity * sonosActivity = [REActivity activityWithName:@"Sonos Activity"];
         [controller registerActivity:sonosActivity];
         sonosActivity.launchMacro = [REMacroBuilder activityMacroForActivity:1 toInitiateState:YES];
         sonosActivity.haltMacro   = [REMacroBuilder activityMacroForActivity:0 toInitiateState:YES];

         RERemote   * sonosRemote   = [RERemoteBuilder constructSonosRemote];
//         [nightshadeTheme applyThemeToElement:sonosRemote];
         sonosActivity.remote = sonosRemote;

         // Home Remote
         RERemote * homeRemote = [RERemoteBuilder constructHomeRemote];
//         [nightshadeTheme applyThemeToElement:homeRemote];
         [controller registerHomeRemote:homeRemote];
     }];
}

@end
