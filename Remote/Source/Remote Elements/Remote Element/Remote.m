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

@dynamic controller, panels;

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (ModelObjectShouldInitialize)
        [self.managedObjectContext performBlockAndWait:
         ^{
             self.elementType = RETypeRemote;
             self.configurationDelegate = [RemoteConfigurationDelegate
                                           delegateForRemoteElement:self];
             [self registerMode:REDefaultMode];
         }];
}

- (void)setParentElement:(RemoteElement *)parentElement
{
    if (parentElement)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"remotes cannot have a parent element"
                                     userInfo:nil];
}

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
    panels[@(assignment)] = CollectionSafeValue(buttonGroup.uuid);
    self.panels = panels;
    buttonGroup.panelAssignment = assignment;
}

- (ButtonGroup *)buttonGroupForAssignment:(REPanelAssignment)assignment
{
    NSString * uuid = NilSafeValue(self.panels[@(assignment)]);
    return (uuid ? [ButtonGroup objectWithUUID:uuid context:self.managedObjectContext] : nil);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [[super JSONDictionary] mutableCopy];
    if ([self.panels count])
        dictionary[@"panels"] = [self.panels dictionaryByMappingKeysToBlock:
                                 ^NSString *(NSNumber * key, id obj)
                                 {
                                     NSString * keyString = panelKeyForPanelAssignment(INTValue(key));
                                     return (keyString ?: [key stringValue]);
                                 }];

    NSArray * modes = self.modes;
    if ([modes count]) dictionary[@"modes"] = modes;

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
