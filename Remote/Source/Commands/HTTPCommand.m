//
// HTTPCommand.m
// iPhonto
//
// Created by Jason Cardwell on 2/18/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "Command.h"
#import "Command_Private.h"

static int   ddLogLevel = DefaultDDLogLevel;

@implementation HTTPCommand

@dynamic url;

/// @name ￼Creating an HTTPCommand

+ (HTTPCommand *)httpCommandInContext:(NSManagedObjectContext *)context {
    return (HTTPCommand *)[super commandInContext:context];
}

+ (HTTPCommand *)HTTPCommandWithURL:(NSString *)urlString
                          inContext:(NSManagedObjectContext *)context {
    HTTPCommand * command =
        [NSEntityDescription insertNewObjectForEntityForName:@"HTTPCommand"
                                      inManagedObjectContext:context];

    command.url = urlString;

    return command;
}

/**
 * Invokes `sendCommand:ofType:toDeviceAtIndex:` of <ConnectionManager> with the command's url.
 * @param sender Object to be notified upon completion.
 * @param options Options to apply when executing the command.
 */
- (void)execute:(id <CommandDelegate> )sender  /* withOptions:(CommandOptions)options*/
{
    [super execute:sender /* withOptions:options*/];

    if (ValueIsNil(self.url)) {
        [super commandDidComplete:self success:NO];

        return;
    }

    DDLogVerbose(@"sending http command with url: %@", self.url);

    [[ConnectionManager sharedConnectionManager] sendCommand:self.url ofType:URLConnectionCommandType toDevice:0];
}

@end
