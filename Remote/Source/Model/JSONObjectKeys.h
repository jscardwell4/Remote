/*

  JSONObjectKeys.h
  Remote

  Created by Jason Cardwell on 10/15/13.
  Copyright (c) 2013 Moondeer Studios. All rights reserved.

*/

// remote element types
MSEXTERN_KEY(RETypeUndefined);
MSEXTERN_KEY(RETypeRemote);
MSEXTERN_KEY(RETypeButtonGroup);
MSEXTERN_KEY(RETypeButton);

// remote element subtypes
MSEXTERN_KEY(RESubtypeUndefined);

MSEXTERN_KEY(REButtonGroupTopPanel1);
MSEXTERN_KEY(REButtonGroupTopPanel2);
MSEXTERN_KEY(REButtonGroupTopPanel3);

MSEXTERN_KEY(REButtonGroupBottomPanel1);
MSEXTERN_KEY(REButtonGroupBottomPanel2);
MSEXTERN_KEY(REButtonGroupBottomPanel3);

MSEXTERN_KEY(REButtonGroupLeftPanel1);
MSEXTERN_KEY(REButtonGroupLeftPanel2);
MSEXTERN_KEY(REButtonGroupLeftPanel3);

MSEXTERN_KEY(REButtonGroupRightPanel1);
MSEXTERN_KEY(REButtonGroupRightPanel2);
MSEXTERN_KEY(REButtonGroupRightPanel3);

MSEXTERN_KEY(REPanelLocationUnassigned);
MSEXTERN_KEY(REPanelLocationTop);
MSEXTERN_KEY(REPanelLocationBottom);
MSEXTERN_KEY(REPanelLocationLeft);
MSEXTERN_KEY(REPanelLocationRight);

MSEXTERN_KEY(REPanelNoTrigger);
MSEXTERN_KEY(REPanelTrigger1);
MSEXTERN_KEY(REPanelTrigger2);
MSEXTERN_KEY(REPanelTrigger3);

// remote element options
MSEXTERN_KEY(REOptionsUndefined);
MSEXTERN_KEY(RERemoteOptionsDefault);
MSEXTERN_KEY(RERemoteOptionTopBarHidden);
MSEXTERN_KEY(REButtonGroupOptionsDefault);
MSEXTERN_KEY(REButtonGroupOptionAutohide);

// remote element shapes
MSEXTERN_KEY(REShapeUndefined);
MSEXTERN_KEY(REShapeRoundedRectangle);
MSEXTERN_KEY(REShapeOval);
MSEXTERN_KEY(REShapeRectangle);
MSEXTERN_KEY(REShapeTriangle);
MSEXTERN_KEY(REShapeDiamond);

MSEXTERN_KEY(REStyleUndefined);
MSEXTERN_KEY(REStyleApplyGloss);
MSEXTERN_KEY(REStyleGlossStyle1);
MSEXTERN_KEY(REStyleGlossStyle2);
MSEXTERN_KEY(REStyleGlossStyle3);
MSEXTERN_KEY(REStyleGlossStyle4);
MSEXTERN_KEY(REStyleDrawBorder);
MSEXTERN_KEY(REStyleStretchable);

// remote element theme override flags
MSEXTERN_KEY(REThemeNone);
MSEXTERN_KEY(REThemeNoBackgroundImage);
MSEXTERN_KEY(REThemeNoBackgroundImageAlpha);
MSEXTERN_KEY(REThemeNoBackgroundColor);
MSEXTERN_KEY(REThemeNoBackground);
MSEXTERN_KEY(REThemeNoBorder);
MSEXTERN_KEY(REThemeNoGloss);
MSEXTERN_KEY(REThemeNoStretchable);
MSEXTERN_KEY(REThemeNoStyle);
MSEXTERN_KEY(REThemeNoIconImage);
MSEXTERN_KEY(REThemeNoIconColor);
MSEXTERN_KEY(REThemeNoIconInsets);
MSEXTERN_KEY(REThemeNoIcon);
MSEXTERN_KEY(REThemeNoTitleForegroundColor);
MSEXTERN_KEY(REThemeNoTitleBackgroundColor);
MSEXTERN_KEY(REThemeNoTitleShadowColor);
MSEXTERN_KEY(REThemeNoTitleStrokeColor);
MSEXTERN_KEY(REThemeNoTitleColor);
MSEXTERN_KEY(REThemeNoFontName);
MSEXTERN_KEY(REThemeNoFontSize);
MSEXTERN_KEY(REThemeNoFont);
MSEXTERN_KEY(REThemeNoStrokeWidth);
MSEXTERN_KEY(REThemeNoStrikethrough);
MSEXTERN_KEY(REThemeNoUnderline);
MSEXTERN_KEY(REThemeNoLigature);
MSEXTERN_KEY(REThemeNoKern);
MSEXTERN_KEY(REThemeNoParagraphStyle);
MSEXTERN_KEY(REThemeNoTitleAttributes);
MSEXTERN_KEY(REThemeNoTitleInsets);
MSEXTERN_KEY(REThemeNoTitleText);
MSEXTERN_KEY(REThemeNoTitle);
MSEXTERN_KEY(REThemeNoContentInsets);
MSEXTERN_KEY(REThemeNoShape);
MSEXTERN_KEY(REThemeAll);

// remote element roles
MSEXTERN_KEY(RERoleUndefined);

MSEXTERN_KEY(REButtonGroupRolePanel);
MSEXTERN_KEY(REButtonGroupRoleSelectionPanel);
MSEXTERN_KEY(REButtonGroupRoleToolbar);
MSEXTERN_KEY(REButtonGroupRoleDPad);
MSEXTERN_KEY(REButtonGroupRoleNumberpad);
MSEXTERN_KEY(REButtonGroupRoleTransport);
MSEXTERN_KEY(REButtonGroupRolePickerLabel);

MSEXTERN_KEY(REButtonRoleToolbar);
MSEXTERN_KEY(REButtonRoleConnectionStatus);
MSEXTERN_KEY(REButtonRoleBatteryStatus);

MSEXTERN_KEY(REButtonRolePickerLabelTop);
MSEXTERN_KEY(REButtonRolePickerLabelBottom);

MSEXTERN_KEY(REButtonRolePanel);
MSEXTERN_KEY(REButtonRoleTuck);
MSEXTERN_KEY(REButtonRoleSelectionPanel);

MSEXTERN_KEY(REButtonRoleDPadUp);
MSEXTERN_KEY(REButtonRoleDPadDown);
MSEXTERN_KEY(REButtonRoleDPadLeft);
MSEXTERN_KEY(REButtonRoleDPadRight);
MSEXTERN_KEY(REButtonRoleDPadCenter);

MSEXTERN_KEY(REButtonRoleNumberpad1);
MSEXTERN_KEY(REButtonRoleNumberpad2);
MSEXTERN_KEY(REButtonRoleNumberpad3);
MSEXTERN_KEY(REButtonRoleNumberpad4);
MSEXTERN_KEY(REButtonRoleNumberpad5);
MSEXTERN_KEY(REButtonRoleNumberpad6);
MSEXTERN_KEY(REButtonRoleNumberpad7);
MSEXTERN_KEY(REButtonRoleNumberpad8);
MSEXTERN_KEY(REButtonRoleNumberpad9);
MSEXTERN_KEY(REButtonRoleNumberpad0);
MSEXTERN_KEY(REButtonRoleNumberpadAux1);
MSEXTERN_KEY(REButtonRoleNumberpadAux2);

MSEXTERN_KEY(REButtonRoleTransportPlay);
MSEXTERN_KEY(REButtonRoleTransportStop);
MSEXTERN_KEY(REButtonRoleTransportPause);
MSEXTERN_KEY(REButtonRoleTransportSkip);
MSEXTERN_KEY(REButtonRoleTransportReplay);
MSEXTERN_KEY(REButtonRoleTransportFF);
MSEXTERN_KEY(REButtonRoleTransportRewind);
MSEXTERN_KEY(REButtonRoleTransportRecord);

// remote element states
MSEXTERN_KEY(REStateDefault);
MSEXTERN_KEY(REStateNormal);
MSEXTERN_KEY(REStateHighlighted);
MSEXTERN_KEY(REStateDisabled);
MSEXTERN_KEY(REStateSelected);

// command classes
MSEXTERN_KEY(PowerCommandType);
MSEXTERN_KEY(SendIRCommandType);
MSEXTERN_KEY(HTTPCommandType);
MSEXTERN_KEY(DelayCommandType);
MSEXTERN_KEY(MacroCommandType);
MSEXTERN_KEY(SystemCommandType);
MSEXTERN_KEY(SwitchCommandType);
MSEXTERN_KEY(ActivityCommandType);

// command options
MSEXTERN_KEY(CommandOptionDefault);
MSEXTERN_KEY(CommandOptionLongPress);

// system command types
MSEXTERN_KEY(SystemCommandTypeUndefined);
MSEXTERN_KEY(SystemCommandProximitySensor);
MSEXTERN_KEY(SystemCommandURLRequest);
MSEXTERN_KEY(SystemCommandLaunchScreen);
MSEXTERN_KEY(SystemCommandOpenSettings);
MSEXTERN_KEY(SystemCommandOpenEditor);

// switch command types
MSEXTERN_KEY(SwitchRemoteCommand);
MSEXTERN_KEY(SwitchModeCommand);

// command set types
MSEXTERN_KEY(CommandSetTypeUnspecified);
MSEXTERN_KEY(CommandSetTypeDPad);
MSEXTERN_KEY(CommandSetTypeTransport);
MSEXTERN_KEY(CommandSetTypeNumberpad);
MSEXTERN_KEY(CommandSetTypeRocker);

// remote element actions
MSEXTERN_KEY(RESingleTapAction);
MSEXTERN_KEY(RELongPressAction);
