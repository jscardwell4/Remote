//
// ControlStateSet.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
#import "RETypedefs.h"

/**
 *
 * valid UIControlState bit combinations:
 * UIControlStateNormal: 0
 * UIControlStateHighlighted: 1
 * UIControlStateDisabled: 2
 * UIControlStateHighlighted|UIControlStateDisabled: 3
 * UIControlStateSelected: 4
 * UIControlStateHighlighted|UIControlStateSelected: 5
 * UIControlStateDisabled|UIControlStateSelected: 6
 * UIControlStateSelected|UIControlStateHighlighted|UIControlStateDisabled: 7
 *
 */
MSSTATIC_INLINE BOOL validState(NSUInteger state) {
    static const NSSet * validStates = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        validStates = [@[@0,@1,@2,@3,@4,@5,@6,@7] set];
    });
    return [validStates containsObject:@(state)];
}

MSSTATIC_INLINE NSString * propertyForState(NSUInteger state) {
    switch (state) {
        case UIControlStateNormal:
            return @"normal";

        case UIControlStateHighlighted:
            return @"highlighted";

        case UIControlStateDisabled:
            return @"disabled";

        case UIControlStateHighlighted|UIControlStateDisabled:
            return @"highlightedAndDisabled";

        case UIControlStateSelected:
            return @"selected";

        case UIControlStateSelected|UIControlStateHighlighted:
            return @"highlightedAndSelected";

        case UIControlStateSelected|UIControlStateDisabled:
            return @"disabledAndSelected";

        case UIControlStateSelected|UIControlStateDisabled|UIControlStateHighlighted:
            return @"selectedHighlightedAndDisabled";
            
        default:
            return nil;
    }
}

MSSTATIC_INLINE NSUInteger stateForProperty(NSString * property) {
    static const NSDictionary * properties = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        properties = @{@"normal"                         : @0,
                       @"highlighted"                    : @1,
                       @"disabled"                       : @2,
                       @"highlightedAndDisabled"         : @3,
                       @"selected"                       : @4,
                       @"highlightedAndSelected"         : @5,
                       @"disabledAndSelected"            : @6,
                       @"selectedHighlightedAndDisabled" : @7};

    });
    return NSUIntegerValue(properties[property]);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateSet
////////////////////////////////////////////////////////////////////////////////

@interface ControlStateSet : ModelObject <NSCopying>

+ (instancetype)controlStateSet;
+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)moc;
+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)moc
                             withObjects:(NSDictionary *)objects;

- (NSDictionary *)dictionaryFromSetObjects;

- (id)objectAtIndexedSubscript:(NSUInteger)state;
- (id)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)state;
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;
- (void)setObject:(id)obj forStates:(NSArray *)states;

- (void)copyObjectsFromSet:(ControlStateSet *)set;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateColorSet
////////////////////////////////////////////////////////////////////////////////
@class Button, ControlStateImageSet;

@interface ControlStateColorSet : ControlStateSet

- (UIColor *)objectAtIndexedSubscript:(NSUInteger)state;
@property (nonatomic, strong) Button * button;
@property (nonatomic, strong) ControlStateImageSet * imageSet;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateImageSet
////////////////////////////////////////////////////////////////////////////////
@class Image;

@interface ControlStateImageSet : ControlStateSet

+ (ControlStateImageSet *)imageSetWithImages:(NSDictionary *)images
                                       context:(NSManagedObjectContext *)moc;

+ (ControlStateImageSet *)imageSetWithColors:(id)colors
                                        images:(NSDictionary *)images
                                       context:(NSManagedObjectContext *)moc;

- (UIImage *)UIImageForState:(NSUInteger)state;

- (Image *)objectAtIndexedSubscript:(NSUInteger)state;

@property (nonatomic, strong) ControlStateColorSet * colors;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateTitleSet
////////////////////////////////////////////////////////////////////////////////

@interface ControlStateTitleSet : ControlStateSet

- (NSDictionary *)objectAtIndexedSubscript:(REState)state;

- (void)setObject:(id)obj forTitleAttribute:(NSString *)attributeKey;


@end

MSEXTERN_KEY(REForegroundColor);
MSEXTERN_KEY(REBackgroundColor);
MSEXTERN_KEY(REShadow);
MSEXTERN_KEY(REStrokeColor);
MSEXTERN_KEY(REStrokeWidth);
MSEXTERN_KEY(REStrikethroughStyle);
MSEXTERN_KEY(REUnderlineStyle);
MSEXTERN_KEY(REKern);
MSEXTERN_KEY(RELigature);
MSEXTERN_KEY(REParagraphStyle);
MSEXTERN_KEY(REFontName);
MSEXTERN_KEY(REFontSize);
MSEXTERN_KEY(RETitleText);
