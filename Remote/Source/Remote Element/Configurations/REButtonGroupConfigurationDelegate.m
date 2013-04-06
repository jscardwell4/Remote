//
// REButtonGroupConfigurationDelegate.m
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "REConfigurationDelegate_Private.h"

#import "RECommandContainer.h"

@implementation REButtonGroupConfigurationDelegate

@dynamic commandSets;

- (REButtonGroup *)buttonGroup { return (REButtonGroup *)self.remoteElement; }

- (void)setCommandSet:(RECommandSet *)commandSet forConfiguration:(RERemoteConfiguration)configuration
{
    assert(commandSet && configuration);
    [self addCommandSetsObject:commandSet];
    self[$(@"%@.commandSet", configuration)] = commandSet.uuid;
}

- (void)setLabel:(NSAttributedString *)label forConfiguration:(RERemoteConfiguration)configuration
{
    assert(label && configuration);
    self[$(@"%@.label", configuration)] = label;
}

- (void)updateConfigForConfiguration:(RERemoteConfiguration)configuration
{
    if (![self hasConfiguration:configuration]) return;

    NSAttributedString * label = self[$(@"%@.label",configuration)];
    if (label) self.buttonGroup.label = label;

    NSString * uuid = self[$(@"%@.commandSet",configuration)];
    if (uuid) {
        RECommandSet * commandSet = [self.commandSets objectPassingTest:^BOOL(RECommandSet * obj) {
            return [uuid isEqualToString:obj.uuid];
        }];
        assert(commandSet);
        self.buttonGroup.commandSet = commandSet;
    }
}

@end
