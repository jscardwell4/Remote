//
//  REActivityCommand.m
//  Remote
//
//  Created by Jason Cardwell on 4/10/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RECommand_Private.h"
#import "REActivity.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

@interface REActivityCommandOperation : RECommandOperation @end


@implementation REActivityCommand

@dynamic activity;

+ (REActivityCommand *)commandWithActivity:(REActivity *)activity
{
    REActivityCommand * command = [self commandInContext:activity.managedObjectContext];
    command.activity = activity;
    return command;
}

- (RECommandOperation *)operation { return [REActivityCommandOperation operationForCommand:self]; }

- (NSString *)shortDescription
{
    return $(@"activity: %@", (self.activity.name ?: @"nil"));
}

@end

@implementation REActivityCommandOperation

- (void)main
{
    @try
    {
        REActivity * activity = ((REActivityCommand *)_command).activity;
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