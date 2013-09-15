//
//  SwitchToConfigCommand.m
//  Remote
//
//  Created by Jason Cardwell on 3/25/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "Command_Private.h"
#import "RemoteController.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);

@interface SwitchToConfigCommandOperation : RECommandOperation @end

@implementation SwitchToConfigCommand

@dynamic remoteController, configuration;

+ (SwitchToConfigCommand *)commandWithConfiguration:(RERemoteConfiguration)configuration
{
    return [self commandWithConfiguration:configuration
                                inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (SwitchToConfigCommand *)commandWithConfiguration:(RERemoteConfiguration)configuration
                                            inContext:(NSManagedObjectContext *)context
{
    SwitchToConfigCommand * command = [self commandInContext:context];
    command.remoteController = [RemoteController remoteControllerInContext:context];
    command.configuration = configuration;
    return command;
}

- (RECommandOperation *)operation
{
    return [SwitchToConfigCommandOperation operationForCommand:self];
}

- (NSString *)shortDescription { return $(@"configuration:'%@'", self.primitiveConfiguration); }

@end

@implementation SwitchToConfigCommandOperation

- (void)main
{
    @try
    {
        _success = NO;
        [super main];
    }
    
    @catch (NSException * exception)
    {
        MSLogDebugTag(@"seriously, wtf?");
    }
}

@end