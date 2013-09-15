//
// Remote.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"

static const int ddLogLevel = LOG_LEVEL_WARN;
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
             self.type = RETypeRemote;
             self.configurationDelegate = [RemoteConfigurationDelegate
                                           delegateForRemoteElement:self];
             [self registerConfiguration:REDefaultConfiguration];
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

- (void)setTopBarHiddenOnLoad:(BOOL)topBarHiddenOnLoad
{
    REOptions options = self.options;
    self.options = (topBarHiddenOnLoad
                    ? options | RERemoteOptionTopBarHiddenOnLoad
                    : options & ~RERemoteOptionTopBarHiddenOnLoad);
}

- (BOOL)isTopBarHiddenOnLoad
{
    BOOL topBarHiddenOnLoad = (self.options == RERemoteOptionTopBarHiddenOnLoad) ? YES : NO;
    BOOL faultyTopBarHiddenOnLoad = (self.options & RERemoteOptionTopBarHiddenOnLoad) ? YES : NO;
    assert(topBarHiddenOnLoad == faultyTopBarHiddenOnLoad);
    if (topBarHiddenOnLoad) assert(self.options == 1);

    return topBarHiddenOnLoad;
}

- (BOOL)registerConfiguration:(NSString *)configuration
{
    return [self.configurationDelegate addConfiguration:configuration];
}

- (NSArray *)registeredConfigurations { return self.configurationDelegate.configurationKeys;}

- (BOOL)switchToConfiguration:(NSString *)configuration
{
    self.configurationDelegate.currentConfiguration = configuration;
    return [self.configurationDelegate.currentConfiguration isEqualToString:configuration];
}

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

@end

@implementation Remote (Debugging)

- (MSDictionary *)deepDescriptionDictionary
{
    Remote * element = [self faultedObject];
    assert(element);

    MSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"topBarHiddenOnLoad"] = BOOLString(element.topBarHiddenOnLoad);

    return dd;
}

@end
