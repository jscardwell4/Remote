//
// REButtonConfigurationDelegate.m
// Remote
//
// Created by Jason Cardwell on 7/11/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "REConfigurationDelegate_Private.h"
#import "REControlStateSet.h"
#import "RECommand.h"

@implementation REButtonConfigurationDelegate

@dynamic commands, titleSets, iconSets, imageSets, backgroundColorSets;

@synthesize command = _command,
            titles = _titles,
            backgroundColors = _backgroundColors,
            icons = _icons,
            images = _images,
            kvoReceptionist = _kvoReceptionist;

+ (instancetype)delegateForRemoteElement:(REButton *)element
{
    __block REButtonConfigurationDelegate * configurationDelegate = nil;
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
                                    REButtonConfigurationDelegate * delegate =
                                        (__bridge REButtonConfigurationDelegate*)context;
                                    [delegate.managedObjectContext performBlock:
                                     ^{
                                         [delegate updateButtonForState: ((REButton*)object).state];
                                     }];
                                }];
}


- (REButton *)button { return (REButton *)self.element; }

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
- (void)updateForConfiguration:(RERemoteConfiguration)configuration
{
    if (![self hasConfiguration:configuration]) return;

    self.command = (RECommand *)memberOfCollectionWithUUID(self.commands,
                                                           self[$(@"%@.command",
                                                                  configuration)]);

    self.titles =
        (REControlStateTitleSet*)memberOfCollectionWithUUID(self.titleSets,
                                                            self[$(@"%@.titles",
                                                                   configuration)]);

    self.icons =
        (REControlStateImageSet*)memberOfCollectionWithUUID(self.iconSets,
                                                            self[$(@"%@.icons",
                                                                   configuration)]);

    self.images =
        (REControlStateImageSet*)memberOfCollectionWithUUID(self.imageSets,
                                                            self[$(@"%@.images",
                                                                   configuration)]);

    self.backgroundColors =
        (REControlStateColorSet*)memberOfCollectionWithUUID(self.backgroundColorSets,
                                                            self[$(@"%@.backgroundColors",
                                                                   configuration)]);
    [self updateButtonForState:self.button.state];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configuration Members
////////////////////////////////////////////////////////////////////////////////

- (void)setCommand:(RECommand *)command configuration:(RERemoteConfiguration)config
{
    RECommand * currentCommand = (RECommand *)NilSafeValue(self[$(@"%@.command", config)]);
    if (currentCommand && currentCommand != command) [self removeCommandsObject:currentCommand];

    assert(config);
    if (![self hasConfiguration:config]) [self addConfiguration:config];

    if (command) [self addCommandsObject:command];
    self[$(@"%@.command", config)] = CollectionSafeValue(command.uuid);
}

- (void)setTitle:(id)title configuration:(RERemoteConfiguration)config
{
    REControlStateTitleSet * titleSet = [REControlStateTitleSet
                                         controlStateSetInContext:self.managedObjectContext
                                                      withObjects:@{@"normal": title}];
    if (titleSet) [self setTitles:titleSet configuration:config];
}

- (void)setTitles:(REControlStateTitleSet *)titles configuration:(RERemoteConfiguration)config
{
    assert(titles && config);
    [self addTitleSetsObject:titles];
    self[$(@"%@.titles", config)] = titles.uuid;
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

- (REControlStateTitleSet *)titles
{
    RERemoteConfiguration config = self.currentConfiguration;
    assert(config);
    if (![self hasConfiguration:config]) [self addConfiguration:config];
    NSString * uuid = self[$(@"%@.titles", config)];
    if (!uuid) return nil;
    REControlStateTitleSet * titleSet = (REControlStateTitleSet *)memberOfCollectionWithUUID(self.titleSets, uuid);
    assert(titleSet);
    return titleSet;
}

- (void)setBackgroundColors:(REControlStateColorSet *)colors configuration:(RERemoteConfiguration)config
{
    assert(colors && config);
    [self addBackgroundColorSetsObject:colors];
    self[$(@"%@.backgroundColors", config)] = colors.uuid;
}

- (REControlStateColorSet *)backgroundColors
{
    RERemoteConfiguration config = self.currentConfiguration;
    assert(config);
    if (![self hasConfiguration:config]) [self addConfiguration:config];
    NSString * uuid = self[$(@"%@.backgroundColors", config)];
    if (!uuid) return nil;
    REControlStateColorSet * colorSet = (REControlStateColorSet *)memberOfCollectionWithUUID(self.backgroundColorSets, uuid);
    assert(colorSet);
    return colorSet;
}

- (void)setIcons:(REControlStateImageSet *)icons configuration:(RERemoteConfiguration)config
{
    assert(icons && config);
    [self addIconSetsObject:icons];
    self[$(@"%@.icons", config)] = icons.uuid;
}

- (REControlStateImageSet *)icons
{
    RERemoteConfiguration config = self.currentConfiguration;
    assert(config);
    if (![self hasConfiguration:config]) return nil;
    NSString * uuid = self[$(@"%@.icons", config)];
    if (!uuid) return nil;
    REControlStateImageSet * iconSet = (REControlStateImageSet *)memberOfCollectionWithUUID(self.iconSets, uuid);
    assert(iconSet);
    return iconSet;
}

- (void)setImages:(REControlStateImageSet *)images configuration:(RERemoteConfiguration)config
{
    assert(images && config);
    [self addImageSetsObject:images];
    self[$(@"%@.images",config)] = images.uuid;
}

- (REControlStateImageSet *)images
{
    RERemoteConfiguration config = self.currentConfiguration;
    assert(config);
    if (![self hasConfiguration:config]) [self addConfiguration:config];
    NSString * uuid = self[$(@"%@.images", config)];
    if (!uuid) return nil;
    REControlStateImageSet * imageSet = (REControlStateImageSet *)memberOfCollectionWithUUID(self.imageSets, uuid);
    assert(imageSet);
    return imageSet;
}

@end
