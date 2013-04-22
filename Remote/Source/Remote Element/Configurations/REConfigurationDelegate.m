//
// ConfigurationDelegate.m
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "REConfigurationDelegate_Private.h"
#import "RemoteElement.h"

MSKIT_STRING_CONST   REDefaultConfiguration = @"REDefaultConfiguration";

static const int ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE);
#pragma unused(ddLogLevel, msLogContext)

/*
Class delegateClassForElement(RemoteElement * element)
{
    if ([element isKindOfClass:[RERemote class]])
        return [RERemoteConfigurationDelegate class];
    else if ([element isKindOfClass:[REButtonGroup class]])
        return [REButtonGroupConfigurationDelegate class];
    else if ([element isKindOfClass:[REButton class]])
        return [REButtonConfigurationDelegate class];
    else
        return NULL;
}
*/

@implementation REConfigurationDelegate

@synthesize currentConfiguration = _currentConfiguration;

@dynamic configurations, subscribers, delegate, element;

+ (instancetype)configurationDelegate
{
    return [self MR_createEntity];
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    NSArray * keys = [key componentsSeparatedByString:@"."];
    if (keys.count != 2) return;

    RERemoteConfiguration configuration = keys[0];
    NSString * property = keys[1];

    if (![self hasConfiguration:configuration]) [self addConfiguration:configuration];

    NSMutableDictionary * configurations = [self.configurations mutableCopy];
    NSMutableDictionary * registration = [configurations[configuration] mutableCopy];
    registration[property] = object;
    configurations[configuration] = registration;
    self.configurations = [NSDictionary dictionaryWithDictionary:configurations];
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    NSArray * keys = [key componentsSeparatedByString:@"."];
    if (keys.count != 2) return nil;

    RERemoteConfiguration configuration = keys[0];
    NSString * property = keys[1];
    id object = ([self hasConfiguration:configuration]
                 ? self.configurations[configuration][property]
                 : nil);
    return object;
}

- (NSArray *)configurationKeys { return [self.configurations allKeys]; }

- (BOOL)addConfiguration:(RERemoteConfiguration)configuration
{
    if (![self hasConfiguration:configuration])
    {
        NSMutableDictionary * configurations = [self.configurations mutableCopy];
        configurations[configuration] = @{};
        self.configurations = [NSDictionary dictionaryWithDictionary:configurations];
        return YES;
    }
    
    else
        return NO;
}

- (RERemoteConfiguration)currentConfiguration
{
    [self willAccessValueForKey:@"currentConfiguration"];
    RERemoteConfiguration currentConfiguration = _currentConfiguration;
    [self didAccessValueForKey:@"currentConfiguration"];
    if (!currentConfiguration)
    {
        self.currentConfiguration = REDefaultConfiguration;
        currentConfiguration = _currentConfiguration;
        assert(currentConfiguration);
    }
    return currentConfiguration;
}

- (void)setCurrentConfiguration:(RERemoteConfiguration)currentConfiguration
{
    MSLogDebugTag(@"currentConfiguration:%@ ⇒ %@\nconfigurationKeys:%@",
                  _currentConfiguration, currentConfiguration, self.configurationKeys);

    [self willChangeValueForKey:@"currentConfiguration"];
    _currentConfiguration = currentConfiguration;
    if ([self hasConfiguration:currentConfiguration])
        [self updateConfigForConfiguration:currentConfiguration];
    [self didChangeValueForKey:@"currentConfiguration"];
    [self.subscribers setValue:_currentConfiguration forKeyPath:@"currentConfiguration"];
}

- (void)updateConfigForConfiguration:(RERemoteConfiguration)configuration {}

- (BOOL)hasConfiguration:(RERemoteConfiguration)key
{
    BOOL hasConfiguration = [self.configurations hasKey:key];
    return hasConfiguration;
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    if (_currentConfiguration) _currentConfiguration = REDefaultConfiguration;
    [self updateConfigForConfiguration:_currentConfiguration];
}

- (NSString *)shortDescription { return self.element.displayName; }

- (NSString *)deepDescription
{
    return (self.configurationKeys.count
            ? $(@"registered configurations:%@", [self.configurationKeys componentsJoinedByString:@"\n\t"])
            : @"no registered configurations");
}

@end
