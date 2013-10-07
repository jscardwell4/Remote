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

@implementation ComponentDevice {
    BOOL _ignoreNextPowerCommand;
}

@dynamic port, codes, power, inputPowersOn, alwaysOn, offCommand, onCommand, manufacturer, networkDevice;

/*
+ (id)MR_importFromObject:(id)objectData inContext:(NSManagedObjectContext *)context;
{
    NSAttributeDescription * primaryAttribute = [[self MR_entityDescription]
                                                 MR_primaryAttributeToRelateBy];

    id value = [objectData MR_valueForAttribute:primaryAttribute];

    NSManagedObject * managedObject = [self MR_findFirstByAttribute:[primaryAttribute name]
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

- (BOOL)ignorePowerCommand:(RECommandCompletionHandler)handler
{
    if (_ignoreNextPowerCommand)
    {
        _ignoreNextPowerCommand = NO;
        if (handler) handler(YES, nil);
        return YES;
    }

    else return NO;
}

- (void)powerOn:(RECommandCompletionHandler)completion
{
    __weak ComponentDevice * weakself = self;
    if (![self ignorePowerCommand:completion])
        [self.onCommand execute:^(BOOL success, NSError * error) {
            weakself.power = (!error && success ? YES : NO);
            if (completion) completion(success, error);
        }];
}

- (void)powerOff:(RECommandCompletionHandler)completion
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

- (MSDictionary *)deepDescriptionDictionary
{
    ComponentDevice * device = [self faultedObject];
    assert(device);

    MSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"name"] = device.name;
    dd[@"port"] = $(@"%i",device.port);
    return dd;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Bankable
////////////////////////////////////////////////////////////////////////////////

+ (NSString *)directoryLabel { return @"Component Devices"; }

+ (BankFlags)bankFlags { return (BankDetail|BankNoSections|BankEditable); }

- (BOOL)isEditable { return ([super isEditable] && self.user); }

@end
