//
// CommandContainer.m
// Remote
//
// Created by Jason Cardwell on 6/29/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "RECommandContainer_Private.h"

static int ddLogLevel   = DefaultDDLogLevel;
static int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE);
#pragma unused(ddLogLevel,msLogContext)

@implementation RECommandContainer

@dynamic index, name;

+ (instancetype)commandContainerInContext:(NSManagedObjectContext *)context
{
    return [self MR_createInContext:context];
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key
{
    NSMutableDictionary * index = [self.index mutableCopy];
    index[key] = object;
    self.index = index;
}

- (id)objectForKeyedSubscript:(id<NSCopying>)key { return self.index[key]; }

@end
