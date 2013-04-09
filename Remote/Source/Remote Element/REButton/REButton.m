//
// Button.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"
#import <QuartzCore/QuartzCore.h>

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation REButton 

@dynamic titleEdgeInsets;
@dynamic contentEdgeInsets;
@dynamic configurationDelegate;
@dynamic parentElement;
@dynamic imageEdgeInsets;
@dynamic command;
@dynamic longPressCommand;
@dynamic icons;
@dynamic images;
@dynamic backgroundColors;
@dynamic titles;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Object Lifecycle
////////////////////////////////////////////////////////////////////////////////

+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)context
{
    REButton * element = [super remoteElementInContext:context];
    element.type = RETypeButton;
    return element;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    NSManagedObjectContext * cxt = self.managedObjectContext;
    
    [cxt performBlockAndWait:
     ^{
         NSValue * zeroInsets = NSValueWithUIEdgeInsets(UIEdgeInsetsZero);
         self.primitiveTitleEdgeInsets   = zeroInsets;
         self.primitiveImageEdgeInsets   = zeroInsets;
         self.primitiveContentEdgeInsets = zeroInsets;

         self.icons            = [REControlStateIconImageSet   controlStateSetInContext:cxt];
         self.titles           = [REControlStateTitleSet       controlStateSetInContext:cxt];
         self.images           = [REControlStateButtonImageSet controlStateSetInContext:cxt];
         self.backgroundColors = [REControlStateColorSet       controlStateSetInContext:cxt];
     }];
}

- (RERemote *)remote { return (RERemote *)self.parentElement.parentElement; }

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
                       completion:(void (^)(BOOL, BOOL))completion
{

    if (options == RECommandOptionsLongPress && self.longPressCommand)
        [self.longPressCommand execute:completion];

    else if (self.command) [self.command execute:completion];

    else if (completion) completion(YES, NO);
}

@end

@implementation REActivityButton

@dynamic deviceConfigurations;

+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)context
{
    REActivityButton * element = [super remoteElementInContext:context];
    element.type = REButtonTypeActivityButton;
    return element;
}

- (void)setActivityButtonType:(REActivityButtonType)activityButtonType
{
    assert(   activityButtonType == REActivityButtonTypeBegin
           || activityButtonType == REActivityButtonTypeEnd);
    [self setSubtype:(RESubtype)activityButtonType];
}

- (REActivityButtonType)activityButtonType { return [self flagsWithMask:RESubtypeMask]; }

/**
 * Calls `activityActionForButton:` on the button's remote controller before exiting the command.
 * @param options Options for the command to execute.
 * @param delegate `CommandDelegate` for the command to notify with result of execution.
 */
- (void)executeCommandWithOptions:(RECommandOptions)options
                       completion:(void (^)(BOOL finished, BOOL success))completion
{
    [self.controller activityActionForButton:self
                                  completion:^(BOOL finished, BOOL success)
                                             {
                                                 [super executeCommandWithOptions:options
                                                                       completion:completion];
                                             }];
}

@end
