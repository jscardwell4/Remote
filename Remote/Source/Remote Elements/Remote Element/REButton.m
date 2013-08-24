//
// REButton.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElement_Private.h"
#import <QuartzCore/QuartzCore.h>
//#import "REControlStateSetProxy.h"

static int   ddLogLevel = DefaultDDLogLevel;
#pragma unused(ddLogLevel)

static const NSSet * kConfigurationDelegateSelectors;
static const NSSet * kConfigurationDelegateKeys;

@implementation REButton

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
#pragma mark - Object Lifecycle
////////////////////////////////////////////////////////////////////////////////

+ (void)initialize
{
    if (self == [REButton class])
    {
        kConfigurationDelegateSelectors =
            [@[NSValueWithPointer(@selector(titles)),
               NSValueWithPointer(@selector(backgroundColors)),
               NSValueWithPointer(@selector(images)),
               NSValueWithPointer(@selector(icons)),
               NSValueWithPointer(@selector(setTitle:configuration:)),
               NSValueWithPointer(@selector(setTitles:configuration:)),
               NSValueWithPointer(@selector(setIcons:configuration:)),
               NSValueWithPointer(@selector(setImages:configuration:)),
               NSValueWithPointer(@selector(setBackgroundColors:configuration:)),
               NSValueWithPointer(@selector(setCommand:configuration:))] set];
        
        kConfigurationDelegateKeys = [@[@"titles",
                                        @"icons",
                                        @"images",
                                        @"backgroundColors",
                                        @"commands"] set];
    }
}

+ (instancetype)buttonWithType:(REType)type
{
    return ((baseTypeForREType(type) == RETypeButton)
            ? [self remoteElementWithAttributes:@{@"type": @(type)}]
            : nil);
}

+ (instancetype)buttonWithType:(REType)type context:(NSManagedObjectContext *)moc
{
    return ((baseTypeForREType(type) == RETypeButton)
            ? [self remoteElementInContext:moc attributes:@{@"type": @(type)}]
            : nil);
}

+ (instancetype)buttonWithTitle:(id)title
{
    return [self remoteElementWithAttributes:@{@"title": title}];
}

+ (instancetype)buttonWithTitle:(id)title context:(NSManagedObjectContext *)moc
{
    return [self remoteElementInContext:moc attributes:@{@"title": title}];
}

+ (instancetype)buttonWithType:(REType)type title:(id)title
{
    return ((baseTypeForREType(type) == RETypeButton)
            ? [self remoteElementWithAttributes:@{@"type": @(type), @"title": title}]
            : nil);
}

+ (instancetype)buttonWithType:(REType)type title:(id)title context:(NSManagedObjectContext *)moc
{
    return ((baseTypeForREType(type) == RETypeButton)
            ? [self remoteElementInContext:moc attributes:@{@"type": @(type), @"title": title}]
            : nil);
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
    REButton * element = [self remoteElementInContext:context];
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
            [element setTitles:[REControlStateTitleSet controlStateSetInContext:context
                                                                    withObjects:@{@"normal": titleObj}]
              configuration:REDefaultConfiguration];
    }

    if (attributes[@"icon"])
    {
        [filteredAttributes removeObjectForKey:@"icon"];
        [element setIcons:[REControlStateImageSet controlStateSetInContext:context
                                                               withObjects:@{@"normal": attributes[@"icon"]}]
         configuration:REDefaultConfiguration];
    }

    if (attributes[@"image"])
    {
        [filteredAttributes removeObjectForKey:@"image"];
        [element setImages:[REControlStateImageSet controlStateSetInContext:context
                                                                withObjects:@{@"normal": attributes[@"image"]}]
          configuration:REDefaultConfiguration];
    }

    if (attributes[@"icons"])
    {
        [filteredAttributes removeObjectForKey:@"icons"];
        [element setIcons:attributes[@"icons"] configuration:REDefaultConfiguration];
    }

    [element setValuesForKeysWithDictionary:attributes];
    return element;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (MSModelObjectShouldInitialize)
        [self.managedObjectContext performBlockAndWait:
        ^{
            self.type                  = RETypeButton;
            self.configurationDelegate = [REButtonConfigurationDelegate
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
#pragma mark - Lazy Accessors
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
#pragma mark - Importing
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

- (RERemote *)remote { return (RERemote *)self.parentElement.parentElement; }

- (REButtonConfigurationDelegate *)buttonConfigurationDelegate
{
    return (REButtonConfigurationDelegate *)self.configurationDelegate;
}

- (RERemoteController *)controller
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


- (void)setCommand:(RECommand *)command
{
    [self willChangeValueForKey:@"command"];
    self.primitiveCommand = command;
    [self didChangeValueForKey:@"command"];
    
    [((REButtonConfigurationDelegate *)self.configurationDelegate) setCommand:command
                                                             configuration:REDefaultConfiguration];
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

    if (options == RECommandOptionLongPress && self.longPressCommand)
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


    MSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

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


    return dd;
}

@end

