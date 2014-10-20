//
// NetworkDeviceMulticastConnection.h
// Remote
//
// Created by Jason Cardwell on 9/10/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
@import CocoaLumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"

#import "NetworkDeviceConnection.h"

/**
 The `NetworkDeviceMulticastConnection` class handles managing the resources necessary for
 joining a multicast group over UDP to listen for beacons or send packets.
 */
@interface NetworkDeviceMulticastConnection : NetworkDeviceConnection

/// connectionWithAddress:port:delegate:
/// @param address
/// @param port
/// @param delegate
/// @return instancetype
+ (instancetype)connectionWithAddress:(NSString *)address
                                 port:(NSString *)port
                             delegate:(id<NetworkDeviceConnectionDelegate>)delegate;

@end
