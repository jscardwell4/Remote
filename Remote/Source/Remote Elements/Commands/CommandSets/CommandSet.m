//
// CommandSet.m
// Remote
//
// Created by Jason Cardwell on 6/9/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "CommandSet.h"
#import "CommandContainer_Private.h"
#import "Command.h"
#import "ButtonGroup.h"

static int ddLogLevel   = DefaultDDLogLevel;
static int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE);
#pragma unused(ddLogLevel,msLogContext)

@interface CommandSet ()

@property (nonatomic, readwrite) CommandSetType   type;
@property (nonatomic, strong)    NSSet          * commands;
@property (nonatomic, strong)    ButtonGroup    * buttonGroup;

@end

@interface CommandSet (CoreDataGeneratedAccessors)

- (void)addCommandsObject:(Command *)value;
- (void)removeCommandsObject:(Command *)value;
- (void)addCommands:(NSSet *)values;
- (void)removeCommands:(NSSet *)values;

@property (nonatomic, strong) NSMutableSet  * primitiveCommands;
@property (nonatomic, strong) ButtonGroup   * primitiveButtonGroup;
@property (nonatomic, strong) NSNumber      * primitiveType;

@end


NSArray * sharedKeysForType(CommandSetType type)
{
    static NSDictionary const * index = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      index = @{ @(CommandSetTypeDPad):
                                     @[@(REButtonRoleDPadCenter),
                                       @(REButtonRoleDPadUp),
                                       @(REButtonRoleDPadDown),
                                       @(REButtonRoleDPadLeft),
                                       @(REButtonRoleDPadRight)],

                                 @(CommandSetTypeNumberpad):
                                     @[@(REButtonRoleNumberpad1),
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
                                       @(REButtonRoleNumberpadAux2)],

                                 @(CommandSetTypeRocker):
                                     @[@(REButtonRoleRockerTop),
                                       @(REButtonRoleRockerBottom)],

                                 @(CommandSetTypeTransport):
                                     @[@(REButtonRoleTransportPlay),
                                       @(REButtonRoleTransportPause),
                                       @(REButtonRoleTransportStop),
                                       @(REButtonRoleTransportRecord),
                                       @(REButtonRoleTransportSkip),
                                       @(REButtonRoleTransportReplay),
                                       @(REButtonRoleTransportFF),
                                       @(REButtonRoleTransportRewind)] };
                  });

    return index[@(type)];
}

@implementation CommandSet

@dynamic buttonGroup, commands;

+ (instancetype)commandSetWithType:(CommandSetType)type
{
    return [self commandSetInContext:[CoreDataManager defaultContext] type:type];
}

+ (instancetype)commandSetInContext:(NSManagedObjectContext *)context type:(CommandSetType)type
{
    __block CommandSet * commandSet = nil;
    [context performBlockAndWait:
     ^{
         commandSet = [self commandContainerInContext:context];
         commandSet.type = type;
         NSArray * sharedKeys = sharedKeysForType(type);
         if (sharedKeys)
             commandSet.primitiveIndex = [MSDictionary dictionaryWithSharedKeys:sharedKeys];
     }];
    return commandSet;
}

- (void)setObject:(Command *)command forKeyedSubscript:(NSString *)key
{
    if (!command) ThrowInvalidNilArgument(command);
    else if (![_index isValidKey:key]) ThrowInvalidArgument(key, "is not valid for this command set");

    [self addCommandsObject:command];
    _index[key] = [command permanentURI];
}

- (Command *)objectForKeyedSubscript:(id<NSCopying>)key
{
    return ([_index isValidKey:key]
            ? [Command objectForURI:_index[key] context:self.managedObjectContext]
            : nil);
}

- (CommandSetType)type
{
    [self willAccessValueForKey:@"type"];
    CommandSetType type = UnsignedIntegerValue(self.primitiveType);
    [self didAccessValueForKey:@"type"];
    return type;
}

- (void)setType:(CommandSetType)type
{
    [self willChangeValueForKey:@"type"];
    self.primitiveType = @(type);
    [self didChangeValueForKey:@"type"];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Import and export
////////////////////////////////////////////////////////////////////////////////


/*
+ (id)importObjectFromData:(NSDictionary *)data inContext:(NSManagedObjectContext *)context
{
    if (!context) ThrowInvalidNilArgument(context);
    else if (!isDictionaryKind(data)) ThrowInvalidArgument(data, "must be some kind of dictionary");

    NSString * typeString = data[CommandSetTypeJSONKey];
    CommandSetType type = commandSetTypeFromImportKey(typeString);
    if (!type) return nil;

    CommandSet * commandSet = [CommandSet commandSetInContext:context type:type];
    if (!commandSet) return nil;

    for (NSString * key in data)
    {
        if ([key isEqualToString:CommandSetTypeJSONKey]) continue;

        RERole buttonRole = remoteElementRoleFromImportKey(key);
        if (!(type & buttonRole)) continue;

        NSDictionary * commandData = data[key];
        if (!isDictionaryKind(commandData)) continue;

        Class commandClass = commandClassForImportKey(commandData[@"class"]);
        if (!commandClass) continue;

        Command * command = [commandClass importFromData:commandData inContext:context];

        if (command) commandSet[@(buttonRole)] = command;
    }

    return commandSet;
}
*/

- (MSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];
    [dictionary removeObjectForKey:@"uuid"];

    dictionary[CommandSetTypeJSONKey] = CollectionSafe(commandSetTypeJSONValueForCommandSet(self));

    for (NSNumber * key in _index)
    {
        NSString * jsonKey = roleJSONValueForRERole(UnsignedShortValue(key));
        assert(jsonKey);

        Command * command = [Command objectForURI:_index[key] context:self.managedObjectContext];
        assert(command);

        dictionary[jsonKey] = CollectionSafe(command.JSONDictionary);
    }

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}

@end
