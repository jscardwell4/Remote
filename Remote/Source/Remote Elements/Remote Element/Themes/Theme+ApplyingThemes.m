//
//  Theme+ApplyingThemes.m
//  Remote
//
//  Created by Jason Cardwell on 4/9/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "Theme_Private.h"
#import "RemoteElement.h"
#import "Remote.h"
#import "ButtonGroup.h"
#import "Button.h"

@implementation Theme (ApplyingThemes)

////////////////////////////////////////////////////////////////////////////////
#pragma mark Helper Methods
////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)themedAttributesFromAttributes:(NSDictionary *)attributes
                              templateAttributes:(NSDictionary *)templateAttributes
                                           flags:(REThemeOverrideFlags)flags
{
    NSString * stringText = attributes[RETitleTextAttributeKey];
    if (!stringText) return nil;

    NSMutableDictionary * themeAttributes = [templateAttributes mutableCopy];

    // foreground color?
    if (flags & REThemeNoTitleForegroundColorAttribute)
    {
        [themeAttributes removeObjectForKey:REForegroundColorAttributeKey];
        UIColor * foregroundColor = attributes[REForegroundColorAttributeKey];
        if (foregroundColor) themeAttributes[REForegroundColorAttributeKey] = foregroundColor;
    }

    // background color?
    if (flags & REThemeNoTitleBackgroundColorAttribute)
    {
        [themeAttributes removeObjectForKey:REBackgroundColorAttributeKey];
        UIColor * backgroundColor = attributes[REBackgroundColorAttributeKey];
        if (backgroundColor) themeAttributes[REBackgroundColorAttributeKey] = backgroundColor;
    }

    // shadow color?
    if (flags & REThemeNoTitleShadowColorAttribute)
    {
        [themeAttributes removeObjectForKey:REShadowAttributeKey];
        NSShadow * shadow = attributes[REShadowAttributeKey];
        if (shadow) themeAttributes[REShadowAttributeKey] = shadow;
    }

    // stroke color?
    if (flags & REThemeNoTitleStrokeColorAttribute)
    {
        [themeAttributes removeObjectForKey:REStrokeColorAttributeKey];
        UIColor * strokeColor = attributes[REStrokeColorAttributeKey];
        if (strokeColor) themeAttributes[REStrokeColorAttributeKey] = strokeColor;
    }

    // font name?
    //FIXME: Needs updating
/*
    if (flags & REThemeNoFontName)
    {
        NSString * themeFont = attributes[REFontAttributeKey];
        NSArray * themeFontComponents = [themeFont componentsSeparatedByString:@"@"];
        
        [themeAttributes removeObjectForKey:REFontAttributeKey];
        NSString * font = attributes[REFontAttributeKey];
        if (font) themeAttributes[REFontAttributeKey] = font;

        // font size?
        if (flags & REThemeNoFontSize)
        {
            [themeAttributes removeObjectForKey:REFontSizeAttributeKey];
            NSNumber * fontSize = attributes[REFontSizeAttributeKey];
            if (fontSize) themeAttributes[REFontSizeAttributeKey] = fontSize;
        }
    }
*/

    // stroke width?
    if (flags & REThemeNoStrokeWidth)
    {
        [themeAttributes removeObjectForKey:REStrokeWidthAttributeKey];
        NSNumber * strokeWidth = attributes[REStrokeWidthAttributeKey];
        if (strokeWidth) themeAttributes[REStrokeWidthAttributeKey] = strokeWidth;
    }

    // strikethrough?
    if (flags & REThemeNoStrikethrough)
    {
        [themeAttributes removeObjectForKey:REStrikethroughStyleAttributeKey];
        NSNumber * strikethrough = attributes[REStrikethroughStyleAttributeKey];
        if (strikethrough) themeAttributes[REStrikethroughStyleAttributeKey] = strikethrough;
    }

    // underline?
    if (flags & REThemeNoUnderline)
    {
        [themeAttributes removeObjectForKey:REUnderlineStyleAttributeKey];
        NSNumber * underline = attributes[REUnderlineStyleAttributeKey];
        if (underline) themeAttributes[REUnderlineStyleAttributeKey] = underline;
    }

    // ligature?
    if (flags & REThemeNoLigature)
    {
        [themeAttributes removeObjectForKey:RELigatureAttributeKey];
        NSNumber * ligature = attributes[RELigatureAttributeKey];
        if (ligature) themeAttributes[RELigatureAttributeKey] = ligature;
    }

    // kern?
    if (flags & REThemeNoKern)
    {
        [themeAttributes removeObjectForKey:REKernAttributeKey];
        NSNumber * kern = attributes[REKernAttributeKey];
        if (kern) themeAttributes[REKernAttributeKey] = kern;
    }

    // paragraph style?
    if (flags & REThemeNoParagraphStyle)
    {
        [themeAttributes removeObjectForKey:REParagraphStyleAttributeKey];
        NSParagraphStyle * paragraphStyle = attributes[REParagraphStyleAttributeKey];
        if (paragraphStyle) themeAttributes[REParagraphStyleAttributeKey] = paragraphStyle;
    }

    if (!themeAttributes[RETitleTextAttributeKey] && attributes[RETitleTextAttributeKey])
    {
        themeAttributes[RETitleTextAttributeKey] = attributes[RETitleTextAttributeKey];
    }

    else if (flags & REThemeNoTitleText)
    {
        [themeAttributes removeObjectForKey:RETitleTextAttributeKey];
        NSString * titleText = attributes[RETitleTextAttributeKey];
        if (titleText) themeAttributes[RETitleTextAttributeKey] = titleText;
    }

    return themeAttributes;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Applying Theme to Elements
////////////////////////////////////////////////////////////////////////////////
- (void)applyThemeToElement:(RemoteElement *)element
{
    switch (element.elementType)
    {
        case RETypeRemote:      [self applyThemeToRemote:(Remote *)element];           break;
        case RETypeButtonGroup: [self applyThemeToButtonGroup:(ButtonGroup *)element]; break;
        case RETypeButton:      [self applyThemeToButton:(Button *)element];           break;
        default:                assert(NO);                                            break;
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
- (void)applyThemeToRemote:(Remote *)remote
{
    NSManagedObjectContext * moc = remote.managedObjectContext;

    [moc performBlockAndWait:
     ^{
         REThemeOverrideFlags flags = remote.themeFlags;
         ThemeRemoteSettings * settings = [self remoteSettingsForRole:remote.role];

         if (!settings) return;

         Image * backgroundImage = settings.backgroundImage;
         NSNumber * backgroundImageAlpha = settings.backgroundImageAlpha;
         UIColor * backgroundColor = settings.backgroundColor;

         // background color
         if (!(flags & REThemeNoBackgroundColorAttribute) && backgroundColor)
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
- (void)applyThemeToButtonGroup:(ButtonGroup *)buttonGroup
{
    NSManagedObjectContext * moc = buttonGroup.managedObjectContext;

    [moc performBlockAndWait:
     ^{
         REThemeOverrideFlags flags = buttonGroup.themeFlags;
         ThemeButtonGroupSettings * defaultSettings = [self buttonGroupSettingsForRole:RERoleUndefined];
         ThemeButtonGroupSettings * panelSettings = nil;/*
                                                         ([buttonGroup isPanel]
                                                          ? [self buttonGroupSettingsForRole:REButtonGroupRolePanel]
                                                          : nil);
                                                         */

         ThemeButtonGroupSettings * settings = [self buttonGroupSettingsForRole:buttonGroup.role];
         if (!(settings || panelSettings)) return;

         NSNumber * style = (settings.style
                             ?: (panelSettings.style
                                 ?: defaultSettings.style));
         NSNumber * shape = (settings.shape
                             ?: (panelSettings.shape
                                 ?: defaultSettings.shape));
         Image * backgroundImage = (settings.backgroundImage
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
         if (!(flags & REThemeNoBackgroundColorAttribute) && backgroundColor) buttonGroup.backgroundColor = backgroundColor;

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
- (void)applyThemeToButton:(Button *)button
{

    NSManagedObjectContext * moc = button.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         REThemeOverrideFlags flags = button.themeFlags;
         ThemeButtonSettings * defaultSettings = [self buttonSettingsForRole:RERoleUndefined];
         ThemeButtonSettings * settings = [self buttonSettingsForRole:RERoleUndefined];
         ThemeButtonSettings * subSettings = [settings subSettingsForRole:button.role];

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
         ControlStateColorSet * backgroundColors = (subSettings.backgroundColors
                                                      ?: (settings.backgroundColors
                                                          ?: defaultSettings.backgroundColors));
         ControlStateImageSet * images = (subSettings.images
                                                  ?: (settings.images
                                                      ?: defaultSettings.images));
         ControlStateTitleSet * titles = (subSettings.titles
                                            ?: (settings.titles
                                                ?: defaultSettings.titles));
         ControlStateImageSet * icons = (subSettings.icons
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


         NSArray * modeKeys = button.remote.configurationDelegate.modeKeys;

         if (!modeKeys) modeKeys = @[REDefaultMode];

         for (RERemoteMode mode in modeKeys)
         {
             button.buttonConfigurationDelegate.currentMode = mode;

             // background color
             if (!(flags & REThemeNoBackgroundColorAttribute) && backgroundColors)
             {
                 ControlStateColorSet * colorSet = button.backgroundColors;
                 if (!colorSet)
                 {
                     colorSet = [ControlStateColorSet controlStateSetInContext:moc];
                     [button setBackgroundColors:colorSet mode:mode];
                 }

                 [colorSet copyObjectsFromSet:backgroundColors];
             }


             // images
             if (!(flags & REThemeNoBackgroundImage) && images)
             {
                 ControlStateImageSet * imageSet = button.images;
                 if (!imageSet)
                 {
                     imageSet = [ControlStateImageSet controlStateSetInContext:moc];
                     [button setImages:imageSet mode:mode];
                 }
                 [imageSet copyObjectsFromSet:images];
             }

             // titles
             if (!(flags & REThemeNoTitle) && titles)
             {
                 ControlStateTitleSet * titleSet = button.titles;
                 if (!titleSet) titleSet = [ControlStateTitleSet controlStateSetInContext:moc];
                 assert(titleSet);

                 for (int i = 0; i < 8; i++)
                 {
                     id obj = [titleSet objectAtIndex:i];
                     id templateObj = [titles objectAtIndex:i];
                     if (obj)
                     {
                         if (!templateObj) templateObj = titles[i];
                         titleSet[i] = [self themedAttributesFromAttributes:obj
                                                         templateAttributes:templateObj
                                                                      flags:flags];
                     }
                     else if (!(flags & REThemeNoTitleText) && templateObj[RETitleTextAttributeKey])
                         titleSet[i] = [templateObj copy];
                 }

                 [button setTitles:titleSet mode:mode];
             }

             // icon colors
             if (!(flags & REThemeNoIcon) && icons)
             {
                 ControlStateImageSet * iconSet = button.icons;
                 if (!iconSet) iconSet = [ControlStateImageSet controlStateSetInContext:moc];

                 if (!(flags & REThemeNoIconImage))
                 {
                     for (int i = 0; i < 8; i++)
                     {
                         id templateObj = [icons objectAtIndex:i];
                         if (templateObj) iconSet[i] = templateObj;
                     }
                 }

                 ControlStateColorSet * colorSet = iconSet.colors;
                 if (!(flags & REThemeNoIconColorAttribute))
                     [colorSet copyObjectsFromSet:icons.colors];

                 [button setIcons:iconSet mode:mode];
             }
         }
     }];
    
}

@end
