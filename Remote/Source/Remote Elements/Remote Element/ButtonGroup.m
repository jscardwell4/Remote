//
// ButtonGroup.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "ButtonGroup.h"
#import "RemoteElement_Private.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)

MSNAMETAG_DEFINITION(REButtonGroupPanel);


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonGroup
////////////////////////////////////////////////////////////////////////////////

@implementation ButtonGroup

@dynamic label, labelConstraints, parentElement, controller;

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

- (Button *)objectForKeyedSubscript:(NSString *)subscript
{
    return (Button *)[super objectForKeyedSubscript:subscript];
}

- (Button *)objectAtIndexedSubscript:(NSUInteger)subscript {
    return (Button *)[super objectAtIndexedSubscript:subscript];
}

- (void)addCommandContainer:(CommandContainer *)container mode:(RERemoteMode)mode
{
    [self.groupConfigurationDelegate setCommandContainer:container mode:mode];
}

- (void)setCommandContainer:(CommandContainer *)container
{
    //TODO: Update
    CommandSet * commandSet = ([container isKindOfClass:[CommandSet class]]
                                 ? (CommandSet *)container
                                 : ([container isKindOfClass:[CommandSetCollection class]]
                                    ? ((CommandSetCollection *)container)[0]
                                    : nil
                                    )
                                 );
    for (Button * button in self.subelements)
    {
        Command * cmd = commandSet[@(button.elementType)];
        button.command = cmd;
        button.enabled = (cmd != nil);
    }
}

- (RemoteController *)controller
{
    return (self.parentElement ? self.parentElement.controller : nil);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////

- (BOOL)shouldImportTopToolbarForController:(id)data {return NO;}

/*
- (void)importLabel:(id)data {}

- (void)importLabelConstraints:(id)data {}
*/


////////////////////////////////////////////////////////////////////////////////
#pragma mark Command set collections
////////////////////////////////////////////////////////////////////////////////


- (BOOL)shouldUseCommandSetCollection
{
    return ((self.options & REButtonGroupOptionCommandSetContainer) ==
            REButtonGroupOptionCommandSetContainer);
}

- (void)addCommandSet:(CommandSet *)commandSet withLabel:(id)label
{
    if (!([self shouldUseCommandSetCollection] && commandSet && label)) return;

    CommandContainer * container = self.groupConfigurationDelegate.commandContainer;
    if (!isKind(container, CommandSetCollection)) return;

    ((CommandSetCollection *)container)[commandSet] =
        (isAttributedStringKind(label)
         ? label
         : (isStringKind(label)
            ? [NSAttributedString attributedStringWithString:label]
            : nil));

}

- (CommandSetCollection *)commandSetCollection
{
    CommandSetCollection * collection = nil;

    if ([self shouldUseCommandSetCollection])
    {
        CommandContainer * container = self.groupConfigurationDelegate.commandContainer;
        if (isKind(container, CommandSetCollection)) collection = (CommandSetCollection *)container;
    }

    return collection;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////

- (MSDictionary *)JSONDictionary
{
    //TODO: Update

    MSDictionary * dictionary = [super JSONDictionary];

    if (self.label)
        dictionary[@"label"] = self.label;

    if (self.labelConstraints)
        dictionary[@"labelConstraints"] = self.labelConstraints;

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
//    dd[@"label"] = (element.label ? element.label.string : @"nil");
//    dd[@"labelConstraints"] = (element.labelConstraints ? : @"nil");
    dd[@"panelAssignment"] = NSStringFromREPanelAssignment(element.panelAssignment);

    return (MSDictionary *)dd;
}

@end
