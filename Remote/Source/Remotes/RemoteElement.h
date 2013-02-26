//
// RemoteElement.h
// iPhonto
//
// Created by Jason Cardwell on 10/3/12.
// Copyright © 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteElementEditingViewController.h"
#import "RemoteElementConstraintManager.h"

typedef NS_ENUM (uint8_t, RemoteElementRelationshipType) {
    RemoteElementParentRelationship,
    RemoteElementChildRelationship,
    RemoteElementSiblingRelationship,
    RemoteElementIntrinsicRelationship
};

/**
 *
 * Bit vector assignments for `appearance`
 *
 *   0xFF 0xFF   0xFF 0xFF 0xFF   0xFF  0xFF 0xFF
 * └──────┴─────────┴───┴──────┘
 *     ⬇             ⬇         ⬇       ⬇
 *   style          shape       size   alignment
 *
 */
typedef NS_OPTIONS(uint64_t, RemoteElementAlignmentOptions) {
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
    RemoteElementAlignmentOptionsMask      = 0xFFFF
};

RemoteElementAlignmentOptions alignmentOptionForNSLayoutAttribute(NSLayoutAttribute attribute, RemoteElementRelationshipType type);

typedef NS_OPTIONS (uint64_t, RemoteElementSizingOptions) {
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

        RemoteElementSizingOptionsProportionLock = 0x100000,

        RemoteElementSizingOptionReserved = 0xC00000,
        RemoteElementSizingOptionsMask    = 0xFF0000
};

RemoteElementSizingOptions sizingOptionForNSLayoutAttribute(NSLayoutAttribute attribute, RemoteElementRelationshipType type);

typedef NS_ENUM (uint64_t, RemoteElementShape) {
    RemoteElementShapeUndefined            = 0 << 0x2F,
        RemoteElementShapeRoundedRectangle = 0x1000000,
        RemoteElementShapeOval             = 0x2000000,
        RemoteElementShapeRectangle        = 0x3000000,
        RemoteElementShapeTriangle         = 0x4000000,
        RemoteElementShapeDiamond          = 0x5000000,
        RemoteElementShapeReserved         = 0xFFFFF8000000,
        RemoteElementShapeMask             = 0xFFFFFF000000
};
typedef NS_OPTIONS (uint64_t, RemoteElementStyle) {
    RemoteElementNoStyle              = 0 << 0x3F,
        RemoteElementStyleApplyGloss  = 0x1000000000000,
        RemoteElementStyleDrawBorder  = 0x2000000000000,
        RemoteElementStyleStretchable = 0x4000000000000,
        RemoteElementStyleReserved    = 0xFFF8000000000000,
        RemoteElementStyleMask        = 0xFFFF000000000000
};

/**
 *
 * Bit vector assignments for `flags`
 *
 *   0xFF 0xFF   0xFF 0xFF   0xFF 0xFF  0xFF 0xFF
 * └──────┴──────┴──────┴──────┘
 *     ⬇           ⬇        ⬇            ⬇
 *   state       options    subtype     type
 *
 */
typedef NS_ENUM (uint64_t, RemoteElementType) {
    RemoteElementUnspecifiedType     = 0 << 0xF,
        RemoteElementRemoteType      = 0x1,
        RemoteElementButtonGroupType = 0x2,
        RemoteElementButtonType      = 0x3,
        RemoteElementBaseTypeMask    = 0xC,
        RemoteElementTypeReserved    = 0xFFF0,
        RemoteElementTypeMask        = 0xFFFF
};
typedef NS_ENUM (uint64_t, RemoteElementSubtype) {
    RemoteElementUnspecifiedSubtype  = 0 << 0x1F,
        RemoteElementSubtypeReserved = 0xFFFF0000,
        RemoteElementSubtypeMask     = 0xFFFF0000
};
typedef NS_ENUM (uint64_t, RemoteElementOptions) {
    RemoteElementNoOptions           = 0 << 0x2F,
        RemoteElementOptionsReserved = 0xFFFF00000000,
        RemoteElementOptionsMask     = 0xFFFF00000000
};
typedef NS_OPTIONS (uint64_t, RemoteElementState) {
    RemoteElementDefaultState      = 0 << 0x3F,
        RemoteElementStateReserved = 0xFFFF000000000000,
        RemoteElementStateMask     = 0xFFFF000000000000
};

// TODO: Should editing go in the view file?
typedef NS_ENUM (uint64_t, EditingMode) {
    EditingModeEditingNone        = RemoteElementUnspecifiedType,
    EditingModeEditingRemote      = RemoteElementRemoteType,
    EditingModeEditingButtonGroup = RemoteElementButtonGroupType,
    EditingModeEditingButton      = RemoteElementButtonType
};

MSKIT_STATIC_INLINE NSString * NSStringFromEditingMode(EditingMode mode) {
    NSMutableString * modeString = [NSMutableString string];

    if (mode & EditingModeEditingRemote) {
        [modeString appendString:@"EditingModeEditingRemote"];
        if (mode & EditingModeEditingButtonGroup) {
            [modeString appendString:@"|EditingModeEditingButtonGroup"];
            if (mode & EditingModeEditingButton) [modeString appendString:@"|EditingModeEditingButton"];
        }
    } else
        [modeString appendString:@"EditingModeEditingNone"];


    return modeString;
}

@class   RemoteController, RemoteElementLayoutConfiguration;

@interface RemoteElement : NSManagedObject <EditableBackground>

// model backed properties
@property (nonatomic, assign)                   int16_t            tag;
@property (nonatomic, copy)                     NSString         * key;
@property (nonatomic, copy)                     NSString         * identifier;
@property (nonatomic, copy)                     NSString         * displayName;
@property (nonatomic, strong)                   NSSet            * constraints;
@property (nonatomic, strong)                   NSSet            * firstItemConstraints;
@property (nonatomic, strong)                   NSSet            * secondItemConstraints;
@property (nonatomic, assign)                   CGFloat            backgroundImageAlpha;
@property (nonatomic, strong)                   UIColor          * backgroundColor;
@property (nonatomic, strong)                   GalleryImage     * backgroundImage;
@property (nonatomic, strong)                   RemoteController * controller;
@property (nonatomic, strong)                   RemoteElement    * parentElement;
@property (nonatomic, strong)                   NSOrderedSet     * subelements;

// derived properties
@property (nonatomic, assign) BOOL   needsUpdateConstraints;

+ (id)remoteElementInContext:(NSManagedObjectContext *)context withAttributes:(NSDictionary *)attributes;
+ (id)remoteElementOfType:(RemoteElementType)type context:(NSManagedObjectContext *)context;
- (RemoteElement *)objectForKeyedSubscript:(NSString *)key;

@end

@interface RemoteElement (ConstraintManager)

@property (nonatomic, strong, readonly) RemoteElementLayoutConfiguration     * layoutConfiguration;
@property (nonatomic, readonly, getter = isLayoutConfigurationValid)    BOOL   layoutConfigurationValid;

@property (nonatomic, strong, readonly)     NSHashTable * subelementConstraints;
@property (nonatomic, strong, readonly)     NSHashTable * dependentConstraints;
@property (nonatomic, strong, readonly)     NSHashTable * dependentChildConstraints;
@property (nonatomic, strong, readonly)     NSHashTable * dependentSiblingConstraints;

- (void)processConstraints;
- (void)setConstraintsFromString:(NSString *)constraints;
- (NSSet *)constraintsAffectingAxis:(UILayoutConstraintAxis)axis
                              order:(RELayoutConstraintOrder)order;
- (void)processConstraint:(RemoteElementLayoutConstraint *)constraint;
- (void)constraintDidUpdate:(RemoteElementLayoutConstraint *)constraint;
- (void)removeConstraintFromCache:(RemoteElementLayoutConstraint *)constraint;
- (void)freezeSize:(CGSize)size
     forSubelement:(RemoteElement *)subelement
         attribute:(NSLayoutAttribute)attribute;
- (NSArray *)replacementCandidatesForAddingAttribute:(NSLayoutAttribute)attribute
                                           additions:(NSArray **)additions;
- (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute;
- (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute order:(RELayoutConstraintOrder)order;

@end

@interface RemoteElement (FLagsAndOptions)

@property (nonatomic, assign)       RemoteElementAlignmentOptions   alignmentOptions;
@property (nonatomic, assign)       RemoteElementAlignmentOptions   topAlignmentOption;
@property (nonatomic, assign)       RemoteElementAlignmentOptions   bottomAlignmentOption;
@property (nonatomic, assign)       RemoteElementAlignmentOptions   leftAlignmentOption;
@property (nonatomic, assign)       RemoteElementAlignmentOptions   rightAlignmentOption;
@property (nonatomic, assign)       RemoteElementAlignmentOptions   baselineAlignmentOption;
@property (nonatomic, assign)       RemoteElementAlignmentOptions   centerXAlignmentOption;
@property (nonatomic, assign)       RemoteElementAlignmentOptions   centerYAlignmentOption;

@property (nonatomic, assign)       RemoteElementSizingOptions   sizingOptions;
@property (nonatomic, assign)       RemoteElementSizingOptions   widthSizingOption;
@property (nonatomic, assign)       RemoteElementSizingOptions   heightSizingOption;
@property (nonatomic, assign)       BOOL                         proportionLock;

@property (nonatomic, assign)       RemoteElementShape     shape;
@property (nonatomic, assign)       RemoteElementStyle     style;
@property (nonatomic, readonly)     RemoteElementType      type;
@property (nonatomic, readonly)     RemoteElementSubtype   subtype;
@property (nonatomic, assign)       RemoteElementOptions   options;
@property (nonatomic, readonly)     RemoteElementState     state;

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

@class   RemoteElementLayoutConstraint;

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

- (void)addConstraintsObject:(RemoteElementLayoutConstraint *)value;
- (void)removeConstraintsObject:(RemoteElementLayoutConstraint *)value;
- (void)addConstraints:(NSSet *)values;
- (void)removeConstraints:(NSSet *)values;

- (void)addFirstItemConstraintsObject:(RemoteElementLayoutConstraint *)value;
- (void)removeFirstItemConstraintsObject:(RemoteElementLayoutConstraint *)value;
- (void)addFirstItemConstraints:(NSSet *)values;
- (void)removeFirstItemConstraints:(NSSet *)values;

- (void)addSecondItemConstraintsObject:(RemoteElementLayoutConstraint *)value;
- (void)removeSecondItemConstraintsObject:(RemoteElementLayoutConstraint *)value;
- (void)addSecondItemConstraints:(NSSet *)values;
- (void)removeSecondItemConstraints:(NSSet *)values;

@end

@interface RemoteElement (Debugging)

- (NSString *)constraintsDescription;
- (NSString *)dumpElementHierarchy;
- (NSString *)flagsAndAppearanceDescription;
- (NSString *)sizingOptionsDescription;
- (NSString *)alignmentOptionsDescription;

@end

#define NSDictionaryOfVariableBindingsToIdentifiers(...) \
    _NSDictionaryOfVariableBindingsToIdentifiers(@"" # __VA_ARGS__, __VA_ARGS__, nil)

MSKIT_EXTERN NSDictionary * _NSDictionaryOfVariableBindingsToIdentifiers(NSString * commaSeparatedKeysString, id firstValue, ...);
