//
//  ActivityCommand.m
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "Command_Private.h"
#import "Activity.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

@interface ActivityCommandOperation : RECommandOperation @end


@implementation ActivityCommand

@dynamic activity;

+ (ActivityCommand *)commandWithActivity:(Activity *)activity
{
    ActivityCommand * command = [self commandInContext:activity.managedObjectContext];
    command.activity = activity;
    return command;
}

- (RECommandOperation *)operation { return [ActivityCommandOperation operationForCommand:self]; }

- (NSString *)shortDescription
{
    return $(@"activity: %@", (self.activity.name ?: @"nil"));
}

@end

@implementation ActivityCommandOperation

- (void)main
{
    @try
    {
        Activity * activity = ((ActivityCommand *)_command).activity;
        [activity launchOrHault:^(BOOL success, NSError *error)
         {
             _success = success;
             _finished = YES;
             [super main];
         }];
    }
    @catch (NSException * exception)
    {
        MSLogDebugTag(@"wtf?");
    }
}

@end