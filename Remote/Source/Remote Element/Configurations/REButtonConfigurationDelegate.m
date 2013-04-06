//
// REButtonConfigurationDelegate.m
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "REConfigurationDelegate_Private.h"

#import "REControlStateSet.h"
#import "RECommand.h"

@implementation REButtonConfigurationDelegate

@dynamic commands, titleSets;

- (REButton *)button { return (REButton *)self.remoteElement; }

- (void)updateConfigForConfiguration:(RERemoteConfiguration)configuration
{
    if (![self hasConfiguration:configuration]) return;

    NSString * uuid = self[$(@"%@.command", configuration)];
    if (uuid)
        self.button.command = [self.commands objectPassingTest:
                               ^BOOL(RECommand * obj) {
                                   return [uuid isEqualToString:obj.uuid];
                               }];

    uuid = self[$(@"%@.titleSet", configuration)];
    if (uuid)
        self.button.titles = [self.titleSets objectPassingTest:
                              ^BOOL(REControlStateTitleSet * obj) {
                                  return [uuid isEqualToString:obj.uuid];
                              }];
}

- (void)setCommand:(RECommand *)command forConfiguration:(RERemoteConfiguration)configuration
{
    assert(command && configuration);
    [self addCommandsObject:command];
    self[$(@"%@.command", configuration)] = command.uuid;
}

- (void)setTitleSet:(REControlStateTitleSet *)titleSet
   forConfiguration:(RERemoteConfiguration)configuration
{
    assert(titleSet && configuration);
    [self addTitleSetsObject:titleSet];
    self[$(@"%@.titleSet", configuration)] = titleSet.uuid;
}

@end
