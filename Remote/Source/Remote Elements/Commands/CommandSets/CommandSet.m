//
// CommandSet.m
// Remote
//
// Created by Jason Cardwell on 6/9/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "CommandContainer_Private.h"
#import "Command.h"
//#import "BankObject.h"

static int ddLogLevel   = DefaultDDLogLevel;
static int   msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE);
#pragma unused(ddLogLevel,msLogContext)

static const NSDictionary * kValidKeysets;

@implementation CommandSet

@dynamic buttonGroup, commands;

+ (void)initialize
{
    if (self == [CommandSet class])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            kValidKeysets =
            @{
                @(CommandSetTypeDPad):
                    [@[@(REButtonRoleDPadCenter),
                       @(REButtonRoleDPadUp),
                       @(REButtonRoleDPadDown),
                       @(REButtonRoleDPadLeft),
                       @(REButtonRoleDPadRight)] set],

                @(CommandSetTypeNumberpad):
                    [@[@(REButtonRoleNumberpad1),
                       @(REButtonRoleNumberpad2),
                       @(REButtonRoleNumberpad3),
                       @(REButtonRoleNumberpad4),
                       @(REButtonRoleNumberpad5),
                       @(REButtonRoleNumberpad6),
                       @(REButtonRoleNumberpad7),
                       @(REButtonRoleNumberpad8),
                       @(REButtonRoleNumberpad9),
                       @(REButtonRoleNumberpad0),
                       @(REButtonRoleNumberpadAux1),
                       @(REButtonRoleNumberpadAux2)] set],

                @(CommandSetTypeRocker):
                    [@[@(REButtonRolePickerLabelTop),
                       @(REButtonRolePickerLabelBottom)] set],

                @(CommandSetTypeTransport):
                    [@[@(REButtonRoleTransportPlay),
                       @(REButtonRoleTransportPause),
                       @(REButtonRoleTransportStop),
                       @(REButtonRoleTransportRecord),
                       @(REButtonRoleTransportSkip),
                       @(REButtonRoleTransportReplay),
                       @(REButtonRoleTransportFF),
                       @(REButtonRoleTransportRewind)] set]
            };
        });
    }
}

+ (instancetype)commandSetWithType:(CommandSetType)type
{
    CommandSet * commandSet = [self MR_createEntity];
    commandSet.type = type;
    return commandSet;
}

+ (instancetype)commandSetWithType:(CommandSetType)type
                              name:(NSString *)name
                            values:(NSDictionary *)values
{
    CommandSet * commandSet = [self commandSetWithType:type];
    commandSet.name = name;
    for (id<NSCopying> key in values) commandSet[key] = values[key];
    return commandSet;
}

+ (instancetype)commandSetInContext:(NSManagedObjectContext *)context
                           withType:(CommandSetType)type
                               name:(NSString *)name
                             values:(NSDictionary *)values
{
    CommandSet * commandSet = [self commandSetInContext:context type:type];
    commandSet.name = name;
    for (id<NSCopying> key in values) commandSet[key] = values[key];
    return commandSet;
}


+ (instancetype)commandSetInContext:(NSManagedObjectContext *)context type:(CommandSetType)type
{
    __block CommandSet * commandSet = nil;
    [context performBlockAndWait:
     ^{
         commandSet = [self commandContainerInContext:context];
         commandSet.type = type;
     }];
    return commandSet;
}

- (void)setObject:(Command *)command forKeyedSubscript:(NSString *)key
{
    if ([kValidKeysets[self.primitiveType] containsObject:key])
    {
        NSMutableDictionary * index = [self.index mutableCopy];
        index[key] = [command permanentURI];
        self.index = [NSDictionary dictionaryWithDictionary:index];
    }
}

- (Command *)objectForKeyedSubscript:(id<NSCopying>)key
{
    return (Command *)[self.managedObjectContext objectForURI:self.index[key]];
}

- (CommandSetType)type
{
    [self willAccessValueForKey:@"type"];
    CommandSetType type = NSUIntegerValue(self.primitiveType);
    [self didAccessValueForKey:@"type"];
    return type;
}

- (void)setType:(CommandSetType)type
{
    [self willChangeValueForKey:@"type"];
    self.primitiveType = @(type);
    [self didChangeValueForKey:@"type"];
}

@end
