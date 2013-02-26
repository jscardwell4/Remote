//
// ButtonGroupConfigurationDelegate.m
// iPhonto
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "ConfigurationDelegate.h"
#import "ButtonGroup.h"
#import "CommandSet.h"

static int   ddLogLevel = DefaultDDLogLevel;

@interface ButtonGroupConfigurationDelegate ()

@property (nonatomic, strong) NSMutableDictionary * commandSets;
@property (nonatomic, strong) NSMutableDictionary * labels;

@end

@implementation ButtonGroupConfigurationDelegate
@dynamic
buttonGroup,
commandSets,
labels;

+ (ButtonGroupConfigurationDelegate *)buttonGroupConfigurationDelegateForButtonGroup:(ButtonGroup *)buttonGroup {
    if (ValueIsNil(buttonGroup)) return nil;

    ButtonGroupConfigurationDelegate * configurationDelegate =
        [NSEntityDescription insertNewObjectForEntityForName:@"ButtonGroupConfigurationDelegate"
                                      inManagedObjectContext:buttonGroup.managedObjectContext];

    configurationDelegate.buttonGroup = buttonGroup;

    return configurationDelegate;
}

- (void)configurationDidChangeNotification:(NSNotification *)note {
    DDLogVerbose(@"%@ configurationDidChangeNotification:%@", ClassTagSelectorString, note);

    NSString * configuration = [[note userInfo] objectForKey:kConfigurationKey];

    if ([self containsConfigurationForKey:configuration]) [self loadConfiguration:configuration];
}

- (void)loadConfiguration:(NSString *)configuration {
    NSURL * newCommandSetURI = [self.commandSets objectForKey:configuration];

    if (ValueIsNotNil(newCommandSetURI)) {
        NSManagedObjectID * newCommandSetID =
            [[self.managedObjectContext persistentStoreCoordinator]
             managedObjectIDForURIRepresentation:newCommandSetURI];
        CommandSet * newCommandSet =
            (CommandSet *)[self.managedObjectContext objectWithID:newCommandSetID];

        self.buttonGroup.commandSet = newCommandSet;
    }

    NSAttributedString * newButtonGroupLabel = [self.labels objectForKey:configuration];

    if (ValueIsNotNil(newButtonGroupLabel)) self.buttonGroup.label = newButtonGroupLabel;
}

- (void)registerCommandSet:(CommandSet *)set forConfiguration:(NSString *)configuration {
    if (ValueIsNil(set) || ValueIsNil(configuration)) return;

    if (![self containsConfigurationForKey:configuration]) [self addNewConfiguration:configuration];

    if ([set.objectID isTemporaryID])
        [set.managedObjectContext
         obtainPermanentIDsForObjects:@[set]
                                error:nil];

    NSURL * commandSetURI = [set.objectID URIRepresentation];

    [self.commandSets setObject:commandSetURI forKey:configuration];
}

- (void)registerLabel:(NSString *)label forConfiguration:(NSString *)configuration {
    if (ValueIsNil(label) || ValueIsNil(configuration)) return;

    if (![self containsConfigurationForKey:configuration]) [self addNewConfiguration:configuration];

    [self.labels setObject:label forKey:configuration];
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

- (NSMutableDictionary *)commandSets {
    [self willAccessValueForKey:@"commandSets"];

    NSMutableDictionary * tmpValue = [self primitiveValueForKey:@"commandSets"];

    [self didAccessValueForKey:@"commandSets"];

    if (ValueIsNil(tmpValue)) {
        tmpValue         = [NSMutableDictionary dictionary];
        self.commandSets = tmpValue;
    }

    return tmpValue;
}

@end
