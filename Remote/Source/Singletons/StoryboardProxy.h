//
// StoryboardProxy.h
// Remote
//
// Created by Jason Cardwell on 4/25/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@class   ColorSelectionViewController,
         LabelEditingViewController,
         REButtonEditingViewController,
         IconEditingViewController,
         REDetailedButtonEditingViewController,
         IconSelectionViewController,
         CommandEditingViewController,
         REButtonGroupEditingViewController,
         BackgroundEditingViewController,
         RERemoteEditingViewController,
         SettingsViewController,
         LogsViewController,
         LaunchScreenViewController;

@interface StoryboardProxy : NSObject

+ (UIStoryboard *)                       auxiliaryStoryboard;
+ (UIStoryboard *)                       mainStoryboard;
+ (ColorSelectionViewController *)       colorSelectionViewController;
+ (LabelEditingViewController *)         labelEditingViewController;
+ (REButtonEditingViewController *)        buttonEditingViewController;
+ (IconEditingViewController *)          iconEditingViewController;
+ (REDetailedButtonEditingViewController *)detailedButtonEditingViewController;
+ (IconSelectionViewController *)        iconSelectionViewController;
+ (CommandEditingViewController *)       commandEditingViewController;
+ (REButtonGroupEditingViewController *)   buttonGroupEditingViewController;
+ (RERemoteEditingViewController *)        remoteEditingViewController;
+ (BackgroundEditingViewController *)    backgroundEditingViewController;
+ (SettingsViewController *)             settingsViewController;
+ (LogsViewController *)                 logsViewController;
+ (LaunchScreenViewController *)         launchScreenViewController;

@end
