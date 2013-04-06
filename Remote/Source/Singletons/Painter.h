//
// Painter.h
// Remote
//
// Created by Jason Cardwell on 2/29/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>


@interface Painter : NSObject

+ (UIImage *)circledText:(NSString *)text
                    font:(UIFont *)font
         backgroundColor:(UIColor *)color
               textColor:(UIColor *)textColor
                    size:(CGSize)size;

+ (void)drawGlossGradientWithColor:(UIColor *)color
                            inRect:(CGRect)rect
                         inContext:(CGContextRef)context;

+ (void)drawLinearGradientInRect:(CGRect)rect
                  withStartColor:(CGColorRef)startColor
                        endColor:(CGColorRef)endColor
                       inContext:(CGContextRef)context;

+ (void)drawBorderForShape:(PainterShape)shape
                     color:(UIColor *)color
                     width:(CGFloat)width
                      join:(CGLineJoin)join
                      rect:(CGRect)rect
               cornerRadii:(CGSize)cornerRadii
                   context:(CGContextRef)context;

+ (void)drawBackdropForShape:(PainterShape)shape
                      inRect:(CGRect)rect
               backdropColor:(UIColor *)color
                 cornerRadii:(CGSize)cornerRadii
                   inContext:(CGContextRef)context;

+ (UIImage *)borderPathImage:(UIImage *)image color:(UIColor *)color width:(NSUInteger)width;

+ (NSArray *)borderPointsForImage:(UIImage *)image;

+ (UIBezierPath *)stretchedOvalFromRect:(CGRect)rect;

+ (UIBezierPath *)borderPathForImage:(UIImage *)image;

+ (UIImage *)embossImage:(UIImage *)image;

+ (UIImage *)blurImage:(UIImage *)image;

+ (void)drawLEDButtons;

+ (void)drawPowerButton;

+ (void)drawRoundedRectButton;

+ (void)drawRoundedRectButtonBaseInContext:(CGContextRef)context
                               buttonColor:(UIColor *)buttonColor
                               shadowColor:(UIColor *)shadowColor
                                    opaque:(BOOL)opaque
                                     frame:(CGRect)frame;

+ (void)drawRoundedRectButtonOverlayInContext:(CGContextRef)context
                                   shineColor:(UIColor *)shineColor
                                        frame:(CGRect)frame;

+ (void)drawIconButton;

+ (void)drawResizableButton;

+ (void)drawBlueButton;

+ (void)drawGlassShelf;

+ (void)drawProgressBar;

+ (void)drawOrganicSlider;

+ (void)drawCMYPad;

@end
