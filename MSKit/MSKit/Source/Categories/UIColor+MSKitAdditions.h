//
//  UIColor+MSKitAdditions.h
//  Remote
//
//  Created by Jason Cardwell on 4/24/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ClearColor      [UIColor clearColor]
#define GreenColor      [UIColor greenColor]
#define RedColor        [UIColor redColor]
#define WhiteColor      [UIColor whiteColor]
#define BlueColor       [UIColor blueColor]
#define OrangeColor     [UIColor orangeColor]
#define BlackColor      [UIColor blackColor]
#define YellowColor     [UIColor yellowColor]
#define PurpleColor     [UIColor purpleColor]
#define GrayColor       [UIColor grayColor]
#define DarkGrayColor   [UIColor darkGrayColor]
#define LightGrayColor  [UIColor lightTextColor]
#define DarkTextColor   [UIColor darkTextColor]
#define LightTextColor  [UIColor lightGrayColor]
#define CyanColor       [UIColor cyanColor]
#define MagentaColor    [UIColor magentaColor]
#define BrownColor      [UIColor brownColor]
#define FlipsideColor   [UIColor colorWithR:31 G:33 B:36 A:255]
#define GroupTableColor [UIColor groupTableViewBackgroundColor]

#define ColorFromRGBHex(c)     [UIColor colorWithRGBHex:c]
#define ColorFromRGBAHex(c)    [UIColor colorWithRGBAHex:c]
#define ColorFromRGBA(r,g,b,a) [UIColor colorWithR:r G:g B:b A:a]
#define UIColorMake(r,g,b,a)   [UIColor colorWithRed:r green:g blue:b alpha:a]


NSString * NSStringFromCGColorSpaceModel(CGColorSpaceModel model);
NSString * NSStringFromCGColorRenderingIntent(CGColorRenderingIntent intent);
NSString * NSStringFromUIColor(UIColor * color);

@interface UIColor (MSKitAdditions)

@property (nonatomic, readonly) CGColorSpaceModel colorSpaceModel;
@property (nonatomic, readonly) BOOL              isRGBCompatible;
@property (nonatomic, readonly) CGFloat           red;
@property (nonatomic, readonly) CGFloat           green;
@property (nonatomic, readonly) CGFloat           blue;
@property (nonatomic, readonly) CGFloat           white;
@property (nonatomic, readonly) CGFloat           alpha;
@property (nonatomic, readonly) NSArray         * components;
@property (nonatomic, readonly) uint32_t          rgbHex;
@property (nonatomic, readonly) uint32_t          rgbaHex;
@property (nonatomic, readonly) UIColor         * rgbColor;
@property (nonatomic, readonly) UIColor         * invertedColor;
@property (nonatomic, readonly) UIColor         * luminanceMappedColor;

- (BOOL)isPatternBased;

- (UIColor *)colorByMultiplyingByRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a;
- (UIColor *)colorByMultiplyingBy:(CGFloat)f;
- (UIColor *)colorByMultiplyingByColor:(UIColor *)color;

- (UIColor *)colorByAddingRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a;
- (UIColor *)colorByAdding:(CGFloat)f;
- (UIColor *)colorByAddingColor:(UIColor *)color;

- (UIColor *)colorByLighteningToRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a;
- (UIColor *)colorByLighteningTo:(CGFloat)f;
- (UIColor *)colorByLighteningToColor:(UIColor *)color;

- (UIColor *)colorByDarkeningToRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a;
- (UIColor *)colorByDarkeningTo:(CGFloat)f;
- (UIColor *)colorByDarkeningToColor:(UIColor *)color;

+ (UIColor *)colorWithRGBHex:(uint32_t)hex;
+ (UIColor *)colorWithRGBAHex:(uint32_t)hex;
+ (UIColor *)colorWithR:(uint8_t)r G:(uint8_t)g B:(uint8_t)b A:(uint8_t)a;
+ (UIColor *)colorWithRGBHexString:(NSString *)string;
+ (UIColor *)colorWithRGBAHexString:(NSString *)string;

+ (UIColor *)colorWithName:(NSString *)name;
+ (NSArray *)colorNames;
+ (NSString *)nameForColor:(UIColor *)color ignoreAlpha:(BOOL)ignoreAlpha;

+ (UIColor *)randomColor;

- (NSString *)stringRepresentation;
- (NSString *)RGBHexStringRepresentation;
- (NSString *)RGBAHexStringRepresentation;

@end
