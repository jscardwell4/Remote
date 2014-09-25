//
// ComponentDevice.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "ComponentDevice.h"
#import "IRCode.h"
#import "NetworkDevice.h"
#import "Manufacturer.h"
#import "RemoteElementImportSupportFunctions.h"
#import "RemoteElementExportSupportFunctions.h"
#import "ComponentDeviceViewController.h"


@implementation ComponentDevice {
  BOOL _ignoreNextPowerCommand;
}

@dynamic port, codes, power, inputPowersOn, alwaysOn, offCommand, onCommand, manufacturer, networkDevice;

/// fetchDeviceWithName:
/// @param name
/// @return instancetype
+ (instancetype)fetchDeviceWithName:(NSString *)name {
  return [self findFirstByAttribute:@"name" withValue:name];
}

/// fetchDeviceWithName:context:
/// @param name
/// @param context
/// @return instancetype
+ (instancetype)fetchDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)context {
  return [self findFirstByAttribute:@"name" withValue:name context:context];
}

/// ignorePowerCommand:
/// @param handler
/// @return BOOL
- (BOOL)ignorePowerCommand:(void (^)(BOOL success, NSError *))handler {
  if (_ignoreNextPowerCommand) {
    _ignoreNextPowerCommand = NO;

    if (handler) handler(YES, nil);

    return YES;
  } else return NO;
}

/// powerOn:
/// @param completion
- (void)powerOn:(void (^)(BOOL success, NSError *))completion {
  __weak ComponentDevice * weakself = self;

  if (![self ignorePowerCommand:completion])
    [self.onCommand execute:^(BOOL success, NSError * error) {
      weakself.power = (!error && success ? YES : NO);

      if (completion) completion(success, error);
    }];
}

/// powerOff:
/// @param completion
- (void)powerOff:(void (^)(BOOL success, NSError *))completion {
  __weak ComponentDevice * weakself = self;

  if (![self ignorePowerCommand:completion])
    [self.offCommand execute:^(BOOL success, NSError * error) {
      weakself.power = (!error && success ? NO : YES);

      if (completion) completion(success, error);
    }];
}

/// objectForKeyedSubscript:
/// @param name
/// @return IRCode *
- (IRCode *)objectForKeyedSubscript:(NSString *)name {
  return [self.codes objectPassingTest:
          ^BOOL (IRCode * obj) { return [name isEqualToString:obj.name]; }];
}

/// JSONDictionary
/// @return MSDictionary *
- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];

  SetValueForKeyIfNotDefault(@(self.port),          @"port",          dictionary);
  SetValueForKeyIfNotDefault(@(self.alwaysOn),      @"alwaysOn",      dictionary);
  SetValueForKeyIfNotDefault(@(self.inputPowersOn), @"inputPowersOn", dictionary);

  SafeSetValueForKey(SelfKeyPathValue(@"onCommand.JSONDictionary"),    @"on-command",         dictionary);
  SafeSetValueForKey(SelfKeyPathValue(@"offCommand.JSONDictionary"),   @"off-command",        dictionary);
  SafeSetValueForKey(SelfKeyPathValue(@"manufacturer.commentedUUID"),  @"manufacturer.uuid",  dictionary);
  SafeSetValueForKey(SelfKeyPathValue(@"networkDevice.commentedUUID"), @"networkDevice.uuid", dictionary);
  SafeSetValueForKey(SelfKeyPathValue(@"codes.JSONDictionary"),        @"codes",              dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

/// deepDescriptionDictionary
/// @return MSDictionary *
- (MSDictionary *)deepDescriptionDictionary {
  ComponentDevice * device = [self faultedObject];

  assert(device);

  MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

  dd[@"name"] = device.name;
  dd[@"port"] = $(@"%i", device.port);

  return (MSDictionary *)dd;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Import/Export
////////////////////////////////////////////////////////////////////////////////


/// updateWithData:
/// @param data
- (void)updateWithData:(NSDictionary *)data {


  [super updateWithData:data];

  NSNumber               * port          = data[@"port"];
  NSDictionary           * onCommand     = data[@"on-command"];
  NSDictionary           * offCommand    = data[@"off-command"];
  NSDictionary           * manufacturer  = data[@"manufacturer"];
  NSDictionary           * networkDevice = data[@"network-device"];
  NSArray                * codes         = data[@"codes"];
  NSManagedObjectContext * moc           = self.managedObjectContext;


  if (port) self.port = port.shortValue;

  if (onCommand) self.onCommand = [Command importObjectFromData:onCommand context:moc];

  if (offCommand) self.onCommand = [Command importObjectFromData:offCommand context:moc];

  if (manufacturer) self.manufacturer = [Manufacturer importObjectFromData:manufacturer context:moc];

  if (codes) self.codes = [[IRCode importObjectsFromData:codes context:moc] set];

  if (networkDevice) self.networkDevice = [NetworkDevice importObjectFromData:networkDevice context:moc];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankableModel
////////////////////////////////////////////////////////////////////////////////

/// directoryLabel
/// @return NSString *
+ (NSString *)directoryLabel { return @"Component Devices"; }

/// directoryIcon
/// @return UIImage *
+ (UIImage *)directoryIcon { return [UIImage imageNamed:@"969-gray-television"]; }

/// isEditable
/// @return BOOL
- (BOOL)isEditable { return ([super isEditable] && self.user); }

/// isSectionable
/// @return BOOL
+ (BOOL)isSectionable { return NO;  }

/// detailViewController
/// @return ComponentDeviceViewController *
- (ComponentDeviceViewController *)detailViewController {
  return [ComponentDeviceViewController controllerWithItem:self];
}

/// editingViewController
/// @return ComponentDeviceViewController *
- (ComponentDeviceViewController *)editingViewController {
  return [ComponentDeviceViewController controllerWithItem:self editing:YES];
}

@end
