//
//  RemoteElementImportSupportFunctions.m
//  Remote
//
//  Created by Jason Cardwell on 4/30/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteElementImportSupportFunctions.h"
#import "JSONObjectKeys.h"
#import "RemoteElementKeys.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Types
////////////////////////////////////////////////////////////////////////////////

//Class remoteElementClassForImportKey(NSString * importKey) {
//  return classForREType(remoteElementTypeFromImportKey(importKey));
//}

//REType remoteElementTypeFromImportKey(NSString * importKey) {
//  static NSDictionary const * index = nil;
//  static dispatch_once_t      onceToken;
//
//  dispatch_once(&onceToken,
//                ^{
//    index = @{ RETypeRemoteJSONKey      : @(RETypeRemote),
//               RETypeButtonGroupJSONKey : @(RETypeButtonGroup),
//               RETypeButtonJSONKey      : @(RETypeButton),
//               RETypeUndefinedJSONKey   : @(RETypeUndefined) };
//  });
//
//  NSNumber * typeValue = (importKey ? index[importKey] : nil);
//
//  return (typeValue ? [typeValue unsignedShortValue] : RETypeUndefined);
//}

RERole remoteElementRoleFromImportKey(NSString * importKey) {
  static NSDictionary const * index = nil;
  static dispatch_once_t      onceToken;

  dispatch_once(&onceToken,
                ^{
    index =
      @{ RERoleUndefinedJSONKey                 : @(RERoleUndefined),

         // button group roles
         REButtonGroupRoleSelectionPanelJSONKey : @(REButtonGroupRoleSelectionPanel),
         REButtonGroupRoleToolbarJSONKey        : @(REButtonGroupRoleToolbar),
         REButtonGroupRoleDPadJSONKey           : @(REButtonGroupRoleDPad),
         REButtonGroupRoleNumberpadJSONKey      : @(REButtonGroupRoleNumberpad),
         REButtonGroupRoleTransportJSONKey      : @(REButtonGroupRoleTransport),
         REButtonGroupRoleRockerJSONKey         : @(REButtonGroupRoleRocker),

         // toolbar buttons
         REButtonRoleToolbarJSONKey             : @(REButtonRoleToolbar),
         REButtonRoleConnectionStatusJSONKey    : @(REButtonRoleConnectionStatus),
         REButtonRoleBatteryStatusJSONKey       : @(REButtonRoleBatteryStatus),

         // picker label buttons
         REButtonRoleRockerTopJSONKey      : @(REButtonRoleRockerTop),
         REButtonRoleRockerBottomJSONKey   : @(REButtonRoleRockerBottom),

         // panel buttons
         REButtonRolePanelJSONKey               : @(REButtonRolePanel),
         REButtonRoleTuckJSONKey                : @(REButtonRoleTuck),
         REButtonRoleSelectionPanelJSONKey      : @(REButtonRoleSelectionPanel),

         // dpad buttons
         REButtonRoleDPadUpJSONKey              : @(REButtonRoleDPadUp),
         REButtonRoleDPadDownJSONKey            : @(REButtonRoleDPadDown),
         REButtonRoleDPadLeftJSONKey            : @(REButtonRoleDPadLeft),
         REButtonRoleDPadRightJSONKey           : @(REButtonRoleDPadRight),
         REButtonRoleDPadCenterJSONKey          : @(REButtonRoleDPadCenter),


         // numberpad buttons
         REButtonRoleNumberpad1JSONKey          : @(REButtonRoleNumberpad1),
         REButtonRoleNumberpad2JSONKey          : @(REButtonRoleNumberpad2),
         REButtonRoleNumberpad3JSONKey          : @(REButtonRoleNumberpad3),
         REButtonRoleNumberpad4JSONKey          : @(REButtonRoleNumberpad4),
         REButtonRoleNumberpad5JSONKey          : @(REButtonRoleNumberpad5),
         REButtonRoleNumberpad6JSONKey          : @(REButtonRoleNumberpad6),
         REButtonRoleNumberpad7JSONKey          : @(REButtonRoleNumberpad7),
         REButtonRoleNumberpad8JSONKey          : @(REButtonRoleNumberpad8),
         REButtonRoleNumberpad9JSONKey          : @(REButtonRoleNumberpad9),
         REButtonRoleNumberpad0JSONKey          : @(REButtonRoleNumberpad0),
         REButtonRoleNumberpadAux1JSONKey       : @(REButtonRoleNumberpadAux1),
         REButtonRoleNumberpadAux2JSONKey       : @(REButtonRoleNumberpadAux2),

         // transport buttons
         REButtonRoleTransportPlayJSONKey       : @(REButtonRoleTransportPlay),
         REButtonRoleTransportStopJSONKey       : @(REButtonRoleTransportStop),
         REButtonRoleTransportPauseJSONKey      : @(REButtonRoleTransportPause),
         REButtonRoleTransportSkipJSONKey       : @(REButtonRoleTransportSkip),
         REButtonRoleTransportReplayJSONKey     : @(REButtonRoleTransportReplay),
         REButtonRoleTransportFFJSONKey         : @(REButtonRoleTransportFF),
         REButtonRoleTransportRewindJSONKey     : @(REButtonRoleTransportRewind),
         REButtonRoleTransportRecordJSONKey     : @(REButtonRoleTransportRecord) };

  });


  NSNumber * roleValue = (importKey ? index[importKey] : nil);

  return (roleValue ? [roleValue unsignedShortValue] : RERoleUndefined);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element State
////////////////////////////////////////////////////////////////////////////////

//REState buttonStateFromImportKey(NSString * importKey) {
//
//  // TODO: This should be updated to allow for state other than default
//  return REStateDefault;
//}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Shape, Style, & Theme
////////////////////////////////////////////////////////////////////////////////

//REShape remoteElementShapeFromImportKey(NSString * importKey) {
//  static NSDictionary const * index = nil;
//  static dispatch_once_t      onceToken;
//
//  dispatch_once(&onceToken,
//                ^{
//    index = @{ REShapeUndefinedJSONKey        : @(REShapeUndefined),
//               REShapeRoundedRectangleJSONKey : @(REShapeRoundedRectangle),
//               REShapeRectangleJSONKey        : @(REShapeRectangle),
//               REShapeDiamondJSONKey          : @(REShapeDiamond),
//               REShapeTriangleJSONKey         : @(REShapeTriangle),
//               REShapeOvalJSONKey             : @(REShapeOval) };
//  });
//
//  NSNumber * shapeValue = index[importKey];
//
//  return (shapeValue ? [shapeValue unsignedShortValue] : REShapeUndefined);
//}

//REStyle remoteElementStyleFromImportKey(NSString * importKey) {
//  static NSDictionary const * index = nil;
//  static dispatch_once_t      onceToken;
//
//  dispatch_once(&onceToken,
//                ^{
//    index = @{ REStyleUndefinedJSONKey   : @(REStyleUndefined),
//               REStyleDrawBorderJSONKey  : @(REStyleDrawBorder),
//               REStyleStretchableJSONKey : @(REStyleStretchable),
//               REStyleApplyGlossJSONKey  : @(REStyleApplyGloss),
//               REStyleGlossStyle1JSONKey : @(REStyleGlossStyle1),
//               REStyleGlossStyle2JSONKey : @(REStyleGlossStyle2),
//               REStyleGlossStyle3JSONKey : @(REStyleGlossStyle3),
//               REStyleGlossStyle4JSONKey : @(REStyleGlossStyle4) };
//  });
//
//  REStyle style = REStyleUndefined;
//
//  for (NSString * key in [importKey componentsSeparatedByString:@" "]) {
//    NSNumber * styleValue = index[key];
//
//    if (styleValue) style |= [styleValue unsignedShortValue];
//  }
//
//  return style;
//}

//REThemeOverrideFlags remoteElementThemeFlagsFromImportKey(NSString * importKey) {
//  static NSDictionary const * index = nil;
//  static dispatch_once_t      onceToken;
//
//  dispatch_once(&onceToken, ^{
//    index = @{ REThemeNoneJSONKey                            : @(REThemeNone),
//               REThemeNoBackgroundImageJSONKey               : @(REThemeNoBackgroundImage),
//               REThemeNoBackgroundImageAlphaJSONKey          : @(REThemeNoBackgroundImageAlpha),
//               REThemeNoBackgroundColorAttributeJSONKey      : @(REThemeNoBackgroundColorAttribute),
//               REThemeNoBorderJSONKey                        : @(REThemeNoBorder),
//               REThemeNoGlossJSONKey                         : @(REThemeNoGloss),
//               REThemeNoStretchableJSONKey                   : @(REThemeNoStretchable),
//               REThemeNoIconImageJSONKey                     : @(REThemeNoIconImage),
//               REThemeNoIconColorAttributeJSONKey            : @(REThemeNoIconColorAttribute),
//               REThemeNoIconInsetsJSONKey                    : @(REThemeNoIconInsets),
//               REThemeNoTitleForegroundColorAttributeJSONKey : @(REThemeNoTitleForegroundColorAttribute),
//               REThemeNoTitleBackgroundColorAttributeJSONKey : @(REThemeNoTitleBackgroundColorAttribute),
//               REThemeNoTitleShadowColorAttributeJSONKey     : @(REThemeNoTitleShadowColorAttribute),
//               REThemeNoTitleStrokeColorAttributeJSONKey     : @(REThemeNoTitleStrokeColorAttribute),
//               REThemeNoFontNameJSONKey                      : @(REThemeNoFontName),
//               REThemeNoFontSizeJSONKey                      : @(REThemeNoFontSize),
//               REThemeNoStrokeWidthJSONKey                   : @(REThemeNoStrokeWidth),
//               REThemeNoStrikethroughJSONKey                 : @(REThemeNoStrikethrough),
//               REThemeNoUnderlineJSONKey                     : @(REThemeNoUnderline),
//               REThemeNoLigatureJSONKey                      : @(REThemeNoLigature),
//               REThemeNoKernJSONKey                          : @(REThemeNoKern),
//               REThemeNoParagraphStyleJSONKey                : @(REThemeNoParagraphStyle),
//               REThemeNoTitleInsetsJSONKey                   : @(REThemeNoTitleInsets),
//               REThemeNoTitleTextJSONKey                     : @(REThemeNoTitleText),
//               REThemeNoContentInsetsJSONKey                 : @(REThemeNoContentInsets),
//               REThemeNoShapeJSONKey                         : @(REThemeNoShape),
//               REThemeAllJSONKey                             : @(REThemeAll) };
//  });
//
//  REThemeOverrideFlags flags = REThemeNone;
//
//  if (importKey) {
//
//    BOOL invert = NO;
//
//    if ([importKey[0] isEqualToNumber:@('-')]) {
//      invert    = YES;
//      importKey = [importKey substringFromIndex:1];
//    }
//
//    NSMutableSet * flagsToSet  = [[[index allKeys] set] mutableCopy];
//    NSSet        * parsedFlags = [[importKey componentsSeparatedByString:@" "] set];
//
//    if (invert) [flagsToSet minusSet:parsedFlags];
//    else [flagsToSet intersectSet:parsedFlags];
//
//
//    if ([parsedFlags count]) {
//      NSMutableArray * flagValues = [[index objectsForKeys:[flagsToSet allObjects]
//                                            notFoundMarker:NullObject] mutableCopy];
//
//      [flagValues compact];
//
//      for (NSNumber * f  in flagValues)
//        flags |= [f unsignedShortValue];
//    }
//  }
//
//  return flags;
//}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote
////////////////////////////////////////////////////////////////////////////////

//REPanelAssignment panelAssignmentFromImportKey(NSString * importKey) {
//  static NSDictionary const * locationIndex, * triggerIndex;
//  static dispatch_once_t      onceToken;
//
//  dispatch_once(&onceToken,
//                ^{
//    locationIndex = @{ REPanelLocationTopJSONKey    : @(REPanelLocationTop),
//                       REPanelLocationBottomJSONKey : @(REPanelLocationBottom),
//                       REPanelLocationLeftJSONKey   : @(REPanelLocationLeft),
//                       REPanelLocationRightJSONKey  : @(REPanelLocationRight) };
//
//    triggerIndex = @{ REPanelTrigger1JSONKey : @(REPanelTrigger1),
//                      REPanelTrigger2JSONKey : @(REPanelTrigger2),
//                      REPanelTrigger3JSONKey : @(REPanelTrigger3) };
//  });
//  NSString        * locationString = [importKey substringToIndex:[importKey length] - 1];
//  NSString        * triggerString  = [importKey substringFromIndex:[importKey length] - 1];
//  REPanelLocation   location       = [locationIndex[locationString] unsignedShortValue];
//  REPanelTrigger    trigger        = [triggerIndex[triggerString] unsignedShortValue];
//  REPanelAssignment assignment     = location | trigger;
//
//  return assignment;
//}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////

//SystemCommandType systemCommandTypeFromImportKey(NSString * importKey) {
//  static NSDictionary const * index = nil;
//  static dispatch_once_t      onceToken;
//
//  dispatch_once(&onceToken,
//                ^{
//    index =
//      @{ SystemCommandTypeUndefinedJSONKey   : @(SystemCommandTypeUndefined),
//         SystemCommandProximitySensorJSONKey : @(SystemCommandProximitySensor),
//         SystemCommandURLRequestJSONKey      : @(SystemCommandURLRequest),
//         SystemCommandLaunchScreenJSONKey    : @(SystemCommandLaunchScreen),
//         SystemCommandOpenSettingsJSONKey    : @(SystemCommandOpenSettings),
//         SystemCommandOpenEditorJSONKey      : @(SystemCommandOpenEditor) };
//  });
//
//  NSNumber * typeValue = (importKey ? index[importKey] : nil);
//
//  return (typeValue ? [typeValue unsignedShortValue] : SystemCommandTypeUndefined);
//}
//
//SwitchCommandType switchCommandTypeFromImportKey(NSString * importKey) {
//  static NSDictionary const * index;
//  static dispatch_once_t      onceToken;
//
//  dispatch_once(&onceToken,
//                ^{
//    index = @{ SwitchRemoteCommandJSONKey : @(SwitchRemoteCommand),
//               SwitchModeCommandJSONKey   : @(SwitchModeCommand) };
//  });
//
//  NSNumber * result = (importKey ? index[importKey] : nil);
//
//  return (result ? result.unsignedShortValue : SwitchUndefinedCommand);
//}

//CommandSetType commandSetTypeFromImportKey(NSString * importKey) {
//  static NSDictionary const * index = nil;
//  static dispatch_once_t      onceToken;
//
//  dispatch_once(&onceToken,
//                ^{
//    index = @{ CommandSetTypeUnspecifiedJSONKey : @(CommandSetTypeUnspecified),
//               CommandSetTypeDPadJSONKey        : @(CommandSetTypeDPad),
//               CommandSetTypeTransportJSONKey   : @(CommandSetTypeTransport),
//               CommandSetTypeNumberpadJSONKey   : @(CommandSetTypeNumberpad),
//               CommandSetTypeRockerJSONKey      : @(CommandSetTypeRocker) };
//  });
//
//  NSNumber * typeValue = (importKey ? index[importKey] : nil);
//
//  return (typeValue ? [typeValue unsignedShortValue] : CommandSetTypeUnspecified);
//}

Class commandClassForImportKey(NSString * importKey) {
  static NSDictionary const * index;
  static dispatch_once_t      onceToken;

  dispatch_once(&onceToken,
                ^{
    index = @{ PowerCommandTypeJSONKey    : NSClassFromString(@"PowerCommand"),
               SendIRCommandTypeJSONKey   : NSClassFromString(@"SendIRCommand"),
               HTTPCommandTypeJSONKey     : NSClassFromString(@"HTTPCommand"),
               DelayCommandTypeJSONKey    : NSClassFromString(@"DelayCommand"),
               MacroCommandTypeJSONKey    : NSClassFromString(@"MacroCommand"),
               SystemCommandTypeJSONKey   : NSClassFromString(@"SystemCommand"),
               SwitchCommandTypeJSONKey   : NSClassFromString(@"SwitchCommand"),
               ActivityCommandTypeJSONKey : NSClassFromString(@"ActivityCommand") };
  });

  return (importKey ? index[importKey] : NULL);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Control state sets
////////////////////////////////////////////////////////////////////////////////

NSString *titleAttributesPropertyForJSONKey(NSString * key) {
  static NSDictionary const * index = nil;
  static dispatch_once_t      onceToken;

  dispatch_once(&onceToken, ^{
    index = @{ REFontAttributeJSONKey                   : @"font",
               REForegroundColorAttributeJSONKey        : @"foregroundColor",
               REBackgroundColorAttributeJSONKey        : @"backgroundColor",
               RELigatureAttributeJSONKey               : @"ligature",
               REKernAttributeJSONKey                   : @"kern",
               REStrikethroughStyleAttributeJSONKey     : @"strikethroughStyle",
               REUnderlineStyleAttributeJSONKey         : @"underlineStyle",
               REStrokeColorAttributeJSONKey            : @"strokeColor",
               REStrokeWidthAttributeJSONKey            : @"strokeWidth",
               RETextEffectAttributeJSONKey             : @"textEffect",
               REBaselineOffsetAttributeJSONKey         : @"baselineOffset",
               REUnderlineColorAttributeJSONKey         : @"underlineColor",
               REStrikethroughColorAttributeJSONKey     : @"strikethroughColor",
               REObliquenessAttributeJSONKey            : @"obliqueness",
               REExpansionAttributeJSONKey              : @"expansion",
               REShadowAttributeJSONKey                 : @"shadow",
               RETitleTextAttributeJSONKey              : @"titleText",
               REFontAwesomeIconJSONKey                 : @"iconName",
               RELineSpacingAttributeJSONKey            : @"lineSpacing",
               REParagraphSpacingAttributeJSONKey       : @"paragraphSpacing",
               RETextAlignmentAttributeJSONKey          : @"textAlignment",
               REFirstLineHeadIndentAttributeJSONKey    : @"firstLineHeadIndent",
               REHeadIndentAttributeJSONKey             : @"headIndent",
               RETailIndentAttributeJSONKey             : @"tailIndent",
               RELineBreakModeAttributeJSONKey          : @"lineBreakMode",
               REMinimumLineHeightAttributeJSONKey      : @"minimumLineHeight",
               REMaximumLineHeightAttributeJSONKey      : @"maximumLineHeight",
               RELineHeightMultipleAttributeJSONKey     : @"lineHeightMultiple",
               REParagraphSpacingBeforeAttributeJSONKey : @"paragraphSpacingBefore",
               REHyphenationFactorAttributeJSONKey      : @"hyphenationFactor",
               RETabStopsAttributeJSONKey               : @"tabStops",
               REDefaultTabIntervalAttributeJSONKey     : @"defaultTabInterval" };
  });

  return (key ? index[key] : nil);
}

NSString *titleSetAttributeKeyForJSONKey(NSString * key) {
  static NSDictionary const * index = nil;
  static dispatch_once_t      onceToken;

  dispatch_once(&onceToken, ^{
    index = @{ REFontAttributeJSONKey                   : REFontAttributeKey,
               REParagraphStyleAttributeJSONKey         : REParagraphStyleAttributeKey,
               REForegroundColorAttributeJSONKey        : REForegroundColorAttributeKey,
               REBackgroundColorAttributeJSONKey        : REBackgroundColorAttributeKey,
               RELigatureAttributeJSONKey               : RELigatureAttributeKey,
               REKernAttributeJSONKey                   : REKernAttributeKey,
               REStrikethroughStyleAttributeJSONKey     : REStrikethroughStyleAttributeKey,
               REUnderlineStyleAttributeJSONKey         : REUnderlineStyleAttributeKey,
               REStrokeColorAttributeJSONKey            : REStrokeColorAttributeKey,
               REStrokeWidthAttributeJSONKey            : REStrokeWidthAttributeKey,
               RETextEffectAttributeJSONKey             : RETextEffectAttributeKey,
               REBaselineOffsetAttributeJSONKey         : REBaselineOffsetAttributeKey,
               REUnderlineColorAttributeJSONKey         : REUnderlineColorAttributeKey,
               REStrikethroughColorAttributeJSONKey     : REStrikethroughColorAttributeKey,
               REObliquenessAttributeJSONKey            : REObliquenessAttributeKey,
               REExpansionAttributeJSONKey              : REExpansionAttributeKey,
               REShadowAttributeJSONKey                 : REShadowAttributeKey,
               RETitleTextAttributeJSONKey              : RETitleTextAttributeKey,
               REFontAwesomeIconJSONKey                 : RETitleTextAttributeKey,

               RELineSpacingAttributeJSONKey            : RELineSpacingAttributeKey,
               REParagraphSpacingAttributeJSONKey       : REParagraphSpacingAttributeKey,
               RETextAlignmentAttributeJSONKey          : RETextAlignmentAttributeKey,
               REFirstLineHeadIndentAttributeJSONKey    : REFirstLineHeadIndentAttributeKey,
               REHeadIndentAttributeJSONKey             : REHeadIndentAttributeKey,
               RETailIndentAttributeJSONKey             : RETailIndentAttributeKey,
               RELineBreakModeAttributeJSONKey          : RELineBreakModeAttributeKey,
               REMinimumLineHeightAttributeJSONKey      : REMinimumLineHeightAttributeKey,
               REMaximumLineHeightAttributeJSONKey      : REMaximumLineHeightAttributeKey,
               RELineHeightMultipleAttributeJSONKey     : RELineHeightMultipleAttributeKey,
               REParagraphSpacingBeforeAttributeJSONKey : REParagraphSpacingBeforeAttributeKey,
               REHyphenationFactorAttributeJSONKey      : REHyphenationFactorAttributeKey,
               RETabStopsAttributeJSONKey               : RETabStopsAttributeKey,
               REDefaultTabIntervalAttributeJSONKey     : REDefaultTabIntervalAttributeKey };
  });

  return index[key];
}

NSTextAlignment textAlignmentForJSONKey(NSString * key) {
  static NSDictionary const * index = nil;
  static dispatch_once_t      onceToken;

  dispatch_once(&onceToken, ^{
    index = @{ RETextAlignmentLeftJSONKey : @0,
               RETextAlignmentCenterJSONKey : @1,
               RETextAlignmentRightJSONKey : @2,
               RETextAlignmentJustifiedJSONKey : @3,
               RETextAlignmentNaturalJSONKey : @4 };
  });

  id value = key ? index[key] : nil;

  return (value ? IntegerValue(value) : NSTextAlignmentNatural);

}

NSLineBreakMode lineBreakModeForJSONKey(NSString * key) {
  static NSDictionary const * index = nil;
  static dispatch_once_t      onceToken;

  dispatch_once(&onceToken, ^{
    index = @{ RELineBreakByWordWrappingJSONKey : @0,
               RELineBreakByCharWrappingJSONKey : @1,
               RELineBreakByClippingJSONKey : @2,
               RELineBreakByTruncatingHeadJSONKey : @3,
               RELineBreakByTruncatingTailJSONKey : @4,
               RELineBreakByTruncatingMiddleJSONKey : @5 };
  });

  id value = index[key];

  return (value ? IntegerValue(value) : (NSLineBreakMode)NSTextAlignmentNatural);
}

NSUnderlineStyle underlineStrikethroughStyleForJSONKey(NSString * key) {
  static NSDictionary const * index = nil;
  static dispatch_once_t      onceToken;

  dispatch_once(&onceToken, ^{
    index = @{ REUnderlineStyleNoneJSONKey         : @0x00,
               REUnderlineStyleSingleJSONKey       : @0x01,
               REUnderlineStyleThickJSONKey        : @0x02,
               REUnderlineStyleDoubleJSONKey       : @0x09,
               REUnderlinePatternSolidJSONKey      : @0x0000,
               REUnderlinePatternDotJSONKey        : @0x0100,
               REUnderlinePatternDashJSONKey       : @0x0200,
               REUnderlinePatternDashDotJSONKey    : @0x0300,
               REUnderlinePatternDashDotDotJSONKey : @0x0400,
               REUnderlineByWordJSONKey            : @0x8000 };
  });

  NSArray * components = [key componentsSeparatedByString:@"-"];

  NSUnderlineStyle style = NSUnderlineStyleNone;

  for (NSString * component in components)
    if ([index hasKey:component]) style |= IntegerValue(index[component]);

  return style;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utility functions
////////////////////////////////////////////////////////////////////////////////

UIColor *colorFromImportValue(id importValue) {
  if (!importValue) return nil;
  else if ([importValue isKindOfClass:[UIColor class]]) return importValue;

  if (!isStringKind(importValue)) return nil;

  UIColor * color = [UIColor colorWithName:importValue];

  if (!color && [importValue hasSubstring:@"@.*%"]) {
    NSArray * baseAndAlpha = [importValue componentsSeparatedByString:@"@"];

    if ([baseAndAlpha count] != 2) return nil;

    NSString * base    = baseAndAlpha[0];
    NSString * percent = [baseAndAlpha[1] substringToIndex:[baseAndAlpha[1] length] - 1];

    UIColor * baseColor = [UIColor colorWithName:base];

    if (!baseColor) return nil;

    color = [baseColor colorWithAlphaComponent:[percent floatValue] / 100.0f];
  } else if (!color && [importValue hasPrefix:@"#"]) {
    color = [UIColor colorWithRGBAHexString:importValue];
  } else if (!color) {
    NSArray * components = [importValue componentsSeparatedByString:@" "];

    if ([components count] != 4) return nil;

    color = [UIColor colorWithRed:[(NSString *)components[0] floatValue]
                            green:[(NSString *)components[1] floatValue]
                             blue:[(NSString *)components[2] floatValue]
                            alpha:[(NSString *)components[3] floatValue]];
  }

  return color;
}
