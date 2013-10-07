//
// ComponentDevice.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BankableModelObject.h"
#import "Command.h"

@class IRCode, Command, Manufacturer, NetworkDevice;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Component Device
////////////////////////////////////////////////////////////////////////////////

@interface ComponentDevice : BankableModelObject

+ (instancetype)fetchDeviceWithName:(NSString *)deviceName;
+ (instancetype)fetchDeviceWithName:(NSString *)deviceName context:(NSManagedObjectContext *)context;

- (IRCode *)objectForKeyedSubscript:(NSString *)name;

- (void)powerOn:(RECommandCompletionHandler)completion;

- (void)powerOff:(RECommandCompletionHandler)completion;

@property (nonatomic, assign) int16_t         port;
@property (nonatomic, strong) NSSet         * codes;
@property (nonatomic, assign) BOOL            power;
@property (nonatomic, assign) BOOL            alwaysOn;
@property (nonatomic, assign) BOOL            inputPowersOn;
@property (nonatomic, strong) Command       * offCommand;
@property (nonatomic, strong) Command       * onCommand;
@property (nonatomic, strong) Manufacturer  * manufacturer;
@property (nonatomic, strong) NetworkDevice * networkDevice;

@end

