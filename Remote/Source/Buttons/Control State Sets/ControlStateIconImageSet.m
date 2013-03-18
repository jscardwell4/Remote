//
// ControlStateIconImageSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ControlStateSet.h"
#import "ControlStateSet_Private.h"
#import "REButton.h"
#import "REImage.h"

static int   ddLogLevel = LOG_LEVEL_OFF;

@implementation ControlStateIconImageSet

@dynamic styleHighlightedIcon, iconColors, styledIconStates;

+ (ControlStateIconImageSet *)iconSetWithColors:(ControlStateColorSet *)colors icons:(NSDictionary *)icons {
    ControlStateIconImageSet * iconSet = nil;

    if (colors && icons) {
        iconSet = [NSEntityDescription insertNewObjectForEntityForName:@"ControlStateIconImageSet"
                                                inManagedObjectContext:colors.managedObjectContext];
        iconSet.iconColors = colors;
        [icons enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
                   if ([key isKindOfClass:[NSNumber class]])
                   [iconSet    setImage:obj
                            forState:[key unsignedIntegerValue]];
               }

        ];
    }

    return iconSet;
}

+ (ControlStateIconImageSet *)iconSetForButton:(REButton *)button {
    if (ValueIsNil(button)) return nil;

    ControlStateIconImageSet * imageSet =
        [NSEntityDescription insertNewObjectForEntityForName:@"ControlStateIconImageSet"
                                      inManagedObjectContext:button.managedObjectContext];

    imageSet.button     = button;
    imageSet.iconColors = [ControlStateColorSet colorSetForIcons:imageSet
                                               withDefaultColors:ControlStateTitleColorSet];

    return imageSet;
}

- (CGRect)patternColorFrameForState:(NSUInteger)state {
    CGRect    frame         = CGRectZero;
    UIImage * imageForState = [[self imageForState:state
                                          substituteIfNil:YES
                                         substitutedState:NULL] image];

    if (ValueIsNotNil(imageForState)) frame.size = imageForState.size;

    return frame;
}

- (void)removeIconStyleForState:(NSUInteger)state {
    if (IsInvalidControlState(state)) return;

    self.styledIconStates &= ~state;

// [self.iconColors removePatternColorForState:state];

    if (self.shouldUseCache) [self.imageCache insertObject:CollectionSafeValue(nil) atIndex:state];
}

- (void)styleIconForState:(NSUInteger)state {
    if (IsInvalidControlState(state)) return;

    self.styledIconStates |= state;

// [self.iconColors addPatternColorForState:state];

    if (self.shouldUseCache) [self.imageCache insertObject:CollectionSafeValue(nil) atIndex:state];
}

- (void)setIconColor:(UIColor *)color forState:(NSUInteger)state {
    [self.iconColors setColor:color forState:state];

    if (self.shouldUseCache) [self.imageCache insertObject:CollectionSafeValue(nil) atIndex:state];
}

- (UIColor *)iconColorForState:(NSUInteger)state {
    UIControlState   substitutedState = state;

    return [self.iconColors
            colorForState:state
                substituteIfNil:YES
               substitutedState:&substitutedState];
}

- (BOOL)iconColorDefinedForState:(NSUInteger)state {
    return [self.iconColors colorDefinedForState:state];
}

- (UIImage *)UIImageForState:(NSUInteger)state {
// DDLogDebug(@"%@\n\timage requested for state:%@\ncache contents:%@",
// ClassTagString,
// UIControlStateString(state),
// [self.imageCache debugDescription]);

    // Validate state
    if (IsInvalidControlState(state)) return nil;

    // Try retrieving image from cache
    UIControlState   substitutedState = state;
    BOOL             substituteUsed   = NO;

    // Determine which state will provide the image, if any
    if ([self alternateObjectStateForState:state substitutedState:&substitutedState]) substituteUsed = (state != substitutedState);
    else return nil;

    // Check the cache
    UIImage * image = nil;

    if (self.shouldUseCache) {
        image = self.imageCache[substitutedState];
                DDLogDebug(@"%@\n\tcached image? %@", ClassTagString, BOOLString((ValueIsNotNil(image))));

        // If cached image available, stick a reference to it in original state and return
        if (ValueIsNotNil(image)) {
            if (substituteUsed) [self.imageCache insertObject:image atIndex:state];

                DDLogDebug(@"%@\n\treturning cached image, using substitute? %@",
                       ClassTagString, BOOLString(substituteUsed));

            return image;
        }
    }

    // Otherwise retrieve icon color and create the image
    image = [super UIImageForState:substitutedState];

    UIColor * imageColor = [self.iconColors colorForState:state];

                DDLogDebug(@"%@\n\tbase image retrieved? %@ color retrieved for image:%@",
               ClassTagString, BOOLString(ValueIsNotNil(image)), [imageColor stringFromColor]);

    // Apply color if not nil
    if (ValueIsNotNil(image) && ValueIsNotNil(imageColor)) {
                DDLogDebug(@"%@\n\timage and color found, painting image with color", ClassTagString);
        image = [UIImage imageFromAlphaOfImage:image color:imageColor];
    }

    if (self.shouldUseCache)
        if (ValueIsNotNil(image)) {
            // Store image in cache
                DDLogDebug(@"%@\n\tinserting image into cache for state:%@",
                       ClassTagString, UIControlStateString(state));
            [self.imageCache insertObject:CollectionSafeValue(image) atIndex:state];

            if (state != substitutedState) {
                DDLogDebug(@"%@\n\tinserting image into cache for substituted state:%@",
                           ClassTagString, UIControlStateString(substitutedState));
                [self.imageCache insertObject:image atIndex:substitutedState];
            }
        }

    // Return the image
                DDLogDebug(@"%@\n\treturning non-null image? %@",
               ClassTagString, BOOLString(ValueIsNotNil(image)));

    return NilSafeValue(image);
}  /* imageForState */

@end
