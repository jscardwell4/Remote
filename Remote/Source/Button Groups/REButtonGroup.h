//
// ButtonGroup.h
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement.h"

typedef NS_ENUM (uint64_t, REButtonGroupType) {
    REButtonGroupTypeDefault           = RETypeButtonGroup,
    REButtonGroupTypeToolbar           = 0xA,
    REButtonGroupTypeTransport         = 0x12,
    REButtonGroupTypeDPad              = 0x1A,
    REButtonGroupTypeSelectionPanel    = 0x22,
    REButtonGroupTypeCommandSetManager = 0x2A,
    REButtonGroupTypeRoundedPanel      = 0x3A,
    REButtonGroupTypePickerLabel       = 0x42,
    REButtonGroupTypeReserved          = 0xFF80,
    REButtonGroupTypeMask              = RETypeMask
};
typedef NS_ENUM (uint64_t, REButtonGroupSubtype) {
    REButtonGroupPanelLocationUndefined = RETypeUndefined,
    REButtonGroupPanelLocationTop       = 0x10000,
    REButtonGroupPanelLocationBottom    = 0x20000,
    REButtonGroupPanelLocationLeft      = 0x30000,
    REButtonGroupPanelLocationRight     = 0x40000,
    REButtonGroupSubtypeReserved        = 0xFFF80000,
    REButtonGroupPanelLocationMask      = 0x70000,
    REButtonGroupSubtypeMask            = RESubtypeMask
};
typedef NS_OPTIONS (uint64_t, REButtonGroupOptions) {
    REButtonGroupOptionsDefault = REOptionsUndefined,
    REButtonGroupOptionAutohide = 0x100000000,
    REButtonGroupOptionReserved = 0xFFFE00000000,
    REButtonGroupOptionsMask    = REOptionsMask
};
typedef NS_OPTIONS (uint64_t, REButtonGroupShape) {
    REButtonGroupShapeDefault  = REShapeUndefined,
    REButtonGroupShapeRocker   = REShapeRoundedRectangle,
    REButtonGroupShapeDPad     = REShapeOval,
    REButtonGroupShapeReserved = 0xFFFFFC000000,
    REButtonGroupShapeMask     = REShapeMask
};
typedef NS_OPTIONS (uint64_t, REButtonGroupStyle) {
    REButtonGroupStyleNoStyle     = REStyleUndefined,
    REButtonGroupStyleApplyGloss  = REStyleApplyGloss,
    REButtonGroupStyleDrawBorder  = REStyleDrawBorder,
    REButtonGroupStyleStretchable = REStyleStretchable,
    REButtonGroupStyleReserved    = REStyleReserved,
    REButtonGroupStyleMask        = REStyleMask
};

typedef NS_ENUM (NSUInteger, REButtonGroupStyleDefault) {
    REButtonGroupStyleDefaultNone = 0,
    REButtonGroupStyleDefault1    = 1,
    REButtonGroupStyleDefault2    = 2,
    REButtonGroupStyleDefault3    = 3,
    REButtonGroupStyleDefault4    = 4,
    REButtonGroupStyleDefault5    = 5
};
typedef NS_ENUM (uint64_t, REButtonGroupPiece) {
    REButtonGroupPieceDefault      = 0,
    REButtonGroupPieceRockerTop    = 1,
    REButtonGroupPieceRockerBottom = 2,
    REButtonGroupPieceDPadUp       = 3,
    REButtonGroupPieceDPadDown     = 4,
    REButtonGroupPieceDPadLeft     = 5,
    REButtonGroupPieceDPadRight    = 6,
    REButtonGroupPieceDPadCenter   = 7
};

MSKIT_STATIC_INLINE NSString *NSStringFromPanelLocation(REButtonGroupSubtype location)
{
    switch (location)
    {
        case REButtonGroupPanelLocationUndefined:
            return @"REButtonGroupPanelLocationUndefined";

        case REButtonGroupPanelLocationTop:
            return @"REButtonGroupPanelLocationTop";

        case REButtonGroupPanelLocationBottom:
            return @"REButtonGroupPanelLocationBottom";

        case REButtonGroupPanelLocationLeft:
            return @"REButtonGroupPanelLocationLeft";

        case REButtonGroupPanelLocationRight:
            return @"REButtonGroupPanelLocationRight";

        default:
            return nil;
    }
}

@class ButtonGroupConfigurationDelegate, CommandSet, REButton;

/**
 * `ButtonGroup` is an `NSManagedObject` subclass that models a group of buttons for a home
 * theater remote control. Its main function is to manage a collection of <Button> objects and to
 * interact with the <Remote> object to which it typically will belong. <ButtonGroupView> objects
 * use an instance of the `ButtonGroup` class to govern their style, behavior, etc.
 */
@interface REButtonGroup : RemoteElement

/**
 * Retrieve a Button object contained by the `ButtonGroup` by its key.
 * @param key The key for the Button object.
 * @return The Button specifed or nil if it does not exist.
 */
- (REButton *)objectForKeyedSubscript:(NSString *)subscript;

/**
 * Label text for the optional `UILabelView`.
 */
@property (nonatomic, copy) NSAttributedString * label;

/**
 * String used to generate auto layout  constraint for the label.
 */
@property (nonatomic, copy) NSString * labelConstraints;

/**
 * REButtonGroupPanelLocation referring to which side the `ButtonGroup` appears when attached to a
 * Remote as a panel.
 */
@property (nonatomic, assign) REButtonGroupSubtype   panelLocation;

/**
 * The configuration delegate handles dynamically swapping CommandSet objects from which
 * the Button contained by the `ButtonGroup` are assigned a Command object.
 */
@property (nonatomic, strong) ButtonGroupConfigurationDelegate * configurationDelegate;

/**
 * CommandSet object containing the commands currently in use for the button group's Button
 * objects.
 */
@property (nonatomic, strong) CommandSet * commandSet;

@end

/**
 * The PickerLabelButtonGroup is a `ButtonGroup` subclass that manages multiple CommandSet objects,
 * allowing for the buttons of the `ButtonGroup` to provide a different set of commands per user
 * selection. The command sets are represented by a label title. The titles are displayed on a
 * scroll view, which the user swipes left or right to load the next/previous command set.
 */
@interface REPickerLabelButtonGroup : REButtonGroup

#pragma mark - Managing the CommandSets
/// @name ￼Managing the CommandSets

/**
 * Add a new `CommandSet` for the specified label text.
 * @param label The display name for selecting the `CommandSet`.
 * @param commandSet The `CommandSet` object to add the `PickerLabelButtonGroup`'s collection.
 */
- (void)addLabel:(NSAttributedString *)label withCommandSet:(CommandSet *)commandSet;

/**
 * The labels for available CommandSets
 */
@property (nonatomic, strong) NSOrderedSet * commandSetLabels;

/**
 * The `CommandSet` objects available for use. Each `CommandSet` of the array has a matching label
 * string with the same index in the `labels` array.
 */
@property (nonatomic, strong) NSOrderedSet * commandSets;

@end
