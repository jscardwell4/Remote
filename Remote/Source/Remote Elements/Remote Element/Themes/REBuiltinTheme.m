//
//  REBuiltinTheme.m
//  Remote
//
//  Created by Jason Cardwell on 4/8/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RETheme_Private.h"

static const int ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Builtin Themes
////////////////////////////////////////////////////////////////////////////////


MSKIT_STRING_CONST REThemeNightshadeName = @"Nightshade";
MSKIT_STRING_CONST REThemePowerBlueName  = @"Power Blue";

@implementation REBuiltinTheme

@synthesize decorator = __decorator;


+ (BOOL)isValidThemeName:(NSString *)name
{
    static const NSSet * kThemeNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kThemeNames = [@[REThemeNightshadeName, REThemePowerBlueName] set];
    });
    return ([super isValidThemeName:name] && [kThemeNames containsObject:name]);
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (MSModelObjectShouldInitialize) _shouldInitializeColors = YES;
}

- (void)initializeSettings
{
    [super initializeSettings];
    _shouldInitializeColors = NO;

    MSLogDebug(@"theme initialized:\n%@", [self deepDescription]);

}

- (void)initializeRemoteSettings
{
    [super initializeRemoteSettings];
    if (_shouldInitializeColors) [self.decorator initializeRemoteSettingsForTheme:self];
}

- (void)initializeButtonGroupSettings
{
    [super initializeButtonGroupSettings];
    if (_shouldInitializeColors) [self.decorator initializeButtonGroupSettingsForTheme:self];
}

- (void)initializeButtonSettings
{
    [super initializeButtonSettings];
    if (_shouldInitializeColors) [self.decorator initializeButtonSettingsForTheme:self];
}

- (REBuiltinThemeDecorator *)decorator
{
    static dispatch_once_t onceToken;
    static NSDictionary const * index;
    dispatch_once(&onceToken, ^{
        index = @{ REThemeNightshadeName: @"RENightshadeThemeDecorator",
                   REThemePowerBlueName: @"REPowerBlueThemeDecorator" };
    });

    if (!__decorator)
    {
        NSString * className = index[self.name];
        __decorator = (className ? [NSClassFromString(className) new] : nil);
    }

    return __decorator;
}

@end


@implementation REBuiltinThemeDecorator

- (void)initializeRemoteSettingsForTheme:(REBuiltinTheme *)theme {}

- (void)initializeButtonGroupSettingsForTheme:(REBuiltinTheme *)theme {}

- (void)initializeButtonSettingsForTheme:(REBuiltinTheme *)theme {}

@end

