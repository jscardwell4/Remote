//
//  ISYDeviceConnection.h
//  Remote
//
//  Created by Jason Cardwell on 9/5/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

@import Foundation;
#import "MSKit/MSKit.h"
#import "Lumberjack/Lumberjack.h"

@class ISYDevice;

@interface ISYDeviceConnection : NSObject

/// connectionForDevice:
/// @param device description
/// @return instancetype
+ (instancetype)connectionForDevice:(ISYDevice *)device;

/// connectionWithBaseURL:
/// @param baseURL description
/// @return instancetype
+ (void)connectionWithBaseURL:(NSURL *)baseURL
                   completion:(void (^)(ISYDeviceConnection * connection))completion;

/// sendRestCommand:toNode:parameters:completion:
/// @param command description
/// @param nodeID description
/// @param parameters description
/// @param completion description
- (void)sendRestCommand:(NSString *)command
                 toNode:(NSString *)nodeID
             parameters:(NSArray *)parameters
             completion:(void (^)(BOOL success, NSError * error))completion;

/// sendSoapCommandWithBody:completion:
/// @param body description
/// @param completion description
- (void)sendSoapCommandWithBody:(NSString *)body completion:(void(^)(BOOL success, NSError * error))completion;

@property (nonatomic, strong, readonly) ISYDevice * device;
@property (nonatomic, strong, readonly) NSURL     * baseURL;

@end
