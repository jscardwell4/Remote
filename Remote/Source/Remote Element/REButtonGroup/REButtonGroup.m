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

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REButtonGroup
////////////////////////////////////////////////////////////////////////////////

@implementation REButtonGroup

@dynamic label;
@dynamic labelConstraints;
@dynamic parentElement;
@dynamic controller;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self.managedObjectContext performBlockAndWait:
     ^{
        self.type = RETypeButtonGroup;
        self.configurationDelegate = [REButtonGroupConfigurationDelegate delegateForRemoteElement:self];
    }];
}

- (void)setPanelLocation:(REButtonGroupPanelLocation)panelLocation
{
    self.subtype = panelLocation << 0x10;
}

- (REButtonGroupPanelLocation)panelLocation
{
    return (REButtonGroupPanelLocation)(self.subtype >> 0x10);
}

- (REButton *)objectForKeyedSubscript:(NSString *)subscript
{
    return (REButton *)[super objectForKeyedSubscript:subscript];
}

- (REButton *)objectAtIndexedSubscript:(NSUInteger)subscript {
    return (REButton *)[super objectAtIndexedSubscript:subscript];
}

- (void)addCommandSet:(RECommandSet *)commandSet forConfiguration:(RERemoteConfiguration)config
{
    [(REButtonGroupConfigurationDelegate *)self.configurationDelegate setCommandSet:commandSet
                                                                   forConfiguration:config];
}

- (void)setCommandSet:(RECommandSet *)commandSet
{
    [(REButtonGroupConfigurationDelegate *)self.configurationDelegate setCommandSet:commandSet
                                                                   forConfiguration:REDefaultConfiguration];
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
    self.type = REButtonGroupTypePickerLabel;
}

- (RECommandSetCollection *)commandSetCollection
{
    [self willAccessValueForKey:@"commandSetColleciton"];
    RECommandSetCollection * collection = self.primitiveCommandSetCollection;
    [self didAccessValueForKey:@"commandSetCollection"];
    if (!collection)
    {
        collection = [RECommandSetCollection commandContainerInContext:self.managedObjectContext];
        self.primitiveCommandSetCollection = collection;
    }
    return collection;
}

- (void)setCommandSet:(RECommandSet *)commandSet { /* Does nothing, this may change */}

- (void)addCommandSet:(RECommandSet *)commandSet withLabel:(id)label
{
    if ([label isKindOfClass:[NSString class]])
        label = [NSAttributedString attributedStringWithString:label];
    self.commandSetCollection[commandSet] = label;
}

@end

@implementation REButtonGroup (Debugging)

- (MSDictionary *)deepDescriptionDictionary
{
    REButtonGroup * element = [self faultedObject];
    assert(element);
    
    MSMutableDictionary * descriptionDictionary = [[super deepDescriptionDictionary] mutableCopy];
    descriptionDictionary[@"label"]            = (element.label ? element.label.string : @"nil");
    descriptionDictionary[@"labelConstraints"] = (element.labelConstraints ? : @"nil");
    descriptionDictionary[@"panelLocation"]    = NSStringFromPanelLocation(element.panelLocation);

    return descriptionDictionary;
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Miscellaneous Functions
////////////////////////////////////////////////////////////////////////////////

NSString *NSStringFromPanelLocation(REButtonGroupPanelLocation location)
{
    switch (location)
    {
        case REPanelLocationNotAPanel:
            return @"REPanelLocationNotAPanel";

        case REPanelLocationTop:
            return @"REPanelLocationTop";

        case REPanelLocationBottom:
            return @"REPanelLocationBottom";

        case REPanelLocationLeft:
            return @"REPanelLocationLeft";

        case REPanelLocationRight:
            return @"REPanelLocationRight";

        default:
            return nil;
    }
}
