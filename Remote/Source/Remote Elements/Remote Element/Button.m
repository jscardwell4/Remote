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

static int ddLogLevel = DefaultDDLogLevel;
#pragma unused(ddLogLevel)

static const NSSet * kConfigurationDelegateSelectors;
static const NSSet * kConfigurationDelegateKeys;

@implementation Button

// modeled properties
@dynamic titleEdgeInsets,
         contentEdgeInsets,
         parentElement,
         imageEdgeInsets,
         command,
         longPressCommand,
         controller;

@synthesize title = _title,
            icon = _icon,
            image = _image;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Object Lifecycle
////////////////////////////////////////////////////////////////////////////////

+ (void)initialize
{
    if (self == [Button class])
    {
        kConfigurationDelegateSelectors =
            [@[NSValueWithPointer(@selector(commands)),
               NSValueWithPointer(@selector(titles)),
               NSValueWithPointer(@selector(backgroundColors)),
               NSValueWithPointer(@selector(images)),
               NSValueWithPointer(@selector(icons)),
               NSValueWithPointer(@selector(setTitle:mode:)),
               NSValueWithPointer(@selector(setTitles:mode:)),
               NSValueWithPointer(@selector(setIcons:mode:)),
               NSValueWithPointer(@selector(setImages:mode:)),
               NSValueWithPointer(@selector(setBackgroundColors:mode:)),
               NSValueWithPointer(@selector(setCommand:mode:))] set];
        
        kConfigurationDelegateKeys = [@[@"titles",
                                        @"icons",
                                        @"images",
                                        @"backgroundColors",
                                        @"commands"] set];
    }
}

+ (instancetype)buttonWithRole:(RERole)role
{
    return [self remoteElementWithAttributes:@{@"role": @(role)}];
}

+ (instancetype)buttonWithRole:(RERole)role context:(NSManagedObjectContext *)moc
{
    return [self remoteElementInContext:moc attributes:@{@"role": @(role)}];
}

+ (instancetype)buttonWithTitle:(id)title
{
    return [self remoteElementWithAttributes:@{@"title": title}];
}

+ (instancetype)buttonWithTitle:(id)title context:(NSManagedObjectContext *)moc
{
    return [self remoteElementInContext:moc attributes:@{@"title": title}];
}

+ (instancetype)buttonWithRole:(RERole)role title:(id)title
{
    return [self remoteElementWithAttributes:@{@"role": @(role), @"title": title}];
}

+ (instancetype)buttonWithRole:(RERole)role title:(id)title context:(NSManagedObjectContext *)moc
{
    return [self remoteElementInContext:moc attributes:@{@"role": @(role), @"title": title}];
}

- (id)forwardingTargetForSelector:(SEL)selector
{
    if ([kConfigurationDelegateSelectors containsObject:NSValueWithPointer(selector)])
        return self.configurationDelegate;
    else
        return [super forwardingTargetForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSValue * selector = NSValueWithPointer(invocation.selector);
    if ([kConfigurationDelegateSelectors containsObject:selector])
        [invocation invokeWithTarget:self.configurationDelegate];

    else
        [super forwardInvocation:invocation];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    if ([kConfigurationDelegateKeys containsObject:key])
        return [self.configurationDelegate valueForKey:key];

    else
        return [super valueForUndefinedKey:key];
}

+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)context
                        attributes:(NSDictionary *)attributes
{
    Button * element = [self remoteElementInContext:context];
    NSMutableDictionary * filteredAttributes = [attributes mutableCopy];
    if (attributes[@"title"])
    {
        [filteredAttributes removeObjectForKey:@"title"];
        id title = attributes[@"title"];
        id titleObj = nil;
        if ([title isKindOfClass:[NSAttributedString class]])
            titleObj = [title copy];
        else if ([title isKindOfClass:[NSString class]])
            titleObj = @{RETitleTextKey: title};
        else if ([title isKindOfClass:[NSDictionary class]])
            titleObj = title;

        if (titleObj)
            [element setTitles:[ControlStateTitleSet controlStateSetInContext:context
                                                                    withObjects:@{@"normal": titleObj}]
              mode:REDefaultMode];
    }

    if (attributes[@"icon"])
    {
        [filteredAttributes removeObjectForKey:@"icon"];
        [element setIcons:[ControlStateImageSet controlStateSetInContext:context
                                                               withObjects:@{@"normal": attributes[@"icon"]}]
         mode:REDefaultMode];
    }

    if (attributes[@"image"])
    {
        [filteredAttributes removeObjectForKey:@"image"];
        [element setImages:[ControlStateImageSet controlStateSetInContext:context
                                                                withObjects:@{@"normal": attributes[@"image"]}]
          mode:REDefaultMode];
    }

    if (attributes[@"icons"])
    {
        [filteredAttributes removeObjectForKey:@"icons"];
        [element setIcons:attributes[@"icons"] mode:REDefaultMode];
    }

    [element setValuesForKeysWithDictionary:attributes];
    return element;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (ModelObjectShouldInitialize)
        [self.managedObjectContext performBlockAndWait:
        ^{
            self.elementType                  = RETypeButton;
            self.configurationDelegate = [ButtonConfigurationDelegate
                                          delegateForRemoteElement:self];
        }];
}

/*
- (void)awakeFromFetch
{
    [super awakeFromFetch];
    REState                         state    = self.state;
    REButtonConfigurationDelegate * delegate = self.buttonConfigurationDelegate;
    
    self.primitiveBackgroundColor = delegate.backgroundColors[state];
    _icon                         = [delegate.icons UIImageForState:state];
    _image                        = [delegate.images UIImageForState:state];
    _title                        = delegate.titles[state];
}
*/

////////////////////////////////////////////////////////////////////////////////
#pragma mark Lazy Accessors
////////////////////////////////////////////////////////////////////////////////

- (UIColor *)backgroundColor
{
    [self willAccessValueForKey:@"backgroundColor"];
    UIColor * backgroundColor = self.primitiveBackgroundColor;
    [self didAccessValueForKey:@"backgroundColor"];
    if (!backgroundColor)
    {
        backgroundColor = self.buttonConfigurationDelegate.backgroundColors[self.state];
        if (backgroundColor) self.primitiveBackgroundColor = backgroundColor;
    }
    return backgroundColor;
}

- (UIImage *)icon
{
    [self willAccessValueForKey:@"icon"];
    UIImage * icon = _icon;
    [self didAccessValueForKey:@"icon"];
    if (!icon)
    {
        icon = [self.buttonConfigurationDelegate.icons UIImageForState:self.state];
        _icon = icon;
    }
    return icon;
}

- (UIImage *)image
{
    [self willAccessValueForKey:@"image"];
    UIImage * image = _icon;
    [self didAccessValueForKey:@"image"];
    if (!image)
    {
        image = [self.buttonConfigurationDelegate.images UIImageForState:self.state];
        _icon = image;
    }
    return image;
}

- (id)title
{
    [self willAccessValueForKey:@"title"];
    id title = _title;
    [self didAccessValueForKey:@"title"];
    if (!title)
    {
        title = [self.buttonConfigurationDelegate titleForState:self.state];
        _title = title;
    }
    return title;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////

- (BOOL)importTitles:(NSDictionary *)data
{
    return YES;
}

- (BOOL)importIcons:(NSDictionary *)data
{
    return YES;
}

- (BOOL)importImages:(NSDictionary *)data
{
    return YES;
}

- (BOOL)importBackgroundColors:(NSDictionary *)data
{
    return YES;
}

- (BOOL)importCommand:(NSDictionary *)data
{
    return YES;
}

- (BOOL)importLongPressCommand:(NSDictionary *)data
{
    return YES;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
////////////////////////////////////////////////////////////////////////////////

- (Remote *)remote { return (Remote *)self.parentElement.parentElement; }

- (ButtonConfigurationDelegate *)buttonConfigurationDelegate
{
    return (ButtonConfigurationDelegate *)self.configurationDelegate;
}

- (RemoteController *)controller
{
    return (self.parentElement ? self.parentElement.controller : nil);
}

- (BOOL)isEnabled { return !(self.state & REStateDisabled); }

- (void)setEnabled:(BOOL)enabled
{
    [self willChangeValueForKey:@"enabled"];
    if (enabled) self.state &= ~REStateDisabled;
    else         self.state |= REStateDisabled;
    [self didChangeValueForKey:@"enabled"];
}

- (BOOL)isHighlighted { return (self.state & REStateHighlighted); }

- (void)setHighlighted:(BOOL)highlighted
{
    [self willChangeValueForKey:@"highlighted"];
    if (highlighted) self.state |= REStateHighlighted;
    else             self.state &= ~REStateHighlighted;
    [self didChangeValueForKey:@"highlighted"];
}

- (BOOL)isSelected { return (self.state & REStateSelected); }

- (void)setSelected:(BOOL)selected
{
    [self willChangeValueForKey:@"selected"];
    if (selected) self.state |= REStateSelected;
    else          self.state &= ~REStateSelected;
    [self didChangeValueForKey:@"selected"];
}


- (void)setCommand:(Command *)command
{
    [self willChangeValueForKey:@"command"];
    self.primitiveCommand = command;
    [self didChangeValueForKey:@"command"];
    
    [((ButtonConfigurationDelegate *)self.configurationDelegate) setCommand:command
                                                             mode:REDefaultMode];
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

- (void)executeCommandWithOptions:(CommandOptions)options
                       completion:(CommandCompletionHandler)completion
{

    if (options == CommandOptionLongPress && self.longPressCommand)
        [self.longPressCommand execute:completion];

    else if (self.command) [self.command execute:completion];

    else if (completion) completion(YES, NO);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////


- (NSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [[super JSONDictionary] mutableCopy];

    ButtonConfigurationDelegate * delegate = (ButtonConfigurationDelegate *)self.configurationDelegate;
    NSArray * configurations = delegate.modeKeys;
    
    MSDictionary * titles           = [MSDictionary dictionary];
    MSDictionary * backgroundColors = [MSDictionary dictionary];
    MSDictionary * icons            = [MSDictionary dictionary];
    MSDictionary * images           = [MSDictionary dictionary];
    MSDictionary * commands         = [MSDictionary dictionary];

    for (RERemoteMode mode in configurations)
    {
        ControlStateSet * stateSet = [delegate titlesForMode:mode];
        if (stateSet && ![stateSet isEmptySet]) titles[mode] = [stateSet JSONDictionary];

        stateSet = [delegate backgroundColorsForMode:mode];
        if (stateSet && ![stateSet isEmptySet]) backgroundColors[mode] = [stateSet JSONDictionary];

        stateSet = [delegate iconsForMode:mode];
        if (stateSet && ![stateSet isEmptySet]) icons[mode] = [stateSet JSONDictionary];

        stateSet = [delegate imagesForMode:mode];
        if (stateSet && ![stateSet isEmptySet]) images[mode] = [stateSet JSONDictionary];

        Command * command = [delegate commandForMode:mode];
        if (command) commands[mode] = [command JSONDictionary];

    }

    dictionary[@"commands"] = ([commands count] ? commands : NullObject);
    dictionary[@"titles"] = ([titles count] ? titles : NullObject) ;
    dictionary[@"icons"] = ([icons count] ? icons : NullObject);
    dictionary[@"backgroundColors"]  = ([backgroundColors count] ? backgroundColors : NullObject);
    dictionary[@"images"] = ([images count] ? images : NullObject);

    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.titleEdgeInsets))
        dictionary[@"titleEdgeInsets"]   = NSStringFromUIEdgeInsets(self.titleEdgeInsets);

    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.imageEdgeInsets))
        dictionary[@"imageEdgeInsets"]   = NSStringFromUIEdgeInsets(self.imageEdgeInsets);

    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.contentEdgeInsets))
        dictionary[@"contentEdgeInsets"] = NSStringFromUIEdgeInsets(self.contentEdgeInsets);

    [dictionary removeKeysWithNullObjectValues];

    return dictionary;
}
@end

@implementation Button (Debugging)

- (MSDictionary *)deepDescriptionDictionary
{
    Button * element = [self faultedObject];
    assert(element);


    MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

    dd[@"titles"] = (element.titles
                                        ? $(@"%@(%p)\n%@", element.titles.uuid, element.titles, [element.titles deepDescription])
                                        : @"nil");

    dd[@"icons"] = (element.icons
                                       ? $(@"%@(%p)\n%@", element.icons.uuid, element.icons, [element.icons deepDescription])
                                       : @"nil");

    dd[@"backgroundColors"] = (element.backgroundColors
                                                  ? $(@"%@(%p)\n%@",
                                                      element.backgroundColors.uuid,
                                                      element.backgroundColors,
                                                      [element.backgroundColors deepDescription])
                                                  : @"nil");

    dd[@"images"] = (element.images
                                        ? $(@"%@(%p)\n%@",
                                            element.images.uuid,
                                            element.images,
                                            [element.images deepDescription])
                                        : @"nil");

    dd[@"command"] = (element.command
                                         ? $(@"%@(%p)-%@",
                                             element.command.uuid,
                                             element.command,
                                             [element.command shortDescription])
                                         : @"nil");

    dd[@"longPressCommand"] = (element.longPressCommand
                                         ? $(@"%@(%p)-%@",
                                             element.longPressCommand.uuid,
                                             element.longPressCommand,
                                             [element.longPressCommand shortDescription])
                                         : @"nil");

    dd[@"titleEdgeInsets"  ] = UIEdgeInsetsString(element.titleEdgeInsets  );
    dd[@"imageEdgeInsets"  ] = UIEdgeInsetsString(element.imageEdgeInsets  );
    dd[@"contentEdgeInsets"] = UIEdgeInsetsString(element.contentEdgeInsets);

    dd[@"remote"] = (element.remote
                                        ? $(@"%@(%p)", element.remote.uuid, element.remote)
                                        : @"nil");


    return (MSDictionary *)dd;
}

@end

