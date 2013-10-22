//
//  RemoteElementImportSupportFunctions.m
//  Remote
//
//  Created by Jason Cardwell on 4/30/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteElementImportSupportFunctions.h"
#import "RemoteElement.h"
#import "JSONObjectKeys.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Types
////////////////////////////////////////////////////////////////////////////////

Class remoteElementClassForImportKey(NSString * importKey)
{
    return classForREType(remoteElementTypeFromImportKey(importKey));
}

REType remoteElementTypeFromImportKey(NSString * importKey)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ RETypeRemoteKey      : @(RETypeRemote),
                                 RETypeButtonGroupKey : @(RETypeButtonGroup),
                                 RETypeButtonKey      : @(RETypeButton),
                                 RETypeUndefinedKey   : @(RETypeUndefined)};
                  });

    NSNumber * typeValue = index[importKey];

    return (typeValue ? [typeValue unsignedShortValue] : RETypeUndefined);
}

RERole remoteElementRoleFromImportKey(NSString * importKey)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index =
                      @{ RERoleUndefinedKey                 : @(RERoleUndefined),

                         // button group roles
                         REButtonGroupRolePanelKey          : @(REButtonGroupRolePanel),
                         REButtonGroupRoleSelectionPanelKey : @(REButtonGroupRoleSelectionPanel),
                         REButtonGroupRoleToolbarKey        : @(REButtonGroupRoleToolbar),
                         REButtonGroupRoleDPadKey           : @(REButtonGroupRoleDPad),
                         REButtonGroupRoleNumberpadKey      : @(REButtonGroupRoleNumberpad),
                         REButtonGroupRoleTransportKey      : @(REButtonGroupRoleTransport),
                         REButtonGroupRolePickerLabelKey    : @(REButtonGroupRolePickerLabel),

                         // toolbar buttons
                         REButtonRoleToolbarKey             : @(REButtonRoleToolbar),
                         REButtonRoleConnectionStatusKey    : @(REButtonRoleConnectionStatus),
                         REButtonRoleBatteryStatusKey       : @(REButtonRoleBatteryStatus),

                         // picker label buttons
                         REButtonRolePickerLabelTopKey      : @(REButtonRolePickerLabelTop),
                         REButtonRolePickerLabelBottomKey   : @(REButtonRolePickerLabelBottom),

                         // panel buttons
                         REButtonRolePanelKey               : @(REButtonRolePanel),
                         REButtonRoleTuckKey                : @(REButtonRoleTuck),
                         REButtonRoleSelectionPanelKey      : @(REButtonRoleSelectionPanel),

                         // dpad buttons
                         REButtonRoleDPadUpKey              : @(REButtonRoleDPadUp),
                         REButtonRoleDPadDownKey            : @(REButtonRoleDPadDown),
                         REButtonRoleDPadLeftKey            : @(REButtonRoleDPadLeft),
                         REButtonRoleDPadRightKey           : @(REButtonRoleDPadRight),
                         REButtonRoleDPadCenterKey          : @(REButtonRoleDPadCenter),


                         // numberpad buttons
                         REButtonRoleNumberpad1Key          : @(REButtonRoleNumberpad1),
                         REButtonRoleNumberpad2Key          : @(REButtonRoleNumberpad2),
                         REButtonRoleNumberpad3Key          : @(REButtonRoleNumberpad3),
                         REButtonRoleNumberpad4Key          : @(REButtonRoleNumberpad4),
                         REButtonRoleNumberpad5Key          : @(REButtonRoleNumberpad5),
                         REButtonRoleNumberpad6Key          : @(REButtonRoleNumberpad6),
                         REButtonRoleNumberpad7Key          : @(REButtonRoleNumberpad7),
                         REButtonRoleNumberpad8Key          : @(REButtonRoleNumberpad8),
                         REButtonRoleNumberpad9Key          : @(REButtonRoleNumberpad9),
                         REButtonRoleNumberpad0Key          : @(REButtonRoleNumberpad0),
                         REButtonRoleNumberpadAux1Key       : @(REButtonRoleNumberpadAux1),
                         REButtonRoleNumberpadAux2Key       : @(REButtonRoleNumberpadAux2),

                         // transport buttons
                         REButtonRoleTransportPlayKey       : @(REButtonRoleTransportPlay),
                         REButtonRoleTransportStopKey       : @(REButtonRoleTransportStop),
                         REButtonRoleTransportPauseKey      : @(REButtonRoleTransportPause),
                         REButtonRoleTransportSkipKey       : @(REButtonRoleTransportSkip),
                         REButtonRoleTransportReplayKey     : @(REButtonRoleTransportReplay),
                         REButtonRoleTransportFFKey         : @(REButtonRoleTransportFF),
                         REButtonRoleTransportRewindKey     : @(REButtonRoleTransportRewind),
                         REButtonRoleTransportRecordKey     : @(REButtonRoleTransportRecord) };
                      
                  });


    NSNumber * roleValue = index[importKey];

    return (roleValue ? [roleValue unsignedShortValue] : RERoleUndefined);
}


RESubtype remoteElementSubtypeFromImportKey(NSString * importKey)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ RESubtypeUndefinedKey        : @(RESubtypeUndefined),
                                 
                                 REButtonGroupTopPanel1Key    : @(REButtonGroupTopPanel1),
                                 REButtonGroupTopPanel2Key    : @(REButtonGroupTopPanel2),
                                 REButtonGroupTopPanel3Key    : @(REButtonGroupTopPanel3),
                                 
                                 REButtonGroupBottomPanel1Key : @(REButtonGroupBottomPanel1),
                                 REButtonGroupBottomPanel2Key : @(REButtonGroupBottomPanel2),
                                 REButtonGroupBottomPanel3Key : @(REButtonGroupBottomPanel3),
                                 
                                 REButtonGroupLeftPanel1Key   : @(REButtonGroupLeftPanel1),
                                 REButtonGroupLeftPanel2Key   : @(REButtonGroupLeftPanel2),
                                 REButtonGroupLeftPanel3Key   : @(REButtonGroupLeftPanel3),
                                 
                                 REButtonGroupRightPanel1Key  : @(REButtonGroupRightPanel1),
                                 REButtonGroupRightPanel2Key  : @(REButtonGroupRightPanel2),
                                 REButtonGroupRightPanel3Key  : @(REButtonGroupRightPanel3) };
                  });
    
    

    NSNumber * typeValue = index[importKey];

    return (typeValue ? [typeValue unsignedShortValue] : RESubtypeUndefined);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Options & State
////////////////////////////////////////////////////////////////////////////////

REOptions remoteElementOptionsFromImportKey(NSString * importKey)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ REOptionsUndefinedKey          : @(REOptionsUndefined),
                                 RERemoteOptionsDefaultKey      : @(RERemoteOptionsDefault),
                                 RERemoteOptionTopBarHiddenKey  : @(RERemoteOptionTopBarHidden),
                                 REButtonGroupOptionAutohideKey : @(REButtonGroupOptionAutohide) };
                  });

    NSNumber * typeValue = index[importKey];

    return (typeValue ? [typeValue unsignedShortValue] : REOptionsUndefined);
}

REState remoteElementStateFromImportKey(NSString * importKey) { return REStateDefault; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Shape, Style, & Theme
////////////////////////////////////////////////////////////////////////////////

REShape remoteElementShapeFromImportKey(NSString * importKey)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ REShapeUndefinedKey        : @(REShapeUndefined),
                                 REShapeRoundedRectangleKey : @(REShapeRoundedRectangle),
                                 REShapeRectangleKey        : @(REShapeRectangle),
                                 REShapeDiamondKey          : @(REShapeDiamond),
                                 REShapeTriangleKey         : @(REShapeTriangle),
                                 REShapeOvalKey             : @(REShapeOval) };
                  });

    NSNumber * shapeValue = index[importKey];

    return (shapeValue ? [shapeValue unsignedShortValue] : REShapeUndefined);
}

REStyle remoteElementStyleFromImportKey(NSString * importKey)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ REStyleUndefinedKey   : @(REStyleUndefined),
                                 REStyleDrawBorderKey  : @(REStyleDrawBorder),
                                 REStyleStretchableKey : @(REStyleStretchable),
                                 REStyleApplyGlossKey  : @(REStyleApplyGloss),
                                 REStyleGlossStyle1Key : @(REStyleGlossStyle1),
                                 REStyleGlossStyle2Key : @(REStyleGlossStyle2),
                                 REStyleGlossStyle3Key : @(REStyleGlossStyle3),
                                 REStyleGlossStyle4Key : @(REStyleGlossStyle4) };
                  });

    REStyle style = REStyleUndefined;

    for (NSString * key in [importKey componentsSeparatedByString:@" "])
    {
        NSNumber * styleValue = index[key];
        if (styleValue) style |= [styleValue unsignedShortValue];
    }

    return style;
}

REThemeOverrideFlags remoteElementThemeFlagsFromImportKey(NSString * importKey)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ REThemeNoneKey                   : @(REThemeNone),
                                 REThemeNoBackgroundImageKey      : @(REThemeNoBackgroundImage),
                                 REThemeNoBackgroundImageAlphaKey : @(REThemeNoBackgroundImageAlpha),
                                 REThemeNoBackgroundColorKey      : @(REThemeNoBackgroundColor),
                                 REThemeNoBorderKey               : @(REThemeNoBorder),
                                 REThemeNoGlossKey                : @(REThemeNoGloss),
                                 REThemeNoStretchableKey          : @(REThemeNoStretchable),
                                 REThemeNoIconImageKey            : @(REThemeNoIconImage),
                                 REThemeNoIconColorKey            : @(REThemeNoIconColor),
                                 REThemeNoIconInsetsKey           : @(REThemeNoIconInsets),
                                 REThemeNoTitleForegroundColorKey : @(REThemeNoTitleForegroundColor),
                                 REThemeNoTitleBackgroundColorKey : @(REThemeNoTitleBackgroundColor),
                                 REThemeNoTitleShadowColorKey     : @(REThemeNoTitleShadowColor),
                                 REThemeNoTitleStrokeColorKey     : @(REThemeNoTitleStrokeColor),
                                 REThemeNoFontNameKey             : @(REThemeNoFontName),
                                 REThemeNoFontSizeKey             : @(REThemeNoFontSize),
                                 REThemeNoStrokeWidthKey          : @(REThemeNoStrokeWidth),
                                 REThemeNoStrikethroughKey        : @(REThemeNoStrikethrough),
                                 REThemeNoUnderlineKey            : @(REThemeNoUnderline),
                                 REThemeNoLigatureKey             : @(REThemeNoLigature),
                                 REThemeNoKernKey                 : @(REThemeNoKern),
                                 REThemeNoParagraphStyleKey       : @(REThemeNoParagraphStyle),
                                 REThemeNoTitleInsetsKey          : @(REThemeNoTitleInsets),
                                 REThemeNoTitleTextKey            : @(REThemeNoTitleText),
                                 REThemeNoContentInsetsKey        : @(REThemeNoContentInsets),
                                 REThemeNoShapeKey                : @(REThemeNoShape),
                                 REThemeAllKey                    : @(REThemeAll) };
                  });

    REThemeOverrideFlags flags = REThemeNone;

    BOOL invert = NO;

    if ([importKey[0] isEqualToNumber:@('-')])
    {
        invert = YES;
        importKey = [importKey substringFromIndex:1];
    }

    NSMutableSet * flagsToSet = [[[index allKeys] set] mutableCopy];
    NSSet * parsedFlags = [[importKey componentsSeparatedByString:@" "] set];

    if (invert) [flagsToSet minusSet:parsedFlags];
    else [flagsToSet intersectSet:parsedFlags];


    if ([parsedFlags count])
    {
        NSMutableArray * flagValues = [[index objectsForKeys:[flagsToSet allObjects]
                                              notFoundMarker:NullObject] mutableCopy];
        [flagValues removeNullObjects];
        for (NSNumber * f  in flagValues)
            flags |= [f unsignedShortValue];
    }

    return flags;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////

SystemCommandType systemCommandTypeFromImportKey(NSString * importKey)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index =
                      @{ SystemCommandTypeUndefinedKey         : @(SystemCommandTypeUndefined),
                         SystemCommandProximitySensorKey : @(SystemCommandProximitySensor),
                         SystemCommandURLRequestKey            : @(SystemCommandURLRequest),
                         SystemCommandLaunchScreenKey  : @(SystemCommandLaunchScreen),
                         SystemCommandOpenSettingsKey          : @(SystemCommandOpenSettings),
                         SystemCommandOpenEditorKey            : @(SystemCommandOpenEditor) };
                  });

    NSNumber * typeValue = index[importKey];

    return (typeValue ? [typeValue unsignedShortValue] : SystemCommandTypeUndefined);
}

CommandSetType commandSetTypeFromImportKey(NSString * importKey)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ CommandSetTypeUnspecifiedKey : @(CommandSetTypeUnspecified),
                                 CommandSetTypeDPadKey        : @(CommandSetTypeDPad),
                                 CommandSetTypeTransportKey   : @(CommandSetTypeTransport),
                                 CommandSetTypeNumberpadKey   : @(CommandSetTypeNumberpad),
                                 CommandSetTypeRockerKey      : @(CommandSetTypeRocker) };
                  });

    NSNumber * typeValue = index[importKey];

    return (typeValue ? [typeValue unsignedShortValue] : CommandSetTypeUnspecified);
}

Class commandClassForImportKey(NSString * importKey)
{
    static NSDictionary const * index;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ PowerCommandTypeKey    : NSClassFromString(@"PowerCommand"),
                                 SendIRCommandTypeKey   : NSClassFromString(@"SendIRCommand"),
                                 HTTPCommandTypeKey     : NSClassFromString(@"HTTPCommand"),
                                 DelayCommandTypeKey    : NSClassFromString(@"DelayCommand"),
                                 MacroCommandTypeKey    : NSClassFromString(@"MacroCommand"),
                                 SystemCommandTypeKey   : NSClassFromString(@"SystemCommand"),
                                 SwitchCommandTypeKey   : NSClassFromString(@"SwitchCommand"),
                                 ActivityCommandTypeKey : NSClassFromString(@"ActivityCommand") };
                  });

    return index[importKey];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utility functions
////////////////////////////////////////////////////////////////////////////////

UIColor * colorFromImportValue(NSString * importValue)
{
    UIColor * color = [UIColor colorWithName:importValue];

    if (!color && [importValue hasSubstring:@"@[0-9.]+%"])
    {
        NSArray * baseAndAlpha = [importValue componentsSeparatedByString:@"@"];
        if (![baseAndAlpha count] == 2) return nil;

        NSString * base = baseAndAlpha[0];
        NSString * percent = [baseAndAlpha[1] substringToIndex:[baseAndAlpha[1] length] - 1];

        UIColor * baseColor = [UIColor colorWithName:base];
        if (!baseColor) return nil;

        color = [baseColor colorWithAlphaComponent:[percent floatValue] / 100.0f];
    }

    else if (!color && [importValue hasPrefix:@"#"])
    {
        color = [UIColor colorWithRGBAHexString:importValue];
    }

    else if (!color)
    {
        NSArray * components = [importValue componentsSeparatedByString:@" "];
        if (![components count] == 4) return nil;
        color = [UIColor colorWithRed:[(NSString *)components[0] floatValue]
                                green:[(NSString *)components[1] floatValue]
                                 blue:[(NSString *)components[2] floatValue]
                                alpha:[(NSString *)components[3] floatValue]];
    }

    return color;
}

