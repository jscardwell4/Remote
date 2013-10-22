//
//  RemoteElementExportSupportFunctions.m
//  Remote
//
//  Created by Jason Cardwell on 10/12/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteElementExportSupportFunctions.h"
#import "RemoteElement.h"
#import "Remote.h"
#import "ButtonGroup.h"
#import "Button.h"
#import "Command.h"
#import "CommandContainer.h"
#import "JSONObjectKeys.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Types, Subtypes and Roles
////////////////////////////////////////////////////////////////////////////////

NSString * typeJSONValueForRemoteElement(RemoteElement * element)
{
    static NSDictionary const * index;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ @(RETypeRemote)      : RETypeRemoteKey,
                                 @(RETypeButtonGroup) : RETypeButtonGroupKey,
                                 @(RETypeButton)      : RETypeButtonKey };
                  });

    return (element ? index[@(element.elementType)] : nil);
}

NSString * subtypeJSONValueForRemoteElement(RemoteElement * element)
{
    static NSDictionary const * index;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ @(RESubtypeUndefined)        : RESubtypeUndefinedKey,
                                 
                                 @(REButtonGroupTopPanel1)    : REButtonGroupTopPanel1Key,
                                 @(REButtonGroupTopPanel2)    : REButtonGroupTopPanel2Key,
                                 @(REButtonGroupTopPanel3)    : REButtonGroupTopPanel3Key,
                                 
                                 @(REButtonGroupBottomPanel1) : REButtonGroupBottomPanel1Key,
                                 @(REButtonGroupBottomPanel2) : REButtonGroupBottomPanel2Key,
                                 @(REButtonGroupBottomPanel3) : REButtonGroupBottomPanel3Key,
                                 
                                 @(REButtonGroupLeftPanel1)   : REButtonGroupLeftPanel1Key,
                                 @(REButtonGroupLeftPanel2)   : REButtonGroupLeftPanel2Key,
                                 @(REButtonGroupLeftPanel3)   : REButtonGroupLeftPanel3Key,
                                 
                                 @(REButtonGroupRightPanel1)  : REButtonGroupRightPanel1Key,
                                 @(REButtonGroupRightPanel2)  : REButtonGroupRightPanel2Key,
                                 @(REButtonGroupRightPanel3)  : REButtonGroupRightPanel3Key };
                  });

    return (element ? index[@(element.subtype)] : nil);
}

NSString * roleJSONValueForRemoteElement(RemoteElement * element)
{
    static NSDictionary const * index;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index =
                      @{ @(RERoleUndefined)                 : RERoleUndefinedKey,

                         // button group roles
                         @(REButtonGroupRolePanel)          : REButtonGroupRolePanelKey,
                         @(REButtonGroupRoleSelectionPanel) : REButtonGroupRoleSelectionPanelKey,
                         @(REButtonGroupRoleToolbar)        : REButtonGroupRoleToolbarKey,
                         @(REButtonGroupRoleDPad)           : REButtonGroupRoleDPadKey,
                         @(REButtonGroupRoleNumberpad)      : REButtonGroupRoleNumberpadKey,
                         @(REButtonGroupRoleTransport)      : REButtonGroupRoleTransportKey,
                         @(REButtonGroupRolePickerLabel)    : REButtonGroupRolePickerLabelKey,

                         // toolbar buttons
                         @(REButtonRoleToolbar)             : REButtonRoleToolbarKey,
                         @(REButtonRoleConnectionStatus)    : REButtonRoleConnectionStatusKey,
                         @(REButtonRoleBatteryStatus)       : REButtonRoleBatteryStatusKey,

                         // picker label buttons
                         @(REButtonRolePickerLabelTop)      : REButtonRolePickerLabelTopKey,
                         @(REButtonRolePickerLabelBottom)   : REButtonRolePickerLabelBottomKey,

                         // panel buttons
                         @(REButtonRolePanel)               : REButtonRolePanelKey,
                         @(REButtonRoleTuck)                : REButtonRoleTuckKey,
                         @(REButtonRoleSelectionPanel)      : REButtonRoleSelectionPanelKey,

                         // dpad buttons
                         @(REButtonRoleDPadUp)              : REButtonRoleDPadUpKey,
                         @(REButtonRoleDPadDown)            : REButtonRoleDPadDownKey,
                         @(REButtonRoleDPadLeft)            : REButtonRoleDPadLeftKey,
                         @(REButtonRoleDPadRight)           : REButtonRoleDPadRightKey,
                         @(REButtonRoleDPadCenter)          : REButtonRoleDPadCenterKey,


                         // numberpad buttons
                         @(REButtonRoleNumberpad1)          : REButtonRoleNumberpad1Key,
                         @(REButtonRoleNumberpad2)          : REButtonRoleNumberpad2Key,
                         @(REButtonRoleNumberpad3)          : REButtonRoleNumberpad3Key,
                         @(REButtonRoleNumberpad4)          : REButtonRoleNumberpad4Key,
                         @(REButtonRoleNumberpad5)          : REButtonRoleNumberpad5Key,
                         @(REButtonRoleNumberpad6)          : REButtonRoleNumberpad6Key,
                         @(REButtonRoleNumberpad7)          : REButtonRoleNumberpad7Key,
                         @(REButtonRoleNumberpad8)          : REButtonRoleNumberpad8Key,
                         @(REButtonRoleNumberpad9)          : REButtonRoleNumberpad9Key,
                         @(REButtonRoleNumberpad0)          : REButtonRoleNumberpad0Key,
                         @(REButtonRoleNumberpadAux1)       : REButtonRoleNumberpadAux1Key,
                         @(REButtonRoleNumberpadAux2)       : REButtonRoleNumberpadAux2Key,

                         // transport buttons
                         @(REButtonRoleTransportPlay)       : REButtonRoleTransportPlayKey,
                         @(REButtonRoleTransportStop)       : REButtonRoleTransportStopKey,
                         @(REButtonRoleTransportPause)      : REButtonRoleTransportPauseKey,
                         @(REButtonRoleTransportSkip)       : REButtonRoleTransportSkipKey,
                         @(REButtonRoleTransportReplay)     : REButtonRoleTransportReplayKey,
                         @(REButtonRoleTransportFF)         : REButtonRoleTransportFFKey,
                         @(REButtonRoleTransportRewind)     : REButtonRoleTransportRewindKey,
                         @(REButtonRoleTransportRecord)     : REButtonRoleTransportRecordKey };
                  });

    return (element ? index[@(element.role)] : nil);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element State & Options
////////////////////////////////////////////////////////////////////////////////

NSString * stateJSONValueForRemoteElement(RemoteElement * element)
{
    static NSDictionary const * index;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ @(REStateNormal)      : REStateNormalKey,
                                 @(REStateDisabled)    : REStateDisabledKey,
                                 @(REStateHighlighted) : REStateHighlightedKey,
                                 @(REStateSelected)    : REStateSelectedKey };
                  });

    NSMutableArray * stateArray = [@[] mutableCopy];

    REState state = element.state;

    if (state & REStateDisabled)    [stateArray addObject:index[@(REStateDisabled)]];
    if (state & REStateHighlighted) [stateArray addObject:index[@(REStateHighlighted)]];
    if (state & REStateSelected)    [stateArray addObject:index[@(REStateSelected)]];

    return ([stateArray count] ? [stateArray componentsJoinedByString:@" "] : nil);
}

NSString * optionsJSONValueForRemoteElement(RemoteElement * element)
{
    static NSDictionary const * remoteIndex, * buttonGroupIndex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      remoteIndex =
                          @{ @(RERemoteOptionTopBarHidden) : RERemoteOptionTopBarHiddenKey };

                      buttonGroupIndex =
                          @{ @(REButtonGroupOptionAutohide) : REButtonGroupOptionAutohideKey };
                  });

    if ([element isKindOfClass:[Remote class]])
        return remoteIndex[@(element.options)];

    else if ([element isKindOfClass:[ButtonGroup class]])
        return buttonGroupIndex[@(element.options)];

    else
        return nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Shape, Style, & Theme
////////////////////////////////////////////////////////////////////////////////

NSString * shapeJSONValueForRemoteElement(RemoteElement * element)
{
    static NSDictionary const * index;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ @(REShapeUndefined)        : REShapeUndefinedKey,
                                 @(REShapeRoundedRectangle) : REShapeRoundedRectangleKey,
                                 @(REShapeRectangle)        : REShapeRectangleKey,
                                 @(REShapeDiamond)          : REShapeDiamondKey,
                                 @(REShapeTriangle)         : REShapeTriangleKey,
                                 @(REShapeOval)             : REShapeOvalKey };
                  });

    return (element ? index[@(element.shape)] : nil);
}

NSString * styleJSONValueForRemoteElement(RemoteElement * element)
{
    static NSDictionary const * index;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ @(REStyleUndefined)   : REStyleUndefinedKey,
                                 @(REStyleDrawBorder)  : REStyleDrawBorderKey,
                                 @(REStyleStretchable) : REStyleStretchableKey,
                                 @(REStyleApplyGloss)  : REStyleGlossStyle1Key,
                                 @(REStyleGlossStyle2) : REStyleGlossStyle2Key,
                                 @(REStyleGlossStyle3) : REStyleGlossStyle3Key,
                                 @(REStyleGlossStyle4) : REStyleGlossStyle4Key };
                  });

    if (!element) return nil;

    REStyle style = element.style;

    NSMutableArray * stringsArray = [@[] mutableCopy];

    if (style & REStyleDrawBorder) [stringsArray addObject:index[@(REStyleDrawBorder)]];
    if (style & REStyleStretchable) [stringsArray addObject:index[@(REStyleStretchable)]];

    REStyle glossStyle = (style & REGlossStyleMask);

    if (glossStyle) [stringsArray addObject:index[@(glossStyle)]];

    return ([stringsArray count] ? [stringsArray componentsJoinedByString:@" "] : nil);
}

NSString * themeFlagsJSONValueForRemoteElement(RemoteElement * element)
{
    static NSDictionary const * index;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index =
                          @{ @(REThemeNoBackgroundImage)      : REThemeNoBackgroundImageKey,
                             @(REThemeNoBackgroundImageAlpha) : REThemeNoBackgroundImageAlphaKey,
                             @(REThemeNoBackgroundColor)      : REThemeNoBackgroundColorKey,
                             @(REThemeNoBorder)               : REThemeNoBorderKey,
                             @(REThemeNoGloss)                : REThemeNoGlossKey,
                             @(REThemeNoStretchable)          : REThemeNoStretchableKey,
                             @(REThemeNoIconImage)            : REThemeNoIconImageKey,
                             @(REThemeNoIconColor)            : REThemeNoIconColorKey,
                             @(REThemeNoIconInsets)           : REThemeNoIconInsetsKey,
                             @(REThemeNoTitleForegroundColor) : REThemeNoTitleForegroundColorKey,
                             @(REThemeNoTitleBackgroundColor) : REThemeNoTitleBackgroundColorKey,
                             @(REThemeNoTitleShadowColor)     : REThemeNoTitleShadowColorKey,
                             @(REThemeNoTitleStrokeColor)     : REThemeNoTitleStrokeColorKey,
                             @(REThemeNoFontName)             : REThemeNoFontNameKey,
                             @(REThemeNoFontSize)             : REThemeNoFontSizeKey,
                             @(REThemeNoStrokeWidth)          : REThemeNoStrokeWidthKey,
                             @(REThemeNoStrikethrough)        : REThemeNoStrikethroughKey,
                             @(REThemeNoUnderline)            : REThemeNoUnderlineKey,
                             @(REThemeNoLigature)             : REThemeNoLigatureKey,
                             @(REThemeNoKern)                 : REThemeNoKernKey,
                             @(REThemeNoParagraphStyle)       : REThemeNoParagraphStyleKey,
                             @(REThemeNoTitleInsets)          : REThemeNoTitleInsetsKey,
                             @(REThemeNoTitleText)            : REThemeNoTitleTextKey,
                             @(REThemeNoContentInsets)        : REThemeNoContentInsetsKey,
                             @(REThemeNoShape)                : REThemeNoShapeKey };
                  });
    

    if (!element) return nil;

    REThemeOverrideFlags elementFlags = element.themeFlags;

    if (elementFlags == REThemeAll)
        return REThemeAllKey;

    else if (elementFlags == REThemeNone)
        return REThemeNoneKey;

    else
    {
        NSArray * possibleFlags = [index allKeys];
        NSArray * flagsSet = [possibleFlags objectsPassingTest:
                              ^BOOL(NSNumber *obj, NSUInteger idx, BOOL *stop)
                              {
                                  uint8_t flag = [obj unsignedShortValue];
                                  return ((elementFlags & flag) == flag);
                              }];

        if (![flagsSet count])
            return nil;

        else if ([flagsSet count] > [possibleFlags count]/2)
        {
            NSMutableSet * flagsNotSet = [[possibleFlags set] mutableCopy];
            [flagsNotSet minusSet:[flagsSet set]];
            NSMutableArray * jsonValues = [[index objectsForKeys:[flagsNotSet allObjects]
                                                  notFoundMarker:NullObject] mutableCopy];
            [jsonValues removeNullObjects];
            return [@"-" stringByAppendingString:[jsonValues componentsJoinedByString:@" "]];
        }

        else
        {
            NSMutableArray * jsonValues = [[index objectsForKeys:flagsSet
                                                  notFoundMarker:NullObject] mutableCopy];
            [jsonValues removeNullObjects];
            return [jsonValues componentsJoinedByString:@" "];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////

NSString * systemCommandTypeJSONValueForSystemCommand(SystemCommand * command)
{
    static NSDictionary const * index;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ @(SystemCommandTypeUndefined)   : SystemCommandTypeUndefinedKey,
                                 @(SystemCommandProximitySensor) : SystemCommandProximitySensorKey,
                                 @(SystemCommandURLRequest)      : SystemCommandURLRequestKey,
                                 @(SystemCommandLaunchScreen)    : SystemCommandLaunchScreenKey,
                                 @(SystemCommandOpenSettings)    : SystemCommandOpenSettingsKey,
                                 @(SystemCommandOpenEditor)      : SystemCommandOpenEditorKey };
                  });

    return (command ? index[@(command.type)] : nil);
}

NSString * switchCommandTypeJSONValueForSwitchCommand(SwitchCommand * command)
{
    static NSDictionary const * index;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ @(SwitchRemoteCommand) : SwitchRemoteCommandKey,
                                 @(SwitchModeCommand)   : SwitchModeCommandKey };
                  });

    return (command ? index[@(command.type)] : nil);
}

NSString * commandSetTypeJSONValueForCommandSet(CommandSet * commandSet)
{
    static NSDictionary const * index;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ @(CommandSetTypeUnspecified) : CommandSetTypeUnspecifiedKey,
                                 @(CommandSetTypeDPad)        : CommandSetTypeDPadKey,
                                 @(CommandSetTypeTransport)   : CommandSetTypeTransportKey,
                                 @(CommandSetTypeNumberpad)   : CommandSetTypeNumberpadKey,
                                 @(CommandSetTypeRocker)      : CommandSetTypeRockerKey };
                  });

    return (commandSet ? index[@(commandSet.type)] : nil);
}

NSString * classJSONValueForCommand(Command * command)
{
    static NSDictionary const * index;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        index = @{ @"PowerCommand"    : PowerCommandTypeKey,
                   @"SendIRCommand"   : SendIRCommandTypeKey,
                   @"HTTPCommand"     : HTTPCommandTypeKey,
                   @"DelayCommand"    : DelayCommandTypeKey,
                   @"MacroCommand"    : MacroCommandTypeKey,
                   @"SystemCommand"   : SystemCommandTypeKey,
                   @"SwitchCommand"   : SwitchCommandTypeKey,
                   @"ActivityCommand" : ActivityCommandTypeKey };
    });
    return index[ClassString([command class])];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote
////////////////////////////////////////////////////////////////////////////////

NSString * panelKeyForPanelAssignment(REPanelAssignment assignment)
{
    static NSDictionary const * locationIndex, * triggerIndex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      locationIndex = @{ @(REPanelLocationTop)    : REPanelLocationTopKey,
                                         @(REPanelLocationBottom) : REPanelLocationBottomKey,
                                         @(REPanelLocationLeft)   : REPanelLocationLeftKey,
                                         @(REPanelLocationRight)  : REPanelLocationRightKey };

                      triggerIndex = @{ @(REPanelTrigger1) : REPanelTrigger1Key,
                                        @(REPanelTrigger2) : REPanelTrigger2Key,
                                        @(REPanelTrigger3) : REPanelTrigger3Key };
                  });

    REPanelLocation location = (assignment & REPanelAssignmentLocationMask);
    REPanelTrigger  trigger  = (assignment & REPanelAssignmentTriggerMask);

    NSString * key = nil;

    if (location && trigger)
    {
        NSString * locationString = locationIndex[@(location)];
        NSString * triggerString  = triggerIndex[@(trigger)];

        if (locationString && triggerString)
            key = [locationString stringByAppendingString:triggerString];
    }

    return key;

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utility functions
////////////////////////////////////////////////////////////////////////////////

NSString * normalizedColorJSONValueForColor(UIColor * color)
{
    NSString * value = [UIColor nameForColor:color ignoreAlpha:NO];

    if (!value)
    {
        NSString * base = [UIColor nameForColor:color ignoreAlpha:YES];
        if (base)
            value = [base stringByAppendingFormat:@"@%@%%", [@(color.alpha * 100.0f) stringValue]];
    }

    if (!value && color.isRGBCompatible) value = [color RGBAHexStringRepresentation];

    return value;
}

BOOL exportModelDataForClassToFile(Class modelClass, NSString *fileName)
{
    return NO;
}
