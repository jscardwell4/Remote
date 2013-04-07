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

+ (BOOL)buildController
{

    __block BOOL success = [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
                            ^(NSManagedObjectContext * context)
                            {
                                RERemoteController * controller = [RERemoteController
                                                                   MR_findFirstInContext:context];
                                assert(!controller);
                                controller = [RERemoteController remoteControllerInContext:context];
                                assert(controller);
                                controller.topToolbar = [REButtonGroupBuilder
                                                         constructControllerTopToolbar];
                                
                                BOComponentDevice * avReceiver = [BOComponentDevice
                                                                  fetchDeviceWithName:@"AV Receiver"
                                                                              context:context];
                                assert(avReceiver);
                                avReceiver.inputPowersOn = YES;
                                avReceiver.offCommand    = MakeIRCommand(avReceiver, @"Power");
                                
                                BOComponentDevice * comcastDVR = [BOComponentDevice
                                                                  fetchDeviceWithName:@"Comcast DVR"
                                                                               context:context];
                                assert(comcastDVR);
                                comcastDVR.alwaysOn = YES;
                                
                                BOComponentDevice * samsungTV = [BOComponentDevice
                                                                 fetchDeviceWithName:@"Samsung TV"
                                                                             context:context];
                                assert(samsungTV);
                                samsungTV.offCommand = MakeIRCommand(samsungTV, @"Power Off");
                                samsungTV.onCommand  = MakeIRCommand(samsungTV, @"Power On");
                                
                                BOComponentDevice * ps3 = [BOComponentDevice
                                                           fetchDeviceWithName:@"PS3"
                                                                       context:context];
                                assert(ps3);
                                ps3.offCommand = MakeIRCommand(ps3, @"Discrete Off");
                                ps3.onCommand  = MakeIRCommand(ps3, @"Discrete On");
                            }];

    if (!success || ![MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
                      ^(NSManagedObjectContext *localContext)
                      {
                          success = ([RERemoteBuilder constructHomeRemote] != nil);
                      }]) return NO;
    
    if (!success || ![MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
                      ^(NSManagedObjectContext *localContext)
                      {
                          success = ([RERemoteBuilder constructDVRRemote] != nil);
                      }]) return NO;
    
    if (!success || ![MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
                      ^(NSManagedObjectContext *localContext)
                      {
                          success = ([RERemoteBuilder constructPS3Remote] != nil);
                      }]) return NO;

    if (!success || ![MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:
                      ^(NSManagedObjectContext *localContext)
                      {
                          success = ([RERemoteBuilder constructSonosRemote] != nil);
                      }]) return NO;


    return success;
}

@end
