//
// ConfigurationDelegate.m
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "ConfigurationDelegate_Private.h"
#import "RemoteElement.h"

MSSTRING_CONST   REDefaultMode = @"default";

static int ddLogLevel   = LOG_LEVEL_DEBUG;
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

@implementation ConfigurationDelegate

@synthesize currentMode = _currentMode;

@dynamic configurations, subscribers, delegate, element, autoPopulateFromDefaultMode;

+ (instancetype)configurationDelegate
{
    return [self MR_createEntity];
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    NSArray * keys = [key componentsSeparatedByString:@"."];
    if (keys.count != 2) return;

    RERemoteMode mode = keys[0];
    NSString * property = keys[1];

    if (![self hasMode:mode]) [self addMode:mode];

    NSMutableDictionary * configurations = [self.configurations mutableCopy];
    NSMutableDictionary * registration = [configurations[mode] mutableCopy];
    registration[property] = CollectionSafeValue(object);
    configurations[mode] = registration;
    self.configurations = [NSDictionary dictionaryWithDictionary:configurations];
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    NSArray * keys = [key componentsSeparatedByString:@"."];
    if (keys.count != 2) return nil;

    RERemoteMode mode = keys[0];
    NSString * property = keys[1];
    id object = ([self hasMode:mode]
                 ? self.configurations[mode][property]
                 : nil);
    return NilSafeValue(object);
}

- (NSArray *)modeKeys { return [self.configurations allKeys]; }

- (BOOL)addMode:(RERemoteMode)mode
{
    if (![self hasMode:mode])
    {
        NSMutableDictionary * configurations = [self.configurations mutableCopy];
        configurations[mode] = (  ![mode isEqualToString:REDefaultMode]
                                         && self.autoPopulateFromDefaultMode
                                         && configurations[REDefaultMode]
                                         ? [configurations[REDefaultMode] copy]
                                         : @{});
        self.configurations = [NSDictionary dictionaryWithDictionary:configurations];
        return YES;
    }
    
    else
        return NO;
}

- (RERemoteMode)currentMode
{
    [self willAccessValueForKey:@"currentMode"];
    RERemoteMode currentMode = _currentMode;
    [self didAccessValueForKey:@"currentMode"];
    if (!currentMode)
    {
        _currentMode = REDefaultMode;
        currentMode = _currentMode;
        assert(currentMode);
    }
    return currentMode;
}

- (void)setCurrentMode:(RERemoteMode)currentMode
{
    MSLogDebugTag(@"currentMode:%@ ⇒ %@\nmodeKeys:%@",
                  _currentMode, currentMode, self.modeKeys);

    [self willChangeValueForKey:@"currentMode"];
    _currentMode = currentMode;
    if (![self hasMode:currentMode]) [self addMode:currentMode];
    [self updateForMode:currentMode];
    [self didChangeValueForKey:@"currentMode"];
    [self.subscribers setValue:_currentMode forKeyPath:@"currentMode"];
}

- (void)updateForMode:(RERemoteMode)mode {}

- (BOOL)hasMode:(RERemoteMode)key
{
    BOOL hasMode = [self.configurations hasKey:key];
    return hasMode;
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    _currentMode = REDefaultMode;
    [self updateForMode:_currentMode];
}

- (void)refresh { [self updateForMode:_currentMode]; }

- (NSString *)shortDescription { return self.element.name; }

- (NSString *)deepDescription
{
    return (self.modeKeys.count
            ? $(@"registered configurations:%@", [self.modeKeys componentsJoinedByString:@"\n\t"])
            : @"no registered configurations");
}

@end
