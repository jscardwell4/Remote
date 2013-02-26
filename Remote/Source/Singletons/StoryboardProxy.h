//
// StoryboardProxy.h
// iPhonto
//
// Created by Jason Cardwell on 4/25/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@class   ColorSelectionViewController,
         LabelEditingViewController,
         ButtonEditingViewController,
         IconEditingViewController,
         DetailedButtonEditingViewController,
         IconSelectionViewController,
         CommandEditingViewController,
         ButtonGroupEditingViewController,
         BackgroundEditingViewController,
         RemoteEditingViewController,
         SettingsViewController,
         LogsViewController,
         LaunchScreenViewController;

@interface StoryboardProxy : NSObject

+ (UIStoryboard *)                       auxiliaryStoryboard;
+ (UIStoryboard *)                       mainStoryboard;
+ (ColorSelectionViewController *)       colorSelectionViewController;
+ (LabelEditingViewController *)         labelEditingViewController;
+ (ButtonEditingViewController *)        buttonEditingViewController;
+ (IconEditingViewController *)          iconEditingViewController;
+ (DetailedButtonEditingViewController *)detailedButtonEditingViewController;
+ (IconSelectionViewController *)        iconSelectionViewController;
+ (CommandEditingViewController *)       commandEditingViewController;
+ (ButtonGroupEditingViewController *)   buttonGroupEditingViewController;
+ (RemoteEditingViewController *)        remoteEditingViewController;
+ (BackgroundEditingViewController *)    backgroundEditingViewController;
+ (SettingsViewController *)             settingsViewController;
+ (LogsViewController *)                 logsViewController;
+ (LaunchScreenViewController *)         launchScreenViewController;

@end
