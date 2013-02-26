//
// ComponentDevice.h
// iPhonto
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "CommandDelegate.h"
#import "BankObject.h"

typedef NS_ENUM (BOOL, ComponentDevicePowerState) {
    ComponentDevicePowerOff = NO,
    ComponentDevicePowerOn  = YES
};

@class   IRCode, Command;

@interface ComponentDevice : BankObject <CommandDelegate>

+ (ComponentDevice *)fetchComponentDeviceWithName:(NSString *)componentDeviceName
                                        inContext:(NSManagedObjectContext *)context;

- (IRCode *)codeWithName:(NSString *)codeName;

- (void)setPowerStateToState:(ComponentDevicePowerState)powerState
                      sender:(id <CommandDelegate> )sender;

@property (nonatomic, strong) NSString * name;
@property (nonatomic, assign) int16_t    port;
@property (nonatomic, strong) NSSet    * codes;
@property (nonatomic, assign) int16_t    power;
@property (nonatomic, assign) BOOL       alwaysOn;
@property (nonatomic, assign) BOOL       inputPowersOn;
@property (nonatomic, assign) BOOL       ignoreNextPowerCommand;
@property (nonatomic, strong) Command  * offCommand;
@property (nonatomic, strong) Command  * onCommand;

@end
