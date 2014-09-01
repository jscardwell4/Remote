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
MSSTRING_CONST NDDeviceMakeKey     = @"make";
MSSTRING_CONST NDDeviceModelKey    = @"model";
MSSTRING_CONST NDDeviceRevisionKey = @"revision";
MSSTRING_CONST NDDeviceStatusKey   = @"status";
MSSTRING_CONST NDDeviceUUIDKey     = @"deviceUUID";
MSSTRING_CONST NDDeviceURLKey      = @"configURL";


static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@interface NetworkDevice ()

@property (nonatomic, copy, readwrite) NSString * deviceUUID;
@property (nonatomic, copy, readwrite) NSString * make;
@property (nonatomic, copy, readwrite) NSString * model;
@property (nonatomic, copy, readwrite) NSString * status;
@property (nonatomic, copy, readwrite) NSString * configURL;
@property (nonatomic, copy, readwrite) NSString * revision;

@end

@implementation NetworkDevice

@dynamic deviceUUID, make, model, status, configURL, revision, componentDevices;

+ (instancetype)device { return [self createInContext:[CoreDataManager defaultContext]]; }

+ (instancetype)deviceInContext:(NSManagedObjectContext *)context {
  return [self createInContext:context];
}

+ (instancetype)deviceWithAttributes:(NSDictionary *)attributes {
  return [self deviceWithAttributes:attributes
                            context:[CoreDataManager defaultContext]];
}

+ (instancetype)deviceWithAttributes:(NSDictionary *)attributes
                             context:(NSManagedObjectContext *)context {
  NSString * deviceUUID = attributes[NDDeviceUUIDKey];

  if ([self deviceExistsWithDeviceUUID:deviceUUID])
    return [self findFirstByAttribute:@"deviceUUID" withValue:deviceUUID inContext:context];

  else {
    NetworkDevice * device = [self deviceInContext:context];
    [device setValuesForKeysWithDictionary:attributes];
    return device;
  }
}

+ (BOOL)deviceExistsWithDeviceUUID:(NSString *)deviceUUID {

  return (  StringIsNotEmpty(deviceUUID)
         && [self countOfObjectsWithPredicate:NSPredicateMake(@"deviceUUID == %@", deviceUUID)] == 1);
}

@end

// constants
MSSTRING_CONST NDiTachDeviceMulticastGroupAddress = @"239.255.250.250";
MSSTRING_CONST NDiTachDeviceMulticastGroupPort    = @"9131";
MSSTRING_CONST NDiTachDeviceTCPPort               = @"4998";

// keys
MSSTRING_CONST NDiTachDevicePCBKey = @"pcb_pn";
MSSTRING_CONST NDiTachDevicePkgKey = @"pkg_level";
MSSTRING_CONST NDiTachDeviceSDKKey = @"sdkClass";

@implementation NDiTachDevice

@dynamic pcb_pn, pkg_level, sdkClass;

@end
