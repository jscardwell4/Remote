//
//  ThemeSettings.m
//  Remote
//
//  Created by Jason Cardwell on 7/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "Theme_Private.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Theme Settings
////////////////////////////////////////////////////////////////////////////////
@implementation ThemeSettings

@dynamic theme, role, backgroundImage;

+ (instancetype)themeSettings
{
    return [self themeSettingsInContext:[CoreDataManager defaultContext]];
}

+ (instancetype)themeSettingsInContext:(NSManagedObjectContext *)moc
{
    return [self MR_createInContext:moc];
}

+ (instancetype)themeSettingsWithRole:(RERole)role
{
    return [self themeSettingsWithRole:role
                               context:[CoreDataManager defaultContext]];
}

+ (instancetype)themeSettingsWithRole:(RERole)role context:(NSManagedObjectContext *)moc
{
    ThemeSettings * themeSettings = [self themeSettingsInContext:moc];
    themeSettings.role = role;
    return themeSettings;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    ThemeSettings * themeSettings = [[self class] themeSettingsInContext:self.managedObjectContext];
    themeSettings.backgroundImage = self.backgroundImage;
    themeSettings.theme = self.theme;
    return themeSettings;
}

- (REType)type { return RETypeUndefined; }

- (RERole)role
{
    [self willAccessValueForKey:@"role"];
    NSNumber * role = [self primitiveValueForKey:@"role"];
    [self didAccessValueForKey:@"role"];
    return [role unsignedShortValue];
}

- (void)setRole:(RERole)role
{
    [self willChangeValueForKey:@"role"];
    [self setPrimitiveValue:@(role) forKey:@"role"];
    [self didChangeValueForKey:@"role"];
}

- (MSDictionary *)deepDescriptionDictionary
{

    ThemeSettings * settings = [self faultedObject];

    MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

    NSString * themeString = (settings.theme.name ?: @"nil");
    NSString * typeString  = NSStringFromREType(settings.type);
    NSString * roleString  = NSStringFromRERole(settings.role);
    NSString * bgString    = namedModelObjectDescription(settings.backgroundImage);

    dd[@"theme"]           = themeString;
    dd[@"type"]            = typeString;
    dd[@"role"]            = roleString;
    dd[@"backgroundImage"] = bgString;

    return (MSDictionary *)dd;
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Theme Settings
////////////////////////////////////////////////////////////////////////////////
@implementation ThemeRemoteSettings

@dynamic backgroundColor, backgroundImageAlpha;


- (id)copyWithZone:(NSZone *)zone
{
    ThemeRemoteSettings * themeSettings = [super copyWithZone:zone];
    themeSettings.backgroundColor = self.backgroundColor;
    themeSettings.backgroundImageAlpha = self.backgroundImageAlpha;
    return themeSettings;
}

- (REType)type { return RETypeRemote; }

- (MSDictionary *)deepDescriptionDictionary
{

    ThemeRemoteSettings * settings = [self faultedObject];

    MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

    NSString * bgColorString       = NSStringFromUIColor(settings.backgroundColor);
    NSString * bgImageAlphaString  = [settings.backgroundImageAlpha stringValue];

    dd[@"backgroundColor"]       = bgColorString;
    dd[@"backgroundImageAlpha"]  = bgImageAlphaString;

    return (MSDictionary *)dd;
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Group Theme Settings
////////////////////////////////////////////////////////////////////////////////
@implementation ThemeButtonGroupSettings

@dynamic backgroundColor, backgroundImageAlpha, style, shape;

- (id)copyWithZone:(NSZone *)zone
{
    ThemeButtonGroupSettings * themeSettings = [super copyWithZone:zone];
    themeSettings.backgroundColor = self.backgroundColor;
    themeSettings.backgroundImageAlpha = self.backgroundImageAlpha;
    themeSettings.style = self.style;
    themeSettings.shape = self.shape;

    return themeSettings;
}

- (REType)type { return RETypeButtonGroup; }

- (MSDictionary *)deepDescriptionDictionary
{
    ThemeButtonGroupSettings * settings = [self faultedObject];

    MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

    NSString * bgColorString       = NSStringFromUIColor(settings.backgroundColor);
    NSString * bgImageAlphaString  = [settings.backgroundImageAlpha stringValue];
    NSString * styleString         = NSStringFromREStyle([settings.style shortValue]);
    NSString * shapeString         = NSStringFromREShape([settings.shape shortValue]);

    dd[@"backgroundColor"]      = bgColorString;
    dd[@"backgroundImageAlpha"] = bgImageAlphaString;
    dd[@"style"]                = styleString;
    dd[@"shape"]                = shapeString;

    return (MSDictionary *)dd;
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Theme Settings
////////////////////////////////////////////////////////////////////////////////
@implementation ThemeButtonSettings

@dynamic titleInsets, contentInsets, imageInsets, backgroundColors, icons, titles, images, primarySettings, subSettings, style, shape;

- (id)copyWithZone:(NSZone *)zone
{
    ThemeButtonSettings * themeSettings = [super copyWithZone:zone];
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

- (REType)type { return RETypeButton; }

- (ThemeButtonSettings *)subSettingsForRole:(RERole)role
{
    return [self.subSettings objectPassingTest:
            ^BOOL(ThemeButtonSettings * obj) {
                return (obj.role == role);
            }];
}

- (MSDictionary *)deepDescriptionDictionary
{

    ThemeButtonSettings * settings = [self faultedObject];

    MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

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

    return (MSDictionary *)dd;
}

@end
