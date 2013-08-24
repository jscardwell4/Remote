//
//  RENightshadeThemeDecorator.m
//  Remote
//
//  Created by Jason Cardwell on 7/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RETheme_Private.h"

static const int ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

#define RemoteSettings(type)      ((REThemeRemoteSettings*)[theme settingsForType:type])
#define ButtonGroupSettings(type) ((REThemeButtonGroupSettings*)[theme settingsForType:type])
#define ButtonSettings(type)      ((REThemeButtonSettings*)[theme settingsForType:type])


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Nightshade Theme Decorator
////////////////////////////////////////////////////////////////////////////////


@implementation RENightshadeThemeDecorator

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remotes
////////////////////////////////////////////////////////////////////////////////
- (void)initializeRemoteSettingsForTheme:(REBuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         /// default remote

         REThemeRemoteSettings * remoteSettings = RemoteSettings(RETypeRemote);

         // background color
         remoteSettings.backgroundColor = BlackColor;

         // background image
         remoteSettings.backgroundImage = [BOImage fetchImageNamed:@"Pro Dots" context:moc];

         // background image alpha
         remoteSettings.backgroundImageAlpha = @1;
     }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Groups
////////////////////////////////////////////////////////////////////////////////
- (void)initializeButtonGroupSettingsForTheme:(REBuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         /// default button group

         REThemeButtonGroupSettings * buttonGroupSettings = ButtonGroupSettings(RETypeButtonGroup);
         buttonGroupSettings.backgroundColor = DarkTextColor;
         buttonGroupSettings.backgroundImageAlpha = @0;
         buttonGroupSettings.backgroundImage = nil;
         buttonGroupSettings.style = @(REStyleUndefined);
         buttonGroupSettings.shape = @(REShapeUndefined);

         /// panel button group

         buttonGroupSettings = ButtonGroupSettings(REButtonGroupTypePanel);
         buttonGroupSettings.backgroundColor = [WhiteColor colorWithAlphaComponent:0.75f];

         /// selection panel button group

         buttonGroupSettings = ButtonGroupSettings(REButtonGroupTypeSelectionPanel);
         buttonGroupSettings.shape = @(REShapeRoundedRectangle);

         /// picker label button group

         buttonGroupSettings = ButtonGroupSettings(REButtonGroupTypePickerLabel);
         buttonGroupSettings.style = @(REStyleDrawBorder);
         buttonGroupSettings.shape = @(REShapeRoundedRectangle);
         buttonGroupSettings.backgroundColor = ClearColor;

         /// toolbar button group

         buttonGroupSettings = ButtonGroupSettings(REButtonGroupTypeToolbar);
         buttonGroupSettings.backgroundColor = FlipsideColor;
         buttonGroupSettings.shape = @(REShapeRectangle);

         /// dpad button group
         buttonGroupSettings = ButtonGroupSettings(REButtonGroupTypeDPad);
         buttonGroupSettings.style = @(REStyleGlossStyle1);
         buttonGroupSettings.shape = @(REShapeOval);
     }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Buttons
////////////////////////////////////////////////////////////////////////////////
- (void)initializeButtonSettingsForTheme:(REBuiltinTheme *)theme
{
    [self initializeDefaultButtonSettingsForTheme:theme];
    [self initializeToolbarButtonSettingsForTheme:theme];
    [self initializeDPadButtonSettingsForTheme:theme];
    [self initializeRockerButtonSettingsForTheme:theme];
    [self initializePanelButtonSettingsForTheme:theme];
}

- (void)initializeDefaultButtonSettingsForTheme:(REBuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         ////////////////////////////////////////////////////////////////////////////////
         /// default button settings
         ////////////////////////////////////////////////////////////////////////////////


         REThemeButtonSettings * buttonSettings = ButtonSettings(RETypeButton);

         // background colors
         buttonSettings.backgroundColors = [REControlStateColorSet
                                            controlStateSetInContext:moc
                                                         withObjects:@{
                                                                       @"normal" :
                                                                           [DarkTextColor
                                                                            colorByLighteningTo:.025f]
                                                                       }
                                            ];

         // icons
         buttonSettings.icons = [REControlStateImageSet
                                 imageSetWithColors:@{
                                                      @"normal":
                                                          WhiteColor,
                                                      @"highlighted":
                                                          [UIColor colorWithR:0 G:175 B:255 A:255],
                                                      @"disabled":
                                                          GrayColor
                                                      }
                                             images:@{}
                                           context:moc
                                 ];

         // titles
         NSMutableParagraphStyle * paragraphStyle = [NSMutableParagraphStyle new];
         paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
         paragraphStyle.alignment     = NSTextAlignmentCenter;

         buttonSettings.titles = [REControlStateTitleSet
                                  controlStateSetInContext:moc
                                  withObjects:@{
                                                @"normal":
                                                    @{
                                                        REFontNameKey:
                                                            MSDefaultFontName,
                                                        REFontSizeKey:
                                                            @20,
                                                        REForegroundColorKey:
                                                            WhiteColor,
                                                        REStrokeWidthKey:
                                                            @(-2.0),
                                                        REStrokeColorKey:
                                                            [WhiteColor colorWithAlphaComponent:.5],
                                                        REParagraphStyleKey:
                                                            paragraphStyle
                                                        },
                                                @"highlighted":
                                                    @{
                                                        REFontNameKey:
                                                            MSDefaultFontName,
                                                        REFontSizeKey:
                                                            @20,
                                                        REForegroundColorKey:
                                                            [UIColor colorWithR:0 G:175 B:255 A:255],
                                                        REStrokeWidthKey:
                                                            @(-2.0),
                                                        REStrokeColorKey:
                                                            [UIColor colorWithR:0 G:255 B:255 A:127],
                                                        REParagraphStyleKey:
                                                            paragraphStyle
                                                        }
                                                }
                                  ];

         // title insets
         buttonSettings.titleInsets = NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20));

         // style
         buttonSettings.style = @(REStyleApplyGloss);

         // shape
         buttonSettings.shape = @(REShapeRoundedRectangle);
     }];
}

- (void)initializeToolbarButtonSettingsForTheme:(REBuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         ////////////////////////////////////////////////////////////////////////////////
         /// toolbar button
         ////////////////////////////////////////////////////////////////////////////////


         REThemeButtonSettings * buttonSettings = ButtonSettings(REButtonTypeToolbar);

         // icons
         buttonSettings.icons = [REControlStateImageSet
                                 imageSetWithColors:@{
                                                     @"normal":
                                                         WhiteColor,
                                                     @"highlighted":
                                                         [UIColor colorWithR:0 G:175 B:255 A:255],
                                                     @"disabled":
                                                         GrayColor
                                                     }
                                             images:@{}
                                           context:moc
                                 ];

         // background colors
         buttonSettings.backgroundColors = [REControlStateColorSet
                                            controlStateSetInContext:moc
                                                         withObjects:@{
                                                                       @"normal":
                                                                           ClearColor
                                                                       }
                                            ];

         // style
         buttonSettings.style = @(REStyleUndefined);


         ////////////////////////////////////////////////////////////////////////////////
         /// battery status button (toolbar)
         ////////////////////////////////////////////////////////////////////////////////


         REThemeButtonSettings * buttonSubSettings = [REThemeButtonSettings
                                                      themeSettingsWithType:REButtonTypeBatteryStatus
                                                                    context:moc];

         // icons
         buttonSubSettings.icons = [REControlStateImageSet
                                    imageSetWithColors:@{
                                                        @"normal":
                                                            WhiteColor,
                                                        @"selected":
                                                            LightGrayColor,
                                                        @"disabled":
                                                            LightGrayColor,
                                                        @"highlighted":
                                                            LightGrayColor
                                                        }
                                                images:@{
                                                        @"normal":
                                                            @"49-battery",
                                                        @"selected":
                                                            @"09-lightning",
                                                        @"disabled":
                                                            @"396-power-plug"
                                                        }
                                              context:moc
                                    ];

         // add subsettings to toolbar button settings
         [buttonSettings addSubSettingsObject:buttonSubSettings];


         ////////////////////////////////////////////////////////////////////////////////
         /// connection status button (toolbar)
         ////////////////////////////////////////////////////////////////////////////////


         buttonSubSettings = [REThemeButtonSettings themeSettingsWithType:REButtonTypeConnectionStatus
                                                                  context:moc];

         // icons
         buttonSubSettings.icons = [REControlStateImageSet
                                    imageSetWithColors:@{
                                                        @"normal":
                                                            GrayColor,
                                                        @"selected":
                                                            WhiteColor
                                                        }
                                                images:@{
                                                        @"normal":
                                                            @"58-wifi"
                                                        }
                                              context:moc
                                    ];

         // add subsettings to toolbar button settings
         [buttonSettings addSubSettingsObject:buttonSubSettings];
     }];
}

- (void)initializeDPadButtonSettingsForTheme:(REBuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         ////////////////////////////////////////////////////////////////////////////////
         /// dpad button
         ////////////////////////////////////////////////////////////////////////////////


         REThemeButtonSettings * buttonSettings = ButtonSettings(REButtonTypeDPad);

         // style
         buttonSettings.style = @(REStyleUndefined);

         // shape
         buttonSettings.shape = @(REShapeUndefined);

         // background colors
         buttonSettings.backgroundColors = [REControlStateColorSet
                                            controlStateSetInContext:moc
                                                         withObjects:@{
                                                                       @"normal" :
                                                                           ClearColor
                                                                       }
                                           ];


         ////////////////////////////////////////////////////////////////////////////////
         /// center (dpad)
         ////////////////////////////////////////////////////////////////////////////////


         REControlStateTitleSet * titles = [ButtonSettings(RETypeButton).titles copy];
         [titles setObject:@"OK" forTitleAttribute:RETitleTextKey];

         REThemeButtonSettings * buttonSubSettings = [REThemeButtonSettings themeSettingsWithType:REButtonTypeDPadCenter
                                                                                          context:moc];
         buttonSubSettings.titles = titles;

         // add subsettings to dpad button settings
         [buttonSettings addSubSettingsObject:buttonSubSettings];
         
         
         ////////////////////////////////////////////////////////////////////////////////
         /// up (dpad)
         ////////////////////////////////////////////////////////////////////////////////

         titles = [titles copy];
         [titles setObject:@"FontAwesome" forTitleAttribute:REFontNameKey];
         [titles setObject:@32.0f forTitleAttribute:REFontSizeKey];
         [titles setObject:[UIFont fontAwesomeIconForName:@"caret-up"] forTitleAttribute:RETitleTextKey];


         buttonSubSettings = [REThemeButtonSettings themeSettingsWithType:REButtonTypeDPadUp
                                                                  context:moc];
         buttonSubSettings.titles = titles;

         // add subsettings to dpad button settings
         [buttonSettings addSubSettingsObject:buttonSubSettings];


         ////////////////////////////////////////////////////////////////////////////////
         /// down (dpad)
         ////////////////////////////////////////////////////////////////////////////////

         titles = [titles copy];
         [titles setObject:[UIFont fontAwesomeIconForName:@"caret-down"] forTitleAttribute:RETitleTextKey];

         buttonSubSettings = [REThemeButtonSettings themeSettingsWithType:REButtonTypeDPadDown
                                                                  context:moc];
         buttonSubSettings.titles = titles;

         // add subsettings to dpad button settings
         [buttonSettings addSubSettingsObject:buttonSubSettings];


         ////////////////////////////////////////////////////////////////////////////////
         /// left (dpad)
         ////////////////////////////////////////////////////////////////////////////////


         titles = [titles copy];
         [titles setObject:[UIFont fontAwesomeIconForName:@"caret-left"] forTitleAttribute:RETitleTextKey];

         buttonSubSettings = [REThemeButtonSettings themeSettingsWithType:REButtonTypeDPadLeft
                                                                  context:moc];
         buttonSubSettings.titles = titles;

         // add subsettings to dpad button settings
         [buttonSettings addSubSettingsObject:buttonSubSettings];


         ////////////////////////////////////////////////////////////////////////////////
         /// right (dpad)
         ////////////////////////////////////////////////////////////////////////////////


         titles = [titles copy];
         [titles setObject:[UIFont fontAwesomeIconForName:@"caret-right"] forTitleAttribute:RETitleTextKey];

         buttonSubSettings = [REThemeButtonSettings themeSettingsWithType:REButtonTypeDPadRight
                                                                  context:moc];
         buttonSubSettings.titles = titles;


         // add subsettings to dpad button settings
         [buttonSettings addSubSettingsObject:buttonSubSettings];
     }];
}

- (void)initializeNumberpadButtonSettingsForTheme:(REBuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         ////////////////////////////////////////////////////////////////////////////////
         /// numberpad button
         ////////////////////////////////////////////////////////////////////////////////
     }];
}

- (void)initializeTransportButtonSettingsForTheme:(REBuiltinTheme *)theme
{
    static dispatch_once_t onceToken;
    static NSDictionary const * index;
    dispatch_once(&onceToken, ^{
        index = @{@(REButtonTypeTransportPlay)   : @"play",
                  @(REButtonTypeTransportPause)  : @"pause",
                  @(REButtonTypeTransportStop)   : @"stop",
                  @(REButtonTypeTransportFF)     : @"fast-forward",
                  @(REButtonTypeTransportRewind) : @"backward",
                  @(REButtonTypeTransportSkip)   : @"step-forward",
                  @(REButtonTypeTransportReplay) : @"step-backward",
                  @(REButtonTypeTransportRecord) : @"circle"};
    });

    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         ////////////////////////////////////////////////////////////////////////////////
         /// transport button
         ////////////////////////////////////////////////////////////////////////////////
         REControlStateTitleSet * titles = [ButtonSettings(RETypeButton).titles copy];
         [titles setObject:@"FontAwesome" forTitleAttribute:REFontNameKey];
         [titles setObject:@32 forTitleAttribute:REFontSizeKey];

         REThemeButtonSettings * buttonSettings = ButtonSettings(REButtonTypeTransport);
         buttonSettings.titles = titles;

         for (NSNumber * type in index)
         {
             REType t = [type integerValue];
             REThemeButtonSettings * buttonSubSettings = [REThemeButtonSettings themeSettingsWithType:t
                                                                                              context:moc];
             REControlStateTitleSet * subSettingTitles = [buttonSettings.titles copy];
             NSString * iconName = index[type];
             [subSettingTitles setObject:[UIFont fontAwesomeIconForName:iconName] forTitleAttribute:RETitleTextKey];
             buttonSubSettings.titles = subSettingTitles;
             [buttonSettings addSubSettingsObject:buttonSubSettings];
         }
     }];
}

- (void)initializeRockerButtonSettingsForTheme:(REBuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         ////////////////////////////////////////////////////////////////////////////////
         /// rocker button
         ////////////////////////////////////////////////////////////////////////////////


         REThemeButtonSettings * buttonSettings = ButtonSettings(REButtonTypePickerLabel);
         buttonSettings.backgroundColors = [REControlStateColorSet
                                            controlStateSetInContext:moc
                                                         withObjects:@{
                                                                       @"normal":
                                                                           DarkTextColor
                                                                       }
                                            ];
         buttonSettings.style = @(REStyleUndefined);
         buttonSettings.shape = @(REShapeRoundedRectangle);
         buttonSettings.titles = [ButtonSettings(RETypeButton).titles copy];


         ////////////////////////////////////////////////////////////////////////////////
         /// top button (rocker)
         ////////////////////////////////////////////////////////////////////////////////


         REThemeButtonSettings * buttonSubSettings = [REThemeButtonSettings themeSettingsWithType:REButtonTypePickerLabelTop
                                                                                          context:moc];
         buttonSubSettings.style = @(REStyleGlossStyle3);
         buttonSubSettings.icons = [REControlStateImageSet
                                    imageSetWithColors:ButtonSettings(RETypeButton).icons.colors
                                                images:@{@"normal": @"436-plus"}
                                               context:moc];
         [buttonSettings addSubSettingsObject:buttonSubSettings];


         ////////////////////////////////////////////////////////////////////////////////
         /// top button (rocker)
         ////////////////////////////////////////////////////////////////////////////////


         buttonSubSettings = [REThemeButtonSettings themeSettingsWithType:REButtonTypePickerLabelBottom
                                                                  context:moc];
         buttonSubSettings.style = @(REStyleGlossStyle4);
         buttonSubSettings.icons = [REControlStateImageSet
                                    imageSetWithColors:ButtonSettings(RETypeButton).icons.colors
                                                images:@{@"normal": @"437-minus"}
                                               context:moc];
         [buttonSettings addSubSettingsObject:buttonSubSettings];
     }];
}

- (void)initializePanelButtonSettingsForTheme:(REBuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         ////////////////////////////////////////////////////////////////////////////////
         /// tuck button
         ////////////////////////////////////////////////////////////////////////////////
         REThemeButtonSettings * buttonSettings = ButtonSettings(REButtonTypePanel);
         REThemeButtonSettings * buttonSubSettings = [REThemeButtonSettings themeSettingsWithType:REButtonTypeTuck
                                                                                          context:moc];

         buttonSubSettings.backgroundColors = [REControlStateColorSet controlStateSetInContext:moc
                                                                                   withObjects:@{@"normal": ClearColor}];
         buttonSubSettings.icons = [REControlStateImageSet imageSetWithColors:@{}
                                                                       images:@{}
                                                                      context:moc];

         [buttonSettings addSubSettingsObject:buttonSubSettings];

     }];

    [self initializeNumberpadButtonSettingsForTheme:theme];
    [self initializeTransportButtonSettingsForTheme:theme];

}

@end

