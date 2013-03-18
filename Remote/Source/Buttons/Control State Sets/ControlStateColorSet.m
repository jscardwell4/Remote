//
// ControlStateColorSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ControlStateSet.h"
#import "ControlStateSet_Private.h"
#import "REButton.h"

static int    ddLogLevel = LOG_LEVEL_OFF;
static BOOL   useCache   = NO;

#pragma mark - ControlStateColorSet

@implementation ControlStateColorSet

// @dynamic disabledPatternImage;
// @dynamic selectedPatternImage;
// @dynamic highlightedAndDisabledPatternImage;
// @dynamic highlightedAndSelectedPatternImage;
// @dynamic highlightedPatternImage;
// @dynamic normalPatternImage;
// @dynamic disabledAndSelectedPatternImage;
// @dynamic selectedHighlightedAndDisabledPatternImage;
// @dynamic patternColorStates;
@dynamic colorSetType;
@dynamic icons;

@synthesize shouldUseCache = _shouldUseCache;
@synthesize colorCache     = _colorCache;

#pragma mark - Creating a ControlStateColorSet

+ (void)setClassShouldUseCache:(BOOL)shouldUseCache {
    useCache = shouldUseCache;
}

+ (BOOL)classShouldUseCache {
    return useCache;
}

- (void)setShouldUseCache:(BOOL)shouldUseCache {
    if (shouldUseCache && useCache) _shouldUseCache = YES;
    else _shouldUseCache = NO;
}

- (BOOL)shouldUseCache {
    if (_shouldUseCache && !useCache) _shouldUseCache = NO;

    return _shouldUseCache;
}

+ (ControlStateColorSet *)colorSetInContext:(NSManagedObjectContext *)context {
    return [self colorSetInContext:context
                 withDefaultColors:ControlStateColorSetEmpty
                              type:ControlStateUndefinedType];
}

+ (ControlStateColorSet *)colorSetInContext:(NSManagedObjectContext *)context
                                 withColors:(NSDictionary *)colors {
    ControlStateColorSet * colorSet = (ControlStateColorSet *)[super controlStateSetInContext:context];

    if (colorSet) {
        [colors enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
                    if ([key isKindOfClass:[NSNumber class]]) {
                    NSUInteger state = [key unsignedIntegerValue];
                    switch (state) {
                    case UIControlStateHighlighted :
                        colorSet.highlighted = obj; break;

                    case UIControlStateHighlighted | UIControlStateSelected :
                        colorSet.highlightedAndSelected = obj; break;

                    case UIControlStateHighlighted | UIControlStateDisabled :
                        colorSet.highlightedAndDisabled = obj; break;

                    case UIControlStateDisabled | UIControlStateSelected :
                        colorSet.disabledAndSelected = obj; break;

                    case UIControlStateSelected | UIControlStateHighlighted | UIControlStateDisabled :
                        colorSet.selectedHighlightedAndDisabled = obj; break;

                    case UIControlStateSelected :
                        colorSet.selected = obj; break;

                    case UIControlStateDisabled :
                        colorSet.disabled = obj; break;

                    case UIControlStateNormal :
                        colorSet.normal = obj; break;
                    } /* switch */
                    }
                }

        ];
    }

    return colorSet;
}

+ (ControlStateColorSet *)colorSetInContext:(NSManagedObjectContext *)context
                          withDefaultColors:(ControlStateColorSetDefault)defaultColors
                                       type:(ControlStateColorType)type {
    ControlStateColorSet * colorSet = (ControlStateColorSet *)[super controlStateSetInContext:context];

    if (colorSet) {
        switch (defaultColors) {
            case ControlStateColorSetBackgroundDefault :
                colorSet.normal = [[UIColor darkTextColor] colorWithAlphaComponent:1.00];
                break;

            case ControlStateColorSetTitleShadowDefault :
                break;

            case ControlStateColorSetTitleDefault :
                colorSet.normal      = [UIColor whiteColor];
                colorSet.highlighted = [UIColor colorWithRed:0 green:175.0 / 255.0 blue:1.0 alpha:1.0];
                colorSet.disabled    = [UIColor darkGrayColor];
                break;

            default :
                break;
        }  /* switch */

        colorSet.colorSetType = type;
    }

    return colorSet;
}

+ (ControlStateColorSet *)colorSetForIcons:(ControlStateIconImageSet *)icons {
    return [self colorSetForIcons:icons withDefaultColors:ControlStateColorSetEmpty];
}

+ (ControlStateColorSet *)colorSetForIcons:(ControlStateIconImageSet *)icons
                         withDefaultColors:(ControlStateColorSetDefault)defaultColors {
    ControlStateColorSet * colorSet = [self colorSetInContext:icons.managedObjectContext];

    if (colorSet) {
        colorSet.icons = icons;

        switch (defaultColors) {
            case ControlStateColorSetBackgroundDefault :
                colorSet.normal = [UIColor darkTextColor];
                break;

            case ControlStateColorSetTitleShadowDefault :
                break;

            case ControlStateColorSetTitleDefault :
                colorSet.normal      = [UIColor whiteColor];
                colorSet.highlighted = [UIColor colorWithRed:0 green:175.0 / 255.0 blue:1.0 alpha:1.0];
                colorSet.disabled    = [UIColor darkGrayColor];
                break;

            default :
                break;
        }  /* switch */
    }

    return colorSet;
}

+ (ControlStateColorSet *)colorSetForButton:(REButton *)button
                          withDefaultColors:(ControlStateColorSetDefault)defaultColors
                                       type:(ControlStateColorType)type {
    ControlStateColorSet * colorSet = [self colorSetInContext:button.managedObjectContext
                                            withDefaultColors:defaultColors
                                                         type:type];

    if (colorSet) colorSet.button = button;

    return colorSet;
}

#pragma mark - UIColor cache

- (NSMutableArray *)colorCache {
    if (!self.shouldUseCache) return nil;

    if (ValueIsNotNil(_colorCache)) return _colorCache;

    self.colorCache = [NSMutableArray arrayWithNullCapacity:8];

    return _colorCache;
}

- (void)emptyCache {
    if (_colorCache) [_colorCache replaceAllObjectsWithNull];
}

- (BOOL)colorDefinedForState:(NSUInteger)state {
    return ValueIsNotNil([super objectForState:state]);
}

#pragma mark - End result colors

- (UIColor *)colorForState:(NSUInteger)state {
            DDLogDebug(@"%@\n\tcolor requested for state:%@", ClassTagString, UIControlStateString(state));

    // Validate state
    if (IsInvalidControlState(state)) return nil;

    // Check cache for color and return if found
    UIColor * color = nil;

    if (self.shouldUseCache) {
        color = self.colorCache[state];
        if (ValueIsNotNil(color)) {
            DDLogDebug(@"%@\n\treturning color found in cache:%@",
                       ClassTagString, [color stringFromColor]);

            return color;
        }
    }

    // Check base color
    NSUInteger   substituteState = state;

    color = [self colorForState:state substituteIfNil:YES substitutedState:&substituteState];

    // Return if color could not be found
    if (ValueIsNil(color)) {
            DDLogDebug(@"%@\n\tcould not locate color or substitute, returning nil", ClassTagString);

        return nil;
    }

    if (self.shouldUseCache) {
        // Return if cache has substitute
        UIColor * substituteColor = self.colorCache[substituteState];

        if (ValueIsNotNil(substituteColor)) {
            DDLogDebug(@"%@\n\treturning cached color:%@ from substituted state:%@",
                       ClassTagString,
                       [substituteColor stringFromColor],
                       UIControlStateString(substituteState));

            return substituteColor;
        }
    }

    // Check whether pattern is needed
// if (self.patternColorStates & substituteState) {
// DDLogDebug(@"%@\n\tpattern color should be applied for state:%@",
// ClassTagString, UIControlStateString(substituteState));

    // Check if pattern already exists
// UIImage *patternImage = [self patternImageForState:substituteState];

    // If no pattern, generate it
// if (ValueIsNil(patternImage)) {
// DDLogDebug(@"%@\n\tno pattern exists for state:%@, creating pattern...",
// ClassTagString, UIControlStateString(substituteState));
// [self generatePatternColorForState:substituteState];
// patternImage = [self patternImageForState:substituteState];
// } else {
// DDLogDebug(@"%@\n\tpattern already exists for state:%@",
// ClassTagString, UIControlStateString(substituteState));
// }

    // If pattern was created successfully, insert pattern color in cache and return
// if (ValueIsNotNil(patternImage)) {
// DDLogDebug(@"%@\n\tapplying pattern image to color...", ClassTagString);
// color = [UIColor colorWithPatternImage:patternImage];
// } else {
// DDLogDebug(@"%@\n\tfailed to retrieve or create pattern image for state:%@",
// ClassTagString, UIControlStateString(substituteState));
// }
// }

    if (self.shouldUseCache) {
        // Cache color in original state as well, if substitute has been used
        DDLogDebug(@"%@\n\tinserting color into cache for state:%@ color is valid?"
                   " %@ color is pattern-based? %@",
                   ClassTagString,
                   UIControlStateString(state),
                   BOOLString(ValueIsNotNil(color)),
                   BOOLString([color isPatternBased]));
        [self.colorCache insertObject:CollectionSafeValue(color) atIndex:state];

        if (state != substituteState) {
            DDLogDebug(@"%@\n\talso inserting color into cache for substituted state:%@",
                       ClassTagString, UIControlStateString(substituteState));
            [self.colorCache insertObject:CollectionSafeValue(color) atIndex:substituteState];
        }
    }

            DDLogDebug(@"%@\n\treturning valid color? %@",
               ClassTagString, BOOLString(ValueIsNotNil(color)));

    return NilSafeValue(color);
}  /* colorForState */

- (void)setColor:(UIColor *)color forState:(NSUInteger)state {
// [self setBaseColor:color forState:state];
// }

// #pragma mark - Base colors

// - (void)setBaseColor:(UIColor *)color forState:(NSUInteger)state {
    if (IsInvalidControlState(state)) return;

    if ([color isPatternBased] || ValueIsNil(color)) color = nil;

    switch (state) {
        case UIControlStateHighlighted :
            self.highlighted = color;
            break;

        case UIControlStateHighlighted | UIControlStateSelected :
            self.highlightedAndSelected = color;
            break;

        case UIControlStateHighlighted | UIControlStateDisabled :
            self.highlightedAndDisabled = color;
            break;

        case UIControlStateDisabled | UIControlStateSelected :
            self.disabledAndSelected = color;
            break;

        case UIControlStateSelected | UIControlStateHighlighted | UIControlStateDisabled :
            self.selectedHighlightedAndDisabled = color;
            break;

        case UIControlStateSelected :
            self.selected = color;
            break;

        case UIControlStateDisabled :
            self.disabled = color;
            break;

        case UIControlStateNormal :
            self.normal = color;
            break;

        default :
            break;
    } /* switch */

// [self setPatternImage:nil forState:state];

    if (self.shouldUseCache) [self.colorCache insertObject:CollectionSafeValue(nil) atIndex:state];
}     /* setColor */

- (UIColor *)colorForState:(NSUInteger)state
           substituteIfNil:(BOOL)substitute
          substitutedState:(NSUInteger *)substitutedState {
    // Return nil if state is invalid
    if (IsInvalidControlState(state)) return nil;

    BOOL         substitutePointerOK   = (substitutedState != NULL);
    NSUInteger   localSubstitutedState = state;

    // Retrieve the base color from super's method
    UIColor * color = (UIColor *)[self alternateObjectStateForState:state
                                                   substitutedState:&localSubstitutedState];

    if (substitutePointerOK) *substitutedState = localSubstitutedState;

    if (!substitute && localSubstitutedState != state) color = nil;

    return NilSafeValue(color);
}

/*
 * - (UIColor *)baseColorForState:(NSUInteger)state {
 *      return [self baseColorForState:state substituteIfNil:NO substitutedState:NULL];
 * }
 *
 * #pragma mark - Pattern-based colors
 *
 *
 * - (UIImage *)patternImageForState:(NSUInteger)state {
 *      UIImage * patternImage = nil;
 *      if (InvalidControlState(state))
 *              return patternImage;
 *
 *      switch (state) {
 *              case NSUIntegerHighlighted:
 *                      patternImage = self.highlightedPatternImage;
 *                      break;
 *
 *              case NSUIntegerHighlighted|NSUIntegerSelected:
 *                      patternImage = self.highlightedAndSelectedPatternImage;
 *                      break;
 *
 *              case NSUIntegerHighlighted|NSUIntegerDisabled:
 *                      patternImage = self.highlightedAndDisabledPatternImage;
 *                      break;
 *
 *              case NSUIntegerDisabled|NSUIntegerSelected:
 *                      patternImage = self.disabledAndSelectedPatternImage;
 *                      break;
 *
 *              case NSUIntegerSelected|NSUIntegerHighlighted|NSUIntegerDisabled:
 *                      patternImage = self.selectedHighlightedAndDisabledPatternImage;
 *                      break;
 *
 *              case NSUIntegerSelected:
 *                      patternImage = self.selectedPatternImage;
 *                      break;
 *
 *              case NSUIntegerDisabled:
 *                      patternImage = self.disabledPatternImage;
 *                      break;
 *
 *              default:
 *                      patternImage = self.normalPatternImage;
 *                      break;
 *      }
 *      return patternImage;
 * }
 *
 * - (void)addPatternColorForState:(NSUInteger)state {
 *      if (InvalidControlState(state))
 *              return;
 *
 *      self.patternColorStates |= state;
 *      [self generatePatternColorForState:state];
 * }
 *
 * - (void)removePatternColorForState:(NSUInteger)state {
 *      if (InvalidControlState(state))
 *              return;
 *
 *      [self setPatternImage:nil forState:state];
 *      self.patternColorStates &= ~state;
 * }
 *
 * - (void)generatePatternColorForState:(NSUInteger)state {
 *
 *
 *      if (InvalidControlState(state))
 *              return;
 *
 *      CGRect frame = CGRectZero;
 *
 *      if (ValueIsNotNil(self.button))
 *              frame = [self.button patternColorFrameForState:state];
 *      else if (ValueIsNotNil(self.icons))
 *              frame = [self.icons patternColorFrameForState:state];
 *
 *      if (CGRectIsEmpty(frame))
 *              return;
 *
 *      UIColor * patternColor = [self baseColorForState:state];
 *      if (ValueIsNil(patternColor))
 *              return;
 *
 *      __block UIImage * patternImage = nil;
 *
 *      void(^createPatternImage)(void) = ^(void) {
 *              CGFloat locations[2] = {0.0, 1.0};
 *              CGPoint startPoint = CGPointMake(frame.size.width / 2.0, 0);
 *              CGPoint endPoint = CGPointMake(frame.size.width / 2.0, frame.size.height);
 *              NSArray * colors = @[patternColor, [UIColor whiteColor]];
 *
 *              UIGraphicsBeginImageContextWithOptions(frame.size, YES, MainScreenScale);
 *
 *              CGContextRef context = UIGraphicsGetCurrentContext();
 *              CGContextScaleCTM(context, 1, -1);
 *              CGContextTranslateCTM(context, 0, -frame.size.height);
 *              CGGradientRef gradient;
 *              CGColorSpaceRef colorspace;
 *              size_t numlocations = [colors count];
 *              CGFloat components[numlocations * 4];
 *
 *              int i = 0;
 *              for (UIColor * color in colors) {
 *                      // get components for color
 *                      const CGFloat * colorComponents;
 *                      size_t numberOfComponents = CGColorGetNumberOfComponents(color.CGColor);
 *                      colorComponents = CGColorGetComponents(color.CGColor);
 *                      if (numberOfComponents == 2) {
 *                              components[i++] = colorComponents[0];
 *                              components[i++] = colorComponents[0];
 *                              components[i++] = colorComponents[0];
 *                              components[i++] = colorComponents[1];
 *                      } else {
 *                              components[i++] = colorComponents[0];
 *                              components[i++] = colorComponents[1];
 *                              components[i++] = colorComponents[2];
 *                              components[i++] = colorComponents[3];
 *                      }
 *              }
 *
 *              colorspace = CGColorSpaceCreateDeviceRGB();
 *
 *              gradient = CGGradientCreateWithColorComponents(colorspace,
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *                                                                                       components,
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *                                                                                        locations,
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *                                                                                    numlocations);
 *
 *              CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
 *
 *              patternImage = UIGraphicsGetImageFromCurrentImageContext();
 *              UIGraphicsEndImageContext();
 *
 *              CGGradientRelease(gradient);
 *              CGColorSpaceRelease(colorspace);
 *
 *      };
 *
 *      if ([NSThread isMainThread])
 *              createPatternImage();
 *      else
 *              dispatch_sync(dispatch_get_main_queue(),createPatternImage);
 *
 *      if (patternImage) {
 *              [self setPatternImage:patternImage forState:state];
 *      }
 *
 *
 * }
 *
 * - (void)setPatternImage:(UIImage *)patternImage forState:(NSUInteger)state {
 *      if (InvalidControlState(state))
 *              return;
 *
 *      switch (state) {
 *              case NSUIntegerHighlighted:
 *                      self.highlightedPatternImage = patternImage;
 *                      break;
 *
 *              case NSUIntegerHighlighted|NSUIntegerSelected:
 *                      self.highlightedAndSelectedPatternImage = patternImage;
 *                      break;
 *
 *              case NSUIntegerHighlighted|NSUIntegerDisabled:
 *                      self.highlightedAndDisabledPatternImage = patternImage;
 *                      break;
 *
 *              case NSUIntegerDisabled|NSUIntegerSelected:
 *                      self.disabledAndSelectedPatternImage = patternImage;
 *                      break;
 *
 *              case NSUIntegerSelected:
 *                      self.selectedPatternImage = patternImage;
 *                      break;
 *
 *              case NSUIntegerSelected|NSUIntegerHighlighted|NSUIntegerDisabled:
 *                      self.selectedHighlightedAndDisabledPatternImage = patternImage;
 *                      break;
 *
 *              case NSUIntegerDisabled:
 *                      self.disabledPatternImage = patternImage;
 *                      break;
 *
 *              default:
 *                      self.normalPatternImage = patternImage;
 *                      break;
 *      }
 *
 *      if (self.shouldUseCache)
 *              [self.colorCache insertObject:CollectionSafeValue(nil) atIndex:state];
 * }
 *
 *
 */
#pragma mark - Debugging

- (NSString *)debugDescription {
    return [NSString stringWithFormat:
            @"normal:%@\n"
            "selected:%@\n"
            "highlighted:%@\n"
            "disabled:%@\n"
            "highlightedAndSelected:%@\n"
            "highlightedAndDisabled:%@\n"
            "disabledAndSelected:%@",
            self.normal,
            self.selected,
            self.highlighted,
            self.disabled,
            self.highlightedAndSelected,
            self.highlightedAndDisabled,
            self.disabledAndSelected];
}

@end
