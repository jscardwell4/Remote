//
// ControlStateSet.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "REImage.h"

@class   REButton;

#pragma mark - ControlStateSet

MSKIT_STATIC_INLINE BOOL IsValidControlState(NSInteger state) {
    return state >= 0 && state <= 7;
}

MSKIT_STATIC_INLINE BOOL IsInvalidControlState(NSInteger state) {
    return !IsValidControlState(state);
}

@interface ControlStateSet : NSManagedObject

@property (nonatomic, strong) REButton * button;

+ (ControlStateSet *)controlStateSetInContext:(NSManagedObjectContext *)context;
+ (ControlStateSet *)controlStateSetForButton:(REButton *)button;
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
+ (ControlStateColorSet *)colorSetForButton:(REButton *)button
                          withDefaultColors:(ControlStateColorSetDefault)defaultColors
                                       type:(ControlStateColorType)type;

- (BOOL)colorDefinedForState:(NSUInteger)state;
- (UIColor *)colorForState:(NSUInteger)state;
- (UIColor *)colorForState:(NSUInteger)state
           substituteIfNil:(BOOL)substitute
          substitutedState:(NSUInteger *)substitutedState;
- (void)setColor:(UIColor *)color forState:(NSUInteger)state;

@property (nonatomic, assign, readonly) int16_t   colorSetType;

+ (void)setClassShouldUseCache:(BOOL)shouldUseCache;

@end

#pragma mark - ControlStateImageSet

@interface ControlStateImageSet : ControlStateSet <MSCaching>

- (UIImage *)UIImageForState:(NSUInteger)state;
- (UIImage *)UIImageForState:(NSUInteger)state
             substituteIfNil:(BOOL)substitute
            substitutedState:(NSUInteger *)substitutedState;
- (REImage *)imageForState:(NSUInteger)state;
- (REImage *)imageForState:(NSUInteger)state
           substituteIfNil:(BOOL)substitute
          substitutedState:(NSUInteger *)substitutedState;
- (void)setImage:(REImage *)image forState:(NSUInteger)state;
+ (void)setClassShouldUseCache:(BOOL)shouldUseCache;

@end

#pragma mark - ControlStateButtonImageSet

@interface ControlStateButtonImageSet : ControlStateImageSet

+ (ControlStateButtonImageSet *)imageSetForButton:(REButton *)button;

@end

#pragma mark - ControlStateIconImageSet

@interface ControlStateIconImageSet : ControlStateImageSet <ControlStateColorSetDelegate>

@property (nonatomic, assign) BOOL   styleHighlightedIcon;

+ (ControlStateIconImageSet *)iconSetWithColors:(ControlStateColorSet *)colors icons:(NSDictionary *)icons;
+ (ControlStateIconImageSet *)iconSetForButton:(REButton *)button;

- (void)setIconColor:(UIColor *)color forState:(NSUInteger)state;
- (BOOL)iconColorDefinedForState:(NSUInteger)state;
- (UIColor *)iconColorForState:(NSUInteger)state;
- (void)removeIconStyleForState:(NSUInteger)state;
- (void)styleIconForState:(NSUInteger)state;

@property (nonatomic, strong) ControlStateColorSet * iconColors;

@end

#pragma mark - ControlStateTitleSet

@interface ControlStateTitleSet : ControlStateSet

+ (ControlStateTitleSet *)titleSetForButton:(REButton *)button;

+ (ControlStateTitleSet *)titleSetInContext:(NSManagedObjectContext *)context
                                 withTitles:(NSDictionary *)titles;
- (NSAttributedString *)titleForState:(NSUInteger)state;

- (void)setTitle:(NSAttributedString *)title forState:(NSUInteger)state;

@end
