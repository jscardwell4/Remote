//
// ButtonImage.m
// Remote
//
// Created by Jason Cardwell on 6/16/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "BOImage_Private.h"

@implementation BOButtonImage {
    BOButtonImageState _state;
}

@dynamic state;

- (void)setState:(BOButtonImageState)state
{
    [self willChangeValueForKey:@"state"];
    _state = state;
    [self didChangeValueForKey:@"state"];
}

- (BOButtonImageState)state
{
    [self willAccessValueForKey:@"state"];
    BOButtonImageState state = _state;
    [self didAccessValueForKey:@"state"];
    return state;
}

@end
