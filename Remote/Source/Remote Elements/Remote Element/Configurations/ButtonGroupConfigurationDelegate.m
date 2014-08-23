//
// ButtonGroupConfigurationDelegate.m
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "ButtonGroupConfigurationDelegate.h"
#import "ConfigurationDelegate_Private.h"
#import "CommandContainer.h"

static int ddLogLevel = LOG_LEVEL_WARN;
static const int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)


@interface ButtonGroupConfigurationDelegate ()

@property (nonatomic, strong, readwrite) NSSet * commandContainers;

@end

@interface ButtonGroupConfigurationDelegate (CoreDataGeneratedAccessors)

- (void)addCommandContainersObject:(CommandContainer *)container;
- (void)removeCommandContainersObject:(CommandContainer *)container;

@end

@implementation ButtonGroupConfigurationDelegate

@dynamic commandContainers;

- (ButtonGroup *)buttonGroup { return (ButtonGroup *)self.element; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Command containers
////////////////////////////////////////////////////////////////////////////////


- (void)setCommandContainer:(CommandContainer *)container mode:(RERemoteMode)mode
{
    [self addCommandContainersObject:container];
    self[makeKeyPath(mode,@"commandContainer")] = container.uuid;
}

- (CommandContainer *)commandContainerForMode:(RERemoteMode)mode
{
    ControlStateKeyPath * keypath = makeKeyPath(mode, @"commandContainer");
    NSString * uuid = self[keypath];
    return ((CommandContainer *)memberOfCollectionWithUUID(self.commandContainers, uuid) ?: nil);

}

- (CommandContainer *)commandContainer
{
    CommandContainer * commandContainer = [self commandContainerForMode:self.currentMode];
    if (!(commandContainer || [self.currentMode isEqualToString:REDefaultMode]))
        commandContainer = [self commandContainerForMode:REDefaultMode];
    return commandContainer;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Labels
////////////////////////////////////////////////////////////////////////////////


- (void)setLabel:(NSAttributedString *)label mode:(RERemoteMode)mode
{
    self[makeKeyPath(mode,@"label")] = label;
}

- (NSAttributedString *)labelForMode:(RERemoteMode)mode
{
    return self[makeKeyPath(mode,@"label")];
}

- (NSAttributedString *)label
{
    NSAttributedString * label = [self labelForMode:self.currentMode];
    if (!(label || [self.currentMode isEqualToString:REDefaultMode]))
        label = [self labelForMode:REDefaultMode];
    return label;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Updating
////////////////////////////////////////////////////////////////////////////////


- (void)updateForMode:(RERemoteMode)mode
{
    if (![self hasMode:mode]) return;

    self.buttonGroup.label = self.label;
    [self.buttonGroup setCommandContainer:self.commandContainer];

    ControlStateKeyPath * keypath = makeKeyPath(mode,@"label");

    NSAttributedString * label = self[keypath];
    if (label) self.buttonGroup.label = label;

    keypath.property = @"commandContainer";
    NSString * uuid = self[keypath];
    if (uuid)
    {
        CommandContainer * container = (CommandContainer *)
                                         memberOfCollectionWithUUID(self.commandContainers, uuid);
        assert(container);

        [self.buttonGroup setCommandContainer:container];
    }
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////


- (void)importCommandContainer:(id)data
{
    if (!isDictionaryKind(data)) return;

    if ([data hasKey:ButtonGroupCommandSetJSONKey])
        [self importCommandSet:data[ButtonGroupCommandSetJSONKey]];

    else if ([data hasKey:ButtonGroupCommandSetCollectionJSONKey])
        [self importCommandSetCollection:data[ButtonGroupCommandSetCollectionJSONKey]];
}

- (void)importCommandSet:(NSDictionary *)data
{
    if (!isDictionaryKind(data)) return;

    for (NSString * mode  in data)
    {
        CommandSet * commandSet = [CommandSet importObjectFromData:data[mode]
                                                        inContext:self.managedObjectContext];

        if (commandSet) [self setCommandContainer:commandSet mode:mode];
    }
}

- (void)importCommandSetCollection:(NSDictionary *)data
{
    if (!isDictionaryKind(data)) return;

    for (NSString * mode in data)
    {
        CommandSetCollection * collection =
            [CommandSetCollection importObjectFromData:data[mode] inContext:self.managedObjectContext];

        if (collection)
            [self setCommandContainer:collection mode:mode];
    }
}

- (BOOL)shouldImportCommandContainers:(id)data { return NO; }

@end
