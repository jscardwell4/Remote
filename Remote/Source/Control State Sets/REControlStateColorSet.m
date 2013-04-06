//
// ControlStateColorSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "REControlStateSet.h"


@implementation REControlStateColorSet

@dynamic button, icon;

- (UIColor *)objectAtIndexedSubscript:(NSUInteger)state
{
    return (UIColor *)[super objectAtIndexedSubscript:state];
}

#pragma mark - Debugging

- (NSString *)debugDescription
{
    return $(@"normal:%@\n"
            "selected:%@\n"
            "highlighted:%@\n"
            "disabled:%@\n"
            "highlightedAndSelected:%@\n"
            "highlightedAndDisabled:%@\n"
            "disabledAndSelected:%@\n"
            "selectedHighlightedAndDisabled:%@",
            NSStringFromUIColor(self[0]),
            NSStringFromUIColor(self[4]),
            NSStringFromUIColor(self[1]),
            NSStringFromUIColor(self[2]),
            NSStringFromUIColor(self[5]),
            NSStringFromUIColor(self[3]),
            NSStringFromUIColor(self[6]),
            NSStringFromUIColor(self[7]));
}

@end
