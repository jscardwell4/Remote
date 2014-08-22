//
//  RETheme.m
//  Remote
//
//  Created by Jason Cardwell on 4/8/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "Theme_Private.h"
#import "RemoteElement.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Theme
////////////////////////////////////////////////////////////////////////////////
@implementation Theme

@dynamic theme, name, elements, settings;

+ (BOOL)isValidThemeName:(NSString *)name
{
    return StringIsNotEmpty(name);
}

+ (instancetype)themeWithName:(NSString *)name
{
    return [self themeWithName:name context:[CoreDataManager defaultContext]];
}

+ (instancetype)themeWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    Theme * theme = [self MR_findFirstByAttribute:@"name" withValue:name inContext:context];
    if (!theme && [self isValidThemeName:name])
    {
        theme = [self MR_createInContext:context];
        theme.name = [name copy];
        [theme initializeSettings];
    }
    return theme;
}

- (void)initializeSettings
{
    NSManagedObjectContext * moc = self.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         self.settings = [@[[ThemeRemoteSettings
                                     themeSettingsWithRole:RERoleUndefined
                                                   context:moc],
                            [ThemeButtonGroupSettings
                                      themeSettingsWithRole:RERoleUndefined
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithRole:(RERole)RETypeButton
                                                    context:moc],
//                            [ThemeButtonGroupSettings
//                                      themeSettingsWithRole:REButtonGroupRolePanel
//                                                    context:moc],
                            [ThemeButtonGroupSettings
                                      themeSettingsWithRole:REButtonGroupRoleSelectionPanel
                                                    context:moc],
                            [ThemeButtonGroupSettings
                                      themeSettingsWithRole:REButtonGroupRoleToolbar
                                                    context:moc],
                            [ThemeButtonGroupSettings
                                      themeSettingsWithRole:REButtonGroupRoleDPad
                                                    context:moc],
                            [ThemeButtonGroupSettings
                                      themeSettingsWithRole:REButtonGroupRoleNumberpad
                                                    context:moc],
                            [ThemeButtonGroupSettings
                                      themeSettingsWithRole:REButtonGroupRoleTransport
                                                    context:moc],
                            [ThemeButtonGroupSettings
                                      themeSettingsWithRole:REButtonGroupRoleRocker
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithRole:REButtonRoleToolbar
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithRole:REButtonRoleRocker
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithRole:RERoleUndefined
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithRole:REButtonRoleTuck
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithRole:REButtonRoleSelectionPanel
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithRole:REButtonRoleDPad
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithRole:REButtonRoleNumberpad
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithRole:REButtonRoleTransport
                                                    context:moc]] set];
     }];

    [self initializeRemoteSettings];
    [self initializeButtonGroupSettings];
    [self initializeButtonSettings];
}

- (void)initializeRemoteSettings {}

- (void)initializeButtonGroupSettings {}

- (void)initializeButtonSettings {}


- (ThemeSettings *)settingsForType:(REType)type withRole:(RERole)role
{
    return [self.settings objectPassingTest:
            ^BOOL(ThemeSettings * obj) {
                return (obj.type == type && obj.role == role);
            }];
}

- (ThemeRemoteSettings *)remoteSettingsForRole:(RERole)role
{
    ThemeSettings * settings = [self settingsForType:RETypeRemote withRole:role];
    return ([settings isKindOfClass:[ThemeRemoteSettings class]]
            ? (ThemeRemoteSettings *)settings
            : nil);
}

- (ThemeButtonGroupSettings *)buttonGroupSettingsForRole:(RERole)role
{
    ThemeSettings * settings = [self settingsForType:RETypeButtonGroup withRole:role];
    return ([settings isKindOfClass:[ThemeButtonGroupSettings class]]
            ? (ThemeButtonGroupSettings *)settings
            : nil);
}

- (ThemeButtonSettings *)buttonSettingsForRole:(RERole)role
{
    ThemeSettings * settings = [self settingsForType:RETypeButton withRole:role];
    return ([settings isKindOfClass:[ThemeButtonSettings class]]
            ? (ThemeButtonSettings *)settings
            : nil);
}

- (MSDictionary *)deepDescriptionDictionary
{
    Theme * theme = [self faultedObject];

    NSString * themeString = ([theme.theme stringValue] ?: @"nil");
    NSString * nameString = ([theme.name description] ?: @"nil");
    NSString * elementsString = $(@"%lu", (unsigned long)[theme.elements count]);
    NSString * settingsString = [[self.settings valueForKeyPath:@"deepDescription"]
                                 componentsJoinedByString:@"\n\n"];

    MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

    dd[@"theme"]    = themeString;
    dd[@"name"]     = nameString;
    dd[@"elements"] = elementsString;
    dd[@"settings"] = settingsString;

    return (MSDictionary *)dd;
}


@end
