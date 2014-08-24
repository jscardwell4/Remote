//
// Manufacturer.m
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "Manufacturer.h"
#import "BankGroup.h"
#import "IRCode.h"
#import "ComponentDevice.h"

@implementation Manufacturer

@dynamic codes, devices;


+ (instancetype)manufacturerWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    assert(name && context);

    __block Manufacturer * manufacturer = nil;

    [context performBlockAndWait:
     ^{
         manufacturer = [self findFirstByAttribute:@"info.name"
                                            withValue:name
                                            inContext:context];
         if (!manufacturer)
         {
             manufacturer = [self createInContext:context];
             manufacturer.info.name = name;
         }
     }];

    return manufacturer;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////


- (void)updateWithData:(NSDictionary *)data {
    /*
     {
         "uuid": "D3D49520-818A-4E4A-9AD4-FDBC99BE99AC",
         "info.name": "LG",
         "codes": [
             {
                 "uuid": "5AE3E47B-3743-4DF7-82C4-2E377529E13C",
                 "info": {
                     "name": "1",
                     "category": "(LG) 0768"
                 },
                 "codeset": "0768",
                 "frequency": 39105,
                 "onOffPattern": "344,176,22,3691,"
             },
         "devices": [
             "CC67B0D5-13E8-4548-BDBF-7B81CAA85A9F" // Samsung TV
             ]
     }
     */

    [super updateWithData:data];

    NSString               * name     = data[@"info"][@"name"];
    NSString               * category = data[@"info"][@"category"];
    NSArray                * codes    = data[@"codes"];
    NSArray                * devices  = data[@"devices"];
    NSManagedObjectContext * moc      = self.managedObjectContext;

    if (name) self.info.name = name;
    if (category) self.info.category = category;
    if (codes) {
        NSMutableSet * manufacturerCodes = [NSMutableSet set];
        for (NSDictionary * code in codes) {
            IRCode * manufacturerCode = [IRCode importObjectFromData:code inContext:moc];
            if (manufacturerCode) [manufacturerCodes addObject:manufacturerCode];
        }
        self.codes = manufacturerCodes;
    }
    if (devices) {
        NSMutableSet * manufacturerDevices = [NSMutableSet set];
        for (id device in devices) {
            if ([device isKindOfClass:[NSString class]] && UUIDIsValid(device)) {
                ComponentDevice * d = [ComponentDevice existingObjectWithUUID:device context:moc];
                if (!d) d = [ComponentDevice objectWithUUID:device context:moc];
                [manufacturerDevices addObject:d];
            } else if ([device isKindOfClass:[NSDictionary class]]) {
                ComponentDevice * d = [ComponentDevice importObjectFromData:device inContext:moc];
                if (d) [manufacturerDevices addObject:d];
            }
        }
        if ([manufacturerDevices count] > 0) self.devices = manufacturerDevices;
    }

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////


- (MSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];

    dictionary[@"codes"] = CollectionSafeSelfKeyPathValue(@"codes.JSONDictionary");
    dictionary[@"devices"] = CollectionSafeSelfKeyPathValue(@"devices.uuid");

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}


- (NSSet *)codesets { return [self.codes valueForKeyPath:@"codeset"]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Bankable
////////////////////////////////////////////////////////////////////////////////

+ (NSString *)directoryLabel { return @"Manufacturers"; }

+ (BankFlags)bankFlags { return (BankDetail|BankNoSections|BankEditable); }

- (BOOL)isEditable { return ([super isEditable] && self.user); }

@end
