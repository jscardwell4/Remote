//
// REButtonGroupConfigurationDelegate.m
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "REConfigurationDelegate_Private.h"
#import "RECommandContainer.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)


@implementation REButtonGroupConfigurationDelegate

@dynamic commandSets;

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

- (void)setCommandSet:(RECommandSet *)commandSet forConfiguration:(RERemoteConfiguration)config
{
    assert(commandSet && config);
    [self addCommandSetsObject:commandSet];
    self[$(@"%@.commandSet", config)] = commandSet.uuid;
}

- (void)setLabel:(NSAttributedString *)label forConfiguration:(RERemoteConfiguration)config
{
    assert(label && config);
    self[$(@"%@.label", config)] = label;
}

- (void)updateConfigForConfiguration:(RERemoteConfiguration)configuration
{
    if (![self hasConfiguration:configuration]) return;

    NSAttributedString * label = self[$(@"%@.label",configuration)];
    if (label) ((REButtonGroup *)self.element).label = label;

    NSString * uuid = self[$(@"%@.commandSet",configuration)];
    if (uuid) {
        RECommandSet * commandSet = [self.commandSets objectPassingTest:
                                     ^BOOL(RECommandSet * obj)
                                     {
                                         return [uuid isEqualToString:obj.uuid];
                                     }];
        assert(commandSet);
        for (REButton * button in self.element.subelements)
        {
            RECommand * cmd = ([commandSet isValidKey:button.key] ? commandSet[button.key] : nil);

            if (ValueIsNotNil(cmd))
            {
                button.command = cmd;
                button.enabled = YES;
                MSLogDebugTag(@"new command: %@", [cmd description]);
            }
            else
            {
                button.enabled = NO;
                MSLogDebugTag(@"command not found for key \"%@\"", button.key);
            }
        }
    }
}

@end
