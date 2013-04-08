//
// RESendCommand.m
// Remote
//
// Created by Jason Cardwell on 3/28/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RECommand_Private.h"
#import "ConnectionManager.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = COMMAND_F_C;
#pragma unused(ddLogLevel, msLogContext)


@interface RESendCommandOperation : RECommandOperation @end

@implementation RESendCommand

- (NSOperation *)operation { return [RESendCommandOperation operationForCommand:self]; }

@end

@implementation RESendCommandOperation

- (void)main
{
    @try
    {
        NSManagedObjectID * commandID = _command.objectID;
        MSLogDebugTag(@"command ID:'%@', %@", commandID, [_command shortDescription]);
        [ConnectionManager
             sendCommand:commandID
              completion:^(BOOL finished, BOOL success)
                         {
                             MSLogDebugTag(@"command ID:%@\ncompletion: finished? %@, success? %@",
                                           commandID,
                                           BOOLString(finished),
                                           BOOLString(success));
                             _finished = finished;
                             _success = success;
                             [super main];
                         }];
    }

    @catch (NSException *exception)
    {
        MSLogDebugTag(@"wtf");
    }

}

@end
