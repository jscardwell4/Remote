//
// MSRemoteWindow.h
// iPhonto
//
// Created by Jason Cardwell on 10/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@interface MSRemoteWindow : UIWindow

@property (nonatomic, readonly) dispatch_time_t             lastEvent;
@property (nonatomic, getter = shouldTrackLastEvent) BOOL   trackLastEvent;

- (void)dimScreen;

@end
