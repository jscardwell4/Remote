//
// SendCommand.m
// Remote
//
// Created by Jason Cardwell on 3/28/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "Command_Private.h"
#import "ConnectionManager.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)


@interface SendCommandOperation : CommandOperation @end

@implementation SendCommand

- (NSOperation *)operation { return [SendCommandOperation operationForCommand:self]; }

@end

@implementation SendCommandOperation

- (void)main
{
    @try
    {
        NSManagedObjectID * commandID = _command.objectID;
        MSLogDebugTag(@"command ID:'%@', %@", commandID, [_command shortDescription]);
        [ConnectionManager
             sendCommand:commandID
              completion:^(BOOL success, NSError * error)
                         {
                             MSLogDebugTag(@"command ID:%@\ncompletion: success? %@ error - %@",
                                           commandID,
                                           BOOLString(success),
                                           error);
                             _success = success;
                             _error   = error;
                             [super main];
                         }];
    }

    @catch (NSException *exception)
    {
        MSLogDebugTag(@"wtf, %@", [exception description]);
    }

}

@end
