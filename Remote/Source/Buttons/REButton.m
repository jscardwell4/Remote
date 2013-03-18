//
// Button.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"
#import "REButton.h"
#import "REImage.h"
#import "ConfigurationDelegate.h"
#import "REButtonGroup.h"
#import <QuartzCore/QuartzCore.h>

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@interface REButton ()

//@property (nonatomic, strong) NSValue *  primitiveTitleEdgeInsets;
//@property (nonatomic, strong) NSValue *  primitiveImageEdgeInsets;
//@property (nonatomic, strong) NSValue *  primitiveContentEdgeInsets;

@end

@implementation REButton {
    __weak id <CommandDelegate>   _commandDelegate;
}

//@synthesize primitiveTitleEdgeInsets;
//@synthesize primitiveImageEdgeInsets;
//@synthesize primitiveContentEdgeInsets;

@dynamic titleEdgeInsets;
@dynamic contentEdgeInsets;
@dynamic configurationDelegate;
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

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    self.backgroundColors = [ControlStateColorSet
                             colorSetForButton:self
                             withDefaultColors:ControlStateColorSetBackgroundDefault
                                          type:ControlStateBackgroundColorSet];
    self.titles = [ControlStateTitleSet titleSetForButton:self];
    self.images = [ControlStateButtonImageSet imageSetForButton:self];
    self.icons  = [ControlStateIconImageSet iconSetForButton:self];
    [self setPrimitiveValue:NSValueWithUIEdgeInsets(UIEdgeInsetsZero) forKey:@"titleEdgeInsets"];
    [self setPrimitiveValue:NSValueWithUIEdgeInsets(UIEdgeInsetsZero) forKey:@"imageEdgeInsets"];
    [self setPrimitiveValue:NSValueWithUIEdgeInsets(UIEdgeInsetsZero) forKey:@"contentEdgeInsets"];
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    [self.configurationDelegate registerForConfigurationChangeNotifications];
//    _titleEdgeInsets   = UIEdgeInsetsFromString([self valueForKey:@"titleEdgeInsetsString"]);
//    _imageEdgeInsets   = UIEdgeInsetsFromString([self valueForKey:@"imageEdgeInsetsString"]);
//    _contentEdgeInsets = UIEdgeInsetsFromString([self valueForKey:@"contentEdgeInsetsString"]);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    static NSDictionary const * kRedirects = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kRedirects =
        @{
          SelectorString(@selector(iconUIImageForState:)):
              @[NSValueWithPointer(@selector(icons)),
                NSValueWithPointer(@selector(UIImageForState:))],
          SelectorString(@selector(iconColorForState:)):
              @[NSValueWithPointer(@selector(icons)),
                NSValueWithPointer(@selector(iconColorForState:))],
          SelectorString(@selector(iconImageForState:)):
              @[NSValueWithPointer(@selector(icons)),
                NSValueWithPointer(@selector(imageForState:))],
          SelectorString(@selector(setIcon:forState:)):
              @[NSValueWithPointer(@selector(icons)),
                NSValueWithPointer(@selector(setImage:forState:))],
          SelectorString(@selector(setIconColor:forState:)):
              @[NSValueWithPointer(@selector(icons)),
                NSValueWithPointer(@selector(setIconColor:forState:))],
          SelectorString(@selector(titleForState:)):
              @[NSValueWithPointer(@selector(titles)),
                NSValueWithPointer(@selector(titleForState:))],
          SelectorString(@selector(setTitle:forState:)):
              @[NSValueWithPointer(@selector(titles)),
                NSValueWithPointer(@selector(setObject:forState:))],
          SelectorString(@selector(backgroundColorForState:)):
              @[NSValueWithPointer(@selector(backgroundColors)),
                NSValueWithPointer(@selector(colorForState:))],
          SelectorString(@selector(setBackgroundColor:forState:)):
              @[NSValueWithPointer(@selector(backgroundColors)),
                NSValueWithPointer(@selector(setColor:forState:))],
          SelectorString(@selector(buttonUIImageForState:)):
              @[NSValueWithPointer(@selector(images)),
                NSValueWithPointer(@selector(UIImageForState:))],
          SelectorString(@selector(setButtonImage:forState:)):
              @[NSValueWithPointer(@selector(images)),
                NSValueWithPointer(@selector(setImage:forState:))]
          };
    });

    NSArray * redirect = kRedirects[SelectorString(aSelector)];
    if (redirect) {
        id target;
        SuppressWarning("-Warc-performSelector-leaks",
                        target = (id)[self performSelector:PointerValue(redirect[0])];)
        assert(target);
        SEL action = (SEL)PointerValue(redirect[1]);
        assert(action);
        return [target methodSignatureForSelector:action];
    }

    else {
        return [super methodSignatureForSelector:aSelector];
    }

}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    static NSDictionary const * kRedirects = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kRedirects =
        @{
          SelectorString(@selector(iconUIImageForState:)):
              @[NSValueWithPointer(@selector(icons)),
                NSValueWithPointer(@selector(UIImageForState:))],
          SelectorString(@selector(iconColorForState:)):
              @[NSValueWithPointer(@selector(icons)),
                NSValueWithPointer(@selector(iconColorForState:))],
          SelectorString(@selector(iconImageForState:)):
              @[NSValueWithPointer(@selector(icons)),
                NSValueWithPointer(@selector(imageForState:))],
          SelectorString(@selector(setIcon:forState:)):
              @[NSValueWithPointer(@selector(icons)),
                NSValueWithPointer(@selector(setImage:forState:))],
          SelectorString(@selector(setIconColor:forState:)):
              @[NSValueWithPointer(@selector(icons)),
                NSValueWithPointer(@selector(setIconColor:forState:))],
          SelectorString(@selector(titleForState:)):
              @[NSValueWithPointer(@selector(titles)),
                NSValueWithPointer(@selector(titleForState:))],
          SelectorString(@selector(setTitle:forState:)):
              @[NSValueWithPointer(@selector(titles)),
                NSValueWithPointer(@selector(setObject:forState:))],
          SelectorString(@selector(backgroundColorForState:)):
              @[NSValueWithPointer(@selector(backgroundColors)),
                NSValueWithPointer(@selector(colorForState:))],
          SelectorString(@selector(setBackgroundColor:forState:)):
              @[NSValueWithPointer(@selector(backgroundColors)),
                NSValueWithPointer(@selector(setColor:forState:))],
          SelectorString(@selector(buttonUIImageForState:)):
              @[NSValueWithPointer(@selector(images)),
                NSValueWithPointer(@selector(UIImageForState:))],
          SelectorString(@selector(setButtonImage:forState:)):
              @[NSValueWithPointer(@selector(images)),
                NSValueWithPointer(@selector(setImage:forState:))]
          };
    });

    SEL selector = [anInvocation selector];
    assert(selector);
    NSArray * redirect = kRedirects[SelectorString(selector)];
    if (redirect) {
        id target;
        SuppressWarning("-Warc-performSelector-leaks",
                        target = (id)[self performSelector:PointerValue(redirect[0])];)
        assert(target);
        SEL action = (SEL)PointerValue(redirect[1]);
        assert(action);
        [anInvocation setTarget:target];
        [anInvocation setSelector:action];
        [anInvocation invoke];
    }

    else {
        [super forwardInvocation:anInvocation];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - State Accessors
////////////////////////////////////////////////////////////////////////////////

- (BOOL)isEnabled
{
    return ![self isFlagSetForBits:REButtonStateDisabled];
}

- (void)setEnabled:(BOOL)enabled
{
    [self willChangeValueForKey:@"enabled"];

    if (enabled)
        [self unsetFlagBits:REButtonStateDisabled];

    else
        [self setFlagBits:REButtonStateDisabled];

    [self didChangeValueForKey:@"enabled"];
}

- (BOOL)isHighlighted
{
    return [self isFlagSetForBits:REButtonStateHighlighted];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [self willChangeValueForKey:@"highlighted"];

    if (highlighted)
        [self setFlagBits:REButtonStateHighlighted];

    else
        [self unsetFlagBits:REButtonStateHighlighted];

    [self didChangeValueForKey:@"highlighted"];
}

- (BOOL)isSelected
{
    return [self isFlagSetForBits:REButtonStateSelected];
}

- (void)setSelected:(BOOL)selected
{
    [self willChangeValueForKey:@"selected"];

    if (selected)
        [self setFlagBits:REButtonStateSelected];

    else
        [self unsetFlagBits:REButtonStateSelected];

    [self didChangeValueForKey:@"selected"];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateSet Accessor Wrappers
////////////////////////////////////////////////////////////////////////////////

/*
- (UIImage *)iconUIImageForState:(UIControlState)state
{
    return [self.icons UIImageForState:state];
}

- (UIColor *)iconColorForState:(UIControlState)state
{
    return [self.icons iconColorForState:state];
}

- (REIconImage *)iconImageForState:(UIControlState)state
{
    return (REIconImage*)[self.icons imageForState:state
                                   substituteIfNil:YES
                                  substitutedState:NULL];
}

- (UIImage *)buttonUIImageForState:(UIControlState)state
{
    return [self.images UIImageForState:state];
}

- (NSAttributedString *)titleForState:(UIControlState)state
{
    return [self.titles titleForState:state];
}

- (UIColor *)backgroundColorForState:(UIControlState)state
{
    return [self.backgroundColors colorForState:state];
}

- (void)setBackgroundColor:(UIColor *)color
                  forState:(UIControlState)state
{
    [self.backgroundColors setColor:color forState:state];
}

- (void)setIcon:(REIconImage *)icon
       forState:(UIControlState)state
{
    [self.icons setImage:icon forState:state];
}

- (void)setIconColor:(UIColor *)color
            forState:(UIControlState)state
{
    [self.icons setIconColor:color forState:state];
}

- (void)setButtonImage:(REButtonImage *)image
              forState:(UIControlState)state
{
    [self.images setImage:image forState:state];
}

- (void)setTitle:(NSAttributedString *)title
        forState:(UIControlState)state
{
    [self.titles setObject:title forState:state];
}
*/

#pragma mark - Managing style properties

//- (void)setPrimitiveTitleEdgeInsets:(UIEdgeInsets)primitiveTitleEdgeInsets
//{
//    _titleEdgeInsets = primitiveTitleEdgeInsets;
//}

//- (UIEdgeInsets)primitiveTitleEdgeInsets
//{
//    return _titleEdgeInsets;
//}

- (UIEdgeInsets)titleEdgeInsets
{
    [self willAccessValueForKey:@"titleEdgeInsets"];
    UIEdgeInsets insets = UIEdgeInsetsValue([self primitiveValueForKey:@"titleEdgeInsets"]);
    [self didAccessValueForKey:@"titleEdgeInsets"];
    return insets;
}

- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets
{
    [self willChangeValueForKey:@"titleEdgeInsets"];
    [self setPrimitiveValue:NSValueWithUIEdgeInsets(titleEdgeInsets) forKey:@"titleEdgeInsets"];
    [self didChangeValueForKey:@"titleEdgeInsets"];
}

//- (void)setPrimitiveImageEdgeInsets:(UIEdgeInsets)primitiveImageEdgeInsets
//{
//    _imageEdgeInsets = primitiveImageEdgeInsets;
//}

//- (UIEdgeInsets)primitiveImageEdgeInsets
//{
//    return _imageEdgeInsets;
//}

- (UIEdgeInsets)imageEdgeInsets
{
    [self willAccessValueForKey:@"imageEdgeInsets"];
    UIEdgeInsets insets = UIEdgeInsetsValue([self primitiveValueForKey:@"imageEdgeInsets"]);
    [self didAccessValueForKey:@"imageEdgeInsets"];
    return insets;
}

- (void)setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets
{
    [self willChangeValueForKey:@"imageEdgeInsets"];
    [self setPrimitiveValue:NSValueWithUIEdgeInsets(imageEdgeInsets) forKey:@"imageEdgeInsets"];
    [self didChangeValueForKey:@"imageEdgeInsets"];
}

//- (void)setPrimitiveContentEdgeInsets:(UIEdgeInsets)primitiveContentEdgeInsets
//{
//    _contentEdgeInsets = primitiveContentEdgeInsets;
//}

//- (UIEdgeInsets)primitiveContentEdgeInsets
//{
//    return _contentEdgeInsets;
//}

- (UIEdgeInsets)contentEdgeInsets
{
    [self willAccessValueForKey:@"contentEdgeInsets"];
    UIEdgeInsets insets = UIEdgeInsetsValue([self primitiveValueForKey:@"contentEdgeInsets"]);
    [self didAccessValueForKey:@"contentEdgeInsets"];
    return insets;
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets
{
    [self willChangeValueForKey:@"contentEdgeInsets"];
    [self setPrimitiveValue:NSValueWithUIEdgeInsets(contentEdgeInsets) forKey:@"contentEdgeInsets"];
    [self didChangeValueForKey:@"contentEdgeInsets"];
}

#pragma mark - Executing commands
/// @name ￼Executing commands

- (void)executeCommandWithOptions:(CommandOptions)options
                         delegate:(id <CommandDelegate> )delegate
{
    _commandDelegate = delegate;

    BOOL   commandIssued = NO;

    if (options == CommandOptionsLongPress && self.longPressCommand)
    {
        [self.longPressCommand execute:self];
        commandIssued = YES;
    }

    else if (self.command)
        [self.command execute:self]; commandIssued = YES;

    if (!commandIssued)
        [self commandDidComplete:nil success:NO];
}

- (void)commandDidComplete:(Command *)command success:(BOOL)success
{
    if (_commandDelegate)
        [_commandDelegate commandDidComplete:command success:success];
}

@end

#import "ComponentDevice.h"
#import "RERemoteController.h"

@implementation REActivityButton

@dynamic deviceConfigurations;

- (void)setActivityButtonType:(REActivityButtonType)activityButtonType
{
    assert(activityButtonType == REActivityButtonTypeBegin || activityButtonType == REActivityButtonTypeEnd);
    [self setSubtype:(RESubtype)activityButtonType];
}

- (REActivityButtonType)activityButtonType
{
    return [self flagsWithMask:RESubtypeMask];
}

/**
 * Calls `activityActionForButton:` on the button's remote controller before exiting the command.
 * @param options Options for the command to execute.
 * @param delegate `CommandDelegate` for the command to notify with result of execution.
 */
- (void)executeCommandWithOptions:(CommandOptions)options delegate:(id <CommandDelegate> )delegate
{
    [self.controller activityActionForButton:self];

    [super executeCommandWithOptions:options delegate:delegate];
}

@end
