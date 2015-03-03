//
//  RETypedefs.h
//  Remote
//
//  Created by Jason Cardwell on 3/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
@import CocoaLumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Appearance
////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM (uint8_t, REShape) {
  REShapeUndefined        = 0,
  REShapeRoundedRectangle = 1,
  REShapeOval             = 2,
  REShapeRectangle        = 3,
  REShapeTriangle         = 4,
  REShapeDiamond          = 5
};

static inline NSString *NSStringFromREShape(REShape shape) {
  static dispatch_once_t      onceToken;
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

typedef NS_OPTIONS (uint8_t, REStyle) {
  REStyleUndefined   = 0b00000000,
  REStyleApplyGloss  = 0b00000001,
  REStyleDrawBorder  = 0b00000010,
  REStyleStretchable = 0b00000100,
  REStyleGlossStyle1 = REStyleApplyGloss,         // 50-50 split
  REStyleGlossStyle2 = 0b00001001,                // Top ⅓
  REStyleGlossStyle3 = 0b00010001,                // Unused
  REStyleGlossStyle4 = 0b00100001,                // Unused
  REGlossStyleMask   = 0b00111001
};

static inline NSString *NSStringFromREStyle(REStyle style) {
  NSMutableArray * stringArray = [@[] mutableCopy];

  if (style & REStyleGlossStyle1) [stringArray addObject:@"REStyleGlossStyle1"];
  else if (style & REStyleGlossStyle2) [stringArray addObject:@"REStyleGlossStyle2"];
  else if (style & REStyleGlossStyle3) [stringArray addObject:@"REStyleGlossStyle3"];
  else if (style & REStyleGlossStyle4) [stringArray addObject:@"REStyleGlossStyle4"];

  if (style & REStyleDrawBorder) [stringArray addObject:@"REStyleDrawBorder"];

  if (style & REStyleStretchable) [stringArray addObject:@"REStyleStretchable"];

  return (stringArray.count ? [stringArray componentsJoinedByString:@"|"] : @"REStyleUndefined");
}

typedef NS_OPTIONS (uint32_t, REThemeOverrideFlags) {

  REThemeNone = 0b000000000000000000000000000000,

  REThemeNoBackgroundImage               = 0b000000000000000000000000000001,
  REThemeNoBackgroundImageAlpha          = 0b000000000000000000000000000010,
  REThemeNoBackgroundColorAttribute      = 0b000000000000000000000000000100,
  REThemeNoBackground                    = 0b000000000000000000000000000111,

  REThemeNoBorder                        = 0b000000000000000000000000001000,
  REThemeNoGloss                         = 0b000000000000000000000000010000,
  REThemeNoStretchable                   = 0b000000000000000000000000100000,
  REThemeNoStyle                         = 0b000000000000000000000000111000,

  REThemeNoIconImage                     = 0b000000000000000000000001000000,
  REThemeNoIconColorAttribute            = 0b000000000000000000000010000000,
  REThemeNoIconInsets                    = 0b000000000000000000000100000000,
  REThemeNoIcon                          = 0b000000000000000000000111000000,

  REThemeNoTitleForegroundColorAttribute = 0b000000000000000000001000000000,
  REThemeNoTitleBackgroundColorAttribute = 0b000000000000000000010000000000,
  REThemeNoTitleShadowColorAttribute     = 0b000000000000000000100000000000,
  REThemeNoTitleStrokeColorAttribute     = 0b000000000000000001000000000000,
  REThemeNoTitleColorAttribute           = 0b000000000000000001111000000000,
  REThemeNoFontName                      = 0b000000000000000001000000000000,
  REThemeNoFontSize                      = 0b000000000000000010000000000000,
  REThemeNoFont                          = 0b000000000000000011000000000000,
  REThemeNoStrokeWidth                   = 0b000000000000000100000000000000,
  REThemeNoStrikethrough                 = 0b000000000000001000000000000000,
  REThemeNoUnderline                     = 0b000000000000010000000000000000,
  REThemeNoLigature                      = 0b000000000000100000000000000000,
  REThemeNoKern                          = 0b000000000001000000000000000000,
  REThemeNoParagraphStyle                = 0b000000000010000000000000000000,
  REThemeNoTitleAttributes               = 0b000000000011111111111000000000,
  REThemeNoTitleInsets                   = 0b000000000100000000000000000000,
  REThemeNoTitleText                     = 0b000000001000000000000000000000,
  REThemeNoTitle                         = 0b000000001111111111111000000000,

  REThemeNoContentInsets                 = 0b000000010000000000000000000000,
  REThemeNoShape                         = 0b000000100000000000000000000000,

  REThemeReserved                        = 0b111111000000000000000000000000,
  REThemeAll                             = 0b111111111111111111111111111111

};

static inline NSString *NSStringFromREThemeFlags(REThemeOverrideFlags themeFlags) {
  static dispatch_once_t      onceToken;
  static NSDictionary const * index;
  dispatch_once(&onceToken, ^{
    index =
      @{ @(REThemeNoBackgroundImage)               : @"REThemeNoBackgroundImage",
         @(REThemeNoBackgroundImageAlpha)          : @"REThemeNoBackgroundImageAlpha",
         @(REThemeNoBackgroundColorAttribute)      : @"REThemeNoBackgroundColorAttribute",
         @(REThemeNoBorder)                        : @"REThemeNoBorder",
         @(REThemeNoGloss)                         : @"REThemeNoGloss",
         @(REThemeNoStretchable)                   : @"REThemeNoStretchable",
         @(REThemeNoIconImage)                     : @"REThemeNoIconImage",
         @(REThemeNoIconColorAttribute)            : @"REThemeNoIconColorAttribute",
         @(REThemeNoIconInsets)                    : @"REThemeNoIconInsets",
         @(REThemeNoTitleForegroundColorAttribute) : @"REThemeNoTitleForegroundColorAttribute",
         @(REThemeNoTitleBackgroundColorAttribute) : @"REThemeNoTitleBackgroundColorAttribute",
         @(REThemeNoTitleShadowColorAttribute)     : @"REThemeNoTitleShadowColorAttribute",
         @(REThemeNoTitleStrokeColorAttribute)     : @"REThemeNoTitleStrokeColorAttribute",
         @(REThemeNoFontName)                      : @"REThemeNoFontName",
         @(REThemeNoFontSize)                      : @"REThemeNoFontSize",
         @(REThemeNoStrokeWidth)                   : @"REThemeNoStrokeWidth",
         @(REThemeNoStrikethrough)                 : @"REThemeNoStrikethrough",
         @(REThemeNoUnderline)                     : @"REThemeNoUnderline",
         @(REThemeNoLigature)                      : @"REThemeNoLigature",
         @(REThemeNoKern)                          : @"REThemeNoKern",
         @(REThemeNoParagraphStyle)                : @"REThemeNoParagraphStyle",
         @(REThemeNoTitleAttributes)               : @"REThemeNoTitleAttributes",
         @(REThemeNoTitleInsets)                   : @"REThemeNoTitleInsets",
         @(REThemeNoTitleText)                     : @"REThemeNoTitleText",
         @(REThemeNoContentInsets)                 : @"REThemeNoContentInsets",
         @(REThemeNoShape)                         : @"REThemeNoShape" };
  });

  NSArray * flagKeys = [[index allKeys] objectsPassingTest:
                        ^BOOL (NSNumber * obj, NSUInteger idx, BOOL * stop) {
    uint32_t flag = [obj unsignedIntValue];
    BOOL hasFlag = ((themeFlags & flag) == flag ? YES : NO);
    return hasFlag;
  }];

  if (![flagKeys count]) {
    assert(themeFlags == 0);
    return @"REThemeNone";
  } else if ([flagKeys count] == [index count]) return @"REThemeAll";

  else
    return [[index objectsForKeys:flagKeys notFoundMarker:NullObject]
            componentsJoinedByString:@"|"];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Flags
////////////////////////////////////////////////////////////////////////////////


typedef NS_ENUM (uint8_t, REType) {
  RETypeUndefined   = 0b00000000,
  RETypeRemote      = 0b00000001,
  RETypeButtonGroup = 0b00000010,
  RETypeButton      = 0b00000011
};

static inline NSString *NSStringFromREType(REType type) {
  static dispatch_once_t      onceToken;
  static NSDictionary const * index;
  dispatch_once(&onceToken, ^{
    index = @{ @(RETypeUndefined)   : @"RETypeUndefined",
               @(RETypeRemote)      : @"RETypeRemote",
               @(RETypeButtonGroup) : @"RETypeButtonGroup",
               @(RETypeButton)      : @"RETypeButton" };
  });

  return index[@(type)];
}

// TODO: incorportate panel assignments into role value
typedef NS_OPTIONS (uint8_t, RERole) {
  RERoleUndefined                 = 0b00000000,

  // button group roles
  REButtonGroupRoleSelectionPanel = 0b00000011,
  REButtonGroupRoleToolbar        = 0b00000010,
  REButtonGroupRoleDPad           = 0b00000100,
  REButtonGroupRoleNumberpad      = 0b00000110,
  REButtonGroupRoleTransport      = 0b00001000,
  REButtonGroupRoleRocker         = 0b00001010,

  // toolbar buttons
  REButtonRoleToolbar             = 0b00000010,
  REButtonRoleConnectionStatus    = 0b00010010,
  REButtonRoleBatteryStatus       = 0b00100010,
  REButtonRoleToolbarMask         = 0b00000010,

  // picker label buttons
  REButtonRoleRocker              = 0b00001010,
  REButtonRoleRockerTop           = 0b00011010,
  REButtonRoleRockerBottom        = 0b00101010,
  REButtonRoleRockerMask          = 0b00001010,

  // panel buttons
  REButtonRolePanel               = 0b00000001,
  REButtonRoleTuck                = 0b00010001,
  REButtonRoleSelectionPanel      = 0b00000011,
  REButtonRolePanelMask           = 0b00000001,

  // dpad buttons
  REButtonRoleDPad                = 0b00000100,
  REButtonRoleDPadUp              = 0b00010100,
  REButtonRoleDPadDown            = 0b00100100,
  REButtonRoleDPadLeft            = 0b00110100,
  REButtonRoleDPadRight           = 0b01000100,
  REButtonRoleDPadCenter          = 0b01010100,
  REButtonRoleDPadMask            = 0b00000100,


  // numberpad buttons
  REButtonRoleNumberpad           = 0b00000110,
  REButtonRoleNumberpad1          = 0b00010110,
  REButtonRoleNumberpad2          = 0b00100110,
  REButtonRoleNumberpad3          = 0b00110110,
  REButtonRoleNumberpad4          = 0b01000110,
  REButtonRoleNumberpad5          = 0b01010110,
  REButtonRoleNumberpad6          = 0b01110110,
  REButtonRoleNumberpad7          = 0b10000110,
  REButtonRoleNumberpad8          = 0b10010110,
  REButtonRoleNumberpad9          = 0b10100110,
  REButtonRoleNumberpad0          = 0b10110110,
  REButtonRoleNumberpadAux1       = 0b11000110,
  REButtonRoleNumberpadAux2       = 0b11001110,
  REButtonRoleNumberpadMask       = 0b00000110,

  // transport buttons
  REButtonRoleTransport           = 0b00001000,
  REButtonRoleTransportPlay       = 0b00011000,
  REButtonRoleTransportStop       = 0b00101000,
  REButtonRoleTransportPause      = 0b00111000,
  REButtonRoleTransportSkip       = 0b01001000,
  REButtonRoleTransportReplay     = 0b01011000,
  REButtonRoleTransportFF         = 0b01111000,
  REButtonRoleTransportRewind     = 0b10001000,
  REButtonRoleTransportRecord     = 0b10011000,
  REButtonRoleTransportMask       = 0b00001000,

};

static inline NSString *NSStringFromRERole(RERole role) {
  static dispatch_once_t      onceToken;
  static NSDictionary const * index;
  dispatch_once(&onceToken, ^{
    index = @{ @(REButtonGroupRoleSelectionPanel) : @"REButtonGroupRoleSelectionPanel",
               @(REButtonGroupRoleToolbar)        : @"REButtonGroupRoleToolbar",
               @(REButtonGroupRoleDPad)           : @"REButtonGroupRoleDPad",
               @(REButtonGroupRoleNumberpad)      : @"REButtonGroupRoleNumberpad",
               @(REButtonGroupRoleTransport)      : @"REButtonGroupRoleTransport",
               @(REButtonGroupRoleRocker)         : @"REButtonGroupRoleRocker",
               @(REButtonRoleToolbar)             : @"REButtonRoleToolbar",
               @(REButtonRoleConnectionStatus)    : @"REButtonRoleConnectionStatus",
               @(REButtonRoleBatteryStatus)       : @"REButtonRoleBatteryStatus",
               @(REButtonRoleRocker)              : @"REButtonRoleRocker",
               @(REButtonRoleRockerTop)           : @"REButtonRoleRockerTop",
               @(REButtonRoleRockerBottom)        : @"REButtonRoleRockerBottom",
               @(REButtonRolePanel)               : @"REButtonRolePanel",
               @(REButtonRoleTuck)                : @"REButtonRoleTuck",
               @(REButtonRoleSelectionPanel)      : @"REButtonRoleSelectionPanel",
               @(REButtonRoleDPad)                : @"REButtonRoleDPad",
               @(REButtonRoleDPadUp)              : @"REButtonRoleDPadUp",
               @(REButtonRoleDPadDown)            : @"REButtonRoleDPadDown",
               @(REButtonRoleDPadLeft)            : @"REButtonRoleDPadLeft",
               @(REButtonRoleDPadRight)           : @"REButtonRoleDPadRight",
               @(REButtonRoleDPadCenter)          : @"REButtonRoleDPadCenter",
               @(REButtonRoleNumberpad)           : @"REButtonRoleNumberpad",
               @(REButtonRoleNumberpad1)          : @"REButtonRoleNumberpad1",
               @(REButtonRoleNumberpad2)          : @"REButtonRoleNumberpad2",
               @(REButtonRoleNumberpad3)          : @"REButtonRoleNumberpad3",
               @(REButtonRoleNumberpad4)          : @"REButtonRoleNumberpad4",
               @(REButtonRoleNumberpad5)          : @"REButtonRoleNumberpad5",
               @(REButtonRoleNumberpad6)          : @"REButtonRoleNumberpad6",
               @(REButtonRoleNumberpad7)          : @"REButtonRoleNumberpad7",
               @(REButtonRoleNumberpad8)          : @"REButtonRoleNumberpad8",
               @(REButtonRoleNumberpad9)          : @"REButtonRoleNumberpad9",
               @(REButtonRoleNumberpad0)          : @"REButtonRoleNumberpad0",
               @(REButtonRoleNumberpadAux1)       : @"REButtonRoleNumberpadAux1",
               @(REButtonRoleNumberpadAux2)       : @"REButtonRoleNumberpadAux2",
               @(REButtonRoleTransport)           : @"REButtonRoleTransport",
               @(REButtonRoleTransportPlay)       : @"REButtonRoleTransportPlay",
               @(REButtonRoleTransportStop)       : @"REButtonRoleTransportStop",
               @(REButtonRoleTransportPause)      : @"REButtonRoleTransportPause",
               @(REButtonRoleTransportSkip)       : @"REButtonRoleTransportSkip",
               @(REButtonRoleTransportReplay)     : @"REButtonRoleTransportReplay",
               @(REButtonRoleTransportFF)         : @"REButtonRoleTransportFF",
               @(REButtonRoleTransportRewind)     : @"REButtonRoleTransportRewind",
               @(REButtonRoleTransportRecord)     : @"REButtonRoleTransportRecord" };
  });

  return index[@(role)];
}

typedef NS_ENUM (uint8_t, REPanelLocation) {
  REPanelLocationUnassigned = 0b00000000,
  REPanelLocationTop        = 0b00000001,
  REPanelLocationBottom     = 0b00000010,
  REPanelLocationLeft       = 0b00000011,
  REPanelLocationRight      = 0b00000100
};

static inline
NSString *NSStringFromREPanelLocation(REPanelLocation location) {
  static dispatch_once_t      onceToken;
  static NSDictionary const * index;
  dispatch_once(&onceToken, ^{
    index = @{ @(REPanelLocationTop)    : @"REPanelLocationTop",
               @(REPanelLocationBottom) : @"REPanelLocationBottom",
               @(REPanelLocationLeft)   : @"REPanelLocationLeft",
               @(REPanelLocationRight)  : @"REPanelLocationRight" };
  });

  return (index[@(location)] ?: @"REPanelLocationUnassigned");
}

typedef NS_ENUM (uint8_t, REPanelTrigger) {
  REPanelNoTrigger = 0b00000000,
  REPanelTrigger1  = 0b00001000,
  REPanelTrigger2  = 0b00010000,
  REPanelTrigger3  = 0b00011000
};

static inline
NSString *NSStringFromREPanelTrigger(REPanelTrigger assignment) {
  static dispatch_once_t      onceToken;
  static NSDictionary const * index;
  dispatch_once(&onceToken, ^{
    index = @{ @(REPanelTrigger1) : @"REPanelTrigger1",
               @(REPanelTrigger2) : @"REPanelTrigger2",
               @(REPanelTrigger3) : @"REPanelTrigger3" };
  });

  return (index[@(assignment)] ?: @"REPanelNoTrigger");
}

typedef NS_ENUM (uint8_t, REPanelAssignment) {
  REPanelUnassigned             = 0b00000000,
  REPanelAssignmentLocationMask = 0b00000111,
  REPanelAssignmentTriggerMask  = 0b00011000
};

static inline
NSString *NSStringFromREPanelAssignment(REPanelAssignment assignment) {
  return (assignment == REPanelUnassigned
          ? @"REPanelUnassigned"
          : $(@"%@ | %@",
              NSStringFromREPanelLocation(assignment & REPanelAssignmentLocationMask),
              NSStringFromREPanelTrigger(assignment & REPanelAssignmentTriggerMask)));
}


typedef NS_OPTIONS (uint8_t, REState) {
  REStateDefault     = 0b00000000,
  REStateNormal      = 0b00000000,
  REStateHighlighted = 0b00000001,
  REStateDisabled    = 0b00000010,
  REStateSelected    = 0b00000100
};

static inline NSString *NSStringFromREState(REState state) {
  if (state == REStateDefault) return @"REStateDefault";

  NSMutableArray * stateStrings = [@[] mutableCopy];

  if ((state & REStateDisabled)) [stateStrings addObject:@"REStateDisabled"];

  if ((state & REStateSelected)) [stateStrings addObject:@"REStateSelected"];

  if ((state & REStateHighlighted)) [stateStrings addObject:@"REStateHighlighted"];

  return (stateStrings.count
          ? [stateStrings componentsJoinedByString:@"|"]
          : @"REStateNormal");
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////

//typedef NS_ENUM (NSUInteger, CommandOptions) {
//  CommandOptionDefault     = 0 << 0,
//    CommandOptionLongPress = 1 << 0
//};

//typedef NS_ENUM (uint8_t, SystemCommandType) {
//  SystemCommandTypeUndefined   = 0,
//  SystemCommandProximitySensor = 1,
//  SystemCommandURLRequest      = 2,
//  SystemCommandLaunchScreen    = 3,
//  SystemCommandOpenSettings    = 4,
//  SystemCommandOpenEditor      = 5
//};
//
//static inline NSString *NSStringFromSystemCommandType(SystemCommandType type) {
//  switch (type) {
//    case SystemCommandOpenEditor:            return @"SystemCommandOpenEditor";
//    case SystemCommandOpenSettings:          return @"SystemCommandOpenSettings";
//    case SystemCommandLaunchScreen:          return @"SystemCommandLaunchScreen";
//    case SystemCommandProximitySensor:       return @"SystemCommandProximitySensor";
//    case SystemCommandURLRequest:            return @"SystemCommandURLRequest";
//    default:                                 return nil;
//  }
//}
//
//typedef NS_ENUM (uint8_t, SwitchCommandType) {
//  SwitchUndefinedCommand = 0,
//  SwitchRemoteCommand    = 1,
//  SwitchModeCommand      = 2
//};
//
//static inline NSString *NSStringFromSwitchCommandType(SwitchCommandType type) {
//  switch (type) {
//    case SwitchModeCommand:   return @"SwitchModeCommand";
//    case SwitchRemoteCommand: return @"SwitchRemoteCommand";
//    default:                  return @"Undefined";
//  }
//}

//typedef NS_ENUM (uint8_t, CommandSetType) {
//  CommandSetTypeUnspecified = RERoleUndefined,
//  CommandSetTypeDPad        = REButtonGroupRoleDPad,
//  CommandSetTypeTransport   = REButtonGroupRoleTransport,
//  CommandSetTypeNumberpad   = REButtonGroupRoleNumberpad,
//  CommandSetTypeRocker      = REButtonGroupRoleRocker
//};

//static inline BOOL CommandSetTypeIsValid(CommandSetType type) {
//  switch (type) {
//    case CommandSetTypeDPad:
//    case CommandSetTypeTransport:
//    case CommandSetTypeNumberpad:
//    case CommandSetTypeRocker:
//      return YES;
//    case CommandSetTypeUnspecified:
//    default:
//      return NO;
//  }
//}

//typedef (void (^)(BOOL success, NSError *));


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Editing
////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM (uint8_t, REEditingMode) {
  REEditingModeNotEditing  = RETypeUndefined,
  REEditingModeRemote      = RETypeRemote,
  REEditingModeButtonGroup = RETypeButtonGroup,
  REEditingModeButton      = RETypeButton
};

static inline NSString *NSStringFromREEditingMode(REEditingMode mode) {
  NSMutableString * modeString = [NSMutableString string];

  if (mode & REEditingModeRemote) {
    [modeString appendString:@"REEditingModeRemote"];

    if (mode & REEditingModeButtonGroup) {
      [modeString appendString:@"|REEditingModeButtonGroup"];

      if (mode & REEditingModeButton) [modeString appendString:@"|REEditingModeButton"];
    }
  } else
    [modeString appendString:@"REEditingModeNotEditing"];


  return modeString;
}

typedef NS_ENUM (uint8_t, REEditingState) {
  REEditingStateNotEditing = 0 << 0,
    REEditingStateSelected = 1 << 0,
    REEditingStateFocus    = 1 << 1,
    REEditingStateMoving   = 1 << 2
};

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constraints
////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM (uint8_t, RERelationshipType) {
  REUnspecifiedRelation   = 0,
  REParentRelationship    = 1,
  REChildRelationship     = 2,
  RESiblingRelationship   = 3,
  REIntrinsicRelationship = 4
};

static inline NSString *NSStringFromRERelationshipType(RERelationshipType relationship) {
  static dispatch_once_t      onceToken;
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

typedef NS_ENUM (uint8_t, RELayoutAxisDimension) {
  RELayoutXAxis           = 0,
  RELayoutYAxis           = 1,
  RELayoutWidthDimension  = 2,
  RELayoutHeightDimension = 3
};

typedef NS_ENUM (uint8_t, RELayoutAttribute) {
  RELayoutAttributeHeight    = 1 << 0,
    RELayoutAttributeWidth   = 1 << 1,
    RELayoutAttributeCenterY = 1 << 2,
    RELayoutAttributeCenterX = 1 << 3,
    RELayoutAttributeBottom  = 1 << 4,
    RELayoutAttributeTop     = 1 << 5,
    RELayoutAttributeRight   = 1 << 6,
    RELayoutAttributeLeft    = 1 << 7
};

typedef NS_ENUM (NSUInteger, RELayoutConstraintOrder) {
  RELayoutConstraintUnspecifiedOrder = 0,
  RELayoutConstraintFirstOrder       = 1,
  RELayoutConstraintSecondOrder      = 2
};

typedef NS_ENUM (NSUInteger, RELayoutConstraintAffiliation) {
  RELayoutConstraintUnspecifiedAffiliation  = 0,
  RELayoutConstraintFirstItemAffiliation    = 1 << 0,
    RELayoutConstraintSecondItemAffiliation = 1 << 1,
    RELayoutConstraintOwnerAffiliation      = 1 << 2
};

static inline NSString *NSStringFromRELayoutConstraintAffiliation(RELayoutConstraintAffiliation affiliation) {
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

typedef NS_ENUM (NSInteger, RELayoutConfigurationDependencyType) {
  RELayoutConfigurationUnspecifiedDependency = REUnspecifiedRelation,
  RELayoutConfigurationParentDependency      = REChildRelationship,
  RELayoutConfigurationSiblingDependency     = RESiblingRelationship,
  RELayoutConfigurationIntrinsicDependency   = REIntrinsicRelationship
};
