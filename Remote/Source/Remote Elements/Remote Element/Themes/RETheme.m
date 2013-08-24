//
//  RETheme.m
//  Remote
//
//  Created by Jason Cardwell on 4/8/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RETheme_Private.h"
#import "RemoteElement.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Theme
////////////////////////////////////////////////////////////////////////////////
@implementation RETheme

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
    RETheme * theme = [self MR_findFirstByAttribute:@"name" withValue:name inContext:context];
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
         self.settings = [@[[REThemeRemoteSettings
                                     themeSettingsWithType:RETypeRemote
                                                   context:moc],
                            [REThemeButtonGroupSettings
                                      themeSettingsWithType:RETypeButtonGroup
                                                    context:moc],
                            [REThemeButtonSettings
                                      themeSettingsWithType:RETypeButton
                                                    context:moc],
                            [REThemeButtonGroupSettings
                                      themeSettingsWithType:REButtonGroupTypePanel
                                                    context:moc],
                            [REThemeButtonGroupSettings
                                      themeSettingsWithType:REButtonGroupTypeSelectionPanel
                                                    context:moc],
                            [REThemeButtonGroupSettings
                                      themeSettingsWithType:REButtonGroupTypeToolbar
                                                    context:moc],
                            [REThemeButtonGroupSettings
                                      themeSettingsWithType:REButtonGroupTypeDPad
                                                    context:moc],
                            [REThemeButtonGroupSettings
                                      themeSettingsWithType:REButtonGroupTypeNumberpad
                                                    context:moc],
                            [REThemeButtonGroupSettings
                                      themeSettingsWithType:REButtonGroupTypeTransport
                                                    context:moc],
                            [REThemeButtonGroupSettings
                                      themeSettingsWithType:REButtonGroupTypePickerLabel
                                                    context:moc],
                            [REThemeButtonSettings
                                      themeSettingsWithType:REButtonTypeToolbar
                                                    context:moc],
                            [REThemeButtonSettings
                                      themeSettingsWithType:REButtonTypePickerLabel
                                                    context:moc],
                            [REThemeButtonSettings
                                      themeSettingsWithType:REButtonTypePanel
                                                    context:moc],
                            [REThemeButtonSettings
                                      themeSettingsWithType:REButtonTypeTuck
                                                    context:moc],
                            [REThemeButtonSettings
                                      themeSettingsWithType:REButtonTypeSelectionPanel
                                                    context:moc],
                            [REThemeButtonSettings
                                      themeSettingsWithType:REButtonTypeDPad
                                                    context:moc],
                            [REThemeButtonSettings
                                      themeSettingsWithType:REButtonTypeNumberpad
                                                    context:moc],
                            [REThemeButtonSettings
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

- (REThemeSettings *)settingsForType:(REType)type
{
    return [self.settings objectPassingTest:
            ^BOOL(REThemeSettings * obj) {
                return ([obj.type intValue] == type);
            }];
}

- (REThemeRemoteSettings *)remoteSettingsForType:(REType)type
{
    REThemeSettings * settings = [self settingsForType:type];
    return ([settings isKindOfClass:[REThemeRemoteSettings class]]
            ? (REThemeRemoteSettings *)settings
            : nil);
}

- (REThemeButtonGroupSettings *)buttonGroupSettingsForType:(REType)type
{
    REThemeSettings * settings = [self settingsForType:type];
    if (!settings && type != REButtonGroupTypeSelectionPanel && (type & REButtonGroupTypePanel) == REButtonGroupTypePanel)
    {
        settings = [self settingsForType:(type & ~REButtonGroupTypePanel) | RETypeButtonGroup];
    }
    return ([settings isKindOfClass:[REThemeButtonGroupSettings class]]
            ? (REThemeButtonGroupSettings *)settings
            : nil);
}

- (REThemeButtonSettings *)buttonSettingsForType:(REType)type
{
    REThemeSettings * settings = [self settingsForType:type];
    return ([settings isKindOfClass:[REThemeButtonSettings class]]
            ? (REThemeButtonSettings *)settings
            : nil);
}

- (MSDictionary *)deepDescriptionDictionary
{
    RETheme * theme = [self faultedObject];

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
