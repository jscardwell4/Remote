//
// CommandSet.m
// Remote
//
// Created by Jason Cardwell on 6/9/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "RECommandContainer_Private.h"
#import "RECommand.h"
#import "BankObject.h"

static int   ddLogLevel   = DefaultDDLogLevel;
static int   msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE);
#pragma unused(ddLogLevel,msLogContext)

static const NSDictionary * kValidKeysets;

@implementation RECommandSet

@dynamic buttonGroup, commands;

+ (void)initialize
{
    if (self == [RECommandSet class])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            kValidKeysets =
            @{
                @(RECommandSetTypeDPad):
                    [@[@(REButtonTypeDPadCenter),
                       @(REButtonTypeDPadUp),
                       @(REButtonTypeDPadDown),
                       @(REButtonTypeDPadLeft),
                       @(REButtonTypeDPadRight)] set],

                @(RECommandSetTypeNumberPad):
                    [@[@(REButtonTypeNumberpad1),
                       @(REButtonTypeNumberpad2),
                       @(REButtonTypeNumberpad3),
                       @(REButtonTypeNumberpad4),
                       @(REButtonTypeNumberpad5),
                       @(REButtonTypeNumberpad6),
                       @(REButtonTypeNumberpad7),
                       @(REButtonTypeNumberpad8),
                       @(REButtonTypeNumberpad9),
                       @(REButtonTypeNumberpad0),
                       @(REButtonTypeNumberpadAux1),
                       @(REButtonTypeNumberpadAux2)] set],

                @(RECommandSetTypeRocker):
                    [@[@(REButtonTypePickerLabelTop),
                       @(REButtonTypePickerLabelBottom)] set],

                @(RECommandSetTypeTransport):
                    [@[@(REButtonTypeTransportPlay),
                       @(REButtonTypeTransportPause),
                       @(REButtonTypeTransportStop),
                       @(REButtonTypeTransportRecord),
                       @(REButtonTypeTransportSkip),
                       @(REButtonTypeTransportReplay),
                       @(REButtonTypeTransportFF),
                       @(REButtonTypeTransportRewind)] set]
            };
        });
    }
}

+ (instancetype)commandSetWithType:(RECommandSetType)type
{
    RECommandSet * commandSet = [self MR_createEntity];
    commandSet.type = type;
    return commandSet;
}

+ (instancetype)commandSetWithType:(RECommandSetType)type
                              name:(NSString *)name
                            values:(NSDictionary *)values
{
    RECommandSet * commandSet = [self commandSetWithType:type];
    commandSet.name = name;
    for (id<NSCopying> key in values) commandSet[key] = values[key];
    return commandSet;
}

+ (instancetype)commandSetInContext:(NSManagedObjectContext *)context
                           withType:(RECommandSetType)type
                               name:(NSString *)name
                             values:(NSDictionary *)values
{
    RECommandSet * commandSet = [self commandSetInContext:context type:type];
    commandSet.name = name;
    for (id<NSCopying> key in values) commandSet[key] = values[key];
    return commandSet;
}


+ (instancetype)commandSetInContext:(NSManagedObjectContext *)context type:(RECommandSetType)type
{
    __block RECommandSet * commandSet = nil;
    [context performBlockAndWait:
     ^{
         commandSet = [self commandContainerInContext:context];
         commandSet.type = type;
     }];
    return commandSet;
}

- (void)setObject:(RECommand *)command forKeyedSubscript:(NSString *)key
{
    if ([kValidKeysets[self.primitiveType] containsObject:key])
    {
        NSMutableDictionary * index = [self.index mutableCopy];
        index[key] = [command permanentURI];
        self.index = [NSDictionary dictionaryWithDictionary:index];
    }
}

- (RECommand *)objectForKeyedSubscript:(id<NSCopying>)key
{
    return (RECommand *)[self.managedObjectContext objectForURI:self.index[key]];
}

- (RECommandSetType)type
{
    [self willAccessValueForKey:@"type"];
    RECommandSetType type = NSUIntegerValue(self.primitiveType);
    [self didAccessValueForKey:@"type"];
    return type;
}

- (void)setType:(RECommandSetType)type
{
    [self willChangeValueForKey:@"type"];
    self.primitiveType = @(type);
    [self didChangeValueForKey:@"type"];
}

@end
