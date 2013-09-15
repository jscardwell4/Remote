//
//  MSRemoteImportSupportFunctions.m
//  Remote
//
//  Created by Jason Cardwell on 4/30/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSRemoteImportSupportFunctions.h"
#import "RemoteElement.h"

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
    dispatch_once(&onceToken, ^{
        index = @{ @"remote"                    : @(RETypeRemote),
                   @"buttongroup"               : @(RETypeButtonGroup),
                   @"toolbarbuttongroup"        : @(REButtonGroupTypeToolbar),
                   @"selectionpanelbuttongroup" : @(REButtonGroupTypeSelectionPanel),
                   @"panelbuttongroup"          : @(REButtonGroupTypePanel),
                   @"pickerlabelbuttongroup"    : @(REButtonGroupTypePickerLabel),
                   @"button"                    : @(RETypeButton),
                   @"connectionstatusbutton"    : @(REButtonTypeConnectionStatus),
                   @"batterystatusbutton"       : @(REButtonTypeBatteryStatus) };
    });

    importKey = [[importKey stringByRemovingCharactersFromSet:NSWhitespaceCharacters]
                 lowercaseString];
    NSNumber * typeValue = index[importKey];
    return (typeValue ? [typeValue shortValue] : RETypeUndefined);
}

RESubtype remoteElementSubtypeFromImportKey(NSString * importKey)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        index = @{ @"toppanel"          : @(REButtonGroupTopPanel),
                   @"bottompanel"       : @(REButtonGroupBottomPanel),
                   @"leftpanel"         : @(REButtonGroupLeftPanel),
                   @"rightpanel"        : @(REButtonGroupRightPanel) };
    });

    importKey = [[importKey stringByRemovingCharactersFromSet:NSWhitespaceCharacters]
                 lowercaseString];
    NSNumber * typeValue = index[importKey];
    return (typeValue ? [typeValue shortValue] : RESubtypeUndefined);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Options & State
////////////////////////////////////////////////////////////////////////////////

REOptions remoteElementOptionsFromImportKey(NSString * importKey)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        index = @{ @"topbarhidden" : @(RERemoteOptionTopBarHiddenOnLoad),
                   @"autohide"     : @(REButtonGroupOptionAutohide)};
    });

    importKey = [[importKey stringByRemovingCharactersFromSet:NSWhitespaceCharacters]
                 lowercaseString];
    NSNumber * typeValue = index[importKey];
    return (typeValue ? [typeValue shortValue] : REOptionsUndefined);
}

REState remoteElementStateFromImportKey(NSString * importKey) { return REStateDefault; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Shape & Style
////////////////////////////////////////////////////////////////////////////////

REShape remoteElementShapeFromImportKey(NSString * importKey)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        index = @{ @"roundedrectangle": @(REShapeRoundedRectangle),
                   @"rectangle"        : @(REShapeRectangle),
                   @"diamond"     : @(REShapeDiamond),
                   @"triangle"    : @(REShapeTriangle),
                   @"oval"        : @(REShapeOval) };
    });
    importKey = [[importKey stringByRemovingCharactersFromSet:NSWhitespaceCharacters]
                 lowercaseString];
    NSNumber * shapeValue = index[importKey];
    return (shapeValue ? [shapeValue unsignedLongLongValue] : REShapeUndefined);
}

REStyle remoteElementStyleFromImportKey(NSString * importKey)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        index = @{ @"border"      : @(REStyleDrawBorder),
                   @"stretchable" : @(REStyleStretchable),
                   @"gloss"       : @(REStyleApplyGloss),
                   @"gloss2"      : @(REStyleGlossStyle2),
                   @"gloss3"      : @(REStyleGlossStyle3),
                   @"gloss4"      : @(REStyleGlossStyle4) };



    });

    importKey = [[importKey stringByRemovingCharactersFromSet:NSWhitespaceCharacters]
                 lowercaseString];
    REStyle style = REStyleUndefined;
    for (NSString * key in [importKey componentsSeparatedByString:@","])
    {
        NSNumber * styleValue = index[key];
        if (styleValue) style |= [styleValue unsignedLongLongValue];
    }
    return style;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Command Types
////////////////////////////////////////////////////////////////////////////////

SystemCommandType systemCommandTypeFromImportKey(NSString * importKey)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        index = @{ @"proximity"     : @(SystemCommandToggleProximitySensor),
                   @"url"           : @(SystemCommandURLRequest),
                   @"launchscreen" : @(SystemCommandReturnToLaunchScreen),
                   @"settings"      : @(SystemCommandOpenSettings),
                   @"editor"        : @(SystemCommandOpenEditor) };
    });

    importKey = [[importKey stringByRemovingCharactersFromSet:NSWhitespaceCharacters]
                 lowercaseString];
    NSNumber * typeValue = index[importKey];
    return (typeValue ? [typeValue intValue] : -1);
}

RECommandSetType commandSetTypeFromImportKey(NSString * importKey)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        index = @{ @"dpad"      : @(RECommandSetTypeDPad),
                   @"transport" : @(RECommandSetTypeTransport),
                   @"numberpad" : @(RECommandSetTypeNumberPad),
                   @"rocker"    : @(RECommandSetTypeRocker) };
    });

    importKey = [[importKey stringByRemovingCharactersFromSet:NSWhitespaceCharacters]
                 lowercaseString];
    NSNumber * typeValue = index[importKey];
    return (typeValue ? [typeValue unsignedIntegerValue] : RECommandSetTypeUnspecified);
}
