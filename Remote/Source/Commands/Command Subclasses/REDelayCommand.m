//
// DelayCommand.m
// Remote
//
// Created by Jason Cardwell on 7/20/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RECommand_Private.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);

@interface REDelayCommandOperation : RECommandOperation @end

@implementation REDelayCommand

@dynamic duration;

+ (REDelayCommand *)commandInContext:(NSManagedObjectContext *)context duration:(CGFloat)duration
{
    __block REDelayCommand * delayCommand = nil;

    [context performBlockAndWait:
     ^{
         delayCommand = [self commandInContext:context];
         delayCommand.duration = duration;
     }];

    return delayCommand;
}

- (RECommandOperation *)operation { return [REDelayCommandOperation operationForCommand:self]; }

/*
- (void)execute:(void (^)(BOOL, BOOL))completion
{
    [super execute:completion];

    RECommandOperation * operation = self.operation;
    __weak RECommandOperation * weakoperation = operation;
    [operation setCompletionBlock:^{
        if (_completion) _completion(!weakoperation.isCancelled, weakoperation.wasSuccessful);
    }];

    [MainQueue addOperation:operation];

//    dispatch_time_t   popTime = dispatch_time(DISPATCH_TIME_NOW, self.duration * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^{ if (completion) completion(YES, YES); });
}
*/


- (NSString *)shortDescription { return $(@"duration:%@",self.primitiveDuration); }

@end

@implementation REDelayCommandOperation

- (void)main
{
    @try
    {
        CGFloat duration = ((REDelayCommand *)_command).duration;
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

