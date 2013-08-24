//
//  REThemeSettings.m
//  Remote
//
//  Created by Jason Cardwell on 7/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RETheme_Private.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Theme Settings
////////////////////////////////////////////////////////////////////////////////
@implementation REThemeSettings

@dynamic theme, type, backgroundImage;

+ (instancetype)themeSettings
{
    return [self themeSettingsInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (instancetype)themeSettingsInContext:(NSManagedObjectContext *)moc
{
    return [self MR_createInContext:moc];
}

+ (instancetype)themeSettingsWithType:(REType)type
{
    return [self themeSettingsWithType:type
                               context:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (instancetype)themeSettingsWithType:(REType)type context:(NSManagedObjectContext *)moc
{
    REThemeSettings * themeSettings = [self themeSettingsInContext:moc];
    themeSettings.type = @(type);
    return themeSettings;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    REThemeSettings * themeSettings = [[self class] themeSettingsInContext:self.managedObjectContext];
    themeSettings.backgroundImage = self.backgroundImage;
    themeSettings.theme = self.theme;
    return themeSettings;
}


- (MSDictionary *)deepDescriptionDictionary
{

    REThemeSettings * settings = [self faultedObject];

    MSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

    NSString * themeString = (settings.theme.name ?: @"nil");
    NSString * typeString  = NSStringFromREType([settings.type shortValue]);
    NSString * bgString    = namedModelObjectDescription(settings.backgroundImage);

    dd[@"theme"] = themeString;
    dd[@"type" ] = typeString;
    dd[@"backgroundImage"] = bgString;

    return dd;
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Theme Settings
////////////////////////////////////////////////////////////////////////////////
@implementation REThemeRemoteSettings

@dynamic backgroundColor, backgroundImageAlpha;


- (id)copyWithZone:(NSZone *)zone
{
    REThemeRemoteSettings * themeSettings = [super copyWithZone:zone];
    themeSettings.backgroundColor = self.backgroundColor;
    themeSettings.backgroundImageAlpha = self.backgroundImageAlpha;
    return themeSettings;
}

- (MSDictionary *)deepDescriptionDictionary
{

    REThemeRemoteSettings * settings = [self faultedObject];

    MSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

    NSString * bgColorString       = NSStringFromUIColor(settings.backgroundColor);
    NSString * bgImageAlphaString  = [settings.backgroundImageAlpha stringValue];

    dd[@"backgroundColor"]       = bgColorString;
    dd[@"backgroundImageAlpha"]  = bgImageAlphaString;

    return dd;
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Group Theme Settings
////////////////////////////////////////////////////////////////////////////////
@implementation REThemeButtonGroupSettings

@dynamic backgroundColor, backgroundImageAlpha, style, shape;

- (id)copyWithZone:(NSZone *)zone
{
    REThemeButtonGroupSettings * themeSettings = [super copyWithZone:zone];
    themeSettings.backgroundColor = self.backgroundColor;
    themeSettings.backgroundImageAlpha = self.backgroundImageAlpha;
    themeSettings.style = self.style;
    themeSettings.shape = self.shape;

    return themeSettings;
}

- (MSDictionary *)deepDescriptionDictionary
{
    REThemeButtonGroupSettings * settings = [self faultedObject];

    MSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

    NSString * bgColorString       = NSStringFromUIColor(settings.backgroundColor);
    NSString * bgImageAlphaString  = [settings.backgroundImageAlpha stringValue];
    NSString * styleString         = NSStringFromREStyle([settings.style shortValue]);
    NSString * shapeString         = NSStringFromREShape([settings.shape shortValue]);

    dd[@"backgroundColor"]      = bgColorString;
    dd[@"backgroundImageAlpha"] = bgImageAlphaString;
    dd[@"style"]                = styleString;
    dd[@"shape"]                = shapeString;

    return dd;
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Theme Settings
////////////////////////////////////////////////////////////////////////////////
@implementation REThemeButtonSettings

@dynamic titleInsets, contentInsets, imageInsets, backgroundColors, icons, titles, images, primarySettings, subSettings, style, shape;

- (id)copyWithZone:(NSZone *)zone
{
    REThemeButtonSettings * themeSettings = [super copyWithZone:zone];
    themeSettings.backgroundColors = [self.backgroundColors copy];
    themeSettings.icons = [self.icons copy];
    themeSettings.titles = [self.titles copy];
    themeSettings.images = [self.images copy];
    themeSettings.style = self.style;
    themeSettings.shape = self.shape;
    themeSettings.titleInsets = self.titleInsets;
    themeSettings.contentInsets = self.contentInsets;
    themeSettings.imageInsets = self.imageInsets;

    return themeSettings;
}

- (REThemeButtonSettings *)subSettingsForType:(REType)type
{
    return [self.subSettings objectPassingTest:
            ^BOOL(REThemeButtonSettings * obj) {
                return ([obj.type intValue] == type);
            }];
}

- (MSDictionary *)deepDescriptionDictionary
{

    REThemeButtonSettings * settings = [self faultedObject];

    MSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

    NSString * titleInsetsString = NSStringFromUIEdgeInsets([settings.titleInsets
                                                             UIEdgeInsetsValue]);
    NSString * contentInsetsString = NSStringFromUIEdgeInsets([settings.contentInsets
                                                               UIEdgeInsetsValue]);
    NSString * imageInsetsString = NSStringFromUIEdgeInsets([settings.imageInsets
                                                             UIEdgeInsetsValue]);
    NSString * bgColorsString  = (settings.backgroundColors
                                  ? [settings.backgroundColors deepDescription]
                                  : @"nil");
    NSString * iconsString  = (settings.icons
                                    ? [settings.icons deepDescription]
                                    : @"nil");
    NSString * titlesString  = (settings.titles
                                ? [settings.titles deepDescription]
                                : @"nil");
    NSString * imagesString  = (settings.images
                                ? [settings.images deepDescription]
                                : @"nil");
    NSString * primarySettingsString = (settings.primarySettings
                                        ? settings.primarySettings.uuid
                                        : @"nil");
    NSString * subSettingsString = (settings.subSettings
                                    ? [[settings.subSettings valueForKeyPath:@"deepDescription"]
                                       componentsJoinedByString:@"\n\n"]
                                    : @"nil");
    NSString * styleString = NSStringFromREStyle([settings.style shortValue]);
    NSString * shapeString = NSStringFromREShape([settings.shape shortValue]);

    dd[@"titleInsets"]      = titleInsetsString;
    dd[@"contentInsets"]    = contentInsetsString;
    dd[@"imageInsets"]      = imageInsetsString;
    dd[@"backgroundColors"] = bgColorsString;
    dd[@"icons"]            = iconsString;
    dd[@"titles"]           = titlesString;
    dd[@"images"]           = imagesString;
    dd[@"primarySettings"]  = primarySettingsString;
    dd[@"subSettings"]      = subSettingsString;
    dd[@"style"]            = styleString;
    dd[@"shape"]            = shapeString;

    return dd;
}

@end
