//
// ControlStateButtonImageSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "REControlStateSet.h"
#import "BankObject.h"

@implementation REControlStateButtonImageSet

- (BOButtonImage *)objectAtIndexedSubscript:(NSUInteger)state
{
    return (BOButtonImage *)[super objectAtIndexedSubscript:state];
}

@end
