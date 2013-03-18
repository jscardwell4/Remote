//
// Remote.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RERemote.h"
#import "RemoteElement_Private.h"
#import "REImage.h"
#import "REButtonGroup.h"
#import "RERemoteController.h"

static int ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation RERemote

// TODO: Add validation to make sure sub elements are ButtonGroup objects

- (REButtonGroup *)objectForKeyedSubscript:(NSString *)subscript {
    return (REButtonGroup *)[super objectForKeyedSubscript:subscript];
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

@end
