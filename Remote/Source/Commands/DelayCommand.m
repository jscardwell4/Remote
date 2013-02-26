//
// DelayCommand.m
// iPhonto
//
// Created by Jason Cardwell on 7/20/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "Command.h"
#import "Command_Private.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation DelayCommand

@dynamic duration;

+ (DelayCommand *)delayCommandInContext:(NSManagedObjectContext *)context {
    return (DelayCommand *)[super commandInContext:context];
}

/// @name ￼Creating a DelayCommand

+ (DelayCommand *)delayCommandWithDuration:(CGFloat)duration
                                 inContext:(NSManagedObjectContext *)context {
    DelayCommand * delayCommand =
        [NSEntityDescription insertNewObjectForEntityForName:@"DelayCommand"
                                      inManagedObjectContext:context];

    delayCommand.duration = duration;

    return delayCommand;
}

/// @name ￼Executing commands

/**
 * Invokes `commandDidComplete:success:` with a delay equal to the command's `duration` property.
 * @param sender Object to be notified after the delay.
 * @param options `CommandOptions` to be applied.
 */
- (void)execute:(id <CommandDelegate> )sender /* withOptions:(CommandOptions)options*/
{
    if (ValueIsNil(sender)) return;           // What's the point.

    [super execute:sender /* withOptions:options*/];

    double            delayInSeconds = self.duration;
    dispatch_time_t   popTime        = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);

    dispatch_after(popTime,
                   dispatch_get_main_queue(),
                   ^(void) {[self.delegate commandDidComplete:self success:YES]; }

                   );
}

@end
