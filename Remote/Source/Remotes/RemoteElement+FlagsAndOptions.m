//
//RemoteElement+FlagsAndOptions.m
// iPhonto
//
// Created by Jason Cardwell on 2/9/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"

RemoteElementAlignmentOptions alignmentOptionForNSLayoutAttribute(NSLayoutAttribute attribute, RERelationshipType type) {
    switch (attribute) {
        case NSLayoutAttributeBaseline :

            return (type == REParentRelationship
                    ? RemoteElementAlignmentOptionBaselineParent
                    : (type == RESiblingRelationship
                       ? RemoteElementAlignmentOptionBaselineFocus
                       : RemoteElementAlignmentOptionBaselineUnspecified));

        case NSLayoutAttributeBottom :

            return (type == REParentRelationship
                    ? RemoteElementAlignmentOptionBottomParent
                    : (type == RESiblingRelationship
                       ? RemoteElementAlignmentOptionBottomFocus
                       : RemoteElementAlignmentOptionBottomUnspecified));

        case NSLayoutAttributeTop :

            return (type == REParentRelationship
                    ? RemoteElementAlignmentOptionTopParent
                    : (type == RESiblingRelationship
                       ? RemoteElementAlignmentOptionTopFocus
                       : RemoteElementAlignmentOptionTopUnspecified));

        case NSLayoutAttributeLeft :
        case NSLayoutAttributeLeading :

            return (type == REParentRelationship
                    ? RemoteElementAlignmentOptionLeftParent
                    : (type == RESiblingRelationship
                       ? RemoteElementAlignmentOptionLeftFocus
                       : RemoteElementAlignmentOptionLeftUnspecified));

        case NSLayoutAttributeRight :
        case NSLayoutAttributeTrailing :

            return (type == REParentRelationship
                    ? RemoteElementAlignmentOptionRightParent
                    : (type == RESiblingRelationship
                       ? RemoteElementAlignmentOptionRightFocus
                       : RemoteElementAlignmentOptionRightUnspecified));

        case NSLayoutAttributeCenterX :

            return (type == REParentRelationship
                    ? RemoteElementAlignmentOptionCenterXParent
                    : (type == RESiblingRelationship
                       ? RemoteElementAlignmentOptionCenterXFocus
                       : RemoteElementAlignmentOptionCenterXUnspecified));

        case NSLayoutAttributeCenterY :

            return (type == REParentRelationship
                    ? RemoteElementAlignmentOptionCenterYParent
                    : (type == RESiblingRelationship
                       ? RemoteElementAlignmentOptionCenterYFocus
                       : RemoteElementAlignmentOptionCenterYUnspecified));

        case NSLayoutAttributeWidth :
        case NSLayoutAttributeHeight :
        case NSLayoutAttributeNotAnAttribute :
            assert(NO);

            return RemoteElementAlignmentOptionUndefined;
    } /* switch */
}     /* alignmentOptionForNSLayoutAttribute */

RemoteElementSizingOptions sizingOptionForNSLayoutAttribute(NSLayoutAttribute attribute,RERelationshipType type) {
    switch (attribute) {
        case NSLayoutAttributeWidth :

            return (type == REParentRelationship
                    ? RemoteElementSizingOptionWidthParent
                    : (type == RESiblingRelationship
                       ? RemoteElementSizingOptionWidthFocus
                       : (type == REIntrinsicRelationship
                          ? RemoteElementSizingOptionWidthIntrinsic
                          : RemoteElementSizingOptionWidthUnspecified)));

        case NSLayoutAttributeHeight :

            return (type == REParentRelationship
                    ? RemoteElementSizingOptionHeightParent
                    : (type == RESiblingRelationship
                       ? RemoteElementSizingOptionHeightFocus
                       : (type == REIntrinsicRelationship
                          ? RemoteElementSizingOptionHeightIntrinsic
                          : RemoteElementSizingOptionHeightUnspecified)));

        case NSLayoutAttributeBaseline :
        case NSLayoutAttributeBottom :
        case NSLayoutAttributeTop :
        case NSLayoutAttributeLeft :
        case NSLayoutAttributeLeading :
        case NSLayoutAttributeRight :
        case NSLayoutAttributeTrailing :
        case NSLayoutAttributeCenterX :
        case NSLayoutAttributeCenterY :
        case NSLayoutAttributeNotAnAttribute :
            assert(NO);

            return RemoteElementSizingOptionUnspecified;
    }  /* switch */
}

@implementation RemoteElement (FlagsAndOptionsPrivate)
@dynamic type;
@dynamic subtype;
@dynamic state;

- (void)setType:(RemoteElementType)type {
    [self willChangeValueForKey:@"type"];
    [self setFlags:type mask:RemoteElementTypeMask];
    [self didChangeValueForKey:@"type"];
}

- (void)setSubtype:(RemoteElementSubtype)subtype {
    [self willChangeValueForKey:@"subtype"];
    [self setFlags:subtype mask:RemoteElementSubtypeMask];
    [self didChangeValueForKey:@"subtype"];
}

- (void)setState:(RemoteElementState)state {
    [self willChangeValueForKey:@"state"];
    [self setFlags:state mask:RemoteElementStateMask];
    [self didChangeValueForKey:@"state"];
}

- (void)setPrimitiveFlags:(uint64_t)primitiveFlags {
    _flags = primitiveFlags;
}

- (uint64_t)primitiveFlags {
    return _flags;
}

- (void)setPrimitiveAppearance:(uint64_t)primitiveAppearance {
    _appearance = primitiveAppearance;
}

- (uint64_t)primitiveAppearance {
    return _appearance;
}

@end

@implementation RemoteElement (FlagsAndOptions)
#pragma mark Properties stored inside `flags`

- (RemoteElementType)type {
    [self willAccessValueForKey:@"type"];

    uint64_t   t = [self flagsWithMask:RemoteElementTypeMask];

    [self didAccessValueForKey:@"type"];

    return t;
}

- (RemoteElementSubtype)subtype {
    [self willAccessValueForKey:@"subtype"];

    uint64_t   t = [self flagsWithMask:RemoteElementSubtypeMask];

    [self didAccessValueForKey:@"subtype"];

    return t;
}

- (RemoteElementOptions)options {
    [self willAccessValueForKey:@"options"];

    uint64_t   t = [self flagsWithMask:RemoteElementOptionsMask];

    [self didAccessValueForKey:@"options"];

    return t;
}

- (void)setOptions:(RemoteElementOptions)options {
    [self willChangeValueForKey:@"options"];
    [self setFlags:options mask:RemoteElementOptionsMask];
    [self didChangeValueForKey:@"options"];
}

- (RemoteElementState)state {
    [self willAccessValueForKey:@"state"];

    uint64_t   t = [self flagsWithMask:RemoteElementStateMask];

    [self didAccessValueForKey:@"state"];

    return t;
}

- (uint64_t)flagsWithMask:(uint64_t)mask {
    return (_flags & mask);
}

- (void)setFlags:(uint64_t)flags mask:(uint64_t)mask {
    _flags = (_flags & ~mask) | flags;
}

- (void)setFlagBits:(uint64_t)flagBits {
    _flags = (_flags & ~flagBits) | flagBits;
}

- (void)unsetFlagBits:(uint64_t)flagsBits {
    _flags &= ~flagsBits;
}

- (void)toggleFlagBits:(uint64_t)flagBits mask:(uint64_t)mask {
    _flags ^= (flagBits & mask);
}

- (BOOL)isFlagSetForBits:(uint64_t)bits {
    return (_flags & bits ? YES : NO);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Appearance Bit Vector
////////////////////////////////////////////////////////////////////////////////

- (uint64_t)appearanceWithMask:(uint64_t)mask {
    return (_appearance & mask);
}

- (void)setAppearance:(uint64_t)appearance mask:(uint64_t)mask {
    _appearance = (_appearance & ~mask) | appearance;
}

- (void)setAppearanceBits:(uint64_t)appearanceBits {
    _appearance = (_appearance & ~appearanceBits) | appearanceBits;
}

- (void)unsetAppearanceBits:(uint64_t)appearanceBits {
    _appearance &= ~appearanceBits;
}

- (void)toggleAppearanceBits:(uint64_t)appearanceBits mask:(uint64_t)mask {
    _appearance ^= (appearanceBits & mask);
}

- (BOOL)isAppearanceSetforBits:(uint64_t)bits {
    return (_appearance & bits ? YES : NO);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Alignment Options
////////////////////////////////////////////////////////////////////////////////

- (RemoteElementAlignmentOptions)alignmentOptions {
    [self willAccessValueForKey:@"alignmentOptions"];

    uint64_t   t = [self appearanceWithMask:RemoteElementAlignmentOptionsMask];

    [self didAccessValueForKey:@"alignmentOptions"];

    return t;
}

- (void)setAlignmentOptions:(RemoteElementAlignmentOptions)alignmentOptions {
    [self willChangeValueForKey:@"alignmentOptions"];
    [self setAppearance:alignmentOptions mask:RemoteElementAlignmentOptionsMask];
    [self didChangeValueForKey:@"alignmentOptions"];
}

- (RemoteElementAlignmentOptions)bottomAlignmentOption {
    return [self appearanceWithMask:RemoteElementAlignmentOptionBottomMask];
}

- (void)setBottomAlignmentOption:(RemoteElementAlignmentOptions)bottomOption {
    uint64_t   newAlignmentOptions = [self appearanceWithMask:~RemoteElementAlignmentOptionBottomMask];

    newAlignmentOptions  |= (bottomOption & RemoteElementAlignmentOptionBottomMask);
    self.alignmentOptions = newAlignmentOptions;
}

- (RemoteElementAlignmentOptions)topAlignmentOption {
    return [self appearanceWithMask:RemoteElementAlignmentOptionTopMask];
}

- (void)setTopAlignmentOption:(RemoteElementAlignmentOptions)topOption {
    uint64_t   newAlignmentOptions = [self appearanceWithMask:~RemoteElementAlignmentOptionTopMask];

    newAlignmentOptions  |= (topOption & RemoteElementAlignmentOptionTopMask);
    self.alignmentOptions = newAlignmentOptions;
}

- (RemoteElementAlignmentOptions)leftAlignmentOption {
    return [self appearanceWithMask:RemoteElementAlignmentOptionLeftMask];
}

- (void)setLeftAlignmentOption:(RemoteElementAlignmentOptions)leftOption {
    uint64_t   newAlignmentOptions = [self appearanceWithMask:~RemoteElementAlignmentOptionLeftMask];

    newAlignmentOptions  |= (leftOption & RemoteElementAlignmentOptionLeftMask);
    self.alignmentOptions = newAlignmentOptions;
}

- (RemoteElementAlignmentOptions)rightAlignmentOption {
    return [self appearanceWithMask:RemoteElementAlignmentOptionRightMask];
}

- (void)setRightAlignmentOption:(RemoteElementAlignmentOptions)rightOption {
    uint64_t   newAlignmentOptions = [self appearanceWithMask:~RemoteElementAlignmentOptionRightMask];

    newAlignmentOptions  |= (rightOption & RemoteElementAlignmentOptionRightMask);
    self.alignmentOptions = newAlignmentOptions;
}

- (RemoteElementAlignmentOptions)baselineAlignmentOption {
    return [self appearanceWithMask:RemoteElementAlignmentOptionBaselineMask];
}

- (void)setBaselineAlignmentOption:(RemoteElementAlignmentOptions)baselineOption {
    uint64_t   newAlignmentOptions = [self appearanceWithMask:~RemoteElementAlignmentOptionBaselineMask];

    newAlignmentOptions  |= (baselineOption & RemoteElementAlignmentOptionBaselineMask);
    self.alignmentOptions = newAlignmentOptions;
}

- (RemoteElementAlignmentOptions)centerXAlignmentOption {
    return [self appearanceWithMask:RemoteElementAlignmentOptionCenterXMask];
}

- (void)setCenterXAlignmentOption:(RemoteElementAlignmentOptions)centerXOption {
    uint64_t   newAlignmentOptions = [self appearanceWithMask:~RemoteElementAlignmentOptionCenterXMask];

    newAlignmentOptions  |= (centerXOption & RemoteElementAlignmentOptionCenterXMask);
    self.alignmentOptions = newAlignmentOptions;
}

- (RemoteElementAlignmentOptions)centerYAlignmentOption {
    return [self appearanceWithMask:RemoteElementAlignmentOptionCenterYMask];
}

- (void)setCenterYAlignmentOption:(RemoteElementAlignmentOptions)centerYOption {
    uint64_t   newAlignmentOptions = [self appearanceWithMask:~RemoteElementAlignmentOptionCenterYMask];

    newAlignmentOptions  |= (centerYOption & RemoteElementAlignmentOptionCenterYMask);
    self.alignmentOptions = newAlignmentOptions;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Sizing Options
////////////////////////////////////////////////////////////////////////////////

- (RemoteElementSizingOptions)sizingOptions {
    [self willAccessValueForKey:@"sizingOptions"];

    uint64_t   t = [self appearanceWithMask:RemoteElementSizingOptionsMask];

    [self didAccessValueForKey:@"sizingOptions"];

    return t;
}

- (void)setSizingOptions:(RemoteElementSizingOptions)sizingOptions {
    [self willChangeValueForKey:@"sizingOptions"];
    [self setAppearance:sizingOptions mask:RemoteElementSizingOptionsMask];
    [self didChangeValueForKey:@"sizingOptions"];
}

- (RemoteElementSizingOptions)widthSizingOption {
    return [self appearanceWithMask:RemoteElementSizingOptionWidthMask];
}

- (void)setWidthSizingOption:(RemoteElementSizingOptions)widthOption {
    uint64_t   newSizingOptions = [self appearanceWithMask:~RemoteElementSizingOptionWidthMask];

    newSizingOptions  |= (widthOption & RemoteElementSizingOptionWidthMask);
    self.sizingOptions = newSizingOptions;
}

- (RemoteElementSizingOptions)heightSizingOption {
    return [self appearanceWithMask:RemoteElementSizingOptionHeightMask];
}

- (void)setHeightSizingOption:(RemoteElementSizingOptions)heightOption {
    uint64_t   newSizingOptions = [self appearanceWithMask:~RemoteElementSizingOptionHeightMask];

    newSizingOptions  |= (heightOption & RemoteElementSizingOptionHeightMask);
    self.sizingOptions = newSizingOptions;
}

- (BOOL)proportionLock {
    return ((_appearance & RemoteElementSizingOptionsProportionLock) ? YES : NO);
}

- (void)setProportionLock:(BOOL)proportionLock {
    if (proportionLock) [self setAppearanceBits:RemoteElementSizingOptionsProportionLock];
    else [self unsetAppearanceBits:RemoteElementSizingOptionsProportionLock];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Shape Options
////////////////////////////////////////////////////////////////////////////////

- (RemoteElementShape)shape {
    [self willAccessValueForKey:@"shape"];

    uint64_t   t = [self appearanceWithMask:RemoteElementShapeMask];

    [self didAccessValueForKey:@"shape"];

    return t;
}

- (void)setShape:(RemoteElementShape)shape {
    [self willChangeValueForKey:@"shape"];
    [self setAppearance:shape mask:RemoteElementShapeMask];
    [self didChangeValueForKey:@"shape"];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Style Options
////////////////////////////////////////////////////////////////////////////////

- (RemoteElementStyle)style {
    [self willAccessValueForKey:@"style"];

    uint64_t   t = [self appearanceWithMask:RemoteElementStyleMask];

    [self didAccessValueForKey:@"style"];

    return t;
}

- (void)setStyle:(RemoteElementStyle)style {
    [self willChangeValueForKey:@"style"];
    [self setAppearance:style mask:RemoteElementStyleMask];
    [self didChangeValueForKey:@"style"];
}

@end
