//
//  RemoteConfigurationDelegate.m
//  Remote
//
//  Created by Jason Cardwell on 3/23/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteConfigurationDelegate.h"
#import "ConfigurationDelegate_Private.h"


@implementation RemoteConfigurationDelegate

- (Remote *)remote { return (Remote *)self.element; }
- (ConfigurationDelegate *)delegate { return self; }
- (void)setDelegate:(ConfigurationDelegate *)delegate {}

@end
