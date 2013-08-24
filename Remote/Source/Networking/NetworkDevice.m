//
// NetworkDevice.m
// Remote
//
// Created by Jason Cardwell on 9/25/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "NetworkDevice.h"
#import "CoreDataManager.h"

// property keys
MSKIT_STRING_CONST   NDDeviceMakeKey     = @"make";
MSKIT_STRING_CONST   NDDeviceModelKey    = @"model";
MSKIT_STRING_CONST   NDDeviceRevisionKey = @"revision";
MSKIT_STRING_CONST   NDDeviceStatusKey   = @"status";
MSKIT_STRING_CONST   NDDeviceUUIDKey     = @"deviceUUID";
MSKIT_STRING_CONST   NDDeviceURLKey      = @"configURL";


static const int   ddLogLevel = LOG_LEVEL_DEBUG;

@interface NetworkDevice ()

@property (nonatomic, copy, readwrite) NSString * deviceUUID;
@property (nonatomic, copy, readwrite) NSString * make;
@property (nonatomic, copy, readwrite) NSString * model;
@property (nonatomic, copy, readwrite) NSString * status;
@property (nonatomic, copy, readwrite) NSString * configURL;
@property (nonatomic, copy, readwrite) NSString * revision;

@end

@implementation NetworkDevice

@dynamic deviceUUID, make, model, status, configURL, revision, name;

+ (instancetype)device { return [self MR_createEntity]; }

+ (instancetype)deviceInContext:(NSManagedObjectContext *)context
{
    return [self MR_createInContext:context];
}

+ (instancetype)deviceWithAttributes:(NSDictionary *)attributes
{
    return [self deviceWithAttributes:attributes
                              context:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (instancetype)deviceWithAttributes:(NSDictionary *)attributes
                             context:(NSManagedObjectContext *)context
{   
    NSString * deviceUUID = attributes[NDDeviceUUIDKey];

    if ([self deviceExistsWithDeviceUUID:deviceUUID])
        return [self MR_findFirstByAttribute:@"deviceUUID" withValue:deviceUUID inContext:context];

    else
    {
        NetworkDevice * device = [self deviceInContext:context];
        [device setValuesForKeysWithDictionary:attributes];
        return device;
    }
}

+ (BOOL)deviceExistsWithDeviceUUID:(NSString *)deviceUUID
{
    return (   StringIsNotEmpty(deviceUUID)
            && [self
                MR_countOfEntitiesWithPredicate:NSMakePredicate(@"deviceUUID == %@", deviceUUID)] == 1);
}

@end

// constants
MSKIT_STRING_CONST   NDiTachDeviceMulticastGroupAddress = @"239.255.250.250";
MSKIT_STRING_CONST   NDiTachDeviceMulticastGroupPort    = @"9131";
MSKIT_STRING_CONST   NDiTachDeviceTCPPort               = @"4998";

// keys
MSKIT_STRING_CONST   NDiTachDevicePCBKey = @"pcb_pn";
MSKIT_STRING_CONST   NDiTachDevicePkgKey = @"pkg_level";
MSKIT_STRING_CONST   NDiTachDeviceSDKKey = @"sdkClass";

@implementation NDiTachDevice

@dynamic pcb_pn, pkg_level, sdkClass;

@end
