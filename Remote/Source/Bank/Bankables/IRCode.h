//
// IRCode.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BankableModelObject.h"

@class ComponentDevice, IRCodeset, Manufacturer;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - IR Code
////////////////////////////////////////////////////////////////////////////////

@interface IRCode : BankableModelObject

@property (nonatomic, assign) int64_t             frequency;
@property (nonatomic, assign) int16_t             offset;
@property (nonatomic, assign) int16_t             repeatCount;
@property (nonatomic, strong) NSString          * onOffPattern;
@property (nonatomic, strong) NSString          * prontoHex;
@property (nonatomic, strong) ComponentDevice   * device;
@property (nonatomic, assign) BOOL                setsDeviceInput;
@property (nonatomic, copy)   NSString          * codeset;
@property (nonatomic, strong) Manufacturer      * manufacturer;

@end
