//
// HTTPCommand.m
// Remote
//
// Created by Jason Cardwell on 2/18/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RECommand_Private.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = COMMAND_F_C;
#pragma unused(ddLogLevel,msLogContext)

@implementation REHTTPCommand

@dynamic url;

+ (REHTTPCommand *)commandInContext:(NSManagedObjectContext *)context withURL:(NSString *)url
{
    __block REHTTPCommand * command = nil;

    [context performBlockAndWait:
     ^{
         command = [self commandInContext:context];
         command.primitiveUrl = [NSURL URLWithString:url];
     }];

    return command;
}

- (NSString *)shortDescription { return $(@"url:'%@'", self.primitiveUrl); }

@end
