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

- (void)setCommand:(RECommand *)command forConfiguration:(RERemoteConfiguration)config
{
    assert(command && config);
    [self addCommandsObject:command];
    self[$(@"%@.command", config)] = command.uuid;
}

- (void)setTitleSet:(REControlStateTitleSet *)titleSet forConfiguration:(RERemoteConfiguration)config
{
    assert(titleSet && config);
    [self addTitleSetsObject:titleSet];
    self[$(@"%@.titleSet", config)] = titleSet.uuid;
}

- (void)setTitle:(id)title forConfiguration:(RERemoteConfiguration)config
{
    if ([title isKindOfClass:[NSString class]])
        title = [NSAttributedString attributedStringWithString:(NSString *)title];

    NSString * uuid = self[$(@"%@.titleSet", config)];
    if (!uuid)
    {
        REControlStateTitleSet * titleSet = [REControlStateTitleSet
                                             MR_createInContext:self.managedObjectContext];
        titleSet[UIControlStateNormal] = title;
        [self setTitleSet:titleSet forConfiguration:config];
    }

    else
    {
        REControlStateTitleSet * titleSet = [self.titleSets objectPassingTest:
                                             ^BOOL(REControlStateTitleSet * obj)
                                             {
                                                 return [uuid isEqualToString:obj.uuid];
                                             }];
        titleSet[UIControlStateNormal] = title;

    }


}

@end
