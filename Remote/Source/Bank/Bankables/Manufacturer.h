//
// Manufacturer.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"
#import "BankableModelObject.h"

@class IRCodeset, ComponentDevice;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Manufacturer
////////////////////////////////////////////////////////////////////////////////

@interface Manufacturer : BankableModelObject

+ (instancetype)manufacturerWithName:(NSString *)name context:(NSManagedObjectContext *)context;

@property (nonatomic, weak, readonly) NSSet * codesets;
@property (nonatomic, strong) NSSet * codes;
@property (nonatomic, strong) NSSet * devices;

@end
