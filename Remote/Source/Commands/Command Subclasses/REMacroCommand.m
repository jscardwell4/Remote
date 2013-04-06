//
// MacroCommand.m
// Remote
//
// Created by Jason Cardwell on 7/20/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RECommand_Private.h"
static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = COMMAND_F_C;

@interface REMacroCommandOperation : RECommandOperation @end

@implementation REMacroCommand

@dynamic commands;

@synthesize queue = _queue;

+ (instancetype)commandInContext:(NSManagedObjectContext *)context
{
    __block REMacroCommand * macroCommand = nil;
    [context performBlockAndWait:
     ^{
         macroCommand = [super commandInContext:context];
         macroCommand.primitiveIndicator = @YES;
     }];

    return macroCommand;
}

- (RECommand *)objectAtKeyedSubscript:(NSString *)uuid
{
    return [self.commands objectPassingTest:^BOOL(RECommand * obj, NSUInteger idx) {
        return [obj.uuid isEqualToString:uuid];
    }];
}

- (NSOperationQueue *)queue
{
    if (!_queue)
        _queue = [NSOperationQueue operationQueueWithName:@"com.moondeerstudios.macro"];
    return _queue;
}

- (void)execute:(void (^)(BOOL, BOOL))completion
{
    if (self.commands.count)
    {
        _operations = [[self.commands valueForKey:@"operation"] array];


        RECommandOperation * precedingOperation = nil;
        for (RECommandOperation * operation in _operations) {
            if (precedingOperation) [operation addDependency:precedingOperation];
            precedingOperation = operation;
        }

        [precedingOperation setCompletionBlock:^{
            MSLogDebugTag(@"command dispatch complete");
            if (completion)
            {
                BOOL finished = !([_operations objectPassingTest:
                                   ^BOOL(RECommandOperation * op, NSUInteger idx)
                                   {
                                       return op.isCancelled;
                                   }]);
                BOOL success = !([_operations objectPassingTest:
                                  ^BOOL(RECommandOperation * op, NSUInteger idx)
                                  {
                                      return !op.wasSuccessful;
                                  }]);
                completion(finished, success);
            }
       }];

        [self.queue addOperations:_operations waitUntilFinished:NO];
    }
    
    else if (completion) completion(YES, YES);
}

- (RECommandOperation *)operation
{
    return [REMacroCommandOperation operationForCommand:self];
}


- (void)insertObject:(RECommand *)command inCommandsAtIndex:(NSUInteger)idx
{
    NSIndexSet * indices = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
    [self.primitiveCommands insertObject:command atIndex:idx];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
}

- (void)removeObjectFromCommandsAtIndex:(NSUInteger)idx
{
    NSIndexSet * indices = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
    [self.primitiveCommands removeObjectAtIndex:idx];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
}

- (void)insertCommands:(NSArray *)commands atIndexes:(NSIndexSet *)indices
{
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
    [self.primitiveCommands insertObjects:commands atIndexes:indices];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
}

- (void)removeCommandsAtIndexes:(NSIndexSet *)indices
{
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
    [self.primitiveCommands removeObjectsAtIndexes:indices];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
}

- (void)replaceObjectInCommandsAtIndex:(NSUInteger)idx withObject:(RECommand *)command
{
    NSIndexSet * indices = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indices forKey:@"commands"];
    self.primitiveCommands[idx] = command;
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indices forKey:@"commands"];
}

- (void)replaceCommandsAtIndexes:(NSIndexSet *)indices withCommands:(NSArray *)commands
{
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indices forKey:@"commands"];
    [self.primitiveCommands replaceObjectsAtIndexes:indices withObjects:commands];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indices forKey:@"commands"];
}

- (void)addCommandsObject:(RECommand *)command
{
    NSIndexSet * indices = [NSIndexSet indexSetWithIndex:[self.primitiveCommands count]];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
    [self.primitiveCommands addObject:command];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
}

- (void)removeCommandsObject:(RECommand *)command
{
    NSUInteger   idx = [self.primitiveCommands indexOfObject:command];
    if (idx != NSNotFound)
    {
        NSIndexSet * indices = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
        [self.primitiveCommands removeObject:command];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
    }
}

- (void)addCommands:(NSOrderedSet *)commands
{
    if ([commands count])
    {
        NSIndexSet * indices = [NSIndexSet indexSetWithIndexesInRange:
                                NSMakeRange([self.primitiveCommands count], [commands count])];
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
        [self.primitiveCommands addObjectsFromArray:[commands array]];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"commands"];
    }
}

- (void)removeCommands:(NSOrderedSet *)commands
{
    NSIndexSet * indices = [self.primitiveCommands
                            indexesOfObjectsPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop){
                                return YES;
                            }];

    if ([indices count])
    {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
        [self.primitiveCommands removeObjectsAtIndexes:indices];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indices forKey:@"commands"];
    }
}

- (NSUInteger)count { return [self.primitiveCommands count]; }

- (RECommand *)objectAtIndexedSubscript:(NSUInteger)idx { return self.primitiveCommands[idx]; }

- (void)setObject:(RECommand *)obj atIndexedSubscript:(NSUInteger)idx
{
    [self insertObject:obj inCommandsAtIndex:idx];
}

- (NSString *)shortDescription
{
    return $(@"commands:(%@)",
             [[[self.primitiveCommands array] valueForKeyPath:@"className"] componentsJoinedByString:@", "]);
}

@end

@implementation REMacroCommandOperation

- (void)main
{
    @try
    {
        NSArray * commandOperations = [[((REMacroCommand *)_command).commands
                                            valueForKey:@"operation"] array];
        RECommandOperation * precedingOperation = nil;
        for (RECommandOperation * operation in commandOperations) {
            if (precedingOperation) [operation addDependency:precedingOperation];
            precedingOperation = operation;
        }

        [((REMacroCommand *)_command).queue addOperations:commandOperations
                                        waitUntilFinished:YES];

        _success = !([commandOperations objectPassingTest:
                      ^BOOL(RECommandOperation * op, NSUInteger idx)
                      {
                          return !op.wasSuccessful;
                      }]);


        [super main];
    }
    @catch (NSException * exception)
    {
        MSLogDebugTag(@"wtf?");
    }
}

@end
