//
// RemoteConstruction.h
// Remote
//
// Created by Jason Cardwell on 10/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElementConstructionManager_Private.h"
#import "RemoteElement.h"
#import "Remote.h"
#import "ButtonGroup.h"
#import "Button.h"
#import "RemoteElementView.h"
#import "ComponentDeviceConfiguration.h"
//#import "BankObject.h"
#import "CoreDataManager.h"
#import "RemoteController.h"
#import "BankObjectPreview.h"
#import "Bankables.h"
#import "ControlStateSet.h"
#import "ControlStateImageSet.h"
#import "ControlStateTitleSet.h"
#import "ControlStateColorSet.h"
#import "Command.h"
#import "CommandContainer.h"
#import "CommandSet.h"
#import "CommandSetCollection.h"
#import "Theme.h"
#import "Activity.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constraints
////////////////////////////////////////////////////////////////////////////////

#define SetConstraints(ELEMENT, FORMAT, ...)             \
    [ELEMENT setConstraintsFromString:                   \
     [FORMAT stringByReplacingOccurrencesWithDictionary: \
      NSDictionaryOfVariableBindingsToIdentifiers(ELEMENT,##__VA_ARGS__)]]

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Default Constants
////////////////////////////////////////////////////////////////////////////////

#define kDefaultFontName      @"Optima-Bold"
#define kArrowFontName        @"HiraMinProN-W6"
#define kUpArrow              @"\u25B2"
#define kDownArrow            @"\u25BC"
#define kLeftArrow            @"\u25C0"
#define kRightArrow           @"\u25B6"
#define kTVMode               @"tv"
#define kPanelBackgroundColor DarkGrayColor
#define kHighlightColor       defaultTitleHighlightColor()
