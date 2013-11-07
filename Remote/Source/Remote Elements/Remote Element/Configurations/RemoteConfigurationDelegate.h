//
// RemoteConfigurationDelegate.h
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "ConfigurationDelegate.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RemoteConfigurationDelegate
////////////////////////////////////////////////////////////////////////////////
@class Remote;

@interface RemoteConfigurationDelegate : ConfigurationDelegate

- (Remote *)remote;

@end
