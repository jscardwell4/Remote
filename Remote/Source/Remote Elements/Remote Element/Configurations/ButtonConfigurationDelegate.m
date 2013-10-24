//
// ButtonConfigurationDelegate.m
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "ConfigurationDelegate_Private.h"
#import "ControlStateSet.h"
#import "Command.h"

@implementation ButtonConfigurationDelegate

@dynamic
commands,
titleSets,
iconSets,
imageSets,
backgroundColorSets;

@synthesize
command          = _command,
titles           = _titles,
backgroundColors = _backgroundColors,
icons            = _icons,
images           = _images,
kvoReceptionist  = _kvoReceptionist;


////////////////////////////////////////////////////////////////////////////////
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////////////

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self kvoRegistration];
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    [self kvoRegistration];
}

- (void)didTurnIntoFault
{
    [super didTurnIntoFault];
    self.command = nil;
    self.titles = nil;
    self.backgroundColors = nil;
    self.icons = nil;
    self.images = nil;
    self.kvoReceptionist = nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark KVO
////////////////////////////////////////////////////////////////////////////////

- (void)kvoRegistration
{
    if ([self.managedObjectContext.nametag isEqualToString:@"remote"])
        self.kvoReceptionist = [MSKVOReceptionist
                                receptionistForObject:self.element
                                              keyPath:@"state"
                                              options:NSKeyValueObservingOptionNew
                                              context:(__bridge void*)self
                                                queue:MainQueue
                                              handler:^(MSKVOReceptionist * receptionist,
                                                        NSString * keyPath,
                                                        id object,
                                                        NSDictionary * change,
                                                        void * context)
                                {
                                    ButtonConfigurationDelegate * delegate =
                                        (__bridge ButtonConfigurationDelegate*)context;
                                    [delegate.managedObjectContext performBlock:
                                     ^{
                                         [delegate updateButtonForState: ((Button*)object).state];
                                     }];
                                }];
}


- (Button *)button { return (Button *)self.element; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark Updating State
////////////////////////////////////////////////////////////////////////////////

- (void)updateButtonForState:(REState)state
{
    self.button.command         = self.command;
    self.button.title           = self.titles[state];//[self titleForState:state];
    self.button.icon            = [self.icons UIImageForState:state];
    self.button.image           = [self.images UIImageForState:state];
    self.button.backgroundColor = self.backgroundColors[state];

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Updating Configurations
////////////////////////////////////////////////////////////////////////////////

- (void)updateForMode:(RERemoteMode)mode
{
    if (![self hasMode:mode]) return;

    self.command          = [self commandForMode:mode];
    self.titles           = [self titlesForMode:mode];
    self.icons            = [self iconsForMode:mode];
    self.images           = [self imagesForMode:mode];
    self.backgroundColors = [self backgroundColorsForMode:mode];

    [self updateButtonForState:self.button.state];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Commands
////////////////////////////////////////////////////////////////////////////////

- (void)setCommand:(Command *)command mode:(RERemoteMode)mode
{
    ControlStateKeyPath * kp = makeKeyPath(mode, @"command");
    self[kp] = [[command permanentURI] absoluteString];
    if (command) [self addCommandsObject:command];
}

- (Command *)commandForMode:(RERemoteMode)mode
{
    ControlStateKeyPath * kp = makeKeyPath(mode,@"command");
    NSString * uri = self[kp];
    return (uri ? [self.managedObjectContext objectForURI:[NSURL URLWithString:uri]] : nil);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Titles
////////////////////////////////////////////////////////////////////////////////

- (void)setTitle:(id)title mode:(RERemoteMode)mode
{
    [self setTitles:[ControlStateTitleSet controlStateSetInContext:self.managedObjectContext
                                                       withObjects:@{@"normal": title}]
               mode:mode];
}

- (void)setTitles:(ControlStateTitleSet *)titles mode:(RERemoteMode)mode
{
    ControlStateKeyPath * kp = makeKeyPath(mode,@"titles");
    self[kp] = [[titles permanentURI] absoluteString];
    if (titles) [self addTitleSetsObject:titles];
}

- (ControlStateTitleSet *)titlesForMode:(RERemoteMode)mode
{
    ControlStateKeyPath * kp = makeKeyPath(mode,@"titles");
    NSString * uri = self[kp];
    return (uri ? [self.managedObjectContext objectForURI:[NSURL URLWithString:uri]] : nil);
}

- (ControlStateTitleSet *)titles { return [self titlesForMode:self.currentMode]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark Background colors
////////////////////////////////////////////////////////////////////////////////

- (void)setBackgroundColors:(ControlStateColorSet *)colors mode:(RERemoteMode)mode
{
    ControlStateKeyPath * kp = makeKeyPath(mode,@"backgroundColors");
    self[kp] = [[colors permanentURI] absoluteString];
    if (colors) [self addBackgroundColorSetsObject:colors];
}

- (ControlStateColorSet *)backgroundColorsForMode:(RERemoteMode)mode
{
    ControlStateKeyPath * kp = makeKeyPath(mode,@"backgroundColors");
    NSString * uri = self[kp];
    return (uri ? [self.managedObjectContext objectForURI:[NSURL URLWithString:uri]] : nil);
}

- (ControlStateColorSet *)backgroundColors { return [self backgroundColorsForMode:self.currentMode]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark Icons
////////////////////////////////////////////////////////////////////////////////

- (void)setIcons:(ControlStateImageSet *)icons mode:(RERemoteMode)mode
{
    ControlStateKeyPath * kp = makeKeyPath(mode,@"icons");
    self[kp] = [[icons permanentURI] absoluteString];
    if (icons) [self addIconSetsObject:icons];
}

- (ControlStateImageSet *)iconsForMode:(RERemoteMode)mode
{
    ControlStateKeyPath * kp = makeKeyPath(mode,@"icons");
    NSString * uri = self[kp];
    return (uri ? [self.managedObjectContext objectForURI:[NSURL URLWithString:uri]] : nil);
}

- (ControlStateImageSet *)icons { return [self iconsForMode:self.currentMode]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark Images
////////////////////////////////////////////////////////////////////////////////

- (void)setImages:(ControlStateImageSet *)images mode:(RERemoteMode)mode
{
    ControlStateKeyPath * kp = makeKeyPath(mode,@"images");
    self[kp] = [[images permanentURI] absoluteString];
    if (images) [self addImageSetsObject:images];
}

- (ControlStateImageSet *)imagesForMode:(RERemoteMode)mode
{
    ControlStateKeyPath * kp = makeKeyPath(mode,@"images");
    NSString * uri = self[kp];
    return (uri ? [self.managedObjectContext objectForURI:[NSURL URLWithString:uri]] : nil);
}

- (ControlStateImageSet *)images { return [self imagesForMode:self.currentMode]; }

@end
