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
//{
//    MSDictionary * _primitiveConfigurations;
//}

@synthesize
currentMode = _currentMode;

@dynamic
configurations,
subscribers,
delegate,
element,
autoPopulateFromDefaultMode;

+ (instancetype)configurationDelegateForElement:(RemoteElement *)element
{
    if (!element) ThrowInvalidNilArgument(element);

    __block ConfigurationDelegate * configurationDelegate = nil;
    [element.managedObjectContext performBlockAndWait:
     ^{
         configurationDelegate = [self MR_createInContext:element.managedObjectContext];
         configurationDelegate.element = element;
     }];

    return configurationDelegate;
}

- (void)setObject:(id)object forKeyedSubscript:(id)key
{
    ControlStateKeyPath * kp = (isKind(key, [ControlStateKeyPath class]) ? key : makeKeyPath(key));

    if (![self hasMode:kp.mode]) [self addMode:kp.mode];

    NSMutableDictionary * configurations = [self.configurations mutableCopy];
    NSMutableDictionary * registration = [configurations[kp.mode] mutableCopy];
    if (object) registration[kp.property] = [object copy];
    else [registration removeObjectForKey:kp.property];
    configurations[kp.mode] = registration;
    self.configurations = configurations;
}

- (id)objectForKeyedSubscript:(id)key
{
    ControlStateKeyPath * kp = (isKind(key, [ControlStateKeyPath class]) ? key : makeKeyPath(key));
    return NilSafe(([self hasMode:kp.mode] ? self.configurations[kp.mode][kp.property] : nil));
}

- (NSArray *)modeKeys { return [self.configurations allKeys]; }

- (BOOL)addMode:(RERemoteMode)mode
{
    if (![self hasMode:mode])
    {
        NSMutableDictionary * configurations = [self.configurations mutableCopy];
        configurations[mode] = @{};/*
(  ![mode isEqualToString:REDefaultMode]
                                && self.autoPopulateFromDefaultMode
                                && configurations[REDefaultMode]
                                ? [configurations[REDefaultMode] copy]
                                : [MSDictionary dictionary]);
*/

        self.configurations = configurations;
        return YES;
    }
    
    else
        return YES;
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

- (BOOL)hasMode:(RERemoteMode)key { return [self.configurations hasKey:key]; }

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


////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateKeyPath
////////////////////////////////////////////////////////////////////////////////

@implementation ControlStateKeyPath

+ (ControlStateKeyPath *)keyPathFromString:(NSString *)keypath { return makeKeyPath(keypath); }

+ (ControlStateKeyPath *)keyPathWithMode:(RERemoteMode)mode property:(NSString *)property
{
    if (!mode)
        ThrowInvalidNilArgument(mode);

    else if (!property)
        ThrowInvalidNilArgument(property);

    ControlStateKeyPath * controlStateKeyPath = [self new];
    controlStateKeyPath.mode = mode;
    controlStateKeyPath.property = property;

    return controlStateKeyPath;
}

- (NSString *)keypath { return [@"." join:@[_mode,_property]]; }

@end
