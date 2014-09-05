//
// IRCodeFunctions.h
// Remote
//
// Created by Jason Cardwell on 3/19/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"
@class IRCode;

NSString * iTachIRFormatFromProntoHex(NSString * prontoHex);
NSString * iTachIRFormatWithRepeatOffsetIDFromProntoHex(NSUInteger repeat, NSUInteger offset, NSUInteger tag, NSString * prontoHex);
IRCode   * codeFromProntoHexInContext(NSString * prontoHex, NSManagedObjectContext * context);
