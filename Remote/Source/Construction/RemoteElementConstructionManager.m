//
// RemoteElementConstructionManager.m
// Remote
//
// Created by Jason Cardwell on 10/23/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteConstruction.h"

static const int ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

@implementation RemoteElementConstructionManager

+ (void)buildControllerInContext:(NSManagedObjectContext *)context
{
    __block RERemoteController * controller = nil;
//    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
    context.nametag = @"REMOTE CONSTRUCTION";
// [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
//  ^(NSManagedObjectContext * context)
//  {
    [context performBlockAndWait:
     ^{
         context.nametag = @"remote element construction manager context";
         [context MR_setWorkingName:context.nametag];

         // create controller
         controller = [RERemoteController MR_findFirstInContext:context];
         assert(!controller);
         controller = [RERemoteController remoteControllerInContext:context];
         assert(controller);
     }];

    // [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
    //  ^(NSManagedObjectContext * context)
    //  {
    [context performBlockAndWait:
     ^{
         // create builtin themes
         REBuiltinTheme * nightshadeTheme = [REBuiltinTheme themeWithName:REThemeNightshadeName];
         assert(nightshadeTheme);

         REBuiltinTheme * powerBlueTheme = [REBuiltinTheme themeWithName:REThemePowerBlueName];
         assert(powerBlueTheme);
     }];

    // [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
    //  ^(NSManagedObjectContext * context)
    //  {
    [context performBlockAndWait:
     ^{
         REButtonGroup * topToolbar = [REButtonGroupBuilder constructControllerTopToolbarInContext:context];

         // create top toolbar
         [controller registerTopToolbar:topToolbar];
     }];

    // [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
    //  ^(NSManagedObjectContext * context)
    //  {
    [context performBlockAndWait:
     ^{
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
     }];

    // [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
    //  ^(NSManagedObjectContext * context)
    //  {
    [context performBlockAndWait:
     ^{
         // Comcast DVR Activity
         REActivity * dvrActivity = [REActivity activityWithName:@"Comcast DVR Activity"];
         [controller registerActivity:dvrActivity];
         dvrActivity.launchMacro = [REMacroBuilder activityMacroForActivity:1 toInitiateState:YES context:context];
         dvrActivity.haltMacro   = [REMacroBuilder activityMacroForActivity:0 toInitiateState:YES context:context];

         RERemote   * dvrRemote   = [RERemoteBuilder constructDVRRemoteInContext:context];
         //         [nightshadeTheme applyThemeToElement:dvrRemote];
         dvrActivity.remote = dvrRemote;
     }];

    // [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
    //  ^(NSManagedObjectContext * context)
    //  {
    [context performBlockAndWait:
     ^{
         // Playstation Activity
         REActivity * ps3Activity = [REActivity activityWithName:@"Playstation Activity"];
         [controller registerActivity:ps3Activity];
         ps3Activity.launchMacro = [REMacroBuilder activityMacroForActivity:1 toInitiateState:YES context:context];
         ps3Activity.haltMacro   = [REMacroBuilder activityMacroForActivity:0 toInitiateState:YES context:context];

         RERemote   * ps3Remote   = [RERemoteBuilder constructPS3RemoteInContext:context];
//         [nightshadeTheme applyThemeToElement:ps3Remote];
         ps3Activity.remote = ps3Remote;
     }];

    // [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
    //  ^(NSManagedObjectContext * context)
    //  {
    [context performBlockAndWait:
     ^{
         // TV Activity
         REActivity * appleTVActivity = [REActivity activityWithName:@" TV Activity"];
         [controller registerActivity:appleTVActivity];
         appleTVActivity.launchMacro = [REMacroBuilder activityMacroForActivity:1 toInitiateState:YES context:context];
         appleTVActivity.haltMacro   = [REMacroBuilder activityMacroForActivity:0 toInitiateState:YES context:context];
     }];

    // [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
    //  ^(NSManagedObjectContext * context)
    //  {
    [context performBlockAndWait:
     ^{
         // Sonos Activity
         REActivity * sonosActivity = [REActivity activityWithName:@"Sonos Activity"];
         [controller registerActivity:sonosActivity];
         sonosActivity.launchMacro = [REMacroBuilder activityMacroForActivity:1 toInitiateState:YES context:context];
         sonosActivity.haltMacro   = [REMacroBuilder activityMacroForActivity:0 toInitiateState:YES context:context];

         RERemote   * sonosRemote   = [RERemoteBuilder constructSonosRemoteInContext:context];
//         [nightshadeTheme applyThemeToElement:sonosRemote];
         sonosActivity.remote = sonosRemote;
     }];

    // [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
    //  ^(NSManagedObjectContext * context)
    //  {
    [context performBlockAndWait:
     ^{
         // Home Remote
         RERemote * homeRemote = [RERemoteBuilder constructHomeRemoteInContext:context];
//         [nightshadeTheme applyThemeToElement:homeRemote];
         [controller registerHomeRemote:homeRemote];
     }];
}

@end
