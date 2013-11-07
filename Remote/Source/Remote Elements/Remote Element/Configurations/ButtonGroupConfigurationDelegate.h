//
// ButtonGroupConfigurationDelegate.h
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "ConfigurationDelegate.h"

@class ButtonGroup, CommandContainer;

@interface ButtonGroupConfigurationDelegate : ConfigurationDelegate

- (CommandContainer *)commandContainerForMode:(RERemoteMode)mode;
- (void)setCommandContainer:(CommandContainer *)container mode:(RERemoteMode)mode;

- (NSAttributedString *)labelForMode:(RERemoteMode)mode;
- (void)setLabel:(NSAttributedString *)label mode:(RERemoteMode)mode;

- (void)importCommandContainer:(id)data;

- (ButtonGroup *)buttonGroup;

@property (nonatomic, readonly) CommandContainer * commandContainer;
@property (nonatomic, readonly) NSAttributedString * label;

@end

