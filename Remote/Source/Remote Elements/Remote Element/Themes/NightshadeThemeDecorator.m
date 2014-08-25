//
//  NightshadeThemeDecorator.m
//  Remote
//
//  Created by Jason Cardwell on 7/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "Theme_Private.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

#define RemoteSettings(role)                                   \
    ((ThemeRemoteSettings*)[theme settingsForType:RETypeRemote \
                                         withRole:role])
#define ButtonGroupSettings(role)                                        \
    ((ThemeButtonGroupSettings*)[theme settingsForType:RETypeButtonGroup \
                                              withRole:role])
#define ButtonSettings(role)                                   \
    ((ThemeButtonSettings*)[theme settingsForType:RETypeButton \
                                         withRole:role])


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Nightshade Theme Decorator
////////////////////////////////////////////////////////////////////////////////


@implementation RENightshadeThemeDecorator

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Remotes
////////////////////////////////////////////////////////////////////////////////
- (void)initializeRemoteSettingsForTheme:(BuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         /// default remote

         ThemeRemoteSettings * remoteSettings = RemoteSettings(RERoleUndefined);

         // background color
         remoteSettings.backgroundColor = BlackColor;

         // background image
         remoteSettings.backgroundImage = [Image
                                           existingObjectWithUUID:@"32734604-9B4D-4511-BC47-7367A2C3A710"
                                                  context:moc];

         // background image alpha
         remoteSettings.backgroundImageAlpha = @1;
     }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Groups
////////////////////////////////////////////////////////////////////////////////
- (void)initializeButtonGroupSettingsForTheme:(BuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         /// default button group

         ThemeButtonGroupSettings * buttonGroupSettings = ButtonGroupSettings(RERoleUndefined);
         buttonGroupSettings.backgroundColor = DarkTextColor;
         buttonGroupSettings.backgroundImageAlpha = @0;
         buttonGroupSettings.backgroundImage = nil;
         buttonGroupSettings.style = @(REStyleUndefined);
         buttonGroupSettings.shape = @(REShapeUndefined);

         /// panel button group

//         buttonGroupSettings = ButtonGroupSettings(REButtonGroupRolePanel);
         buttonGroupSettings.backgroundColor = [WhiteColor colorWithAlphaComponent:0.75f];

         /// selection panel button group

         buttonGroupSettings = ButtonGroupSettings(REButtonGroupRoleSelectionPanel);
         buttonGroupSettings.shape = @(REShapeRoundedRectangle);

         /// picker label button group

         buttonGroupSettings = ButtonGroupSettings(REButtonGroupRoleRocker);
         buttonGroupSettings.style = @(REStyleDrawBorder);
         buttonGroupSettings.shape = @(REShapeRoundedRectangle);
         buttonGroupSettings.backgroundColor = ClearColor;

         /// toolbar button group

         buttonGroupSettings = ButtonGroupSettings(REButtonGroupRoleToolbar);
         buttonGroupSettings.backgroundColor = FlipsideColor;
         buttonGroupSettings.shape = @(REShapeRectangle);

         /// dpad button group
         buttonGroupSettings = ButtonGroupSettings(REButtonGroupRoleDPad);
         buttonGroupSettings.style = @(REStyleGlossStyle1);
         buttonGroupSettings.shape = @(REShapeOval);
     }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Buttons
////////////////////////////////////////////////////////////////////////////////
- (void)initializeButtonSettingsForTheme:(BuiltinTheme *)theme
{
    [self initializeDefaultButtonSettingsForTheme:theme];
    [self initializeToolbarButtonSettingsForTheme:theme];
    [self initializeDPadButtonSettingsForTheme:theme];
    [self initializeRockerButtonSettingsForTheme:theme];
    [self initializePanelButtonSettingsForTheme:theme];
}

- (void)initializeDefaultButtonSettingsForTheme:(BuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         ////////////////////////////////////////////////////////////////////////////////
         /// default button settings
         ////////////////////////////////////////////////////////////////////////////////


         ThemeButtonSettings * buttonSettings = ButtonSettings(RERoleUndefined);

         // background colors
         buttonSettings.backgroundColors = [ControlStateColorSet
                                            controlStateSetInContext:moc
                                                         withObjects:@{
                                                                       @"normal" :
                                                                           [DarkTextColor
                                                                            colorByLighteningTo:.025f]
                                                                       }
                                            ];

         // icons
         buttonSettings.icons = [ControlStateImageSet
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

         buttonSettings.titles = [ControlStateTitleSet
                                  controlStateSetInContext:moc
                                  withObjects:@{
                                                @"normal":
                                                    @{
                                                        REFontAttributeKey:
                                                            [REFont fontWithName:MSDefaultFontName size:@20],//[@"@" join:@[MSDefaultFontName, @"20"]],
                                                        REForegroundColorAttributeKey:
                                                            WhiteColor,
                                                        REStrokeWidthAttributeKey:
                                                            @(-2.0),
                                                        REStrokeColorAttributeKey:
                                                            [WhiteColor colorWithAlphaComponent:.5]//,
//                                                        REParagraphStyleAttributeKey:
//                                                            [paragraphStyle copy]
                                                        },
                                                @"highlighted":
                                                    @{
                                                        REFontAttributeKey:
                                                            [REFont fontWithName:MSDefaultFontName size:@20],//[@"@" join:@[MSDefaultFontName, @"20"]],
                                                        REForegroundColorAttributeKey:
                                                            [UIColor colorWithR:0 G:175 B:255 A:255],
                                                        REStrokeWidthAttributeKey:
                                                            @(-2.0),
                                                        REStrokeColorAttributeKey:
                                                            [UIColor colorWithR:0 G:255 B:255 A:127]//,
//                                                        REParagraphStyleAttributeKey:
//                                                            [paragraphStyle copy]
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

- (void)initializeToolbarButtonSettingsForTheme:(BuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         ////////////////////////////////////////////////////////////////////////////////
         /// toolbar button
         ////////////////////////////////////////////////////////////////////////////////


         ThemeButtonSettings * buttonSettings = ButtonSettings(REButtonRoleToolbar);

         // icons
         buttonSettings.icons = [ControlStateImageSet
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
         buttonSettings.backgroundColors = [ControlStateColorSet
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


         ThemeButtonSettings * buttonSubSettings = [ThemeButtonSettings
                                                      themeSettingsWithRole:REButtonRoleBatteryStatus
                                                                    context:moc];

         // icons
         buttonSubSettings.icons = [ControlStateImageSet
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
                                                            @"BADA12DA-FAE1-4E2D-9843-0BD2BD7AD463",
                                                        @"selected":
                                                            @"C25B5084-F167-44F8-9855-42A991936624",
                                                        @"disabled":
                                                            @"6ED6E547-EBF4-478A-B4F5-47ACF2C1FFDA"
                                                        }
                                              context:moc
                                    ];

         // add subsettings to toolbar button settings
         [buttonSettings addSubSettingsObject:buttonSubSettings];


         ////////////////////////////////////////////////////////////////////////////////
         /// connection status button (toolbar)
         ////////////////////////////////////////////////////////////////////////////////


         buttonSubSettings = [ThemeButtonSettings themeSettingsWithRole:REButtonRoleConnectionStatus
                                                                  context:moc];

         // icons
         buttonSubSettings.icons = [ControlStateImageSet
                                    imageSetWithColors:@{
                                                        @"normal":
                                                            GrayColor,
                                                        @"selected":
                                                            WhiteColor
                                                        }
                                                images:@{
                                                        @"normal":
                                                            @"D112F2D8-5E77-405A-B8EA-1DD0E9DE7ED9"
                                                        }
                                              context:moc
                                    ];

         // add subsettings to toolbar button settings
         [buttonSettings addSubSettingsObject:buttonSubSettings];
     }];
}

- (void)initializeDPadButtonSettingsForTheme:(BuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         ////////////////////////////////////////////////////////////////////////////////
         /// dpad button
         ////////////////////////////////////////////////////////////////////////////////


         ThemeButtonSettings * buttonSettings = ButtonSettings(REButtonRoleDPad);

         // style
         buttonSettings.style = @(REStyleUndefined);

         // shape
         buttonSettings.shape = @(REShapeUndefined);

         // background colors
         buttonSettings.backgroundColors = [ControlStateColorSet
                                            controlStateSetInContext:moc
                                                         withObjects:@{
                                                                       @"normal" :
                                                                           ClearColor
                                                                       }
                                           ];


         ////////////////////////////////////////////////////////////////////////////////
         /// center (dpad)
         ////////////////////////////////////////////////////////////////////////////////


         ControlStateTitleSet * titles = [ButtonSettings(RETypeButton).titles copy];
         titles[[@"." join:@[@"normal", RETitleTextAttributeKey]]] = @"OK";

         ThemeButtonSettings * buttonSubSettings = [ThemeButtonSettings themeSettingsWithRole:REButtonRoleDPadCenter
                                                                                      context:moc];
         buttonSubSettings.titles = titles;

         // add subsettings to dpad button settings
         [buttonSettings addSubSettingsObject:buttonSubSettings];
         
         
         ////////////////////////////////////////////////////////////////////////////////
         /// up (dpad)
         ////////////////////////////////////////////////////////////////////////////////

         titles = [titles copy];
         titles[[@"." join:@[@"normal", REFontAttributeKey]]] =
             [REFont fontFromString:@"FontAwesome@32"];
         titles[[@"." join:@[@"normal", RETitleTextAttributeKey]]] =
             [UIFont fontAwesomeIconForName:@"caret-up"];


         buttonSubSettings = [ThemeButtonSettings themeSettingsWithRole:REButtonRoleDPadUp
                                                                  context:moc];
         buttonSubSettings.titles = titles;

         // add subsettings to dpad button settings
         [buttonSettings addSubSettingsObject:buttonSubSettings];


         ////////////////////////////////////////////////////////////////////////////////
         /// down (dpad)
         ////////////////////////////////////////////////////////////////////////////////

         titles = [titles copy];
         titles[[@"." join:@[@"normal", RETitleTextAttributeKey]]] =
             [UIFont fontAwesomeIconForName:@"caret-down"];

         buttonSubSettings = [ThemeButtonSettings themeSettingsWithRole:REButtonRoleDPadDown
                                                                  context:moc];
         buttonSubSettings.titles = titles;

         // add subsettings to dpad button settings
         [buttonSettings addSubSettingsObject:buttonSubSettings];


         ////////////////////////////////////////////////////////////////////////////////
         /// left (dpad)
         ////////////////////////////////////////////////////////////////////////////////


         titles = [titles copy];
         titles[[@"." join:@[@"normal", RETitleTextAttributeKey]]] =
             [UIFont fontAwesomeIconForName:@"caret-left"];

         buttonSubSettings = [ThemeButtonSettings themeSettingsWithRole:REButtonRoleDPadLeft
                                                                  context:moc];
         buttonSubSettings.titles = titles;

         // add subsettings to dpad button settings
         [buttonSettings addSubSettingsObject:buttonSubSettings];


         ////////////////////////////////////////////////////////////////////////////////
         /// right (dpad)
         ////////////////////////////////////////////////////////////////////////////////


         titles = [titles copy];
         titles[[@"." join:@[@"normal", RETitleTextAttributeKey]]] =
             [UIFont fontAwesomeIconForName:@"caret-right"];

         buttonSubSettings = [ThemeButtonSettings themeSettingsWithRole:REButtonRoleDPadRight
                                                                  context:moc];
         buttonSubSettings.titles = titles;


         // add subsettings to dpad button settings
         [buttonSettings addSubSettingsObject:buttonSubSettings];
     }];
}

- (void)initializeNumberpadButtonSettingsForTheme:(BuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         ////////////////////////////////////////////////////////////////////////////////
         /// numberpad button
         ////////////////////////////////////////////////////////////////////////////////
     }];
}

- (void)initializeTransportButtonSettingsForTheme:(BuiltinTheme *)theme
{
    static dispatch_once_t onceToken;
    static NSDictionary const * index;
    dispatch_once(&onceToken, ^{
        index = @{@(REButtonRoleTransportPlay)   : @"play",
                  @(REButtonRoleTransportPause)  : @"pause",
                  @(REButtonRoleTransportStop)   : @"stop",
                  @(REButtonRoleTransportFF)     : @"fast-forward",
                  @(REButtonRoleTransportRewind) : @"backward",
                  @(REButtonRoleTransportSkip)   : @"step-forward",
                  @(REButtonRoleTransportReplay) : @"step-backward",
                  @(REButtonRoleTransportRecord) : @"circle"};
    });

    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         ////////////////////////////////////////////////////////////////////////////////
         /// transport button
         ////////////////////////////////////////////////////////////////////////////////
         ControlStateTitleSet * titles = [ButtonSettings(RETypeButton).titles copy];
         titles[[@"." join:@[@"normal", REFontAttributeKey]]] =
             [REFont fontFromString:@"FontAwesome@32"];


         ThemeButtonSettings * buttonSettings = ButtonSettings(REButtonRoleTransport);
         buttonSettings.titles = titles;

         for (NSNumber * type in index)
         {
             RERole role = [type unsignedShortValue];
             ThemeButtonSettings * buttonSubSettings = [ThemeButtonSettings
                                                        themeSettingsWithRole:role
                                                                      context:moc];
             ControlStateTitleSet * subSettingTitles = [buttonSettings.titles copy];
             NSString * iconName = index[type];
             subSettingTitles[[@"." join:@[@"normal", RETitleTextAttributeKey]]] =
                 [UIFont fontAwesomeIconForName:iconName];
             buttonSubSettings.titles = subSettingTitles;
             [buttonSettings addSubSettingsObject:buttonSubSettings];
         }
     }];
}

- (void)initializeRockerButtonSettingsForTheme:(BuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         ////////////////////////////////////////////////////////////////////////////////
         /// rocker button
         ////////////////////////////////////////////////////////////////////////////////


         ThemeButtonSettings * buttonSettings = ButtonSettings(REButtonRoleRocker);
         buttonSettings.backgroundColors = [ControlStateColorSet
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


         ThemeButtonSettings * buttonSubSettings = [ThemeButtonSettings themeSettingsWithRole:REButtonRoleRockerTop
                                                                                          context:moc];
         buttonSubSettings.style = @(REStyleGlossStyle3);
//     TODO: Update
/*
         buttonSubSettings.icons = [ControlStateImageSet
                                    imageSetWithColors:ButtonSettings(RETypeButton).icons.colors
                                                images:@{@"normal":
                                                             @"439EF306-6036-47A8-B9A9-6CEE55ACD02A"}
                                               context:moc];
*/
         [buttonSettings addSubSettingsObject:buttonSubSettings];


         ////////////////////////////////////////////////////////////////////////////////
         /// top button (rocker)
         ////////////////////////////////////////////////////////////////////////////////


         buttonSubSettings = [ThemeButtonSettings themeSettingsWithRole:REButtonRoleRockerBottom
                                                                  context:moc];
         buttonSubSettings.style = @(REStyleGlossStyle4);
//     TODO: Update
/*
         buttonSubSettings.icons = [ControlStateImageSet
                                    imageSetWithColors:ButtonSettings(RETypeButton).icons.colors
                                                images:@{@"normal":
                                                             @"3DA6EC67-B294-4A7E-8E2C-B4939693D214"}
                                               context:moc];
*/
         [buttonSettings addSubSettingsObject:buttonSubSettings];
     }];
}

- (void)initializePanelButtonSettingsForTheme:(BuiltinTheme *)theme
{
    NSManagedObjectContext * moc = theme.managedObjectContext;
    [moc performBlockAndWait:
     ^{
         ////////////////////////////////////////////////////////////////////////////////
         /// tuck button
         ////////////////////////////////////////////////////////////////////////////////
         ThemeButtonSettings * buttonSettings = ButtonSettings(REButtonRolePanel);
         ThemeButtonSettings * buttonSubSettings = [ThemeButtonSettings
                                                    themeSettingsWithRole:REButtonRoleTuck
                                                                  context:moc];

         buttonSubSettings.backgroundColors = [ControlStateColorSet
                                               controlStateSetInContext:moc
                                                            withObjects:@{@"normal": ClearColor}];
         buttonSubSettings.icons = [ControlStateImageSet imageSetWithColors:@{}
                                                                       images:@{}
                                                                      context:moc];

         [buttonSettings addSubSettingsObject:buttonSubSettings];

     }];

    [self initializeNumberpadButtonSettingsForTheme:theme];
    [self initializeTransportButtonSettingsForTheme:theme];

}

@end

