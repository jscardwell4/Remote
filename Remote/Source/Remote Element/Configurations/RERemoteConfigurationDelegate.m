//
//  RERemoteConfigurationDelegate.m
//  Remote
//
//  Created by Jason Cardwell on 3/23/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REConfigurationDelegate_Private.h"


@implementation RERemoteConfigurationDelegate

- (RERemote *)remote { return (RERemote *)self.remoteElement; }

- (void)awakeFromFetch {
    [super awakeFromFetch];
    if (!self.currentConfiguration)
        self.currentConfiguration = REDefaultConfiguration;
}



@end
