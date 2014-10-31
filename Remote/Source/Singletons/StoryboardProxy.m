//
// StoryboardProxy.m
// Remote
//
// Created by Jason Cardwell on 4/25/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "StoryboardProxy.h"

static int ddLogLevel = DefaultDDLogLevel;
#pragma unused(ddLogLevel)

static UIStoryboard * auxiliaryStoryboard, * mainStoryboard;

@implementation StoryboardProxy

+ (void)initialize
{
    if (self == [StoryboardProxy class])
    {
        auxiliaryStoryboard = [UIStoryboard storyboardWithName:@"AuxiliaryStoryboard" bundle:nil];
        assert(auxiliaryStoryboard);

        mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        assert(mainStoryboard);
    }
}

+ (UIStoryboard *)auxiliaryStoryboard { return auxiliaryStoryboard; }

+ (UIStoryboard *)mainStoryboard { return mainStoryboard; }

+ (ColorSelectionController *)colorSelectionController
{
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Color Selection"];
}

+ (LabelEditingViewController *)labelEditingViewController
{
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Label Editor"];
}

+ (ButtonEditingViewController *)buttonEditingViewController
{
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Button Editor"];
}

+ (IconEditingViewController *)iconEditingViewController
{
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Icon Editor"];
}

+ (DetailedButtonEditingViewController *)detailedButtonEditingViewController
{
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Detailed Button Editor"];
}

+ (IconSelectionViewController *)iconSelectionViewController
{
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Icon Selection"];
}

+ (CommandEditingViewController *)commandEditingViewController
{
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Command Editor"];
}

+ (ButtonGroupEditingViewController *)buttonGroupEditingViewController
{
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Button Group Editor"];
}

+ (RemoteEditingViewController *)remoteEditingViewController
{
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Remote Editor"];
}

+ (REBackgroundEditingViewController *)backgroundEditingViewController
{
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Background Editor"];
}

+ (SettingsViewController *)settingsViewController
{
    return [mainStoryboard instantiateViewControllerWithIdentifier:@"Settings"];
}

/*
+ (UINavigationController *)bankIndexViewController
{
    return [mainStoryboard instantiateViewControllerWithIdentifier:@"Bank Index"];
}
*/

/*
+ (BankTableViewController *)bankItemViewController
{
    return [mainStoryboard instantiateViewControllerWithIdentifier:@"Bank Item"];
}
*/

/*
+ (BankCollectionController *)bankCollectionViewController
{
    return [mainStoryboard instantiateViewControllerWithIdentifier:@"Bank Item Collection"];
}
*/

/*
+ (BankViewController *)bankViewController
{
    return [mainStoryboard instantiateViewControllerWithIdentifier:@"Bank View Controller"];
}
*/

+ (MainMenuViewController *)mainMenuViewController
{
    return (MainMenuViewController *)[mainStoryboard instantiateInitialViewController];
}

+ (UIViewController *)mainControllerWithID:(NSString *)storyboardID
{
    return [mainStoryboard instantiateViewControllerWithIdentifier:storyboardID];
}

+ (UIViewController *)auxControllerWithID:(NSString *)storyboardID
{
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:storyboardID];
}

@end
