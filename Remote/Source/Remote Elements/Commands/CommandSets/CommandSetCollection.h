//
// CommandSetCollection.h
// Remote
//
// Created by Jason Cardwell on 6/29/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import MoonKit;
#import "MSRemoteMacros.h"
#import "CommandContainer.h"

@class CommandSet;

@interface CommandSetCollection : CommandContainer <NSFastEnumeration>

@property (nonatomic, strong) NSOrderedSet * commandSets;

/// Assigning a `CommandSet` to a label
- (void)setObject:(CommandSet *)commandSet forKeyedSubscript:(id)label;

/// Retrieving the `CommandSet` for a label
- (CommandSet *)objectForKeyedSubscript:(NSString *)label;

/// Retrieving the label for a `CommandSet`
- (NSString *)labelForCommandSet:(CommandSet *)commandSet;

/// Inserting a `CommandSet` and label at a specific index
- (void)insertCommandSet:(CommandSet *)commandSet
                forLabel:(NSString *)label
                 atIndex:(NSUInteger)index;

/// Retrieving a `CommandSet` by index
- (CommandSet *)commandSetAtIndex:(NSUInteger)idx;

/// Retrieving a label by index
- (NSString *)labelAtIndex:(NSUInteger)index;

@property (nonatomic, readonly) NSArray * labels;

@end

@interface CommandSetCollection (CommandSetAccessors)

- (void)insertObject:(CommandSet *)value inCommandSetsAtIndex:(NSUInteger)index;
- (void)removeObjectFromCommandSetsAtIndex:(NSUInteger)index;
- (void)insertCommandSets:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCommandSetsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCommandSetsAtIndex:(NSUInteger)index withObject:(CommandSet *)value;
- (void)replaceCommandSetsAtIndexes:(NSIndexSet *)indexes withCommandSets:(NSArray *)values;
- (void)addCommandSetsObject:(CommandSet *)value;
- (void)removeCommandSetsObject:(CommandSet *)value;
- (void)addCommandSets:(NSOrderedSet *)values;
- (void)removeCommandSets:(NSOrderedSet *)values;

@end
