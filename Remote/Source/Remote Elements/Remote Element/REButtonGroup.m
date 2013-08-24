//
// REButtonGroup.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"

static int ddLogLevel   = DefaultDDLogLevel;
static int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel,msLogContext)

MSKIT_NAMETAG_DEFINITION(REButtonGroupPanel);


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonGroup
////////////////////////////////////////////////////////////////////////////////

@implementation REButtonGroup

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

    if (MSModelObjectShouldInitialize)
        [self.managedObjectContext performBlockAndWait:
         ^{
             self.type = RETypeButtonGroup;
             self.configurationDelegate = [REButtonGroupConfigurationDelegate
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

- (REButtonGroupConfigurationDelegate *)groupConfigurationDelegate
{
    return (REButtonGroupConfigurationDelegate *)self.configurationDelegate;
}

- (REButton *)objectForKeyedSubscript:(NSString *)subscript
{
    return (REButton *)[super objectForKeyedSubscript:subscript];
}

- (REButton *)objectAtIndexedSubscript:(NSUInteger)subscript {
    return (REButton *)[super objectAtIndexedSubscript:subscript];
}

- (void)addCommandContainer:(RECommandContainer *)container
              configuration:(RERemoteConfiguration)config
{
    [self.groupConfigurationDelegate setCommandContainer:container
                                     configuration:config];
}

- (void)setCommandContainer:(RECommandContainer *)container
{
    RECommandSet * commandSet = ([container isKindOfClass:[RECommandSet class]]
                                 ? (RECommandSet *)container
                                 : ([container isKindOfClass:[RECommandSetCollection class]]
                                    ? ((RECommandSetCollection *)container)[0]
                                    : nil
                                    )
                                 );
    for (REButton * button in self.subelements)
    {
        RECommand * cmd = commandSet[@(button.type)];
        button.command = cmd;
        button.enabled = (cmd != nil);
    }
}

- (RERemoteController *)controller
{
    return (self.parentElement ? self.parentElement.controller : nil);
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REPickerLabelButtonGroup
////////////////////////////////////////////////////////////////////////////////

@implementation REPickerLabelButtonGroup

@dynamic commandSetCollection;

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (MSModelObjectShouldInitialize)
        self.type = REButtonGroupTypePickerLabel;
}

- (RECommandSetCollection *)commandSetCollection
{
    [self willAccessValueForKey:@"commandSetColleciton"];
    RECommandSetCollection * collection = self.primitiveCommandSetCollection;
    [self didAccessValueForKey:@"commandSetCollection"];
    if (!collection)
    {
        collection = (RECommandSetCollection *)[self.groupConfigurationDelegate commandContainer];
        if (collection) self.primitiveCommandSetCollection = collection;
    }
    return collection;
}

- (void)setCommandSetCollection:(RECommandSetCollection *)commandSetCollection
{
    [self willChangeValueForKey:@"commandSetCollection"];
    self.primitiveCommandSetCollection = commandSetCollection;
    [self didChangeValueForKey:@"commandSetCollection"];
    [self setCommandContainer:commandSetCollection[0]];
}

- (void)addCommandSet:(RECommandSet *)commandSet withLabel:(id)label
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

@implementation REButtonGroup (Debugging)

- (MSDictionary *)deepDescriptionDictionary
{
    REButtonGroup * element = [self faultedObject];
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
