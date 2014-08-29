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
#import "CommandSet.h"
#import "CommandSetCollection.h"
#import "ControlStateSet.h"
#import "ControlStateImageSet.h"
#import "ControlStateTitleSet.h"
#import "ControlStateColorSet.h"
#import "RemoteElementKeys.h"
#import "JSONObjectKeys.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Types, Subtypes and Roles
////////////////////////////////////////////////////////////////////////////////

NSString *typeJSONValueForRemoteElement(RemoteElement * element) {
  static NSDictionary const * index;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken,
                ^{
    index = @{ @(RETypeRemote)      : RETypeRemoteJSONKey,
               @(RETypeButtonGroup) : RETypeButtonGroupJSONKey,
               @(RETypeButton)      : RETypeButtonJSONKey };
  });

  return (element ? index[@(element.elementType)] : nil);
}

/*
NSString *subtypeJSONValueForRemoteElement(RemoteElement * element) {
  static NSDictionary const * index;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken,
                ^{
    index = @{ @(RESubtypeUndefined)        : RESubtypeUndefinedJSONKey,

               @(REButtonGroupTopPanel1)    : REButtonGroupTopPanel1JSONKey,
               @(REButtonGroupTopPanel2)    : REButtonGroupTopPanel2JSONKey,
               @(REButtonGroupTopPanel3)    : REButtonGroupTopPanel3JSONKey,

               @(REButtonGroupBottomPanel1) : REButtonGroupBottomPanel1JSONKey,
               @(REButtonGroupBottomPanel2) : REButtonGroupBottomPanel2JSONKey,
               @(REButtonGroupBottomPanel3) : REButtonGroupBottomPanel3JSONKey,

               @(REButtonGroupLeftPanel1)   : REButtonGroupLeftPanel1JSONKey,
               @(REButtonGroupLeftPanel2)   : REButtonGroupLeftPanel2JSONKey,
               @(REButtonGroupLeftPanel3)   : REButtonGroupLeftPanel3JSONKey,

               @(REButtonGroupRightPanel1)  : REButtonGroupRightPanel1JSONKey,
               @(REButtonGroupRightPanel2)  : REButtonGroupRightPanel2JSONKey,
               @(REButtonGroupRightPanel3)  : REButtonGroupRightPanel3JSONKey };
  });

  return (element ? index[@(element.subtype)] : nil);
}
*/

NSString *roleJSONValueForRemoteElement(RemoteElement * element) {
  return (element ? roleJSONValueForRERole(element.role) : nil);
}

NSString *roleJSONValueForRERole(RERole role) {
  static NSDictionary const * index;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken,
                ^{
    index =
      @{ @(RERoleUndefined)                 : RERoleUndefinedJSONKey,

         // button group roles
         @(REButtonGroupRoleSelectionPanel) : REButtonGroupRoleSelectionPanelJSONKey,
         @(REButtonGroupRoleToolbar)        : REButtonGroupRoleToolbarJSONKey,
         @(REButtonGroupRoleDPad)           : REButtonGroupRoleDPadJSONKey,
         @(REButtonGroupRoleNumberpad)      : REButtonGroupRoleNumberpadJSONKey,
         @(REButtonGroupRoleTransport)      : REButtonGroupRoleTransportJSONKey,
         @(REButtonGroupRoleRocker)         : REButtonGroupRoleRockerJSONKey,

         // toolbar buttons
         @(REButtonRoleToolbar)             : REButtonRoleToolbarJSONKey,
         @(REButtonRoleConnectionStatus)    : REButtonRoleConnectionStatusJSONKey,
         @(REButtonRoleBatteryStatus)       : REButtonRoleBatteryStatusJSONKey,

         // picker label buttons
         @(REButtonRoleRockerTop)           : REButtonRoleRockerTopJSONKey,
         @(REButtonRoleRockerBottom)        : REButtonRoleRockerBottomJSONKey,

         // panel buttons
         @(REButtonRolePanel)               : REButtonRolePanelJSONKey,
         @(REButtonRoleTuck)                : REButtonRoleTuckJSONKey,
         @(REButtonRoleSelectionPanel)      : REButtonRoleSelectionPanelJSONKey,

         // dpad buttons
         @(REButtonRoleDPadUp)              : REButtonRoleDPadUpJSONKey,
         @(REButtonRoleDPadDown)            : REButtonRoleDPadDownJSONKey,
         @(REButtonRoleDPadLeft)            : REButtonRoleDPadLeftJSONKey,
         @(REButtonRoleDPadRight)           : REButtonRoleDPadRightJSONKey,
         @(REButtonRoleDPadCenter)          : REButtonRoleDPadCenterJSONKey,


         // numberpad buttons
         @(REButtonRoleNumberpad1)          : REButtonRoleNumberpad1JSONKey,
         @(REButtonRoleNumberpad2)          : REButtonRoleNumberpad2JSONKey,
         @(REButtonRoleNumberpad3)          : REButtonRoleNumberpad3JSONKey,
         @(REButtonRoleNumberpad4)          : REButtonRoleNumberpad4JSONKey,
         @(REButtonRoleNumberpad5)          : REButtonRoleNumberpad5JSONKey,
         @(REButtonRoleNumberpad6)          : REButtonRoleNumberpad6JSONKey,
         @(REButtonRoleNumberpad7)          : REButtonRoleNumberpad7JSONKey,
         @(REButtonRoleNumberpad8)          : REButtonRoleNumberpad8JSONKey,
         @(REButtonRoleNumberpad9)          : REButtonRoleNumberpad9JSONKey,
         @(REButtonRoleNumberpad0)          : REButtonRoleNumberpad0JSONKey,
         @(REButtonRoleNumberpadAux1)       : REButtonRoleNumberpadAux1JSONKey,
         @(REButtonRoleNumberpadAux2)       : REButtonRoleNumberpadAux2JSONKey,

         // transport buttons
         @(REButtonRoleTransportPlay)       : REButtonRoleTransportPlayJSONKey,
         @(REButtonRoleTransportStop)       : REButtonRoleTransportStopJSONKey,
         @(REButtonRoleTransportPause)      : REButtonRoleTransportPauseJSONKey,
         @(REButtonRoleTransportSkip)       : REButtonRoleTransportSkipJSONKey,
         @(REButtonRoleTransportReplay)     : REButtonRoleTransportReplayJSONKey,
         @(REButtonRoleTransportFF)         : REButtonRoleTransportFFJSONKey,
         @(REButtonRoleTransportRewind)     : REButtonRoleTransportRewindJSONKey,
         @(REButtonRoleTransportRecord)     : REButtonRoleTransportRecordJSONKey };
  });

  return index[@(role)];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element State
////////////////////////////////////////////////////////////////////////////////

NSString *stateJSONValueForButton(Button * element) {
  static NSDictionary const * index;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken,
                ^{
    index = @{ @(REStateNormal)      : REStateNormalJSONKey,
               @(REStateDisabled)    : REStateDisabledJSONKey,
               @(REStateHighlighted) : REStateHighlightedJSONKey,
               @(REStateSelected)    : REStateSelectedJSONKey };
  });

  NSMutableArray * stateArray = [@[] mutableCopy];

  REState state = element.state;

  if (state & REStateDisabled) [stateArray addObject:index[@(REStateDisabled)]];

  if (state & REStateHighlighted) [stateArray addObject:index[@(REStateHighlighted)]];

  if (state & REStateSelected) [stateArray addObject:index[@(REStateSelected)]];

  return ([stateArray count] ? [stateArray componentsJoinedByString:@" "] : nil);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Shape, Style, & Theme
////////////////////////////////////////////////////////////////////////////////

NSString *shapeJSONValueForRemoteElement(RemoteElement * element) {
  static NSDictionary const * index;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken,
                ^{
    index = @{ @(REShapeUndefined)        : REShapeUndefinedJSONKey,
               @(REShapeRoundedRectangle) : REShapeRoundedRectangleJSONKey,
               @(REShapeRectangle)        : REShapeRectangleJSONKey,
               @(REShapeDiamond)          : REShapeDiamondJSONKey,
               @(REShapeTriangle)         : REShapeTriangleJSONKey,
               @(REShapeOval)             : REShapeOvalJSONKey };
  });

  return (element ? index[@(element.shape)] : nil);
}

NSString *styleJSONValueForRemoteElement(RemoteElement * element) {
  static NSDictionary const * index;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken,
                ^{
    index = @{ @(REStyleUndefined)   : REStyleUndefinedJSONKey,
               @(REStyleDrawBorder)  : REStyleDrawBorderJSONKey,
               @(REStyleStretchable) : REStyleStretchableJSONKey,
               @(REStyleApplyGloss)  : REStyleGlossStyle1JSONKey,
               @(REStyleGlossStyle2) : REStyleGlossStyle2JSONKey,
               @(REStyleGlossStyle3) : REStyleGlossStyle3JSONKey,
               @(REStyleGlossStyle4) : REStyleGlossStyle4JSONKey };
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

NSString *themeFlagsJSONValueForRemoteElement(RemoteElement * element) {
  static NSDictionary const * index;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken, ^{
    index =
      @{ @(REThemeNoBackgroundImage)               : REThemeNoBackgroundImageJSONKey,
         @(REThemeNoBackgroundImageAlpha)          : REThemeNoBackgroundImageAlphaJSONKey,
         @(REThemeNoBackgroundColorAttribute)      : REThemeNoBackgroundColorAttributeJSONKey,
         @(REThemeNoBorder)                        : REThemeNoBorderJSONKey,
         @(REThemeNoGloss)                         : REThemeNoGlossJSONKey,
         @(REThemeNoStretchable)                   : REThemeNoStretchableJSONKey,
         @(REThemeNoIconImage)                     : REThemeNoIconImageJSONKey,
         @(REThemeNoIconColorAttribute)            : REThemeNoIconColorAttributeJSONKey,
         @(REThemeNoIconInsets)                    : REThemeNoIconInsetsJSONKey,
         @(REThemeNoTitleForegroundColorAttribute) : REThemeNoTitleForegroundColorAttributeJSONKey,
         @(REThemeNoTitleBackgroundColorAttribute) : REThemeNoTitleBackgroundColorAttributeJSONKey,
         @(REThemeNoTitleShadowColorAttribute)     : REThemeNoTitleShadowColorAttributeJSONKey,
         @(REThemeNoTitleStrokeColorAttribute)     : REThemeNoTitleStrokeColorAttributeJSONKey,
         @(REThemeNoFontName)                      : REThemeNoFontNameJSONKey,
         @(REThemeNoFontSize)                      : REThemeNoFontSizeJSONKey,
         @(REThemeNoStrokeWidth)                   : REThemeNoStrokeWidthJSONKey,
         @(REThemeNoStrikethrough)                 : REThemeNoStrikethroughJSONKey,
         @(REThemeNoUnderline)                     : REThemeNoUnderlineJSONKey,
         @(REThemeNoLigature)                      : REThemeNoLigatureJSONKey,
         @(REThemeNoKern)                          : REThemeNoKernJSONKey,
         @(REThemeNoParagraphStyle)                : REThemeNoParagraphStyleJSONKey,
         @(REThemeNoTitleInsets)                   : REThemeNoTitleInsetsJSONKey,
         @(REThemeNoTitleText)                     : REThemeNoTitleTextJSONKey,
         @(REThemeNoContentInsets)                 : REThemeNoContentInsetsJSONKey,
         @(REThemeNoShape)                         : REThemeNoShapeJSONKey };
  });


  if (!element) return nil;

  REThemeOverrideFlags elementFlags = element.themeFlags;

  if (elementFlags == REThemeAll)
    return REThemeAllJSONKey;

  else if (elementFlags == REThemeNone)
    return REThemeNoneJSONKey;

  else {
    NSArray * possibleFlags = [index allKeys];
    NSArray * flagsSet      = [possibleFlags objectsPassingTest:
                               ^BOOL (NSNumber * obj, NSUInteger idx, BOOL * stop)
    {
      uint8_t flag = [obj unsignedShortValue];
      return ((elementFlags & flag) == flag);
    }];

    if (![flagsSet count])
      return nil;

    else if ([flagsSet count] > [possibleFlags count] / 2) {
      NSMutableSet * flagsNotSet = [[possibleFlags set] mutableCopy];
      [flagsNotSet minusSet:[flagsSet set]];
      NSMutableArray * jsonValues = [[index objectsForKeys:[flagsNotSet allObjects]
                                            notFoundMarker:NullObject] mutableCopy];
      [jsonValues removeNullObjects];
      return [@"-" stringByAppendingString:[jsonValues componentsJoinedByString:@" "]];
    } else   {
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

NSString *systemCommandTypeJSONValueForSystemCommand(SystemCommand * command) {
  static NSDictionary const * index;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken,
                ^{
    index = @{ @(SystemCommandTypeUndefined)   : SystemCommandTypeUndefinedJSONKey,
               @(SystemCommandProximitySensor) : SystemCommandProximitySensorJSONKey,
               @(SystemCommandURLRequest)      : SystemCommandURLRequestJSONKey,
               @(SystemCommandLaunchScreen)    : SystemCommandLaunchScreenJSONKey,
               @(SystemCommandOpenSettings)    : SystemCommandOpenSettingsJSONKey,
               @(SystemCommandOpenEditor)      : SystemCommandOpenEditorJSONKey };
  });

  return (command ? index[@(command.type)] : nil);
}

NSString *switchCommandTypeJSONValueForSwitchCommand(SwitchCommand * command) {
  static NSDictionary const * index;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken,
                ^{
    index = @{ @(SwitchRemoteCommand) : SwitchRemoteCommandJSONKey,
               @(SwitchModeCommand)   : SwitchModeCommandJSONKey };
  });

  return (command ? index[@(command.type)] : nil);
}

NSString *commandSetTypeJSONValueForCommandSet(CommandSet * commandSet) {
  static NSDictionary const * index;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken,
                ^{
    index = @{ @(CommandSetTypeUnspecified) : CommandSetTypeUnspecifiedJSONKey,
               @(CommandSetTypeDPad)        : CommandSetTypeDPadJSONKey,
               @(CommandSetTypeTransport)   : CommandSetTypeTransportJSONKey,
               @(CommandSetTypeNumberpad)   : CommandSetTypeNumberpadJSONKey,
               @(CommandSetTypeRocker)      : CommandSetTypeRockerJSONKey };
  });

  return (commandSet ? index[@(commandSet.type)] : nil);
}

NSString *classJSONValueForCommand(Command * command) {
  static NSDictionary const * index;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken, ^{
    index = @{ @"PowerCommand"    : PowerCommandTypeJSONKey,
               @"SendIRCommand"   : SendIRCommandTypeJSONKey,
               @"HTTPCommand"     : HTTPCommandTypeJSONKey,
               @"DelayCommand"    : DelayCommandTypeJSONKey,
               @"MacroCommand"    : MacroCommandTypeJSONKey,
               @"SystemCommand"   : SystemCommandTypeJSONKey,
               @"SwitchCommand"   : SwitchCommandTypeJSONKey,
               @"ActivityCommand" : ActivityCommandTypeJSONKey };
  });
  return index[ClassString([command class])];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote
////////////////////////////////////////////////////////////////////////////////

NSString *panelKeyForPanelAssignment(REPanelAssignment assignment) {
  static NSDictionary const * locationIndex, * triggerIndex;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken,
                ^{
    locationIndex = @{ @(REPanelLocationTop)    : REPanelLocationTopJSONKey,
                       @(REPanelLocationBottom) : REPanelLocationBottomJSONKey,
                       @(REPanelLocationLeft)   : REPanelLocationLeftJSONKey,
                       @(REPanelLocationRight)  : REPanelLocationRightJSONKey };

    triggerIndex = @{ @(REPanelTrigger1) : REPanelTrigger1JSONKey,
                      @(REPanelTrigger2) : REPanelTrigger2JSONKey,
                      @(REPanelTrigger3) : REPanelTrigger3JSONKey };
  });

  REPanelLocation location = (assignment & REPanelAssignmentLocationMask);
  REPanelTrigger  trigger  = (assignment & REPanelAssignmentTriggerMask);

  NSString * key = nil;

  if (location && trigger) {
    NSString * locationString = locationIndex[@(location)];
    NSString * triggerString  = triggerIndex[@(trigger)];

    if (locationString && triggerString)
      key = [locationString stringByAppendingString:triggerString];
  }

  return key;

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Control state sets
////////////////////////////////////////////////////////////////////////////////

NSString *titleSetAttributeJSONKeyForKey(NSString * key) {
  static NSDictionary const * index = nil;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken, ^{
    index = @{ REFontAttributeKey                   : REFontAttributeJSONKey,
               REParagraphStyleAttributeKey         : REParagraphStyleAttributeJSONKey,
               REForegroundColorAttributeKey        : REForegroundColorAttributeJSONKey,
               REBackgroundColorAttributeKey        : REBackgroundColorAttributeJSONKey,
               RELigatureAttributeKey               : RELigatureAttributeJSONKey,
               REKernAttributeKey                   : REKernAttributeJSONKey,
               REStrikethroughStyleAttributeKey     : REStrikethroughStyleAttributeJSONKey,
               REUnderlineStyleAttributeKey         : REUnderlineStyleAttributeJSONKey,
               REStrokeColorAttributeKey            : REStrokeColorAttributeJSONKey,
               REStrokeWidthAttributeKey            : REStrokeWidthAttributeJSONKey,
               RETextEffectAttributeKey             : RETextEffectAttributeJSONKey,
               REBaselineOffsetAttributeKey         : REBaselineOffsetAttributeJSONKey,
               REUnderlineColorAttributeKey         : REUnderlineColorAttributeJSONKey,
               REStrikethroughColorAttributeKey     : REStrikethroughColorAttributeJSONKey,
               REObliquenessAttributeKey            : REObliquenessAttributeJSONKey,
               REExpansionAttributeKey              : REExpansionAttributeJSONKey,
               REShadowAttributeKey                 : REShadowAttributeJSONKey,
               RETitleTextAttributeKey              : RETitleTextAttributeJSONKey,

               RELineSpacingAttributeKey            : RELineSpacingAttributeJSONKey,
               REParagraphSpacingAttributeKey       : REParagraphSpacingAttributeJSONKey,
               RETextAlignmentAttributeKey          : RETextAlignmentAttributeJSONKey,
               REFirstLineHeadIndentAttributeKey    : REFirstLineHeadIndentAttributeJSONKey,
               REHeadIndentAttributeKey             : REHeadIndentAttributeJSONKey,
               RETailIndentAttributeKey             : RETailIndentAttributeJSONKey,
               RELineBreakModeAttributeKey          : RELineBreakModeAttributeJSONKey,
               REMinimumLineHeightAttributeKey      : REMinimumLineHeightAttributeJSONKey,
               REMaximumLineHeightAttributeKey      : REMaximumLineHeightAttributeJSONKey,
               RELineHeightMultipleAttributeKey     : RELineHeightMultipleAttributeJSONKey,
               REParagraphSpacingBeforeAttributeKey : REParagraphSpacingBeforeAttributeJSONKey,
               REHyphenationFactorAttributeKey      : REHyphenationFactorAttributeJSONKey,
               RETabStopsAttributeKey               : RETabStopsAttributeJSONKey,
               REDefaultTabIntervalAttributeKey     : REDefaultTabIntervalAttributeJSONKey };
  });
  return index[key];
}

NSString *titleAttributesJSONKeyForProperty(NSString * property) {
  static NSDictionary const * index = nil;
  static dispatch_once_t      onceToken;

  dispatch_once(&onceToken, ^{
    index = @{ @"font"                   : REFontAttributeJSONKey,
               @"foregroundColor"        : REForegroundColorAttributeJSONKey,
               @"backgroundColor"        : REBackgroundColorAttributeJSONKey,
               @"ligature"               : RELigatureAttributeJSONKey,
               @"kern"                   : REKernAttributeJSONKey,
               @"strikethroughStyle"     : REStrikethroughStyleAttributeJSONKey,
               @"underlineStyle"         : REUnderlineStyleAttributeJSONKey,
               @"strokeColor"            : REStrokeColorAttributeJSONKey,
               @"strokeWidth"            : REStrokeWidthAttributeJSONKey,
               @"textEffect"             : RETextEffectAttributeJSONKey,
               @"baselineOffset"         : REBaselineOffsetAttributeJSONKey,
               @"underlineColor"         : REUnderlineColorAttributeJSONKey,
               @"strikethroughColor"     : REStrikethroughColorAttributeJSONKey,
               @"obliqueness"            : REObliquenessAttributeJSONKey,
               @"expansion"              : REExpansionAttributeJSONKey,
               @"shadow"                 : REShadowAttributeJSONKey,
               @"titleText"              : RETitleTextAttributeJSONKey,
               @"iconName"               : REFontAwesomeIconJSONKey,
               @"lineSpacing"            : RELineSpacingAttributeJSONKey,
               @"paragraphSpacing"       : REParagraphSpacingAttributeJSONKey,
               @"textAlignment"          : RETextAlignmentAttributeJSONKey,
               @"firstLineHeadIndent"    : REFirstLineHeadIndentAttributeJSONKey,
               @"headIndent"             : REHeadIndentAttributeJSONKey,
               @"tailIndent"             : RETailIndentAttributeJSONKey,
               @"lineBreakMode"          : RELineBreakModeAttributeJSONKey,
               @"minimumLineHeight"      : REMinimumLineHeightAttributeJSONKey,
               @"maximumLineHeight"      : REMaximumLineHeightAttributeJSONKey,
               @"lineHeightMultiple"     : RELineHeightMultipleAttributeJSONKey,
               @"paragraphSpacingBefore" : REParagraphSpacingBeforeAttributeJSONKey,
               @"hyphenationFactor"      : REHyphenationFactorAttributeJSONKey,
               @"tabStops"               : RETabStopsAttributeJSONKey,
               @"defaultTabInterval"     : REDefaultTabIntervalAttributeJSONKey };
  });

  return (property ? index[property] : nil);
}

NSString *titleSetAttributeJSONKeyForName(NSString * key) {
  static NSDictionary const * index = nil;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken, ^{
    index = @{ NSFontAttributeName                   : REFontAttributeJSONKey,
               NSParagraphStyleAttributeName         : REParagraphStyleAttributeJSONKey,
               NSForegroundColorAttributeName        : REForegroundColorAttributeJSONKey,
               NSBackgroundColorAttributeName        : REBackgroundColorAttributeJSONKey,
               NSLigatureAttributeName               : RELigatureAttributeJSONKey,
               NSKernAttributeName                   : REKernAttributeJSONKey,
               NSStrikethroughStyleAttributeName     : REStrikethroughStyleAttributeJSONKey,
               NSUnderlineStyleAttributeName         : REUnderlineStyleAttributeJSONKey,
               NSStrokeColorAttributeName            : REStrokeColorAttributeJSONKey,
               NSStrokeWidthAttributeName            : REStrokeWidthAttributeJSONKey,
               NSTextEffectAttributeName             : RETextEffectAttributeJSONKey,
               NSBaselineOffsetAttributeName         : REBaselineOffsetAttributeJSONKey,
               NSUnderlineColorAttributeName         : REUnderlineColorAttributeJSONKey,
               NSStrikethroughColorAttributeName     : REStrikethroughColorAttributeJSONKey,
               NSObliquenessAttributeName            : REObliquenessAttributeJSONKey,
               NSExpansionAttributeName              : REExpansionAttributeJSONKey,
               NSShadowAttributeName                 : REShadowAttributeJSONKey,

               RELineSpacingAttributeName            : RELineSpacingAttributeJSONKey,
               REParagraphSpacingAttributeName       : REParagraphSpacingAttributeJSONKey,
               RETextAlignmentAttributeName          : RETextAlignmentAttributeJSONKey,
               REFirstLineHeadIndentAttributeName    : REFirstLineHeadIndentAttributeJSONKey,
               REHeadIndentAttributeName             : REHeadIndentAttributeJSONKey,
               RETailIndentAttributeName             : RETailIndentAttributeJSONKey,
               RELineBreakModeAttributeName          : RELineBreakModeAttributeJSONKey,
               REMinimumLineHeightAttributeName      : REMinimumLineHeightAttributeJSONKey,
               REMaximumLineHeightAttributeName      : REMaximumLineHeightAttributeJSONKey,
               RELineHeightMultipleAttributeName     : RELineHeightMultipleAttributeJSONKey,
               REParagraphSpacingBeforeAttributeName : REParagraphSpacingBeforeAttributeJSONKey,
               REHyphenationFactorAttributeName      : REHyphenationFactorAttributeJSONKey,
               RETabStopsAttributeName               : RETabStopsAttributeJSONKey,
               REDefaultTabIntervalAttributeName     : REDefaultTabIntervalAttributeJSONKey };
  });
  return index[key];
}

NSString *textAlignmentJSONValueForAlignment(NSTextAlignment alignment) {
  static NSDictionary const * index = nil;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken, ^{
    index = @{ @0 : RETextAlignmentLeftJSONKey,
               @1 : RETextAlignmentCenterJSONKey,
               @2 : RETextAlignmentRightJSONKey,
               @3 : RETextAlignmentJustifiedJSONKey,
               @4 : RETextAlignmentNaturalJSONKey };
  });

  return index[@(alignment)];
}

NSString *lineBreakModeJSONValueForMode(NSLineBreakMode lineBreakMode) {
  static NSDictionary const * index = nil;
  static dispatch_once_t      onceToken;
  dispatch_once(&onceToken, ^{
    index = @{ @0 : RELineBreakByWordWrappingJSONKey,
               @1 : RELineBreakByCharWrappingJSONKey,
               @2 : RELineBreakByClippingJSONKey,
               @3 : RELineBreakByTruncatingHeadJSONKey,
               @4 : RELineBreakByTruncatingTailJSONKey,
               @5 : RELineBreakByTruncatingMiddleJSONKey };
  });

  return index[@(lineBreakMode)];
}

NSString *underlineStrikethroughStyleJSONValueForStyle(NSUnderlineStyle style) {
  if (!style) return REUnderlineStyleNoneJSONKey;

  NSMutableArray * components = [@[] mutableCopy];

  MSBitVector * bits = BitVector32;
  [bits setBits:@(style)];

  if (bits[3] && bits[0]) [components addObject:REUnderlineStyleDoubleJSONKey];
  else if (bits[0]) [components addObject:REUnderlineStyleSingleJSONKey];

  if (bits[1]) [components addObject:REUnderlineStyleThickJSONKey];

  if (bits[8] && bits[9]) [components addObject:REUnderlinePatternDashDotJSONKey];
  else if (bits[8]) [components addObject:REUnderlinePatternDotJSONKey];
  else if (bits[9]) [components addObject:REUnderlinePatternDashJSONKey];
  else if (bits[10]) [components addObject:REUnderlinePatternDashDotDotJSONKey];
  else [components addObject:REUnderlinePatternSolidJSONKey];

  if (bits[15]) [components addObject:REUnderlineByWordJSONKey];

  return [components componentsJoinedByString:@"-"];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utility functions
////////////////////////////////////////////////////////////////////////////////

NSString *normalizedColorJSONValueForColor(UIColor * color) {
  NSString * value = color.colorName;
  if (value && color.alpha != 1.0)
      value = [value stringByAppendingFormat:@"@%@%%", [@(color.alpha * 100.0f) stringValue]];

  if (!value && color.isRGBCompatible) value = color.rgbaHexString;

  return value;
}

BOOL exportModelDataForClassToFile(Class modelClass, NSString * fileName) {
  return NO;
}
