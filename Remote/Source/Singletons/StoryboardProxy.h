//
// StoryboardProxy.h
// Remote
//
// Created by Jason Cardwell on 4/25/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
@import CocoaLumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"

@class   ColorSelectionController,
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
         MainMenuViewController,
         REBackgroundEditingViewController,
         BankTableViewController,
         BankCollectionController,
         BankViewController;

@interface StoryboardProxy : NSObject

+ (UIStoryboard *)auxiliaryStoryboard;
+ (UIStoryboard *)mainStoryboard;
+ (ColorSelectionController *)colorSelectionController;
+ (LabelEditingViewController *)labelEditingViewController;
+ (ButtonEditingViewController *)buttonEditingViewController;
+ (IconEditingViewController *)iconEditingViewController;
+ (DetailedButtonEditingViewController *)detailedButtonEditingViewController;
+ (IconSelectionViewController *)iconSelectionViewController;
+ (CommandEditingViewController *)commandEditingViewController;
+ (ButtonGroupEditingViewController *)buttonGroupEditingViewController;
+ (RemoteEditingViewController *)remoteEditingViewController;
+ (REBackgroundEditingViewController *)backgroundEditingViewController;
//+ (UINavigationController *)bankIndexViewController;
//+ (BankTableViewController *)bankItemViewController;
//+ (BankCollectionController *)bankCollectionViewController;
//+ (BankViewController *)bankViewController;
+ (SettingsViewController *)settingsViewController;
+ (MainMenuViewController *)mainMenuViewController;

+ (UIViewController *)mainControllerWithID:(NSString *)storyboardID;
+ (UIViewController *)auxControllerWithID:(NSString *)storyboardID;

@end
