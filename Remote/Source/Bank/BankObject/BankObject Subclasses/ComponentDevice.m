//
// ComponentDevice.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "ComponentDevice.h"
#import "IRCode.h"
#import "Command.h"

@implementation ComponentDevice {
    BOOL _ignoreNextPowerCommand;
    BOPowerState _power;
    BODevicePort _port;
}

@dynamic name, port, codes, power, inputPowersOn, alwaysOn, offCommand, onCommand;

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

+ (BOOL)isEditable { return NO; }

+ (BOOL)isPreviewable { return NO;}

+ (NSString *)directoryLabel { return @"Component Device"; }

+ (NSOrderedSet *)directoryItems { return nil; }

- (UIImage *)thumbnail { return nil; }

- (UIImage *)preview { return nil; }

- (NSString *)category { return nil; }

- (UIViewController *)editingViewController { return nil; }

- (NSOrderedSet *)subBankables { return nil; }

+ (instancetype)fetchDeviceWithName:(NSString *)name
{
    return [self MR_findFirstByAttribute:@"name" withValue:name];
}

+ (instancetype)fetchDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    return [self MR_findFirstByAttribute:@"name" withValue:name inContext:context];
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
            weakself.power = (!error && success ? BOPowerStateOn : BOPowerStateOff);
            if (completion) completion(success, error);
        }];
}

- (void)powerOff:(RECommandCompletionHandler)completion
{
    __weak ComponentDevice * weakself = self;
    if (![self ignorePowerCommand:completion])
        [self.offCommand execute:^(BOOL success, NSError * error) {
            weakself.power = (!error && success ? BOPowerStateOff : BOPowerStateOn);
            if (completion) completion(success, error);
        }];
}

- (void)setPower:(BOPowerState)power
{
    [self willChangeValueForKey:@"power"];
    _power = power;
    [self didChangeValueForKey:@"power"];
}

- (BOPowerState)power
{
    [self willAccessValueForKey:@"power"];
    BOPowerState power = _power;
    [self didAccessValueForKey:@"power"];
    return power;
}

- (void)setPort:(BODevicePort)port
{
    [self willChangeValueForKey:@"port"];
    _port = port;
    [self didChangeValueForKey:@"port"];
}

- (BODevicePort)port
{
    [self willAccessValueForKey:@"port"];
    BODevicePort port = _port;
    [self didAccessValueForKey:@"port"];
    return port;
}

- (IRCode *)objectForKeyedSubscript:(NSString *)name
{
    return [self.codes objectPassingTest:^BOOL(IRCode * obj){return [name isEqualToString:obj.name];}];
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

@end
