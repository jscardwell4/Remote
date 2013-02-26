//
// ConnectionManager_Private.h
// iPhonto
//
// Created by Jason Cardwell on 9/14/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ConnectionManager.h"
#import "NetworkDevice.h"
@interface ConnectionManager ()

// TODO:notify sender should be a notification, not a delegate call
- (void)notifySenderForTag:(NSNumber *)tag success:(BOOL)success;

@end
