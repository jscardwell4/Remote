//
//  MessageQueueEntry.h
//  Remote
//
//  Created by Jason Cardwell on 9/8/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

@import Foundation;
@import Moonkit;

@interface MessageQueueEntry : NSObject

@property (nonatomic, readonly) NSData * data;  /// `message` as `NSData`

@property (nonatomic, copy)   NSString * message;       /// Message to send
@property (nonatomic, strong) MSDictionary * userInfo;  /// General use storage space

@property (nonatomic, copy)   void (^completion)(BOOL, NSString *, NSError *);  /// Completion block for entry

/// message:completion:
/// @param message
/// @param completion
/// @return instancetype
+ (instancetype)message:(NSString *)message
             completion:(void(^)(BOOL success, NSString * response, NSError * error))completion;

@end
