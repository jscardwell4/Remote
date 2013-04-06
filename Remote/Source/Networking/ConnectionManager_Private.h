//
// ConnectionManager_Private.h
// Remote
//
// Created by Jason Cardwell on 9/14/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ConnectionManager.h"
#import "NetworkDevice.h"
#import "IRLearnerViewController.h"
#import "IRLearner.h"
#import "SettingsManager.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import "GlobalCacheConnectionManager.h"
#import "MSRemoteAppController.h"
#import "RECommand.h"
#import "CoreDataManager.h"

@interface ConnectionManager () {
    dispatch_queue_t        _reachabilityQueue; /// Queue maintained for reachability notifications
    MSNetworkReachability * _reachability;      /// Monitors changes in connectivity
    struct {
        BOOL autoConnect;               /// Whether to automatically connect to known devices
        BOOL autoListen;                /// Whether to automatically listen for new devices
        BOOL wifiAvailable;             /// Whether wifi connectivity is currently available
        BOOL simulateCommandSuccess;    /// Whether to simulate send operations
    } _flags;
}

@end
