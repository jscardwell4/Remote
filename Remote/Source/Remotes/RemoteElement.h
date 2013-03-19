//
// RemoteElement.h
// Remote
//
// Created by Jason Cardwell on 10/3/12.
// Copyright © 2012 Moondeer Studios. All rights reserved.
//

#import "REEditingViewController.h"
#import "REConstraintManager.h"

/**
 *
 * Bit vector assignments for `appearance`
 *
 *		   0xFF 0xFF   0xFF 0xFF 0xFF  0xFF  0xFF 0xFF
 * 		└──────┴─────────┴───┴──────┘
 *     				  ⬇             ⬇         ⬇       ⬇
 *			style          shape      size   alignment
 *
 */
/*
typedef NS_OPTIONS(uint64_t, REOptionsAlignment) {
    RemoteElementAlignmentOptionUndefined = 0 << 0xF,

    RemoteElementAlignmentOptionCenterXUnspecified = 0 << 0x0,
    RemoteElementAlignmentOptionCenterXParent      = 0x1,
    RemoteElementAlignmentOptionCenterXFocus       = 0x2,
    RemoteElementAlignmentOptionCenterXMask        = 0x3,

    RemoteElementAlignmentOptionCenterYUnspecified = 0 << 0x2,
    RemoteElementAlignmentOptionCenterYParent      = 0x4,
    RemoteElementAlignmentOptionCenterYFocus       = 0x8,
    RemoteElementAlignmentOptionCenterYMask        = 0xC,

    RemoteElementAlignmentOptionTopUnspecified = 0 << 0x4,
    RemoteElementAlignmentOptionTopParent      = 0x10,
    RemoteElementAlignmentOptionTopFocus       = 0x20,
    RemoteElementAlignmentOptionTopMask        = 0x30,

    RemoteElementAlignmentOptionLeftUnspecified = 0 << 0x6,
    RemoteElementAlignmentOptionLeftParent      = 0x40,
    RemoteElementAlignmentOptionLeftFocus       = 0x80,
    RemoteElementAlignmentOptionLeftMask        = 0xC0,

    RemoteElementAlignmentOptionBottomUnspecified = 0 << 0x8,
    RemoteElementAlignmentOptionBottomParent      = 0x100,
    RemoteElementAlignmentOptionBottomFocus       = 0x200,
    RemoteElementAlignmentOptionBottomMask        = 0x300,

    RemoteElementAlignmentOptionRightUnspecified = 0 << 0xA,
    RemoteElementAlignmentOptionRightParent      = 0x400,
    RemoteElementAlignmentOptionRightFocus       = 0x800,
    RemoteElementAlignmentOptionRightMask        = 0xC00,

    RemoteElementAlignmentOptionBaselineUnspecified = 0 << 0xC,
    RemoteElementAlignmentOptionBaselineParent      = 0x1000,
    RemoteElementAlignmentOptionBaselineFocus       = 0x2000,
    RemoteElementAlignmentOptionBaselineMask        = 0x3000,

    RemoteElementAlignmentOptionMaskParent = 0x1555,
    RemoteElementAlignmentOptionMaskFocus  = 0x2AAA,
    RemoteElementAlignmentOptionReserved   = 0xC000,
    REOptionsAlignmentMask      = 0xFFFF
};

REOptionsAlignment
alignmentOptionForNSLayoutAttribute(NSLayoutAttribute attribute, RERelationshipType type);

typedef NS_OPTIONS (uint64_t, REOptionsSizing) {
    RemoteElementSizingOptionUnspecified = 0 << 0x17,

        RemoteElementSizingOptionWidthUnspecified = 0 << 0x11,
        RemoteElementSizingOptionWidthIntrinsic   = 0x10000,
        RemoteElementSizingOptionWidthParent      = 0x20000,
        RemoteElementSizingOptionWidthFocus       = 0x30000,
        RemoteElementSizingOptionWidthMask        = 0x30000,

        RemoteElementSizingOptionHeightUnspecified = 0 << 0x13,
        RemoteElementSizingOptionHeightIntrinsic   = 0x40000,
        RemoteElementSizingOptionHeightParent      = 0x80000,
        RemoteElementSizingOptionHeightFocus       = 0xC0000,
        RemoteElementSizingOptionHeightMask        = 0xC0000,

        REOptionsSizingProportionLock = 0x100000,

        RemoteElementSizingOptionReserved = 0xC00000,
        REOptionsSizingMask    = 0xFF0000
};

REOptionsSizing
sizingOptionForNSLayoutAttribute(NSLayoutAttribute attribute, RERelationshipType type);
*/

typedef NS_ENUM (uint64_t, REShape) {
    REShapeUndefined        = 0 << 0x2F,
    REShapeRoundedRectangle = 0x1000000,
    REShapeOval             = 0x2000000,
    REShapeRectangle        = 0x3000000,
    REShapeTriangle         = 0x4000000,
    REShapeDiamond          = 0x5000000,
    REShapeReserved         = 0xFFFFF8000000,
    REShapeMask             = 0xFFFFFF000000
};

typedef NS_OPTIONS (uint64_t, REStyle) {
    REStyleUndefined   = 0 << 0x3F,
    REStyleApplyGloss  = 0x1000000000000,
    REStyleDrawBorder  = 0x2000000000000,
    REStyleStretchable = 0x4000000000000,
    REStyleReserved    = 0xFFF8000000000000,
    REStyleMask        = 0xFFFF000000000000
};

/**
 *
 * Bit vector assignments for `flags`
 *
 *           0xFF 0xFF   0xFF 0xFF   0xFF 0xFF  0xFF 0xFF
 *         └──────┴──────┴──────┴──────┘
 *             ⬇           ⬇        	⬇          ⬇
 *           state       options    	  subtype      type
 *
 */
typedef NS_ENUM (uint64_t, REType){
    RETypeUndefined   = 0 << 0xF,
    RETypeRemote      = 0x1,
    RETypeButtonGroup = 0x2,
    RETypeButton      = 0x3,
    RETypeBaseMask    = 0xC,
    RETypeReserved    = 0xFFF0,
    RETypeMask        = 0xFFFF
};

typedef NS_ENUM (uint64_t, RESubtype) {
    RESubtypeUndefined  = 0 << 0x1F,
    RESubtypeReserved   = 0xFFFF0000,
    RESubtypeMask       = 0xFFFF0000
};

typedef NS_ENUM (uint64_t, REOptions) {
    REOptionsUndefined = 0 << 0x2F,
    REOptionsReserved  = 0xFFFF00000000,
    REOptionsMask      = 0xFFFF00000000
};

typedef NS_OPTIONS (uint64_t, REState) {
    REStateDefault  = 0 << 0x3F,
    REStateReserved = 0xFFFF000000000000,
    REStateMask     = 0xFFFF000000000000
};

// TODO: Should editing go in the view file?
typedef NS_ENUM (uint64_t, EditingMode) {
    EditingModeEditingNone        = RETypeUndefined,
    EditingModeEditingRemote      = RETypeRemote,
    EditingModeEditingButtonGroup = RETypeButtonGroup,
    EditingModeEditingButton      = RETypeButton
};

MSKIT_STATIC_INLINE NSString * EditingModeString(EditingMode mode) {
    NSMutableString * modeString = [NSMutableString string];

    if (mode & EditingModeEditingRemote) {
        [modeString appendString:@"EditingModeEditingRemote"];
        if (mode & EditingModeEditingButtonGroup) {
            [modeString appendString:@"|EditingModeEditingButtonGroup"];
            if (mode & EditingModeEditingButton) [modeString appendString:@"|EditingModeEditingButton"];
        }
    }

    else
        [modeString appendString:@"EditingModeEditingNone"];


    return modeString;
}

@class   RERemoteController, RELayoutConfiguration;

@interface RemoteElement : NSManagedObject <EditableBackground>

// model backed properties
@property (nonatomic, assign)                   int16_t                 tag;
@property (nonatomic, copy)                     NSString              * key;
@property (nonatomic, copy)                     NSString              * uuid;
@property (nonatomic, copy)                     NSString              * displayName;
@property (nonatomic, strong)                   NSSet                 * constraints;
@property (nonatomic, strong)                   NSSet                 * firstItemConstraints;
@property (nonatomic, strong)                   NSSet                 * secondItemConstraints;
@property (nonatomic, assign)                   CGFloat                 backgroundImageAlpha;
@property (nonatomic, strong)                   UIColor               * backgroundColor;
@property (nonatomic, strong)                   REImage               * backgroundImage;
@property (nonatomic, strong)                   RERemoteController    * controller;
@property (nonatomic, strong)                   RemoteElement         * parentElement;
@property (nonatomic, strong)                   NSOrderedSet          * subelements;
@property (nonatomic, strong, readonly)         RELayoutConfiguration * layoutConfiguration;
@property (nonatomic, strong, readonly)         REConstraintManager   * constraintManager;

+ (id)remoteElementInContext:(NSManagedObjectContext *)context withAttributes:(NSDictionary *)attributes;
+ (id)remoteElementOfType:(REType)type context:(NSManagedObjectContext *)context;
- (RemoteElement *)objectForKeyedSubscript:(NSString *)key;

@end

@interface RemoteElement (LayoutConfiguration)

@property (nonatomic, assign, readonly) BOOL    proportionLock;
@property (nonatomic, strong, readonly) NSSet * subelementConstraints;
@property (nonatomic, strong, readonly) NSSet * dependentConstraints;
@property (nonatomic, strong, readonly) NSSet * dependentChildConstraints;
@property (nonatomic, strong, readonly) NSSet * dependentSiblingConstraints;
@property (nonatomic, strong, readonly) NSSet * intrinsicConstraints;

@end

@interface RemoteElement (FLagsAndOptions)

@property (nonatomic, assign)           REShape     shape;
@property (nonatomic, assign)           REStyle     style;
@property (nonatomic, readonly)         REType      type;
@property (nonatomic, readonly)         RESubtype   subtype;
@property (nonatomic, assign)           REOptions   options;
@property (nonatomic, readonly)         REState     state;

- (uint64_t)flagsWithMask:(uint64_t)mask;
- (uint64_t)appearanceWithMask:(uint64_t)mask;
- (void)setFlags:(uint64_t)flags mask:(uint64_t)mask;
- (void)setAppearance:(uint64_t)appearance mask:(uint64_t)mask;
- (void)setFlagBits:(uint64_t)flagBits;
- (void)unsetFlagBits:(uint64_t)flagsBits;
- (void)toggleFlagBits:(uint64_t)flagBits mask:(uint64_t)mask;
- (void)setAppearanceBits:(uint64_t)appearanceBits;
- (void)unsetAppearanceBits:(uint64_t)appearanceBits;
- (void)toggleAppearanceBits:(uint64_t)appearanceBits mask:(uint64_t)mask;
- (BOOL)isFlagSetForBits:(uint64_t)bits;
- (BOOL)isAppearanceSetforBits:(uint64_t)bits;

@end

@class   REConstraint;

@interface RemoteElement (SubelementsAccessors)

- (void)insertObject:(RemoteElement *)value inSubelementsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSubelementsAtIndex:(NSUInteger)idx;
- (void)insertSubelements:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSubelementsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSubelementsAtIndex:(NSUInteger)idx withObject:(RemoteElement *)value;
- (void)replaceSubelementsAtIndexes:(NSIndexSet *)indexes withSubelements:(NSArray *)values;
- (void)addSubelementsObject:(RemoteElement *)value;
- (void)removeSubelementsObject:(RemoteElement *)value;
- (void)addSubelements:(NSOrderedSet *)values;
- (void)removeSubelements:(NSOrderedSet *)values;

@end

@interface RemoteElement (ConstraintAccessors)

- (void)addConstraint:(REConstraint *)constraint;
- (void)addConstraintsObject:(REConstraint *)constraint;
- (void)removeConstraintsObject:(REConstraint *)constraint;
- (void)addConstraints:(NSSet *)constraints;
- (void)removeConstraint:(REConstraint *)constraint;
- (void)removeConstraints:(NSSet *)constraints;

- (void)addFirstItemConstraintsObject:(REConstraint *)constraint;
- (void)removeFirstItemConstraintsObject:(REConstraint *)constraint;
- (void)addFirstItemConstraints:(NSSet *)constraints;
- (void)removeFirstItemConstraints:(NSSet *)constraints;

- (void)addSecondItemConstraintsObject:(REConstraint *)constraint;
- (void)removeSecondItemConstraintsObject:(REConstraint *)constraint;
- (void)addSecondItemConstraints:(NSSet *)constraints;
- (void)removeSecondItemConstraints:(NSSet *)constraints;

@end

@interface RemoteElement (Debugging)

- (NSString *)constraintsDescription;
- (NSString *)dumpElementHierarchy;
- (NSString *)flagsAndAppearanceDescription;

@end

MSKIT_STATIC_INLINE BOOL REStringIdentifiesRemoteElement(NSString * identifier, RemoteElement * re) {
    return (   StringIsNotEmpty(identifier)
            && ([identifier isEqualToString:re.uuid] || [identifier isEqualToString:re.key]));
}

#define NSDictionaryOfVariableBindingsToIdentifiers(...) \
    _NSDictionaryOfVariableBindingsToIdentifiers(@"" # __VA_ARGS__, __VA_ARGS__, nil)

MSKIT_EXTERN NSDictionary *
_NSDictionaryOfVariableBindingsToIdentifiers(NSString * commaSeparatedKeysString, id firstValue, ...);
