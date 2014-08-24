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

@property (nonatomic, weak, readonly)  RemoteController * controller;

@end

@implementation ButtonGroup
{
    NSUInteger _commandSetCollectionIndex; /// index of command set in collection currently in use
}

@dynamic labelConstraints, labelAttributes, controller;

+ (instancetype)buttonGroupWithRole:(RERole)role
{
    return [self remoteElementWithAttributes:@{@"role" : @(role)}];
}

+ (instancetype)buttonGroupWithRole:(RERole)role context:(NSManagedObjectContext *)moc
{
    return [self remoteElementInContext:moc attributes:@{@"role" : @(role)}];

}

+ (REType)elementType { return RETypeButtonGroup; }

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

- (NSAttributedString *)label
{
    [self willAccessValueForKey:@"label"];
    NSAttributedString * label = self[$(@"%@.label", self.currentMode)];
    [self didAccessValueForKey:@"label"];
    return label;
}

- (CommandContainer *)commandContainer
{
    [self willAccessValueForKey:@"commandContainer"];
    NSURL * containerURI = self[$(@"%@.commandContainer", self.currentMode)];
    [self didAccessValueForKey:@"commandContainer"];
    CommandContainer * container = nil;
    if (containerURI) container = [self.managedObjectContext objectForURI:containerURI];
    return container;
}

- (void)setCommandContainer:(CommandContainer *)container mode:(RERemoteMode)mode
{
    self[$(@"%@.commandContainer", mode)] = container.permanentURI;
}

- (CommandContainer *)commandContainerForMode:(RERemoteMode)mode {
    CommandContainer * container = nil;
    NSURL * uri = self[$(@"%@.commandContainer", mode)];
    if (uri) container = [self.managedObjectContext objectForURI:uri];
    return container;
}

- (void)setLabel:(id)label mode:(RERemoteMode)mode
{
    if (!isAttributedStringKind(label))
        label = (isStringKind(label) ? [NSAttributedString attributedStringWithString:label] : nil);

    if (label && mode)
        self[$(@"%@.label", mode)] = label;
}

- (void)updateForMode:(RERemoteMode)mode {
    [super updateForMode:mode];
    [self updateButtons];
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

- (RemoteController *)controller
{
    return (self.parentElement ? [(Remote *)self.parentElement controller] : nil);
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

- (void)updateWithData:(NSDictionary *)data {
    /*
            {
                "uuid": "3D15E6CA-A182-476D-87D1-8E2CE774346E",
                "name": "Sonos Activity Rocker",
                "elementType": "button-group",
                "role": "rocker",
                "shape": "rounded-rectangle",
                "style": "border gloss1",
                "constraints": {
                    "index": {
                        "buttonTop": "B9C7296F-E1C1-4425-98AF-E67740F64CFE",
                        "buttonBottom": "04A0CAB9-1EFF-46FC-864A-6C00759DD0BD",
                        "sonosActivityRocker": "3D15E6CA-A182-476D-87D1-8E2CE774346E"
                    },
                    "format": [
                            "buttonBottom.height = buttonTop.height",
                            "buttonBottom.left = sonosActivityRocker.left",
                            "buttonBottom.right = sonosActivityRocker.right",
                            "buttonBottom.top = buttonTop.bottom",
                            "buttonTop.height = sonosActivityRocker.height * 0.5",
                            "buttonTop.left = sonosActivityRocker.left",
                            "buttonTop.right = sonosActivityRocker.right",
                            "buttonTop.top = sonosActivityRocker.top",
                            "sonosActivityRocker.height ≥ 150",
                            "sonosActivityRocker.width = 70"
                    ]
                },
                "backgroundColor": "black",
                "subelements": [ **Button**,
                "command-set-collection.default": {
                    "VOL": {
                        "type": "rocker",
                        "top": {
                            "class": "sendir",
                            "code.uuid": "DFBB376D-E061-448C-922C-32B20F69D11C" // Volume Up
                        },
                        "bottom": {
                            "class": "sendir",
                            "code.uuid": "C27992CE-912E-4D75-8938-AE80A0C2F9F0" // Volume Down
                        }
                    }
                },
                "labelAttributes": {
                    "font": "HelveticaNeue@20",
                    "foreground-color": "white",
                    "stroke-color": "white@50%",
                    "stroke-width": -2,
                    "paragraph-style.alignment": "center"
                }
            }
     */

    [super updateWithData:data];

    NSManagedObjectContext * moc = self.managedObjectContext;

    NSDictionary * commandSetData           = data[@"command-set"];
    NSDictionary * commandSetCollectionData = data[@"command-set-collection"];

    if (commandSetData && isDictionaryKind(commandSetData)) {
        for (NSString * mode  in commandSetData)
        {
            CommandContainer * container = [self commandContainerForMode:mode];
            if (container) {
                [self.managedObjectContext deleteObject:container];
                container = nil;
            }

            CommandSet * commandSet = [CommandSet importObjectFromData:commandSetData[mode] inContext:moc];
            if (commandSet) [self setCommandContainer:commandSet mode:mode];
        }
    }


    else if (commandSetCollectionData && isDictionaryKind(commandSetCollectionData)) {
        for (NSString * mode in commandSetCollectionData)
        {
            CommandContainer * container = [self commandContainerForMode:mode];
            if (container) {
                [self.managedObjectContext deleteObject:container];
                container = nil;
            }

            CommandSetCollection * collection =
                [CommandSetCollection importObjectFromData:commandSetCollectionData[mode] inContext:moc];

            if (collection)
                [self setCommandContainer:collection mode:mode];
        }
    }

    NSDictionary * labelAttributes = data[@"labelAttributes"];
    
    if (labelAttributes)
        self.labelAttributes =
            [[StringAttributesJSONValueTransformer new] reverseTransformedValue:labelAttributes];

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////

- (MSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];

    MSDictionary * commandSets           = [MSDictionary dictionary];
    MSDictionary * commandSetCollections = [MSDictionary dictionary];

    for (RERemoteMode mode in self.modes)
    {
        CommandContainer * container = [self commandContainerForMode:mode];
        if (isKind(container, CommandSetCollection))
            commandSetCollections[mode] = container.JSONDictionary;
        else if (isKind(container, CommandSet))
            commandSets[mode] = container.JSONDictionary;
    }

    dictionary[@"command-set-collection"] = ([commandSetCollections count] ? commandSetCollections : NullObject);

    dictionary[@"command-set"] = ([commandSets count] ? commandSets : NullObject);

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
