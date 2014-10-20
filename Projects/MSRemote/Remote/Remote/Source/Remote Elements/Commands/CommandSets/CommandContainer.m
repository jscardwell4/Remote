//
// CommandContainer.m
// Remote
//
// Created by Jason Cardwell on 6/29/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "CommandContainer.h"
#import "CommandContainer_Private.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@implementation CommandContainer

@dynamic index;


- (void)awakeFromInsert {
  [super awakeFromInsert];
  self.primitiveIndex = [MSDictionary dictionary];
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key { self.index[key] = object; }

- (id)objectForKeyedSubscript:(id<NSCopying>)key { return self.index[key]; }

- (NSUInteger)count { return [self.index count]; }

//- (void)setPrimitiveIndex:(MSDictionary *)index { _index = index; }
//
//- (MSDictionary *)primitiveIndex { return _index; }


@end
