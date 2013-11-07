//
//  RETheme_Private.h
//  Remote
//
//  Created by Jason Cardwell on 4/9/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "Theme.h"
#import "ControlStateSet.h"
#import "ControlStateImageSet.h"
#import "ControlStateTitleSet.h"
#import "ControlStateColorSet.h"
#import "Image.h"
#import "RemoteElement.h"
#import "REFont.h"
#import "RemoteElementKeys.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RETheme Class Extension and Core Data Generated
////////////////////////////////////////////////////////////////////////////////


@class ThemeSettings, ThemeRemoteSettings, ThemeButtonGroupSettings, ThemeButtonSettings;

@interface Theme ()
{
    @protected
    BOOL   _shouldInitializeColors;
}

- (void)initializeSettings;
- (void)initializeRemoteSettings;
- (void)initializeButtonGroupSettings;
- (void)initializeButtonSettings;

- (ThemeSettings *)settingsForType:(REType)type withRole:(RERole)role;
- (ThemeRemoteSettings *)remoteSettingsForRole:(RERole)role;
- (ThemeButtonGroupSettings *)buttonGroupSettingsForRole:(RERole)role;
- (ThemeButtonSettings *)buttonSettingsForRole:(RERole)role;

@property (nonatomic, strong) NSSet    * settings;
@property (nonatomic, strong) NSNumber * theme;
@property (nonatomic, copy  ) NSString * name;

@end

@interface Theme (CoreDataGeneratedAccessors)

- (void)addElementsObject:(RemoteElement *)element;
- (void)removeElementsObject:(RemoteElement *)element;
- (void)addElements:(NSSet *)elements;
- (void)removeElements:(NSSet *)elements;

- (void)addSettingsObject:(ThemeSettings *)themeSettings;
- (void)removeSettingsObject:(ThemeSettings *)themeSettings;
- (void)addSettings:(NSSet *)themeSettings;
- (void)removeSettings:(NSSet *)themeSettings;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REBuiltinTheme Class Extension
////////////////////////////////////////////////////////////////////////////////


@class BuiltinThemeDecorator;

@interface BuiltinTheme ()

@property (nonatomic, strong, readonly) BuiltinThemeDecorator * decorator;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Builtin Theme Decorator
////////////////////////////////////////////////////////////////////////////////


@interface BuiltinThemeDecorator : NSObject

- (void)initializeRemoteSettingsForTheme:(BuiltinTheme *)theme;
- (void)initializeButtonGroupSettingsForTheme:(BuiltinTheme *)theme;
- (void)initializeButtonSettingsForTheme:(BuiltinTheme *)theme;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Builtin Theme Concrete Subclasses
////////////////////////////////////////////////////////////////////////////////

@interface RENightshadeThemeDecorator : BuiltinThemeDecorator @end

@interface REPowerBlueThemeDecorator : BuiltinThemeDecorator @end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Theme Settings
////////////////////////////////////////////////////////////////////////////////


@interface ThemeSettings : ModelObject<NSCopying>

@property (nonatomic, strong)   Theme  * theme;
@property (nonatomic, readonly) REType   type;
@property (nonatomic, assign)   RERole   role;
@property (nonatomic, strong)   Image  * backgroundImage;


+ (instancetype)themeSettings;
+ (instancetype)themeSettingsInContext:(NSManagedObjectContext *)moc;
+ (instancetype)themeSettingsWithRole:(RERole)role;
+ (instancetype)themeSettingsWithRole:(RERole)role context:(NSManagedObjectContext *)moc;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Settings
////////////////////////////////////////////////////////////////////////////////


@interface ThemeRemoteSettings : ThemeSettings

@property (nonatomic, strong) UIColor  * backgroundColor;
@property (nonatomic, strong) NSNumber * backgroundImageAlpha;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Group Settings
////////////////////////////////////////////////////////////////////////////////


@interface ThemeButtonGroupSettings : ThemeSettings

@property (nonatomic, strong) UIColor  * backgroundColor;
@property (nonatomic, strong) NSNumber * backgroundImageAlpha;
@property (nonatomic, strong) NSNumber * style;
@property (nonatomic, strong) NSNumber * shape;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Settings
////////////////////////////////////////////////////////////////////////////////


@interface ThemeButtonSettings : ThemeSettings

- (ThemeButtonSettings *)subSettingsForRole:(RERole)role;

@property (nonatomic, strong) NSValue                      * titleInsets;
@property (nonatomic, strong) NSValue                      * contentInsets;
@property (nonatomic, strong) NSValue                      * imageInsets;
@property (nonatomic, strong) ControlStateColorSet       * backgroundColors;
@property (nonatomic, strong) ControlStateImageSet       * icons;
@property (nonatomic, strong) ControlStateTitleSet       * titles;
@property (nonatomic, strong) ControlStateImageSet       * images;
@property (nonatomic, strong) ThemeButtonSettings        * primarySettings;
@property (nonatomic, strong) NSSet                        * subSettings;
@property (nonatomic, strong) NSNumber                     * style;
@property (nonatomic, strong) NSNumber                     * shape;

@end

@interface ThemeButtonSettings (CoreDataGeneratedAccessors)

- (void)addSubSettingsObject:(ThemeButtonSettings *)buttonSettings;
- (void)removeSubSettingsObject:(ThemeButtonSettings *)buttonSettings;
- (void)addSubSettings:(NSSet *)buttonSettings;
- (void)removeSubSettings:(NSSet *)buttonSettings;

@end
