//
// CommandSet.m
// Remote
//
// Created by Jason Cardwell on 6/9/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "CommandSet.h"
#import "CommandContainer_Private.h"
#import "Remote-Swift.h"

static int ddLogLevel   = DefaultDDLogLevel;
static int msLogContext = (LOG_CONTEXT_REMOTE | LOG_CONTEXT_FILE);

#pragma unused(ddLogLevel,msLogContext)

@interface CommandSet ()

@property (nonatomic, readwrite) CommandSetType type;
@property (nonatomic, strong)    NSSet        * commands;
@property (nonatomic, strong)    ButtonGroup  * buttonGroup;

@end

@interface CommandSet (CoreDataGeneratedAccessors)

- (void)addCommandsObject:(Command *)value;
- (void)removeCommandsObject:(Command *)value;
- (void)addCommands:(NSSet *)values;
- (void)removeCommands:(NSSet *)values;

@property (nonatomic, strong) NSMutableSet * primitiveCommands;
@property (nonatomic, strong) ButtonGroup  * primitiveButtonGroup;
@property (nonatomic, strong) NSNumber     * primitiveType;

@end


NSArray *sharedKeysForType(CommandSetType type) {
  static NSDictionary const * index = nil;
  static dispatch_once_t      onceToken;

  dispatch_once(&onceToken,
                ^{
    index = @{ @(CommandSetTypeDPad) :
               @[@(REButtonRoleDPadCenter),
                 @(REButtonRoleDPadUp),
                 @(REButtonRoleDPadDown),
                 @(REButtonRoleDPadLeft),
                 @(REButtonRoleDPadRight)],

               @(CommandSetTypeNumberpad) :
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

               @(CommandSetTypeRocker) :
               @[@(REButtonRoleRockerTop),
                 @(REButtonRoleRockerBottom)],

               @(CommandSetTypeTransport) :
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

+ (instancetype)commandSetWithType:(CommandSetType)type inContext:(NSManagedObjectContext *)moc {
  CommandSet * commandSet = [self createInContext:moc];
  commandSet.type = type;
  return commandSet;
}

- (void)setObject:(Command *)command forKeyedSubscript:(NSString *)key {
  if (!command)
    ThrowInvalidNilArgument(command);

  else if (![self.index isValidKey:key])
    ThrowInvalidArgument(key, "is not valid for this command set");

  [self addCommandsObject:command];
  self.index[key] = command.permanentURI;
}

- (Command *)objectForKeyedSubscript:(id<NSCopying>)key {
  return ([self.index isValidKey:key]
          ? [Command objectForURI:self.index[key] context:self.managedObjectContext]
          : nil);
}

- (CommandSetType)type {
  [self willAccessValueForKey:@"type"];
  CommandSetType type = UnsignedIntegerValue(self.primitiveType);
  [self didAccessValueForKey:@"type"];
  return type;
}

/// Sets the type of the command set if the type specified represents a change, also creating a fresh index
/// @param type
- (void)setType:(CommandSetType)type {
  if (self.type != type) {
    [self willChangeValueForKey:@"type"];
    self.primitiveType = @(type);
    [self didChangeValueForKey:@"type"];

    if (CommandSetTypeIsValid(type)) {
      // ???: Should any existing index have its contents destroyed first?
      self.index = [MSDictionary dictionaryWithSharedKeys:sharedKeysForType(type)];
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Import and export
////////////////////////////////////////////////////////////////////////////////


- (void)updateWithData:(NSDictionary *)data {

  CommandSetType type = commandSetTypeFromImportKey(data[CommandSetTypeJSONKey]);

  if (CommandSetTypeIsValid(type)) {

    self.type = type;

    for (NSString * key in [data dictionaryByRemovingEntriesForKeys:@[CommandSetTypeJSONKey]]) {

      RERole role = remoteElementRoleFromImportKey(key);

      if (!(type & role)) continue; // Continue if type not composed into role

      NSDictionary * commandData = data[key];

      if (!isDictionaryKind(commandData)) continue; // Continue if commandData is not a valid dictionary object

      Command * command = [Command importObjectFromData:commandData context:self.managedObjectContext];

      if (command) self[@(role)] = command;

    }

  }

}

- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];

  [dictionary removeObjectForKey:@"uuid"];

  dictionary[CommandSetTypeJSONKey] = CollectionSafe(commandSetTypeJSONValueForCommandSet(self));

  [self.index enumerateKeysAndObjectsUsingBlock:^(NSNumber * key, NSURL * uri, BOOL *stop) {
    SafeSetValueForKey([Command objectForURI:uri context:self.managedObjectContext].JSONDictionary,
                       roleJSONValueForRERole(UnsignedShortValue(key)),
                       dictionary);
  }];

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

@end
