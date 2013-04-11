//
// ControlStateTitleSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "REControlStateSet.h"

@implementation REControlStateTitleSet

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)state
{
    if ([obj isKindOfClass:[NSString class]])
    {
        id string = [self[state] mutableCopy];
        if (string)
            [string replaceCharactersInRange:NSMakeRange(0, ((NSAttributedString *)string).length)
                                  withString:obj];
        else
            string = [NSAttributedString attributedStringWithString:obj];
        [super setObject:string atIndexedSubscript:state];
    }

    else
        [super setObject:obj atIndexedSubscript:state];
}

- (NSAttributedString *)objectAtIndexedSubscript:(NSUInteger)state
{
    return (NSAttributedString *)[super objectAtIndexedSubscript:state];
}

- (NSString *)shortDescription
{
    NSMutableString * description = [@"" mutableCopy];
    for (int i = 0; i < 8; i++)
    {
        NSAttributedString * s = self[i];
        if (s)
            [description appendFormat:@"%@: '%@'\n", NSStringFromUIControlState(i), s.string];
    }
    return description;
}

@end
