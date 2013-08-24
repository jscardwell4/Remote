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

+ (void)buildController
{
    MSLogDebugTag(@"beginning remote construction...");
    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         localContext.nametag = @"remote element construction manager context";

         // create controller
         RERemoteController * controller = [RERemoteController MR_findFirstInContext:localContext];
         assert(!controller);
         controller = [RERemoteController remoteControllerInContext:localContext];
         assert(controller);
     }];

     [NSManagedObjectContext saveWithBlockAndWait:
      ^(NSManagedObjectContext * localContext)
      {
         // create builtin themes
          REBuiltinTheme * nightshadeTheme = [REBuiltinTheme MR_findFirstByAttribute:@"name"
                                                                           withValue:REThemeNightshadeName
                                                                           inContext:localContext];
          if (nightshadeTheme)
              [localContext deleteObject:nightshadeTheme];

          nightshadeTheme =  [REBuiltinTheme themeWithName:REThemeNightshadeName context:localContext];
         assert(nightshadeTheme);

         REBuiltinTheme * powerBlueTheme = [REBuiltinTheme themeWithName:REThemePowerBlueName
                                                                 context:localContext];
         assert(powerBlueTheme);
     }];

    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         REButtonGroup * topToolbar = [REButtonGroupBuilder
                                       constructControllerTopToolbarInContext:localContext];
         [[REBuiltinTheme themeWithName:@"Nightshade" context:localContext] applyThemeToElement:topToolbar];

         RERemoteController * controller = [RERemoteController MR_findFirstInContext:localContext];

         assert(topToolbar.managedObjectContext == controller.managedObjectContext);
         [controller registerTopToolbar:topToolbar];
     }];

    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         // attach power on/off commands to components
         BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                         context:localContext];
         avReceiver.inputPowersOn       = YES;
         avReceiver.offCommand          = [RESendIRCommand commandWithIRCode:avReceiver[@"Power"]];

         BOComponentDevice * comcastDVR = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                         context:localContext];
         comcastDVR.alwaysOn            = YES;

         BOComponentDevice * samsungTV  = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                         context:localContext];
         samsungTV.offCommand           = [RESendIRCommand commandWithIRCode:samsungTV[@"Power Off"]];
         samsungTV.onCommand            = [RESendIRCommand commandWithIRCode:samsungTV[@"Power On"]];

         BOComponentDevice * ps3        = [BOComponentDevice fetchDeviceWithName:@"PS3"
                                                                         context:localContext];
         ps3.offCommand                 = [RESendIRCommand commandWithIRCode:ps3[@"Discrete Off"]];
         ps3.onCommand                  = [RESendIRCommand commandWithIRCode:ps3[@"Discrete On"]];
     }];

    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         // Comcast DVR Activity
         REActivity * dvrActivity = [REActivity activityWithName:@"Comcast DVR Activity"
                                                       inContext:localContext];
         RERemoteController * controller = [RERemoteController MR_findFirstInContext:localContext];
         [controller registerActivity:dvrActivity];
         dvrActivity.launchMacro = [REMacroBuilder activityMacroForActivity:1
                                                            toInitiateState:YES
                                                                    context:localContext];
         dvrActivity.haltMacro   = [REMacroBuilder activityMacroForActivity:0
                                                            toInitiateState:YES
                                                                    context:localContext];

         RERemote   * dvrRemote   = [RERemoteBuilder constructDVRRemoteInContext:localContext];
         [[REBuiltinTheme themeWithName:@"Nightshade" context:localContext] applyThemeToElement:dvrRemote];
         dvrActivity.remote = dvrRemote;

         [controller registerHomeRemote:dvrRemote];

     }];

    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         // Playstation Activity
         REActivity * ps3Activity = [REActivity activityWithName:@"Playstation Activity"
                                                       inContext:localContext];
         RERemoteController * controller = [RERemoteController MR_findFirstInContext:localContext];
         [controller registerActivity:ps3Activity];
         ps3Activity.launchMacro = [REMacroBuilder activityMacroForActivity:1
                                                            toInitiateState:YES
                                                                    context:localContext];
         ps3Activity.haltMacro   = [REMacroBuilder activityMacroForActivity:0
                                                            toInitiateState:YES
                                                                    context:localContext];

         RERemote   * ps3Remote   = [RERemoteBuilder constructPS3RemoteInContext:localContext];
         [[REBuiltinTheme themeWithName:@"Nightshade" context:localContext] applyThemeToElement:ps3Remote];
         ps3Activity.remote = ps3Remote;
     }];

    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         // TV Activity
         REActivity * appleTVActivity = [REActivity activityWithName:@" TV Activity"
                                                           inContext:localContext];
         RERemoteController * controller = [RERemoteController MR_findFirstInContext:localContext];
         [controller registerActivity:appleTVActivity];
         appleTVActivity.launchMacro = [REMacroBuilder activityMacroForActivity:1
                                                                toInitiateState:YES
                                                                        context:localContext];
         appleTVActivity.haltMacro   = [REMacroBuilder activityMacroForActivity:0
                                                                toInitiateState:YES
                                                                        context:localContext];
     }];

    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         // Sonos Activity
         REActivity * sonosActivity = [REActivity activityWithName:@"Sonos Activity"
                                                         inContext:localContext];
         RERemoteController * controller = [RERemoteController MR_findFirstInContext:localContext];
         [controller registerActivity:sonosActivity];
         sonosActivity.launchMacro = [REMacroBuilder activityMacroForActivity:1
                                                              toInitiateState:YES
                                                                      context:localContext];
         sonosActivity.haltMacro   = [REMacroBuilder activityMacroForActivity:0
                                                              toInitiateState:YES
                                                                      context:localContext];

         RERemote   * sonosRemote   = [RERemoteBuilder constructSonosRemoteInContext:localContext];
         [[REBuiltinTheme themeWithName:@"Nightshade" context:localContext] applyThemeToElement:sonosRemote];
         sonosActivity.remote = sonosRemote;
     }];

    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         // Home Remote
         RERemote * homeRemote = [RERemoteBuilder constructHomeRemoteInContext:localContext];
         [[REBuiltinTheme themeWithName:@"Nightshade" context:localContext] applyThemeToElement:homeRemote];
//         RERemoteController * controller = [RERemoteController MR_findFirstInContext:localContext];
//         [controller registerHomeRemote:homeRemote];
     }];

    [NSManagedObjectContext MR_resetDefaultContext];

//#define LOG_CONSTRUCTED_ELEMENTS
#ifdef LOG_CONSTRUCTED_ELEMENTS

    RERemoteController * controller = [RERemoteController MR_findFirst];
    assert(controller);

    controller.managedObjectContext.nametag = @"default";

    NSSet * remotes = controller.remotes;
    assert(remotes);

    NSMutableArray * constructedElementDescriptions = [@[] mutableCopy];

    for (RERemote * remote in remotes) {
        NSMutableString * remoteDescription = [NSMutableString stringWithFormat:@"%@\n", [remote deepDescription]];
        for (REButtonGroup * buttonGroup in remote.subelements) {
            [remoteDescription appendFormat:@"%@\n", [buttonGroup deepDescription]];
            for (REButton * button in buttonGroup.subelements) {
                [remoteDescription appendFormat:@"%@\n", [button deepDescription]];
            }
        }
        [constructedElementDescriptions addObject:remoteDescription];
    }
    NSString * constructedElementsDescription = [constructedElementDescriptions
                                                 componentsJoinedByString:[NSString stringWithFormat:@"%@\n",
                                                                                                     [NSString stringWithCharacter:'#' count:80]]];

    MSLogDebugInContext(LOG_CONTEXT_CONSOLE,
                        @"%@\n%@\n",
                        [@"Constructed Remote Elements" singleBarMessageBox],
                        constructedElementsDescription);

#endif

    MSLogDebugTag(@"remote construction complete");
}

@end
