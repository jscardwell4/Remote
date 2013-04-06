//
// CommandContainer.m
// Remote
//
// Created by Jason Cardwell on 6/29/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "RECommandContainer_Private.h"

static int ddLogLevel   = DefaultDDLogLevel;
static int msLogContext = REMOTE_F;
#pragma unused(ddLogLevel,msLogContext)

@implementation RECommandContainer

@dynamic uuid, index;

+ (instancetype)commandContainerInContext:(NSManagedObjectContext *)context
{
    __block RECommandContainer * container = nil;
    [context performBlockAndWait:^{ container = NSManagedObjectFromClass(context); }];
    return container;
}

- (void)awakeFromInsert { [super awakeFromInsert]; self.primitiveUuid = MSNonce(); }

- (BOOL)isValidKey:(NSString *)key { return [self.index hasKey:key]; }

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    NSMutableDictionary * index = [self.index mutableCopy];
    index[key] = object;
    self.index = index;
}

- (id)objectForKeyedSubscript:(NSString *)key { return self.index[key]; }

@end
