//
// RemoteElement.h
// Remote
//
// Created by Jason Cardwell on 10/3/12.
// Copyright © 2012 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
#import "RETypedefs.h"
#import "REEditableBackground.h"
#import "ConfigurationDelegate.h"
#import "LayoutConfiguration.h"
#import "Constraint.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element
////////////////////////////////////////////////////////////////////////////////
@class RemoteController, LayoutConfiguration, ConstraintManager, Image, Theme;

@interface RemoteElement : ModelObject <REEditableBackground, NamedModelObject>

// model backed properties
@property (nonatomic, assign, readwrite) int16_t                 tag;
@property (nonatomic, assign, readonly ) REType                  elementType;
@property (nonatomic, assign, readwrite) RESubtype               subtype;
@property (nonatomic, assign, readwrite) RERole                  role;
@property (nonatomic, assign, readwrite) REOptions               options;
@property (nonatomic, assign, readwrite) REState                 state;
@property (nonatomic, assign, readwrite) REShape                 shape;
@property (nonatomic, assign, readwrite) REStyle                 style;
@property (nonatomic, assign, readwrite) REThemeOverrideFlags    themeFlags;
@property (nonatomic, copy,   readwrite) NSString              * key;
@property (nonatomic, copy,   readwrite) NSString              * name;
@property (nonatomic, copy,   readonly ) NSString              * identifier;
@property (nonatomic, strong, readwrite) NSSet                 * constraints;
@property (nonatomic, strong, readonly ) NSSet                 * firstItemConstraints;
@property (nonatomic, strong, readonly ) NSSet                 * secondItemConstraints;
@property (nonatomic, assign, readwrite) CGFloat                 backgroundImageAlpha;
@property (nonatomic, strong, readwrite) UIColor               * backgroundColor;
@property (nonatomic, strong, readwrite) Image                 * backgroundImage;
@property (nonatomic, strong, readwrite) NSOrderedSet          * subelements;
@property (nonatomic, strong, readonly ) LayoutConfiguration   * layoutConfiguration;
@property (nonatomic, strong, readonly ) ConstraintManager     * constraintManager;
@property (nonatomic, strong, readonly ) Theme                 * theme;
@property (nonatomic, strong, readonly ) ConfigurationDelegate * configurationDelegate;

+ (instancetype)remoteElement;
+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)moc;
+ (instancetype)remoteElementWithAttributes:(NSDictionary *)attributes;
+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)moc
                            attributes:(NSDictionary *)attributes;

- (RemoteElement *)objectForKeyedSubscript:(NSString *)key;
- (RemoteElement *)objectAtIndexedSubscript:(NSUInteger)subscript;
- (void)setObject:(RemoteElement *)object atIndexedSubscript:(NSUInteger)idx;

- (void)applyTheme:(Theme *)theme;

@end

@interface RemoteElement (AbstractProperties)

@property (nonatomic, readonly) RemoteElement    * parentElement;
@property (nonatomic, readonly) RemoteController * controller;

@end

@interface RemoteElement (REConstraintManager)

- (void)setConstraintsFromString:(NSString *)constraints;

@end

@interface RemoteElement (RELayoutConfiguration)

@property (nonatomic, assign, readonly) BOOL    proportionLock;
@property (nonatomic, strong, readonly) NSSet * subelementConstraints;
@property (nonatomic, strong, readonly) NSSet * dependentConstraints;
@property (nonatomic, strong, readonly) NSSet * dependentChildConstraints;
@property (nonatomic, strong, readonly) NSSet * dependentSiblingConstraints;
@property (nonatomic, strong, readonly) NSSet * intrinsicConstraints;

@end

@class   Constraint;

@interface RemoteElement (SubelementsAccessors)

- (void)insertObject:(RemoteElement *)value inSubelementsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSubelementsAtIndex:(NSUInteger)idx;
- (void)insertSubelements:(NSArray *)value atIndexes:(NSIndexSet *)indices;
- (void)removeSubelementsAtIndexes:(NSIndexSet *)indices;
- (void)replaceObjectInSubelementsAtIndex:(NSUInteger)idx withObject:(RemoteElement *)value;
- (void)replaceSubelementsAtIndexes:(NSIndexSet *)indexes withSubelements:(NSArray *)values;
- (void)addSubelementsObject:(RemoteElement *)value;
- (void)removeSubelementsObject:(RemoteElement *)value;
- (void)addSubelements:(NSOrderedSet *)values;
- (void)removeSubelements:(NSOrderedSet *)values;

@end

@interface RemoteElement (ConstraintAccessors)

- (void)addConstraint:(Constraint *)constraint;
- (void)addConstraintsObject:(Constraint *)constraint;
- (void)removeConstraintsObject:(Constraint *)constraint;
- (void)addConstraints:(NSSet *)constraints;
- (void)removeConstraint:(Constraint *)constraint;
- (void)removeConstraints:(NSSet *)constraints;

- (void)addFirstItemConstraintsObject:(Constraint *)constraint;
- (void)removeFirstItemConstraintsObject:(Constraint *)constraint;
- (void)addFirstItemConstraints:(NSSet *)constraints;
- (void)removeFirstItemConstraints:(NSSet *)constraints;

- (void)addSecondItemConstraintsObject:(Constraint *)constraint;
- (void)removeSecondItemConstraintsObject:(Constraint *)constraint;
- (void)addSecondItemConstraints:(NSSet *)constraints;
- (void)removeSecondItemConstraints:(NSSet *)constraints;

@end

@interface RemoteElement (Debugging)

- (NSString *)recursiveDeepDescription;
- (NSString *)constraintsDescription;
- (NSString *)dumpElementHierarchy;
- (NSString *)flagsAndAppearanceDescription;

@end

MSEXTERN BOOL REStringIdentifiesRemoteElement(NSString * identifier, RemoteElement * re);

#define NSDictionaryOfVariableBindingsToIdentifiers(...) \
    _NSDictionaryOfVariableBindingsToIdentifiers(@"" # __VA_ARGS__, __VA_ARGS__, nil)

MSEXTERN NSDictionary * _NSDictionaryOfVariableBindingsToIdentifiers(NSString *, id , ...);
MSEXTERN Class classForREType(REType type);
//MSEXTERN Class baseClassForREType(REType type);
