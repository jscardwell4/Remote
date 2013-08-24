//
// BOComponentDevice.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BankObject.h"

@class BOIRCode, RECommand;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Component Device
////////////////////////////////////////////////////////////////////////////////

@interface BOComponentDevice : BankObject

+ (instancetype)fetchDeviceWithName:(NSString *)deviceName;
+ (instancetype)fetchDeviceWithName:(NSString *)deviceName context:(NSManagedObjectContext *)context;

- (BOIRCode *)objectForKeyedSubscript:(NSString *)name;

- (void)powerOn:(RECommandCompletionHandler)completion;

- (void)powerOff:(RECommandCompletionHandler)completion;

@property (nonatomic, strong) NSString     * name;
@property (nonatomic, assign) BODevicePort   port;
@property (nonatomic, strong) NSSet        * codes;
@property (nonatomic, assign) BOPowerState   power;
@property (nonatomic, assign) BOOL           alwaysOn;
@property (nonatomic, assign) BOOL           inputPowersOn;
@property (nonatomic, strong) RECommand    * offCommand;
@property (nonatomic, strong) RECommand    * onCommand;

@end

