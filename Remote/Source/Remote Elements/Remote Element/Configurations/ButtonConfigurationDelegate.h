//
// ButtonConfigurationDelegate.h
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "ConfigurationDelegate.h"


@class Button,
       Command,
       ControlStateTitleSet,
       ControlStateImageSet,
       ControlStateColorSet;

@interface ButtonConfigurationDelegate : ConfigurationDelegate

//- (NSAttributedString *)titleForState:(REState)state;

- (void)setCommand:(Command *)command mode:(RERemoteMode)mode;
- (Command *)commandForMode:(RERemoteMode)mode;

- (void)setTitle:(id)title mode:(RERemoteMode)mode;

- (void)setTitles:(ControlStateTitleSet *)titleSet mode:(RERemoteMode)mode;
- (ControlStateTitleSet *)titlesForMode:(RERemoteMode)mode;

- (void)setBackgroundColors:(ControlStateColorSet *)colors
           mode:(RERemoteMode)mode;
- (ControlStateColorSet *)backgroundColorsForMode:(RERemoteMode)mode;

- (void)setIcons:(ControlStateImageSet *)icons mode:(RERemoteMode)mode;
- (ControlStateImageSet *)iconsForMode:(RERemoteMode)mode;

- (void)setImages:(ControlStateImageSet *)images  mode:(RERemoteMode)mode;
- (ControlStateImageSet *)imagesForMode:(RERemoteMode)mode;

- (Button *)button;

@property (nonatomic, assign, readonly) ControlStateTitleSet   * titles;
@property (nonatomic, assign, readonly) ControlStateColorSet   * backgroundColors;
@property (nonatomic, assign, readonly) ControlStateImageSet   * icons;
@property (nonatomic, assign, readonly) ControlStateImageSet   * images;


@end

