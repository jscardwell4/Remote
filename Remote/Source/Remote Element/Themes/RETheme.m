//
//  RETheme.m
//  Remote
//
//  Created by Jason Cardwell on 4/8/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RETheme_Private.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Theme
////////////////////////////////////////////////////////////////////////////////
@implementation RETheme

@dynamic theme, backgroundColors, iconColors,  titleStyles, name, elements;

+ (BOOL)isValidThemeName:(NSString *)name
{
    return StringIsNotEmpty(name);
}

+ (instancetype)themeWithName:(NSString *)name
{
    RETheme * theme = [self MR_findFirstByAttribute:@"name" withValue:name];
    if (!theme && [self isValidThemeName:name])
    {
        theme = [self MR_createEntity];
        theme.name = [name copy];
        [theme initializeColorsAndStyles];
    }
    return theme;
}

+ (instancetype)themeWithName:(NSString *)name context:(NSManagedObjectContext *)context
{
    RETheme * theme = [self MR_findFirstByAttribute:@"name" withValue:name inContext:context];
    if (!theme && [self isValidThemeName:name])
    {
        theme = [self MR_createInContext:context];
        theme.name = [name copy];
        [theme initializeColorsAndStyles];
    }
    return theme;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.backgroundColors = [REControlStateColorSet MR_createInContext:self.managedObjectContext];
    self.iconColors       = [REControlStateColorSet MR_createInContext:self.managedObjectContext];
    self.titleStyles      = [REControlStateTitleSet MR_createInContext:self.managedObjectContext];
}

- (void)initializeColorsAndStyles {}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Builtin Themes
////////////////////////////////////////////////////////////////////////////////
MSKIT_STRING_CONST REThemeNightshadeName = @"Nightshade";
MSKIT_STRING_CONST REThemePowerBlueName  = @"Power Blue";

@implementation REBuiltinTheme


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
    _shouldInitializeColors = YES;
}

- (void)initializeColorsAndStyles
{
    if (!_shouldInitializeColors) return;
    if ([self.name isEqualToString:REThemeNightshadeName])
        [self initializeNightshadeColorsAndStyles];
    else if ([self.name isEqualToString:REThemePowerBlueName])
        [self initializePowerBlueColorsAndStyles];
    _shouldInitializeColors = NO;
}

- (void)initializeNightshadeColorsAndStyles
{
    self.backgroundColors[UIControlStateNormal] = [DarkTextColor colorByLighteningTo:.025f];

    NSMutableParagraphStyle * paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment     = NSTextAlignmentCenter;
    
    NSMutableDictionary * attributes =
        [@{ NSFontAttributeName            : [UIFont fontWithName:@"Optima-Bold" size:20.0],
            NSKernAttributeName            : NullObject,
            NSLigatureAttributeName        : @1,
            NSForegroundColorAttributeName : WhiteColor,
            NSStrokeWidthAttributeName     : @(-2.0),
            NSStrokeColorAttributeName     : [WhiteColor colorWithAlphaComponent:.5],
            NSParagraphStyleAttributeName  : paragraphStyle } mutableCopy];
        
    NSAttributedString * normalTitle = [NSAttributedString attributedStringWithString:@"normal title"
                                                                           attributes:attributes];
    self.titleStyles[UIControlStateNormal] = normalTitle;

    attributes[NSStrokeColorAttributeName] = [UIColor colorWithRed:0
                                                             green:175.0/255.0
                                                              blue:1.0
                                                             alpha:0.5];

    attributes[NSForegroundColorAttributeName] = [UIColor colorWithRed:0
                                                                 green:175.0/255.0
                                                                  blue:1.0
                                                                 alpha:1.0];

    self.titleStyles[UIControlStateHighlighted] = [NSAttributedString
                                                   attributedStringWithString:@"highlighted title"
                                                                   attributes:attributes];
}

- (void)initializePowerBlueColorsAndStyles
{

}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Custom Themes
////////////////////////////////////////////////////////////////////////////////
@implementation RECustomTheme @end
