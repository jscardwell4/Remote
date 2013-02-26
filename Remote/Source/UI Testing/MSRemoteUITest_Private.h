//
// MSRemoteUITest_Private.h
// iPhonto
//
// Created by Jason Cardwell on 2/12/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "MSRemoteUITest.h"

@class   RemoteController;

@interface MSRemoteUITest () {
    @protected
        struct {
        BOOL   quietMode;
        BOOL   suppressDialog;
    } _flags;
}

@property (nonatomic, strong) NSManagedObjectContext * objectContext;

@property (nonatomic, strong) RemoteController * remoteController;

- (void)testComplete;

@end
