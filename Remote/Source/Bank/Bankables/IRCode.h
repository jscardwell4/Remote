//
// IRCode.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BankableModelObject.h"

@class ComponentDevice, IRCodeset;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - IR Code
////////////////////////////////////////////////////////////////////////////////

@interface IRCode : BankableModelObject

+ (instancetype)codeForDevice:(ComponentDevice *)device;
+ (instancetype)userCodeForDevice:(ComponentDevice *)device;

+ (instancetype)codeFromProntoHex:(NSString *)hex context:(NSManagedObjectContext *)context;
+ (instancetype)userCodeFromProntoHex:(NSString *)hex context:(NSManagedObjectContext *)context;

+ (instancetype)codeFromProntoHex:(NSString *)hex device:(ComponentDevice *)device;
+ (instancetype)userCodeFromProntoHex:(NSString *)hex device:(ComponentDevice *)device;

- (NSString *)globalCacheFromProntoHex;

@property (nonatomic, assign) int64_t             frequency;
@property (nonatomic, assign) int16_t             offset;
@property (nonatomic, assign) int16_t             repeatCount;
@property (nonatomic, strong) NSString          * onOffPattern;
@property (nonatomic, strong) NSString          * prontoHex;
@property (nonatomic, strong) ComponentDevice   * device;
@property (nonatomic, assign) BOOL                setsDeviceInput;
@property (nonatomic, strong) IRCodeset         * codeset;

@end
