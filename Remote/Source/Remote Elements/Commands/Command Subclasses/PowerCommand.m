//
// PowerCommand.m
// Remote
//
// Created by Jason Cardwell on 3/16/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "Command_Private.h"
#import "ComponentDevice.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);

@interface PowerCommandOperation : CommandOperation @end

@implementation PowerCommand

@dynamic state, device;

+ (PowerCommand *)onCommandForDevice:(ComponentDevice *)device {
  PowerCommand * powerCommand = [self commandInContext:device.managedObjectContext];
  powerCommand.state  = YES;
  powerCommand.device = device;
  return powerCommand;
}

+ (PowerCommand *)offCommandForDevice:(ComponentDevice *)device {
  PowerCommand * powerCommand = [self commandInContext:device.managedObjectContext];
  powerCommand.state  = NO;
  powerCommand.device = device;
  return powerCommand;
}

- (void)setState:(BOOL)state {
  [self willChangeValueForKey:@"state"];
  self.primitiveState = @(state);
  [self didChangeValueForKey:@"state"];
}

- (BOOL)state {
  [self willAccessValueForKey:@"state"];
  NSNumber * state = self.primitiveState;
  [self didAccessValueForKey:@"state"];
  return [state boolValue];
}

- (CommandOperation *)operation { return [PowerCommandOperation operationForCommand:self]; }

- (NSString *)shortDescription {
  return $(@"device:'%@', state:%@", self.primitiveDevice.name, (self.state ? @"On" : @"Off"));
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////


- (void)updateWithData:(NSDictionary *)data {
  /*
     {
       "class": "power",
       "device.uuid": "CC67B0D5-13E8-4548-BDBF-7B81CAA85A9F", // Samsung TV
       "state": "off"
     }
   */

  [super updateWithData:data];

  NSString               * state  = data[@"state"];
  NSDictionary           * device = data[@"device"];
  NSManagedObjectContext * moc    = self.managedObjectContext;

  if ([@"on" isEqualToString:state]) self.state = YES;

  if (device) {
    NSString * deviceUUID = device[@"uuid"];

    if (UUIDIsValid(deviceUUID)) {
      ComponentDevice * d = [ComponentDevice existingObjectWithUUID:deviceUUID context:moc];

      if (!d) d = [ComponentDevice importObjectFromData:device context:moc];

      self.device = d;
    }
  }

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////


- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];

  SafeSetValueForKey(self.device.commentedUUID, @"device.uuid", dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

@end

@implementation PowerCommandOperation {
  BOOL _statusReceived;
}

- (void)main {
  @try {
    PowerCommand           * powerCommand = (PowerCommand *)_command;
    CommandCompletionHandler handler      = ^(BOOL success, NSError * error)
    {
      _success = success;
      _error   = error;
      [super main];
    };

    if (powerCommand.state == YES)
      [powerCommand.device powerOn:handler];

    else
      [powerCommand.device powerOff:handler];
  } @catch(NSException * exception)   {
    MSLogErrorTag(@"wtf?");
  }
}

@end
