//
// SystemCommand.m
// Remote
//
// Created by Jason Cardwell on 7/13/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "Command_Private.h"
#import "RemoteElementView.h"
#import "RemoteViewController.h"
#import "MSRemoteAppController.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);

#define kSystemKeyMax 4
#define kSystemKeyMin 0

BOOL isValidSystemType(SystemCommandType type) { return ((NSInteger)type > -1 && (NSInteger)type < 5); }

static __weak RemoteViewController * _remoteViewController;

@interface SystemCommandOperation : RECommandOperation @end

@implementation SystemCommand

@dynamic type;

+ (SystemCommand *)commandWithType:(SystemCommandType)type
{
    return [self commandWithType:type inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (SystemCommand *)commandWithType:(SystemCommandType)type
                           inContext:(NSManagedObjectContext *)context
{
    BOOL isValidType = isValidSystemType(type);
    if (!isValidType) return nil;

    SystemCommand * cmd = [self MR_findFirstByAttribute:@"type"
                                                withValue:@(type)
                                                inContext:context];
    if (!cmd)
    {
        cmd = [self commandInContext:context];
        cmd.type = type;
    }

    return cmd;
}

- (void)setType:(SystemCommandType)type
{
    [self willChangeValueForKey:@"type"];
    _type = type;
    [self didAccessValueForKey:@"type"];
}

- (SystemCommandType)type
{
    [self willAccessValueForKey:@"type"];
    SystemCommandType type = _type;
    [self didAccessValueForKey:@"type"];
    return type;
}

+ (BOOL)registerRemoteViewController:(RemoteViewController *)remoteViewController
{
    _remoteViewController = remoteViewController;

    return YES;
}

- (RECommandOperation *)operation
{
    return [SystemCommandOperation operationForCommand:self];
}

- (NSString *)shortDescription
{
    return $(@"type:%@", NSStringFromSystemCommandType(_type));
}

@end

@implementation SystemCommandOperation

- (void)main
{
    @try
    {
        __block BOOL      taskComplete  = NO;
        SystemCommand * systemCommand = (SystemCommand*)_command;

        switch (systemCommand.type)
        {
            case SystemCommandToggleProximitySensor:
            {
                CurrentDevice.proximityMonitoringEnabled = !CurrentDevice.proximityMonitoringEnabled;
                _success                                 = YES;
                taskComplete                             = YES;
            }   break;

            case SystemCommandURLRequest:
            {
                MSLogWarn(@"currently 'SystemCommandURLRequest' does nothing");
                _success     = YES;
                taskComplete = YES;
            }   break;

            case SystemCommandReturnToLaunchScreen:
            {
                MSRunAsyncOnMain (^{ [_remoteViewController
                                      dismissViewControllerAnimated:YES
                                                         completion:^{
                                          taskComplete = YES;
                                      }]; });
            }   break;

            case SystemCommandOpenSettings:
            {
                MSRunAsyncOnMain (^{ [_remoteViewController openSettings:_command]; });
                _success     = YES;
                taskComplete = YES;
            }  break;

            case SystemCommandOpenEditor:
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