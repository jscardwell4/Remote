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
MSKIT_STRING_CONST   NDDeviceUUIDKey     = @"uuid";
MSKIT_STRING_CONST   NDDeviceURLKey      = @"configURL";


static const int   ddLogLevel = LOG_LEVEL_DEBUG;

@interface NetworkDevice ()

@property (nonatomic, copy, readwrite) NSString * uuid;

@end

@implementation NetworkDevice

@dynamic uuid, make, model, status, configURL, revision;;

+ (instancetype)deviceInContext:(NSManagedObjectContext *)context
{
    assert(context);
    __block NetworkDevice * device = nil;
    [context performBlockAndWait:^{ device = NSManagedObjectFromClass(context); }];
    return device;
}

+ (instancetype)deviceWithAttributes:(NSDictionary *)attributes
                             context:(NSManagedObjectContext *)context
{
    assert(attributes && context);
    NSString * uuid = attributes[NDDeviceUUIDKey];

    if (uuid && [self deviceExistsWithUUID:uuid])
        return [self fetchDeviceWithUUID:uuid context:context];

    __block NetworkDevice * device = nil;
    [context performBlockAndWait:
     ^{
         device = [self deviceInContext:context];
         [device setValuesForKeysWithDictionary:attributes];
         if (!device.uuid) device.uuid = MSNonce();
     }];
    return device;
}

+ (BOOL)deviceExistsWithUUID:(NSString *)uuid
{
    if (!uuid) return NO;

    NSFetchRequest * fetchRequest =
        [NSFetchRequest fetchRequestWithEntityName:ClassString(self)
                                         predicate:[NSPredicate
                                                    predicateWithFormat:@"uuid == %@", uuid]];
    fetchRequest.resultType = NSCountResultType;

    __block NSUInteger       count   = 0;
    NSManagedObjectContext * context = [[CoreDataManager sharedManager] mainObjectContext];
    [context performBlockAndWait:
     ^{
         NSError * error = nil;
         count = [context countForFetchRequest:fetchRequest error:&error];
     }];

    return (count == 1);
}

+ (NetworkDevice *)fetchDeviceWithUUID:(NSString *)uuid context:(NSManagedObjectContext *)context
{
    assert(uuid && context);
    __block NetworkDevice * device;
    [context performBlockAndWait:
     ^{
         NSFetchRequest * fetchRequest =
             [NSFetchRequest fetchRequestWithEntityName:ClassString(self)
                                              predicate:[NSPredicate
                                                         predicateWithFormat:@"uuid == %@", uuid]];

         NSError * error = nil;
         NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
         device = [fetchedObjects lastObject];
     }];
    return device;
}

+ (NSArray *)fetchAllInContext:(NSManagedObjectContext *)context
{
    assert(context);
    __block NSArray * fetchedObjects = nil;
    [context performBlockAndWait:
     ^{
         fetchedObjects = [context executeFetchRequest:NSFetchRequestFromClass error:nil];
     }];
    return fetchedObjects;
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
