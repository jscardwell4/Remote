//
//  REConfigurationDelegate_Private.h
//  Remote
//
//  Created by Jason Cardwell on 3/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "ConfigurationDelegate.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark Abstract Configuration Delegate
////////////////////////////////////////////////////////////////////////////////

@interface ConfigurationDelegate ()

@property (nonatomic, strong)            NSDictionary        * configurations;
@property (nonatomic, strong, readwrite) NSSet               * subscribers;
@property (nonatomic, strong, readwrite) RemoteElement       * element;

- (void)updateForMode:(NSString *)mode;

@end

@interface ConfigurationDelegate (CoreDataGeneratedAccessors)

@property (nonatomic) ConfigurationDelegate * primitiveDelegate;
@property (nonatomic) NSMutableDictionary   * primitiveConfigurations;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark ControlStateKeyPath
////////////////////////////////////////////////////////////////////////////////
@interface ControlStateKeyPath : NSObject

+ (ControlStateKeyPath *)keyPathFromString:(NSString *)keypath;
+ (ControlStateKeyPath *)keyPathWithMode:(RERemoteMode)mode property:(NSString *)property;

@property (nonatomic, copy, readwrite) RERemoteMode   mode;
@property (nonatomic, copy, readwrite) NSString     * property;
@property (nonatomic, copy, readonly)  NSString     * keypath;

@end

MSSTATIC_INLINE ControlStateKeyPath * makeKeyPath(NSString *s,...)
{
    if (StringIsEmpty(s)) return nil;
    NSArray * components = [s componentsSeparatedByString:@"."];
    RERemoteMode mode = components[0];
    NSString * property = nil;
    if ([components count] > 1) property = components[1];
    else
    {
        va_list args;
        va_start(args, s);
        property = va_arg(args, NSString *);
        va_end(args);
    }
    if (!(mode && property))
        ThrowInvalidArgument(s, (must provide either a string with keypath of form mode.property or
                                 two strings, i.e. mode, property));

    ControlStateKeyPath * keypath = [ControlStateKeyPath keyPathWithMode:mode property:property];
    return keypath;
}

#import "RemoteElement_Private.h"
