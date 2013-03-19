//
// RELabelView.m
// Remote
//
// Created by Jason Cardwell on 3/17/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RELabelView.h"

@implementation RELabelView {
    CGSize          _baseSize;
    CGFloat         _scale;
    CGPoint         _offset;
}

- (id)init { if ((self = [super init])) self.clipsToBounds = NO; return self; }

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];

    if (CGSizeEqualToSize(_baseSize, CGSizeZero))
    {
        _baseSize = bounds.size;
        _scale = 1.0f;
        _offset = CGPointZero;
    }

    else
    {
        MSAspectRatio aspectRatio = MSAspectRatioFromSizeOverSize(bounds.size, _baseSize);
        _scale = (ABS(aspectRatio.x - 1) < ABS(aspectRatio.y - 1) ? aspectRatio.x : aspectRatio.y);
        CGSize delta = CGSizeGetDelta(bounds.size, CGSizeApplyScale(_baseSize, _scale));
        _offset = CGPointApplyAffineTransform(CGPointMake(CGSizeUnpack(delta)),
                                              CGAffineTransformMakeScale(0.5, 0.5));
    }
}

- (NSUInteger)lineBreaks { return [self.text numberOfMatchesForRegEx:@"\\n"]; }

- (void)drawTextInRect:(CGRect)rect {
    UIGraphicsPushContext(UIGraphicsGetCurrentContext());
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), _scale, _scale);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(),CGPointUnpack(_offset));
    rect.size = _baseSize;    
    [super drawTextInRect:rect];
    UIGraphicsPopContext();
}

@end
