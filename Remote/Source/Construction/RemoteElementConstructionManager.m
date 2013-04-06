//
// RemoteElementConstructionManager.m
// Remote
//
// Created by Jason Cardwell on 10/23/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteConstruction.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = CONSOLE_LOG_CONTEXT;
#pragma unused(ddLogLevel, msLogContext)

@implementation RemoteElementConstructionManager

+ (RemoteElementConstructionManager *)sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static RemoteElementConstructionManager * _sharedObject = nil;
    dispatch_once(&pred,^{ _sharedObject = [self new]; });
    return _sharedObject;
}

- (BOOL)buildRemoteControllerInContext:(NSManagedObjectContext *)context
{
    _buildContext = context;
    MSLogDebugTag(@"build context:<%@:%p>", _buildContext.nametag, _buildContext);

    __block BOOL success = NO;

    // remove existing and rebuild
    [_buildContext
     performBlockAndWait:
     ^{
         assert([_buildContext countForFetchRequest:[NSFetchRequest fetchRequestWithEntityName:
                                                     ClassString([RERemoteController class])]
                                              error:nil] == 0);

         _remoteBuilder = [RERemoteBuilder builderWithContext:_buildContext];
         _buttonGroupBuilder = [REButtonGroupBuilder builderWithContext:_buildContext];
         _buttonBuilder = [REButtonBuilder builderWithContext:_buildContext];
         _macroBuilder = [MacroBuilder builderWithContext:_buildContext];

         success = [self buildController];
     }];

    return success;
}

- (BOOL)buildController
{
    __block BOOL success = NO;
    [_buildContext performBlockAndWait:
     ^{
         RERemoteController * controller = [RERemoteController remoteControllerInContext:_buildContext];

         controller.topToolbar = [_buttonGroupBuilder constructRemoteViewControllerTopBarButtonGroup];

         BOComponentDevice * avReceiver = [BOComponentDevice fetchDeviceWithName:@"AV Receiver"
                                                                         context:_buildContext];

         avReceiver.inputPowersOn = YES;
         avReceiver.offCommand    = MakeIRCommand(avReceiver, @"Power");

         BOComponentDevice * comcastDVR = [BOComponentDevice fetchDeviceWithName:@"Comcast DVR"
                                                                         context:_buildContext];

         comcastDVR.alwaysOn = YES;

         BOComponentDevice * samsungTV = [BOComponentDevice fetchDeviceWithName:@"Samsung TV"
                                                                        context:_buildContext];

         samsungTV.offCommand = MakeIRCommand(samsungTV, @"Power Off");
         samsungTV.onCommand = MakeIRCommand(samsungTV, @"Power On");

         BOComponentDevice * ps3 = [BOComponentDevice fetchDeviceWithName:@"PS3"
                                                                  context:_buildContext];

         ps3.offCommand = MakeIRCommand(ps3, @"Discrete Off");
         ps3.onCommand  = MakeIRCommand(ps3, @"Discrete On");

         if (![_remoteBuilder constructHomeRemote])
         {
             MSLogErrorTag(@"failed to construct home remote");

             return;
         }

         // dvr activity remote
         if (![_remoteBuilder constructDVRRemote])
         {
             MSLogErrorTag(@"failed to construct dvr remote");

             return;
         }

         // ps3 activity remote
         if (![_remoteBuilder constructPS3Remote])
         {
             MSLogErrorTag(@"failed to construct ps3 remote");

             return;
         }
         
         // sonos activity remote
         if (![_remoteBuilder constructSonosRemote])
         {
             MSLogErrorTag(@"failed to construct sonos remote");
             
             return;
         }
         
         else if (![CoreDataManager saveContext:_buildContext asynchronous:NO completion:nil])
             return;
         
         
         success = YES;
     }];
    
    return success;
}

@end
