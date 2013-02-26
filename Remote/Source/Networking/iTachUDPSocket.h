//
// iTachUDPSocket.h
// iPhonto
//
// Created by Jason Cardwell on 9/9/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iTachUDPSocket : NSObject

@property (nonatomic, assign) BOOL   listen;
- (void)setListen:(BOOL)listen callback:(void (^)(NSString * message))callback;
@end
