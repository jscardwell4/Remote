//
// ControlStateSet.h
// iPhonto
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "GalleryImage.h"

@class   Button;

#pragma mark - ControlStateSet

MSKIT_STATIC_INLINE BOOL ValidControlState(NSInteger state) {
    return state >= 0 && state <= 7;
}

MSKIT_STATIC_INLINE BOOL InvalidControlState(NSInteger state) {
    return !ValidControlState(state);
}

@interface ControlStateSet : NSManagedObject

@property (nonatomic, strong) Button * button;

+ (ControlStateSet *)controlStateSetInContext:(NSManagedObjectContext *)context;
+ (ControlStateSet *)controlStateSetForButton:(Button *)button;
- (id)objectForState:(NSUInteger)state;
- (void)setObject:(id)object forState:(NSUInteger)state;

@end

#pragma mark - ControlStateColorSet

typedef NS_ENUM (NSInteger, ControlStateColorSetDefault) {
    ControlStateColorSetEmpty              = 0,
    ControlStateColorSetTitleDefault       = 1,
    ControlStateColorSetBackgroundDefault  = 2,
    ControlStateColorSetTitleShadowDefault = 3
};
typedef NS_ENUM (NSInteger, ControlStateColorType) {
    ControlStateUndefinedType       = 0,
    ControlStateTitleColorSet       = 1,
    ControlStateTitleShadowColorSet = 2,
    ControlStateBackgroundColorSet  = 3
};

@protocol ControlStateColorSetDelegate <NSObject>

- (CGRect)patternColorFrameForState:(NSUInteger)state;

@end

@class   ControlStateIconImageSet;

@interface ControlStateColorSet : ControlStateSet <MSCaching>
+ (ControlStateColorSet *)colorSetInContext:(NSManagedObjectContext *)context
                                 withColors:(NSDictionary *)colors;
+ (ControlStateColorSet *)colorSetInContext:(NSManagedObjectContext *)context;
+ (ControlStateColorSet *)colorSetInContext:(NSManagedObjectContext *)context
                          withDefaultColors:(ControlStateColorSetDefault)defaultColors
                                       type:(ControlStateColorType)type;
+ (ControlStateColorSet *)colorSetForIcons:(ControlStateIconImageSet *)icons;
+ (ControlStateColorSet *)colorSetForIcons:(ControlStateIconImageSet *)icons
                         withDefaultColors:(ControlStateColorSetDefault)defaultColors;
+ (ControlStateColorSet *)colorSetForButton:(Button *)button
                          withDefaultColors:(ControlStateColorSetDefault)defaultColors
                                       type:(ControlStateColorType)type;

- (BOOL)colorDefinedForState:(NSUInteger)state;
- (UIColor *)colorForState:(NSUInteger)state;
// - (UIColor *)baseColorForState:(NSUInteger)state;
- (UIColor *)colorForState:(NSUInteger)state
           substituteIfNil:(BOOL)substitute
          substitutedState:(NSUInteger *)substitutedState;
// - (void)setBaseColor:(UIColor *)color forState:(NSUInteger)state;
// - (void)removePatternColorForState:(NSUInteger)state;
// - (void)addPatternColorForState:(NSUInteger)state;
- (void)setColor:(UIColor *)color forState:(NSUInteger)state;
@property (nonatomic, assign, readonly) int16_t   colorSetType;

+ (void)setClassShouldUseCache:(BOOL)shouldUseCache;

@end

#pragma mark - ControlStateImageSet

@interface ControlStateImageSet : ControlStateSet <MSCaching>

- (UIImage *)imageForState:(NSUInteger)state;
- (UIImage *)imageForState:(NSUInteger)state
           substituteIfNil:(BOOL)substitute
          substitutedState:(NSUInteger *)substitutedState;
- (GalleryImage *)galleryImageForState:(NSUInteger)state;
- (GalleryImage *)galleryImageForState:(NSUInteger)state
                       substituteIfNil:(BOOL)substitute
                      substitutedState:(NSUInteger *)substitutedState;
- (void)setImage:(GalleryImage *)image forState:(NSUInteger)state;
+ (void)setClassShouldUseCache:(BOOL)shouldUseCache;

@end

#pragma mark - ControlStateButtonImageSet

@interface ControlStateButtonImageSet : ControlStateImageSet

+ (ControlStateButtonImageSet *)imageSetForButton:(Button *)button;

@end

#pragma mark - ControlStateIconImageSet

@interface ControlStateIconImageSet : ControlStateImageSet <ControlStateColorSetDelegate>

@property (nonatomic, assign) BOOL   styleHighlightedIcon;

+ (ControlStateIconImageSet *)iconSetWithColors:(ControlStateColorSet *)colors icons:(NSDictionary *)icons;
+ (ControlStateIconImageSet *)iconSetForButton:(Button *)button;

- (void)setIconColor:(UIColor *)color forState:(NSUInteger)state;
- (BOOL)iconColorDefinedForState:(NSUInteger)state;
- (UIColor *)iconColorForState:(NSUInteger)state;
- (void)removeIconStyleForState:(NSUInteger)state;
- (void)styleIconForState:(NSUInteger)state;

@property (nonatomic, strong) ControlStateColorSet * iconColors;

@end

#pragma mark - ControlStateTitleSet

@interface ControlStateTitleSet : ControlStateSet

+ (ControlStateTitleSet *)titleSetForButton:(Button *)button;

+ (ControlStateTitleSet *)titleSetInContext:(NSManagedObjectContext *)context
                                 withTitles:(NSDictionary *)titles;
- (NSAttributedString *)titleForState:(NSUInteger)state;

- (void)setTitle:(NSAttributedString *)title forState:(NSUInteger)state;

@end
