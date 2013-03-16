//
// Command.m
// iPhonto
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "Command.h"
#import "Command_Private.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation Command

@dynamic tag, button;

@synthesize delegate;

+ (Command *)commandInContext:(NSManagedObjectContext *)context {
    if (!context) return nil;

    Command * command =
        [NSEntityDescription insertNewObjectForEntityForName:ClassString([self class])
                                      inManagedObjectContext:context];

    return command;
}

/// @name ￼Executing commands

- (void)execute:(id <CommandDelegate> )sender {
    self.delegate = sender;
}

/**
 * Default implementation simply passes the results up to the delegate assigned.
 * @param command The command that has completed execution.
 * @param success Whether execution was successful.
 */
- (void)commandDidComplete:(Command *)command success:(BOOL)success {
    [self.delegate commandDidComplete:self success:success];
}

#pragma mark - Debugging

- (NSString *)debugDescription {
    return [super debugDescription];

    NSMutableString * description = [NSMutableString string];
    NSString        * className   = ClassString([self class]);
    NSString        * tabString   = [NSString stringFilledWithCharacter:' ' count:MSDefaultTabWidth];

    // Add the class name tag
    [description appendFormat:@"<%@>", className];

    // Add the "tag" value
    [description appendFormat:@"\n%@tag:%i", tabString, self.tag];

    // Add closing tag
    [description appendFormat:@"\n</%@>", className];

    return description;
}

- (NSString *)debugDescriptionWithVerbosity:(NSUInteger)verbosity
                                   tabDepth:(NSUInteger)tabDepth
                                      inset:(NSUInteger)inset {
    NSString * insetString = [NSString stringFilledWithCharacter:' ' count:inset];
    NSString * tabString   = [NSString stringFilledWithCharacter:' '
                                                           count:MSDefaultTabWidth * tabDepth];
    NSString * singleTab = [NSString stringFilledWithCharacter:' ' count:MSDefaultTabWidth];

    // create return string
    NSArray * descriptionLines =
        [[self debugDescription]
         componentsSeparatedByRegEx:@"(?:\r\n|[\n\v\f\r\\x85\\p{Zl}\\p{Zp}])"];
    NSMutableString * description =
        [NSMutableString stringWithFormat:@"%@", descriptionLines[0]];

    for (int i = 1; i < [descriptionLines count] - 1; i++) {
        [description appendFormat:@"\n%@%@%@%@",
         tabString, singleTab, insetString, descriptionLines[i]];
    }

    [description appendFormat:@"\n%@%@%@", tabString, insetString, [descriptionLines lastObject]];

    return description;
}

@end
