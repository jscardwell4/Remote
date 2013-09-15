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
    return [self themeWithName:name context:[NSManagedObjectContext MR_contextForCurrentThread]];
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
                                     themeSettingsWithType:RETypeRemote
                                                   context:moc],
                            [ThemeButtonGroupSettings
                                      themeSettingsWithType:RETypeButtonGroup
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithType:RETypeButton
                                                    context:moc],
                            [ThemeButtonGroupSettings
                                      themeSettingsWithType:REButtonGroupTypePanel
                                                    context:moc],
                            [ThemeButtonGroupSettings
                                      themeSettingsWithType:REButtonGroupTypeSelectionPanel
                                                    context:moc],
                            [ThemeButtonGroupSettings
                                      themeSettingsWithType:REButtonGroupTypeToolbar
                                                    context:moc],
                            [ThemeButtonGroupSettings
                                      themeSettingsWithType:REButtonGroupTypeDPad
                                                    context:moc],
                            [ThemeButtonGroupSettings
                                      themeSettingsWithType:REButtonGroupTypeNumberpad
                                                    context:moc],
                            [ThemeButtonGroupSettings
                                      themeSettingsWithType:REButtonGroupTypeTransport
                                                    context:moc],
                            [ThemeButtonGroupSettings
                                      themeSettingsWithType:REButtonGroupTypePickerLabel
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithType:REButtonTypeToolbar
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithType:REButtonTypePickerLabel
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithType:REButtonTypePanel
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithType:REButtonTypeTuck
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithType:REButtonTypeSelectionPanel
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithType:REButtonTypeDPad
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithType:REButtonTypeNumberpad
                                                    context:moc],
                            [ThemeButtonSettings
                                      themeSettingsWithType:REButtonTypeTransport
                                                    context:moc]] set];
     }];

    [self initializeRemoteSettings];
    [self initializeButtonGroupSettings];
    [self initializeButtonSettings];
}

- (void)initializeRemoteSettings {}

- (void)initializeButtonGroupSettings {}

- (void)initializeButtonSettings {}

- (ThemeSettings *)settingsForType:(REType)type
{
    return [self.settings objectPassingTest:
            ^BOOL(ThemeSettings * obj) {
                return ([obj.type intValue] == type);
            }];
}

- (ThemeRemoteSettings *)remoteSettingsForType:(REType)type
{
    ThemeSettings * settings = [self settingsForType:type];
    return ([settings isKindOfClass:[ThemeRemoteSettings class]]
            ? (ThemeRemoteSettings *)settings
            : nil);
}

- (ThemeButtonGroupSettings *)buttonGroupSettingsForType:(REType)type
{
    ThemeSettings * settings = [self settingsForType:type];
    if (!settings && type != REButtonGroupTypeSelectionPanel && (type & REButtonGroupTypePanel) == REButtonGroupTypePanel)
    {
        settings = [self settingsForType:(type & ~REButtonGroupTypePanel) | RETypeButtonGroup];
    }
    return ([settings isKindOfClass:[ThemeButtonGroupSettings class]]
            ? (ThemeButtonGroupSettings *)settings
            : nil);
}

- (ThemeButtonSettings *)buttonSettingsForType:(REType)type
{
    ThemeSettings * settings = [self settingsForType:type];
    return ([settings isKindOfClass:[ThemeButtonSettings class]]
            ? (ThemeButtonSettings *)settings
            : nil);
}

- (MSDictionary *)deepDescriptionDictionary
{
    Theme * theme = [self faultedObject];

    NSString * themeString = ([theme.theme stringValue] ?: @"nil");
    NSString * nameString = ([theme.name description] ?: @"nil");
    NSString * elementsString = $(@"%u", [theme.elements count]);
    NSString * settingsString = [[self.settings valueForKeyPath:@"deepDescription"]
                                 componentsJoinedByString:@"\n\n"];

    MSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

    dd[@"theme"]    = themeString;
    dd[@"name"]     = nameString;
    dd[@"elements"] = elementsString;
    dd[@"settings"] = settingsString;

    return dd;
}


@end
