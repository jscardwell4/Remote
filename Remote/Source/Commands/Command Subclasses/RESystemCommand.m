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
static int msLogContext = COMMAND_F_C;

#define kSystemKeyMax 4
#define kSystemKeyMin 0

static __weak RERemoteViewController * _remoteViewController;

@interface RESystemCommandOperation : RECommandOperation @end

@implementation RESystemCommand

@dynamic type;

+ (RESystemCommand *)commandInContext:(NSManagedObjectContext *)context type:(RESystemCommandType)type
{
    __block RESystemCommand * cmd = nil;

    [context performBlockAndWait:
     ^{
         NSFetchRequest * fetchRequest = NSFetchRequestFromClassWithPredicate(@"type == %i", type);
         NSError * error = nil;
         NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

         if (!fetchedObjects || [fetchedObjects count] == 0)
         {
             if (type >= kSystemKeyMin && type <= kSystemKeyMax)
             {
                 cmd = [self commandInContext:context];
                 cmd.type = type;
             }
             
             else
                 DDLogWarn(@"%@ RESystemCommandType invalid:%d", ClassTagSelectorString, type);
        }

         else cmd = [fetchedObjects lastObject];
     }];

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