//
// BOPreset.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BankObject.h"

@class BankObjectPreview, RemoteElement;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Presets
////////////////////////////////////////////////////////////////////////////////
@interface BOPreset : BankObject
+ (instancetype)presetWithElement:(RemoteElement *)element;
@property (nonatomic, strong) BankObjectPreview * preview;
@property (nonatomic, strong) RemoteElement     * element;
@end

@interface BORemotePreset : BOPreset @end

@interface BOButtonGroupPreset : BOPreset @end

@interface BOButtonPreset : BOPreset @end

