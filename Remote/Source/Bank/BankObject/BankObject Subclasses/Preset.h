//
// Preset.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "Bank.h"
#import "ModelObject.h"

@class BankObjectPreview, RemoteElement;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Presets
////////////////////////////////////////////////////////////////////////////////
@interface Preset : ModelObject<Bankable>
+ (instancetype)presetWithElement:(RemoteElement *)element;
@property (nonatomic, strong) BankObjectPreview * preview;
@property (nonatomic, strong) RemoteElement     * element;
@property (nonatomic, strong) NSString          * name;
@end
