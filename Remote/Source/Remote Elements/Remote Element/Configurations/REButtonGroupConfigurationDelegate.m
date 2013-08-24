//
// REButtonGroupConfigurationDelegate.m
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "REConfigurationDelegate_Private.h"
#import "RECommandContainer.h"

static const int ddLogLevel = LOG_LEVEL_WARN;
static const int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonGroupConfigurationDelegate
////////////////////////////////////////////////////////////////////////////////


@implementation REButtonGroupConfigurationDelegate

@dynamic commandContainers;

+ (instancetype)delegateForRemoteElement:(REButtonGroup *)element
{
    assert(element);
    __block REButtonGroupConfigurationDelegate * configurationDelegate = nil;
    [element.managedObjectContext performBlockAndWait:
     ^{
         configurationDelegate = [self MR_createInContext:element.managedObjectContext];
         configurationDelegate.element = element;
     }];

    return configurationDelegate;
}

- (REButtonGroup *)buttonGroup { return (REButtonGroup *)self.element; }

- (void)setCommandContainer:(RECommandContainer *)container
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
        RECommandContainer * container = (RECommandContainer *)
                                         memberOfCollectionWithUUID(self.commandContainers, uuid);
        assert(container);

        [self.buttonGroup setCommandContainer:container];
    }
}

- (RECommandContainer *)commandContainer
{
    NSString * uuid = self[$(@"%@.commandContainer", self.currentConfiguration)];
    if (!uuid) uuid = self[$(@"%@.commandContainer", REDefaultConfiguration)];
    return ((RECommandContainer *)memberOfCollectionWithUUID(self.commandContainers, uuid) ?: nil);
}

@end
