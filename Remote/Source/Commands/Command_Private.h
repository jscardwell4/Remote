//
// Command_Private.h
// iPhonto
//
// Created by Jason Cardwell on 3/17/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "Command.h"

@interface Command ()

@property (nonatomic, weak) id <CommandDelegate>   delegate;

/**
 * Generates a string suitable for logging containing the button's basic attribute values.
 * @return The string containing the button's info.
 */
- (NSString *)debugDescription;

/**
 * MSDebugDescription protocol method thatgenerates a string suitable for logging containing the
 * button's basic attribute values and a more complete rundown its other attributes depending on the
 * verbosity level specified.
 * @param `NSUInteger` specifying how detailed the string returned should be.
 * @return The string containing the button's info.
 */
- (NSString *)debugDescriptionWithVerbosity:(NSUInteger)verbosity
                                   tabDepth:(NSUInteger)tabDepth
                                      inset:(NSUInteger)inset;

@end
