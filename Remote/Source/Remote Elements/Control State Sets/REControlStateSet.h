//
// ControlStateSet.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "MSModelObject.h"
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
MSKIT_STATIC_INLINE BOOL validState(NSUInteger state) {
    static const NSSet * validStates = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        validStates = [@[@0,@1,@2,@3,@4,@5,@6,@7] set];
    });
    return [validStates containsObject:@(state)];
}

MSKIT_STATIC_INLINE NSString * propertyForState(NSUInteger state) {
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

MSKIT_STATIC_INLINE NSUInteger stateForProperty(NSString * property) {
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

@interface REControlStateSet : MSModelObject <NSCopying>

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

- (void)copyObjectsFromSet:(REControlStateSet *)set;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateColorSet
////////////////////////////////////////////////////////////////////////////////
@class REButton, REControlStateImageSet;

@interface REControlStateColorSet : REControlStateSet

- (UIColor *)objectAtIndexedSubscript:(NSUInteger)state;
@property (nonatomic, strong) REButton * button;
@property (nonatomic, strong) REControlStateImageSet * imageSet;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateImageSet
////////////////////////////////////////////////////////////////////////////////
@class BOImage;

@interface REControlStateImageSet : REControlStateSet

+ (REControlStateImageSet *)imageSetWithImages:(NSDictionary *)images
                                       context:(NSManagedObjectContext *)moc;

+ (REControlStateImageSet *)imageSetWithColors:(id)colors
                                        images:(NSDictionary *)images
                                       context:(NSManagedObjectContext *)moc;

- (UIImage *)UIImageForState:(NSUInteger)state;

- (BOImage *)objectAtIndexedSubscript:(NSUInteger)state;

@property (nonatomic, strong) REControlStateColorSet * colors;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateTitleSet
////////////////////////////////////////////////////////////////////////////////

@interface REControlStateTitleSet : REControlStateSet

- (NSDictionary *)objectAtIndexedSubscript:(REState)state;

- (void)setObject:(id)obj forTitleAttribute:(NSString *)attributeKey;


@end

MSKIT_EXTERN_KEY(REForegroundColor);
MSKIT_EXTERN_KEY(REBackgroundColor);
MSKIT_EXTERN_KEY(REShadow);
MSKIT_EXTERN_KEY(REStrokeColor);
MSKIT_EXTERN_KEY(REStrokeWidth);
MSKIT_EXTERN_KEY(REStrikethroughStyle);
MSKIT_EXTERN_KEY(REUnderlineStyle);
MSKIT_EXTERN_KEY(REKern);
MSKIT_EXTERN_KEY(RELigature);
MSKIT_EXTERN_KEY(REParagraphStyle);
MSKIT_EXTERN_KEY(REFontName);
MSKIT_EXTERN_KEY(REFontSize);
MSKIT_EXTERN_KEY(RETitleText);
