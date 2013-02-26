//
// Remote.m
// iPhonto
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "Remote.h"
#import "RemoteElement_Private.h"
#import "GalleryImage.h"
#import "ButtonGroup.h"
#import "RemoteController.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation Remote

// TODO: Add validation to make sure sub elements are ButtonGroup objects

- (ButtonGroup *)buttonGroupWithKey:(NSString *)key {
    return [self.subelements
            objectPassingTest:^BOOL (ButtonGroup * obj, NSUInteger idx, BOOL * stop) {
        return [obj.key
                isEqualToString:key];
    }

    ];
}

- (ButtonGroup *)objectForKeyedSubscript:(NSString *)subscript {
    return [self buttonGroupWithKey:subscript];
}

- (void)setTopBarHiddenOnLoad:(BOOL)topBarHiddenOnLoad {
    if (topBarHiddenOnLoad) [self setFlagBits:RemoteOptionTopBarHiddenOnLoad];
    else [self unsetFlagBits:RemoteOptionTopBarHiddenOnLoad];
}

- (BOOL)isTopBarHiddenOnLoad {
    return [self isFlagSetForBits:RemoteOptionTopBarHiddenOnLoad];
}

@end
