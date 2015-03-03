//
//  CommandOperation.m
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

#import "CommandOperation.h"
#import "Remote-Swift.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)

@implementation CommandOperation

+ (instancetype)operationForCommand:(Command *)command {
  return [[self alloc] initWithCommand:command];
}

- (instancetype)initWithCommand:(Command *)command {
  if ((self = [self init])) {
    _command = command;
    _executing = NO;
    _finished = NO;
    _success = NO;
  }
  return self;
}

- (BOOL)isConcurrent { return YES; }

- (void)start {
  MSLogDebugTag(@"");

  // Always check for cancellation before launching the task.
  if ([self isCancelled]) {
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];

    return;
  } else if (self.dependencies.count && [self.dependencies objectPassingTest:
                                         ^BOOL (CommandOperation * operation, NSUInteger idx)
                                         {
                                           _error = operation.error;

                                           return !operation.wasSuccessful;
                                         }])
  {
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];

    return;
  }

  // If the operation is not canceled, begin executing the task.
  [self willChangeValueForKey:@"isExecuting"];
  [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
  _executing = YES;
  [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting { return _executing; }

- (BOOL)isFinished { return _finished; }

- (NSError *)error { return _error; }

- (void)main {
  [self willChangeValueForKey:@"isFinished"];
  [self willChangeValueForKey:@"isExecuting"];
  _executing = NO;
  _finished  = YES;
  [self didChangeValueForKey:@"isExecuting"];
  [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)wasSuccessful { return (!_error && _success && _finished && ![self isCancelled]); }

@end

@implementation ActivityCommandOperation

- (void)main {
  @try {
    Activity * activity = ((ActivityCommand *)_command).activity;
    [activity launchOrHaltActivity:^(BOOL success, NSError * error)
     {
       _success = success;
       _finished = YES;
       [super main];
     }];
  } @catch(NSException * exception)   {
    MSLogDebugTag(@"wtf?");
  }
}

@end

@implementation SwitchCommandOperation

- (void)main {
  @try {
    NSManagedObjectContext * moc        = _command.managedObjectContext;
    ActivityController       * controller = [[ActivityController alloc] initWithContext:moc];

    if (((SwitchCommand *)_command).type == SwitchTypeMode) {
      Remote   * remote = controller.currentRemote;
      NSString * mode   = ((SwitchCommand *)_command).target;

      remote.currentMode = mode;
      _success           = [remote.currentMode isEqualToString:mode];
    } else if (((SwitchCommand *)_command).type == SwitchTypeRemote)   {
      Remote * remote = [Remote existingObjectWithUUID:((SwitchCommand *)_command).target context:moc];

      if (remote) {
        controller.currentRemote = remote;
        _success                 = controller.currentRemote == remote;
      } else _success = NO;
    } else
      _success = NO;

    [super main];
  } @catch(NSException * exception)   {
    MSLogError(@"command failed");
  }
}

@end

@implementation SendCommandOperation

- (void)main
{
  @try
  {
    NSManagedObjectID * commandID = _command.objectID;
    MSLogDebugTag(@"command ID:'%@', %@", commandID, [_command shortDescription]);
    [ConnectionManager
     sendCommandWithID:commandID
     completion:^(BOOL success, NSError * error)
     {
       MSLogDebugTag(@"command ID:%@\ncompletion: success? %@ error - %@",
                     commandID,
                     BOOLString(success),
                     error);
       _success = success;
       _error   = error;
       [super main];
     }];
  }

  @catch (NSException *exception)
  {
    MSLogDebugTag(@"wtf, %@", [exception description]);
  }

}

@end

@implementation DelayCommandOperation

- (void)main
{
  @try
  {
    CGFloat duration = ((DelayCommand *)_command).duration.floatValue;
    //TODO: Only sleep for small chunks and check for cancellation
    MSLogDebugTag(@"sleeping for %f seconds", duration);
    sleep(duration);
    MSLogDebugTag(@"k, I'm awake");
    _success = YES;
    [super main];
  }

  @catch(NSException * exception)
  {
    // Do not rethrow exceptions.
    MSLogErrorTag(@"wtf?");
  }
}

@end

@implementation MacroCommandOperation

- (void)main {
  @try {
    MacroCommand * command           = (MacroCommand *)_command;
    NSOrderedSet * commandOperations = [command.commands valueForKey:@"operation"];

    [commandOperations enumerateObjectsUsingBlock:
     ^(CommandOperation * operation, NSUInteger idx, BOOL * stop)
     {
       if (idx) [operation addDependency:(CommandOperation *)commandOperations[idx - 1]];
     }];

    [command.queue addOperations:[commandOperations array] waitUntilFinished:YES];

    _success = !([commandOperations objectPassingTest:
                  ^BOOL (CommandOperation * op, NSUInteger idx)
                  {
                    return (!op.wasSuccessful && (_error = op.error));
                  }]);


    [super main];
  } @catch(NSException * exception) {
    MSLogDebugTag(@"wtf?");
  }
}

@end

@implementation SystemCommandOperation

- (void)main {
  @try {
    __block BOOL    taskComplete  = NO;
    SystemCommand * systemCommand = (SystemCommand *)_command;

    switch (systemCommand.type) {
      case SystemCommandTypeProximitySensor: {
        CurrentDevice.proximityMonitoringEnabled = !CurrentDevice.proximityMonitoringEnabled;
        _success                                 = YES;
        taskComplete                             = YES;
      }   break;

      case SystemCommandTypeURLRequest: {
        MSLogWarn(@"currently 'SystemCommandURLRequest' does nothing");
        _success     = YES;
        taskComplete = YES;
      }   break;

      case SystemCommandTypeLaunchScreen: {
        MSRunAsyncOnMain(^{ [AppController dismissViewController:AppController.window.rootViewController
                                                      completion:^{ taskComplete = YES; }]; });
      }   break;

      case SystemCommandTypeOpenSettings: {
        MSRunAsyncOnMain(^{ [AppController showSettings]; });
        _success     = YES;
        taskComplete = YES;
      }  break;

      case SystemCommandTypeOpenEditor: {
        MSRunAsyncOnMain(^{ [AppController showEditor]; });
        _success     = YES;
        taskComplete = YES;
      }    break;

      default:
        taskComplete = YES;
        _success     = NO;
        break;
    }

    while (!taskComplete) ;

    [super main];
  } @catch(NSException * exception)   {
    MSLogDebugTag(@"wtf?");
  }
}

@end
