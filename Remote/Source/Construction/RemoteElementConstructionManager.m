//
// RemoteElementConstructionManager.m
// Remote
//
// Created by Jason Cardwell on 10/23/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteConstruction.h"
#import "RemoteElement_Private.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

@implementation RemoteElementConstructionManager

+ (void)buildController
{
    MSLogDebugTag(@"beginning remote construction...");

/*
    [CoreDataManager saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         localContext.nametag = @"remote element construction manager context";

         // create controller
         RemoteController * controller = [RemoteController MR_findFirstInContext:localContext];
         assert(!controller);
         controller = [RemoteController remoteControllerInContext:localContext];
         assert(controller);
     }];
*/


    [CoreDataManager saveWithBlockAndWait:
      ^(NSManagedObjectContext * localContext)
      {
         // create builtin themes
          BuiltinTheme * nightshadeTheme = [BuiltinTheme MR_findFirstByAttribute:@"name"
                                                                       withValue:REThemeNightshadeName
                                                                       inContext:localContext];
          if (nightshadeTheme)
              [localContext deleteObject:nightshadeTheme];

          nightshadeTheme =  [BuiltinTheme themeWithName:REThemeNightshadeName context:localContext];
          assert(nightshadeTheme);

          BuiltinTheme * powerBlueTheme = [BuiltinTheme themeWithName:REThemePowerBlueName
                                                              context:localContext];
          assert(powerBlueTheme);
     }];

/*
    [CoreDataManager saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         ButtonGroup * topToolbar = [ButtonGroupBuilder
                                       constructControllerTopToolbarInContext:localContext];
         [[BuiltinTheme themeWithName:@"Nightshade" context:localContext] applyThemeToElement:topToolbar];

         RemoteController * controller = [RemoteController MR_findFirstInContext:localContext];

         assert(topToolbar.managedObjectContext == controller.managedObjectContext);
         [controller registerTopToolbar:topToolbar];
     }];
*/

/*
    [CoreDataManager saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         // attach power on/off commands to components
         ComponentDevice * avReceiver = [ComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                         context:localContext];
         avReceiver.inputPowersOn       = YES;
         avReceiver.offCommand          = [SendIRCommand commandWithIRCode:avReceiver[@"Power"]];

         ComponentDevice * hopper = [ComponentDevice fetchDeviceWithName:@"Dish Hopper"
                                                                         context:localContext];
         hopper.alwaysOn            = YES;

         ComponentDevice * samsungTV  = [ComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                         context:localContext];
         samsungTV.offCommand           = [SendIRCommand commandWithIRCode:samsungTV[@"Power Off"]];
         samsungTV.onCommand            = [SendIRCommand commandWithIRCode:samsungTV[@"Power On"]];

         ComponentDevice * ps3        = [ComponentDevice fetchDeviceWithName:@"PS3"
                                                                         context:localContext];
         ps3.offCommand                 = [SendIRCommand commandWithIRCode:ps3[@"Discrete Off"]];
         ps3.onCommand                  = [SendIRCommand commandWithIRCode:ps3[@"Discrete On"]];
     }];
*/

    // [NSManagedObjectContext saveWithBlockAndWait:
/*
    [CoreDataManager saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         // Dish Hopper Activity
         Activity * hopperActivity = [Activity activityWithName:@"Dish Hopper Activity"
                                                       inContext:localContext];
         RemoteController * controller = [RemoteController MR_findFirstInContext:localContext];
         [controller registerActivity:hopperActivity];
         hopperActivity.launchMacro = [MacroBuilder activityMacroForActivity:1
                                                            toInitiateState:YES
                                                                    context:localContext];
         hopperActivity.haltMacro   = [MacroBuilder activityMacroForActivity:0
                                                            toInitiateState:YES
                                                                    context:localContext];

         Remote   * hopperRemote   = [RemoteBuilder constructDVRRemoteInContext:localContext];
         [[BuiltinTheme themeWithName:@"Nightshade" context:localContext] applyThemeToElement:hopperRemote];
         hopperActivity.remote = hopperRemote;
     }];
*/

    // [NSManagedObjectContext saveWithBlockAndWait:
/*
    [CoreDataManager saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         // Playstation Activity
         Activity * ps3Activity = [Activity activityWithName:@"Playstation Activity"
                                                       inContext:localContext];
         RemoteController * controller = [RemoteController MR_findFirstInContext:localContext];
         [controller registerActivity:ps3Activity];
         ps3Activity.launchMacro = [MacroBuilder activityMacroForActivity:1
                                                            toInitiateState:YES
                                                                    context:localContext];
         ps3Activity.haltMacro   = [MacroBuilder activityMacroForActivity:0
                                                            toInitiateState:YES
                                                                    context:localContext];

         Remote   * ps3Remote   = [RemoteBuilder constructPS3RemoteInContext:localContext];
         [[BuiltinTheme themeWithName:@"Nightshade" context:localContext] applyThemeToElement:ps3Remote];
         ps3Activity.remote = ps3Remote;
     }];
*/

    // [NSManagedObjectContext saveWithBlockAndWait:
/*
    [CoreDataManager saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         // TV Activity
         Activity * appleTVActivity = [Activity activityWithName:@" TV Activity"
                                                           inContext:localContext];
         RemoteController * controller = [RemoteController MR_findFirstInContext:localContext];
         [controller registerActivity:appleTVActivity];
         appleTVActivity.launchMacro = [MacroBuilder activityMacroForActivity:1
                                                                toInitiateState:YES
                                                                        context:localContext];
         appleTVActivity.haltMacro   = [MacroBuilder activityMacroForActivity:0
                                                                toInitiateState:YES
                                                                        context:localContext];
     }];
*/

    // [NSManagedObjectContext saveWithBlockAndWait:
/*
    [CoreDataManager saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         // Sonos Activity
         Activity * sonosActivity = [Activity activityWithName:@"Sonos Activity"
                                                         inContext:localContext];
         RemoteController * controller = [RemoteController MR_findFirstInContext:localContext];
         [controller registerActivity:sonosActivity];
         sonosActivity.launchMacro = [MacroBuilder activityMacroForActivity:1
                                                              toInitiateState:YES
                                                                      context:localContext];
         sonosActivity.haltMacro   = [MacroBuilder activityMacroForActivity:0
                                                              toInitiateState:YES
                                                                      context:localContext];

         Remote   * sonosRemote   = [RemoteBuilder constructSonosRemoteInContext:localContext];
         [[BuiltinTheme themeWithName:@"Nightshade" context:localContext] applyThemeToElement:sonosRemote];
         sonosActivity.remote = sonosRemote;
    }];
*/

    // [NSManagedObjectContext saveWithBlockAndWait:
/*
    [CoreDataManager saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         // Home Remote
         Remote * homeRemote = [RemoteBuilder constructHomeRemoteInContext:localContext];
         [[BuiltinTheme themeWithName:@"Nightshade" context:localContext] applyThemeToElement:homeRemote];
         RemoteController * controller = [RemoteController MR_findFirstInContext:localContext];
         [controller registerHomeRemote:homeRemote];
     }];
*/

/*
    [CoreDataManager resetDefaultContext];

    [MSJSONSerialization writeJSONObject:[RemoteController remoteController]
                                filePath:[@"/" join:@[DocumentsFilePath, @"RemoteController.json"]]];

    [MSJSONSerialization writeJSONObject:[[Remote MR_findAllSortedBy:@"name" ascending:YES]
                                          valueForKeyPath:@"JSONDictionary"]
                                filePath:[@"/" join:@[DocumentsFilePath, @"Remote.json"]]];

    [MSJSONSerialization writeJSONObject:[[ComponentDevice MR_findAllSortedBy:@"info.name" ascending:YES]
                                          valueForKeyPath:@"JSONDictionary"]
                                filePath:[@"/" join:@[DocumentsFilePath, @"ComponentDevice.json"]]];

    [MSJSONSerialization writeJSONObject:[[Manufacturer MR_findAllSortedBy:@"info.name" ascending:YES]
                                          valueForKeyPath:@"JSONDictionary"]
                                filePath:[@"/" join:@[DocumentsFilePath, @"Manufacturer.json"]]];
    
    [MSJSONSerialization writeJSONObject:[[Image MR_findAll] valueForKeyPath:@"JSONDictionary"]
                                filePath:[@"/" join:@[DocumentsFilePath, @"Image.json"]]];
*/


//#define LOG_CONSTRUCTED_ELEMENTS

//#ifdef LOG_CONSTRUCTED_ELEMENTS
//
//    RERemoteController * controller = [RERemoteController MR_findFirst];
//    assert(controller);
//
//    controller.managedObjectContext.nametag = @"default";
//
//    NSSet * remotes = controller.remotes;
//    assert(remotes);
//
//    NSMutableArray * constructedElementDescriptions = [@[] mutableCopy];
//
//    for (RERemote * remote in remotes) {
//        NSMutableString * remoteDescription = [NSMutableString stringWithFormat:@"%@\n", [remote deepDescription]];
//        for (REButtonGroup * buttonGroup in remote.subelements) {
//            [remoteDescription appendFormat:@"%@\n", [buttonGroup deepDescription]];
//            for (REButton * button in buttonGroup.subelements) {
//                [remoteDescription appendFormat:@"%@\n", [button deepDescription]];
//            }
//        }
//        [constructedElementDescriptions addObject:remoteDescription];
//    }
//    NSString * constructedElementsDescription = [constructedElementDescriptions
//                                                 componentsJoinedByString:[NSString stringWithFormat:@"%@\n",
//                                                                                                     [NSString stringWithCharacter:'#' count:80]]];
//
//    MSLogDebugInContext(LOG_CONTEXT_CONSOLE,
//                        @"%@\n%@\n",
//                        [@"Constructed Remote Elements" singleBarMessageBox],
//                        constructedElementsDescription);
//
//#endif

    MSLogDebugTag(@"remote construction complete");
}

@end
