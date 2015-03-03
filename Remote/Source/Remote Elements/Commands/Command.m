//
// Command.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "Command.h"
#import "CommandOperation.h"
#import "RemoteElementExportSupportFunctions.h"
#import "RemoteElementImportSupportFunctions.h"
#import "JSONObjectKeys.h"
#import "Remote-Swift.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);

@implementation Command

@dynamic button, indicator;

+ (instancetype)command {
  return [self commandInContext:[DataManager mainContext]];
}

+ (instancetype)commandInContext:(NSManagedObjectContext *)context {
  return [self createInContext:context];
}

- (void)execute:(void (^)(BOOL success, NSError * error))completion {
  MSLogDebugTag(@"");
  __weak CommandOperation * operation = self.operation;

  [operation setCompletionBlock:^{ if (completion) completion(operation.wasSuccessful, nil); }];
  [operation start];
}

- (CommandOperation *)operation { return [CommandOperation operationForCommand:self]; }

- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];

  dictionary[@"class"] = classJSONValueForCommand(self);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////


+ (instancetype)importObjectFromData:(NSDictionary *)data context:(NSManagedObjectContext *)moc {
  if (!isDictionaryKind(data)) return nil;

  if (self == [Command class]) {
    Class commandClass = commandClassForImportKey(((NSDictionary *)data)[@"class"]);
    return [commandClass importObjectFromData:data context:moc];
  } else {
    return [super importObjectFromData:data context:moc];
  }
}

@end
