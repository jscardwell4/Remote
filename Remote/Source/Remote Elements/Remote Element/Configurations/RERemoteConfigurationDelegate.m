//
//  RERemoteConfigurationDelegate.m
//  Remote
//
//  Created by Jason Cardwell on 3/23/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REConfigurationDelegate_Private.h"


@implementation RERemoteConfigurationDelegate


+ (instancetype)delegateForRemoteElement:(RERemote *)element
{
    assert(element);
    __block RERemoteConfigurationDelegate * configurationDelegate = nil;
    [element.managedObjectContext performBlockAndWait:
     ^{
         configurationDelegate = [self MR_createInContext:element.managedObjectContext];
         configurationDelegate.element = element;
     }];

    return configurationDelegate;
}
- (RERemote *)remote { return (RERemote *)self.element; }
- (REConfigurationDelegate *)delegate { return self; }
- (void)setDelegate:(REConfigurationDelegate *)delegate {}

@end
