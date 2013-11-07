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

@dynamic index, name;

+ (instancetype)commandContainerInContext:(NSManagedObjectContext *)context
{
    return [self MR_createInContext:context];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (ModelObjectShouldInitialize)
        self.index = [MSDictionary dictionary];
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key { _index[key] = object; }

- (id)objectForKeyedSubscript:(id<NSCopying>)key { return _index[key]; }

- (NSUInteger)count { return [_index count]; }

- (void)setPrimitiveIndex:(MSDictionary *)index { _index = index; }

- (MSDictionary *)primitiveIndex { return _index; }


@end
