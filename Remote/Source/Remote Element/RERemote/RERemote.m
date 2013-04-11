//
// Remote.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"

static int ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation RERemote

@dynamic configurationDelegate, controller;

+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)context
{
    __block RERemote * element = nil;
    [context performBlockAndWait:
     ^{
         element = [super remoteElementInContext:context];
         element.type = RETypeRemote;
     }];
    return element;
}

- (void)setParentElement:(RemoteElement *)parentElement {}

- (RemoteElement *)parentElement { return nil; }

- (REButtonGroup *)objectForKeyedSubscript:(NSString *)subscript {
    return (REButtonGroup *)[super objectForKeyedSubscript:subscript];
}

- (REButtonGroup *)objectAtIndexedSubscript:(NSUInteger)subscript {
    return (REButtonGroup *)[super objectAtIndexedSubscript:subscript];
}

- (void)setTopBarHiddenOnLoad:(BOOL)topBarHiddenOnLoad {
    if (topBarHiddenOnLoad)
        [self setFlagBits:RERemoteOptionTopBarHiddenOnLoad];
    else
        [self unsetFlagBits:RERemoteOptionTopBarHiddenOnLoad];
}

- (BOOL)isTopBarHiddenOnLoad {
    return [self isFlagSetForBits:RERemoteOptionTopBarHiddenOnLoad];
}

- (BOOL)registerConfiguration:(NSString *)configuration {
    return [self.configurationDelegate addConfiguration:configuration];
}

- (NSArray *)registeredConfigurations { return self.configurationDelegate.configurationKeys;}

- (BOOL)switchToConfiguration:(NSString *)configuration
{
    self.configurationDelegate.currentConfiguration = configuration;
    return [self.configurationDelegate.currentConfiguration isEqualToString:configuration];
}

@end
