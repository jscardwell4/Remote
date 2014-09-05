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
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"
#import "NamedModelObject.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract
////////////////////////////////////////////////////////////////////////////////


@interface NetworkDevice : NamedModelObject

/// deviceExistsWithUniqueIdentifier:
/// @param identifier description
/// @return BOOL
+ (BOOL)deviceExistsWithUniqueIdentifier:(NSString *)identifier;

/// networkDeviceForBeaconData:context:
/// @param message description
/// @param moc description
/// @return instancetype
+ (instancetype)networkDeviceFromDiscoveryBeacon:(NSString *)message context:(NSManagedObjectContext *)moc;

@property (nonatomic, strong) NSSet            * componentDevices;
@property (nonatomic, copy, readonly) NSString * uniqueIdentifier;
@property (nonatomic, readonly)       NSString * multicastGroupAddress;
@property (nonatomic, readonly)       NSString * multicastGroupPort;


@end

