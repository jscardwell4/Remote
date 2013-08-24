//
//  RETheme_Private.h
//  Remote
//
//  Created by Jason Cardwell on 4/9/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RETheme.h"
#import "REControlStateSet.h"
#import "BOImage.h"
#import "RemoteElement.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - RETheme Class Extension and Core Data Generated
////////////////////////////////////////////////////////////////////////////////


@class REThemeSettings, REThemeRemoteSettings, REThemeButtonGroupSettings, REThemeButtonSettings;

@interface RETheme ()
{
    @protected
    BOOL   _shouldInitializeColors;
}

- (void)initializeSettings;
- (void)initializeRemoteSettings;
- (void)initializeButtonGroupSettings;
- (void)initializeButtonSettings;

- (REThemeSettings *)settingsForType:(REType)type;
- (REThemeRemoteSettings *)remoteSettingsForType:(REType)type;
- (REThemeButtonGroupSettings *)buttonGroupSettingsForType:(REType)type;
- (REThemeButtonSettings *)buttonSettingsForType:(REType)type;

@property (nonatomic, strong) NSSet    * settings;
@property (nonatomic, strong) NSNumber * theme;
@property (nonatomic, copy  ) NSString * name;

@end

@interface RETheme (CoreDataGeneratedAccessors)

- (void)addElementsObject:(RemoteElement *)element;
- (void)removeElementsObject:(RemoteElement *)element;
- (void)addElements:(NSSet *)elements;
- (void)removeElements:(NSSet *)elements;

- (void)addSettingsObject:(REThemeSettings *)themeSettings;
- (void)removeSettingsObject:(REThemeSettings *)themeSettings;
- (void)addSettings:(NSSet *)themeSettings;
- (void)removeSettings:(NSSet *)themeSettings;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - REBuiltinTheme Class Extension
////////////////////////////////////////////////////////////////////////////////


@class REBuiltinThemeDecorator;

@interface REBuiltinTheme ()

@property (nonatomic, strong, readonly) REBuiltinThemeDecorator * decorator;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Builtin Theme Decorator
////////////////////////////////////////////////////////////////////////////////


@interface REBuiltinThemeDecorator : NSObject

- (void)initializeRemoteSettingsForTheme:(REBuiltinTheme *)theme;
- (void)initializeButtonGroupSettingsForTheme:(REBuiltinTheme *)theme;
- (void)initializeButtonSettingsForTheme:(REBuiltinTheme *)theme;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Builtin Theme Concrete Subclasses
////////////////////////////////////////////////////////////////////////////////

@interface RENightshadeThemeDecorator : REBuiltinThemeDecorator @end

@interface REPowerBlueThemeDecorator : REBuiltinThemeDecorator @end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Theme Settings
////////////////////////////////////////////////////////////////////////////////


@interface REThemeSettings : MSModelObject<NSCopying>

@property (nonatomic, strong) RETheme  * theme;
@property (nonatomic, strong) NSNumber * type;
@property (nonatomic, strong) BOImage  * backgroundImage;


+ (instancetype)themeSettings;
+ (instancetype)themeSettingsInContext:(NSManagedObjectContext *)moc;
+ (instancetype)themeSettingsWithType:(REType)type;
+ (instancetype)themeSettingsWithType:(REType)type context:(NSManagedObjectContext *)moc;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remote Settings
////////////////////////////////////////////////////////////////////////////////


@class BOBackgroundImage;

@interface REThemeRemoteSettings : REThemeSettings

@property (nonatomic, strong) UIColor  * backgroundColor;
@property (nonatomic, strong) NSNumber * backgroundImageAlpha;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Group Settings
////////////////////////////////////////////////////////////////////////////////


@interface REThemeButtonGroupSettings : REThemeSettings

@property (nonatomic, strong) UIColor  * backgroundColor;
@property (nonatomic, strong) NSNumber * backgroundImageAlpha;
@property (nonatomic, strong) NSNumber * style;
@property (nonatomic, strong) NSNumber * shape;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Settings
////////////////////////////////////////////////////////////////////////////////


@interface REThemeButtonSettings : REThemeSettings

- (REThemeButtonSettings *)subSettingsForType:(REType)type;

@property (nonatomic, strong) NSValue                      * titleInsets;
@property (nonatomic, strong) NSValue                      * contentInsets;
@property (nonatomic, strong) NSValue                      * imageInsets;
@property (nonatomic, strong) REControlStateColorSet       * backgroundColors;
@property (nonatomic, strong) REControlStateImageSet       * icons;
@property (nonatomic, strong) REControlStateTitleSet       * titles;
@property (nonatomic, strong) REControlStateImageSet       * images;
@property (nonatomic, strong) REThemeButtonSettings        * primarySettings;
@property (nonatomic, strong) NSSet                        * subSettings;
@property (nonatomic, strong) NSNumber                     * style;
@property (nonatomic, strong) NSNumber                     * shape;

@end

@interface REThemeButtonSettings (CoreDataGeneratedAccessors)

- (void)addSubSettingsObject:(REThemeButtonSettings *)buttonSettings;
- (void)removeSubSettingsObject:(REThemeButtonSettings *)buttonSettings;
- (void)addSubSettings:(NSSet *)buttonSettings;
- (void)removeSubSettings:(NSSet *)buttonSettings;

@end
