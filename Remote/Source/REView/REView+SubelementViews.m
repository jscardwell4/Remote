//
//  REView+SubelementViews.m
//  Remote
//
//  Created by Jason Cardwell on 3/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REView_Private.h"

@implementation REView (SubelementViews)

/**
 * Searches content view for subviews of the appropriate type and returns them as an array.
 */
- (NSArray *)subelementViews
{
    return [_subelementsView subviews];
}

- (void)addSubelementView:(REView *)view { [_subelementsView addSubview:view]; }

- (void)removeSubelementView:(REView *)view { [view removeFromSuperview]; }

- (void)addSubelementViews:(NSSet *)views
{
    for (REView * view in views)
        [self addSubelementView:view];
}

- (void)removeSubelementViews:(NSSet *)views
{
    [views makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)bringSubelementViewToFront:(REView *)subelementView
{
    [_subelementsView bringSubviewToFront:subelementView];
}

- (void)sendSubelementViewToBack:(REView *)subelementView
{
    [_subelementsView sendSubviewToBack:subelementView];
}

- (void)insertSubelementView:(REView *)subelementView aboveSubelementView:(REView *)siblingSubelementView
{
    [_subelementsView insertSubview:subelementView aboveSubview:siblingSubelementView];
}

- (void)insertSubelementView:(REView *)subelementView atIndex:(NSInteger)index
{
    [_subelementsView insertSubview:subelementView atIndex:index];
}

- (void)insertSubelementView:(REView *)subelementView belowSubelementView:(REView *)siblingSubelementView
{
    [_subelementsView insertSubview:subelementView belowSubview:siblingSubelementView];
}

@end

@implementation REViewInternal

- (id)init
{
    if (self = [super init])
    {
        self.userInteractionEnabled = [self isMemberOfClass:[REViewSubelements class]];
        self.backgroundColor        = ClearColor;
        self.clipsToBounds          = NO;
        self.opaque                 = NO;
        self.contentMode            = UIViewContentModeRedraw;
        self.autoresizesSubviews    = NO;
    }

    return self;
}

- (void)willMoveToSuperview:(REView *)newSuperview { _delegate = newSuperview; }

@end

@implementation REViewSubelements

- (void)addSubview:(REView *)view {
    if ([view isKindOfClass:[REView class]] && view.model.parentElement == _delegate.model)
        [super addSubview:view];
}

@end

@implementation REViewContent {}

/**
 * Calls `drawContentInContext:inRect:`.
 */
- (void)drawRect:(CGRect)rect
{
    [_delegate drawContentInContext:UIGraphicsGetCurrentContext() inRect:rect];
}

@end

@implementation REViewBackdrop {}

/**
 * Calls `drawBackdropInContext:inRect:`.
 */
- (void)drawRect:(CGRect)rect
{
    [_delegate drawBackdropInContext:UIGraphicsGetCurrentContext() inRect:rect];
}

@end

@interface REViewOverlay ()

@property (nonatomic, strong) CAShapeLayer * boundaryOverlay;
@property (nonatomic, strong) CALayer      * alignmentOverlay;

@end

@implementation REViewOverlay {
    CGSize   _renderedSize;
}

#define PAINT_WITH_STROKE

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    assert(object == _delegate);

    if ([@"borderPath" isEqualToString : keyPath])
    {
        __weak REViewOverlay * weakself = self;
        [MainQueue addOperationWithBlock:^{ _boundaryOverlay.path = [weakself boundaryPath]; }];
    }
}

- (CGPathRef)boundaryPath
{
    assert(_boundaryOverlay);

    UIBezierPath * path = _delegate.borderPath;

    if (!path) path = [UIBezierPath bezierPathWithRect:self.bounds];

    CGSize         size         = self.bounds.size;
    CGFloat        lineWidth    = _boundaryOverlay.lineWidth;
    UIBezierPath * innerPath    = [UIBezierPath bezierPathWithCGPath:path.CGPath];
    CGPathRef      boundaryPath = NULL;

#ifdef PAINT_WITH_STROKE
    [innerPath applyTransform:CGAffineTransformMakeScale((size.width - lineWidth) / size.width,
                                                         (size.height - lineWidth) / size.height)];
    [innerPath applyTransform:CGAffineTransformMakeTranslation(lineWidth / 2, lineWidth / 2)];
    boundaryPath = innerPath.CGPath;
#else
    [innerPath applyTransform:CGAffineTransformMakeScale((size.width - 2 * lineWidth) / size.width,
                                                         (size.height - 2 * lineWidth) / size.height)];
    [innerPath applyTransform:CGAffineTransformMakeTranslation(lineWidth, lineWidth)];
    [path appendPath:innerPath];
    boundaryPath = path.CGPath;
#endif

    return boundaryPath;
}

- (CALayer *)boundaryOverlay
{
    if (!_boundaryOverlay)
    {
        self.boundaryOverlay = [CAShapeLayer layer];
#ifdef PAINT_WITH_STROKE
        _boundaryOverlay.lineWidth   = 2.0;
        _boundaryOverlay.lineJoin    = kCALineJoinRound;
        _boundaryOverlay.fillColor   = NULL;
        _boundaryOverlay.strokeColor = _boundaryColor.CGColor;
#else
        _boundaryOverlay.fillColor   = _boundaryColor.CGColor;
        _boundaryOverlay.strokeColor = nil;
        _boundaryOverlay.fillRule    = kCAFillRuleEvenOdd;
#endif
        _boundaryOverlay.path = [self boundaryPath];

        [self.layer addSublayer:_boundaryOverlay];

        _boundaryOverlay.hidden = !_showContentBoundary;

        [_delegate
         addObserver:self
         forKeyPath:@"borderPath"
         options:NSKeyValueObservingOptionNew
         context:NULL];
    }

    return _boundaryOverlay;
}

- (void)dealloc
{
    [_delegate removeObserver:self forKeyPath:@"borderPath"];
}

- (void)setShowContentBoundary:(BOOL)showContentBoundary
{
    _showContentBoundary    = showContentBoundary;
    _boundaryOverlay.hidden = !_showContentBoundary;
}

- (void)setBoundaryColor:(UIColor *)boundaryColor
{
    _boundaryColor = boundaryColor;
#ifdef PAINT_WITH_STROKE
    self.boundaryOverlay.strokeColor = _boundaryColor.CGColor;
#else
    self.boundaryOverlay.fillColor = _boundaryColor.CGColor;
#endif
    [_boundaryOverlay setNeedsDisplay];
}

- (CALayer *)alignmentOverlay
{
    if (!_alignmentOverlay)
    {
        self.alignmentOverlay    = [CALayer layer];
        _alignmentOverlay.frame  = self.layer.bounds;
        _alignmentOverlay.hidden = !_showAlignmentIndicators;

        [self.layer addSublayer:_alignmentOverlay];
    }

    return _alignmentOverlay;
}

- (void)setShowAlignmentIndicators:(BOOL)showAlignmentIndicators
{
    _showAlignmentIndicators = showAlignmentIndicators;
    [self renderAlignmentOverlayIfNeeded];
}

- (void)renderAlignmentOverlayIfNeeded
{
    self.alignmentOverlay.hidden = !_showAlignmentIndicators;

    if (!_showAlignmentIndicators) return;

    RELayoutConfiguration * layoutConfiguration = _delegate.layoutConfiguration;

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);

    //// General Declarations
    CGContextRef   context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor * gentleHighlight = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
    UIColor * parent          = [UIColor colorWithRed:0.899 green:0.287 blue:0.238 alpha:1];
    UIColor * sibling         = [UIColor colorWithRed:0.186 green:0.686 blue:0.661 alpha:1];
    UIColor * intrinsic       = [UIColor colorWithRed:0.686 green:0.186 blue:0.899 alpha:1];
    UIColor * colors[4]       = { gentleHighlight, parent, sibling, intrinsic };

    //// Shadow Declarations
    UIColor * outerHighlight                 = gentleHighlight;
    CGSize    outerHighlightOffset           = CGSizeMake(0.1, -0.1);
    CGFloat   outerHighlightBlurRadius       = 2.5;
    UIColor * innerHighlightLeft             = gentleHighlight;
    CGSize    innerHighlightLeftOffset       = CGSizeMake(-1.1, -0.1);
    CGFloat   innerHighlightLeftBlurRadius   = 0.5;
    UIColor * innerHighlightRight            = gentleHighlight;
    CGSize    innerHighlightRightOffset      = CGSizeMake(1.1, -0.1);
    CGFloat   innerHighlightRightBlurRadius  = 0.5;
    UIColor * innerHighlightTop              = gentleHighlight;
    CGSize    innerHighlightTopOffset        = CGSizeMake(0.1, -1.1);
    CGFloat   innerHighlightTopBlurRadius    = 0.5;
    UIColor * innerHighlightBottom           = gentleHighlight;
    CGSize    innerHighlightBottomOffset     = CGSizeMake(0.1, 1.1);
    CGFloat   innerHighlightBottomBlurRadius = 0.5;
    UIColor * innerHighlightCenter           = gentleHighlight;
    CGSize    innerHighlightCenterOffset     = CGSizeMake(0.1, -0.1);
    CGFloat   innerHighlightCenterBlurRadius = 0.5;

    //// Frames
    CGRect   frame = CGRectInset(self.bounds, 3.0, 3.0);

    //// Abstracted Attributes
    CGRect   leftBarRect = CGRectMake(CGRectGetMinX(frame) + 1,
                                      CGRectGetMinY(frame) + 3,
                                      2,
                                      CGRectGetHeight(frame) - 6);
    CGFloat   leftBarCornerRadius = 1;
    CGRect    rightBarRect        = CGRectMake(CGRectGetMinX(frame) + CGRectGetWidth(frame) - 3,
                                               CGRectGetMinY(frame) + 3,
                                               2,
                                               CGRectGetHeight(frame) - 6);
    CGFloat   rightBarCornerRadius = 1;
    CGRect    topBarRect           = CGRectMake(CGRectGetMinX(frame) + 4,
                                                CGRectGetMinY(frame) + 1,
                                                CGRectGetWidth(frame) - 8,
                                                2);
    CGFloat   topBarCornerRadius = 1;
    CGRect    bottomBarRect      = CGRectMake(CGRectGetMinX(frame) + 4,
                                              CGRectGetMinY(frame) + CGRectGetHeight(frame) - 3,
                                              CGRectGetWidth(frame) - 8,
                                              2);
    CGFloat   bottomBarCornerRadius = 1;
    CGRect    centerXBarRect        = CGRectMake(CGRectGetMinX(frame)
                                                 + floor((CGRectGetWidth(frame) - 2) * 0.50000) + 0.5,
                                                 CGRectGetMinY(frame) + 4,
                                                 2,
                                                 CGRectGetHeight(frame) - 7);
    CGFloat   centerXBarCornerRadius = 1;
    CGRect    centerYBarRect         = CGRectMake(CGRectGetMinX(frame) + 3.5,
                                                  CGRectGetMinY(frame)
                                                  + floor((CGRectGetHeight(frame) - 2) * 0.50000 + 0.5),
                                                  CGRectGetWidth(frame) - 8,
                                                  2);
    CGFloat   centerYBarCornerRadius = 1;

    if (layoutConfiguration[NSLayoutAttributeLeft])
    {
        //// Left Bar Drawing
        UIBezierPath * leftBarPath = [UIBezierPath bezierPathWithRoundedRect:leftBarRect
                                                                cornerRadius:leftBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context,
                                    outerHighlightOffset,
                                    outerHighlightBlurRadius,
                                    outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeLeft]] setFill];
        [leftBarPath fill];

        ////// Left Bar Inner Shadow
        CGRect   leftBarBorderRect = CGRectInset([leftBarPath bounds],
                                                 -innerHighlightLeftBlurRadius,
                                                 -innerHighlightLeftBlurRadius);

        leftBarBorderRect = CGRectOffset(leftBarBorderRect,
                                         -innerHighlightLeftOffset.width,
                                         -innerHighlightLeftOffset.height);
        leftBarBorderRect = CGRectInset(CGRectUnion(leftBarBorderRect, [leftBarPath bounds]), -1, -1);

        UIBezierPath * leftBarNegativePath = [UIBezierPath bezierPathWithRect:leftBarBorderRect];

        [leftBarNegativePath appendPath:leftBarPath];
        leftBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightLeftOffset.width + round(leftBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightLeftOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset),
                                                   yOffset + copysign(0.1, yOffset)),
                                        innerHighlightLeftBlurRadius,
                                        innerHighlightLeft.CGColor);

            [leftBarPath addClip];

            CGAffineTransform   transform =
            CGAffineTransformMakeTranslation(-round(leftBarBorderRect.size.width), 0);

            [leftBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [leftBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    if (layoutConfiguration[NSLayoutAttributeRight])
    {
        //// Right Bar Drawing
        UIBezierPath * rightBarPath = [UIBezierPath bezierPathWithRoundedRect:rightBarRect
                                                                 cornerRadius:rightBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context,
                                    outerHighlightOffset,
                                    outerHighlightBlurRadius,
                                    outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeRight]] setFill];
        [rightBarPath fill];

        ////// Right Bar Inner Shadow
        CGRect   rightBarBorderRect = CGRectInset([rightBarPath bounds],
                                                  -innerHighlightRightBlurRadius,
                                                  -innerHighlightRightBlurRadius);

        rightBarBorderRect = CGRectOffset(rightBarBorderRect,
                                          -innerHighlightRightOffset.width,
                                          -innerHighlightRightOffset.height);
        rightBarBorderRect = CGRectInset(CGRectUnion(rightBarBorderRect, [rightBarPath bounds]), -1, -1);

        UIBezierPath * rightBarNegativePath = [UIBezierPath bezierPathWithRect:rightBarBorderRect];

        [rightBarNegativePath appendPath:rightBarPath];
        rightBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightRightOffset.width + round(rightBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightRightOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset),
                                                   yOffset + copysign(0.1, yOffset)),
                                        innerHighlightRightBlurRadius,
                                        innerHighlightRight.CGColor);

            [rightBarPath addClip];

            CGAffineTransform   transform =
            CGAffineTransformMakeTranslation(-round(rightBarBorderRect.size.width), 0);

            [rightBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [rightBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    if (layoutConfiguration[NSLayoutAttributeTop])
    {
        //// Top Bar Drawing
        UIBezierPath * topBarPath = [UIBezierPath bezierPathWithRoundedRect:topBarRect
                                                               cornerRadius:topBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context,
                                    outerHighlightOffset,
                                    outerHighlightBlurRadius,
                                    outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeTop]] setFill];
        [topBarPath fill];

        ////// Top Bar Inner Shadow
        CGRect   topBarBorderRect = CGRectInset([topBarPath bounds],
                                                -innerHighlightTopBlurRadius,
                                                -innerHighlightTopBlurRadius);

        topBarBorderRect = CGRectOffset(topBarBorderRect,
                                        -innerHighlightTopOffset.width,
                                        -innerHighlightTopOffset.height);
        topBarBorderRect = CGRectInset(CGRectUnion(topBarBorderRect, [topBarPath bounds]), -1, -1);

        UIBezierPath * topBarNegativePath = [UIBezierPath bezierPathWithRect:topBarBorderRect];

        [topBarNegativePath appendPath:topBarPath];
        topBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightTopOffset.width + round(topBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightTopOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset),
                                                   yOffset + copysign(0.1, yOffset)),
                                        innerHighlightTopBlurRadius,
                                        innerHighlightTop.CGColor);

            [topBarPath addClip];

            CGAffineTransform   transform =
            CGAffineTransformMakeTranslation(-round(topBarBorderRect.size.width), 0);

            [topBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [topBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    if (layoutConfiguration[NSLayoutAttributeBottom])
    {
        //// Bottom Bar Drawing
        UIBezierPath * bottomBarPath = [UIBezierPath bezierPathWithRoundedRect:bottomBarRect
                                                                  cornerRadius:bottomBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context,
                                    outerHighlightOffset,
                                    outerHighlightBlurRadius,
                                    outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeBottom]] setFill];
        [bottomBarPath fill];

        ////// Bottom Bar Inner Shadow
        CGRect   bottomBarBorderRect = CGRectInset([bottomBarPath bounds],
                                                   -innerHighlightBottomBlurRadius,
                                                   -innerHighlightBottomBlurRadius);

        bottomBarBorderRect = CGRectOffset(bottomBarBorderRect,
                                           -innerHighlightBottomOffset.width,
                                           -innerHighlightBottomOffset.height);
        bottomBarBorderRect = CGRectInset(CGRectUnion(bottomBarBorderRect, [bottomBarPath bounds]),
                                          -1, -1);

        UIBezierPath * bottomBarNegativePath = [UIBezierPath bezierPathWithRect:bottomBarBorderRect];

        [bottomBarNegativePath appendPath:bottomBarPath];
        bottomBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightBottomOffset.width + round(bottomBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightBottomOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset),
                                                   yOffset + copysign(0.1, yOffset)),
                                        innerHighlightBottomBlurRadius,
                                        innerHighlightBottom.CGColor);

            [bottomBarPath addClip];

            CGAffineTransform   transform =
            CGAffineTransformMakeTranslation(-round(bottomBarBorderRect.size.width), 0);

            [bottomBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [bottomBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    if (layoutConfiguration[NSLayoutAttributeCenterX])
    {
        //// Center X Bar Drawing
        UIBezierPath * centerXBarPath = [UIBezierPath bezierPathWithRoundedRect:centerXBarRect
                                                                   cornerRadius:centerXBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context,
                                    outerHighlightOffset,
                                    outerHighlightBlurRadius,
                                    outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeCenterX]] setFill];
        [centerXBarPath fill];

        ////// Center X Bar Inner Shadow
        CGRect   centerXBarBorderRect = CGRectInset([centerXBarPath bounds],
                                                    -innerHighlightCenterBlurRadius,
                                                    -innerHighlightCenterBlurRadius);

        centerXBarBorderRect = CGRectOffset(centerXBarBorderRect,
                                            -innerHighlightCenterOffset.width,
                                            -innerHighlightCenterOffset.height);
        centerXBarBorderRect = CGRectInset(CGRectUnion(centerXBarBorderRect,
                                                       [centerXBarPath bounds]),
                                           -1, -1);

        UIBezierPath * centerXBarNegativePath = [UIBezierPath bezierPathWithRect:centerXBarBorderRect];

        [centerXBarNegativePath appendPath:centerXBarPath];
        centerXBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightCenterOffset.width + round(centerXBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightCenterOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset),
                                                   yOffset + copysign(0.1, yOffset)),
                                        innerHighlightCenterBlurRadius,
                                        innerHighlightCenter.CGColor);

            [centerXBarPath addClip];

            CGAffineTransform   transform =
            CGAffineTransformMakeTranslation(-round(centerXBarBorderRect.size.width), 0);

            [centerXBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [centerXBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    if (layoutConfiguration[NSLayoutAttributeCenterY])
    {
        //// Center Y Bar Drawing
        UIBezierPath * centerYBarPath = [UIBezierPath bezierPathWithRoundedRect:centerYBarRect
                                                                   cornerRadius:centerYBarCornerRadius];

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, outerHighlightOffset,
                                    outerHighlightBlurRadius,
                                    outerHighlight.CGColor);
        [colors[[layoutConfiguration dependencyTypeForAttribute:NSLayoutAttributeCenterY]] setFill];
        [centerYBarPath fill];

        ////// Center Y Bar Inner Shadow
        CGRect   centerYBarBorderRect = CGRectInset([centerYBarPath bounds],
                                                    -innerHighlightCenterBlurRadius,
                                                    -innerHighlightCenterBlurRadius);

        centerYBarBorderRect = CGRectOffset(centerYBarBorderRect,
                                            -innerHighlightCenterOffset.width,
                                            -innerHighlightCenterOffset.height);
        centerYBarBorderRect = CGRectInset(CGRectUnion(centerYBarBorderRect,
                                                       [centerYBarPath bounds]),
                                           -1, -1);

        UIBezierPath * centerYBarNegativePath = [UIBezierPath bezierPathWithRect:centerYBarBorderRect];

        [centerYBarNegativePath appendPath:centerYBarPath];
        centerYBarNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            CGFloat   xOffset = innerHighlightCenterOffset.width + round(centerYBarBorderRect.size.width);
            CGFloat   yOffset = innerHighlightCenterOffset.height;

            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset),
                                                   yOffset + copysign(0.1, yOffset)),
                                        innerHighlightCenterBlurRadius,
                                        innerHighlightCenter.CGColor);

            [centerYBarPath addClip];

            CGAffineTransform   transform =
            CGAffineTransformMakeTranslation(-round(centerYBarBorderRect.size.width), 0);

            [centerYBarNegativePath applyTransform:transform];
            [[UIColor grayColor] setFill];
            [centerYBarNegativePath fill];
        }
        CGContextRestoreGState(context);

        CGContextRestoreGState(context);
    }

    _alignmentOverlay.contents = (__bridge id)(UIGraphicsGetImageFromCurrentImageContext().CGImage);
    UIGraphicsEndImageContext();

}

/**
 * Calls `drawOverlayInContext:inRect:`.
 */
- (void)drawRect:(CGRect)rect
{
    [_delegate drawOverlayInContext:UIGraphicsGetCurrentContext() inRect:rect];
}

@end

