//
// Remote.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "Remote.h"
#import "RemoteElement_Private.h"

static int ddLogLevel = LOG_LEVEL_WARN;
static const int msLogContext = LOG_CONTEXT_REMOTE;
#pragma unused(ddLogLevel, msLogContext)

@implementation Remote
{
    BOOL _pendingPanels;
}

@dynamic controller, panels;

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (ModelObjectShouldInitialize)
        [self.managedObjectContext performBlockAndWait:
         ^{
             self.elementType = RETypeRemote;
             self.configurationDelegate = [RemoteConfigurationDelegate
                                           configurationDelegateForElement:self];
             [self registerMode:REDefaultMode];
         }];
}

- (void)setParentElement:(RemoteElement *)parentElement {}

- (RemoteElement *)parentElement { return nil; }

- (RemoteConfigurationDelegate *)remoteConfigurationDelegate
{
    return (RemoteConfigurationDelegate *)self.configurationDelegate;
}

- (ButtonGroup *)objectForKeyedSubscript:(NSString *)subscript
{
    return (ButtonGroup *)[super objectForKeyedSubscript:subscript];
}

- (ButtonGroup *)objectAtIndexedSubscript:(NSUInteger)subscript
{
    return (ButtonGroup *)[super objectAtIndexedSubscript:subscript];
}

- (void)setTopBarHidden:(BOOL)topBarHidden
{
    REOptions options = self.options;
    self.options = (topBarHidden
                    ? options | RERemoteOptionTopBarHidden
                    : options & ~RERemoteOptionTopBarHidden);
}

- (BOOL)isTopBarHidden
{
    BOOL topBarHidden = (self.options == RERemoteOptionTopBarHidden) ? YES : NO;
    BOOL faultyTopBarHidden = (self.options & RERemoteOptionTopBarHidden) ? YES : NO;
    assert(topBarHidden == faultyTopBarHidden);
    if (topBarHidden) assert(self.options == 1);

    return topBarHidden;
}

- (BOOL)registerMode:(NSString *)mode
{
    return [self.configurationDelegate addMode:mode];
}

- (NSArray *)registeredConfigurations { return self.configurationDelegate.modeKeys;}

- (BOOL)switchToMode:(NSString *)mode
{
    self.configurationDelegate.currentMode = mode;
    return [self.configurationDelegate.currentMode isEqualToString:mode];
}

- (NSArray *)modes { return self.configurationDelegate.modeKeys; }

- (void)assignButtonGroup:(ButtonGroup *)buttonGroup assignment:(REPanelAssignment)assignment
{
    NSMutableDictionary * panels = [self.panels mutableCopy];
    panels[@(assignment)] = CollectionSafe(buttonGroup.uuid);
    self.panels = panels;
    buttonGroup.panelAssignment = assignment;
}

- (ButtonGroup *)buttonGroupForAssignment:(REPanelAssignment)assignment
{
    NSString * uuid = NilSafe(self.panels[@(assignment)]);
    return (uuid ? [ButtonGroup objectWithUUID:uuid context:self.managedObjectContext] : nil);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////

- (void)willImport:(id)data
{
    [super willImport:data];
    _pendingPanels = [data hasKey:@"panels"];
}

- (void)didImport:(id)data
{
    [super didImport:data];
    if (_pendingPanels) [self importPanels:data[@"panels"]];
}

- (BOOL)shouldImportController:(id)data {return NO;}

- (void)importPanels:(NSDictionary *)data
{
    if (!_importStatus.pendingSubelements && _pendingPanels)
    {
        [data enumerateKeysAndObjectsUsingBlock:
         ^(NSString * assignmentKey, NSString * uuid, BOOL *stop)
         {
             ButtonGroup * panel = (ButtonGroup *)memberOfCollectionWithUUID(self.subelements, uuid);
             if (panel)
             {
                 REPanelAssignment assignment = panelAssignmentFromImportKey(assignmentKey);
                 [self assignButtonGroup:panel assignment:assignment];
             }
         }];

        _pendingPanels = NO;
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////

- (MSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];
    if ([self.panels count])
        dictionary[@"panels"] = [self.panels dictionaryByMappingKeysToBlock:
                                 ^NSString *(NSNumber * key, id obj)
                                 {
                                     NSString * keyString = panelKeyForPanelAssignment(IntValue(key));
                                     return (keyString ?: [key stringValue]);
                                 }];

    NSMutableArray * modes = [self.modes mutableCopy];
    [modes removeObject:REDefaultMode];

    if ([modes count]) dictionary[@"modes"] = modes;

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}


@end

@implementation Remote (Debugging)

- (MSDictionary *)deepDescriptionDictionary
{
    Remote * element = [self faultedObject];
    assert(element);

    MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"topBarHidden"] = BOOLString(element.topBarHidden);

    return (MSDictionary *)dd;
}

@end
