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

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    if (ModelObjectShouldInitialize) self.user = YES;
}

+ (instancetype)fetchDeviceWithName:(NSString *)name
{
    return [self findFirstByAttribute:@"info.name" withValue:name];
}

+ (instancetype)fetchDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    return [self findFirstByAttribute:@"info.name" withValue:name inContext:context];
}

- (BOOL)ignorePowerCommand:(CommandCompletionHandler)handler
{
    if (_ignoreNextPowerCommand)
    {
        _ignoreNextPowerCommand = NO;
        if (handler) handler(YES, nil);
        return YES;
    }

    else return NO;
}

- (void)powerOn:(CommandCompletionHandler)completion
{
    __weak ComponentDevice * weakself = self;
    if (![self ignorePowerCommand:completion])
        [self.onCommand execute:^(BOOL success, NSError * error) {
            weakself.power = (!error && success ? YES : NO);
            if (completion) completion(success, error);
        }];
}

- (void)powerOff:(CommandCompletionHandler)completion
{
    __weak ComponentDevice * weakself = self;
    if (![self ignorePowerCommand:completion])
        [self.offCommand execute:^(BOOL success, NSError * error) {
            weakself.power = (!error && success ? NO : YES);
            if (completion) completion(success, error);
        }];
}

- (IRCode *)objectForKeyedSubscript:(NSString *)name
{
    return [self.codes objectPassingTest:
            ^BOOL(IRCode * obj){ return [name isEqualToString:obj.name]; }];
}

- (MSDictionary *)JSONDictionary
{
    id(^defaultForKey)(NSString *) = ^(NSString * key)
    {
        static const NSDictionary * index;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken,
                      ^{
                          MSDictionary * dictionary = [MSDictionary dictionary];
                          for (NSString * attribute in @[@"port", @"alwaysOn", @"inputPowersOn"])
                              dictionary[attribute] = CollectionSafe([self defaultValueForAttribute:attribute]);
                          [dictionary compact];
                          index = dictionary;
                      });

        return index[key];
    };

    void(^addIfCustom)(id, MSDictionary*, NSString*, id) =
    ^(id object, MSDictionary *dictionary, NSString *attribute, id addition )
    {
        BOOL isCustom = YES;

        id defaultValue = defaultForKey(attribute);
        id setValue = [object valueForKey:attribute];

        if (defaultValue && setValue)
        {
            if ([setValue isKindOfClass:[NSNumber class]])
                isCustom = ![defaultValue isEqualToNumber:setValue];
            
            else if ([setValue isKindOfClass:[NSString class]])
                isCustom = ![defaultValue isEqualToString:setValue];
            
            else
                isCustom = ![defaultValue isEqual:setValue];
        }

        if (isCustom)
            dictionary[attribute] = CollectionSafe(addition);
    };

    MSDictionary * dictionary = [super JSONDictionary];

    addIfCustom(self, dictionary, @"port",          @(self.port));
    addIfCustom(self, dictionary, @"alwaysOn",      @(self.alwaysOn));
    addIfCustom(self, dictionary, @"inputPowersOn", @(self.inputPowersOn));
    addIfCustom(self, dictionary, @"onCommand",     SelfKeyPathValue(@"onCommand.JSONDictionary"));
    addIfCustom(self, dictionary, @"offCommand",    SelfKeyPathValue(@"offCommand.JSONDictionary"));
    addIfCustom(self, dictionary, @"manufacturer",  SelfKeyPathValue(@"manufacturer.commentedUUID"));
    addIfCustom(self, dictionary, @"networkDevice", SelfKeyPathValue(@"networkDevice.commentedUUID"));
    addIfCustom(self, dictionary, @"codes",         SelfKeyPathValue(@"codes.JSONDictionary"));

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}

- (MSDictionary *)deepDescriptionDictionary
{
    ComponentDevice * device = [self faultedObject];
    assert(device);

    MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"name"] = device.name;
    dd[@"port"] = $(@"%i",device.port);
    return (MSDictionary *)dd;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////


+ (instancetype)importObjectFromData:(NSDictionary *)data inContext:(NSManagedObjectContext *)moc {
    /*
     
     {
         "uuid": "DB69F934-E193-4C45-9598-1D5155B8E6E5",
         "info.name": "PS3",
         "port": 3,
         "onCommand": {
             "class": "sendir",
             "code.uuid": "29F4A5B7-B9DD-4348-8C0F-EC36BC6CE1B3" // Discrete On
         },
         "offCommand": {
             "class": "sendir",
             "code.uuid": "9326516F-1923-4461-AD31-E726B4AAAFB1" // Discrete Off
         },
         "manufacturer": "C4149194-D03B-43A7-84CB-DA80EE20FC70", // Sony
         "codes": []
     }

     */

    ComponentDevice * componentDevice = [super importObjectFromData:data inContext:moc];

    if (!componentDevice) {

        componentDevice = [ComponentDevice objectWithUUID:data[@"uuid"] context:moc];

        NSString * name          = data[@"info"][@"name"];
        NSNumber * port          = data[@"port"];
        id         onCommand     = data[@"onCommand"];
        id         offCommand    = data[@"offCommand"];
        id         manufacturer  = data[@"manufacturer"];
        NSArray  * codes         = data[@"codes"];


        if (name) componentDevice.info.name = name;
        if (port) componentDevice.port = port.shortValue;
        if (onCommand) {
            if ([onCommand isKindOfClass:[NSString class]] && UUIDIsValid(onCommand)) {
                //TODO: Fill out stub
            } else if ([onCommand isKindOfClass:[NSDictionary class]]) {
                componentDevice.onCommand = [Command importObjectFromData:onCommand inContext:moc];
            }
        }
        if (offCommand) {
            if ([offCommand isKindOfClass:[NSString class]] && UUIDIsValid(offCommand)) {
                //TODO: Fill out stub
            } else if ([offCommand isKindOfClass:[NSDictionary class]]) {
                componentDevice.onCommand = [Command importObjectFromData:offCommand inContext:moc];
            }
        }
        if (manufacturer) {
            if ([manufacturer isKindOfClass:[NSString class]] && UUIDIsValid(manufacturer)) {
                Manufacturer * m = [Manufacturer existingObjectWithUUID:manufacturer context:moc];
                if (!m) m = [Manufacturer objectWithUUID:manufacturer context:moc];
                componentDevice.manufacturer = m;
            } else if ([manufacturer isKindOfClass:[NSDictionary class]]) {
                componentDevice.manufacturer = [Manufacturer importObjectFromData:manufacturer inContext:moc];
            }
        }
        if (codes) {
            NSMutableSet * componentDeviceCodes = [NSMutableSet set];
            for (NSDictionary * code in codes) {
                IRCode * componentDeviceCode = [IRCode importObjectFromData:code inContext:moc];
                if (componentDeviceCode) [componentDeviceCodes addObject:componentDeviceCode];
            }
            componentDevice.codes = componentDeviceCodes;
        }
    }

    return componentDevice;

}

/*
- (BOOL)shouldImportCodes:(id)data { return YES; }
- (BOOL)shouldImportConfigurations:(id)data { return YES; }
- (BOOL)shouldImportInfo:(id)data { return YES; }
- (BOOL)shouldImportManufacturer:(id)data { return YES; }
- (BOOL)shouldImportNetworkDevice:(id)data { return YES; }
- (BOOL)shouldImportOffCommand:(id)data { return YES; }
- (BOOL)shouldImportOnCommand:(id)data { return YES; }
- (BOOL)shouldImportPowerCommands:(id)data { return YES; }
*/

MSSTATIC_STRING_CONST kOnCommandKey = @"onCommand";
MSSTATIC_STRING_CONST kOffCommandKey = @"offCommand";

/*
- (void)importCommandForKey:(NSString *)key data:(NSDictionary *)data
{
    if (![@[kOnCommandKey, kOffCommandKey] containsObject:key]) return;

    NSString * classKey = data[@"class"];
    Class commandClass = commandClassForImportKey(classKey);

    if (!commandClass) return;

    Command * command = [commandClass importFromData:data
                                                inContext:self.managedObjectContext];

    if (command) [self setValue:command forKey:key];
}

- (void)importOnCommand:(id)data
{
    if (isDictionaryKind(data) && [data hasKey:kOnCommandKey])
    {
        NSDictionary * commandData = data[kOnCommandKey];
        if (isDictionaryKind(commandData)) [self importCommandForKey:kOnCommandKey data:commandData];
    }
}

- (void)importOffCommand:(id)data
{
    if (isDictionaryKind(data) && [data hasKey:kOffCommandKey])
    {
        NSDictionary * commandData = data[kOffCommandKey];
        if (isDictionaryKind(commandData)) [self importCommandForKey:kOffCommandKey data:commandData];
    }
}
*/

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Bankable
////////////////////////////////////////////////////////////////////////////////

+ (NSString *)directoryLabel { return @"Component Devices"; }

+ (BankFlags)bankFlags { return (BankDetail|BankNoSections|BankEditable); }

- (BOOL)isEditable { return ([super isEditable] && self.user); }

@end
