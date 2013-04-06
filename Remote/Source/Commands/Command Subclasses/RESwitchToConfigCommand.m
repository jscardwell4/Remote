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
static int msLogContext = COMMAND_F_C;

@interface RESwitchToConfigCommandOperation : RECommandOperation @end

@implementation RESwitchToConfigCommand

@dynamic remoteController, configuration;

+ (RESwitchToConfigCommand *)configCommandInContext:(NSManagedObjectContext *)ctx
                                    configuration:(RERemoteConfiguration)config
{
    __block RESwitchToConfigCommand * command = nil;

    [ctx performBlockAndWait:
     ^{
         command = (RESwitchToConfigCommand *)[super commandInContext:ctx];
         if (command)
         {
             command.primitiveRemoteController = [RERemoteController remoteControllerInContext:ctx];
             command.primitiveConfiguration = config;
         }
     }];

    return command;
}

/*
- (void)execute:(void (^)(BOOL, BOOL))completion
{
    [super execute:completion];
    assert(NO);
}
*/

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