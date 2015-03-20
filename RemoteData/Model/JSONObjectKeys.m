/*
 *
 * JSONObjectKeys.m
 * Remote
 *
 * Created by Jason Cardwell on 10/15/13.
 * Copyright (c) 2013 Moondeer Studios. All rights reserved.
 *
 */

#import "JSONObjectKeys.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark Remote element types
 ////////////////////////////////////////////////////////////////////////////////
 
MSSTRING_CONST   RETypeUndefinedJSONKey   = @"undefined";
MSSTRING_CONST   RETypeRemoteJSONKey      = @"remote";
MSSTRING_CONST   RETypeButtonGroupJSONKey = @"button-group";
MSSTRING_CONST   RETypeButtonJSONKey      = @"button";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Remote element subtypes
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   REPanelLocationUnassignedJSONKey = @"unassigned";
MSSTRING_CONST   REPanelLocationTopJSONKey        = @"top";
MSSTRING_CONST   REPanelLocationBottomJSONKey     = @"bottom";
MSSTRING_CONST   REPanelLocationLeftJSONKey       = @"left";
MSSTRING_CONST   REPanelLocationRightJSONKey      = @"right";

MSSTRING_CONST   REPanelNoTriggerJSONKey = @"none";
MSSTRING_CONST   REPanelTrigger1JSONKey  = @"1";
MSSTRING_CONST   REPanelTrigger2JSONKey  = @"2";
MSSTRING_CONST   REPanelTrigger3JSONKey  = @"3";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Remote element options
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   REOptionsDefaultJSONKey                       = @"default";
MSSTRING_CONST   RERemoteOptionTopBarHiddenJSONKey             = @"top-bar-hidden";
MSSTRING_CONST   REButtonGroupOptionAutohideJSONKey            = @"autohide";
MSSTRING_CONST   REButtonGroupOptionCommandSetContainerJSONKey = @"command-set-container";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Remote element shapes
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   REShapeUndefinedJSONKey        = @"undefined";
MSSTRING_CONST   REShapeRoundedRectangleJSONKey = @"rounded-rectangle";
MSSTRING_CONST   REShapeOvalJSONKey             = @"oval";
MSSTRING_CONST   REShapeRectangleJSONKey        = @"rectangle";
MSSTRING_CONST   REShapeTriangleJSONKey         = @"triangle";
MSSTRING_CONST   REShapeDiamondJSONKey          = @"diamond";

MSSTRING_CONST   REStyleUndefinedJSONKey   = @"undefined";
MSSTRING_CONST   REStyleApplyGlossJSONKey  = @"gloss";
MSSTRING_CONST   REStyleGlossStyle1JSONKey = @"gloss1";
MSSTRING_CONST   REStyleGlossStyle2JSONKey = @"gloss2";
MSSTRING_CONST   REStyleGlossStyle3JSONKey = @"gloss3";
MSSTRING_CONST   REStyleGlossStyle4JSONKey = @"gloss4";
MSSTRING_CONST   REStyleDrawBorderJSONKey  = @"border";
MSSTRING_CONST   REStyleStretchableJSONKey = @"stretchable";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Remote element theme override flags
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   REThemeNoneJSONKey = @"none";

MSSTRING_CONST   REThemeNoBackgroundImageJSONKey          = @"background-image";
MSSTRING_CONST   REThemeNoBackgroundImageAlphaJSONKey     = @"background-image-alpha";
MSSTRING_CONST   REThemeNoBackgroundColorAttributeJSONKey = @"background-color";
MSSTRING_CONST   REThemeNoBackgroundJSONKey               = @"background";

MSSTRING_CONST   REThemeNoBorderJSONKey      = @"border";
MSSTRING_CONST   REThemeNoGlossJSONKey       = @"gloss";
MSSTRING_CONST   REThemeNoStretchableJSONKey = @"stretchable";
MSSTRING_CONST   REThemeNoStyleJSONKey       = @"style";

MSSTRING_CONST   REThemeNoIconImageJSONKey          = @"icon-image";
MSSTRING_CONST   REThemeNoIconColorAttributeJSONKey = @"icon-color";
MSSTRING_CONST   REThemeNoIconInsetsJSONKey         = @"icon-insets";
MSSTRING_CONST   REThemeNoIconJSONKey               = @"icon";

MSSTRING_CONST   REThemeNoTitleForegroundColorAttributeJSONKey = @"title-foreground-color";
MSSTRING_CONST   REThemeNoTitleBackgroundColorAttributeJSONKey = @"title-background-color";
MSSTRING_CONST   REThemeNoTitleShadowColorAttributeJSONKey     = @"title-shadow-color";
MSSTRING_CONST   REThemeNoTitleStrokeColorAttributeJSONKey     = @"title-stroke-color";
MSSTRING_CONST   REThemeNoTitleColorAttributeJSONKey           = @"title-color";

MSSTRING_CONST   REThemeNoFontNameJSONKey             = @"font-name";
MSSTRING_CONST   REThemeNoFontSizeJSONKey             = @"font-size";
MSSTRING_CONST   REThemeNoFontJSONKey                 = @"font";
MSSTRING_CONST   REThemeNoStrokeWidthJSONKey          = @"stroke-width";
MSSTRING_CONST   REThemeNoStrikethroughJSONKey        = @"strikethrough";
MSSTRING_CONST   REThemeNoUnderlineJSONKey            = @"underline";
MSSTRING_CONST   REThemeNoLigatureJSONKey             = @"ligature";
MSSTRING_CONST   REThemeNoKernJSONKey                 = @"kern";
MSSTRING_CONST   REThemeNoParagraphStyleJSONKey       = @"paragraph-style";
MSSTRING_CONST   REThemeNoTitleAttributesJSONKey      = @"title-attributes";
MSSTRING_CONST   REThemeNoTitleInsetsJSONKey          = @"title-insets";
MSSTRING_CONST   REThemeNoTitleTextJSONKey            = @"title-text";
MSSTRING_CONST   REThemeNoTitleJSONKey                = @"title";

MSSTRING_CONST   REThemeNoContentInsetsJSONKey = @"content-insets";
MSSTRING_CONST   REThemeNoShapeJSONKey         = @"shape";

MSSTRING_CONST   REThemeAllJSONKey = @"all";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Remote element roles
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   RERoleUndefinedJSONKey = @"undefined";

MSSTRING_CONST   REButtonGroupRoleSelectionPanelJSONKey = @"selection-panel";
MSSTRING_CONST   REButtonGroupRoleToolbarJSONKey        = @"toolbar";
MSSTRING_CONST   REButtonGroupRoleDPadJSONKey           = @"dpad";
MSSTRING_CONST   REButtonGroupRoleNumberpadJSONKey      = @"numberpad";
MSSTRING_CONST   REButtonGroupRoleTransportJSONKey      = @"transport";
MSSTRING_CONST   REButtonGroupRoleRockerJSONKey         = @"rocker";

MSSTRING_CONST   REButtonRoleToolbarJSONKey          = @"toolbar";
MSSTRING_CONST   REButtonRoleConnectionStatusJSONKey = @"connection-status";
MSSTRING_CONST   REButtonRoleBatteryStatusJSONKey    = @"battery-status";

MSSTRING_CONST   REButtonRoleRockerTopJSONKey    = @"top";
MSSTRING_CONST   REButtonRoleRockerBottomJSONKey = @"bottom";

MSSTRING_CONST   REButtonRolePanelJSONKey          = @"panel";
MSSTRING_CONST   REButtonRoleTuckJSONKey           = @"tuck";
MSSTRING_CONST   REButtonRoleSelectionPanelJSONKey = @"selection-panel";

MSSTRING_CONST   REButtonRoleDPadUpJSONKey     = @"up";
MSSTRING_CONST   REButtonRoleDPadDownJSONKey   = @"down";
MSSTRING_CONST   REButtonRoleDPadLeftJSONKey   = @"left";
MSSTRING_CONST   REButtonRoleDPadRightJSONKey  = @"right";
MSSTRING_CONST   REButtonRoleDPadCenterJSONKey = @"center";

MSSTRING_CONST   REButtonRoleNumberpad1JSONKey    = @"one";
MSSTRING_CONST   REButtonRoleNumberpad2JSONKey    = @"two";
MSSTRING_CONST   REButtonRoleNumberpad3JSONKey    = @"three";
MSSTRING_CONST   REButtonRoleNumberpad4JSONKey    = @"four";
MSSTRING_CONST   REButtonRoleNumberpad5JSONKey    = @"five";
MSSTRING_CONST   REButtonRoleNumberpad6JSONKey    = @"six";
MSSTRING_CONST   REButtonRoleNumberpad7JSONKey    = @"seven";
MSSTRING_CONST   REButtonRoleNumberpad8JSONKey    = @"eight";
MSSTRING_CONST   REButtonRoleNumberpad9JSONKey    = @"nine";
MSSTRING_CONST   REButtonRoleNumberpad0JSONKey    = @"zero";
MSSTRING_CONST   REButtonRoleNumberpadAux1JSONKey = @"aux1";
MSSTRING_CONST   REButtonRoleNumberpadAux2JSONKey = @"aux2";

MSSTRING_CONST   REButtonRoleTransportPlayJSONKey   = @"play";
MSSTRING_CONST   REButtonRoleTransportStopJSONKey   = @"stop";
MSSTRING_CONST   REButtonRoleTransportPauseJSONKey  = @"pause";
MSSTRING_CONST   REButtonRoleTransportSkipJSONKey   = @"skip";
MSSTRING_CONST   REButtonRoleTransportReplayJSONKey = @"replay";
MSSTRING_CONST   REButtonRoleTransportFFJSONKey     = @"fast-forward";
MSSTRING_CONST   REButtonRoleTransportRewindJSONKey = @"rewind";
MSSTRING_CONST   REButtonRoleTransportRecordJSONKey = @"record";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Remote element states
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   REStateDefaultJSONKey     = @"default";
MSSTRING_CONST   REStateNormalJSONKey      = @"normal";
MSSTRING_CONST   REStateHighlightedJSONKey = @"highlighted";
MSSTRING_CONST   REStateDisabledJSONKey    = @"disabled";
MSSTRING_CONST   REStateSelectedJSONKey    = @"selected";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Command classes
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   PowerCommandTypeJSONKey    = @"power";
MSSTRING_CONST   SendIRCommandTypeJSONKey   = @"sendir";
MSSTRING_CONST   HTTPCommandTypeJSONKey     = @"http";
MSSTRING_CONST   DelayCommandTypeJSONKey    = @"delay";
MSSTRING_CONST   MacroCommandTypeJSONKey    = @"macro";
MSSTRING_CONST   SystemCommandTypeJSONKey   = @"system";
MSSTRING_CONST   SwitchCommandTypeJSONKey   = @"switch";
MSSTRING_CONST   ActivityCommandTypeJSONKey = @"activity";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Command options
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   CommandOptionDefaultJSONKey   = @"default";
MSSTRING_CONST   CommandOptionLongPressJSONKey = @"long-press";


////////////////////////////////////////////////////////////////////////////////
#pragma mark System command types
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   SystemCommandTypeUndefinedJSONKey   = @"undefined";
MSSTRING_CONST   SystemCommandProximitySensorJSONKey = @"proximity-sensor";
MSSTRING_CONST   SystemCommandURLRequestJSONKey      = @"url-request";
MSSTRING_CONST   SystemCommandLaunchScreenJSONKey    = @"return-to-launch-screen";
MSSTRING_CONST   SystemCommandOpenSettingsJSONKey    = @"open-settings";
MSSTRING_CONST   SystemCommandOpenEditorJSONKey      = @"open-editor";


////////////////////////////////////////////////////////////////////////////////
#pragma mark Switch command types
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   SwitchRemoteCommandJSONKey = @"remote";
MSSTRING_CONST   SwitchModeCommandJSONKey   = @"mode";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Command sets
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   ButtonGroupCommandSetJSONKey           = @"command-set";
MSSTRING_CONST   ButtonGroupCommandSetCollectionJSONKey = @"command-set-collection";
MSSTRING_CONST   CommandSetTypeJSONKey                  = @"type";
MSSTRING_CONST   CommandSetTypeUnspecifiedJSONKey       = @"undefined";
MSSTRING_CONST   CommandSetTypeDPadJSONKey              = @"dpad";
MSSTRING_CONST   CommandSetTypeTransportJSONKey         = @"transport";
MSSTRING_CONST   CommandSetTypeNumberpadJSONKey         = @"numberpad";
MSSTRING_CONST   CommandSetTypeRockerJSONKey            = @"rocker";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Remote element actions
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   RESingleTapActionJSONKey = @"tap";
MSSTRING_CONST   RELongPressActionJSONKey = @"long-press";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Control state title set attributes
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   REFontAttributeJSONKey               = @"font";
MSSTRING_CONST   REParagraphStyleAttributeJSONKey     = @"paragraph-style";
MSSTRING_CONST   REForegroundColorAttributeJSONKey    = @"foreground-color";
MSSTRING_CONST   REBackgroundColorAttributeJSONKey    = @"background-color";
MSSTRING_CONST   RELigatureAttributeJSONKey           = @"ligature";
MSSTRING_CONST   REKernAttributeJSONKey               = @"kern";
MSSTRING_CONST   REStrikethroughStyleAttributeJSONKey = @"strikethrough-style";
MSSTRING_CONST   REUnderlineStyleAttributeJSONKey     = @"underline-style";
MSSTRING_CONST   REStrokeColorAttributeJSONKey        = @"stroke-color";
MSSTRING_CONST   REStrokeWidthAttributeJSONKey        = @"stroke-width";
MSSTRING_CONST   RETextEffectAttributeJSONKey         = @"text-effect";
MSSTRING_CONST   REBaselineOffsetAttributeJSONKey     = @"baseline-offset";
MSSTRING_CONST   REUnderlineColorAttributeJSONKey     = @"underline-color";
MSSTRING_CONST   REStrikethroughColorAttributeJSONKey = @"strikethrough-color";
MSSTRING_CONST   REObliquenessAttributeJSONKey        = @"obliqueness";
MSSTRING_CONST   REExpansionAttributeJSONKey          = @"expansion";
MSSTRING_CONST   REShadowAttributeJSONKey             = @"shadow";
MSSTRING_CONST   RETitleTextAttributeJSONKey          = @"text";
MSSTRING_CONST   REFontAwesomeIconJSONKey             = @"icon-name";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Control state title set paragraph attributes
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   RELineSpacingAttributeJSONKey            = @"line-spacing";
MSSTRING_CONST   REParagraphSpacingAttributeJSONKey       = @"paragraph-spacing";
MSSTRING_CONST   RETextAlignmentAttributeJSONKey          = @"alignment";
MSSTRING_CONST   REFirstLineHeadIndentAttributeJSONKey    = @"first-line-head-indent";
MSSTRING_CONST   REHeadIndentAttributeJSONKey             = @"head-indent";
MSSTRING_CONST   RETailIndentAttributeJSONKey             = @"tail-indent";
MSSTRING_CONST   RELineBreakModeAttributeJSONKey          = @"line-break-mode";
MSSTRING_CONST   REMinimumLineHeightAttributeJSONKey      = @"minimum-line-height";
MSSTRING_CONST   REMaximumLineHeightAttributeJSONKey      = @"maximum-line-height";
MSSTRING_CONST   RELineHeightMultipleAttributeJSONKey     = @"line-height-multiple";
MSSTRING_CONST   REParagraphSpacingBeforeAttributeJSONKey = @"paragraph-spacing-before";
MSSTRING_CONST   REHyphenationFactorAttributeJSONKey      = @"hyphenation-factor";
MSSTRING_CONST   RETabStopsAttributeJSONKey               = @"tab-stops";
MSSTRING_CONST   REDefaultTabIntervalAttributeJSONKey     = @"default-tab-interval";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Control state title set text alignment
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   RETextAlignmentLeftJSONKey      = @"left";
MSSTRING_CONST   RETextAlignmentCenterJSONKey    = @"center";
MSSTRING_CONST   RETextAlignmentRightJSONKey     = @"right";
MSSTRING_CONST   RETextAlignmentJustifiedJSONKey = @"justified";
MSSTRING_CONST   RETextAlignmentNaturalJSONKey   = @"natural";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Control state title set line break mode
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   RELineBreakByWordWrappingJSONKey     = @"word-wrap";
MSSTRING_CONST   RELineBreakByCharWrappingJSONKey     = @"character-wrap";
MSSTRING_CONST   RELineBreakByClippingJSONKey         = @"clip";
MSSTRING_CONST   RELineBreakByTruncatingHeadJSONKey   = @"truncate-head";
MSSTRING_CONST   RELineBreakByTruncatingTailJSONKey   = @"truncate-tail";
MSSTRING_CONST   RELineBreakByTruncatingMiddleJSONKey = @"truncate-middle";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Control state title set underline style and text effect
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST   RETextEffectLetterPressJSONKey = @"letter-press";

MSSTRING_CONST   REUnderlineStyleNoneJSONKey         = @"none";
MSSTRING_CONST   REUnderlineStyleSingleJSONKey       = @"single";
MSSTRING_CONST   REUnderlineStyleThickJSONKey        = @"thick";
MSSTRING_CONST   REUnderlineStyleDoubleJSONKey       = @"double";
MSSTRING_CONST   REUnderlinePatternSolidJSONKey      = @"solid";
MSSTRING_CONST   REUnderlinePatternDotJSONKey        = @"dot";
MSSTRING_CONST   REUnderlinePatternDashJSONKey       = @"dash";
MSSTRING_CONST   REUnderlinePatternDashDotJSONKey    = @"dash-dot";
MSSTRING_CONST   REUnderlinePatternDashDotDotJSONKey = @"dash-dot-dot";
MSSTRING_CONST   REUnderlineByWordJSONKey            = @"by-word";


