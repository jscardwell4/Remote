//
// HTTPCommand.m
// Remote
//
// Created by Jason Cardwell on 2/18/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "Command_Private.h"
#import "CoreDataManager.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)

@implementation HTTPCommand

@dynamic url;

+ (HTTPCommand *)commandWithURL:(NSString *)url
{
    return [self commandWithURL:url context:[CoreDataManager defaultContext]];
}

+ (HTTPCommand *)commandWithURL:(NSString *)url context:(NSManagedObjectContext *)context
{
    HTTPCommand * command = [self commandInContext:context];
    command.url = [NSURL URLWithString:url];
    return command;
}

- (NSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [[super JSONDictionary] mutableCopy];

    dictionary[@"url"] = CollectionSafeValue([self.url absoluteString]);

    [dictionary removeKeysWithNullObjectValues];

    return dictionary;
}


- (NSString *)shortDescription { return $(@"url:'%@'", self.primitiveUrl); }

@end