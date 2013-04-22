//
//  SwitchToConfigCommand.m
//  Remote
//
//  Created by Jason Cardwell on 3/25/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RECommand_Private.h"
#import "RERemoteController.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);

@interface RESwitchToConfigCommandOperation : RECommandOperation @end

@implementation RESwitchToConfigCommand

@dynamic remoteController, configuration;

+ (RESwitchToConfigCommand *)commandWithConfiguration:(RERemoteConfiguration)configuration
{
    return [self commandWithConfiguration:configuration
                                inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (RESwitchToConfigCommand *)commandWithConfiguration:(RERemoteConfiguration)configuration
                                            inContext:(NSManagedObjectContext *)context
{
    RESwitchToConfigCommand * command = [self commandInContext:context];
    command.remoteController = [RERemoteController remoteControllerInContext:context];
    command.configuration = configuration;
    return command;
}

- (RECommandOperation *)operation
{
    return [RESwitchToConfigCommandOperation operationForCommand:self];
}

- (NSString *)shortDescription { return $(@"configuration:'%@'", self.primitiveConfiguration); }

@end

@implementation RESwitchToConfigCommandOperation

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