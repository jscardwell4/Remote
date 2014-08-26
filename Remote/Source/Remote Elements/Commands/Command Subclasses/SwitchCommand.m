//
//  SwitchCommand.m
//  Remote
//
//  Created by Jason Cardwell on 3/25/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "Command_Private.h"
#import "RemoteController.h"
#import "Remote.h"
#import "RemoteElementExportSupportFunctions.h"
#import "RemoteElementImportSupportFunctions.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);

@interface SwitchCommandOperation : CommandOperation @end

@implementation SwitchCommand

@dynamic target;

- (CommandOperation *)operation {
  return [SwitchCommandOperation operationForCommand:self];
}

- (SwitchCommandType)type {
  [self willAccessValueForKey:@"type"];
  NSNumber * type = [self primitiveValueForKey:@"type"];

  [self didAccessValueForKey:@"type"];

  return IntValue(type);
}

- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];

  SetValueForKeyIfNotDefault(switchCommandTypeJSONValueForSwitchCommand(self), @"type", dictionary);
  SetValueForKeyIfNotDefault((self.type ?
                             self.target :
                             [[Remote existingObjectWithUUID:self.target
                                                     context:self.managedObjectContext] commentedUUID]),
                             @"target",
                             dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

- (void)updateWithData:(NSDictionary *)data {
  /*
       {
           "class": "switch",
           "type": "remote",
           "target": "B0EA5B35-5CF6-40E9-B302-0F164D4A7ADD" // Home Screen
       }
   */

  [super updateWithData:data];

  [self setPrimitiveValue:@(switchCommandTypeFromImportKey(data[@"type"])) forKey:@"type"];

  NSString * target = data[@"target"];

  if (UUIDIsValid(target)) self.target = target;

}

@end

@implementation SwitchCommandOperation

- (void)main {
  @try {
    NSManagedObjectContext * moc        = _command.managedObjectContext;
    RemoteController       * controller = [RemoteController remoteController:moc];

    if (((SwitchCommand *)_command).type == SwitchModeCommand) {
      Remote   * remote = controller.currentRemote;
      NSString * mode   = ((SwitchCommand *)_command).target;

      remote.currentMode = mode;
      _success           = [remote.currentMode isEqualToString:mode];
    } else if (((SwitchCommand *)_command).type == SwitchRemoteCommand)   {
      Remote * remote = [Remote existingObjectWithUUID:((SwitchCommand *)_command).target context:moc];

      if (remote) {
        controller.currentRemote = remote;
        _success                 = controller.currentRemote == remote;
      } else _success = NO;
    } else
      _success = NO;

    [super main];
  } @catch(NSException * exception)   {
    MSLogError(@"command failed");
  }
}

@end
