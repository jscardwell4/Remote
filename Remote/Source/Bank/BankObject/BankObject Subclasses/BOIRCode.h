//
// BOIRCode.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BankObject.h"

@class BOComponentDevice, BOIRCodeset;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - IR Code
////////////////////////////////////////////////////////////////////////////////

@interface BOIRCode : BankObject

+ (instancetype)codeForDevice:(BOComponentDevice *)device;

+ (instancetype)codeFromProntoHex:(NSString *)hex context:(NSManagedObjectContext *)context;

+ (instancetype)codeFromProntoHex:(NSString *)hex device:(BOComponentDevice *)device;

- (NSString *)globalCacheFromProntoHex;

@property (nonatomic, assign) int64_t             frequency;
@property (nonatomic, assign) int16_t             offset;
@property (nonatomic, assign) int16_t             repeatCount;
@property (nonatomic, strong) NSString          * onOffPattern;
@property (nonatomic, strong) NSString          * prontoHex;
@property (nonatomic, strong) BOComponentDevice * device;
@property (nonatomic, assign) BOOL                setsDeviceInput;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Factory IR Code
////////////////////////////////////////////////////////////////////////////////

@interface BOFactoryIRCode : BOIRCode

+ (BOIRCode *)codeForCodeset:(BOIRCodeset *)set;

@property (nonatomic, strong) BOIRCodeset * codeset;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - User IR Code
////////////////////////////////////////////////////////////////////////////////
@interface BOUserIRCode : BOIRCode @end
