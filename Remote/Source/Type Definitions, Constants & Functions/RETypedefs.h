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

typedef enum REShape : int16_t REShape; enum REShape : int16_t
{
    REShapeUndefined        = 0,
    REShapeRoundedRectangle = 1,
    REShapeOval             = 2,
    REShapeRectangle        = 3,
    REShapeTriangle         = 4,
    REShapeDiamond          = 5
};

static inline NSString *NSStringFromREShape(REShape shape)
{
    static dispatch_once_t onceToken;
    static NSDictionary const * index;
    dispatch_once(&onceToken, ^{
        index = @{ @(REShapeRoundedRectangle) : @"REShapeRoundedRectangle",
                   @(REShapeOval)             : @"REShapeOval",
                   @(REShapeRectangle)        : @"REShapeRectangle",
                   @(REShapeTriangle)         : @"REShapeTriangle",
                   @(REShapeDiamond)          : @"REShapeDiamond",
                   @(REShapeUndefined)        : @"REShapeUndefined" };
    });

    return index[@(shape)];
}

typedef enum REStyle : int16_t REStyle; enum REStyle : int16_t
{
    REStyleUndefined        = 0b0000000000000000,
    REStyleApplyGloss       = 0b0000000000000001,
    REStyleDrawBorder       = 0b0000000000000010,
    REStyleStretchable      = 0b0000000000000100,
    REStyleGlossStyle1      = REStyleApplyGloss,  // 50-50 split
    REStyleGlossStyle2      = 0b0000000000001001, // Top ⅓
    REStyleGlossStyle3      = 0b0000000000010001, // Unused
    REStyleGlossStyle4      = 0b0000000000100001, // Unused
    REGlossStyleMask        = 0b0000000000111001
};

static inline NSString *NSStringFromREStyle(REStyle style)
{
    NSMutableArray * stringArray = [@[] mutableCopy];
    if (style & REStyleGlossStyle1)       [stringArray addObject:@"REStyleGlossStyle1"];
    else if (style & REStyleGlossStyle2)  [stringArray addObject:@"REStyleGlossStyle2"];
    else if (style & REStyleGlossStyle3)  [stringArray addObject:@"REStyleGlossStyle3"];
    else if (style & REStyleGlossStyle4)  [stringArray addObject:@"REStyleGlossStyle4"];
    if (style & REStyleDrawBorder)        [stringArray addObject:@"REStyleDrawBorder"];
    if (style & REStyleStretchable)       [stringArray addObject:@"REStyleStretchable"];
    return (stringArray.count ? [stringArray componentsJoinedByString:@"|"] : @"REStyleUndefined");
}

typedef enum REThemeFlags : int32_t REThemeFlags; enum REThemeFlags : int32_t
{
    REThemeAll                    = 0b000000000000000000000000000000,

    REThemeNoBackgroundImage	  = 0b000000000000000000000000000001,
    REThemeNoBackgroundImageAlpha = 0b000000000000000000000000000010,
    REThemeNoBackgroundColor      = 0b000000000000000000000000000100,
    REThemeNoBackground           = 0b000000000000000000000000000111,

    REThemeNoBorder			      = 0b000000000000000000000000001000,
    REThemeNoGloss			      = 0b000000000000000000000000010000,
    REThemeNoStretchable          = 0b000000000000000000000000100000,
    REThemeNoStyle			      = 0b000000000000000000000000111000,

    REThemeNoIconImage            = 0b000000000000000000000001000000,
    REThemeNoIconColor            = 0b000000000000000000000010000000,
    REThemeNoIconInsets           = 0b000000000000000000000100000000,
    REThemeNoIcon                 = 0b000000000000000000000111000000,

    REThemeNoTitleForegroundColor = 0b000000000000000000001000000000,
    REThemeNoTitleBackgroundColor = 0b000000000000000000010000000000,
    REThemeNoTitleShadowColor     = 0b000000000000000000100000000000,
    REThemeNoTitleStrokeColor     = 0b000000000000000001000000000000,
    REThemeNoTitleColor           = 0b000000000000000001111000000000,
    REThemeNoFontName		      = 0b000000000000000001000000000000,
    REThemeNoFontSize             = 0b000000000000000010000000000000,
    REThemeNoFont                 = 0b000000000000000011000000000000,
    REThemeNoStrokeWidth          = 0b000000000000000100000000000000,
    REThemeNoStrikethrough        = 0b000000000000001000000000000000,
    REThemeNoUnderline            = 0b000000000000010000000000000000,
    REThemeNoLigature             = 0b000000000000100000000000000000,
    REThemeNoKern                 = 0b000000000001000000000000000000,
    REThemeNoParagraphStyle       = 0b000000000010000000000000000000,
    REThemeNoTitleAttributes      = 0b000000000011111111111000000000,
    REThemeNoTitleInsets          = 0b000000000100000000000000000000,
    REThemeNoTitleText            = 0b000000001000000000000000000000,
    REThemeNoTitle                = 0b000000001111111111111000000000,

    REThemeNoContentInsets        = 0b000000010000000000000000000000,
    REThemeNoShape                = 0b000000100000000000000000000000,

    REThemeReserved               = 0b111111000000000000000000000000,
    REThemeNone                   = 0b111111111111111111111111111111
};

static inline NSString *NSStringFromREThemeFlags(REThemeFlags themeFlags)
{
    static dispatch_once_t onceToken;
    static NSDictionary const * index;
    dispatch_once(&onceToken, ^{
        index = @{ @(REThemeNoBackgroundImage)      : @"REThemeNoBackgroundImage",
                   @(REThemeNoBackgroundImageAlpha) : @"REThemeNoBackgroundImageAlpha",
                   @(REThemeNoBackgroundColor)      : @"REThemeNoBackgroundColor",
                   @(REThemeNoBorder)               : @"REThemeNoBorder",
                   @(REThemeNoGloss)                : @"REThemeNoGloss",
                   @(REThemeNoStretchable)          : @"REThemeNoStretchable",
                   @(REThemeNoIconImage)            : @"REThemeNoIconImage",
                   @(REThemeNoIconColor)            : @"REThemeNoIconColor",
                   @(REThemeNoIconInsets)           : @"REThemeNoIconInsets",
                   @(REThemeNoTitleForegroundColor) : @"REThemeNoTitleForegroundColor",
                   @(REThemeNoTitleBackgroundColor) : @"REThemeNoTitleBackgroundColor",
                   @(REThemeNoTitleShadowColor)     : @"REThemeNoTitleShadowColor",
                   @(REThemeNoTitleStrokeColor)     : @"REThemeNoTitleStrokeColor",
                   @(REThemeNoFontName)             : @"REThemeNoFontName",
                   @(REThemeNoFontSize)             : @"REThemeNoFontSize",
                   @(REThemeNoStrokeWidth)          : @"REThemeNoStrokeWidth",
                   @(REThemeNoStrikethrough)        : @"REThemeNoStrikethrough",
                   @(REThemeNoUnderline)            : @"REThemeNoUnderline",
                   @(REThemeNoLigature)             : @"REThemeNoLigature",
                   @(REThemeNoKern)                 : @"REThemeNoKern",
                   @(REThemeNoParagraphStyle)       : @"REThemeNoParagraphStyle",
                   @(REThemeNoTitleAttributes)      : @"REThemeNoTitleAttributes",
                   @(REThemeNoTitleInsets)          : @"REThemeNoTitleInsets",
                   @(REThemeNoTitleText)            : @"REThemeNoTitleText",
                   @(REThemeNoContentInsets)        : @"REThemeNoContentInsets",
                   @(REThemeNoShape)                : @"REThemeNoShape" };
    });

    NSArray * flagKeys = [[index allKeys] objectsPassingTest:
    ^BOOL(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        return (themeFlags & [obj intValue]);
    }];

    if (!flagKeys || ![flagKeys count]) return @"REThemeAll";
    else if ([flagKeys count] == [index count]) return @"REThemeNone";

    else
        return [[index objectsForKeys:flagKeys notFoundMarker:NullObject] componentsJoinedByString:@"|"];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Flags
////////////////////////////////////////////////////////////////////////////////


/*

 0000000000 0000 00
      │      │  └ base type
      │      └ button group
      └ button

 */
typedef enum REType : int16_t REType; enum REType : int16_t
{
    // unknown
    RETypeUndefined                 = 0b0000000000000000,

    // base types
    RETypeRemote                    = 0b0000000000000001,
    RETypeButtonGroup               = 0b0000000000000010,
    RETypeButton                    = 0b0000000000000011,
    RETypeBaseMask                  = 0b0000000000000011,

    // button group types
    REButtonGroupTypePanel          = 0b0000000000000110,
    REButtonGroupTypeSelectionPanel = 0b0000000000001110,
    REButtonGroupTypeToolbar        = 0b0000000000001010,
    REButtonGroupTypeDPad           = 0b0000000000010010,
    REButtonGroupTypeNumberpad      = 0b0000000000011010,
    REButtonGroupTypeTransport      = 0b0000000000100010,
    REButtonGroupTypePickerLabel    = 0b0000000000101010,
    REButtonGroupTypeMask           = 0b0000000000111100,

    // button types
    REButtonTypeToolbar             = 0b0000000000001011,
    REButtonTypeConnectionStatus    = 0b0000000001001011,
    REButtonTypeBatteryStatus       = 0b0000000010001011,

    REButtonTypePickerLabel         = 0b0000000000101011,
    REButtonTypePickerLabelTop      = 0b0000000001101011,
    REButtonTypePickerLabelBottom   = 0b0000000010101011,

    REButtonTypePanel               = 0b0000000000000111,
    REButtonTypeTuck                = 0b0000000001000111,
    REButtonTypeSelectionPanel      = 0b0000000000001111,

    REButtonTypeDPad                = 0b0000000000010011,
    REButtonTypeDPadUp              = 0b0000000001010011,
    REButtonTypeDPadDown            = 0b0000000010010011,
    REButtonTypeDPadLeft            = 0b0000000011010011,
    REButtonTypeDPadRight           = 0b0000000100010011,
    REButtonTypeDPadCenter          = 0b0000000101010011,

    REButtonTypeNumberpad           = 0b0000000000011011,
    REButtonTypeNumberpad1          = 0b0000000001011011,
    REButtonTypeNumberpad2          = 0b0000000010011011,
    REButtonTypeNumberpad3          = 0b0000000011011011,
    REButtonTypeNumberpad4          = 0b0000000100011011,
    REButtonTypeNumberpad5          = 0b0000000101011011,
    REButtonTypeNumberpad6          = 0b0000000111011011,
    REButtonTypeNumberpad7          = 0b0000001000011011,
    REButtonTypeNumberpad8          = 0b0000001001011011,
    REButtonTypeNumberpad9          = 0b0000001010011011,
    REButtonTypeNumberpad0          = 0b0000001011011011,
    REButtonTypeNumberpadAux1       = 0b0000001100011011,
    REButtonTypeNumberpadAux2       = 0b0000001100111011,
    REButtonTypeTransport           = 0b0000000000100011,
    REButtonTypeTransportPlay       = 0b0000000001100011,
    REButtonTypeTransportStop       = 0b0000000010100011,
    REButtonTypeTransportPause      = 0b0000000011100011,
    REButtonTypeTransportSkip       = 0b0000000100100011,
    REButtonTypeTransportReplay     = 0b0000000101100011,
    REButtonTypeTransportFF         = 0b0000000111100011,
    REButtonTypeTransportRewind     = 0b0000001000100011,
    REButtonTypeTransportRecord     = 0b0000001001100011,

    REButtonTypeBaseMask            = 0b0000000000111111
};

static inline REType baseTypeForREType(REType type)
{
    return type & RETypeBaseMask;
}

static inline REType buttonGroupTypeForREType(REType type)
{
    return type & REButtonGroupTypeMask;
}

static inline REType baseButtonTypeForREType(REType type)
{
    return type & REButtonTypeBaseMask;
}

static inline NSString *NSStringFromREType(REType type)
{
    static dispatch_once_t onceToken;
    static NSDictionary const * index;
    dispatch_once(&onceToken, ^{
        index = @{ @(RETypeUndefined)                 : @"RETypeUndefined",
                   @(RETypeRemote)                    : @"RETypeRemote",
                   @(RETypeButtonGroup)               : @"RETypeButtonGroup",
                   @(RETypeButton)                    : @"RETypeButton",
                   @(RETypeBaseMask)                  : @"RETypeBaseMask",
                   @(REButtonGroupTypePanel)          : @"REButtonGroupTypePanel",
                   @(REButtonGroupTypeSelectionPanel) : @"REButtonGroupTypeSelectionPanel",
                   @(REButtonGroupTypeToolbar)        : @"REButtonGroupTypeToolbar",
                   @(REButtonGroupTypeDPad)           : @"REButtonGroupTypeDPad",
                   @(REButtonGroupTypeNumberpad)      : @"REButtonGroupTypeNumberpad",
                   @(REButtonGroupTypeTransport)      : @"REButtonGroupTypeTransport",
                   @(REButtonGroupTypePickerLabel)    : @"REButtonGroupTypePickerLabel",
                   @(REButtonGroupTypeMask)           : @"REButtonGroupTypeMask",
                   @(REButtonTypeToolbar)             : @"REButtonTypeToolbar",
                   @(REButtonTypeConnectionStatus)    : @"REButtonTypeConnectionStatus",
                   @(REButtonTypeBatteryStatus)       : @"REButtonTypeBatteryStatus",
                   @(REButtonTypePickerLabel)         : @"REButtonTypePickerLabel",
                   @(REButtonTypePickerLabelTop)      : @"REButtonTypePickerLabelTop",
                   @(REButtonTypePickerLabelBottom)   : @"REButtonTypePickerLabelBottom",
                   @(REButtonTypePanel)               : @"REButtonTypePanel",
                   @(REButtonTypeTuck)                : @"REButtonTypeTuck",
                   @(REButtonTypeSelectionPanel)      : @"REButtonTypeSelectionPanel",
                   @(REButtonTypeDPad)                : @"REButtonTypeDPad",
                   @(REButtonTypeDPadUp)              : @"REButtonTypeDPadUp",
                   @(REButtonTypeDPadDown)            : @"REButtonTypeDPadDown",
                   @(REButtonTypeDPadLeft)            : @"REButtonTypeDPadLeft",
                   @(REButtonTypeDPadRight)           : @"REButtonTypeDPadRight",
                   @(REButtonTypeDPadCenter)          : @"REButtonTypeDPadCenter",
                   @(REButtonTypeNumberpad)           : @"REButtonTypeNumberpad",
                   @(REButtonTypeNumberpad1)          : @"REButtonTypeNumberpad1",
                   @(REButtonTypeNumberpad2)          : @"REButtonTypeNumberpad2",
                   @(REButtonTypeNumberpad3)          : @"REButtonTypeNumberpad3",
                   @(REButtonTypeNumberpad4)          : @"REButtonTypeNumberpad4",
                   @(REButtonTypeNumberpad5)          : @"REButtonTypeNumberpad5",
                   @(REButtonTypeNumberpad6)          : @"REButtonTypeNumberpad6",
                   @(REButtonTypeNumberpad7)          : @"REButtonTypeNumberpad7",
                   @(REButtonTypeNumberpad8)          : @"REButtonTypeNumberpad8",
                   @(REButtonTypeNumberpad9)          : @"REButtonTypeNumberpad9",
                   @(REButtonTypeNumberpad0)          : @"REButtonTypeNumberpad0",
                   @(REButtonTypeNumberpadAux1)       : @"REButtonTypeNumberpadAux1",
                   @(REButtonTypeNumberpadAux2)       : @"REButtonTypeNumberpadAux2",
                   @(REButtonTypeTransport)           : @"REButtonTypeTransport",
                   @(REButtonTypeTransportPlay)       : @"REButtonTypeTransportPlay",
                   @(REButtonTypeTransportStop)       : @"REButtonTypeTransportStop",
                   @(REButtonTypeTransportPause)      : @"REButtonTypeTransportPause",
                   @(REButtonTypeTransportSkip)       : @"REButtonTypeTransportSkip",
                   @(REButtonTypeTransportReplay)     : @"REButtonTypeTransportReplay",
                   @(REButtonTypeTransportFF)         : @"REButtonTypeTransportFF",
                   @(REButtonTypeTransportRewind)     : @"REButtonTypeTransportRewind",
                   @(REButtonTypeTransportRecord)     : @"REButtonTypeTransportRecord" };
    });

    if (   (baseTypeForREType(type) == RETypeButtonGroup)
        && (type & REButtonGroupTypePanel) == REButtonGroupTypePanel
        && type != REButtonGroupTypeSelectionPanel
        )
        type &= ~REButtonGroupTypePanel|RETypeButtonGroup;

    return index[@(type)];
}

typedef enum RESubtype : int16_t RESubtype; enum RESubtype : int16_t
{
    RESubtypeUndefined                  = 0b0000000000000000,

    REButtonGroupTopPanel               = 0b0000000000000001,
    REButtonGroupTopPanel1              = 0b0000000000001001,
    REButtonGroupTopPanel2              = 0b0000000000010001,
    REButtonGroupTopPanel3              = 0b0000000000011001,

    REButtonGroupBottomPanel            = 0b0000000000000010,
    REButtonGroupBottomPanel1           = 0b0000000000001010,
    REButtonGroupBottomPanel2           = 0b0000000000010010,
    REButtonGroupBottomPanel3           = 0b0000000000011010,

    REButtonGroupLeftPanel              = 0b0000000000000011,
    REButtonGroupLeftPanel1             = 0b0000000000001011,
    REButtonGroupLeftPanel2             = 0b0000000000010011,
    REButtonGroupLeftPanel3             = 0b0000000000011011,

    REButtonGroupRightPanel             = 0b0000000000000100,
    REButtonGroupRightPanel1            = 0b0000000000001100,
    REButtonGroupRightPanel2            = 0b0000000000010100,
    REButtonGroupRightPanel3            = 0b0000000000011100,

    REButtonGroupPanelLocationMask      = 0b0000000000000111,
    REButtonGroupPanelAssignmentMask    = 0b0000000000011000
};

static inline NSString *NSStringFromRESubtype(RESubtype subtype)
{
    static dispatch_once_t onceToken;
    static NSDictionary const * index;
    dispatch_once(&onceToken, ^{
        index = @{ @(REButtonGroupTopPanel)     : @"REButtonGroupTopPanel",
                   @(REButtonGroupTopPanel1)    : @"REButtonGroupTopPanel1",
                   @(REButtonGroupTopPanel2)    : @"REButtonGroupTopPanel2",
                   @(REButtonGroupTopPanel3)    : @"REButtonGroupTopPanel3",
                   @(REButtonGroupBottomPanel)  : @"REButtonGroupBottomPanel",
                   @(REButtonGroupBottomPanel1) : @"REButtonGroupBottomPanel1",
                   @(REButtonGroupBottomPanel2) : @"REButtonGroupBottomPanel2",
                   @(REButtonGroupBottomPanel3) : @"REButtonGroupBottomPanel3",
                   @(REButtonGroupLeftPanel)    : @"REButtonGroupLeftPanel",
                   @(REButtonGroupLeftPanel1)   : @"REButtonGroupLeftPanel1",
                   @(REButtonGroupLeftPanel2)   : @"REButtonGroupLeftPanel2",
                   @(REButtonGroupLeftPanel3)   : @"REButtonGroupLeftPanel3",
                   @(REButtonGroupRightPanel)   : @"REButtonGroupRightPanel",
                   @(REButtonGroupRightPanel1)  : @"REButtonGroupRightPanel1",
                   @(REButtonGroupRightPanel2)  : @"REButtonGroupRightPanel2",
                   @(REButtonGroupRightPanel3)  : @"REButtonGroupRightPanel3" };
    });

    return (index[@(subtype)] ?: @"RESubtypeUndefined");
}

typedef enum REPanelLocation : int16_t REPanelLocation; enum REPanelLocation : int16_t
{
    REPanelLocationUnassigned = 0b0000000000000000,
    REPanelLocationTop        = 0b0000000000000001,
    REPanelLocationBottom     = 0b0000000000000010,
    REPanelLocationLeft       = 0b0000000000000011,
    REPanelLocationRight      = 0b0000000000000100
};

static inline
NSString *NSStringFromREPanelLocation(REPanelLocation location)
{
    static dispatch_once_t onceToken;
    static NSDictionary const * index;
    dispatch_once(&onceToken, ^{
        index = @{ @(REPanelLocationTop)    : @"REPanelLocationTop",
                   @(REPanelLocationBottom) : @"REPanelLocationBottom",
                   @(REPanelLocationLeft)   : @"REPanelLocationLeft",
                   @(REPanelLocationRight)  : @"REPanelLocationRight" };
    });

    return (index[@(location)] ?: @"REPanelLocationUnassigned");
}

typedef enum REPanelTrigger : int16_t REPanelTrigger; enum REPanelTrigger : int16_t
{
    REPanelNoTrigger  = 0b0000000000000000,
    REPanelTrigger1   = 0b0000000000001000,
    REPanelTrigger2   = 0b0000000000010000,
    REPanelTrigger3   = 0b0000000000011000
};

static inline
NSString *NSStringFromREPanelTrigger(REPanelTrigger assignment)
{
    static dispatch_once_t onceToken;
    static NSDictionary const * index;
    dispatch_once(&onceToken, ^{
        index = @{ @(REPanelTrigger1) : @"REPanelTrigger1",
                   @(REPanelTrigger2) : @"REPanelTrigger2",
                   @(REPanelTrigger3) : @"REPanelTrigger3" };
    });

    return (index[@(assignment)] ?: @"REPanelNoTrigger");
}

typedef enum REPanelAssignment : int16_t REPanelAssignment; enum REPanelAssignment : int16_t
{
    REPanelUnassigned             = 0b0000000000000000,
    REPanelAssignmentLocationMask = 0b0000000000000111,
    REPanelAssignmentTriggerMask  = 0b0000000000011000
};

static inline
NSString *NSStringFromREPanelAssignment(REPanelAssignment assignment)
{
    return (assignment == REPanelUnassigned
            ? @"REPanelUnassigned"
            : $(@"%@ | %@",
                NSStringFromREPanelLocation(assignment & REPanelAssignmentLocationMask),
                NSStringFromREPanelTrigger(assignment & REPanelAssignmentTriggerMask)));
}

typedef enum REOptions : int16_t REOptions; enum REOptions : int16_t
{
    REOptionsUndefined               = 0b0000000000000000,
    RERemoteOptionsDefault           = 0b0000000000000000,
    RERemoteOptionTopBarHiddenOnLoad = 0b0000000000000001,
    REButtonGroupOptionsDefault      = 0b0000000000000000,
    REButtonGroupOptionAutohide      = 0b0000000000000001
};

static inline NSString *NSStringFromREOptions(REOptions options, REType type)
{
    switch (options)
    {
        case 1:
            if ((type & RETypeBaseMask) == RETypeRemote)
                return @"RERemoteOptionTopBarHiddenOnLoad";
            else if ((type & RETypeBaseMask) == RETypeButtonGroup)
                return @"REButtonGroupOptionAutohide";
        default: return @"REOptionsUndefined";
    }
}

typedef enum REState : int16_t REState; enum REState : int16_t
{
    REStateDefault     = 0b0000000000000000,
    REStateNormal      = 0b0000000000000000,
    REStateHighlighted = 0b0000000000000001,
    REStateDisabled    = 0b0000000000000010,
    REStateSelected    = 0b0000000000000100
};

static inline NSString *NSStringFromREState(REState state)
{
    if (state == REStateDefault) return @"REStateDefault";

    NSMutableArray * stateStrings = [@[] mutableCopy];
    if ((state & REStateDisabled))    [stateStrings addObject:@"REStateDisabled"];
    if ((state & REStateSelected))    [stateStrings addObject:@"REStateSelected"];
    if ((state & REStateHighlighted)) [stateStrings addObject:@"REStateHighlighted"];
    return (stateStrings.count
            ? [stateStrings componentsJoinedByString:@"|"]
            : @"REStateNormal");
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////

typedef enum RECommandOptions : NSUInteger RECommandOptions; enum RECommandOptions : NSUInteger
{
    RECommandOptionDefault   = 0 << 0,
    RECommandOptionLongPress = 1 << 0
};

typedef enum RESystemCommandType : int16_t RESystemCommandType; enum RESystemCommandType : int16_t
{
    RESystemCommandToggleProximitySensor = 0,
    RESystemCommandURLRequest            = 1,
    RESystemCommandReturnToLaunchScreen  = 2,
    RESystemCommandOpenSettings          = 3,
    RESystemCommandOpenEditor            = 4
};

static inline NSString * NSStringFromRESystemCommandType(RESystemCommandType type)
{
    switch (type) {
        case RESystemCommandOpenEditor: 			   return @"RESystemCommandOpenEditor";
        case RESystemCommandOpenSettings: 		   return @"RESystemCommandOpenSettings";
        case RESystemCommandReturnToLaunchScreen:  return @"RESystemCommandReturnToLaunchScreen";
        case RESystemCommandToggleProximitySensor: return @"RESystemCommandToggleProximitySensor";
        case RESystemCommandURLRequest:  			   return @"RESystemCommandURLRequest";
        default:  							 						   return nil;
    }
}

typedef enum RECommandSetType : NSUInteger RECommandSetType; enum RECommandSetType : NSUInteger
{
    RECommandSetTypeUnspecified = 0,
    RECommandSetTypeDPad		= 1,
    RECommandSetTypeTransport	= 2,
    RECommandSetTypeNumberPad	= 3,
    RECommandSetTypeRocker		= 4
};

typedef void (^ RECommandCompletionHandler)(BOOL success, NSError *);

typedef void (^ REActionHandler)(void);

typedef enum REAction : NSUInteger REAction; enum REAction : NSUInteger
{
    RESingleTapAction = 0,
    RELongPressAction = 1
};

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Editing
////////////////////////////////////////////////////////////////////////////////

typedef enum REEditingMode : uint64_t REEditingMode; enum REEditingMode : uint64_t
{
    REEditingModeNotEditing  = RETypeUndefined,
    RERemoteEditingMode      = RETypeRemote,
    REButtonGroupEditingMode = RETypeButtonGroup,
    REButtonEditingMode      = RETypeButton
};

static inline NSString * NSStringFromREEditingMode(REEditingMode mode)
{
    NSMutableString * modeString = [NSMutableString string];

    if (mode & RERemoteEditingMode) {
        [modeString appendString:@"RERemoteEditingMode"];
        if (mode & REButtonGroupEditingMode) {
            [modeString appendString:@"|REButtonGroupEditingMode"];
            if (mode & REButtonEditingMode) [modeString appendString:@"|REButtonEditingMode"];
        }
    }

    else
        [modeString appendString:@"REEditingModeNotEditing"];


    return modeString;
}

typedef enum REEditingState : NSUInteger REEditingState; enum REEditingState : NSUInteger
{
    REEditingStateNotEditing   = 0 << 0,
    REEditingStateSelected     = 1 << 0,
    REEditingStateFocus        = 1 << 1,
    REEditingStateMoving       = 1 << 2
};

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constraints
////////////////////////////////////////////////////////////////////////////////

typedef enum RERelationshipType : uint8_t RERelationshipType; enum RERelationshipType : uint8_t
{
    REUnspecifiedRelation   = 0,
    REParentRelationship    = 1,
    REChildRelationship     = 2,
    RESiblingRelationship   = 3,
    REIntrinsicRelationship = 4
};

static inline NSString * NSStringFromRERelationshipType(RERelationshipType relationship)
{
    static dispatch_once_t onceToken;
    static NSDictionary const * index;
    dispatch_once(&onceToken, ^{
        index = @{ @(REUnspecifiedRelation)   : @"REUnspecifiedRelation",
                   @(REParentRelationship)    : @"REParentRelationship",
                   @(REChildRelationship)     : @"REChildRelationship",
                   @(RESiblingRelationship)   : @"RESiblingRelationship",
                   @(REIntrinsicRelationship) : @"REIntrinsicRelationship" };
    });

    return index[@(relationship)];
}

typedef enum RELayoutAxisDimension : uint8_t RELayoutAxisDimension; enum RELayoutAxisDimension : uint8_t
{
    RELayoutXAxis           = 0,
    RELayoutYAxis           = 1,
    RELayoutWidthDimension  = 2,
    RELayoutHeightDimension = 3
};

typedef enum RELayoutAttribute : uint8_t RELayoutAttribute; enum RELayoutAttribute : uint8_t
{
    RELayoutAttributeHeight  = 1 << 0,
    RELayoutAttributeWidth   = 1 << 1,
    RELayoutAttributeCenterY = 1 << 2,
    RELayoutAttributeCenterX = 1 << 3,
    RELayoutAttributeBottom  = 1 << 4,
    RELayoutAttributeTop     = 1 << 5,
    RELayoutAttributeRight   = 1 << 6,
    RELayoutAttributeLeft    = 1 << 7
};

typedef enum RELayoutConstraintOrder : NSUInteger RELayoutConstraintOrder; enum RELayoutConstraintOrder : NSUInteger
{
    RELayoutConstraintUnspecifiedOrder = 0,
    RELayoutConstraintFirstOrder       = 1,
    RELayoutConstraintSecondOrder      = 2
};

typedef enum RELayoutConstraintAffiliation : NSUInteger RELayoutConstraintAffiliation; enum RELayoutConstraintAffiliation : NSUInteger
{
    RELayoutConstraintUnspecifiedAffiliation    = 0,
    RELayoutConstraintFirstItemAffiliation      = 1 << 0,
    RELayoutConstraintSecondItemAffiliation     = 1 << 1,
    RELayoutConstraintOwnerAffiliation          = 1 << 2
};

static inline NSString * NSStringFromRELayoutConstraintAffiliation(RELayoutConstraintAffiliation affiliation)
{
    if (!affiliation) return @"RELayoutConstraintUnspecifiedAffiliation";
    NSMutableArray * affiliations = [@[] mutableCopy];
    if (affiliation & RELayoutConstraintFirstItemAffiliation)
        [affiliations addObject:@"RELayoutConstraintFirstItemAffiliation"];
    if (affiliation & RELayoutConstraintSecondItemAffiliation)
        [affiliations addObject:@"RELayoutConstraintSecondItemAffiliation"];
    if (affiliation & RELayoutConstraintOwnerAffiliation)
        [affiliations addObject:@"RELayoutConstraintOwnerAffiliation"];
    return [affiliations componentsJoinedByString:@"|"];
}

typedef enum RELayoutConfigurationDependencyType : uint8_t RELayoutConfigurationDependencyType; enum RELayoutConfigurationDependencyType : uint8_t
{
    RELayoutConfigurationUnspecifiedDependency = REUnspecifiedRelation,
    RELayoutConfigurationParentDependency 	   = REChildRelationship,
    RELayoutConfigurationSiblingDependency 	   = RESiblingRelationship,
    RELayoutConfigurationIntrinsicDependency   = REIntrinsicRelationship
};


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configuration
////////////////////////////////////////////////////////////////////////////////

typedef NSString * RERemoteConfiguration;


