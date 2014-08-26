//
// Button.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "Button.h"
#import "RemoteElement_Private.h"
#import <QuartzCore/QuartzCore.h>

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;

#pragma unused(ddLogLevel,msLogContext)


@interface Button ()

@property (nonatomic, strong, readwrite) NSAttributedString   * title;
@property (nonatomic, strong, readwrite) ImageView            * icon;
@property (nonatomic, strong, readwrite) ImageView            * image;
@property (nonatomic, strong, readwrite) ControlStateTitleSet * titles;
@property (nonatomic, strong, readwrite) ControlStateImageSet * icons;
@property (nonatomic, strong, readwrite) ControlStateColorSet * backgroundColors;
@property (nonatomic, strong, readwrite) ControlStateImageSet * images;


@end

@interface Button (CoreDataGeneratedAccessors)

@property (nonatomic) Command            * primitiveCommand;
@property (nonatomic) Command            * primitiveLongPressCommand;
@property (nonatomic) NSValue            * primitiveTitleEdgeInsets;
@property (nonatomic) NSValue            * primitiveImageEdgeInsets;
@property (nonatomic) NSValue            * primitiveContentEdgeInsets;
@property (nonatomic) NSAttributedString * primitiveTitle;
@property (nonatomic) Image              * primitiveIcon;
@property (nonatomic) Image              * primitiveImage;

@end

@implementation Button

// modeled properties
@dynamic titleEdgeInsets, contentEdgeInsets, imageEdgeInsets;
@dynamic command, longPressCommand, title, icon, image;
@dynamic titles, icons, images, backgroundColors;


+ (REType)elementType { return RETypeButton; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Creation
////////////////////////////////////////////////////////////////////////////////

+ (instancetype)buttonWithRole:(RERole)role {
  return [self remoteElementWithAttributes:@{ @"role" : @(role) }];
}

+ (instancetype)buttonWithRole:(RERole)role context:(NSManagedObjectContext *)moc {
  return [self remoteElementInContext:moc attributes:@{ @"role" : @(role) }];
}

+ (instancetype)buttonWithTitle:(id)title {
  return [self remoteElementWithAttributes:@{ @"title" : title }];
}

+ (instancetype)buttonWithTitle:(id)title context:(NSManagedObjectContext *)moc {
  return [self remoteElementInContext:moc attributes:@{ @"title" : title }];
}

+ (instancetype)buttonWithRole:(RERole)role title:(id)title {
  return [self remoteElementWithAttributes:@{ @"role" : @(role), @"title" : title }];
}

+ (instancetype)buttonWithRole:(RERole)role title:(id)title context:(NSManagedObjectContext *)moc {
  return [self remoteElementInContext:moc attributes:@{ @"role" : @(role), @"title" : title }];
}

+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)moc
                            attributes:(NSDictionary *)attributes {
  Button              * element            = [self remoteElementInContext:moc];
  NSMutableDictionary * filteredAttributes = [attributes mutableCopy];

  if (attributes[@"title"]) {
    [filteredAttributes removeObjectForKey:@"title"];
    id title    = attributes[@"title"];
    id titleObj = nil;

    if ([title isKindOfClass:[NSAttributedString class]])
      titleObj = [title copy];
    else if ([title isKindOfClass:[NSString class]])
      titleObj = @{
                   RETitleTextAttributeKey : title
                   };
    else if ([title isKindOfClass:[NSDictionary class]])
      titleObj = title;

    if (titleObj)
      [element setTitles:[ControlStateTitleSet controlStateSetInContext:moc
                                                            withObjects:@{ @"normal" : titleObj }]
                    mode:REDefaultMode];
  }

  if (attributes[@"icon"]) {
    [filteredAttributes removeObjectForKey:@"icon"];
    [element setIcons:[ControlStateImageSet
                       controlStateSetInContext:moc
                       withObjects:@{ @"normal" : attributes[@"icon"] }]
                 mode:REDefaultMode];
  }

  if (attributes[@"image"]) {
    [filteredAttributes removeObjectForKey:@"image"];
    [element setImages:[ControlStateImageSet
                        controlStateSetInContext:moc
                        withObjects:@{ @"normal" : attributes[@"image"] }]
                  mode:REDefaultMode];
  }

  if (attributes[@"icons"]) {
    [filteredAttributes removeObjectForKey:@"icons"];
    [element setIcons:attributes[@"icons"] mode:REDefaultMode];
  }

  [element setValuesForKeysWithDictionary:attributes];

  return element;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Updating configuration
////////////////////////////////////////////////////////////////////////////////


/// This method updates the non-collection attributes with values for the specified state
/// @param state description
- (void)updateButtonForState:(REState)state {
  self.title           = self.titles[state];
  self.icon            = self.icons[state];
  self.image           = self.images[state];
  self.backgroundColor = self.backgroundColors[state];

}

/// This method updates the collection attributes with values for the specified mode and then
/// calls `updateButtonForState:` to update the non-collection attributes.
/// @param mode description
- (void)updateForMode:(NSString *)mode {
  // if (![self hasMode:mode]) return;

  self.command          = [self commandForMode:mode]           ?: [self commandForMode:REDefaultMode];
  self.longPressCommand = [self longPressCommandForMode:mode]  ?: [self longPressCommandForMode:REDefaultMode];
  self.titles           = [self titlesForMode:mode]            ?: [self titlesForMode:REDefaultMode];
  self.icons            = [self iconsForMode:mode]             ?: [self iconsForMode:REDefaultMode];
  self.images           = [self imagesForMode:mode]            ?: [self imagesForMode:REDefaultMode];
  self.backgroundColors = [self backgroundColorsForMode:mode]  ?: [self backgroundColorsForMode:REDefaultMode];

  [self updateButtonForState:self.state];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configuration attributes
////////////////////////////////////////////////////////////////////////////////


#pragma mark Commands
////////////////////////////////////////////////////////////////////////////////

- (void)setCommand:(Command *)command mode:(NSString *)mode {
  self[modePropertyKey(mode, @"command")] = command.permanentURI;
}

- (Command *)commandForMode:(NSString *)mode {
  return [[self.managedObjectContext objectForURI:self[modePropertyKey(mode, @"command")]] faultedObject];
}

- (void)setLongPressCommand:(Command *)longPressCommand mode:(NSString *)mode {
  self[modePropertyKey(mode, @"longPressCommand")] = longPressCommand.permanentURI;
}

- (Command *)longPressCommandForMode:(NSString *)mode {
  return [[self.managedObjectContext objectForURI:self[modePropertyKey(mode, @"longPressCommand")]] faultedObject];
}

#pragma mark Titles
////////////////////////////////////////////////////////////////////////////////

- (void)setTitles:(ControlStateTitleSet *)titles mode:(NSString *)mode {
  self[modePropertyKey(mode, @"titles")] = titles.permanentURI;
}

- (ControlStateTitleSet *)titlesForMode:(NSString *)mode {
  return [[self.managedObjectContext objectForURI:self[modePropertyKey(mode, @"titles")]] faultedObject];
}

- (ControlStateTitleSet *)titles { return [self titlesForMode:self.currentMode]; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Background colors
////////////////////////////////////////////////////////////////////////////////


- (void)setBackgroundColors:(ControlStateColorSet *)colors mode:(NSString *)mode {
  self[modePropertyKey(mode, @"backgroundColors")] = colors.permanentURI;
}

- (ControlStateColorSet *)backgroundColorsForMode:(NSString *)mode {
  return [[self.managedObjectContext objectForURI:self[modePropertyKey(mode, @"backgroundColors")]] faultedObject];
}

- (ControlStateColorSet *)backgroundColors { return [self backgroundColorsForMode:self.currentMode]; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Icons
////////////////////////////////////////////////////////////////////////////////


- (void)setIcons:(ControlStateImageSet *)icons mode:(NSString *)mode {
  self[modePropertyKey(mode, @"icons")] = icons.permanentURI;
}

- (ControlStateImageSet *)iconsForMode:(NSString *)mode {
  return [[self.managedObjectContext objectForURI:self[modePropertyKey(mode, @"icons")]] faultedObject];
}

- (ControlStateImageSet *)icons { return [self iconsForMode:self.currentMode]; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Images
////////////////////////////////////////////////////////////////////////////////


- (void)setImages:(ControlStateImageSet *)images mode:(NSString *)mode {
  self[modePropertyKey(mode, @"images")] = images.permanentURI;
}

- (ControlStateImageSet *)imagesForMode:(NSString *)mode {
  return [[self.managedObjectContext objectForURI:self[modePropertyKey(mode, @"images")]] faultedObject];
}

- (ControlStateImageSet *)images { return [self imagesForMode:self.currentMode]; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button state
////////////////////////////////////////////////////////////////////////////////


- (BOOL)isEnabled { return !(self.state & REStateDisabled); }

- (void)setEnabled:(BOOL)enabled {
  [self willChangeValueForKey:@"enabled"];
  if (enabled) self.state &= ~REStateDisabled;
  else self.state |= REStateDisabled;
  [self didChangeValueForKey:@"enabled"];
}

- (BOOL)isHighlighted { return (self.state & REStateHighlighted); }

- (void)setHighlighted:(BOOL)highlighted {
  [self willChangeValueForKey:@"highlighted"];
  if (highlighted) self.state |= REStateHighlighted;
  else self.state &= ~REStateHighlighted;
  [self didChangeValueForKey:@"highlighted"];
}

- (BOOL)isSelected { return (self.state & REStateSelected); }

- (void)setSelected:(BOOL)selected {
  [self willChangeValueForKey:@"selected"];
  if (selected) self.state |= REStateSelected;
  else self.state &= ~REStateSelected;
  [self didChangeValueForKey:@"selected"];
}


/////////////////////////////////////////////////////////////////////////////////
#pragma mark - Insets
/////////////////////////////////////////////////////////////////////////////////


- (UIEdgeInsets)titleEdgeInsets {
  [self willAccessValueForKey:@"titleEdgeInsets"];
  UIEdgeInsets insets = UIEdgeInsetsValue(self.primitiveTitleEdgeInsets);
  [self didAccessValueForKey:@"titleEdgeInsets"];
  return insets;
}

- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
  [self willChangeValueForKey:@"titleEdgeInsets"];
  self.primitiveTitleEdgeInsets = NSValueWithUIEdgeInsets(titleEdgeInsets);
  [self didChangeValueForKey:@"titleEdgeInsets"];
}

- (UIEdgeInsets)imageEdgeInsets {
  [self willAccessValueForKey:@"imageEdgeInsets"];
  UIEdgeInsets insets = UIEdgeInsetsValue(self.primitiveImageEdgeInsets);
  [self didAccessValueForKey:@"imageEdgeInsets"];
  return insets;
}

- (void)setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets {
  [self willChangeValueForKey:@"imageEdgeInsets"];
  self.primitiveImageEdgeInsets = NSValueWithUIEdgeInsets(imageEdgeInsets);
  [self didChangeValueForKey:@"imageEdgeInsets"];
}

- (UIEdgeInsets)contentEdgeInsets {
  [self willAccessValueForKey:@"contentEdgeInsets"];
  UIEdgeInsets insets = UIEdgeInsetsValue(self.primitiveContentEdgeInsets);

  [self didAccessValueForKey:@"contentEdgeInsets"];

  return insets;
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
  [self willChangeValueForKey:@"contentEdgeInsets"];
  self.primitiveContentEdgeInsets = NSValueWithUIEdgeInsets(contentEdgeInsets);
  [self didChangeValueForKey:@"contentEdgeInsets"];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Command execution
////////////////////////////////////////////////////////////////////////////////


- (void)executeCommandWithOptions:(CommandOptions)options
                       completion:(CommandCompletionHandler)completion {

  if (options == CommandOptionLongPress && self.longPressCommand) [self.longPressCommand execute:completion];
  else if (self.command) [self.command execute:completion];
  else if (completion) completion(YES, NO);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////


- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

  NSDictionary * titles            = data[@"titles"];
  NSDictionary * commands          = data[@"commands"];
  NSDictionary * longPressCommands = data[@"long-press-commands"];
  NSDictionary * icons             = data[@"icons"];
  NSDictionary * images            = data[@"images"];
  NSDictionary * backgroundColors  = data[@"background-colors"];
  NSString     * titleEdgeInsets   = data[@"title-edge-insets"];
  NSString     * contentEdgeInsets = data[@"content-edge-insets"];
  NSString     * imageEdgeInsets   = data[@"image-edge-insets"];
  NSManagedObjectContext * moc = self.managedObjectContext;

  if (titles) {
    for (NSString * mode in titles) {
      ControlStateTitleSet * titleSet = [self titlesForMode:mode];
      if (titleSet) { [moc deleteObject:titleSet]; titleSet = nil; }
      titleSet = [ControlStateTitleSet importObjectFromData:titles[mode] context:moc];
      if (titleSet) [self setTitles:titleSet mode:mode];
    }
  }

  if (icons) {
    for (NSString * mode in icons) {
      ControlStateImageSet * iconSet = [self iconsForMode:mode];
      if (iconSet) { [moc deleteObject:iconSet]; iconSet = nil; }
      iconSet = [ControlStateImageSet importObjectFromData:icons[mode] context:moc];
      if (iconSet) [self setIcons:iconSet mode:mode];
    }
  }

  if (images) {
    for (NSString * mode in images) {
      ControlStateImageSet * imageSet = [self imagesForMode:mode];
      if (imageSet) { [moc deleteObject:imageSet]; imageSet = nil; }
      imageSet = [ControlStateImageSet importObjectFromData:images[mode] context:moc];
      if (imageSet) [self setImages:imageSet mode:mode];
    }
  }

  if (backgroundColors) {
    for (NSString * mode in backgroundColors) {
      ControlStateColorSet * colorSet = [self backgroundColorsForMode:mode];
      if (colorSet) { [moc deleteObject:colorSet]; colorSet = nil; }
      colorSet = [ControlStateColorSet importObjectFromData:backgroundColors[mode]
                                                  context:moc];
      if (colorSet) [self setBackgroundColors:colorSet mode:mode];
    }
  }

  if (commands) {
    for (NSString * mode in commands) {
      Command * command = [Command importObjectFromData:commands[mode] context:moc];
      if (command) [self setCommand:command mode:mode];
    }
  }

  if (longPressCommands) {
    for (NSString * mode in longPressCommands) {
      Command * longPressCommand = [Command importObjectFromData:longPressCommands[mode] context:moc];
      if (longPressCommand) [self setCommand:longPressCommand mode:mode];
    }
  }

  if (titleEdgeInsets)   self.titleEdgeInsets   = UIEdgeInsetsFromString(titleEdgeInsets);
  if (contentEdgeInsets) self.contentEdgeInsets = UIEdgeInsetsFromString(contentEdgeInsets);
  if (imageEdgeInsets)   self.imageEdgeInsets   = UIEdgeInsetsFromString(imageEdgeInsets);

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////


- (MSDictionary *)JSONDictionary
{
  MSDictionary * dictionary = [super JSONDictionary];
  dictionary[@"background-color"] = NullObject;

  NSArray * configurations = self.modes;

  MSDictionary * titles            = [MSDictionary dictionary];
  MSDictionary * backgroundColors  = [MSDictionary dictionary];
  MSDictionary * icons             = [MSDictionary dictionary];
  MSDictionary * images            = [MSDictionary dictionary];
  MSDictionary * commands          = [MSDictionary dictionary];
  MSDictionary * longPressCommands = [MSDictionary dictionary];

  for (NSString * mode in configurations)
  {
    ControlStateSet * stateSet = [self titlesForMode:mode];
    if (stateSet && ![stateSet isEmptySet]) titles[mode] = [stateSet JSONDictionary];

    stateSet = [self backgroundColorsForMode:mode];
    if (stateSet && ![stateSet isEmptySet]) backgroundColors[mode] = [stateSet JSONDictionary];

    stateSet = [self iconsForMode:mode];
    if (stateSet && ![stateSet isEmptySet]) icons[mode] = [stateSet JSONDictionary];

    stateSet = [self imagesForMode:mode];
    if (stateSet && ![stateSet isEmptySet]) images[mode] = [stateSet JSONDictionary];

    Command * command = [self commandForMode:mode];
    if (command) commands[mode] = [command JSONDictionary];

    Command * longPressCommand = [self longPressCommandForMode:mode];
    if (longPressCommand) longPressCommands[mode] = [longPressCommand JSONDictionary];
  }

  dictionary[@"commands"]           = ([commands count] ? commands : NullObject);
  dictionary[@"titles"]             = ([titles count] ? titles : NullObject) ;
  dictionary[@"icons"]              = ([icons count] ? icons : NullObject);
  dictionary[@"background-colors"]  = ([backgroundColors count] ? backgroundColors : NullObject);
  dictionary[@"images"]             = ([images count] ? images : NullObject);

  if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.titleEdgeInsets))
    dictionary[@"title-edge-insets"] = NSStringFromUIEdgeInsets(self.titleEdgeInsets);

  if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.imageEdgeInsets))
    dictionary[@"image-edge-insets"] = NSStringFromUIEdgeInsets(self.imageEdgeInsets);

  if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.contentEdgeInsets))
    dictionary[@"content-edge-insets"] = NSStringFromUIEdgeInsets(self.contentEdgeInsets);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Debugging
////////////////////////////////////////////////////////////////////////////////


- (MSDictionary *)deepDescriptionDictionary {
  Button * element = [self faultedObject];

  assert(element);

  NSString *(^stringFromDescription)(NSString *) = ^NSString *(NSString * string)
  {
    if (StringIsEmpty(string)) return @"nil";
    else return [string stringByShiftingLeft:4];
  };

  MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

  dd[@"titles"]            = stringFromDescription([element.titles deepDescription]);
  dd[@"icons"]             = stringFromDescription([element.icons deepDescription]);
  dd[@"backgroundColors"]  = stringFromDescription([element.backgroundColors deepDescription]);
  dd[@"images"]            = stringFromDescription([element.images deepDescription]);
  dd[@"command"]           = stringFromDescription([element.command deepDescription]);
  dd[@"longPressCommand"]  = stringFromDescription([element.longPressCommand deepDescription]);
  dd[@"titleEdgeInsets"]   = UIEdgeInsetsString(element.titleEdgeInsets);
  dd[@"imageEdgeInsets"]   = UIEdgeInsetsString(element.imageEdgeInsets);
  dd[@"contentEdgeInsets"] = UIEdgeInsetsString(element.contentEdgeInsets);


  return (MSDictionary *)dd;
}

@end
