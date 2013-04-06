//
// ControlStateSet.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
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

@interface REControlStateSet : NSManagedObject

+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)context;
+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)context
                             withObjects:(NSDictionary *)objects;

- (id)objectAtIndexedSubscript:(NSUInteger)state;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)state;

@property (nonatomic, copy, readonly) NSString * uuid;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateColorSet
////////////////////////////////////////////////////////////////////////////////
@class REButton, REControlStateIconImageSet;

@interface REControlStateColorSet : REControlStateSet

- (UIColor *)objectAtIndexedSubscript:(NSUInteger)state;
@property (nonatomic, strong) REButton * button;
@property (nonatomic, strong) REControlStateIconImageSet * icon;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateImageSet
////////////////////////////////////////////////////////////////////////////////
@class BOImage;

@interface REControlStateImageSet : REControlStateSet

- (UIImage *)UIImageForState:(NSUInteger)state;

- (BOImage *)objectAtIndexedSubscript:(NSUInteger)state;
//- (void)setObject:(BOImage *)image atIndexedSubscript:(NSUInteger)state;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateButtonImageSet
////////////////////////////////////////////////////////////////////////////////
@class BOButtonImage;

@interface REControlStateButtonImageSet : REControlStateImageSet

- (BOButtonImage *)objectAtIndexedSubscript:(NSUInteger)state;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateIconImageSet
////////////////////////////////////////////////////////////////////////////////
@class BOIconImage;

@interface REControlStateIconImageSet : REControlStateImageSet


+ (REControlStateIconImageSet *)iconSetWithColors:(NSDictionary *)colors
                                            icons:(NSDictionary *)icons
                                          context:(NSManagedObjectContext *)context;

- (BOIconImage *)objectAtIndexedSubscript:(NSUInteger)state;

@property (nonatomic, strong) REControlStateColorSet * iconColors;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateTitleSet
////////////////////////////////////////////////////////////////////////////////

@interface REControlStateTitleSet : REControlStateSet

- (void)copyTitlesFromTitleSet:(REControlStateTitleSet *)titleSet;

- (NSAttributedString *)objectAtIndexedSubscript:(NSUInteger)state;

@end
