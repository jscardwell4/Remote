//
// Button.m
// iPhonto
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"
#import "Button.h"
#import "GalleryImage.h"
#import "ConfigurationDelegate.h"
#import "ButtonGroup.h"
#import <QuartzCore/QuartzCore.h>

// #define DEBUG_LOGS_EVENTS NO

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@interface Button ()

@property (nonatomic, assign) UIEdgeInsets   primitiveTitleEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets   primitiveImageEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets   primitiveContentEdgeInsets;

@end

@implementation Button {
    __weak id <CommandDelegate>   _commandDelegate;
    UIEdgeInsets                  _titleEdgeInsets, _imageEdgeInsets, _contentEdgeInsets;
}

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

- (void)awakeFromInsert {
    /*
     * You typically use this method to initialize special default property values. This method
     * is invoked only once in the object's lifetime. If you want to set attribute values in an
     * implementation of this method, you should typically use primitive accessor methods (either
     * setPrimitiveValue:forKey: or—better—the appropriate custom primitive accessors). This
     * ensures that the new values are treated as baseline values rather than being recorded as
     * undoable changes for the properties in question.
     *
     */
    [super awakeFromInsert];

    self.backgroundColors = [ControlStateColorSet
                             colorSetForButton:self
                             withDefaultColors:ControlStateColorSetBackgroundDefault
                                          type:ControlStateBackgroundColorSet];
    self.titles = [ControlStateTitleSet titleSetForButton:self];
    self.images = [ControlStateButtonImageSet imageSetForButton:self];
    self.icons  = [ControlStateIconImageSet iconSetForButton:self];
// self.titleEdgeInsets = UIEdgeInsetsZero;
// self.imageEdgeInsets = UIEdgeInsetsZero;
// self.contentEdgeInsets = UIEdgeInsetsZero;
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self.configurationDelegate registerForConfigurationChangeNotifications];
    _titleEdgeInsets   = UIEdgeInsetsFromString([self valueForKey:@"titleEdgeInsetsString"]);
    _imageEdgeInsets   = UIEdgeInsetsFromString([self valueForKey:@"imageEdgeInsetsString"]);
    _contentEdgeInsets = UIEdgeInsetsFromString([self valueForKey:@"contentEdgeInsetsString"]);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Adding/Validating Attributes
////////////////////////////////////////////////////////////////////////////////

// TODO: Add validation methods

/*
 * - (void)setAttributesFromDictionary:(NSDictionary *)attributes {
 *  assert(attributes);
 *  [super setAttributesFromDictionary:attributes];
 *
 *  static NSArray * kAttributeIndices = nil;
 *  static dispatch_once_t onceToken;
 *  dispatch_once(&onceToken, ^{
 *      kAttributeIndices = @[  @"command",			// 0
 *                              @"titleEdgeInsets",	// 1
 *                              @"contentEdgeInsets",	// 2
 *                              @"imageEdgeInsets",	// 3
 *                              @"titles",				// 4
 *                              @"icons",				// 5
 *                              @"iconColors",                  // 6
 *                              @"backgroundColors",   // 7
 *                              @"longPressCommand"    // 8
 *                          ];
 *
 *  });
 *
 *  [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
 *      switch ([kAttributeIndices indexOfObject:key]) {
 *          case 0: self.command				= obj;
 *                                          break;
 *          case 1: self.titleEdgeInsets                = [obj UIEdgeInsetsValue];      break;
 *          case 2: self.contentEdgeInsets              = [obj UIEdgeInsetsValue];      break;
 *          case 3: self.imageEdgeInsets                = [obj UIEdgeInsetsValue];      break;
 *          case 4: self.titles					= obj;
 *                                          break;
 *          case 5: self.icons					= obj;
 *                                          break;
 *          case 6: self.icons.iconColors		= obj;
 *                                          break;
 *          case 7: self.backgroundColors		= obj;
 *                                          break;
 *          case 8: self.longPressCommand               = ValueIsNil(obj)?nil:obj;	break;
 *      }
 *  }];
 * }
 */

////////////////////////////////////////////////////////////////////////////////
#pragma mark - State Accessors
////////////////////////////////////////////////////////////////////////////////

- (BOOL)isEnabled {
    return ![self isFlagSetForBits:ButtonStateDisabled];
}

- (void)setEnabled:(BOOL)enabled {
    [self willChangeValueForKey:@"enabled"];
    if (enabled) [self unsetFlagBits:ButtonStateDisabled];
    else [self setFlagBits:ButtonStateDisabled];

    [self didChangeValueForKey:@"enabled"];
}

- (BOOL)isHighlighted {
    return [self isFlagSetForBits:ButtonStateHighlighted];
}

- (void)setHighlighted:(BOOL)highlighted {
    [self willChangeValueForKey:@"highlighted"];
    if (highlighted) [self setFlagBits:ButtonStateHighlighted];
    else [self unsetFlagBits:ButtonStateHighlighted];

    [self didChangeValueForKey:@"highlighted"];
}

- (BOOL)isSelected {
    return [self isFlagSetForBits:ButtonStateSelected];
}

- (void)setSelected:(BOOL)selected {
    [self willChangeValueForKey:@"selected"];
    if (selected) [self setFlagBits:ButtonStateSelected];
    else [self unsetFlagBits:ButtonStateSelected];

    [self didChangeValueForKey:@"selected"];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateSet Accessor Wrappers
////////////////////////////////////////////////////////////////////////////////

- (UIImage *)iconForState:(UIControlState)state {
    return [self.icons imageForState:state];
}

- (UIColor *)iconColorForState:(UIControlState)state {
    return [self.icons iconColorForState:state];
}

- (GalleryIconImage *)galleryIconImageForState:(UIControlState)state {
    return (GalleryIconImage *)[self.icons galleryImageForState:state substituteIfNil:YES substitutedState:NULL];
}

- (UIImage *)buttonImageForState:(UIControlState)state {
    return [self.images imageForState:state];
}

- (NSAttributedString *)titleForState:(UIControlState)state {
    return [self.titles titleForState:state];
}

- (UIColor *)backgroundColorForState:(UIControlState)state {
    return [self.backgroundColors colorForState:state];
}

- (void)setBackgroundColor:(UIColor *)color
                  forState:(UIControlState)state {
    [self.backgroundColors setColor:color forState:state];
}

- (void)setIcon:(GalleryIconImage *)icon
       forState:(UIControlState)state {
    [self.icons setImage:icon forState:state];
}

- (void)setIconColor:(UIColor *)color
            forState:(UIControlState)state {
    [self.icons setIconColor:color forState:state];
}

- (void)setButtonImage:(GalleryButtonImage *)image
              forState:(UIControlState)state {
    [self.images setImage:image forState:state];
}

- (void)setTitle:(NSAttributedString *)title
        forState:(UIControlState)state {
    [self.titles setObject:title forState:state];
}

#pragma mark - Managing style properties

- (void)setPrimitiveTitleEdgeInsets:(UIEdgeInsets)primitiveTitleEdgeInsets {
    _titleEdgeInsets = primitiveTitleEdgeInsets;
}

- (UIEdgeInsets)primitiveTitleEdgeInsets {
    return _titleEdgeInsets;
}

- (UIEdgeInsets)titleEdgeInsets {
    [self willAccessValueForKey:@"titleEdgeInsets"];

    UIEdgeInsets   insets = _titleEdgeInsets;

    [self didAccessValueForKey:@"titleEdgeInsets"];

    return insets;
}

- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
    [self willChangeValueForKey:@"titleEdgeInsets"];
    _titleEdgeInsets = titleEdgeInsets;
    [self didChangeValueForKey:@"titleEdgeInsets"];
    [self setValue:NSStringFromUIEdgeInsets(titleEdgeInsets) forKey:@"titleEdgeInsetsString"];
}

- (void)setPrimitiveImageEdgeInsets:(UIEdgeInsets)primitiveImageEdgeInsets {
    _imageEdgeInsets = primitiveImageEdgeInsets;
}

- (UIEdgeInsets)primitiveImageEdgeInsets {
    return _imageEdgeInsets;
}

- (UIEdgeInsets)imageEdgeInsets {
    [self willAccessValueForKey:@"imageEdgeInsets"];

    UIEdgeInsets   insets = _imageEdgeInsets;

    [self didAccessValueForKey:@"imageEdgeInsets"];

    return insets;
}

- (void)setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets {
    [self willChangeValueForKey:@"imageEdgeInsets"];
    _imageEdgeInsets = imageEdgeInsets;
    [self didChangeValueForKey:@"imageEdgeInsets"];
    [self setValue:NSStringFromUIEdgeInsets(imageEdgeInsets) forKey:@"imageEdgeInsetsString"];
}

- (void)setPrimitiveContentEdgeInsets:(UIEdgeInsets)primitiveContentEdgeInsets {
    _contentEdgeInsets = primitiveContentEdgeInsets;
}

- (UIEdgeInsets)primitiveContentEdgeInsets {
    return _contentEdgeInsets;
}

- (UIEdgeInsets)contentEdgeInsets {
    [self willAccessValueForKey:@"contentEdgeInsets"];

    UIEdgeInsets   insets = _contentEdgeInsets;

    [self didAccessValueForKey:@"contentEdgeInsets"];

    return insets;
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    [self willChangeValueForKey:@"contentEdgeInsets"];
    _contentEdgeInsets = contentEdgeInsets;
    [self didChangeValueForKey:@"contentEdgeInsets"];
    [self setValue:NSStringFromUIEdgeInsets(contentEdgeInsets) forKey:@"contentEdgeInsetsString"];
}

#pragma mark - Executing commands
/// @name ￼Executing commands

- (void)executeCommandWithOptions:(CommandOptions)options
                         delegate:(id <CommandDelegate> )delegate {
    _commandDelegate = delegate;

    BOOL   commandIssued = NO;

    if (options == CommandOptionsLongPress && self.longPressCommand) {
        [self.longPressCommand execute:self]; commandIssued = YES;
    } else if (self.command) {
        [self.command execute:self]; commandIssued = YES;
    }

    if (!commandIssued) [self commandDidComplete:nil success:NO];
}

- (void)commandDidComplete:(Command *)command success:(BOOL)success {
    if (_commandDelegate) [_commandDelegate commandDidComplete:command success:success];
}

@end

#import "ComponentDevice.h"
#import "RemoteController.h"

@implementation ActivityButton

@dynamic deviceConfigurations;

/*
 * - (void)setAttributesFromDictionary:(NSDictionary *)attributes {
 *  [super setAttributesFromDictionary:attributes];
 *  self.deviceConfigurations = attributes[@"deviceConfigurations"];
 *  if (attributes[@"type"])
 *      self.activityButtonType = [attributes[@"type"] unsignedLongLongValue];
 * }
 */

/*
 * - (void)setCommand:(Command *)command {
 *  [self willChangeValueForKey:@"command"];
 *  [self setPrimitiveValue:command forKey:@"command"];
 *  [self didChangeValueForKey:@"command"];
 *
 *  if (   self.activityButtonType == ActivityButtonTypeBegin
 *      && [command isKindOfClass:[MacroCommand class]])
 *  {
 *      MacroCommand * macro = (MacroCommand *)command;
 *      for (int i = 0; i < [macro numberOfCommands]; i++) {
 *          Command * c = macro[i];
 *          if ([c isKindOfClass:[SwitchToRemoteCommand class]]) {
 *              self.longPressCommand = c;
 *              break;
 *          }
 *      }
 *  }
 * }
 *
 */

- (void)setActivityButtonType:(ActivityButtonType)activityButtonType {
    assert(activityButtonType == ActivityButtonTypeBegin || activityButtonType == ActivityButtonTypeEnd);
    [self setSubtype:(RemoteElementSubtype)activityButtonType];
}

- (ActivityButtonType)activityButtonType {
    ActivityButtonType   activityType = [self flagsWithMask:RemoteElementSubtypeMask];

    assert(activityType == ActivityButtonTypeBegin || activityType == ActivityButtonTypeEnd);

    return activityType;
}

/**
 * Calls `activityActionForButton:` on the button's remote controller before exiting the command.
 * @param options Options for the command to execute.
 * @param delegate `CommandDelegate` for the command to notify with result of execution.
 */
- (void)executeCommandWithOptions:(CommandOptions)options delegate:(id <CommandDelegate> )delegate {
// if (!(options & CommandOptionsLongPress))
    [self.controller activityActionForButton:self];

    [super executeCommandWithOptions:options delegate:delegate];
}

@end
