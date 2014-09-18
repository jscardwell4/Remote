//
// NetworkDevice.h
// Remote
//
// Created by Jason Cardwell on 9/25/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import Moonkit;
#import "MSRemoteMacros.h"
#import "BankableModelObject.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract
////////////////////////////////////////////////////////////////////////////////


@interface NetworkDevice : BankableModelObject

/// deviceExistsWithUniqueIdentifier:
/// @param identifier
/// @return BOOL
+ (BOOL)deviceExistsWithUniqueIdentifier:(NSString *)identifier;

@property (nonatomic, strong, readonly) NSSet    * componentDevices;
@property (nonatomic, copy,   readonly) NSString * uniqueIdentifier;


@end

