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

@dynamic commands, titleSets, iconSets, imageSets, backgroundColorSets;

@synthesize command = _command,
            titles = _titles,
            backgroundColors = _backgroundColors,
            icons = _icons,
            images = _images,
            kvoReceptionist = _kvoReceptionist;

+ (instancetype)delegateForRemoteElement:(Button *)element
{
    __block ButtonConfigurationDelegate * configurationDelegate = nil;
    assert(element);
    [element.managedObjectContext performBlockAndWait:
     ^{
         configurationDelegate = [self MR_createInContext:element.managedObjectContext];
         
         configurationDelegate.element = element;
     }];

    return configurationDelegate;
}

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
#pragma mark - Updating State
////////////////////////////////////////////////////////////////////////////////
- (void)updateButtonForState:(REState)state
{
    self.button.command         = self.command;
    self.button.title           = [self titleForState:state];
    self.button.icon            = [self.icons UIImageForState:state];
    self.button.image           = [self.images UIImageForState:state];
    self.button.backgroundColor = self.backgroundColors[state];

}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Updating Configurations
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
#pragma mark - Mode Members
////////////////////////////////////////////////////////////////////////////////

- (void)setCommand:(Command *)command mode:(RERemoteMode)mode
{
    Command * currentCommand = (Command *)NilSafeValue(self[$(@"%@.command", mode)]);
    if (currentCommand && currentCommand != command) [self removeCommandsObject:currentCommand];

    assert(mode);
    if (![self hasMode:mode]) [self addMode:mode];

    if (command) [self addCommandsObject:command];
    self[$(@"%@.command", mode)] = CollectionSafeValue(command.uuid);
}

- (Command *)commandForMode:(RERemoteMode)mode
{
    return (Command *)memberOfCollectionWithUUID(self.commands,
                                                 self[$(@"%@.command", mode)]);
}

- (void)setTitle:(id)title mode:(RERemoteMode)mode
{
    ControlStateTitleSet * titleSet = [ControlStateTitleSet
                                         controlStateSetInContext:self.managedObjectContext
                                                      withObjects:@{@"normal": title}];
    if (titleSet) [self setTitles:titleSet mode:mode];
}

- (void)setTitles:(ControlStateTitleSet *)titles mode:(RERemoteMode)mode
{
    assert(titles && mode);
    [self addTitleSetsObject:titles];
    self[$(@"%@.titles", mode)] = titles.uuid;
}

- (ControlStateTitleSet *)titlesForMode:(RERemoteMode)mode
{
    return (ControlStateTitleSet*)memberOfCollectionWithUUID(self.titleSets,
                                                             self[$(@"%@.titles", mode)]);
}

- (NSAttributedString *)titleForState:(REState)state
{

    NSDictionary * titleAttributes = self.titles[state];
    NSAttributedString * title = nil;
    NSString * titleText = titleAttributes[RETitleTextKey];

    if (titleText)
    {
        UIColor          * foregroundColor = titleAttributes[REForegroundColorKey];
        UIColor          * backgroundColor = titleAttributes[REBackgroundColorKey];
        NSShadow         * shadow          = titleAttributes[REShadowKey];
        UIColor          * strokeColor     = titleAttributes[REStrokeColorKey];
        NSNumber         * strokeWidth     = titleAttributes[REStrokeWidthKey];
        NSNumber         * strikethrough   = titleAttributes[REStrikethroughStyleKey];
        NSNumber         * underline       = titleAttributes[REUnderlineStyleKey];
        NSNumber         * kern            = titleAttributes[REKernKey];
        NSNumber         * ligature        = titleAttributes[RELigatureKey];
        NSString         * fontName        = titleAttributes[REFontNameKey];
        NSNumber         * fontSize        = titleAttributes[REFontSizeKey];
        NSParagraphStyle * paragraph       = titleAttributes[REParagraphStyleKey];

        NSMutableDictionary * stringAttributes = [@{} mutableCopy];
        if (foregroundColor) stringAttributes[NSForegroundColorAttributeName]    = foregroundColor;
        if (backgroundColor) stringAttributes[NSBackgroundColorAttributeName]    = backgroundColor;
        if (shadow)          stringAttributes[NSShadowAttributeName]             = shadow;
        if (strokeColor)     stringAttributes[NSStrokeColorAttributeName]        = strokeColor;
        if (strokeWidth)     stringAttributes[NSStrokeWidthAttributeName]        = strokeWidth;
        if (strikethrough)   stringAttributes[NSStrikethroughStyleAttributeName] = strikethrough;
        if (underline)       stringAttributes[NSUnderlineStyleAttributeName]     = underline;
        if (kern)            stringAttributes[NSKernAttributeName]               = kern;
        if (ligature)        stringAttributes[NSLigatureAttributeName]           = ligature;
        if (paragraph)       stringAttributes[NSParagraphStyleAttributeName]     = paragraph;
        if (fontName && fontSize)
            stringAttributes[NSFontAttributeName] = [UIFont fontWithName:fontName
                                                                    size:CGFloatValue(fontSize)];

        title = [NSAttributedString attributedStringWithString:titleText attributes:stringAttributes];
    }

    return title;
}

- (ControlStateTitleSet *)titles
{
    RERemoteMode mode = self.currentMode;
    assert(mode);
    if (![self hasMode:mode]) [self addMode:mode];
    NSString * uuid = self[$(@"%@.titles", mode)];
    if (!uuid) return nil;
    ControlStateTitleSet * titleSet = (ControlStateTitleSet *)memberOfCollectionWithUUID(self.titleSets, uuid);
    assert(titleSet);
    return titleSet;
}

- (void)setBackgroundColors:(ControlStateColorSet *)colors mode:(RERemoteMode)mode
{
    assert(colors && mode);
    [self addBackgroundColorSetsObject:colors];
    self[$(@"%@.backgroundColors", mode)] = colors.uuid;
}

- (ControlStateColorSet *)backgroundColorsForMode:(RERemoteMode)mode
{
    return (ControlStateColorSet*)memberOfCollectionWithUUID(self.backgroundColorSets,
                                                             self[$(@"%@.backgroundColors", mode)]);
}

- (ControlStateColorSet *)backgroundColors
{
    RERemoteMode mode = self.currentMode;
    assert(mode);
    if (![self hasMode:mode]) [self addMode:mode];
    NSString * uuid = self[$(@"%@.backgroundColors", mode)];
    if (!uuid) return nil;
    ControlStateColorSet * colorSet = (ControlStateColorSet *)memberOfCollectionWithUUID(self.backgroundColorSets, uuid);
    assert(colorSet);
    return colorSet;
}

- (void)setIcons:(ControlStateImageSet *)icons mode:(RERemoteMode)mode
{
    assert(icons && mode);
    [self addIconSetsObject:icons];
    self[$(@"%@.icons", mode)] = icons.uuid;
}

- (ControlStateImageSet *)iconsForMode:(RERemoteMode)mode
{
    return (ControlStateImageSet*)memberOfCollectionWithUUID(self.iconSets,
                                                             self[$(@"%@.icons", mode)]);
}

- (ControlStateImageSet *)icons
{
    RERemoteMode mode = self.currentMode;
    assert(mode);
    if (![self hasMode:mode]) return nil;
    NSString * uuid = self[$(@"%@.icons", mode)];
    if (!uuid) return nil;
    ControlStateImageSet * iconSet = (ControlStateImageSet *)memberOfCollectionWithUUID(self.iconSets, uuid);
    assert(iconSet);
    return iconSet;
}

- (void)setImages:(ControlStateImageSet *)images mode:(RERemoteMode)mode
{
    assert(images && mode);
    [self addImageSetsObject:images];
    self[$(@"%@.images",mode)] = images.uuid;
}

- (ControlStateImageSet *)imagesForMode:(RERemoteMode)mode
{
    return (ControlStateImageSet*)memberOfCollectionWithUUID(self.imageSets,
                                                             self[$(@"%@.images", mode)]);
}

- (ControlStateImageSet *)images
{
    RERemoteMode mode = self.currentMode;
    assert(mode);
    if (![self hasMode:mode]) [self addMode:mode];
    NSString * uuid = self[$(@"%@.images", mode)];
    if (!uuid) return nil;
    ControlStateImageSet * imageSet = (ControlStateImageSet *)memberOfCollectionWithUUID(self.imageSets, uuid);
    assert(imageSet);
    return imageSet;
}

@end
