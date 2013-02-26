//
// StoryboardProxy.m
// iPhonto
//
// Created by Jason Cardwell on 4/25/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "StoryboardProxy.h"

static int            ddLogLevel = DefaultDDLogLevel;
static UIStoryboard * auxiliaryStoryboard, * mainStoryboard;

@implementation StoryboardProxy

+ (void)initialize {
    if (self == [StoryboardProxy class]) {
        auxiliaryStoryboard = [UIStoryboard storyboardWithName:(([UserDefaults boolForKey:@"autolayout"] == YES) ? @"AuxiliaryStoryboard-Autolayout" : @"AuxiliaryStoryboard")
                                                        bundle:nil];
        if (!auxiliaryStoryboard) DDLogError(@"%@\n\tfailed to retrieve auxiliary storyboard", ClassTagString);

        mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        if (!mainStoryboard) DDLogError(@"%@\n\tfailed to retrieve main storyboard", ClassTagString);
    }
}

+ (UIStoryboard *)auxiliaryStoryboard {
    return auxiliaryStoryboard;
}

+ (UIStoryboard *)mainStoryboard {
    return mainStoryboard;
}

+ (ColorSelectionViewController *)colorSelectionViewController {
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Color Selection"];
}

+ (LabelEditingViewController *)labelEditingViewController {
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Label Editor"];
}

+ (ButtonEditingViewController *)buttonEditingViewController {
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Button Editor"];
}

+ (IconEditingViewController *)iconEditingViewController {
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Icon Editor"];
}

+ (DetailedButtonEditingViewController *)detailedButtonEditingViewController {
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Detailed Button Editor"];
}

+ (IconSelectionViewController *)iconSelectionViewController {
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Icon Selection"];
}

+ (CommandEditingViewController *)commandEditingViewController {
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Command Editor"];
}

+ (ButtonGroupEditingViewController *)buttonGroupEditingViewController {
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Button Group Editor"];
}

+ (RemoteEditingViewController *)remoteEditingViewController {
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Remote Editor"];
}

+ (BackgroundEditingViewController *)backgroundEditingViewController {
    return [auxiliaryStoryboard instantiateViewControllerWithIdentifier:@"Background Editor"];
}

+ (SettingsViewController *)settingsViewController {
    return [mainStoryboard instantiateViewControllerWithIdentifier:@"Settings"];
}

+ (LogsViewController *)logsViewController {
    return [mainStoryboard instantiateViewControllerWithIdentifier:@"Logs"];
}

+ (LaunchScreenViewController *)launchScreenViewController {
    return (LaunchScreenViewController *)[mainStoryboard instantiateInitialViewController];
}

@end
