//
// IRCode.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import Moonkit;
#import "MSRemoteMacros.h"
#import "BankableModelObject.h"

@class ComponentDevice, IRCodeset, Manufacturer;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - IR Code
////////////////////////////////////////////////////////////////////////////////

@interface IRCode : BankableModelObject

@property (nonatomic, assign) NSNumber        * frequency;
@property (nonatomic, assign) NSNumber        * offset;
@property (nonatomic, assign) NSNumber        * repeatCount;
@property (nonatomic, strong) NSString        * onOffPattern;
@property (nonatomic, strong) NSString        * prontoHex;
@property (nonatomic, strong) ComponentDevice * device;
@property (nonatomic, assign) BOOL              setsDeviceInput;
@property (nonatomic, copy)   NSString        * codeset;
@property (nonatomic, strong) Manufacturer    * manufacturer;

/// isValidOnOffPattern:
/// @param pattern
/// @return BOOL
+ (BOOL)isValidOnOffPattern:(NSString *)pattern;

/// compressedOnOffPatternFromPattern:
/// @param pattern
/// @return NSString *
+ (NSString *)compressedOnOffPatternFromPattern:(NSString *)pattern;

@end
