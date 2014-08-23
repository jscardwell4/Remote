//
// BankGroup.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "BankGroup.h"
#import "Image.h"
#import "IRCode.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@implementation BankGroup

@dynamic name;

+ (instancetype)groupWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    __block BankGroup * group = nil;

    [context performBlockAndWait:
     ^{
         group = [self findFirstByAttribute:@"name" withValue:name inContext:context];
         if (!group)
         {
             group = [self createInContext:context];
             group.name = name;
         }
     }];

    return group;
}

+ (instancetype)fetchGroupWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    return [self findFirstByAttribute:@"name" withValue:name inContext:context];
}

@end
