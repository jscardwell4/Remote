//
// BOComponentDevice.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "BankObject.h"
#import "RECommand.h"

@implementation BOComponentDevice {
    BOOL _ignoreNextPowerCommand;
    BOPowerState _power;
    BODevicePort _port;
}

@dynamic name, port, codes, power, inputPowersOn, alwaysOn, offCommand, onCommand;

+ (instancetype)fetchDeviceWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    __block BOComponentDevice * device = nil;
    [context performBlockAndWait:
     ^{
         NSFetchRequest * fetchRequest = NSFetchRequestFromClassWithPredicate(@"name == %@", name);
         NSError * error = nil;
         NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
         if (fetchedObjects) device = [fetchedObjects lastObject];
     }];

    return device;
}

- (BOOL)ignorePowerCommand:(RECommandCompletionHandler)handler
{
    if (_ignoreNextPowerCommand)
    {
        _ignoreNextPowerCommand = NO;
        if (handler) handler(YES, YES);
        return YES;
    }

    else return NO;
}

- (void)powerOn:(RECommandCompletionHandler)completion
{
    __weak BOComponentDevice * weakself = self;
    if (![self ignorePowerCommand:completion])
        [self.onCommand execute:^(BOOL finished, BOOL success) {
            weakself.power = (finished && success ? BOPowerStateOn : BOPowerStateOff);
            if (completion) completion(finished, success);
        }];
}

- (void)powerOff:(RECommandCompletionHandler)completion
{
    __weak BOComponentDevice * weakself = self;
    if (![self ignorePowerCommand:completion])
        [self.offCommand execute:^(BOOL finished, BOOL success) {
            weakself.power = (finished && success ? BOPowerStateOff : BOPowerStateOn);
            if (completion) completion(finished, success);
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

- (BOIRCode *)objectForKeyedSubscript:(NSString *)name
{
    return [self.codes objectPassingTest:^BOOL(BOIRCode * obj){return [name isEqualToString:obj.name];}];
}

@end
