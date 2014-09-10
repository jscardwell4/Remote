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
#import "ManufacturerDetailViewController.h"

@implementation Manufacturer

@dynamic codes, devices;

/// detailViewController
/// @return ManufacturerDetailViewController *
- (ManufacturerDetailViewController *)detailViewController {
  return [ManufacturerDetailViewController controllerWithItem:self];
}

/// editingViewController
/// @return ManufacturerDetailViewController *
- (ManufacturerDetailViewController *)editingViewController {
  return [ManufacturerDetailViewController controllerWithItem:self editing:YES];
}


+ (instancetype)manufacturerWithName:(NSString *)name context:(NSManagedObjectContext *)context {
  assert(name && context);

  __block Manufacturer * manufacturer = nil;

  [context performBlockAndWait:
   ^{
    manufacturer = [self findFirstByAttribute:@"name"
                                    withValue:name
                                    inContext:context];

    if (!manufacturer) {
      manufacturer = [self createInContext:context];
      manufacturer.name = name;
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
       "name": "LG",
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

  NSArray                * codes    = data[@"codes"];
  NSArray                * devices  = data[@"devices"];
  NSManagedObjectContext * moc      = self.managedObjectContext;

  if (codes) {
    NSMutableSet * manufacturerCodes = [NSMutableSet set];

    for (NSDictionary * code in codes) {
      IRCode * manufacturerCode = [IRCode importObjectFromData:code context:moc];

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
        ComponentDevice * d = [ComponentDevice importObjectFromData:device context:moc];

        if (d) [manufacturerDevices addObject:d];
      }
    }

    if ([manufacturerDevices count] > 0) self.devices = manufacturerDevices;
  }

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////


- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];

  SafeSetValueForKey([self valueForKeyPath:@"codes.JSONDictionary"], @"codes", dictionary);
  SafeSetValueForKey([self valueForKeyPath:@"devices.commentedUUID"], @"devices", dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

- (NSSet *)codesets { return [self.codes valueForKeyPath:@"codeset"]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Bankable
////////////////////////////////////////////////////////////////////////////////

+ (NSString *)directoryLabel { return @"Manufacturers"; }

+ (BankFlags)bankFlags { return (BankDetail | BankNoSections | BankEditable); }

- (BOOL)isEditable { return ([super isEditable] && self.user); }

@end
