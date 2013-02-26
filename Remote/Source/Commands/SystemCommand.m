//
// SystemCommand.m
// iPhonto
//
// Created by Jason Cardwell on 7/13/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "Command.h"
#import "Command_Private.h"
#import "Button.h"
#import "ButtonView.h"
#import "RemoteViewController.h"
#import "MSRemoteAppController.h"

#define kSystemKeyMax 4
#define kSystemKeyMin 0

static int                           ddLogLevel = DefaultDDLogLevel;
static __weak RemoteViewController * _remoteViewController;

@interface SystemCommand ()

/**
 * `SystemCommandKey` for specifying the command's task.
 *              typedef enum {
 *                      SystemCommandToggleProximitySensor = 0,
 *                      SystemCommandURLRequest = 1
 *              } SystemCommandKey;
 */
@property (nonatomic, assign) SystemCommandKey   key;

@end

@implementation SystemCommand

@dynamic key;

/// @name ￼Getting a SystemCommand

+ (SystemCommand *)systemCommandWithKey:(SystemCommandKey)key
                              inContext:(NSManagedObjectContext *)context {
    __block SystemCommand * fetchedCommand = nil;

    [context performBlockAndWait:^{
                 NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SystemCommand"];
                 [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"key == %i", key]];

                 NSError * error = nil;
                 NSArray * fetchedObjects = [context          executeFetchRequest:fetchRequest
                                                                   error:&error];

                 if (!fetchedObjects || [fetchedObjects count] == 0) {
                 if (key >= kSystemKeyMin && key <= kSystemKeyMax) {
                 fetchedCommand = [NSEntityDescription  insertNewObjectForEntityForName:@"SystemCommand"
                                                                inManagedObjectContext:context];
                 fetchedCommand.key = key;
                 } else
                 DDLogWarn(@"%@ SystemCommandKey invalid:%d", ClassTagSelectorString, key);
        } else
                 fetchedCommand = [fetchedObjects lastObject];
    }

    ];

    return fetchedCommand;
}

+ (BOOL)registerRemoteViewController:(RemoteViewController *)remoteViewController {
    _remoteViewController = remoteViewController;

    return YES;
}

/// @name ￼Executing system commands

/**
 * Invokes the `SystemCommand` method for executing the task associated with the command's key.
 * @param sender Object to notify after execution.
 * @param options Options to apply when executing command.
 */
- (void)execute:(id <CommandDelegate> )sender {
    [super execute:sender];
    assert(_remoteViewController);
    switch (self.key) {
        case SystemCommandToggleProximitySensor : {
            CurrentDevice.proximityMonitoringEnabled = !CurrentDevice.proximityMonitoringEnabled;
            [self commandDidComplete:self success:YES];
        }   break;

        case SystemCommandURLRequest : {
            DDLogWarn(@"%@ currently 'SystemCommandURLRequest' does nothing", ClassTagSelectorString);
            [self commandDidComplete:self success:YES];
        }   break;

        case SystemCommandReturnToLaunchScreen : {
            MSRunAsyncOnMain (^{[_remoteViewController dismissViewControllerAnimated:YES
                                 completion:^{[self commandDidComplete:self
                                               success:YES]; }

                                ]; }

                              );
        }   break;

        case SystemCommandOpenSettings : {
            MSRunAsyncOnMain (^{[_remoteViewController openSettings:self]; }

                              );
            [self commandDidComplete:self success:YES];
        }  break;

        case SystemCommandOpenEditor : {
            MSRunAsyncOnMain (^{[_remoteViewController editCurrentRemote:self]; }

                              );
            [self commandDidComplete:self success:YES];
        }    break;
    }  /* switch */
}

@end
