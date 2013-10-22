//
//  RemoteElementView+Drawing.m
//  Remote
//
//  Created by Jason Cardwell on 4/3/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementView_Private.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

@implementation RemoteElementView (Drawing)

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
            self.borderPath = [MSPainter stretchedOvalFromRect:self.bounds];
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
        [MSPainter drawRoundedRectButtonBaseInContext:ctx
                                        buttonColor:self.model.backgroundColor
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
                           : [UIBezierPath bezierPathWithRect:rect]);

    UIGraphicsPushContext(ctx);
    [path addClip];

    if (self.style & REStyleApplyGloss)
    {
        switch ((self.style & REGlossStyleMask))
        {
            case REStyleGlossStyle1:
                [MSPainter drawGlossGradientWithColor:defaultGlossColor()
                                               rect:self.bounds
                                            context:UIGraphicsGetCurrentContext()
                                             offset:0.0f];
                break;

            case REStyleGlossStyle2:
                [MSPainter drawRoundedRectButtonOverlayInContext:ctx shineColor:nil frame:rect];
                break;

            case REStyleGlossStyle3:
                [MSPainter drawGlossGradientWithColor:defaultGlossColor()
                                               rect:self.bounds
                                            context:UIGraphicsGetCurrentContext()
                                             offset:0.8f];
                break;

            case REStyleGlossStyle4:
                [MSPainter drawGlossGradientWithColor:defaultGlossColor()
                                               rect:self.bounds
                                            context:UIGraphicsGetCurrentContext()
                                             offset:-0.8f];
                break;

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