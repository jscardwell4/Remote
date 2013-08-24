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

@implementation RERemote

@dynamic controller, panels;

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (MSModelObjectShouldInitialize)
        [self.managedObjectContext performBlockAndWait:
         ^{
             self.type = RETypeRemote;
             self.configurationDelegate = [RERemoteConfigurationDelegate
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

- (RERemoteConfigurationDelegate *)remoteConfigurationDelegate
{
    return (RERemoteConfigurationDelegate *)self.configurationDelegate;
}

- (REButtonGroup *)objectForKeyedSubscript:(NSString *)subscript
{
    return (REButtonGroup *)[super objectForKeyedSubscript:subscript];
}

- (REButtonGroup *)objectAtIndexedSubscript:(NSUInteger)subscript
{
    return (REButtonGroup *)[super objectAtIndexedSubscript:subscript];
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

- (void)assignButtonGroup:(REButtonGroup *)buttonGroup assignment:(REPanelAssignment)assignment
{
    NSMutableDictionary * panels = [self.panels mutableCopy];
    panels[@(assignment)] = CollectionSafeValue(buttonGroup.uuid);
    self.panels = panels;
    buttonGroup.panelAssignment = assignment;
}

- (REButtonGroup *)buttonGroupForAssignment:(REPanelAssignment)assignment
{
    NSString * uuid = NilSafeValue(self.panels[@(assignment)]);
    return (uuid ? [REButtonGroup objectWithUUID:uuid context:self.managedObjectContext] : nil);
}

@end

@implementation RERemote (Debugging)

- (MSDictionary *)deepDescriptionDictionary
{
    RERemote * element = [self faultedObject];
    assert(element);

    MSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"topBarHiddenOnLoad"] = BOOLString(element.topBarHiddenOnLoad);

    return dd;
}

@end
