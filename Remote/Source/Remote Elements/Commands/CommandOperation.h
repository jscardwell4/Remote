//
//  CommandOperation.h
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

@import Foundation;
@class Command;

@interface CommandOperation : NSOperation {
@protected
  BOOL      _executing;
  BOOL      _finished;
  BOOL      _success;
  Command * _command;
  NSError * _error;
}

@property (assign, readonly, getter = isExecuting)              BOOL      executing;
@property (assign, readonly, getter = isFinished)               BOOL      finished;
@property (nonatomic, strong, readonly)                         NSError * error;
@property (nonatomic, strong, readonly)                         Command * command;
@property (nonatomic, assign, readonly, getter = wasSuccessful) BOOL      success;

+ (instancetype)operationForCommand:(Command *)command;
- (instancetype)initWithCommand:(Command *)command;

@end

@interface ActivityCommandOperation : CommandOperation @end

@interface SwitchCommandOperation : CommandOperation @end

@interface SendCommandOperation : CommandOperation @end

@interface DelayCommandOperation : CommandOperation @end

@interface MacroCommandOperation : CommandOperation @end

@interface SystemCommandOperation : CommandOperation @end