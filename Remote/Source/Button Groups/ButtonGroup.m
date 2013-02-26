//
// ButtonGroupState.m
// iPhonto
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"
#import "ButtonGroup.h"
#import "Button.h"
#import "Command.h"
#import "CommandSet.h"
#import "ConfigurationDelegate.h"

static int   ddLogLevel = DefaultDDLogLevel;

@interface ButtonGroup ()

- (void)updateButtons;

@end

@implementation ButtonGroup

@dynamic label;
@dynamic labelConstraints;
@dynamic configurationDelegate;
@dynamic commandSet;

/*
 + (ButtonGroup *)buttonGroupWithType:(ButtonGroupType)type context:(NSManagedObjectContext
 ++*)context {
 +
 +  if (type == ButtonGroupTypePickerLabel)
 +      return [self pickerLabelButtonGroupInContext:context];
 +
 +  ButtonGroup * buttonGroup =
 +      [NSEntityDescription insertNewObjectForEntityForName:@"ButtonGroup"
 +                                    inManagedObjectContext:context];
 +  assert(buttonGroup);
 +  buttonGroup.flags = buttonGroup.flags|type;
 +
 +      return buttonGroup;
 + }
 +
 + (PickerLabelButtonGroup *)pickerLabelButtonGroupInContext:(NSManagedObjectContext *)context {
 +      PickerLabelButtonGroup * buttonGroup =
 +  [NSEntityDescription insertNewObjectForEntityForName:@"PickerLabelButtonGroup"
 +                                inManagedObjectContext:context];
 +
 +      return buttonGroup;
 + }
 +
 */
- (void)setPanelLocation:(ButtonGroupSubtype)panelLocation {
    self.subtype = panelLocation;
}

// TODO: Fix after generating bit vector
- (ButtonGroupSubtype)panelLocation {
    return (ButtonGroupSubtype)self.subtype;
}

#pragma mark - NSManagedObject overrides
/// @name ￼NSManagedObject overrides

- (void)awakeFromFetch {
    [super awakeFromFetch];
    if (ValueIsNotNil(self.configurationDelegate)) [self.configurationDelegate registerForConfigurationChangeNotifications];
}

// TODO: Add validation to make sure subelements are Button Objects

- (Button *)buttonWithKey:(NSString *)key {
    return [self.subelements
            objectPassingTest:^BOOL (Button * obj, NSUInteger idx, BOOL * stop) {
        return [obj.key
                isEqualToString:key];
    }

    ];
}

- (Button *)objectForKeyedSubscript:(NSString *)subscript {
    return [self buttonWithKey:subscript];
}

/// @name Managing the button group's collection of buttons

/**
 * Updates the Command for each Button contained by the ButtonGroup with Command object from
 * the current CommandSet
 */
- (void)updateButtons {
    CommandSet * currentCommandSet = self.commandSet;

    if (ValueIsNil(currentCommandSet)) return;

    for (Button * button in self.subelements) {
        NSString * key = button.key;

        if (![currentCommandSet isValidKey:key]) continue;

        Command * newCommand = [currentCommandSet commandForKey:key];

        if (ValueIsNotNil(newCommand)) {
            DDLogDebug(@"button = %@; newCommand = %@", button.key, [newCommand description]);
            [button setValue:newCommand forKey:@"command"];
            button.enabled = YES;
        } else {
            button.enabled = NO;
            DDLogInfo(@"%@ Button[%@]: command not found for key \"%@\"", ClassTagSelectorString, button.key, key);
        }
    }
}

- (void)setCommandSet:(CommandSet *)commandSet {
    [self willChangeValueForKey:@"commandSet"];
    [self setPrimitiveValue:commandSet forKey:@"commandSet"];
    [self didChangeValueForKey:@"commandSet"];

    [self updateButtons];
}

@end

@interface PickerLabelButtonGroup ()

- (NSURL *)uriForCommandSet:(CommandSet *)commandSet;

- (CommandSet *)commandSetForURI:(NSURL *)uri;

@end

@implementation PickerLabelButtonGroup
@dynamic commandSetLabels;
@dynamic commandSets;

/// @name ￼Overridden NSManagedObject methods

/*
 * Creates empty arrays if nil and sets default background and label text colors
 */

/*
 * - (void)awakeFromInsert {
 *  [super awakeFromInsert];
 *      if (ValueIsNil(self.backgroundColor))
 *              self.backgroundColor = [UIColor clearColor];
 * }
 *
 */
- (void)addLabel:(NSAttributedString *)label withCommandSet:(CommandSet *)commandSet {
    NSURL * uri = [self uriForCommandSet:commandSet];

    assert(uri && label && [label isKindOfClass:[NSAttributedString class]] && label.string.length > 0);

    self.commandSetLabels = (self.commandSetLabels
                             ?[NSOrderedSet orderedSetWithArray:[[self.commandSetLabels array] arrayByAddingObject:label]]
                             :[NSOrderedSet orderedSetWithObject:label]);
    self.commandSets = (self.commandSets
                        ?[NSOrderedSet orderedSetWithArray:[[self.commandSets array] arrayByAddingObject:uri]]
                        :[NSOrderedSet orderedSetWithObject:uri]);
}

/// @name ￼URI helper methods

/*
 * Retrieves a URL for the specified `CommandSet`, first obtaining a permanent ID if the object
 * specified has a temporary ID.
 * @param commandSet The `CommandSet` for which to get a URI representation.
 * @return `NSURL` containing the URI for the specified `CommandSet`.
 */
- (NSURL *)uriForCommandSet:(CommandSet *)commandSet {
    if (!commandSet) return nil;

    if ([commandSet.objectID isTemporaryID]) {
        [commandSet.managedObjectContext
         performBlockAndWait:^{
             [commandSet.managedObjectContext
              obtainPermanentIDsForObjects:@[commandSet]
                                     error:nil];
         }

        ];
    }

    return [commandSet.objectID URIRepresentation];
}

/*
 * Retrieves a `CommandSet` object for the specified URI.
 * @param uri `NSURL` with the URI of the `CommandSet` to retrieve.
 * @return The `CommandSet` with the specified URI or nil if it does not exist.
 */
- (CommandSet *)commandSetForURI:(NSURL *)uri {
    CommandSet                * commandSet = nil;
    __block NSManagedObjectID * objectID   = nil;

    [self.managedObjectContext
     performBlockAndWait:^{
         objectID = [[self.managedObjectContext persistentStoreCoordinator]
                    managedObjectIDForURIRepresentation:uri];
     }

    ];

    if (objectID) commandSet = (CommandSet *)[self.managedObjectContext objectWithID:objectID];

    return commandSet;
}

@end
