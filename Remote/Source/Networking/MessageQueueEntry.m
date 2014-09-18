//
//  MessageQueueEntry.m
//  Remote
//
//  Created by Jason Cardwell on 9/8/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

#import "MessageQueueEntry.h"
@import Moonkit;

@implementation MessageQueueEntry

/// message:completion:
/// @param message
/// @param completion
/// @return instancetype
+ (instancetype)message:(NSString *)message
             completion:(void (^)(BOOL success, NSString * response, NSError * error))completion
{

  if (StringIsEmpty(message)) ThrowInvalidNilArgument(message);

  MessageQueueEntry * entry = [self new];
  entry.message    = message;
  entry.completion = completion;
  entry.userInfo   = [MSDictionary dictionary];

  return entry;
  
}

/// data
/// @return NSData *
- (NSData *)data { return (self.message ? [self.message dataUsingEncoding:NSUTF8StringEncoding] : nil); }

/// description
/// @return NSString
- (NSString *)description {

  return $(@"MessageQueueEntry(\n"
           "  message: '%@'\n"
           "  userInfo: {\n"
           "    %@\n"
           "  }", [self.message stringByReplacingReturnsWithSymbol], [self.userInfo formattedDescription]);

}

@end
