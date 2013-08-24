//
//  RETheme+ApplyingThemes.m
//  Remote
//
//  Created by Jason Cardwell on 4/9/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RETheme_Private.h"
#import "RemoteElement.h"

@implementation RETheme (ApplyingThemes)

////////////////////////////////////////////////////////////////////////////////
#pragma mark Helper Methods
////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)themedAttributesFromAttributes:(NSDictionary *)attributes
                              templateAttributes:(NSDictionary *)templateAttributes
                                           flags:(REThemeFlags)flags
{
    NSString * stringText = attributes[RETitleTextKey];
    if (!stringText) return nil;

    NSMutableDictionary * themeAttributes = [templateAttributes mutableCopy];

    // foreground color?
    if (flags & REThemeNoTitleForegroundColor)
    {
        [themeAttributes removeObjectForKey:REForegroundColorKey];
        UIColor * foregroundColor = attributes[REForegroundColorKey];
        if (foregroundColor) themeAttributes[REForegroundColorKey] = foregroundColor;
    }

    // background color?
    if (flags & REThemeNoTitleBackgroundColor)
    {
        [themeAttributes removeObjectForKey:REBackgroundColorKey];
        UIColor * backgroundColor = attributes[REBackgroundColorKey];
        if (backgroundColor) themeAttributes[REBackgroundColorKey] = backgroundColor;
    }

    // shadow color?
    if (flags & REThemeNoTitleShadowColor)
    {
        [themeAttributes removeObjectForKey:REShadowKey];
        NSShadow * shadow = attributes[REShadowKey];
        if (shadow) themeAttributes[REShadowKey] = shadow;
    }

    // stroke color?
    if (flags & REThemeNoTitleStrokeColor)
    {
        [themeAttributes removeObjectForKey:REStrokeColorKey];
        UIColor * strokeColor = attributes[REStrokeColorKey];
        if (strokeColor) themeAttributes[REStrokeColorKey] = strokeColor;
    }

    // font name?
    if (flags & REThemeNoFontName)
    {
        [themeAttributes removeObjectForKey:REFontNameKey];
        NSString * fontName = attributes[REFontNameKey];
        if (fontName) themeAttributes[REFontNameKey] = fontName;
    }

    // font size?
    if (flags & REThemeNoFontSize)
    {
        [themeAttributes removeObjectForKey:REFontSizeKey];
        NSNumber * fontSize = attributes[REFontSizeKey];
        if (fontSize) themeAttributes[REFontSizeKey] = fontSize;
    }

    // stroke width?
    if (flags & REThemeNoStrokeWidth)
    {
        [themeAttributes removeObjectForKey:REStrokeWidthKey];
        NSNumber * strokeWidth = attributes[REStrokeWidthKey];
        if (strokeWidth) themeAttributes[REStrokeWidthKey] = strokeWidth;
    }

    // strikethrough?
    if (flags & REThemeNoStrikethrough)
    {
        [themeAttributes removeObjectForKey:REStrikethroughStyleKey];
        NSNumber * strikethrough = attributes[REStrikethroughStyleKey];
        if (strikethrough) themeAttributes[REStrikethroughStyleKey] = strikethrough;
    }

    // underline?
    if (flags & REThemeNoUnderline)
    {
        [themeAttributes removeObjectForKey:REUnderlineStyleKey];
        NSNumber * underline = attributes[REUnderlineStyleKey];
        if (underline) themeAttributes[REUnderlineStyleKey] = underline;
    }

    // ligature?
    if (flags & REThemeNoLigature)
    {
        [themeAttributes removeObjectForKey:RELigatureKey];
        NSNumber * ligature = attributes[RELigatureKey];
        if (ligature) themeAttributes[RELigatureKey] = ligature;
    }

    // kern?
    if (flags & REThemeNoKern)
    {
        [themeAttributes removeObjectForKey:REKernKey];
        NSNumber * kern = attributes[REKernKey];
        if (kern) themeAttributes[REKernKey] = kern;
    }

    // paragraph style?
    if (flags & REThemeNoParagraphStyle)
    {
        [themeAttributes removeObjectForKey:REParagraphStyleKey];
        NSParagraphStyle * paragraphStyle = attributes[REParagraphStyleKey];
        if (paragraphStyle) themeAttributes[REParagraphStyleKey] = paragraphStyle;
    }

    if (!themeAttributes[RETitleTextKey] && attributes[RETitleTextKey])
    {
        themeAttributes[RETitleTextKey] = attributes[RETitleTextKey];
    }

    else if (flags & REThemeNoTitleText)
    {
        [themeAttributes removeObjectForKey:RETitleTextKey];
        NSString * titleText = attributes[RETitleTextKey];
        if (titleText) themeAttributes[RETitleTextKey] = titleText;
    }

    return themeAttributes;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Applying Theme to Elements
////////////////////////////////////////////////////////////////////////////////
- (void)applyThemeToElement:(RemoteElement *)element
{
    switch ((element.type & RETypeBaseMask))
    {
        case RETypeRemote:      [self applyThemeToRemote:(RERemote *)element];           break;
        case RETypeButtonGroup: [self applyThemeToButtonGroup:(REButtonGroup *)element]; break;
        case RETypeButton:      [self applyThemeToButton:(REButton *)element];           break;
        default:                assert(NO);                                              break;
    }

    [self addElementsObject:element];

    [self applyThemeToElements:[element.subelements set]];
}

- (void)applyThemeToElements:(NSSet *)elements
{
    for (RemoteElement * element in elements)
        [self applyThemeToElement:element];
}
//TODO: Apply to all configurations

////////////////////////////////////////////////////////////////////////////////
#pragma mark Applying Theme to a Remote
////////////////////////////////////////////////////////////////////////////////
- (void)applyThemeToRemote:(RERemote *)remote
{
    NSManagedObjectContext * moc = remote.managedObjectContext;

    [moc performBlockAndWait:
     ^{
         REThemeFlags flags = remote.themeFlags;
         REThemeRemoteSettings * settings = [self remoteSettingsForType:remote.type];

         if (!settings) return;

         BOImage * backgroundImage = settings.backgroundImage;
         NSNumber * backgroundImageAlpha = settings.backgroundImageAlpha;
         UIColor * backgroundColor = settings.backgroundColor;

         // background color
         if (!(flags & REThemeNoBackgroundColor) && backgroundColor)
             remote.backgroundColor = backgroundColor;

         // background image
         if (!(flags & REThemeNoBackgroundImage) && backgroundImage)
             remote.backgroundImage = backgroundImage;

         if (!(flags & REThemeNoBackgroundImageAlpha) && backgroundImageAlpha)
             remote.backgroundImageAlpha = [backgroundImageAlpha floatValue];
     }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Applying Theme to a Button Group
////////////////////////////////////////////////////////////////////////////////
- (void)applyThemeToButtonGroup:(REButtonGroup *)buttonGroup
{
    NSManagedObjectContext * moc = buttonGroup.managedObjectContext;

    [moc performBlockAndWait:
     ^{
         REThemeFlags flags = buttonGroup.themeFlags;
         REThemeButtonGroupSettings * defaultSettings = [self buttonGroupSettingsForType:RETypeButtonGroup];
         REThemeButtonGroupSettings * panelSettings = ([buttonGroup isPanel]
                                                       ? [self buttonGroupSettingsForType:REButtonGroupTypePanel]
                                                       : nil);
         REThemeButtonGroupSettings * settings = [self buttonGroupSettingsForType:buttonGroup.type];
         if (!(settings || panelSettings)) return;

         NSNumber * style = (settings.style
                             ?: (panelSettings.style
                                 ?: defaultSettings.style));
         NSNumber * shape = (settings.shape
                             ?: (panelSettings.shape
                                 ?: defaultSettings.shape));
         BOImage * backgroundImage = (settings.backgroundImage
                                                ?: (panelSettings.backgroundImage
                                                    ?: defaultSettings.backgroundImage));
         NSNumber * backgroundImageAlpha = (settings.backgroundImageAlpha
                                            ?: (panelSettings.backgroundImageAlpha
                                                ?: defaultSettings.backgroundImageAlpha));
         UIColor * backgroundColor = (settings.backgroundColor
                                      ?: (panelSettings.backgroundColor
                                          ?: defaultSettings.backgroundColor));

         // style
         if (!(flags & REThemeNoStyle) && style) buttonGroup.style = [style shortValue];

         // shape
         if (!(flags & REThemeNoShape) && shape) buttonGroup.shape = [shape shortValue];

         // background image
         if (!(flags & REThemeNoBackgroundImage) && backgroundImage) buttonGroup.backgroundImage = backgroundImage;

         // background image alpha
         if (!(flags & REThemeNoBackgroundImageAlpha) && backgroundImageAlpha)
             buttonGroup.backgroundImageAlpha = [backgroundImageAlpha floatValue];

         // background color
         if (!(flags & REThemeNoBackgroundColor) && backgroundColor) buttonGroup.backgroundColor = backgroundColor;

         // label
         // TODO: Add property for button group label style
         /*
          buttonGroup.label = [self themedStringFromString:buttonGroup.label
          state:UIControlStateNormal
          flags:flags];
          */
     }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Applying Theme to a Button
////////////////////////////////////////////////////////////////////////////////
- (void)applyThemeToButton:(REButton *)button
{

    NSManagedObjectContext * moc = button.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         REThemeFlags flags = button.themeFlags;
         REType baseButtonType = baseButtonTypeForREType(button.type);
         REThemeButtonSettings * defaultSettings = [self buttonSettingsForType:RETypeButton];
         REThemeButtonSettings * settings = [self buttonSettingsForType:baseButtonType];
         REThemeButtonSettings * subSettings = [settings subSettingsForType:button.type];

         if (!(settings || subSettings)) return;

         NSNumber * style = (subSettings.style
                             ?: (settings.style
                                 ?: defaultSettings.style));
         NSNumber * shape = (subSettings.shape
                             ?: (settings.shape
                                 ?: defaultSettings.shape));
         NSValue * titleEdgeInsets = (subSettings.titleInsets
                                      ?: (settings.titleInsets
                                          ?: defaultSettings.titleInsets));
         NSValue * contentEdgeInsets = (subSettings.contentInsets
                                        ?: (settings.contentInsets
                                            ?: defaultSettings.contentInsets));
         NSValue * imageEdgeInsets = (subSettings.imageInsets
                                      ?: (settings.imageInsets
                                          ?: defaultSettings.imageInsets));
         REControlStateColorSet * backgroundColors = (subSettings.backgroundColors
                                                      ?: (settings.backgroundColors
                                                          ?: defaultSettings.backgroundColors));
         REControlStateImageSet * images = (subSettings.images
                                                  ?: (settings.images
                                                      ?: defaultSettings.images));
         REControlStateTitleSet * titles = (subSettings.titles
                                            ?: (settings.titles
                                                ?: defaultSettings.titles));
         REControlStateImageSet * icons = (subSettings.icons
                                               ?: (settings.icons
                                                   ?: defaultSettings.icons));


         // style
         if (!(flags & REThemeNoStyle) && style) button.style = [style shortValue];

         // shape
         if (!(flags & REThemeNoShape) && shape) button.shape = [shape shortValue];

         // insets
         if (!(flags & REThemeNoTitleInsets) && titleEdgeInsets)
             button.titleEdgeInsets = [titleEdgeInsets UIEdgeInsetsValue];

         if (!(flags & REThemeNoContentInsets) && contentEdgeInsets)
             button.contentEdgeInsets = [contentEdgeInsets UIEdgeInsetsValue];

         if (!(flags & REThemeNoIconInsets) && imageEdgeInsets)
             button.imageEdgeInsets = [imageEdgeInsets UIEdgeInsetsValue];


         NSArray * configurationKeys = button.remote.configurationDelegate.configurationKeys;

         if (!configurationKeys) configurationKeys = @[REDefaultConfiguration];

         for (RERemoteConfiguration configuration in configurationKeys)
         {
             button.buttonConfigurationDelegate.currentConfiguration = configuration;

             // background color
             if (!(flags & REThemeNoBackgroundColor) && backgroundColors)
             {
                 REControlStateColorSet * colorSet = button.backgroundColors;
                 if (!colorSet)
                 {
                     colorSet = [REControlStateColorSet controlStateSetInContext:moc];
                     [button setBackgroundColors:colorSet configuration:configuration];
                 }

                 [colorSet copyObjectsFromSet:backgroundColors];
             }


             // images
             if (!(flags & REThemeNoBackgroundImage) && images)
             {
                 REControlStateImageSet * imageSet = button.images;
                 if (!imageSet)
                 {
                     imageSet = [REControlStateImageSet controlStateSetInContext:moc];
                     [button setImages:imageSet configuration:configuration];
                 }
                 [imageSet copyObjectsFromSet:images];
             }

             // titles
             if (!(flags & REThemeNoTitle) && titles)
             {
                 REControlStateTitleSet * titleSet = button.titles;
                 if (!titleSet) titleSet = [REControlStateTitleSet controlStateSetInContext:moc];
                 assert(titleSet);

                 for (int i = 0; i < 8; i++)
                 {
                     if (titleSet[i])
                         titleSet[i] = [self themedAttributesFromAttributes:titleSet[i]
                                                         templateAttributes:titles[i]
                                                                      flags:flags];
                     else if (!(flags & REThemeNoTitleText) && titles[i][RETitleTextKey])
                         titleSet[i] = [titles[i] copy];
                 }

                 [button setTitles:titleSet configuration:configuration];
             }

             // icon colors
             if (!(flags & REThemeNoIcon) && icons)
             {
                 REControlStateImageSet * iconSet = button.icons;
                 if (!iconSet) iconSet = [REControlStateImageSet controlStateSetInContext:moc];

                 if (!(flags & REThemeNoIconImage))
                     for (int i = 0; i < 8; i++)
                         if (icons[i]) iconSet[i] = icons[i];

                 REControlStateColorSet * colorSet = iconSet.colors;
                 if (!(flags & REThemeNoIconColor))
                     [colorSet copyObjectsFromSet:icons.colors];

                 [button setIcons:iconSet configuration:configuration];
             }
         }
     }];
    
}

@end
