//
//  RemoteElementExportSupportFunctions.h
//  Remote
//
//  Created by Jason Cardwell on 10/12/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import MoonKit;
#import "MSRemoteMacros.h"
#import "RETypedefs.h"

@class RemoteElement, SystemCommand, CommandSet, Command, SwitchCommand, Button;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Types, Subtypes and Roles
////////////////////////////////////////////////////////////////////////////////

NSString * typeJSONValueForRemoteElement(RemoteElement * element);
NSString * roleJSONValueForRemoteElement(RemoteElement * element);
NSString * roleJSONValueForRERole(RERole role);

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element State
////////////////////////////////////////////////////////////////////////////////

NSString * stateJSONValueForButton(Button * element);

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Element Shape, Style & Theme
////////////////////////////////////////////////////////////////////////////////

NSString * shapeJSONValueForRemoteElement(RemoteElement * element);
NSString * styleJSONValueForRemoteElement(RemoteElement * element);

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Commands
////////////////////////////////////////////////////////////////////////////////

NSString * systemCommandTypeJSONValueForSystemCommand(SystemCommand * command);
NSString * switchCommandTypeJSONValueForSwitchCommand(SwitchCommand * command);
NSString * commandSetTypeJSONValueForCommandSet(CommandSet * commandSet);
NSString * classJSONValueForCommand(Command * command);

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote
////////////////////////////////////////////////////////////////////////////////

NSString * panelKeyForPanelAssignment(REPanelAssignment assignment);

////////////////////////////////////////////////////////////////////////////////
#pragma mark Control state sets
////////////////////////////////////////////////////////////////////////////////

NSString * titleAttributesJSONKeyForProperty(NSString * property);
NSString * titleSetAttributeJSONKeyForKey(NSString * key);
NSString * titleSetAttributeJSONKeyForName(NSString * key);
NSString * textAlignmentJSONValueForAlignment(NSTextAlignment alignment);
NSString * lineBreakModeJSONValueForMode(NSLineBreakMode lineBreakMode);
NSString * underlineStrikethroughStyleJSONValueForStyle(NSUnderlineStyle style);

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utility functions
////////////////////////////////////////////////////////////////////////////////

NSString * normalizedColorJSONValueForColor(UIColor * color);
