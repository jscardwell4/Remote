//
// ButtonGroup.h
// iPhonto
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark Flags and Appearance Enumerations

////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM (uint64_t, ButtonGroupType) {
    ButtonGroupTypeDefault           = RemoteElementButtonGroupType,
    ButtonGroupTypeToolbar           = 0xA,
    ButtonGroupTypeTransport         = 0x12,
    ButtonGroupTypeDPad              = 0x1A,
    ButtonGroupTypeSelectionPanel    = 0x22,
    ButtonGroupTypeCommandSetManager = 0x2A,
    ButtonGroupTypeRoundedPanel      = 0x3A,
    ButtonGroupTypePickerLabel       = 0x42,
    ButtonGroupTypeReserved          = 0xFF80,
    ButtonGroupTypeMask              = RemoteElementTypeMask
};
typedef NS_ENUM (uint64_t, ButtonGroupSubtype) {
    ButtonGroupPanelLocationUndefined = RemoteElementUnspecifiedType,
    ButtonGroupPanelLocationTop       = 0x10000,
    ButtonGroupPanelLocationBottom    = 0x20000,
    ButtonGroupPanelLocationLeft      = 0x30000,
    ButtonGroupPanelLocationRight     = 0x40000,
    ButtonGroupSubtypeReserved        = 0xFFF80000,
    ButtonGroupPanelLocationMask      = 0x70000,
    ButtonGroupSubtypeMask            = RemoteElementSubtypeMask
};
typedef NS_OPTIONS (uint64_t, ButtonGroupOptions) {
    ButtonGroupOptionsDefault = RemoteElementNoOptions,
    ButtonGroupOptionAutohide = 0x100000000,
    ButtonGroupOptionReserved = 0xFFFE00000000,
    ButtonGroupOptionsMask    = RemoteElementOptionsMask
};
typedef NS_OPTIONS (uint64_t, ButtonGroupShape) {
    ButtonGroupShapeDefault  = RemoteElementShapeUndefined,
    ButtonGroupShapeRocker   = RemoteElementShapeRoundedRectangle,
    ButtonGroupShapeDPad     = RemoteElementShapeOval,
    ButtonGroupShapeReserved = 0xFFFFFC000000,
    ButtonGroupShapeMask     = RemoteElementShapeMask
};
typedef NS_OPTIONS (uint64_t, ButtonGroupStyle) {
    ButtonGroupStyleNoStyle     = RemoteElementNoStyle,
    ButtonGroupStyleApplyGloss  = RemoteElementStyleApplyGloss,
    ButtonGroupStyleDrawBorder  = RemoteElementStyleDrawBorder,
    ButtonGroupStyleStretchable = RemoteElementStyleStretchable,
    ButtonGroupStyleReserved    = RemoteElementStyleReserved,
    ButtonGroupStyleMask        = RemoteElementStyleMask
};

////////////////////////////////////////////////////////////////////////////////
#pragma mark Other Enumerations

typedef NS_ENUM (NSUInteger, ButtonGroupStyleDefault) {
    ButtonGroupStyleDefaultNone = 0,
    ButtonGroupStyleDefault1    = 1,
    ButtonGroupStyleDefault2    = 2,
    ButtonGroupStyleDefault3    = 3,
    ButtonGroupStyleDefault4    = 4,
    ButtonGroupStyleDefault5    = 5
};
typedef NS_ENUM (uint64_t, ButtonGroupPiece) {
    ButtonGroupPieceDefault      = 0,
    ButtonGroupPieceRockerTop    = 1,
    ButtonGroupPieceRockerBottom = 2,
    ButtonGroupPieceDPadUp       = 3,
    ButtonGroupPieceDPadDown     = 4,
    ButtonGroupPieceDPadLeft     = 5,
    ButtonGroupPieceDPadRight    = 6,
    ButtonGroupPieceDPadCenter   = 7
};

MSKIT_STATIC_INLINE NSString * NSStringFromPanelLocation(ButtonGroupSubtype location) {
    switch (location) {
        case ButtonGroupPanelLocationUndefined :

            return @"ButtonGroupPanelLocationUndefined";

        case ButtonGroupPanelLocationTop :

            return @"ButtonGroupPanelLocationTop";

        case ButtonGroupPanelLocationBottom :

            return @"ButtonGroupPanelLocationBottom";

        case ButtonGroupPanelLocationLeft :

            return @"ButtonGroupPanelLocationLeft";

        case ButtonGroupPanelLocationRight :

            return @"ButtonGroupPanelLocationRight";

        default :

            return nil;
    }
}

@class   GalleryBackgroundImage, ButtonGroupConfigurationDelegate, PickerLabelButtonGroup, CommandSet, Remote, Button;

/**
 * `ButtonGroup` is an `NSManagedObject` subclass that models a group of buttons for a home
 * theater remote control. Its main function is to manage a collection of <Button> objects and to
 * interact with the <Remote> object to which it typically will belong. <ButtonGroupView> objects
 * use an instance of the `ButtonGroup` class to govern their style, behavior, etc.
 */
@interface ButtonGroup : RemoteElement

/**
 * Retrieve a Button object contained by the `ButtonGroup` by its key.
 * @param key The key for the Button object.
 * @return The Button specifed or nil if it does not exist.
 */
- (Button *)buttonWithKey:(NSString *)key;

- (Button *)objectForKeyedSubscript:(NSString *)subscript;

/**
 * Label text for the optional `UILabelView`.
 */
@property (nonatomic, copy) NSAttributedString * label;

/**
 * String used to generate auto layout  constraint for the label.
 */
@property (nonatomic, copy) NSString * labelConstraints;

/**
 * ButtonGroupPanelLocation referring to which side the `ButtonGroup` appears when attached to a
 * Remote as a panel.
 */
@property (nonatomic, assign) ButtonGroupSubtype   panelLocation;

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
@interface PickerLabelButtonGroup : ButtonGroup

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
