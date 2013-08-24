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

