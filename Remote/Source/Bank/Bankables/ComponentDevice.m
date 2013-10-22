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

@implementation ComponentDevice {
    BOOL _ignoreNextPowerCommand;
}

@dynamic port, codes, power, inputPowersOn, alwaysOn, offCommand, onCommand, manufacturer, networkDevice;

/*
+ (ComponentDevice *)importDeviceWithData:(NSDictionary *)data context:(NSManagedObjectContext *)moc
{
    ComponentDevice * device = [self MR_createInContext:moc];

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
+ (ComponentDevice *)MR_importFromObject:(id)objectData inContext:(NSManagedObjectContext *)context;
{

    NSAttributeDescription * primaryAttribute = [[self MR_entityDescription]
                                                 MR_primaryAttributeToRelateBy];

    id value = [objectData MR_valueForAttribute:primaryAttribute];

    ComponentDevice * managedObject = [self MR_findFirstByAttribute:[primaryAttribute name]
                                                          withValue:value
                                                          inContext:context];
    if (managedObject == nil)
    {
        managedObject = [self MR_createInContext:context];
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
    return [self MR_findFirstByAttribute:@"info.name" withValue:name];
}

+ (instancetype)fetchDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    return [self MR_findFirstByAttribute:@"info.name" withValue:name inContext:context];
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

- (NSDictionary *)JSONDictionary
{
    id(^defaultForKey)(NSString *) = ^(NSString * key)
    {
        static const NSDictionary * index;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken,
                      ^{
                          MSDictionary * dictionary = [MSDictionary dictionary];
                          for (NSString * attribute in @[@"port", @"alwaysOn", @"inputPowersOn"])
                              dictionary[attribute] = CollectionSafeValue([self defaultValueForAttribute:attribute]);
                          [dictionary removeKeysWithNullObjectValues];
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
            dictionary[attribute] = CollectionSafeValue(addition);
    };

    MSDictionary * dictionary = [[super JSONDictionary] mutableCopy];

    addIfCustom(self, dictionary, @"port",          @(self.port));
    addIfCustom(self, dictionary, @"alwaysOn",      @(self.alwaysOn));
    addIfCustom(self, dictionary, @"inputPowersOn", @(self.inputPowersOn));
    addIfCustom(self, dictionary, @"onCommand",     SelfKeyPathValue(@"onCommand.JSONDictionary"));
    addIfCustom(self, dictionary, @"offCommand",    SelfKeyPathValue(@"offCommand.JSONDictionary"));
    addIfCustom(self, dictionary, @"manufacturer",  SelfKeyPathValue(@"manufacturer.uuid"));
    addIfCustom(self, dictionary, @"networkDevice", SelfKeyPathValue(@"networkDevice.uuid"));
    addIfCustom(self, dictionary, @"codes",         SelfKeyPathValue(@"codes.JSONDictionary"));

    [dictionary removeKeysWithNullObjectValues];

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
#pragma mark - Bankable
////////////////////////////////////////////////////////////////////////////////

+ (NSString *)directoryLabel { return @"Component Devices"; }

+ (BankFlags)bankFlags { return (BankDetail|BankNoSections|BankEditable); }

- (BOOL)isEditable { return ([super isEditable] && self.user); }

@end
