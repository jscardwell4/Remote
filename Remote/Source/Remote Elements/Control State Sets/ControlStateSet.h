//
// ControlStateSet.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
#import "RETypedefs.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateSet
////////////////////////////////////////////////////////////////////////////////

@interface ControlStateSet : ModelObject <NSCopying>

+ (instancetype)controlStateSet;
+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)moc;
+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)moc
                             withObjects:(NSDictionary *)objects;

+ (BOOL)validState:(NSUInteger)state;
+ (NSString *)propertyForState:(NSUInteger)state;
+ (NSUInteger)stateForProperty:(NSString *)property;

- (BOOL)isEmptySet;
- (NSDictionary *)dictionaryFromSetObjects;

// objectAtIndex: and objectForKey: do not use fall through logic
// where as objectAtIndexedSubscript: and objectForKeyedSubscript: do use fall through logic
- (id)objectAtIndex:(NSUInteger)state;
- (id)objectForKey:(NSString *)key;
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
