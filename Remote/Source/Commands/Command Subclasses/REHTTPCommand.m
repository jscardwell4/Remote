//
// HTTPCommand.m
// Remote
//
// Created by Jason Cardwell on 2/18/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RECommand_Private.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)

@implementation REHTTPCommand

@dynamic url;

+ (REHTTPCommand *)commandWithURL:(NSString *)url
{
    return [self commandWithURL:url inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (REHTTPCommand *)commandWithURL:(NSString *)url inContext:(NSManagedObjectContext *)context
{
    REHTTPCommand * command = [self commandInContext:context];
    command.url = [NSURL URLWithString:url];
    return command;
}

- (NSString *)shortDescription { return $(@"url:'%@'", self.primitiveUrl); }

@end
