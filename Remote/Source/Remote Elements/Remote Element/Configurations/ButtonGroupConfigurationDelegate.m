//
// ButtonGroupConfigurationDelegate.m
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "ConfigurationDelegate_Private.h"
#import "CommandContainer.h"

static const int ddLogLevel = LOG_LEVEL_WARN;
static const int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonGroupConfigurationDelegate
////////////////////////////////////////////////////////////////////////////////


@implementation ButtonGroupConfigurationDelegate

@dynamic commandContainers;

+ (instancetype)delegateForRemoteElement:(ButtonGroup *)element
{
    assert(element);
    __block ButtonGroupConfigurationDelegate * configurationDelegate = nil;
    [element.managedObjectContext performBlockAndWait:
     ^{
         configurationDelegate = [self MR_createInContext:element.managedObjectContext];
         configurationDelegate.element = element;
     }];

    return configurationDelegate;
}

- (ButtonGroup *)buttonGroup { return (ButtonGroup *)self.element; }

- (void)setCommandContainer:(CommandContainer *)container
        configuration:(RERemoteConfiguration)config
{
    assert(container && config);
    [self addCommandContainersObject:container];
    self[$(@"%@.commandContainer", config)] = container.uuid;
}

- (void)setLabel:(NSAttributedString *)label configuration:(RERemoteConfiguration)config
{
    assert(label && config);
    self[$(@"%@.label", config)] = label;
}

- (void)updateForConfiguration:(RERemoteConfiguration)configuration
{
    if (![self hasConfiguration:configuration]) return;

    NSAttributedString * label = self[$(@"%@.label", configuration)];
    if (label) self.buttonGroup.label = label;

    NSString * uuid = self[$(@"%@.commandContainer", configuration)];
    if (uuid) {
        CommandContainer * container = (CommandContainer *)
                                         memberOfCollectionWithUUID(self.commandContainers, uuid);
        assert(container);

        [self.buttonGroup setCommandContainer:container];
    }
}

- (CommandContainer *)commandContainer
{
    NSString * uuid = self[$(@"%@.commandContainer", self.currentConfiguration)];
    if (!uuid) uuid = self[$(@"%@.commandContainer", REDefaultConfiguration)];
    return ((CommandContainer *)memberOfCollectionWithUUID(self.commandContainers, uuid) ?: nil);
}

@end
