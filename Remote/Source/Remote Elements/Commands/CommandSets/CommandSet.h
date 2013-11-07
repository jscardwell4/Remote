//
// CommandSet.h
// Remote
//
// Created by Jason Cardwell on 6/29/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "CommandContainer.h"

@class Command;

@interface CommandSet : CommandContainer

+ (instancetype)commandSetWithType:(CommandSetType)type;
+ (instancetype)commandSetInContext:(NSManagedObjectContext *)context type:(CommandSetType)type;

- (void)setObject:(Command *)command forKeyedSubscript:(id<NSCopying>)key;
- (Command *)objectForKeyedSubscript:(id<NSCopying>)key;

@property (nonatomic, readonly) CommandSetType   type;

@end

