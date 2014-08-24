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

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)


@interface Button ()

@property (nonatomic, strong, readwrite) ButtonGroup          * parentElement;
@property (nonatomic, weak,   readonly)  RemoteController     * controller;

@end

@interface Button (CoreDataGeneratedAccessors)

@property (nonatomic) Command            * primitiveCommand;
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
@dynamic parentElement, controller;
@dynamic command, longPressCommand, title, icon, image;


////////////////////////////////////////////////////////////////////////////////
#pragma mark Object Lifecycle
////////////////////////////////////////////////////////////////////////////////


+ (REType)elementType { return RETypeButton; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Creation
////////////////////////////////////////////////////////////////////////////////

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

+ (instancetype)remoteElementInContext:(NSManagedObjectContext *)moc
                            attributes:(NSDictionary *)attributes
{
    Button * element = [self remoteElementInContext:moc];
    NSMutableDictionary * filteredAttributes = [attributes mutableCopy];
    if (attributes[@"title"])
    {
        [filteredAttributes removeObjectForKey:@"title"];
        id title = attributes[@"title"];
        id titleObj = nil;
        if ([title isKindOfClass:[NSAttributedString class]])
            titleObj = [title copy];
        else if ([title isKindOfClass:[NSString class]])
            titleObj = @{RETitleTextAttributeKey: title};
        else if ([title isKindOfClass:[NSDictionary class]])
            titleObj = title;

        if (titleObj)
            [element setTitles:[ControlStateTitleSet controlStateSetInContext:moc
                                                                    withObjects:@{@"normal": titleObj}]
              mode:REDefaultMode];
    }

    if (attributes[@"icon"])
    {
        [filteredAttributes removeObjectForKey:@"icon"];
        [element setIcons:[ControlStateImageSet
                           controlStateSetInContext:moc
                                        withObjects:@{ @"normal" : attributes[@"icon"] }]
                     mode:REDefaultMode];
    }

    if (attributes[@"image"])
    {
        [filteredAttributes removeObjectForKey:@"image"];
        [element setImages:[ControlStateImageSet
                            controlStateSetInContext:moc
                                         withObjects:@{ @"normal" : attributes[@"image"] }]
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
        backgroundColor = self.backgroundColors[self.state];
        if (backgroundColor) self.primitiveBackgroundColor = backgroundColor;
    }
    return backgroundColor;
}

- (Image *)icon
{
    [self willAccessValueForKey:@"icon"];
    Image * icon = self.primitiveIcon;
    if (!icon)
    {
        ControlStateImageSet * icons = [self iconsForMode:self.currentMode];
        if (icons) self.primitiveIcon = icons[self.state];
        icon = self.primitiveIcon;
    }
    [self didAccessValueForKey:@"icon"];
    return icon;
}

- (Image *)image
{
    [self willAccessValueForKey:@"image"];
    Image * image = self.primitiveImage;
    if (!image)
    {
        ControlStateImageSet * images = [self imagesForMode:self.currentMode];
        if (images) self.primitiveImage = images[self.state];
        image = self.primitiveImage;
    }
    [self didAccessValueForKey:@"image"];

    return image;
}

- (id)title
{
    [self willAccessValueForKey:@"title"];
    id title = _title;
    [self didAccessValueForKey:@"title"];
    if (!title)
    {
        title = self.titles[self.state];
        _title = title;
    }
    return title;
}


- (void)setTitle:(id)title
{
    [self willChangeValueForKey:@"title"];
    _title = title;
    [self didChangeValueForKey:@"title"];
}

- (void)updateButtonForState:(REState)state
{
    self.command         = self.command;
    self.title           = self.titles[state];//[self titleForState:state];
    self.icon            = [self.icons UIImageForState:state];
    self.image           = [self.images UIImageForState:state];
    self.backgroundColor = self.backgroundColors[state];

}

- (void)updateForMode:(RERemoteMode)mode
{
    if (![self hasMode:mode]) return;

    self.command          = [self commandForMode:mode];
    self.titles           = [self titlesForMode:mode];
    self.icons            = [self iconsForMode:mode];
    self.images           = [self imagesForMode:mode];
    self.backgroundColors = [self backgroundColorsForMode:mode];

    [self updateButtonForState:self.state];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Commands
////////////////////////////////////////////////////////////////////////////////

- (void)setCommand:(Command *)command mode:(RERemoteMode)mode
{
    self[[@"." join:@[mode, @"command"]]] = [[command permanentURI] absoluteString];
}

- (Command *)commandForMode:(RERemoteMode)mode
{
    NSURL * uri = self[[@"." join:@[mode, @"command"]]];
    return (uri ? [self.managedObjectContext objectForURI:uri] : nil);
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
    self[[@"." join:@[mode,@"titles"]]] = titles.permanentURI;
}

- (ControlStateTitleSet *)titlesForMode:(RERemoteMode)mode
{
    NSURL * uri = self[[@"." join:@[mode,@"titles"]]];
    return (uri ? [self.managedObjectContext objectForURI:uri] : nil);
}

- (ControlStateTitleSet *)titles { return [self titlesForMode:self.currentMode]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark Background colors
////////////////////////////////////////////////////////////////////////////////

- (void)setBackgroundColors:(ControlStateColorSet *)colors mode:(RERemoteMode)mode
{
    self[[@"." join:@[mode,@"backgroundColors"]]] = colors.permanentURI;
}

- (ControlStateColorSet *)backgroundColorsForMode:(RERemoteMode)mode
{
    NSURL * uri = self[[@"." join:@[mode,@"backgroundColors"]]];
    return (uri ? [self.managedObjectContext objectForURI:uri] : nil);
}

- (ControlStateColorSet *)backgroundColors { return [self backgroundColorsForMode:self.currentMode]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark Icons
////////////////////////////////////////////////////////////////////////////////

- (void)setIcons:(ControlStateImageSet *)icons mode:(RERemoteMode)mode
{
    self[[@"." join:@[mode,@"icons"]]] = icons.permanentURI;
}

- (ControlStateImageSet *)iconsForMode:(RERemoteMode)mode
{
    NSURL * uri = self[[@"." join:@[mode,@"icons"]]];
    return (uri ? [self.managedObjectContext objectForURI:uri] : nil);
}

- (ControlStateImageSet *)icons { return [self iconsForMode:self.currentMode]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark Images
////////////////////////////////////////////////////////////////////////////////

- (void)setImages:(ControlStateImageSet *)images mode:(RERemoteMode)mode
{
    self[[@"." join:@[mode,@"images"]]] = images.permanentURI;
}

- (ControlStateImageSet *)imagesForMode:(RERemoteMode)mode
{
    NSURL * uri = self[[@"." join:@[mode,@"images"]]];
    return (uri ? [self.managedObjectContext objectForURI:uri] : nil);
}

- (ControlStateImageSet *)images { return [self imagesForMode:self.currentMode]; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
////////////////////////////////////////////////////////////////////////////////

- (Remote *)remote { return (Remote *)self.parentElement.parentElement; }

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

    [self setCommand:command mode:REDefaultMode];
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


@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark Debugging
////////////////////////////////////////////////////////////////////////////////


@implementation Button (Debugging)

- (MSDictionary *)deepDescriptionDictionary
{
    Button * element = [self faultedObject];
    assert(element);

    NSString *(^stringFromDescription)(NSString*) = ^NSString *(NSString *string)
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

    dd[@"remote"] = (element.remote ? $(@"%@(%p)", element.remote.uuid, element.remote) : @"nil");


    return (MSDictionary *)dd;
}

@end

