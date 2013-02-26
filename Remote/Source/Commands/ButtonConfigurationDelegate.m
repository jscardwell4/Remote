//
// ButtonConfigurationDelegate.m
// iPhonto
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "ConfigurationDelegate.h"
#import "Button.h"
#import "ControlStateSet.h"
#import "Command.h"

// static int ddLogLevel = LOG_LEVEL_DEBUG;
static int   ddLogLevel = DefaultDDLogLevel;

@interface ButtonConfigurationDelegate ()

@property (nonatomic, strong) NSMutableDictionary * commands;
@property (nonatomic, strong) NSMutableDictionary * labels;

@end

@implementation ButtonConfigurationDelegate
@dynamic button;
@dynamic commands;
@dynamic labels;

+ (ButtonConfigurationDelegate *)buttonConfigurationDelegateForButton:(Button *)button {
    if (ValueIsNil(button)) return nil;

    ButtonConfigurationDelegate * configurationDelegate =
        [NSEntityDescription insertNewObjectForEntityForName:@"ButtonConfigurationDelegate"
                                      inManagedObjectContext:button.managedObjectContext];

    configurationDelegate.button = button;
    if (button.titles != nil)
        [configurationDelegate registerTitleSet:button.titles
                               forConfiguration:kDefaultConfiguration];


    return configurationDelegate;
}

- (void)configurationDidChangeNotification:(NSNotification *)note {
    NSString * configuration = [[note userInfo] objectForKey:kConfigurationKey];

    DDLogDebug(@"%@\n\treceived notification of configuration change to configuration:'%@'",
               ClassTagSelectorString, configuration);

    if (ValueIsNil(configuration)) return;

    NSURL * newCommandURI = self.commands[configuration];

    if (ValueIsNotNil(newCommandURI)) {
        NSManagedObjectID * newCommandID =
            [[self.managedObjectContext persistentStoreCoordinator]
             managedObjectIDForURIRepresentation:newCommandURI];
        Command * newCommand = (Command *)[self.managedObjectContext objectWithID:newCommandID];

        self.button.command = newCommand;
    }

    NSURL * newTitleSetURI = self.labels[configuration];

    if (ValueIsNotNil(newTitleSetURI)) {
        NSManagedObjectID * newTitleSetID =
            [[self.managedObjectContext persistentStoreCoordinator]
             managedObjectIDForURIRepresentation:newTitleSetURI];

        if (self.button.titles.objectID != newTitleSetID) {
            ControlStateTitleSet * newTitleSet = (ControlStateTitleSet *)[self.managedObjectContext objectWithID:newTitleSetID];

            self.button.titles = newTitleSet;
        }
    }

    // MARK: Disabled to implement title set registration
    // id newButtonLabel = [self.labels objectForKey:configuration];
    // if (ValueIsNotNil(newButtonLabel)) {
    // if ([newButtonLabel isKindOfClass:[NSAttributedString class]])
    // [self.button setAttributedTitle:(NSAttributedString *)newButtonLabel
    // forState:UIControlStateNormal];
    // else
    // [self.button setTitle:newButtonLabel forState:UIControlStateNormal];
    // }
}

- (void)registerCommand:(Command *)buttonCommand forConfiguration:(NSString *)configuration {
    if (ValueIsNil(buttonCommand) || ValueIsNil(configuration)) return;

    if (![self containsConfigurationForKey:configuration]) [self addNewConfiguration:configuration];

    if ([buttonCommand.objectID isTemporaryID])
        [buttonCommand.managedObjectContext
         obtainPermanentIDsForObjects:@[buttonCommand]
                                error:nil];

    NSURL * commandURI = [buttonCommand.objectID URIRepresentation];

    self.commands[configuration] = commandURI;
    DDLogVerbose(@"%@ self.commands = %@", ClassTagSelectorString, self.commands);
}

- (void)registerLabel:(id)buttonLabel forConfiguration:(NSString *)configuration {
    // MARK: Disabled to implement title set registration
    // if (ValueIsNil(buttonLabel) || ValueIsNil(configuration))
    // return;
    //
    // if (![self containsConfigurationForKey:configuration])
    // [self addNewConfiguration:configuration];
    //
    // self.labels[configuration] = buttonLabel;
}

- (void)registerTitleSet:(ControlStateTitleSet *)titleSet
        forConfiguration:(NSString *)configuration {
    if (ValueIsNil(titleSet) || ValueIsNil(configuration)) return;

    if (![self containsConfigurationForKey:configuration]) [self addNewConfiguration:configuration];

    if ([titleSet.objectID isTemporaryID])
        [titleSet.managedObjectContext
         obtainPermanentIDsForObjects:@[titleSet]
                                error:nil];

    NSURL * titleSetURI = [titleSet.objectID URIRepresentation];

    self.labels[configuration] = titleSetURI;
}

- (NSMutableDictionary *)labels {
    [self willAccessValueForKey:@"labels"];

    NSMutableDictionary * tmpValue = [self primitiveValueForKey:@"labels"];

    [self didAccessValueForKey:@"labels"];

    if (ValueIsNil(tmpValue)) {
        tmpValue    = [NSMutableDictionary dictionary];
        self.labels = tmpValue;
    }

    return tmpValue;
}

- (NSMutableDictionary *)commands {
    [self willAccessValueForKey:@"commands"];

    NSMutableDictionary * tmpValue = [self primitiveValueForKey:@"commands"];

    [self didAccessValueForKey:@"commands"];

    if (ValueIsNil(tmpValue)) {
        tmpValue      = [NSMutableDictionary dictionary];
        self.commands = tmpValue;
    }

    return tmpValue;
}

@end
