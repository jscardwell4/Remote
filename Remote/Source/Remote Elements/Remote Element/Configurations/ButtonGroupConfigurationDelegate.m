//
// ButtonGroupConfigurationDelegate.m
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "ConfigurationDelegate_Private.h"
#import "CommandContainer.h"

static int ddLogLevel = LOG_LEVEL_WARN;
static const int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonGroupConfigurationDelegate
////////////////////////////////////////////////////////////////////////////////


@implementation ButtonGroupConfigurationDelegate

@dynamic commandContainers;

- (ButtonGroup *)buttonGroup { return (ButtonGroup *)self.element; }

- (void)setCommandContainer:(CommandContainer *)container mode:(RERemoteMode)mode
{
    self[makeKeyPath(mode,@"commandContainer")] = container.uuid;
    [self addCommandContainersObject:container];
}

- (void)setLabel:(NSAttributedString *)label mode:(RERemoteMode)mode
{
    self[makeKeyPath(mode,@"label")] = label;
}

- (void)updateForMode:(RERemoteMode)mode
{
    if (![self hasMode:mode]) return;


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

- (CommandContainer *)commandContainer
{
    ControlStateKeyPath * keypath = makeKeyPath(self.currentMode, @"commandContainer");
    NSString * uuid = self[keypath];
    if (!uuid) { keypath.mode = REDefaultMode; uuid = self[keypath];}
    return ((CommandContainer *)memberOfCollectionWithUUID(self.commandContainers, uuid) ?: nil);
}

@end
