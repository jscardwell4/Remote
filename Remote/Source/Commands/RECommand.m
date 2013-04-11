//
// Command.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RECommand_Private.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = COMMAND_F_C;

@implementation RECommand

@dynamic button, indicator, onDevice, offDevice;

+ (int)ddLogLevel { return ddLogLevel; }

+ (void)ddSetLogLevel:(int)logLevel { ddLogLevel = logLevel; }

+ (int)msLogContext { return msLogContext; }

+ (void)msSetLogContext:(int)logContext { msLogContext = logContext; }

+ (instancetype)commandInContext:(NSManagedObjectContext *)context
{
    __block RECommand * command = nil;
    [context performBlockAndWait:^{ command = NSManagedObjectFromClass(context); }];
    return command;
}

- (void)execute:(RECommandCompletionHandler)completion
{
    MSLogDebugTag(@"");
    _completion = completion;

    RECommandOperation * operation = self.operation;
    __weak RECommandOperation * weakoperation = operation;
    [operation setCompletionBlock:^{
        if (_completion) _completion(!weakoperation.isCancelled, weakoperation.wasSuccessful);
    }];

    if (CurrentQueue)
        [CurrentQueue addOperation:operation];
    else
        [operation start];
}

- (RECommandOperation *)operation { return [RECommandOperation operationForCommand:self]; }

@end

@implementation RECommandOperation

+ (int)ddLogLevel { return ddLogLevel; }

+ (void)ddSetLogLevel:(int)logLevel { ddLogLevel = logLevel; }

+ (int)msLogContext { return msLogContext; }

+ (void)msSetLogContext:(int)logContext { msLogContext = logContext; }

+ (instancetype)operationForCommand:(RECommand *)command
{
    RECommandOperation * operation = [self new];
    operation->_command = command;
    operation->_executing = NO;
    operation->_finished = NO;
    operation->_success = NO;
    return operation;
}

- (BOOL)isConcurrent { return YES; }

- (void)start
{
    MSLogDebugTag(@"");

    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    else if (self.dependencies.count && [self.dependencies objectPassingTest:
                                         ^BOOL(RECommandOperation * operation, NSUInteger idx)
                                         {
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

- (void)main
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    _finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)wasSuccessful { return (_success && _finished && ![self isCancelled]); }

@end

