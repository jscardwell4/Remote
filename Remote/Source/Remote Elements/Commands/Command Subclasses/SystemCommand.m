//
// SystemCommand.m
// Remote
//
// Created by Jason Cardwell on 7/13/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "Command.h"
#import "MSRemoteAppController.h"
#import "RemoteElementImportSupportFunctions.h"
#import "RemoteElementExportSupportFunctions.h"
#import "Remote-Swift.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);

// #define kSystemKeyMax 5
// #define kSystemKeyMin 0

BOOL isValidSystemType(SystemCommandType type) { return ((NSInteger)type > -1 && (NSInteger)type < 6); }

@interface SystemCommand (CoreDataGeneratedAccessors)

/// Specifies the action performed by the system command
@property (nonatomic) NSNumber * primitiveType;

@end


//@interface SystemCommandOperation : CommandOperation @end

@implementation SystemCommand

@dynamic type;

+ (SystemCommand *)commandWithType:(SystemCommandType)type {
  return [self commandWithType:type inContext:[DataManager mainContext]];
}

+ (SystemCommand *)commandWithType:(SystemCommandType)type inContext:(NSManagedObjectContext *)moc {
  if (!moc) ThrowInvalidNilArgument("context cannot be nil");

  if (!isValidSystemType(type)) ThrowInvalidArgument(type, "invalid type value");

  SystemCommand * cmd = [self commandInContext:moc];
  cmd.type = type;

  return cmd;
}

- (void)setType:(SystemCommandType)type {
  [self willChangeValueForKey:@"type"];
  self.primitiveType = @(type);
  [self didAccessValueForKey:@"type"];
}

- (SystemCommandType)type {
  [self willAccessValueForKey:@"type"];
  NSNumber * type = self.primitiveType;
  [self didAccessValueForKey:@"type"];
  return (type ? [type unsignedShortValue] : SystemCommandTypeUndefined);
}

- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];

  SetValueForKeyIfNotDefault(systemCommandTypeJSONValueForSystemCommand(self), @"type", dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

- (void)updateWithData:(NSDictionary *)data {
  [super updateWithData:data];
  self.type = systemCommandTypeFromImportKey(data[@"type"]);

}

- (CommandOperation *)operation { return [SystemCommandOperation operationForCommand:self]; }

- (NSString *)shortDescription { return $(@"type:%@", NSStringFromSystemCommandType(self.type)); }

@end

//@implementation SystemCommandOperation
//
//- (void)main {
//  @try {
//    __block BOOL    taskComplete  = NO;
//    SystemCommand * systemCommand = (SystemCommand *)_command;
//
//    switch (systemCommand.type) {
//      case SystemCommandProximitySensor: {
//        CurrentDevice.proximityMonitoringEnabled = !CurrentDevice.proximityMonitoringEnabled;
//        _success                                 = YES;
//        taskComplete                             = YES;
//      }   break;
//
//      case SystemCommandURLRequest: {
//        MSLogWarn(@"currently 'SystemCommandURLRequest' does nothing");
//        _success     = YES;
//        taskComplete = YES;
//      }   break;
//
//      case SystemCommandLaunchScreen: {
//        MSRunAsyncOnMain(^{ [AppController dismissViewController:AppController.window.rootViewController
//                                                      completion:^{ taskComplete = YES; }]; });
//      }   break;
//
//      case SystemCommandOpenSettings: {
//        MSRunAsyncOnMain(^{ [AppController showSettings]; });
//        _success     = YES;
//        taskComplete = YES;
//      }  break;
//
//      case SystemCommandOpenEditor: {
//        MSRunAsyncOnMain(^{ [AppController showEditor]; });
//        _success     = YES;
//        taskComplete = YES;
//      }    break;
//
//      default:
//        taskComplete = YES;
//        _success     = NO;
//        break;
//    }
//
//    while (!taskComplete) ;
//
//    [super main];
//  } @catch(NSException * exception)   {
//    MSLogDebugTag(@"wtf?");
//  }
//}
//
//@end
