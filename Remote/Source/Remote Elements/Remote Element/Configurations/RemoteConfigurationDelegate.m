//
//  RemoteConfigurationDelegate.m
//  Remote
//
//  Created by Jason Cardwell on 3/23/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "ConfigurationDelegate_Private.h"


@implementation RemoteConfigurationDelegate


+ (instancetype)delegateForRemoteElement:(Remote *)element
{
    assert(element);
    __block RemoteConfigurationDelegate * configurationDelegate = nil;
    [element.managedObjectContext performBlockAndWait:
     ^{
         configurationDelegate = [self MR_createInContext:element.managedObjectContext];
         configurationDelegate.element = element;
     }];

    return configurationDelegate;
}
- (Remote *)remote { return (Remote *)self.element; }
- (ConfigurationDelegate *)delegate { return self; }
- (void)setDelegate:(ConfigurationDelegate *)delegate {}

@end
