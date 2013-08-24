//
// RemoteConstruction.h
// Remote
//
// Created by Jason Cardwell on 10/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElementConstructionManager_Private.h"
#import "RemoteElement.h"
#import "REView.h"
#import "REConfigurationDelegate.h"
#import "REDeviceConfiguration.h"
#import "BankObject.h"
#import "CoreDataManager.h"
#import "RERemoteController.h"
#import "BankObjectPreview.h"
#import "BankObjects.h"
#import "REControlStateSet.h"
#import "RECommand.h"
#import "RECommandContainer.h"
#import "RETheme.h"
#import "REActivity.h"

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
#define kTVConfiguration      @"kTVConfiguration"
#define kPanelBackgroundColor DarkGrayColor
#define kHighlightColor       defaultTitleHighlightColor()
