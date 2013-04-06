//
//  REView+Drawing.m
//  Remote
//
//  Created by Jason Cardwell on 4/3/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REView_Private.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = REMOTE_F_C;
#pragma unused(ddLogLevel, msLogContext)

@implementation REView (Drawing)

- (void)setBorderPath:(UIBezierPath *)borderPath
{
    _borderPath = borderPath;

    if (_borderPath)
    {
        self.layer.mask = [CAShapeLayer layer];
        ((CAShapeLayer*)self.layer.mask).path = [_borderPath CGPath];
    }
    else
        self.layer.mask = nil;
}

- (UIBezierPath *)borderPath { return _borderPath; }

- (void)setCornerRadii:(CGSize)cornerRadii { _drawingFlags.cornerRadii = cornerRadii; }

- (CGSize)cornerRadii { return _drawingFlags.cornerRadii; }

- (void)refreshBorderPath
{
    switch (self.shape)
    {
        case REShapeRectangle:
            self.borderPath = [UIBezierPath bezierPathWithRect:self.bounds];
            break;

        case REShapeRoundedRectangle:
            self.borderPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                    byRoundingCorners:UIRectCornerAllCorners
                                                          cornerRadii:_drawingFlags.cornerRadii];
            break;

        case REShapeOval:
            self.borderPath = [Painter stretchedOvalFromRect:self.bounds];
            break;

        case REShapeTriangle:
        case REShapeDiamond:
        default:
            self.borderPath = nil;
            break;
    }
    
}

/**
 * Override point for subclasses to draw into the content subview.
 */
- (void)drawContentInContext:(CGContextRef)ctx inRect:(CGRect)rect {}

/**
 * Override point for subclasses to draw into the backdrop subview.
 */
- (void)drawBackdropInContext:(CGContextRef)ctx inRect:(CGRect)rect
{
    if (self.shape == REShapeRoundedRectangle)
    {
        UIGraphicsPushContext(ctx);
        [Painter drawRoundedRectButtonBaseInContext:ctx
                                        buttonColor:self.backgroundColor
                                        shadowColor:nil
                                             opaque:YES
                                              frame:rect];
        UIGraphicsPopContext();
    }

    else if (_borderPath)
    {
        UIGraphicsPushContext(ctx);
        [self.backgroundColor setFill];
        [_borderPath fill];
        UIGraphicsPopContext();
    }
}

/**
 * Override point for subclasses to draw into the overlay subview.
 */
- (void)drawOverlayInContext:(CGContextRef)ctx inRect:(CGRect)rect
{
    UIBezierPath * path = (_borderPath
                           ? [UIBezierPath bezierPathWithCGPath:_borderPath.CGPath]
                           : [UIBezierPath bezierPathWithRect:self.bounds]);

    UIGraphicsPushContext(ctx);
    [path addClip];

    if (self.style & REStyleApplyGloss)
    {
        uint64_t glossStyle = (uint64_t)(self.style & REStyleGlossStyleMask);
        switch (glossStyle)
        {
            case REStyleGlossStyle1:
                [Painter drawGlossGradientWithColor:defaultGlossColor()
                                             inRect:self.bounds
                                          inContext:UIGraphicsGetCurrentContext()];
                break;
            case REStyleGlossStyle2:
                [Painter drawRoundedRectButtonOverlayInContext:ctx shineColor:nil frame:rect];
            default:
                // Other styles not yet implemented
                break;
        }
    }


    if (self.style & REStyleDrawBorder)
    {
        path.lineWidth     = 3.0;
        path.lineJoinStyle = kCGLineJoinRound;
        [BlackColor setStroke];
        [path stroke];
    }

    UIGraphicsPopContext();
}

@end
