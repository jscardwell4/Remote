//
// Painter.h
// iPhonto
//
// Created by Jason Cardwell on 2/29/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM (NSInteger, PainterShape) {
    PainterShapeUndefined        = 0,
    PainterShapeRoundedRectangle = 1,
    PainterShapeOval             = 2,
    PainterShapeRectangle        = 3,
    PainterShapeTriangle         = 4,
    PainterShapeDiamond          = 5
};

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

@end
