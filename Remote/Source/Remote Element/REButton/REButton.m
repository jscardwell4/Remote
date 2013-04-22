//
// Button.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"
#import <QuartzCore/QuartzCore.h>
#import "REControlStateSetProxy.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation REButton 

@dynamic titleEdgeInsets;
@dynamic contentEdgeInsets;
@dynamic parentElement;
@dynamic imageEdgeInsets;
@dynamic command;
@dynamic longPressCommand;
@dynamic controller;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Object Lifecycle
////////////////////////////////////////////////////////////////////////////////

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self.managedObjectContext performBlockAndWait:
    ^{
        self.type                  = RETypeButton;
        self.configurationDelegate = [REButtonConfigurationDelegate delegateForRemoteElement:self];
    }];
}

- (RERemote *)remote { return (RERemote *)self.parentElement.parentElement; }

- (RERemoteController *)controller
{
    return (self.parentElement ? self.parentElement.controller : nil);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Proxies
////////////////////////////////////////////////////////////////////////////////

- (REControlStateTitleSet *)titles
{
    if (!__titles) __titles = ((REButtonConfigurationDelegate *)self.configurationDelegate).titlesProxy;
    return (REControlStateTitleSet *)__titles;
}

- (REControlStateIconImageSet *)icons
{
    if (!__icons) __icons = ((REButtonConfigurationDelegate *)self.configurationDelegate).iconsProxy;
    return (REControlStateIconImageSet *)__icons;
}

- (REControlStateButtonImageSet *)images
{
    if (!__images) __images = ((REButtonConfigurationDelegate *)self.configurationDelegate).imagesProxy;
    return (REControlStateButtonImageSet *)__images;
}

- (REControlStateColorSet *)backgroundColors
{
    if (!__backgroundColors) __backgroundColors = ((REButtonConfigurationDelegate *)self.configurationDelegate).backgroundColorsProxy;
    return (REControlStateColorSet *)__backgroundColors;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - State Accessors
////////////////////////////////////////////////////////////////////////////////

- (BOOL)isEnabled { return ![self isFlagSetForBits:REButtonStateDisabled]; }

- (void)setEnabled:(BOOL)enabled
{
    [self willChangeValueForKey:@"enabled"];
    if (enabled) [self unsetFlagBits:REButtonStateDisabled];
    else         [self setFlagBits:REButtonStateDisabled];
    [self didChangeValueForKey:@"enabled"];
}

- (BOOL)isHighlighted { return [self isFlagSetForBits:REButtonStateHighlighted]; }

- (void)setHighlighted:(BOOL)highlighted
{
    [self willChangeValueForKey:@"highlighted"];
    if (highlighted) [self setFlagBits:REButtonStateHighlighted];
    else             [self unsetFlagBits:REButtonStateHighlighted];
    [self didChangeValueForKey:@"highlighted"];
}

- (BOOL)isSelected { return [self isFlagSetForBits:REButtonStateSelected]; }

- (void)setSelected:(BOOL)selected
{
    [self willChangeValueForKey:@"selected"];
    if (selected) [self setFlagBits:REButtonStateSelected];
    else          [self unsetFlagBits:REButtonStateSelected];
    [self didChangeValueForKey:@"selected"];
}

- (void)setTitle:(NSString *)title { self.titles[UIControlStateNormal] = title; }

- (void)setTitle:(NSString *)title forConfiguration:(RERemoteConfiguration)configuration
{
    [((REButtonConfigurationDelegate *)self.configurationDelegate) setTitle:title forConfiguration:configuration];
}

- (void)setCommand:(RECommand *)command forConfiguration:(RERemoteConfiguration)configuration
{
    [((REButtonConfigurationDelegate *)self.configurationDelegate) setCommand:command forConfiguration:configuration];
}

- (NSString *)title { return self.titles[UIControlStateNormal].string; }

- (void)setIcons:(REControlStateIconImageSet *)icons
forConfiguration:(RERemoteConfiguration)configuration
{
    [(REButtonConfigurationDelegate *)self.configurationDelegate setIcons:icons
                                                         forConfiguration:configuration];
}

- (UIEdgeInsets)titleEdgeInsets
{
    [self willAccessValueForKey:@"titleEdgeInsets"];
    UIEdgeInsets insets = UIEdgeInsetsValue(self.primitiveTitleEdgeInsets);
    [self didAccessValueForKey:@"titleEdgeInsets"];
    return insets;
}

- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets
{
    [self willChangeValueForKey:@"titleEdgeInsets"];
    self.primitiveTitleEdgeInsets = NSValueWithUIEdgeInsets(titleEdgeInsets);
    [self didChangeValueForKey:@"titleEdgeInsets"];
}

- (UIEdgeInsets)imageEdgeInsets
{
    [self willAccessValueForKey:@"imageEdgeInsets"];
    UIEdgeInsets insets = UIEdgeInsetsValue(self.primitiveImageEdgeInsets);
    [self didAccessValueForKey:@"imageEdgeInsets"];
    return insets;
}

- (void)setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets
{
    [self willChangeValueForKey:@"imageEdgeInsets"];
    self.primitiveImageEdgeInsets = NSValueWithUIEdgeInsets(imageEdgeInsets);
    [self didChangeValueForKey:@"imageEdgeInsets"];
}

- (UIEdgeInsets)contentEdgeInsets
{
    [self willAccessValueForKey:@"contentEdgeInsets"];
    UIEdgeInsets insets = UIEdgeInsetsValue(self.primitiveContentEdgeInsets);
    [self didAccessValueForKey:@"contentEdgeInsets"];
    return insets;
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets
{
    [self willChangeValueForKey:@"contentEdgeInsets"];
    self.primitiveContentEdgeInsets = NSValueWithUIEdgeInsets(contentEdgeInsets);
    [self didChangeValueForKey:@"contentEdgeInsets"];
}

- (void)executeCommandWithOptions:(RECommandOptions)options
                       completion:(RECommandCompletionHandler)completion
{

    if (options == RECommandOptionsLongPress && self.longPressCommand)
        [self.longPressCommand execute:completion];

    else if (self.command) [self.command execute:completion];

    else if (completion) completion(YES, NO);
}

@end

@implementation REButton (Debugging)

- (MSDictionary *)deepDescriptionDictionary
{
    REButton * element = [self faultedObject];
    assert(element);

    MSMutableDictionary * descriptionDictionary = [[super deepDescriptionDictionary] mutableCopy];

    descriptionDictionary[@"titles"] = (element.titles
                                        ? $(@"%@(%p)", element.titles.uuid, element.titles)
                                        : @"nil");

    descriptionDictionary[@"icons"] = (element.icons
                                       ? $(@"%@(%p)", element.icons.uuid, element.icons)
                                       : @"nil");

    descriptionDictionary[@"backgroundColors"] = (element.backgroundColors
                                                  ? $(@"%@(%p)",
                                                      element.backgroundColors.uuid,
                                                      element.backgroundColors)
                                                  : @"nil");

    descriptionDictionary[@"images"] = (element.images
                                        ? $(@"%@(%p)",
                                            element.images.uuid,
                                            element.images)
                                        : @"nil");

    descriptionDictionary[@"command"] = (element.command
                                         ? $(@"%@(%p)-%@",
                                             element.command.uuid,
                                             element.command,
                                             [element.command shortDescription])
                                         : @"nil");

    descriptionDictionary[@"longPressCommand"] = (element.longPressCommand
                                         ? $(@"%@(%p)-%@",
                                             element.longPressCommand.uuid,
                                             element.longPressCommand,
                                             [element.longPressCommand shortDescription])
                                         : @"nil");

    descriptionDictionary[@"titleEdgeInsets"  ] = UIEdgeInsetsString(element.titleEdgeInsets  );
    descriptionDictionary[@"imageEdgeInsets"  ] = UIEdgeInsetsString(element.imageEdgeInsets  );
    descriptionDictionary[@"contentEdgeInsets"] = UIEdgeInsetsString(element.contentEdgeInsets);

    descriptionDictionary[@"remote"] = (element.remote
                                        ? $(@"%@(%p)", element.remote.uuid, element.remote)
                                        : @"nil");


    return descriptionDictionary;
}

@end

