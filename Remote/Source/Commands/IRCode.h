//
// IRCode.h
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BankObject.h"

@class   ComponentDevice, IRCodeSet;

@interface IRCode : BankObject

+ (IRCode *)newCodeForDevice:(ComponentDevice *)componentDevice;

// + (IRCode *)newCodeInCodeSet:(IRCodeSet *)set;

+ (IRCode *)newCodeFromProntoHex:(NSString *)hex forDevice:(ComponentDevice *)componentDevice;

// + (IRCode *)newCodeFromProntoHex:(NSString *)hex inCodeSet:(IRCodeSet *)set;

- (NSString *)globalCacheFromProntoHex;

@property (nonatomic, assign) int64_t    frequency;
@property (nonatomic, assign) int16_t    offset;
@property (nonatomic, assign) int16_t    repeatCount;
@property (nonatomic, strong) NSString * onOffPattern;
// @property (nonatomic, strong) NSString        * name;
@property (nonatomic, strong) NSString        * alternateName;
@property (nonatomic, strong) NSString        * prontoHex;
@property (nonatomic, strong) ComponentDevice * device;
// @property (nonatomic, strong) IRCodeSet       * codeSet;
@property (nonatomic, strong) NSSet * sendCommands;
@property (nonatomic, assign) BOOL    setsDeviceInput;
// @property (nonatomic, assign) BOOL              userCode;

@end
