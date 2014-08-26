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
#import "MSKit/NSManagedObject+MSKitAdditions.h"
#import "RemoteElementImportSupportFunctions.h"
#import "RemoteElementExportSupportFunctions.h"


@implementation ComponentDevice {
  BOOL _ignoreNextPowerCommand;
}

@dynamic port, codes, power, inputPowersOn, alwaysOn, offCommand, onCommand, manufacturer, networkDevice;

/*
 + (ComponentDevice *)importDeviceWithData:(NSDictionary *)data context:(NSManagedObjectContext *)moc
   {
    ComponentDevice * device = [self createInContext:moc];

    NSString     * name          = data[@"name"];
    NSNumber     * port          = data[@"port"];
    NSNumber     * inputPowersOn = data[@"inputPowersOn"];
    NSDictionary * onCommand     = data[@"onCommand"];
    NSDictionary * offCommand    = data[@"offCommand"];
    NSNumber     * alwaysOn      = data[@"alwaysOn"];
    NSArray      * codes         = data[@"codes"];

    if (name) device.info.name = name;
    if (port) device.port = [port intValue];
    if (inputPowersOn) device.inputPowersOn = [inputPowersOn boolValue];
    if (alwaysOn) device.alwaysOn = [alwaysOn boolValue];


    return device;
   }

 */

/*
 + (ComponentDevice *)importFromData:(NSDictionary *)objectData inContext:(NSManagedObjectContext *)context;
   {

    NSAttributeDescription * primaryAttribute = [[self MR_entityDescription]
                                                 MR_primaryAttributeToRelateBy];

    id value = [objectData MR_valueForAttribute:primaryAttribute];

    ComponentDevice * managedObject = [self findFirstByAttribute:[primaryAttribute name]
                                                          withValue:value
                                                          inContext:context];
    if (managedObject == nil)
    {
        managedObject = [self createInContext:context];
    }

    [managedObject MR_importValuesForKeysWithObject:objectData];


    return managedObject;
   }
 */

//- (void)awakeFromInsert {
//  [super awakeFromInsert];
//  self.user = @YES;
//}

+ (instancetype)fetchDeviceWithName:(NSString *)name {
  return [self findFirstByAttribute:@"info.name" withValue:name];
}

+ (instancetype)fetchDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)context {
  return [self findFirstByAttribute:@"info.name" withValue:name inContext:context];
}

- (BOOL)ignorePowerCommand:(CommandCompletionHandler)handler {
  if (_ignoreNextPowerCommand) {
    _ignoreNextPowerCommand = NO;

    if (handler) handler(YES, nil);

    return YES;
  } else return NO;
}

- (void)powerOn:(CommandCompletionHandler)completion {
  __weak ComponentDevice * weakself = self;

  if (![self ignorePowerCommand:completion])
    [self.onCommand execute:^(BOOL success, NSError * error) {
      weakself.power = (!error && success ? YES : NO);

      if (completion) completion(success, error);
    }];
}

- (void)powerOff:(CommandCompletionHandler)completion {
  __weak ComponentDevice * weakself = self;

  if (![self ignorePowerCommand:completion])
    [self.offCommand execute:^(BOOL success, NSError * error) {
      weakself.power = (!error && success ? NO : YES);

      if (completion) completion(success, error);
    }];
}

- (IRCode *)objectForKeyedSubscript:(NSString *)name {
  return [self.codes objectPassingTest:
          ^BOOL (IRCode * obj) { return [name isEqualToString:obj.name]; }];
}

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

- (MSDictionary *)deepDescriptionDictionary {
  ComponentDevice * device = [self faultedObject];

  assert(device);

  MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

  dd[@"name"] = device.name;
  dd[@"port"] = $(@"%i", device.port);

  return (MSDictionary *)dd;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////


- (void)updateWithData:(NSDictionary *)data {
  /*

     {
         "uuid": "DB69F934-E193-4C45-9598-1D5155B8E6E5",
         "info.name": "PS3",
         "port": 3,
         "on-command": {
             "class": "sendir",
             "code.uuid": "29F4A5B7-B9DD-4348-8C0F-EC36BC6CE1B3" // Discrete On
         },
         "off-command": {
             "class": "sendir",
             "code.uuid": "9326516F-1923-4461-AD31-E726B4AAAFB1" // Discrete Off
         },
         "manufacturer": "C4149194-D03B-43A7-84CB-DA80EE20FC70", // Sony
         "codes": []
     }

   */


  [super updateWithData:data];

  NSString               * name         = data[@"name"];
  NSNumber               * port         = data[@"port"];
  NSDictionary           * onCommand    = data[@"on-command"];
  NSDictionary           * offCommand   = data[@"off-command"];
  NSDictionary           * manufacturer = data[@"manufacturer"];
  NSArray                * codes        = data[@"codes"];
  NSManagedObjectContext * moc          = self.managedObjectContext;


  if (port)         self.port         = port.shortValue;
  if (onCommand)    self.onCommand    = [Command importObjectFromData:onCommand context:moc];
  if (offCommand)   self.onCommand    = [Command importObjectFromData:offCommand context:moc];
  if (manufacturer) self.manufacturer = [Manufacturer importObjectFromData:manufacturer context:moc];
  if (codes)        self.codes        = [[IRCode importObjectsFromData:codes context:moc] set];

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Bankable
////////////////////////////////////////////////////////////////////////////////

+ (NSString *)directoryLabel { return @"Component Devices"; }

+ (BankFlags)bankFlags { return (BankDetail | BankNoSections | BankEditable); }

- (BOOL)isEditable { return ([super isEditable] && self.user); }

@end
