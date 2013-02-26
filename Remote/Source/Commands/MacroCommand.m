//
// MacroCommand.m
// iPhonto
//
// Created by Jason Cardwell on 7/20/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "Command.h"
#import "Command_Private.h"

// static int ddLogLevel         = DefaultDDLogLevel;
static int   ddLogLevel = LOG_LEVEL_VERBOSE;

@interface MacroCommand ()

/**
 * Helper method that returns the URI for the specified command. Obtains a permanent ID first if the
 * command has a temporary ID.
 * @param command The command for which a URI should be retrieved.
 * @return `NSURL` object containing the command's URI.
 */
- (NSURL *)uriForCommand:(Command *)command;

/// @name ￼Tracking command execution

/**
 * Holds the index of the currently executing command in the collection of commands.
 */
@property (nonatomic, assign) NSUInteger   executionIndex;

/**
 * Stores the `Command` objects to be executed in order when the `MacroCommand` is executed.
 */
@property (nonatomic, strong) NSMutableArray * commands;

@end

@implementation MacroCommand

@dynamic commands;
@synthesize executionIndex;

/// @name ￼Creating a MacroCommand

+ (MacroCommand *)macroCommandInContext:(NSManagedObjectContext *)context {
    MacroCommand * macroCommand =
        [NSEntityDescription insertNewObjectForEntityForName:@"MacroCommand"
                                      inManagedObjectContext:context];

    return macroCommand;
}

/// @name ￼Executing commands

- (void)execute:(id <CommandDelegate> )sender {
    DDLogVerbose(@"[MacroCommand] self.commands: %@", [self.commands debugDescription]);
    [super execute:sender];
    if ([self.commands count] == 0) [self.delegate commandDidComplete:self success:NO];

    executionIndex = 0;
    DDLogVerbose(@"%@ executing command:%@", ClassTagSelectorString, self[executionIndex]);
    [self[executionIndex] execute:self];
}

/**
 * Executes the next command in the collection until out of commands to execute.
 * @param command The command that has completed execution.
 * @param success Whether it completed successfully.
 */
- (void)commandDidComplete:(Command *)command success:(BOOL)success {
    DDLogVerbose(@"execution completed %@ for command at index %i",
                 success ? @"successfully" : @"unsuccessfully", executionIndex);

    if (success && [self.commands count] > ++executionIndex) [self[executionIndex] execute:self];
    else [super commandDidComplete:self success:success];
}

/// @name ￼Storing commands

- (NSMutableArray *)commands {
    [self willAccessValueForKey:@"commands"];

    NSMutableArray * array = [self primitiveValueForKey:@"commands"];

    [self didAccessValueForKey:@"commands"];

    if (!array) {
        array         = [NSMutableArray array];
        self.commands = array;
    }

    return array;
}

- (NSURL *)uriForCommand:(Command *)command {
    if (ValueIsNil(command)) return nil;

    if ([command.objectID isTemporaryID])
        [command.managedObjectContext
         obtainPermanentIDsForObjects:@[command]
                                error:nil];

    NSURL * commandURI = [command.objectID URIRepresentation];

    return commandURI;
}

/// @name Managing the collection of command objects

- (void)addCommand:(Command *)command {
    NSURL * commandURI = [self uriForCommand:command];

    if (commandURI) [self.commands addObject:commandURI];
}

- (void)insertCommand:(Command *)command atIndex:(NSUInteger)index {
    if ([self.commands count] <= index) return;

    NSURL * commandURI = [self uriForCommand:command];

    if (commandURI) self.commands[index] = commandURI;
}

- (void)removeCommandAtIndex:(NSUInteger)index {
    [self.commands removeObjectAtIndex:index];
}

- (NSUInteger)numberOfCommands {
    return [self.commands count];
}

- (Command *)commandAtIndex:(NSUInteger)index {
    if (index > [self.commands count] - 1) return nil;

    NSURL             * commandURI = self.commands[index];
    NSManagedObjectID * commandID  =
        [[self.managedObjectContext persistentStoreCoordinator]
         managedObjectIDForURIRepresentation:commandURI];

    return (Command *)[self.managedObjectContext objectWithID:commandID];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self commandAtIndex:idx];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    if ([obj isKindOfClass:[Command class]]) [self insertCommand:obj atIndex:idx];
}

/// @name ￼Debugging

- (NSString *)debugDescriptionWithVerbosity:(NSUInteger)verbosity
                                   tabDepth:(NSUInteger)tabDepth
                                      inset:(NSUInteger)inset {
    NSArray * descriptionLines =
        [[super debugDescriptionWithVerbosity:verbosity
                                     tabDepth:tabDepth
                                        inset:inset]
         componentsSeparatedByRegEx:@"(?:\r\n|[\n\v\f\r\\x85\\p{Zl}\\p{Zp}])"];
    NSString * insetString = [NSString stringFilledWithCharacter:' ' count:inset];
    NSString * tabString   = [NSString stringFilledWithCharacter:' '
                                                           count:MSDefaultTabWidth * tabDepth];
    NSString        * singleTab   = [NSString stringFilledWithCharacter:' ' count:MSDefaultTabWidth];
    NSMutableString * description =
        [NSMutableString stringWithString:descriptionLines[0]];

    for (int i = 1; i < [descriptionLines count] - 1; i++) {
        [description appendFormat:@"\n%@", descriptionLines[i]];
    }

    [description appendFormat:@"\n%@%@        commands:\n", tabString, insetString];

    for (int i = 0; i < [self.commands count]; i++) {
        Command * command = [self commandAtIndex:i];

        [description appendFormat:@"        %@%@%@%@\n", singleTab, tabString, insetString,
         [command debugDescriptionWithVerbosity:verbosity
                                       tabDepth:tabDepth + 1
                                          inset:inset + 8]];
    }

    [description appendFormat:@"%@", [descriptionLines lastObject]];

    return description;
}

@end
