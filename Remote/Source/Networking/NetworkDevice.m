//
// NetworkDevice.m
// Remote
//
// Created by Jason Cardwell on 9/25/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "NetworkDevice.h"
#import "CoreDataManager.h"

static const int   ddLogLevel = LOG_LEVEL_DEBUG;

@implementation NetworkDevice

@dynamic uuid;

+ (NetworkDevice *)networkDeviceInContext:(NSManagedObjectContext *)context {
    if (!context) return nil;

    return [NSEntityDescription insertNewObjectForEntityForName:ClassString([self class]) inManagedObjectContext:context];
}

+ (BOOL)networkDeviceExistsForUUID:(NSString *)uuid {
    if (!uuid) return NO;

    __block NSUInteger       count   = 0;
    NSManagedObjectContext * context = [DataManager newContext];
// [context performBlockAndWait:^{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ClassString([self class])];
    NSPredicate    * predicate    = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];

    [fetchRequest setPredicate:predicate];

    NSError * error = nil;

    count = [context countForFetchRequest:fetchRequest error:&error];
// }];

    return (count > 0);
}

+ (NetworkDevice *)networkDeviceForUUID:(NSString *)uuid
                                context:(NSManagedObjectContext *)context {
    if (!context || !uuid) return nil;

    __block NSArray * fetchedObjects = nil;

    [context performBlockAndWait:^{
                 NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
                 NSEntityDescription * entity = [NSEntityDescription entityForName:ClassString([self class])
                                                   inManagedObjectContext:context];
                 [fetchRequest setEntity:entity];

                 NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];
                 [fetchRequest setPredicate:predicate];

                 NSError * error = nil;
                 fetchedObjects = [context          executeFetchRequest:fetchRequest
                                                         error:&error];
                 if (fetchedObjects == nil) DDLogWarn(@"%@ failed to retrieve device from database with uuid '%@'", ClassTagSelectorString, uuid);
             }

    ];

    return (fetchedObjects.count ? fetchedObjects[0] : nil);
}

@end

// iTach device keys
MSKIT_STRING_CONST   kiTachDeviceMake                  = @"Make";
MSKIT_STRING_CONST   kiTachDeviceModel                 = @"Model";
MSKIT_STRING_CONST   kiTachDevicePCB                   = @"PCB_PN";
MSKIT_STRING_CONST   kiTachDevicePkg                   = @"Pkg_Level";
MSKIT_STRING_CONST   kiTachDeviceRev                   = @"Revision";
MSKIT_STRING_CONST   kiTachDeviceSDK                   = @"SDKClass";
MSKIT_STRING_CONST   kiTachDeviceStatus                = @"Status";
MSKIT_STRING_CONST   kiTachDeviceUUID                  = @"UUID";
MSKIT_STRING_CONST   kiTachDeviceURL                   = @"Config-URL";
MSKIT_STRING_CONST   kiTachDeviceMulticastGroupAddress = @"239.255.250.250";
MSKIT_STRING_CONST   kiTachDeviceMulticastGroupPort    = @"9131";
MSKIT_STRING_CONST   kiTachDeviceTCPPort               = @"4998";

@implementation ITachDevice

@dynamic make;
@dynamic model;
@dynamic pcb_pn;
@dynamic pkg_level;
@dynamic sdkClass;
@dynamic status;
@dynamic configURL;
@dynamic revision;

+ (ITachDevice *)iTachDeviceWithAttributes:(NSDictionary *)attributes context:(NSManagedObjectContext *)context {
    NSString * uuid = attributes[kiTachDeviceUUID];

    assert(uuid);

    if ([super networkDeviceExistsForUUID:uuid]) return [self iTachDeviceForUUID:uuid context:context];

    ITachDevice * device = (ITachDevice *)[super networkDeviceInContext:context];

    if (device && attributes) {
        device.make      = attributes[kiTachDeviceMake];
        device.model     = attributes[kiTachDeviceModel];
        device.pcb_pn    = attributes[kiTachDevicePCB];
        device.pkg_level = attributes[kiTachDevicePkg];
        device.revision  = attributes[kiTachDeviceRev];
        device.sdkClass  = attributes[kiTachDeviceSDK];
        device.uuid      = attributes[kiTachDeviceUUID];
        device.configURL = attributes[kiTachDeviceURL];
    }

    return device;
}

+ (ITachDevice *)iTachDeviceForUUID:(NSString *)uuid context:(NSManagedObjectContext *)context {
    return (ITachDevice *)[super networkDeviceForUUID:uuid context:context];
}

+ (NSArray *)allDevicesInContext:(NSManagedObjectContext *)context {
    __block NSArray * fetchedObjects = nil;

    [context performBlockAndWait:^{
                 NSFetchRequest * req = [[DataManager objectModel] fetchRequestTemplateForName:@"AlliTachDevices"];
                 NSError * error = nil;
                 fetchedObjects = [[DataManager mainObjectContext]          executeFetchRequest:req
                                                                                 error:&error];
                 if (fetchedObjects == nil) DDLogWarn(@"%@ failed to retrieve devices from database", ClassTagSelectorString);
             }

    ];

    return fetchedObjects;
}

@end
