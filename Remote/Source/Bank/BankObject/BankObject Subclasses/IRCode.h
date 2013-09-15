//
// IRCode.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "Bank.h"
#import "ModelObject.h"

@class ComponentDevice, BOIRCodeset;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - IR Code
////////////////////////////////////////////////////////////////////////////////

@interface IRCode : ModelObject<Bankable>

+ (instancetype)codeForDevice:(ComponentDevice *)device;

+ (instancetype)codeFromProntoHex:(NSString *)hex context:(NSManagedObjectContext *)context;

+ (instancetype)codeFromProntoHex:(NSString *)hex device:(ComponentDevice *)device;

- (NSString *)globalCacheFromProntoHex;

@property (nonatomic, assign) int64_t             frequency;
@property (nonatomic, assign) int16_t             offset;
@property (nonatomic, assign) int16_t             repeatCount;
@property (nonatomic, strong) NSString          * onOffPattern;
@property (nonatomic, strong) NSString          * prontoHex;
@property (nonatomic, strong) ComponentDevice * device;
@property (nonatomic, assign) BOOL                setsDeviceInput;
@property (nonatomic, strong) NSString          * name;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Factory IR Code
////////////////////////////////////////////////////////////////////////////////

@interface FactoryIRCode : IRCode

+ (IRCode *)codeForCodeset:(BOIRCodeset *)set;

@property (nonatomic, strong) BOIRCodeset * codeset;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - User IR Code
////////////////////////////////////////////////////////////////////////////////
@interface UserIRCode : IRCode @end
