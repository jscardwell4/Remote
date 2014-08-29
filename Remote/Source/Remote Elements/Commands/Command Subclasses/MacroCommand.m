//
// MacroCommand.m
// Remote
//
// Created by Jason Cardwell on 7/20/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "Command_Private.h"
static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_COMMAND | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);

@interface MacroCommandOperation : CommandOperation @end

@implementation MacroCommand

@dynamic commands;

@synthesize queue = __queue;

- (void)awakeFromInsert {
  [super awakeFromInsert];

  self.indicator = YES;
}

- (id)keySubscriptedCollection { return self.commands; }
- (id)indexSubscriptedCollection { return self.commands; }

- (NSOperationQueue *)queue {
  if (!__queue) __queue = [NSOperationQueue operationQueueWithName:@"com.moondeerstudios.macro"];

  return __queue;
}

- (void)execute:(void (^)(BOOL success, NSError * error))completion {
  if (self.commands.count) {
    _operations = [[self.commands valueForKey:@"operation"] array];


    CommandOperation * precedingOperation = nil;

    for (CommandOperation * operation in _operations) {
      if (precedingOperation) [operation addDependency:precedingOperation];

      precedingOperation = operation;
    }

    [precedingOperation setCompletionBlock:
     ^{
      MSLogDebugTag(@"command dispatch complete");

      if (completion) {
        __block NSError * error = nil;
        BOOL success = !([_operations objectPassingTest:
                          ^BOOL (CommandOperation * op, NSUInteger idx)
        {
          return (!op.wasSuccessful && (error = op.error));
        }]);
        completion(success, error);
      }
    }];

    [self.queue addOperations:_operations waitUntilFinished:NO];
  } else if (completion) completion(YES, nil);
}

- (CommandOperation *)operation { return [MacroCommandOperation operationForCommand:self]; }

- (void)insertObject:(Command *)command inCommandsAtIndex:(NSUInteger)idx {
  NSIndexSet * indices = [NSIndexSet indexSetWithIndex:idx];
  [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
  [self.primitiveCommands insertObject:command atIndex:idx];
  [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
}

- (void)removeObjectFromCommandsAtIndex:(NSUInteger)idx {
  NSIndexSet * indices = [NSIndexSet indexSetWithIndex:idx];
  [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
  [self.primitiveCommands removeObjectAtIndex:idx];
  [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
}

- (void)insertCommands:(NSArray *)commands atIndexes:(NSIndexSet *)indices {
  [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
  [self.primitiveCommands insertObjects:commands atIndexes:indices];
  [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
}

- (void)removeCommandsAtIndexes:(NSIndexSet *)indices {
  [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
  [self.primitiveCommands removeObjectsAtIndexes:indices];
  [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
}

- (void)replaceObjectInCommandsAtIndex:(NSUInteger)idx withObject:(Command *)command {
  NSIndexSet * indices = [NSIndexSet indexSetWithIndex:idx];
  [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indices forKey:@"commands"];
  self.primitiveCommands[idx] = command;
  [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indices forKey:@"commands"];
}

- (void)replaceCommandsAtIndexes:(NSIndexSet *)indices withCommands:(NSArray *)commands {
  [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indices forKey:@"commands"];
  [self.primitiveCommands replaceObjectsAtIndexes:indices withObjects:commands];
  [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indices forKey:@"commands"];
}

- (void)addCommandsObject:(Command *)command {
  NSIndexSet * indices = [NSIndexSet indexSetWithIndex:[self.primitiveCommands count]];
  [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
  [self.primitiveCommands addObject:command];
  [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
}

- (void)removeCommandsObject:(Command *)command {
  NSUInteger idx = [self.primitiveCommands indexOfObject:command];

  if (idx != NSNotFound) {
    NSIndexSet * indices = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
    [self.primitiveCommands removeObject:command];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
  }
}

- (void)addCommands:(NSOrderedSet *)commands {
  if ([commands count]) {
    NSIndexSet * indices = [NSIndexSet indexSetWithIndexesInRange:
                            NSMakeRange([self.primitiveCommands count], [commands count])];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
    [self.primitiveCommands addObjectsFromArray:[commands array]];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
  }
}

- (void)removeCommands:(NSOrderedSet *)commands {
  NSIndexSet * indices = [self.primitiveCommands
                          indexesOfObjectsPassingTest:^BOOL (id obj, NSUInteger idx, BOOL * stop) {
    return YES;
  }];

  if ([indices count]) {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
    [self.primitiveCommands removeObjectsAtIndexes:indices];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
  }
}

- (NSUInteger)count { return [self.primitiveCommands count]; }

- (void)setObject:(Command *)obj atIndexedSubscript:(NSUInteger)idx {
  [self insertObject:obj inCommandsAtIndex:idx];
}

- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];

  SafeSetValueForKey([self valueForKeyPath:@"commands.JSONDictionary"], @"commands", dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

- (NSString *)name {
  [self willAccessValueForKey:@"name"];
  NSString * name = [self primitiveValueForKey:@"name"];
  [self didAccessValueForKey:@"name"];

  if (StringIsEmpty(name))
    name = [[self.commands valueForKeyPath:@"className"] componentsJoinedByString:@" \u2192 "];

  return name;
}

- (NSString *)shortDescription {
  return $(@"commands:(%@)",
           ([[[self.primitiveCommands array] valueForKeyPath:@"className"] componentsJoinedByString:@", "]) ?: @"nil");
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////


- (void)updateWithData:(NSDictionary *)data {
  /*
     {
       "class": "macro",
       "commands": [
           {
               "class": "power",
               "device.uuid": "CC67B0D5-13E8-4548-BDBF-7B81CAA85A9F", // Samsung TV
               "state": "off"
           },
           {
               "class": "power",
               "device.uuid": "18A7C007-4DED-48D6-9A72-FA63640C49B5", // AV Receiver
               "state": "off"
           }
       ]
     }
   */

  [super updateWithData:data];
  NSArray                * commands = data[@"commands"];
  NSManagedObjectContext * moc      = self.managedObjectContext;

  if (commands && isArrayKind(commands)) {

    NSMutableArray * macroCommands = [(NSArray *)commands mutableCopy];
    [macroCommands filter:^BOOL (id obj) {
      return isDictionaryKind(obj) && commandClassForImportKey([obj valueForKey:@"class"]) != NULL;
    }];
    [macroCommands map:^id (NSDictionary * obj, NSUInteger idx) {
      Class commandClass = commandClassForImportKey(obj[@"class"]);
      Command * command = [commandClass importObjectFromData:obj context:moc];
      return command ?: NullObject;
    }];
    [macroCommands removeNullObjects];
    self.commands = [macroCommands orderedSet];

  }
}

@end

@implementation MacroCommandOperation

- (void)main {
  @try {
    MacroCommand * command           = (MacroCommand *)_command;
    NSOrderedSet * commandOperations = [command.commands valueForKey:@"operation"];

    [commandOperations enumerateObjectsUsingBlock:
     ^(CommandOperation * operation, NSUInteger idx, BOOL * stop)
    {
      if (idx) [operation addDependency:(CommandOperation *)commandOperations[idx - 1]];
    }];

    [command.queue addOperations:[commandOperations array] waitUntilFinished:YES];

    _success = !([commandOperations objectPassingTest:
                  ^BOOL (CommandOperation * op, NSUInteger idx)
    {
      return (!op.wasSuccessful && (_error = op.error));
    }]);


    [super main];
  } @catch(NSException * exception) {
    MSLogDebugTag(@"wtf?");
  }
}

@end
