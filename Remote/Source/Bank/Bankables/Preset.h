//
// Preset.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BankableModelObject.h"

@class RemoteElement;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Presets
////////////////////////////////////////////////////////////////////////////////
@interface Preset : BankableModelObject

+ (instancetype)presetWithElement:(RemoteElement *)element;

@property (nonatomic, strong, readwrite) RemoteElement  * element;

@end