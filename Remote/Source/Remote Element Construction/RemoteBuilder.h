//
// RemoteBuilder.h
// Remote
//
// Created by Jason Cardwell on 7/12/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

/**
 * `RemoteBuilder` is a singleton class that, when provided with an `NSManagedObjectContext`, can
 * fetch or create a <RemoteController> object and construct a multitude of elements that together
 * form a fully realized remote control interface. Currently this class is used for testing
 * purposes.
 */
@interface RemoteBuilder : NSObject

+ (RemoteBuilder *)remoteBuilderWithContext:(NSManagedObjectContext *)context;

- (RERemote *)constructDVRRemote;

- (RERemote *)constructHomeRemote;

- (RERemote *)constructPS3Remote;

- (RERemote *)constructSonosRemote;

@property (nonatomic, strong) NSManagedObjectContext * buildContext;

@end
