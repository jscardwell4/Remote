//
// ButtonGroup.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"

static int ddLogLevel   = DefaultDDLogLevel;
static int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)

MSNAMETAG_DEFINITION(REButtonGroupPanel);


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonGroup
////////////////////////////////////////////////////////////////////////////////

@implementation ButtonGroup

@dynamic label;
@dynamic labelConstraints;
@dynamic parentElement;
@dynamic controller;

+ (instancetype)buttonGroupWithType:(REType)type
{
    return ((baseTypeForREType(type) == RETypeButtonGroup)
            ? [self remoteElementWithAttributes:@{@"type": @(type)}]
            : nil);
}

+ (instancetype)buttonGroupWithType:(REType)type context:(NSManagedObjectContext *)moc
{
    return ((baseTypeForREType(type) == RETypeButtonGroup)
            ? [self remoteElementInContext:moc attributes:@{@"type": @(type)}]
            : nil);
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (ModelObjectShouldInitialize)
        [self.managedObjectContext performBlockAndWait:
         ^{
             self.type = RETypeButtonGroup;
             self.configurationDelegate = [ButtonGroupConfigurationDelegate
                                           delegateForRemoteElement:self];
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

    if (self.panelLocation == REPanelLocationUnassigned || self.panelTrigger == REPanelNoTrigger)
        self.type &= ~REButtonGroupTypePanel | RETypeButtonGroup;

    else
        self.type |= REButtonGroupTypePanel;
}

- (REPanelAssignment)panelAssignment { return (REPanelAssignment)self.subtype; }

- (REPanelTrigger)panelTrigger { return self.panelAssignment & REPanelAssignmentTriggerMask; }

- (REPanelLocation)panelLocation { return self.panelAssignment & REPanelAssignmentLocationMask; }

- (BOOL)isPanel { return ((self.type & REButtonGroupTypePanel) == REButtonGroupTypePanel); }

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

- (void)addCommandContainer:(CommandContainer *)container
              configuration:(RERemoteConfiguration)config
{
    [self.groupConfigurationDelegate setCommandContainer:container
                                     configuration:config];
}

- (void)setCommandContainer:(CommandContainer *)container
{
    CommandSet * commandSet = ([container isKindOfClass:[CommandSet class]]
                                 ? (CommandSet *)container
                                 : ([container isKindOfClass:[CommandSetCollection class]]
                                    ? ((CommandSetCollection *)container)[0]
                                    : nil
                                    )
                                 );
    for (Button * button in self.subelements)
    {
        Command * cmd = commandSet[@(button.type)];
        button.command = cmd;
        button.enabled = (cmd != nil);
    }
}

- (RemoteController *)controller
{
    return (self.parentElement ? self.parentElement.controller : nil);
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REPickerLabelButtonGroup
////////////////////////////////////////////////////////////////////////////////

@implementation PickerLabelButtonGroup

@dynamic commandSetCollection;

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (ModelObjectShouldInitialize)
        self.type = REButtonGroupTypePickerLabel;
}

- (CommandSetCollection *)commandSetCollection
{
    [self willAccessValueForKey:@"commandSetColleciton"];
    CommandSetCollection * collection = self.primitiveCommandSetCollection;
    [self didAccessValueForKey:@"commandSetCollection"];
    if (!collection)
    {
        collection = (CommandSetCollection *)[self.groupConfigurationDelegate commandContainer];
        if (collection) self.primitiveCommandSetCollection = collection;
    }
    return collection;
}

- (void)setCommandSetCollection:(CommandSetCollection *)commandSetCollection
{
    [self willChangeValueForKey:@"commandSetCollection"];
    self.primitiveCommandSetCollection = commandSetCollection;
    [self didChangeValueForKey:@"commandSetCollection"];
    [self setCommandContainer:commandSetCollection[0]];
}

- (void)addCommandSet:(CommandSet *)commandSet withLabel:(id)label
{
    self.commandSetCollection[commandSet] = ([label isKindOfClass:[NSAttributedString class]]
                                             ? label
                                             : ([label isKindOfClass:[NSString class]]
                                                ? [NSAttributedString
                                                   attributedStringWithString:label]
                                                : nil
                                                )
                                             );
}

@end

@implementation ButtonGroup (Debugging)

- (MSDictionary *)deepDescriptionDictionary
{
    ButtonGroup * element = [self faultedObject];
    assert(element);
    
    MSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"label"] = (element.label ? element.label.string : @"nil");
    dd[@"labelConstraints"] = (element.labelConstraints ? : @"nil");
    dd[@"panelAssignment"] = NSStringFromREPanelAssignment(element.panelAssignment);

    return dd;
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Miscellaneous Functions
////////////////////////////////////////////////////////////////////////////////
