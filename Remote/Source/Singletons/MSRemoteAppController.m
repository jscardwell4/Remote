//
// MSRemoteAppController.m
// Remote
//
// Created by Jason Cardwell on 5/3/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElementConstructionManager.h"
#import "RERemoteViewController.h"
#import "LaunchScreenViewController.h"
#import "CoreDataManager.h"
#import "DatabaseLoader.h"
#import "SettingsManager.h"
#import "ConnectionManager.h"
#import "MSRemoteAppController.h"
#import "UITestRunner.h"
#import "StoryboardProxy.h"

static const int   ddLogLevel   = LOG_LEVEL_DEBUG;
static const int   msLogContext = 0;
#pragma unused(ddLogLevel, msLogContext)

@implementation MSRemoteAppController {
    LaunchScreenViewController * _launchScreenVC;
    NSOperationQueue           * _workQueue;
}

+ (NSString const *)versionInfo
{

    static NSString const * kVersionInfo = nil;

    static dispatch_once_t   onceToken;
    dispatch_once(&onceToken, ^{

        #ifdef DEBUG
        NSString * prefix = @"debug";
        #else
        NSString * prefix = @"release";
        #endif

        NSMutableString * s = [@"" mutableCopy];
        if ([UserDefaults boolForKey:@"rebuild"])  [s appendString:@"-rebuild"];
        if ([UserDefaults boolForKey:@"replace"])  [s appendString:@"-replace"];
        if ([UserDefaults boolForKey:@"remote"])   [s appendString:@"-remote"];
        if ([UserDefaults boolForKey:@"uitest"])   [s appendString:@"-uitest"];
        if ([UserDefaults boolForKey:@"simulate"]) [s appendString:@"-simulate"];

        kVersionInfo = [prefix stringByAppendingString:s];

    });

    return kVersionInfo;

}

- (void)runUITests
{
    #define ButtonGroupEditingTest(focus, number, options) \
    @(UITestTypeButtonGroupEditing | focus | (uint64_t)((uint64_t)number << UITestNumberOffset) | (uint64_t)((uint64_t)options << UITestOptionsOffset))
    #define RemoteEditingTest(focus, number, options) \
    @(UITestTypeRemoteEditing | focus | (uint64_t)((uint64_t)number << UITestNumberOffset) | (uint64_t)((uint64_t)options << UITestOptionsOffset))

    NSArray * tests = @[ButtonGroupEditingTest(UITestFocusTranslation, 0, 2), // 0
                        ButtonGroupEditingTest(UITestFocusTranslation, 1, 2), // 1
                        ButtonGroupEditingTest(UITestFocusTranslation, 2, 2), // 2
                        ButtonGroupEditingTest(UITestFocusFocus,       0, 2), // 3
                        ButtonGroupEditingTest(UITestFocusAlignment,   0, 2), // 4
                        ButtonGroupEditingTest(UITestFocusAlignment,   1, 2), // 5
                        ButtonGroupEditingTest(UITestFocusAlignment,   2, 2), // 6
                        ButtonGroupEditingTest(UITestFocusAlignment,   3, 2), // 7
                        ButtonGroupEditingTest(UITestFocusAlignment,   5, 2), // 8
                        ButtonGroupEditingTest(UITestFocusAlignment,   6, 2), // 9
                        ButtonGroupEditingTest(UITestFocusAlignment,   7, 2), // 10
                        ButtonGroupEditingTest(UITestFocusAlignment,   4, 2), // 11
                        ButtonGroupEditingTest(UITestFocusAlignment,   8, 2), // 12
                        ButtonGroupEditingTest(UITestFocusInfo,        0, 2), // 13
                        ButtonGroupEditingTest(UITestFocusInfo,        1, 2), // 14
                        ButtonGroupEditingTest(UITestFocusScale,       0, 2), // 15
                        ButtonGroupEditingTest(UITestFocusDialog,      0, 3), // 16
                        RemoteEditingTest(     UITestFocusScale,       0, 2), // 17
                        RemoteEditingTest(     UITestFocusInfo,        0, 2), // 18
                        RemoteEditingTest(     UITestFocusInfo,        1, 2)  // 19
                      ];

    NSIndexSet * bgTranslationTests  = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange( 0, 3)];
    NSIndexSet * bgFocusTests        = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange( 3, 1)];
    NSIndexSet * bgAlignmentTests    = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange( 4, 9)];
    NSIndexSet * bgInfoTests         = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(13, 2)];
    NSIndexSet * bgScaleTests        = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(15, 1)];
    NSIndexSet * bgDialogTests       = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(16, 1)];

    NSIndexSet * rInfoTests          = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(18, 2)];
    NSIndexSet * rScaleTests         = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(17, 1)];

#pragma unused(bgTranslationTests, bgFocusTests, bgAlignmentTests, bgInfoTests, bgScaleTests, \
               bgDialogTests, rInfoTests, rScaleTests)

    
    NSMutableIndexSet * indices = [NSMutableIndexSet indexSet];
//    [indices addIndex:1];
    [indices addIndexes:bgScaleTests];
//    [indices addIndexes:bgTranslationTests];
//    [indices addIndexes:bgAlignmentTests];

    NSArray * selectedTests = [tests objectsAtIndexes:indices];

    [UITestRunner runTests:selectedTests];
}

#pragma mark - Shared controller and Storyboard controllers

+ (MSRemoteAppController *)sharedAppController
{
    static dispatch_once_t pred = 0;
    __strong static MSRemoteAppController * _sharedObject = nil;
    dispatch_once(&pred, ^{_sharedObject = UIApp.delegate;});
    return _sharedObject;
}

- (void)showRemote
{
    [MainQueue addOperationWithBlock:^{ [_launchScreenVC performSegueWithIdentifier:@"remoteView"
                                                                             sender:self]; }];
}

+ (void)attachLoggers
{

    [MSLog addTaggingTTYLogger];
    DDTTYLogger * ttyLogger = [DDTTYLogger sharedInstance];
    assert(ttyLogger);
    assert([ttyLogger colorsEnabled]);

    UIColor * errorColor = [UIColor colorWithR:217 G:30 B:0 A:255];

    [ttyLogger setForegroundColor:errorColor
                  backgroundColor:nil
                          forFlag:LOG_FLAG_ERROR
                          context:LOG_CONTEXT_ANY];

    [MSLog addTaggingASLLogger];

    NSString * logsDirectory = [MSLog defaultLogDirectory];

    NSDictionary * fileLoggers = @{
       @(LOG_CONTEXT_FILE)          : $(@"%@/Default",       logsDirectory),
       @(LOG_CONTEXT_PAINTER)       : $(@"%@/Painter",       logsDirectory),
       @(LOG_CONTEXT_NETWORKING)    : $(@"%@/Networking",    logsDirectory),
       @(LOG_CONTEXT_REMOTE)        : $(@"%@/Remote",        logsDirectory),
       @(LOG_CONTEXT_COREDATA)      : $(@"%@/CoreData",      logsDirectory),
       @(LOG_CONTEXT_UITESTING)     : $(@"%@/UITesting",     logsDirectory),
       @(LOG_CONTEXT_EDITOR)        : $(@"%@/Editor",        logsDirectory),
       @(LOG_CONTEXT_COMMAND)       : $(@"%@/Command",       logsDirectory),
       @(LOG_CONTEXT_CONSTRAINT)    : $(@"%@/Constraints",   logsDirectory),
       @(LOG_CONTEXT_BUILDING)      : $(@"%@/Building",      logsDirectory),
       @(LOG_CONTEXT_MAGICALRECORD) : $(@"%@/MagicalRecord", logsDirectory)
    };

    [fileLoggers enumerateKeysAndObjectsUsingBlock:^(NSNumber * key, NSString * obj, BOOL *stop)
    {
        [MSLog addDefaultFileLoggerForContext:NSUIntegerValue(key) directory:obj];
    }];

}

/*
 * Creates the application's loggers and registers default settings
 */
+ (void)initialize
{
    nsprintf(@"\u00ABversion\u00BB %@\n", [self versionInfo]);

    // Create loggers
    [self attachLoggers];

    // Register default settings
    [SettingsManager registerDefaults];
}

- (void)showLaunchScreen
{
    if (!_launchScreenVC) _launchScreenVC = [StoryboardProxy launchScreenViewController];

    [self.window setRootViewController:_launchScreenVC];
    _launchScreenVC.view.userInteractionEnabled = YES;
}

/*
 * Assigns the window's root view controller to static variable `launchScreenVC` and sets up Core
 * Data stack.
 */
- (BOOL)              application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UIApplication sharedApplication].statusBarHidden = YES;

    // set a reference to our launch screen view controller
    _launchScreenVC = (LaunchScreenViewController*)[self.window rootViewController];
    _launchScreenVC.view.userInteractionEnabled = NO;
    [_launchScreenVC toggleSpinner];

    // Apply user defined settings and observe status bar setting changes
    [SettingsManager applyUserSettings];
    [NotificationCenter addObserverForName:MSSettingsManagerStatusBarSettingDidChangeNotification
                                    object:[SettingsManager class]
                                     queue:MainQueue
                                usingBlock:^(NSNotification * note)
                                           {
                                               UIApp.statusBarHidden =
                                                   [SettingsManager boolForSetting:MSSettingsStatusBarKey];
                                           }];

    // intialize core data statck
    BOOL coreDataStackInitializedSuccessfully = [CoreDataManager initializeDatabase];
    assert(coreDataStackInitializedSuccessfully);

    // create our work queue for database loading and building
    _workQueue = [NSOperationQueue  operationQueueWithName:@"com.moondeerstudios.initialization"];

    // create block operations for our work queue
    __block BOOL errorOccurred = NO; // if set to YES, remaining operations should cancel
    
    NSOperation * rebuildDatabase = [NSBlockOperation blockOperationWithBlock:
                                     ^{
                                         if (!errorOccurred && [UserDefaults boolForKey:@"loadData"])
                                             errorOccurred = (![DatabaseLoader loadData]);
                                     }];
    
    NSOperation * rebuildRemote = [NSBlockOperation blockOperationWithBlock:
                                   ^{
                                       if (   !errorOccurred
                                           && (   [UserDefaults boolForKey:@"rebuildRemote"]
                                               || [UserDefaults boolForKey:@"loadData"]))
                                       {
                                           [RemoteElementConstructionManager buildController];
                                       }
                                   }];
    
    [rebuildRemote addDependency:rebuildDatabase];

    NSOperation * runUITests = [NSBlockOperation blockOperationWithBlock:
                                ^{
                                    if (!errorOccurred && [UserDefaults boolForKey:@"uitest"])
                                        MSRunAsyncOnMain (^{ [self runUITests]; });
                                }];

    [runUITests addDependency:rebuildRemote];

    NSOperation * readyApplication = [NSBlockOperation blockOperationWithBlock:
                                      ^{
                                          [MainQueue addOperationWithBlock:
                                           ^{
                                               [_launchScreenVC toggleSpinner];
                                               _launchScreenVC.view. userInteractionEnabled = YES;
                                           }];
                                      }];

    [readyApplication addDependency:runUITests];

    [_workQueue addOperations:@[rebuildDatabase,
                                rebuildRemote,
                                runUITests,
                                readyApplication]
            waitUntilFinished:NO];

    return YES;
}

//- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Carry out any methods dependent on the state of top level defines.

    // Listen for available devices
    // [[ConnectionManager sharedConnectionManager] logStatus];
//}

//???: Why are random saves like these crashing with -[NSNull countByEnumeratingWithState:objects:count:] message sends?
//- (void)applicationWillResignActive:(UIApplication *)application
//{
//    [CoreDataManager saveMainContext];
//}

/*
 * Saves the primary managed object context
 */
//- (void)applicationDidEnterBackground:(UIApplication *)application {
//    [CoreDataManager saveMainContext];
//}

@end
