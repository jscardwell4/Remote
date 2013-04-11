//
//  RETypedefs.h
//  Remote
//
//  Created by Jason Cardwell on 3/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Appearance
////////////////////////////////////////////////////////////////////////////////

/**
 *
 * Bit vector assignments for `appearance`
 *
 *		   0xFF 0xFF   0xFF 0xFF    0xFF   0xFF 0xFF 0xFF
 * 		└──────┴───────┴───┴──────────┘
 *     				  ⬇           ⬇        ⬇           ⬇
 *			style       reserved   theme        shape
 *
 */
typedef NS_ENUM (uint64_t, REShape)
{
    REShapeUndefined        = 0x0000000000000000,
    REShapeRoundedRectangle = 0x0000000000000001,
    REShapeOval             = 0x0000000000000002,
    REShapeRectangle        = 0x0000000000000003,
    REShapeTriangle         = 0x0000000000000004,
    REShapeDiamond          = 0x0000000000000005,
    REShapeReserved         = 0x0000000000FFFFF8,
    REShapeMask             = 0x0000000000FFFFFF
};

typedef NS_ENUM(NSUInteger, REThemeType)
{
    REThemeUnspecified      = 0x0000000000000000,
    REThemeNightshade       = 0x0000000001000000,
    REThemePowerBlue        = 0x0000000002000000,
    REThemeMask             = 0x00000000FF000000
};


typedef NS_OPTIONS (uint64_t, REStyle)
{
    REStyleUndefined        = 0x0000000000000000,
    REStyleApplyGloss       = 0x0001000000000000,
    REStyleDrawBorder       = 0x0002000000000000,
    REStyleStretchable      = 0x0004000000000000,
    
    REStyleGlossStyle1      = 0x0000000000000000, // 50-50 split
    REStyleGlossStyle2      = 0x0008000000000000, // Top ⅓
    REStyleGlossStyle3      = 0x0010000000000000, // Unused
    REStyleGlossStyle4      = 0x0018000000000000, // Unused
    REStyleGlossStyleMask   = 0x0018000000000000,
    
    REStyleReserved         = 0xFFE0000000000000,
    REStyleMask             = 0xFFFF000000000000
};

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Flags
////////////////////////////////////////////////////////////////////////////////

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
    RETypeUndefined   = 0x0000000000000000,
    RETypeRemote      = 0x0000000000000001,
    RETypeButtonGroup = 0x0000000000000002,
    RETypeButton      = 0x0000000000000003,
    RETypeBaseMask    = 0x0000000000000003,
    RETypeReserved    = 0x000000000000FFF0,
    RETypeMask        = 0x000000000000FFFF
};

typedef NS_ENUM (uint64_t, REButtonGroupType) {
    REButtonGroupTypeDefault           = RETypeButtonGroup,
    REButtonGroupTypeToolbar           = 0x000000000000000A,
    REButtonGroupTypeTransport         = 0x0000000000000012,
    REButtonGroupTypeDPad              = 0x000000000000001A,
    REButtonGroupTypeSelectionPanel    = 0x0000000000000022,
    REButtonGroupTypeCommandSetManager = 0x000000000000002A,
    REButtonGroupTypeRoundedPanel      = 0x000000000000003A,
    REButtonGroupTypePickerLabel       = 0x0000000000000042,
    REButtonGroupTypeReserved          = 0x000000000000FF80,
    REButtonGroupTypeMask              = RETypeMask
};

typedef NS_ENUM (uint64_t, REButtonType) {
    REButtonTypeDefault          = RETypeButton,
    REButtonTypeNumberPad        = 0x000000000000000F,
    REButtonTypeConnectionStatus = 0x0000000000000017,
    REButtonTypeBatteryStatus    = 0x000000000000001F,
    REButtonTypeCommandManager   = 0x0000000000000027,
    REButtonTypeReserved         = 0x000000000000FFC0,
    REButtonTypeMask             = RETypeMask
};

typedef NS_ENUM (uint64_t, RESubtype) {
    RESubtypeUndefined  = 0x0000000000000000,
    RESubtypeReserved   = 0x00000000FFFF0000,
    RESubtypeMask       = 0x00000000FFFF0000
};

typedef NS_ENUM (uint64_t, REButtonGroupSubtype) {
    REButtonGroupSubtypeUndefined       = RETypeUndefined,
    REButtonGroupTopPanel               = 0x0000000000010000,
    REButtonGroupBottomPanel            = 0x0000000000020000,
    REButtonGroupLeftPanel              = 0x0000000000030000,
    REButtonGroupRightPanel             = 0x0000000000040000,
    REButtonGroupSubtypeReserved        = 0x00000000FFF80000,
    REButtonGroupPanelLocationMask      = 0x0000000000070000,
    REButtonGroupSubtypeMask            = RESubtypeMask
};

typedef NS_ENUM (uint64_t, REButtonSubtype) {
    REButtonSubtypeUnspecified      = RESubtypeUndefined,
    REButtonSubtypeActivityOn       = 0x0000000000010000,
    REButtonSubtypeReserved         = 0x0000000000FC0000,
    REButtonSubtypeButtonGroupPiece = 0x00000000FF000000,
    REButtonSubtypeMask             = RESubtypeMask
};

typedef NS_ENUM (uint64_t, REOptions) {
    REOptionsUndefined = 0x0000000000000000,
    REOptionsReserved  = 0x0000FFFF00000000,
    REOptionsMask      = 0x0000FFFF00000000
};

typedef NS_OPTIONS (uint64_t, RERemoteOptions) {
    RERemoteOptionsDefault           = REOptionsUndefined,
    RERemoteOptionTopBarHiddenOnLoad = 0x0000000100000000,
    RERemoteOptionReserved           = 0x0000FFFE00000000,
    RERemoteOptionsMask              = REOptionsMask
};

typedef NS_OPTIONS (uint64_t, REButtonGroupOptions) {
    REButtonGroupOptionsDefault = REOptionsUndefined,
    REButtonGroupOptionAutohide = 0x0000000100000000,
    REButtonGroupOptionReserved = 0x0000FFFE00000000,
    REButtonGroupOptionsMask    = REOptionsMask
};

typedef NS_OPTIONS (uint64_t, REState) {
    REStateDefault  = 0x0000000000000000,
    REStateReserved = 0xFFFF000000000000,
    REStateMask     = 0xFFFF000000000000
};

typedef NS_OPTIONS (uint64_t, REButtonState) {
    REButtonStateNormal      = REStateDefault,
    REButtonStateDisabled    = 0x0001000000000000,
    REButtonStateSelected    = 0x0002000000000000,
    REButtonStateHighlighted = 0x0004000000000000,
    REButtonStateReserved    = 0xFFF8000000000000,
    REButtonStateMask        = REStateMask
};

typedef NS_ENUM(NSUInteger, REButtonGroupPanelLocation) {
    REPanelLocationNotAPanel = 0x0,
    REPanelLocationTop       = REButtonGroupTopPanel    >> 0x10,
    REPanelLocationBottom    = REButtonGroupBottomPanel >> 0x10,
    REPanelLocationLeft      = REButtonGroupLeftPanel   >> 0x10,
    REPanelLocationRight     = REButtonGroupRightPanel  >> 0x10
};

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Style Presets
////////////////////////////////////////////////////////////////////////////////

/*
typedef NS_ENUM (NSUInteger, REButtonGroupStyleDefault) {
    REButtonGroupStyleDefaultNone = 0,
    REButtonGroupStyleDefault1    = 1,
    REButtonGroupStyleDefault2    = 2,
    REButtonGroupStyleDefault3    = 3,
    REButtonGroupStyleDefault4    = 4,
    REButtonGroupStyleDefault5    = 5
};
*/

/*
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
*/


/*
typedef NS_ENUM (NSInteger, REButtonStyleDefault) {
    REButtonStyleDefault1 = 0,
    REButtonStyleDefault2 = 1,
    REButtonStyleDefault3 = 2,
    REButtonStyleDefault4 = 3,
    REButtonStyleDefault5 = 4
};
*/

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////

typedef NS_OPTIONS (NSUInteger, RECommandOptions) {
    RECommandOptionsDefault               = 0 << 0,
    RECommandOptionsLongPress             = 1 << 0,
    RECommandOptionsNotifyComponentDevice = 1 << 1
};

typedef NS_ENUM (int16_t, RESystemCommandType) {
    RESystemCommandToggleProximitySensor = 0,
    RESystemCommandURLRequest            = 1,
    RESystemCommandReturnToLaunchScreen  = 2,
    RESystemCommandOpenSettings          = 3,
    RESystemCommandOpenEditor            = 4
};

typedef NS_ENUM(NSUInteger, RECommandSetType) {
    RECommandSetTypeUnspecified = 0,
    RECommandSetTypeDPad		= 1,
    RECommandSetTypeTransport	= 2,
    RECommandSetTypeNumberPad	= 3,
    RECommandSetTypeRocker		= 4
};

typedef void (^ RECommandCompletionHandler)(BOOL finished, BOOL success);

typedef void (^ REActionHandler)(void);

typedef NS_ENUM (NSUInteger, REAction) {
    RESingleTapAction = 0,
    RELongPressAction = 1
};

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Editing
////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM (uint64_t, REEditingMode) {
    REEditingModeNotEditing  = RETypeUndefined,
    RERemoteEditingMode      = RETypeRemote,
    REButtonGroupEditingMode = RETypeButtonGroup,
    REButtonEditingMode      = RETypeButton
};

typedef NS_OPTIONS (NSUInteger, REEditingState) {
    REEditingStateNotEditing   = 0 << 0,
    REEditingStateSelected     = 1 << 0,
    REEditingStateFocus        = 1 << 1,
    REEditingStateMoving       = 1 << 2
};

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constraints
////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM (uint8_t, RERelationshipType){
    REUnspecifiedRelation   = 0,
    REParentRelationship    = 1,
    REChildRelationship     = 2,
    RESiblingRelationship   = 3,
    REIntrinsicRelationship = 4
};

typedef NS_ENUM (uint8_t, RELayoutAxisDimension){
    RELayoutXAxis           = 0,
    RELayoutYAxis           = 1,
    RELayoutWidthDimension  = 2,
    RELayoutHeightDimension = 3
};

typedef NS_ENUM (uint8_t, RELayoutAttribute){
    RELayoutAttributeHeight  = 1 << 0,
    RELayoutAttributeWidth   = 1 << 1,
    RELayoutAttributeCenterY = 1 << 2,
    RELayoutAttributeCenterX = 1 << 3,
    RELayoutAttributeBottom  = 1 << 4,
    RELayoutAttributeTop     = 1 << 5,
    RELayoutAttributeRight   = 1 << 6,
    RELayoutAttributeLeft    = 1 << 7
};

typedef NS_ENUM (NSUInteger, RELayoutConstraintOrder){
    RELayoutConstraintUnspecifiedOrder = 0,
    RELayoutConstraintFirstOrder       = 1,
    RELayoutConstraintSecondOrder      = 2
};

typedef NS_OPTIONS (NSUInteger, RELayoutConstraintAffiliation){
    RELayoutConstraintUnspecifiedAffiliation    = 0,
    RELayoutConstraintFirstItemAffiliation      = 1 << 0,
    RELayoutConstraintSecondItemAffiliation     = 1 << 1,
    RELayoutConstraintOwnerAffiliation          = 1 << 2
};

typedef NS_ENUM(uint8_t, RELayoutConfigurationDependencyType) {
    RELayoutConfigurationUnspecifiedDependency = REUnspecifiedRelation,
    RELayoutConfigurationParentDependency 	   = REChildRelationship,
    RELayoutConfigurationSiblingDependency 	   = RESiblingRelationship,
    RELayoutConfigurationIntrinsicDependency   = REIntrinsicRelationship
};

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Control State Sets
////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM (NSInteger, ControlStateColorSetDefault) {
    ControlStateColorSetEmpty              = 0,
    ControlStateColorSetTitleDefault       = 1,
    ControlStateColorSetBackgroundDefault  = 2,
    ControlStateColorSetTitleShadowDefault = 3
};

typedef NS_ENUM (NSInteger, ControlStateColorType) {
    ControlStateUndefinedType       = 0,
    ControlStateTitleColorSet       = 1,
    ControlStateTitleShadowColorSet = 2,
    ControlStateBackgroundColorSet  = 3
};

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configuration
////////////////////////////////////////////////////////////////////////////////

typedef NSString * RERemoteConfiguration;


