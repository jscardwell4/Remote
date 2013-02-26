//
// ControlStateSet_Private.h
// iPhonto
//
// Created by Jason Cardwell on 3/27/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ControlStateSet.h"

@interface ControlStateSet ()

@property (nonatomic, strong) id   disabled;
@property (nonatomic, strong) id   disabledAndSelected;
@property (nonatomic, strong) id   highlighted;
@property (nonatomic, strong) id   highlightedAndDisabled;
@property (nonatomic, strong) id   highlightedAndSelected;
@property (nonatomic, strong) id   normal;
@property (nonatomic, strong) id   selected;
@property (nonatomic, strong) id   selectedHighlightedAndDisabled;
- (id)alternateObjectStateForState:(UIControlState)state
                  substitutedState:(UIControlState *)substitutedState;

@end

@interface ControlStateColorSet ()

// @property (nonatomic, strong) UIImage * disabledPatternImage;
// @property (nonatomic, strong) UIImage * disabledAndSelectedPatternImage;
// @property (nonatomic, strong) UIImage * highlightedPatternImage;
// @property (nonatomic, strong) UIImage * highlightedAndDisabledPatternImage;
// @property (nonatomic, strong) UIImage * highlightedAndSelectedPatternImage;
// @property (nonatomic, strong) UIImage * normalPatternImage;
// @property (nonatomic, strong) UIImage * selectedPatternImage;
// @property (nonatomic, strong) UIImage * selectedHighlightedAndDisabledPatternImage;
@property (nonatomic, strong) ControlStateIconImageSet * icons;
@property (nonatomic, assign, readwrite) int16_t         colorSetType;
@property (nonatomic, strong) NSMutableArray           * colorCache;
// @property (nonatomic, assign) int16_t patternColorStates;

+ (BOOL)classShouldUseCache;

// - (UIImage *)patternImageForState:(NSUInteger)state;
// - (void)setPatternImage:(UIImage *)image forState:(NSUInteger)state;
// - (void)generatePatternColorForState:(UIControlState)state;

@end

@interface ControlStateImageSet ()
@property (nonatomic, strong) NSMutableArray * imageCache;
+ (BOOL)classShouldUseCache;
@end

@interface ControlStateIconImageSet ()

@property (nonatomic, assign) int16_t   styledIconStates;

@end
