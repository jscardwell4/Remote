//
// SystemCommand.m
// Remote
//
// Created by Jason Cardwell on 7/13/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "RECommand_Private.h"
#import "REView.h"
#import "RERemoteViewController.h"
#import "MSRemoteAppController.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);

#define kSystemKeyMax 4
#define kSystemKeyMin 0

BOOL isValidSystemType(RESystemCommandType type) { return ((NSInteger)type > -1 && (NSInteger)type < 5); }

static __weak RERemoteViewController * _remoteViewController;

@interface RESystemCommandOperation : RECommandOperation @end

@implementation RESystemCommand

@dynamic type;

+ (RESystemCommand *)commandWithType:(RESystemCommandType)type
{
    return [self commandWithType:type inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (RESystemCommand *)commandWithType:(RESystemCommandType)type
                           inContext:(NSManagedObjectContext *)context
{
    BOOL isValidType = isValidSystemType(type);
    if (!isValidType) return nil;

    RESystemCommand * cmd = [self MR_findFirstByAttribute:@"type"
                                                withValue:@(type)
                                                inContext:context];
    if (!cmd)
    {
        cmd = [self commandInContext:context];
        cmd.type = type;
    }

    return cmd;
}

- (void)setType:(RESystemCommandType)type
{
    [self willChangeValueForKey:@"type"];
    _type = type;
    [self didAccessValueForKey:@"type"];
}

- (RESystemCommandType)type
{
    [self willAccessValueForKey:@"type"];
    RESystemCommandType type = _type;
    [self didAccessValueForKey:@"type"];
    return type;
}

+ (BOOL)registerRemoteViewController:(RERemoteViewController *)remoteViewController
{
    _remoteViewController = remoteViewController;

    return YES;
}

- (RECommandOperation *)operation
{
    return [RESystemCommandOperation operationForCommand:self];
}

- (NSString *)shortDescription
{
    return $(@"type:%@", NSStringFromRESystemCommandType(_type));
}

@end

@implementation RESystemCommandOperation

- (void)main
{
    @try
    {
        __block BOOL      taskComplete  = NO;
        RESystemCommand * systemCommand = (RESystemCommand*)_command;

        switch (systemCommand.type)
        {
            case RESystemCommandToggleProximitySensor:
            {
                CurrentDevice.proximityMonitoringEnabled = !CurrentDevice.proximityMonitoringEnabled;
                _success                                 = YES;
                taskComplete                             = YES;
            }   break;

            case RESystemCommandURLRequest:
            {
                MSLogWarn(@"currently 'RESystemCommandURLRequest' does nothing");
                _success     = YES;
                taskComplete = YES;
            }   break;

            case RESystemCommandReturnToLaunchScreen:
            {
                MSRunAsyncOnMain (^{ [_remoteViewController
                                      dismissViewControllerAnimated:YES
                                                         completion:^{
                                          taskComplete = YES;
                                      }]; });
            }   break;

            case RESystemCommandOpenSettings:
            {
                MSRunAsyncOnMain (^{ [_remoteViewController openSettings:_command]; });
                _success     = YES;
                taskComplete = YES;
            }  break;

            case RESystemCommandOpenEditor:
            {
                MSRunAsyncOnMain (^{ [_remoteViewController editCurrentRemote:_command]; });
                _success     = YES;
                taskComplete = YES;
            }    break;

            default:
                taskComplete = YES;
                _success     = NO;
                break;
        }

        while (!taskComplete);
        [super main];
    }
    @catch(NSException * exception)
    {
        MSLogDebugTag(@"wtf?");
    }
}


@end