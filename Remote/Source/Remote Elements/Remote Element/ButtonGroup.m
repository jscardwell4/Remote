//
// ButtonGroup.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "ButtonGroup.h"
#import "RemoteElement_Private.h"
#import "CommandSetCollection.h"
#import "JSONObjectKeys.h"
#import "StringAttributesValueTransformer.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)

MSNAMETAG_DEFINITION(REButtonGroupPanel);

@interface ButtonGroup ()

@property (nonatomic, strong, readwrite) Remote           * parentElement;
@property (nonatomic, weak,   readonly)  RemoteController * controller;

@end

@implementation ButtonGroup
{
    NSUInteger _commandSetCollectionIndex; /// index of command set in collection currently in use
}

@dynamic labelConstraints, labelAttributes, parentElement, controller;
@synthesize label = _label, commandContainer = _commandContainer;

+ (instancetype)buttonGroupWithRole:(RERole)role
{
    return [self remoteElementWithAttributes:@{@"role" : @(role)}];
}

+ (instancetype)buttonGroupWithRole:(RERole)role context:(NSManagedObjectContext *)moc
{
    return [self remoteElementInContext:moc attributes:@{@"role" : @(role)}];

}

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (ModelObjectShouldInitialize)
        [self.managedObjectContext performBlockAndWait:
         ^{
             self.elementType = RETypeButtonGroup;
             self.configurationDelegate = [ButtonGroupConfigurationDelegate
                                           configurationDelegateForElement:self];
         }];
}

- (void)setPanelLocation:(REPanelLocation)panelLocation
{
    switch (panelLocation)
    {
        case REPanelLocationTop:
        case REPanelLocationBottom:
        case REPanelLocationLeft:
        case REPanelLocationRight:
        {
            self.subtype = panelLocation | self.panelTrigger;
        }   break;

        default:
        {
            self.subtype = self.panelTrigger;
        }   break;
    }
}

- (void)setPanelTrigger:(REPanelTrigger)panelTrigger
{
    switch (panelTrigger)
    {
        case REPanelTrigger1:
        case REPanelTrigger2:
        case REPanelTrigger3:
        {
            self.subtype = panelTrigger | self.panelLocation;
        }   break;

        default:
        {
            self.subtype = self.panelLocation;
        }   break;
    }
}

- (void)setPanelAssignment:(REPanelAssignment)panelAssignment
{
    REPanelLocation location = panelAssignment & REPanelAssignmentLocationMask;
    REPanelTrigger trigger = panelAssignment & REPanelAssignmentTriggerMask;
    self.panelLocation = location;
    self.panelTrigger = trigger;
}

- (REPanelAssignment)panelAssignment { return (REPanelAssignment)self.subtype; }

- (REPanelTrigger)panelTrigger { return self.panelAssignment & REPanelAssignmentTriggerMask; }

- (REPanelLocation)panelLocation { return self.panelAssignment & REPanelAssignmentLocationMask; }

- (BOOL)isPanel { return (self.subtype ? YES : NO); }

- (ButtonGroupConfigurationDelegate *)groupConfigurationDelegate
{
    return (ButtonGroupConfigurationDelegate *)self.configurationDelegate;
}

/*
- (Button *)objectForKeyedSubscript:(NSString *)subscript
{
    return (Button *)[super objectForKeyedSubscript:subscript];
}

- (Button *)objectAtIndexedSubscript:(NSUInteger)subscript {
    return (Button *)[super objectAtIndexedSubscript:subscript];
}
*/

- (NSAttributedString *)label
{
    [self willAccessValueForKey:@"label"];
    NSAttributedString * label = _label;
    [self didAccessValueForKey:@"label"];
    if (!label)
    {
        label = self.groupConfigurationDelegate.label;
        if (label) _label = label;
    }
    return label;
}

- (CommandContainer *)commandContainer
{
    [self willAccessValueForKey:@"commandContainer"];
    CommandContainer * container = _commandContainer;
    [self didAccessValueForKey:@"commandContainer"];
    if (!container)
    {
        container = self.groupConfigurationDelegate.commandContainer;
        if (container) _commandContainer = container;
    }
    return container;
}

- (void)setCommandContainer:(CommandContainer *)container mode:(RERemoteMode)mode
{
    [self.groupConfigurationDelegate setCommandContainer:container mode:mode];
}

- (void)setLabel:(id)label mode:(RERemoteMode)mode
{
    if (!isAttributedStringKind(label))
        label = (isStringKind(label)
                 ? [NSAttributedString attributedStringWithString:label]
                 : nil);
    if (label && mode)
        [self.groupConfigurationDelegate setLabel:label mode:mode];
}

- (void)setLabel:(NSAttributedString *)label
{
    [self willChangeValueForKey:@"label"];
    _label = label;
    [self didChangeValueForKey:@"label"];
}

- (void)updateButtons
{
    CommandContainer * container = self.commandContainer;

    if (!(isKind(container, CommandSet) || isKind(container, CommandSetCollection))) return;

    CommandSet * commandSet = ([container isKindOfClass:[CommandSet class]]
                               ? (CommandSet *)container
                               : [(CommandSetCollection *)container
                                  commandSetAtIndex:_commandSetCollectionIndex]);

    if (commandSet) commandSet = [commandSet faultedObject];

    for (Button * button in self.subelements)
    {
        if (button.role == REButtonRoleTuck) continue;

        Command * cmd = commandSet[@(button.role)];
        button.command = cmd;
        button.enabled = (cmd != nil);
        assert(button.enabled);
    }
}

- (void)setCommandContainer:(CommandContainer *)container
{
    [self willChangeValueForKey:@"commandContainer"];
    _commandContainer = container;
    [self didChangeValueForKey:@"commandContainer"];

    [self updateButtons];
}

- (RemoteController *)controller
{
    return (self.parentElement ? self.parentElement.controller : nil);
}

- (NSAttributedString *)labelForCommandSetAtIndex:(NSUInteger)index
{
    CommandContainer * container = self.commandContainer;

    if (!(container && isKind(self.commandContainer, CommandSetCollection) && index < container.count))
        return nil;

    NSString * labelText = [(CommandSetCollection *)container labelAtIndex:index];
    if (!labelText) return nil;

    MSDictionary * labelAttributes = self.labelAttributes;
    if (!labelAttributes) labelAttributes = [MSDictionary dictionary];
    labelAttributes[RETitleTextAttributeKey] = labelText;

    return [[StringAttributesValueTransformer new] transformedValue:labelAttributes];
}

- (void)selectCommandSetAtIndex:(NSUInteger)index
{
    CommandContainer * container = self.commandContainer;
    if (container && isKind(self.commandContainer, CommandSetCollection) && index < container.count)
    {
        _commandSetCollectionIndex = index;
        [self updateButtons];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////


/*
- (void)didImport:(id)data
{
    [super didImport:data];
    [self.groupConfigurationDelegate importCommandContainer:data];
}

- (BOOL)shouldImportTopToolbarForController:(id)data {return NO;}

- (void)importLabelAttributes:(id)data
{
    if (isDictionaryKind(data))
    {
        MSDictionary * attributes = [[StringAttributesJSONValueTransformer new]
                                     reverseTransformedValue:data];
        if (isMSDictionary(attributes)) self.labelAttributes = attributes;
    }
}

- (void)importLabel:(id)data
{
    if (isDictionaryKind(data))
        for (NSString * mode in data) if (isStringKind(mode)) [self setLabel:data[mode] mode:mode];
}

*/
/*
- (void)importLabelConstraints:(id)data {}
*/

////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////

- (MSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];

    MSDictionary * commandSets           = [MSDictionary dictionary];
    MSDictionary * commandSetCollections = [MSDictionary dictionary];

    for (RERemoteMode mode  in self.groupConfigurationDelegate.modeKeys)
    {
        CommandContainer * container = [self.groupConfigurationDelegate commandContainerForMode:mode];
        if (isKind(container, CommandSetCollection))
            commandSetCollections[mode] = container.JSONDictionary;
        else if (isKind(container, CommandSet))
            commandSets[mode] = container.JSONDictionary;
    }

    dictionary[ButtonGroupCommandSetCollectionJSONKey] =
        ([commandSetCollections count] ? commandSetCollections : NullObject);

    dictionary[ButtonGroupCommandSetJSONKey] =
        ([commandSets count] ? commandSets : NullObject);

/*
    if (self.labelConstraints)
        dictionary[@"labelConstraints"] = self.labelConstraints;
*/

    dictionary[@"label"] = CollectionSafe(self.label);
    dictionary[@"labelAttributes"] = CollectionSafe([[StringAttributesJSONValueTransformer new]
                                                     transformedValue:self.labelAttributes]);

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}

@end

@implementation ButtonGroup (Debugging)

- (MSDictionary *)deepDescriptionDictionary
{
    //TODO: Update

    ButtonGroup * element = [self faultedObject];
    assert(element);
    
    MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

    for (NSString * mode in self.groupConfigurationDelegate.modeKeys)
    {
//        CommandContainer * container = [self.groupConfigurationDelegate con]
    }
//    dd[@"label"] = (element.label ? element.label.string : @"nil");
//    dd[@"labelConstraints"] = (element.labelConstraints ? : @"nil");
    dd[@"panelAssignment"] = NSStringFromREPanelAssignment(element.panelAssignment);

    return (MSDictionary *)dd;
}

@end
