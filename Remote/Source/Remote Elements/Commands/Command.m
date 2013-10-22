//
// Command.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "Command_Private.h"
#import "RemoteElementExportSupportFunctions.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);

@implementation Command

@dynamic button, indicator, onDevice, offDevice, name;

+ (instancetype)command
{
    return [self commandInContext:[CoreDataManager defaultContext]];
}

+ (instancetype)commandInContext:(NSManagedObjectContext *)context
{
    return [self MR_createInContext:context];
}

- (void)execute:(CommandCompletionHandler)completion
{
    MSLogDebugTag(@"");
    __weak CommandOperation * operation = self.operation;
    [operation setCompletionBlock:^{ if (completion) completion(operation.wasSuccessful, nil); }];
    [operation start];
}

- (CommandOperation *)operation { return [CommandOperation operationForCommand:self]; }

- (NSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [[super JSONDictionary] mutableCopy];

    dictionary[@"class"] = classJSONValueForCommand(self);

    return dictionary;
}

@end

@implementation CommandOperation

+ (instancetype)operationForCommand:(Command *)command
{
    CommandOperation * operation = [self new];
    operation->_command   = command;
    operation->_executing = NO;
    operation->_finished  = NO;
    operation->_success   = NO;
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
                                         ^BOOL(CommandOperation * operation, NSUInteger idx)
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

- (void)main
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    _finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)wasSuccessful { return (!_error && _success && _finished && ![self isCancelled]); }

@end


@implementation Command (Logging)

+ (int)ddLogLevel { return ddLogLevel; }

+ (void)ddSetLogLevel:(int)logLevel { ddLogLevel = logLevel; }

+ (int)msLogContext { return msLogContext; }

+ (void)msSetLogContext:(int)logContext { msLogContext = logContext; }

@end

@implementation CommandOperation (Logging)

+ (int)ddLogLevel { return ddLogLevel; }

+ (void)ddSetLogLevel:(int)logLevel { ddLogLevel = logLevel; }

+ (int)msLogContext { return msLogContext; }

+ (void)msSetLogContext:(int)logContext { msLogContext = logContext; }

@end