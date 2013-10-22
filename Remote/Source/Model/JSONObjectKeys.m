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

// remote element types
MSSTRING_CONST   RETypeUndefinedKey   = @"undefined";
MSSTRING_CONST   RETypeRemoteKey      = @"remote";
MSSTRING_CONST   RETypeButtonGroupKey = @"button-group";
MSSTRING_CONST   RETypeButtonKey      = @"button";

// remote element subtypes
MSSTRING_CONST   RESubtypeUndefinedKey = @"undefined";

MSSTRING_CONST   REButtonGroupTopPanel1Key = @"top1";
MSSTRING_CONST   REButtonGroupTopPanel2Key = @"top2";
MSSTRING_CONST   REButtonGroupTopPanel3Key = @"top3";

MSSTRING_CONST   REButtonGroupBottomPanel1Key = @"bottom1";
MSSTRING_CONST   REButtonGroupBottomPanel2Key = @"bottom2";
MSSTRING_CONST   REButtonGroupBottomPanel3Key = @"bottom3";

MSSTRING_CONST   REButtonGroupLeftPanel1Key = @"left1";
MSSTRING_CONST   REButtonGroupLeftPanel2Key = @"left2";
MSSTRING_CONST   REButtonGroupLeftPanel3Key = @"left3";

MSSTRING_CONST   REButtonGroupRightPanel1Key = @"right1";
MSSTRING_CONST   REButtonGroupRightPanel2Key = @"right2";
MSSTRING_CONST   REButtonGroupRightPanel3Key = @"right3";

MSSTRING_CONST   REPanelLocationUnassignedKey = @"unassigned";
MSSTRING_CONST   REPanelLocationTopKey        = @"top";
MSSTRING_CONST   REPanelLocationBottomKey     = @"bottom";
MSSTRING_CONST   REPanelLocationLeftKey       = @"left";
MSSTRING_CONST   REPanelLocationRightKey      = @"right";

MSSTRING_CONST   REPanelNoTriggerKey = @"none";
MSSTRING_CONST   REPanelTrigger1Key  = @"1";
MSSTRING_CONST   REPanelTrigger2Key  = @"2";
MSSTRING_CONST   REPanelTrigger3Key  = @"3";

// remote element options
MSSTRING_CONST   REOptionsUndefinedKey          = @"undefined";
MSSTRING_CONST   RERemoteOptionsDefaultKey      = @"default";
MSSTRING_CONST   RERemoteOptionTopBarHiddenKey  = @"top-bar-hidden";
MSSTRING_CONST   REButtonGroupOptionsDefaultKey = @"default";
MSSTRING_CONST   REButtonGroupOptionAutohideKey = @"autohide";

// remote element shapes
MSSTRING_CONST   REShapeUndefinedKey        = @"undefined";
MSSTRING_CONST   REShapeRoundedRectangleKey = @"rounded-rectangle";
MSSTRING_CONST   REShapeOvalKey             = @"oval";
MSSTRING_CONST   REShapeRectangleKey        = @"rectangle";
MSSTRING_CONST   REShapeTriangleKey         = @"triangle";
MSSTRING_CONST   REShapeDiamondKey          = @"diamond";

MSSTRING_CONST   REStyleUndefinedKey   = @"undefined";
MSSTRING_CONST   REStyleApplyGlossKey  = @"gloss";
MSSTRING_CONST   REStyleGlossStyle1Key = @"gloss1";
MSSTRING_CONST   REStyleGlossStyle2Key = @"gloss2";
MSSTRING_CONST   REStyleGlossStyle3Key = @"gloss3";
MSSTRING_CONST   REStyleGlossStyle4Key = @"gloss4";
MSSTRING_CONST   REStyleDrawBorderKey  = @"border";
MSSTRING_CONST   REStyleStretchableKey = @"stretchable";

// remote element theme override flags
MSSTRING_CONST   REThemeNoneKey = @"none";

MSSTRING_CONST   REThemeNoBackgroundImageKey      = @"background-image";
MSSTRING_CONST   REThemeNoBackgroundImageAlphaKey = @"background-image-alpha";
MSSTRING_CONST   REThemeNoBackgroundColorKey      = @"background-color";
MSSTRING_CONST   REThemeNoBackgroundKey           = @"background";

MSSTRING_CONST   REThemeNoBorderKey      = @"border";
MSSTRING_CONST   REThemeNoGlossKey       = @"gloss";
MSSTRING_CONST   REThemeNoStretchableKey = @"stretchable";
MSSTRING_CONST   REThemeNoStyleKey       = @"style";

MSSTRING_CONST   REThemeNoIconImageKey  = @"icon-image";
MSSTRING_CONST   REThemeNoIconColorKey  = @"icon-color";
MSSTRING_CONST   REThemeNoIconInsetsKey = @"icon-insets";
MSSTRING_CONST   REThemeNoIconKey       = @"icon";

MSSTRING_CONST   REThemeNoTitleForegroundColorKey = @"title-foreground-color";
MSSTRING_CONST   REThemeNoTitleBackgroundColorKey = @"title-background-color";
MSSTRING_CONST   REThemeNoTitleShadowColorKey     = @"title-shadow-color";
MSSTRING_CONST   REThemeNoTitleStrokeColorKey     = @"title-stroke-color";
MSSTRING_CONST   REThemeNoTitleColorKey           = @"title-color";
MSSTRING_CONST   REThemeNoFontNameKey             = @"font-name";
MSSTRING_CONST   REThemeNoFontSizeKey             = @"font-size";
MSSTRING_CONST   REThemeNoFontKey                 = @"font";
MSSTRING_CONST   REThemeNoStrokeWidthKey          = @"stroke-width";
MSSTRING_CONST   REThemeNoStrikethroughKey        = @"strikethrough";
MSSTRING_CONST   REThemeNoUnderlineKey            = @"underline";
MSSTRING_CONST   REThemeNoLigatureKey             = @"ligature";
MSSTRING_CONST   REThemeNoKernKey                 = @"kern";
MSSTRING_CONST   REThemeNoParagraphStyleKey       = @"paragraph-style";
MSSTRING_CONST   REThemeNoTitleAttributesKey      = @"title-attributes";
MSSTRING_CONST   REThemeNoTitleInsetsKey          = @"title-insets";
MSSTRING_CONST   REThemeNoTitleTextKey            = @"title-text";
MSSTRING_CONST   REThemeNoTitleKey                = @"title";

MSSTRING_CONST   REThemeNoContentInsetsKey = @"content-insets";
MSSTRING_CONST   REThemeNoShapeKey         = @"shape";

MSSTRING_CONST   REThemeAllKey = @"all";

// remote element roles
MSSTRING_CONST   RERoleUndefinedKey = @"undefined";

MSSTRING_CONST   REButtonGroupRolePanelKey          = @"panel";
MSSTRING_CONST   REButtonGroupRoleSelectionPanelKey = @"selection-panel";
MSSTRING_CONST   REButtonGroupRoleToolbarKey        = @"toolbar";
MSSTRING_CONST   REButtonGroupRoleDPadKey           = @"dpad";
MSSTRING_CONST   REButtonGroupRoleNumberpadKey      = @"numberpad";
MSSTRING_CONST   REButtonGroupRoleTransportKey      = @"transport";
MSSTRING_CONST   REButtonGroupRolePickerLabelKey    = @"picker";

MSSTRING_CONST   REButtonRoleToolbarKey          = @"toolbar";
MSSTRING_CONST   REButtonRoleConnectionStatusKey = @"connection-status";
MSSTRING_CONST   REButtonRoleBatteryStatusKey    = @"battery-status";

MSSTRING_CONST   REButtonRolePickerLabelTopKey    = @"picker-top";
MSSTRING_CONST   REButtonRolePickerLabelBottomKey = @"picker-bottom";

MSSTRING_CONST   REButtonRolePanelKey          = @"panel";
MSSTRING_CONST   REButtonRoleTuckKey           = @"tuck";
MSSTRING_CONST   REButtonRoleSelectionPanelKey = @"selection-panel";

MSSTRING_CONST   REButtonRoleDPadUpKey     = @"dpad-up";
MSSTRING_CONST   REButtonRoleDPadDownKey   = @"dpad-down";
MSSTRING_CONST   REButtonRoleDPadLeftKey   = @"dpad-left";
MSSTRING_CONST   REButtonRoleDPadRightKey  = @"dpad-right";
MSSTRING_CONST   REButtonRoleDPadCenterKey = @"dpad-center";

MSSTRING_CONST   REButtonRoleNumberpad1Key    = @"numberpad-1";
MSSTRING_CONST   REButtonRoleNumberpad2Key    = @"numberpad-2";
MSSTRING_CONST   REButtonRoleNumberpad3Key    = @"numberpad-3";
MSSTRING_CONST   REButtonRoleNumberpad4Key    = @"numberpad-4";
MSSTRING_CONST   REButtonRoleNumberpad5Key    = @"numberpad-5";
MSSTRING_CONST   REButtonRoleNumberpad6Key    = @"numberpad-6";
MSSTRING_CONST   REButtonRoleNumberpad7Key    = @"numberpad-7";
MSSTRING_CONST   REButtonRoleNumberpad8Key    = @"numberpad-8";
MSSTRING_CONST   REButtonRoleNumberpad9Key    = @"numberpad-9";
MSSTRING_CONST   REButtonRoleNumberpad0Key    = @"numberpad-0";
MSSTRING_CONST   REButtonRoleNumberpadAux1Key = @"numberpad-aux1";
MSSTRING_CONST   REButtonRoleNumberpadAux2Key = @"numberpad-aux2";

MSSTRING_CONST   REButtonRoleTransportPlayKey   = @"transport-play";
MSSTRING_CONST   REButtonRoleTransportStopKey   = @"transport-stop";
MSSTRING_CONST   REButtonRoleTransportPauseKey  = @"transport-pause";
MSSTRING_CONST   REButtonRoleTransportSkipKey   = @"transport-skip";
MSSTRING_CONST   REButtonRoleTransportReplayKey = @"transport-replay";
MSSTRING_CONST   REButtonRoleTransportFFKey     = @"transport-fast-forward";
MSSTRING_CONST   REButtonRoleTransportRewindKey = @"transport-rewind";
MSSTRING_CONST   REButtonRoleTransportRecordKey = @"transport-record";

// remote element states
MSSTRING_CONST   REStateDefaultKey     = @"default";
MSSTRING_CONST   REStateNormalKey      = @"normal";
MSSTRING_CONST   REStateHighlightedKey = @"highlighted";
MSSTRING_CONST   REStateDisabledKey    = @"disabled";
MSSTRING_CONST   REStateSelectedKey    = @"selected";

// command classes
MSSTRING_CONST   PowerCommandTypeKey    = @"power";
MSSTRING_CONST   SendIRCommandTypeKey   = @"sendir";
MSSTRING_CONST   HTTPCommandTypeKey     = @"http";
MSSTRING_CONST   DelayCommandTypeKey    = @"delay";
MSSTRING_CONST   MacroCommandTypeKey    = @"macro";
MSSTRING_CONST   SystemCommandTypeKey   = @"system";
MSSTRING_CONST   SwitchCommandTypeKey   = @"switch";
MSSTRING_CONST   ActivityCommandTypeKey = @"activity";

// command options
MSSTRING_CONST   CommandOptionDefaultKey   = @"default";
MSSTRING_CONST   CommandOptionLongPressKey = @"long-press";

// system command types
MSSTRING_CONST   SystemCommandTypeUndefinedKey         = @"undefined";
MSSTRING_CONST   SystemCommandProximitySensorKey = @"proximity-sensor";
MSSTRING_CONST   SystemCommandURLRequestKey            = @"url-request";
MSSTRING_CONST   SystemCommandLaunchScreenKey  = @"return-to-launch-screen";
MSSTRING_CONST   SystemCommandOpenSettingsKey          = @"open-settings";
MSSTRING_CONST   SystemCommandOpenEditorKey            = @"open-editor";

// switch command types
MSSTRING_CONST   SwitchRemoteCommandKey = @"remote";
MSSTRING_CONST   SwitchModeCommandKey   = @"mode";

// command set types
MSSTRING_CONST   CommandSetTypeUnspecifiedKey = @"undefined";
MSSTRING_CONST   CommandSetTypeDPadKey        = @"dpad";
MSSTRING_CONST   CommandSetTypeTransportKey   = @"transport";
MSSTRING_CONST   CommandSetTypeNumberpadKey   = @"numberpad";
MSSTRING_CONST   CommandSetTypeRockerKey      = @"rocker";

// remote element actions
MSSTRING_CONST   RESingleTapActionKey = @"tap";
MSSTRING_CONST   RELongPressActionKey = @"long-press";
