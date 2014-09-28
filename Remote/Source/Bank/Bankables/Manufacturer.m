//
// Manufacturer.m
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "Manufacturer.h"
#import "IRCode.h"
#import "ComponentDevice.h"
#import "Remote-Swift.h"

@implementation Manufacturer

@dynamic codes, devices;

/// manufacturerWithName:context:
/// @param name
/// @param context
/// @return instancetype
+ (instancetype)manufacturerWithName:(NSString *)name context:(NSManagedObjectContext *)context {
  assert(name && context);

  __block Manufacturer * manufacturer = nil;

  [context performBlockAndWait:
   ^{
    manufacturer = [self findFirstByAttribute:@"name"
                                    withValue:name
                                    context:context];

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


/// updateWithData:
/// @param data
- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

  NSArray                * codes   = data[@"codes"];
  NSArray                * devices = data[@"devices"];
  NSManagedObjectContext * moc     = self.managedObjectContext;

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
      if ([device isKindOfClass:[NSString class]] && [ModelObject isValidUUID:device]) {
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


/// JSONDictionary
/// @return MSDictionary *
- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];

  SafeSetValueForKey([self valueForKeyPath:@"codes.JSONDictionary"],  @"codes",   dictionary);
  SafeSetValueForKey([self valueForKeyPath:@"devices.commentedUUID"], @"devices", dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

/// codesets
/// @return NSSet *
- (NSSet *)codesets { return [self.codes valueForKeyPath:@"codeset"]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankableModel
////////////////////////////////////////////////////////////////////////////////

/// directoryLabel
/// @return NSString *
+ (NSString *)directoryLabel { return @"Manufacturers"; }

/// directoryIcon
/// @return UIImage *
//+ (UIImage *)directoryIcon { return [UIImage imageNamed:@"909-gray-tags"]; }
+ (UIImage *)directoryIcon { return [UIImage imageNamed:@"1022-gray-factory"]; }

/// detailViewController
/// @return ManufacturerViewController *
- (ManufacturerDetailController *)detailViewController {
  return [[ManufacturerDetailController alloc] initWithItem:self editing:NO];
}

/// editingViewController
/// @return ManufacturerViewController *
- (ManufacturerDetailController *)editingViewController {
  return [[ManufacturerDetailController alloc] initWithItem:self editing:YES];
}

/// isEditable
/// @return BOOL
- (BOOL)isEditable { return ([super isEditable] && self.user); }

@end
