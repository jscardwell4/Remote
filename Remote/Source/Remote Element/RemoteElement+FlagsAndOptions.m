//
//RemoteElement+FlagsAndOptions.m
// Remote
//
// Created by Jason Cardwell on 2/9/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"

@implementation RemoteElement (FlagsAndOptionsPrivate)

@dynamic type;
@dynamic subtype;
@dynamic state;

- (void)setType:(REType)type {
    [self willChangeValueForKey:@"type"];
    [self setFlags:type mask:RETypeMask];
    [self didChangeValueForKey:@"type"];
}

- (void)setSubtype:(RESubtype)subtype {
    [self willChangeValueForKey:@"subtype"];
    [self setFlags:subtype mask:RESubtypeMask];
    [self didChangeValueForKey:@"subtype"];
}

- (void)setState:(REState)state {
    [self willChangeValueForKey:@"state"];
    [self setFlags:state mask:REStateMask];
    [self didChangeValueForKey:@"state"];
}

- (void)setPrimitiveAppearance:(uint64_t)primitiveAppearance
{
    [self willChangeValueForKey:@"appearance"];
    _primitiveAppearance = primitiveAppearance;
    [self didChangeValueForKey:@"appearance"];
}

- (uint64_t)primitiveAppearance
{
    [self willAccessValueForKey:@"appearance"];
    uint64_t primitiveAppearance = _primitiveAppearance;
    [self didAccessValueForKey:@"appearance"];
    return primitiveAppearance;
}

- (void)setPrimitiveFlags:(uint64_t)primitiveFlags
{
    [self willChangeValueForKey:@"flags"];
    _primitiveFlags = primitiveFlags;
    [self didChangeValueForKey:@"flags"];
}

- (uint64_t)primitiveFlags
{
    [self willAccessValueForKey:@"flags"];
    uint64_t primitiveFlags = _primitiveFlags;
    [self didAccessValueForKey:@"flags"];
    return primitiveFlags;
}

- (uint64_t)flagsWithMask:(uint64_t)mask {
    return (_primitiveFlags & mask);
}

- (void)setFlags:(uint64_t)flags mask:(uint64_t)mask {
    _primitiveFlags = (_primitiveFlags & ~mask) | flags;
}

- (void)setFlagBits:(uint64_t)flagBits {
    _primitiveFlags = (_primitiveFlags & ~flagBits) | flagBits;
}

- (void)unsetFlagBits:(uint64_t)flagsBits {
    _primitiveFlags &= ~flagsBits;
}

- (void)toggleFlagBits:(uint64_t)flagBits mask:(uint64_t)mask {
    _primitiveFlags ^= (flagBits & mask);
}

- (BOOL)isFlagSetForBits:(uint64_t)bits {
    return (_primitiveFlags & bits ? YES : NO);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Appearance Bit Vector
////////////////////////////////////////////////////////////////////////////////

- (void)setAppearance:(uint64_t)appearance mask:(uint64_t)mask {
    _primitiveAppearance = (_primitiveAppearance & ~mask) | appearance;
}

- (uint64_t)appearanceWithMask:(uint64_t)mask {
    return (_primitiveAppearance & mask);
}

- (void)setAppearanceBits:(uint64_t)appearanceBits {
    _primitiveAppearance = (_primitiveAppearance & ~appearanceBits) | appearanceBits;
}

- (void)unsetAppearanceBits:(uint64_t)appearanceBits {
    _primitiveAppearance &= ~appearanceBits;
}

- (void)toggleAppearanceBits:(uint64_t)appearanceBits mask:(uint64_t)mask {
    _primitiveAppearance ^= (appearanceBits & mask);
}

- (BOOL)isAppearanceSetForBits:(uint64_t)bits {
    return (_primitiveAppearance & bits ? YES : NO);
}

@end

@implementation RemoteElement (FlagsAndOptions)
#pragma mark Properties stored inside `flags`

- (REType)type {
    [self willAccessValueForKey:@"type"];
    uint64_t   t = [self flagsWithMask:RETypeMask];
    [self didAccessValueForKey:@"type"];
    return t;
}

- (REType)baseType { return (self.type & RETypeBaseMask); }

- (RESubtype)subtype {
    [self willAccessValueForKey:@"subtype"];
    uint64_t   t = [self flagsWithMask:RESubtypeMask];
    [self didAccessValueForKey:@"subtype"];
    return t;
}

- (REOptions)options {
    [self willAccessValueForKey:@"options"];
    uint64_t   t = [self flagsWithMask:REOptionsMask];
    [self didAccessValueForKey:@"options"];
    return t;
}

- (void)setOptions:(REOptions)options {
    [self willChangeValueForKey:@"options"];
    [self setFlags:options mask:REOptionsMask];
    [self didChangeValueForKey:@"options"];
}

- (REState)state {
    [self willAccessValueForKey:@"state"];
    uint64_t   t = [self flagsWithMask:REStateMask];
    [self didAccessValueForKey:@"state"];
    return t;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Shape, Style, and Theme Options
////////////////////////////////////////////////////////////////////////////////

- (REShape)shape {
    [self willAccessValueForKey:@"shape"];
    uint64_t t = [self appearanceWithMask:REShapeMask];
    [self didAccessValueForKey:@"shape"];
    return t;
}

- (void)setShape:(REShape)shape {
    [self willChangeValueForKey:@"shape"];
    [self setAppearance:shape mask:REShapeMask];
    [self didChangeValueForKey:@"shape"];
}

- (REStyle)style {
    [self willAccessValueForKey:@"style"];
    uint64_t t = [self appearanceWithMask:REStyleMask];
    [self didAccessValueForKey:@"style"];
    return t;
}

- (void)setStyle:(REStyle)style {
    [self willChangeValueForKey:@"style"];
    [self setAppearance:style mask:REStyleMask];
    [self didChangeValueForKey:@"style"];
}

/*
- (RETheme)theme {
    [self willAccessValueForKey:@"theme"];
    uint64_t t = [self appearanceWithMask:REThemeMask];
    [self didAccessValueForKey:@"theme"];
    return t;
}

- (void)setTheme:(RETheme)theme {
    [self willChangeValueForKey:@"theme"];
    [self setAppearance:theme mask:REThemeMask];
    [self didChangeValueForKey:@"theme"];
}
*/

@end
