/*

  JSONObjectKeys.h
  Remote

  Created by Jason Cardwell on 10/15/13.
  Copyright (c) 2013 Moondeer Studios. All rights reserved.

*/

// remote element types
MSEXTERN_KEY(RETypeUndefinedJSON);
MSEXTERN_KEY(RETypeRemoteJSON);
MSEXTERN_KEY(RETypeButtonGroupJSON);
MSEXTERN_KEY(RETypeButtonJSON);

MSEXTERN_KEY(REPanelLocationUnassignedJSON);
MSEXTERN_KEY(REPanelLocationTopJSON);
MSEXTERN_KEY(REPanelLocationBottomJSON);
MSEXTERN_KEY(REPanelLocationLeftJSON);
MSEXTERN_KEY(REPanelLocationRightJSON);

MSEXTERN_KEY(REPanelNoTriggerJSON);
MSEXTERN_KEY(REPanelTrigger1JSON);
MSEXTERN_KEY(REPanelTrigger2JSON);
MSEXTERN_KEY(REPanelTrigger3JSON);

// remote element options
MSEXTERN_KEY(REOptionsDefaultJSON);
MSEXTERN_KEY(RERemoteOptionTopBarHiddenJSON);
MSEXTERN_KEY(REButtonGroupOptionAutohideJSON);
MSEXTERN_KEY(REButtonGroupOptionCommandSetContainerJSON);

// remote element shapes
MSEXTERN_KEY(REShapeUndefinedJSON);
MSEXTERN_KEY(REShapeRoundedRectangleJSON);
MSEXTERN_KEY(REShapeOvalJSON);
MSEXTERN_KEY(REShapeRectangleJSON);
MSEXTERN_KEY(REShapeTriangleJSON);
MSEXTERN_KEY(REShapeDiamondJSON);

MSEXTERN_KEY(REStyleUndefinedJSON);
MSEXTERN_KEY(REStyleApplyGlossJSON);
MSEXTERN_KEY(REStyleGlossStyle1JSON);
MSEXTERN_KEY(REStyleGlossStyle2JSON);
MSEXTERN_KEY(REStyleGlossStyle3JSON);
MSEXTERN_KEY(REStyleGlossStyle4JSON);
MSEXTERN_KEY(REStyleDrawBorderJSON);
MSEXTERN_KEY(REStyleStretchableJSON);

// remote element theme override flags
MSEXTERN_KEY(REThemeNoneJSON);
MSEXTERN_KEY(REThemeNoBackgroundImageJSON);
MSEXTERN_KEY(REThemeNoBackgroundImageAlphaJSON);
MSEXTERN_KEY(REThemeNoBackgroundColorAttributeJSON);
MSEXTERN_KEY(REThemeNoBackgroundJSON);
MSEXTERN_KEY(REThemeNoBorderJSON);
MSEXTERN_KEY(REThemeNoGlossJSON);
MSEXTERN_KEY(REThemeNoStretchableJSON);
MSEXTERN_KEY(REThemeNoStyleJSON);
MSEXTERN_KEY(REThemeNoIconImageJSON);
MSEXTERN_KEY(REThemeNoIconColorAttributeJSON);
MSEXTERN_KEY(REThemeNoIconInsetsJSON);
MSEXTERN_KEY(REThemeNoIconJSON);
MSEXTERN_KEY(REThemeNoTitleForegroundColorAttributeJSON);
MSEXTERN_KEY(REThemeNoTitleBackgroundColorAttributeJSON);
MSEXTERN_KEY(REThemeNoTitleShadowColorAttributeJSON);
MSEXTERN_KEY(REThemeNoTitleStrokeColorAttributeJSON);
MSEXTERN_KEY(REThemeNoTitleColorAttributeJSON);
MSEXTERN_KEY(REThemeNoFontNameJSON);
MSEXTERN_KEY(REThemeNoFontSizeJSON);
MSEXTERN_KEY(REThemeNoFontJSON);
MSEXTERN_KEY(REThemeNoStrokeWidthJSON);
MSEXTERN_KEY(REThemeNoStrikethroughJSON);
MSEXTERN_KEY(REThemeNoUnderlineJSON);
MSEXTERN_KEY(REThemeNoLigatureJSON);
MSEXTERN_KEY(REThemeNoKernJSON);
MSEXTERN_KEY(REThemeNoParagraphStyleJSON);
MSEXTERN_KEY(REThemeNoTitleAttributesJSON);
MSEXTERN_KEY(REThemeNoTitleInsetsJSON);
MSEXTERN_KEY(REThemeNoTitleTextJSON);
MSEXTERN_KEY(REThemeNoTitleJSON);
MSEXTERN_KEY(REThemeNoContentInsetsJSON);
MSEXTERN_KEY(REThemeNoShapeJSON);
MSEXTERN_KEY(REThemeAllJSON);

// remote element roles
MSEXTERN_KEY(RERoleUndefinedJSON);

MSEXTERN_KEY(REButtonGroupRoleSelectionPanelJSON);
MSEXTERN_KEY(REButtonGroupRoleToolbarJSON);
MSEXTERN_KEY(REButtonGroupRoleDPadJSON);
MSEXTERN_KEY(REButtonGroupRoleNumberpadJSON);
MSEXTERN_KEY(REButtonGroupRoleTransportJSON);
MSEXTERN_KEY(REButtonGroupRoleRockerJSON);

MSEXTERN_KEY(REButtonRoleToolbarJSON);
MSEXTERN_KEY(REButtonRoleConnectionStatusJSON);
MSEXTERN_KEY(REButtonRoleBatteryStatusJSON);

MSEXTERN_KEY(REButtonRoleRockerTopJSON);
MSEXTERN_KEY(REButtonRoleRockerBottomJSON);

MSEXTERN_KEY(REButtonRolePanelJSON);
MSEXTERN_KEY(REButtonRoleTuckJSON);
MSEXTERN_KEY(REButtonRoleSelectionPanelJSON);

MSEXTERN_KEY(REButtonRoleDPadUpJSON);
MSEXTERN_KEY(REButtonRoleDPadDownJSON);
MSEXTERN_KEY(REButtonRoleDPadLeftJSON);
MSEXTERN_KEY(REButtonRoleDPadRightJSON);
MSEXTERN_KEY(REButtonRoleDPadCenterJSON);

MSEXTERN_KEY(REButtonRoleNumberpad1JSON);
MSEXTERN_KEY(REButtonRoleNumberpad2JSON);
MSEXTERN_KEY(REButtonRoleNumberpad3JSON);
MSEXTERN_KEY(REButtonRoleNumberpad4JSON);
MSEXTERN_KEY(REButtonRoleNumberpad5JSON);
MSEXTERN_KEY(REButtonRoleNumberpad6JSON);
MSEXTERN_KEY(REButtonRoleNumberpad7JSON);
MSEXTERN_KEY(REButtonRoleNumberpad8JSON);
MSEXTERN_KEY(REButtonRoleNumberpad9JSON);
MSEXTERN_KEY(REButtonRoleNumberpad0JSON);
MSEXTERN_KEY(REButtonRoleNumberpadAux1JSON);
MSEXTERN_KEY(REButtonRoleNumberpadAux2JSON);

MSEXTERN_KEY(REButtonRoleTransportPlayJSON);
MSEXTERN_KEY(REButtonRoleTransportStopJSON);
MSEXTERN_KEY(REButtonRoleTransportPauseJSON);
MSEXTERN_KEY(REButtonRoleTransportSkipJSON);
MSEXTERN_KEY(REButtonRoleTransportReplayJSON);
MSEXTERN_KEY(REButtonRoleTransportFFJSON);
MSEXTERN_KEY(REButtonRoleTransportRewindJSON);
MSEXTERN_KEY(REButtonRoleTransportRecordJSON);

// remote element states
MSEXTERN_KEY(REStateDefaultJSON);
MSEXTERN_KEY(REStateNormalJSON);
MSEXTERN_KEY(REStateHighlightedJSON);
MSEXTERN_KEY(REStateDisabledJSON);
MSEXTERN_KEY(REStateSelectedJSON);

// command classes
MSEXTERN_KEY(PowerCommandTypeJSON);
MSEXTERN_KEY(SendIRCommandTypeJSON);
MSEXTERN_KEY(HTTPCommandTypeJSON);
MSEXTERN_KEY(DelayCommandTypeJSON);
MSEXTERN_KEY(MacroCommandTypeJSON);
MSEXTERN_KEY(SystemCommandTypeJSON);
MSEXTERN_KEY(SwitchCommandTypeJSON);
MSEXTERN_KEY(ActivityCommandTypeJSON);

// command options
MSEXTERN_KEY(CommandOptionDefaultJSON);
MSEXTERN_KEY(CommandOptionLongPressJSON);

// system command types
MSEXTERN_KEY(SystemCommandTypeUndefinedJSON);
MSEXTERN_KEY(SystemCommandProximitySensorJSON);
MSEXTERN_KEY(SystemCommandURLRequestJSON);
MSEXTERN_KEY(SystemCommandLaunchScreenJSON);
MSEXTERN_KEY(SystemCommandOpenSettingsJSON);
MSEXTERN_KEY(SystemCommandOpenEditorJSON);

// switch command types
MSEXTERN_KEY(SwitchRemoteCommandJSON);
MSEXTERN_KEY(SwitchModeCommandJSON);

// command sets
MSEXTERN_KEY(ButtonGroupCommandSetJSON);
MSEXTERN_KEY(ButtonGroupCommandSetCollectionJSON);
MSEXTERN_KEY(CommandSetTypeJSON);
MSEXTERN_KEY(CommandSetTypeUnspecifiedJSON);
MSEXTERN_KEY(CommandSetTypeDPadJSON);
MSEXTERN_KEY(CommandSetTypeTransportJSON);
MSEXTERN_KEY(CommandSetTypeNumberpadJSON);
MSEXTERN_KEY(CommandSetTypeRockerJSON);

// remote element actions
MSEXTERN_KEY(RESingleTapActionJSON);
MSEXTERN_KEY(RELongPressActionJSON);

// control state title set attributes
MSEXTERN_KEY(REFontAttributeJSON);
MSEXTERN_KEY(REParagraphStyleAttributeJSON);
MSEXTERN_KEY(REForegroundColorAttributeJSON);
MSEXTERN_KEY(REBackgroundColorAttributeJSON);
MSEXTERN_KEY(RELigatureAttributeJSON);
MSEXTERN_KEY(REKernAttributeJSON);
MSEXTERN_KEY(REStrikethroughStyleAttributeJSON);
MSEXTERN_KEY(REUnderlineStyleAttributeJSON);
MSEXTERN_KEY(REStrokeColorAttributeJSON);
MSEXTERN_KEY(REStrokeWidthAttributeJSON);
MSEXTERN_KEY(REShadowAttributeJSON);
MSEXTERN_KEY(RETextEffectAttributeJSON);
MSEXTERN_KEY(REBaselineOffsetAttributeJSON);
MSEXTERN_KEY(REUnderlineColorAttributeJSON);
MSEXTERN_KEY(REStrikethroughColorAttributeJSON);
MSEXTERN_KEY(REObliquenessAttributeJSON);
MSEXTERN_KEY(REExpansionAttributeJSON);
MSEXTERN_KEY(RETitleTextAttributeJSON);
MSEXTERN_KEY(REFontAwesomeIconJSON);

MSEXTERN_KEY(RELineSpacingAttributeJSON);
MSEXTERN_KEY(REParagraphSpacingAttributeJSON);
MSEXTERN_KEY(RETextAlignmentAttributeJSON);
MSEXTERN_KEY(REFirstLineHeadIndentAttributeJSON);
MSEXTERN_KEY(REHeadIndentAttributeJSON);
MSEXTERN_KEY(RETailIndentAttributeJSON);
MSEXTERN_KEY(RELineBreakModeAttributeJSON);
MSEXTERN_KEY(REMinimumLineHeightAttributeJSON);
MSEXTERN_KEY(REMaximumLineHeightAttributeJSON);
MSEXTERN_KEY(RELineHeightMultipleAttributeJSON);
MSEXTERN_KEY(REParagraphSpacingBeforeAttributeJSON);
MSEXTERN_KEY(REHyphenationFactorAttributeJSON);
MSEXTERN_KEY(RETabStopsAttributeJSON);
MSEXTERN_KEY(REDefaultTabIntervalAttributeJSON);

MSEXTERN_KEY(RETextAlignmentLeftJSON);
MSEXTERN_KEY(RETextAlignmentCenterJSON);
MSEXTERN_KEY(RETextAlignmentRightJSON);
MSEXTERN_KEY(RETextAlignmentJustifiedJSON);
MSEXTERN_KEY(RETextAlignmentNaturalJSON);

MSEXTERN_KEY(RELineBreakByWordWrappingJSON);
MSEXTERN_KEY(RELineBreakByCharWrappingJSON);
MSEXTERN_KEY(RELineBreakByClippingJSON);
MSEXTERN_KEY(RELineBreakByTruncatingHeadJSON);
MSEXTERN_KEY(RELineBreakByTruncatingTailJSON);
MSEXTERN_KEY(RELineBreakByTruncatingMiddleJSON);

MSEXTERN_KEY(RETextEffectLetterPressJSON);

MSEXTERN_KEY(REUnderlineStyleNoneJSON);
MSEXTERN_KEY(REUnderlineStyleSingleJSON);
MSEXTERN_KEY(REUnderlineStyleThickJSON);
MSEXTERN_KEY(REUnderlineStyleDoubleJSON);
MSEXTERN_KEY(REUnderlinePatternSolidJSON);
MSEXTERN_KEY(REUnderlinePatternDotJSON);
MSEXTERN_KEY(REUnderlinePatternDashJSON);
MSEXTERN_KEY(REUnderlinePatternDashDotJSON);
MSEXTERN_KEY(REUnderlinePatternDashDotDotJSON);
MSEXTERN_KEY(REUnderlineByWordJSON);

