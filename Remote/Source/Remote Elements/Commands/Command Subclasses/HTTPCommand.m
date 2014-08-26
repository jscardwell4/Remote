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

- (MSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];

    SafeSetValueForKey([self.url absoluteString], @"url", dictionary);

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}

- (void)updateWithData:(NSDictionary *)data {
    /*
         {
             "class": "http",
             "url": "http://10.0.1.27/0?1201=I=0"
         }
     */

    [super updateWithData:data];
    NSString * url = data[@"url"];
    if (url) self.url = [NSURL URLWithString:url];

}

- (NSString *)shortDescription { return $(@"url:'%@'", self.primitiveUrl); }

@end
