//
// RemoteElementConstructionManager.h
// Remote
//
// Created by Jason Cardwell on 10/23/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteConstruction.h"

@interface RemoteElementConstructionManager : NSObject

- (BOOL)buildRemoteControllerInContext:(NSManagedObjectContext *)context;

+ (RemoteElementConstructionManager *)sharedManager;

@end

#define ConstructionManager [RemoteElementConstructionManager sharedManager]
