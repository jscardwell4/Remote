//
// MSRemoteAppController.m
// iPhonto
//
// Created by Jason Cardwell on 5/3/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "MSRemoteLogFormatter.h"
#import "RemoteElementConstructionManager.h"
#import "RemoteViewController.h"
#import "LaunchScreenViewController.h"
#import "CoreDataManager.h"
#import "DatabaseLoader.h"
#import "SettingsManager.h"
#import "ConnectionManager.h"
#import "MSRemoteAppController.h"
#import "UITestRunner.h"
#import "StoryboardProxy.h"

// Database options
#define USE_UNDO_MANAGER NO
#define REBUILD_PREVIEWS NO

static int   ddLogLevel = LOG_LEVEL_DEBUG;
// static int ddLogLevel = DefaultDDLogLevel;
static NSMutableArray * kLogReceptionists;

@implementation MSRemoteAppController {
    LaunchScreenViewController * _launchScreenVC;
    NSOperationQueue           * _workQueue;
}

+ (NSString const *)versionInfo {

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

- (void)runUITests {
    #define ButtonGroupEditingTest(focus, number, options) \
    @(UITestTypeButtonGroupEditing | focus | (uint64_t)((uint64_t)number << UITestNumberOffset) | (uint64_t)((uint64_t)options << UITestOptionsOffset))
    #define RemoteEditingTest(focus, number, options) \
    @(UITestTypeRemoteEditing | focus | (uint64_t)((uint64_t)number << UITestNumberOffset) | (uint64_t)((uint64_t)options << UITestOptionsOffset))

    NSArray * tests = @[ButtonGroupEditingTest(UITestFocusTranslation, 0, 2), // 0
                        ButtonGroupEditingTest(UITestFocusTranslation, 1, 2), // 1
                        ButtonGroupEditingTest(UITestFocusFocus,       0, 2), // 2
                        ButtonGroupEditingTest(UITestFocusAlignment,   0, 2), // 3
                        ButtonGroupEditingTest(UITestFocusAlignment,   1, 2), // 4
                        ButtonGroupEditingTest(UITestFocusAlignment,   2, 2), // 5
                        ButtonGroupEditingTest(UITestFocusAlignment,   3, 2), // 6
                        ButtonGroupEditingTest(UITestFocusAlignment,   4, 2), // 7
                        ButtonGroupEditingTest(UITestFocusAlignment,   5, 2), // 8
                        ButtonGroupEditingTest(UITestFocusAlignment,   6, 2), // 9
                        ButtonGroupEditingTest(UITestFocusAlignment,   7, 2), // 10
                        ButtonGroupEditingTest(UITestFocusInfo,        0, 2), // 11
                        ButtonGroupEditingTest(UITestFocusInfo,        1, 2), // 12
                        ButtonGroupEditingTest(UITestFocusScale,       0, 2), // 13
                        ButtonGroupEditingTest(UITestFocusTranslation, 2, 2), // 14
                        RemoteEditingTest(     UITestFocusScale,       0, 2), // 15
                        RemoteEditingTest(     UITestFocusInfo,        0, 2), // 16
                        RemoteEditingTest(     UITestFocusInfo,        1, 2), // 17
                        ButtonGroupEditingTest(UITestFocusDialog,      0, 3)  // 18
                      ];
    NSMutableIndexSet * indices       = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(18, 1)];
    NSArray           * selectedTests = [tests objectsAtIndexes:indices];

    [UITestRunner runTests:selectedTests];
}

#pragma mark - Shared controller and Storyboard controllers

+ (MSRemoteAppController *)sharedAppController {
    static dispatch_once_t                  pred          = 0;
    __strong static MSRemoteAppController * _sharedObject = nil;

    dispatch_once(&pred, ^{_sharedObject = SharedApp.delegate;});

    return _sharedObject;
}

- (void)showRemote {
    [MainQueue addOperationWithBlock:^{
                   [_launchScreenVC performSegueWithIdentifier:@"remoteView" sender:self];
               }];
}

+ (void)attachLoggers {
    kLogReceptionists = [@[] mutableCopy];

    void   (^ addFileLoggerForContextAndDirectory)(NSUInteger, NSString *) =
        ^(NSUInteger context, NSString * directory) {
        MSRemoteLogFileManager * fileManager = [[MSRemoteLogFileManager alloc] initWithLogsDirectory:directory];
        fileManager.maximumNumberOfLogFiles = 100;
#ifdef LOG_LOGGER_FILE_ROLL
        [kLogReceptionists addObject:
         [MSKVOReceptionist receptionistForObject:fileManager
                                          keyPath:@"currentLogFile"
                                          options:NSKeyValueObservingOptionNew
                                          context:NULL
                                          handler:
          ^(MSKVOReceptionist * r, NSString * k, id o, NSDictionary * c, void * ctx) {
                nsprintf(@"\u00ABnew log file created\u00BB\n\t%@: %@\n",
                         [o valueForKeyPath:@"logsDirectory.lastPathComponent.lowercaseString"],
                         c[NSKeyValueChangeNewKey]);
            }

                                            queue:[NSOperationQueue mainQueue]
         ]
        ];
#endif
        DDFileLogger * fileLogger = [[DDFileLogger alloc] initWithLogFileManager:fileManager];
        fileLogger.rollingFrequency = 60;
        fileLogger.maximumFileSize  = 0;
        MSRemoteLogFormatter * logFormatter = [MSRemoteLogFormatter remoteLogFormatterForContext:context];
        logFormatter.includeTimestamp      = YES;
        logFormatter.addReturnAfterPrefix  = YES;
        logFormatter.addReturnAfterMessage = YES;
        logFormatter.includeLogLevel       = NO;
        logFormatter.indentMessageBody     = NO;
        fileLogger.logFormatter            = logFormatter;

        [DDLog addLogger:fileLogger];
    };

    [DDLog addLogger:[DDTTYLogger sharedInstanceWithLogFormatter:
                      [MSRemoteLogFormatter remoteLogFormatterForContext:TTY_LOG_CONTEXT]]];

    [DDLog addLogger:[DDASLLogger sharedInstanceWithLogFormatter:
                      [MSRemoteLogFormatter remoteLogFormatterForContext:ASL_LOG_CONTEXT]]];

    NSString * logsDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
                                stringByAppendingPathComponent:@"Logs"];

    NSDictionary * fileLoggers = @{@(FILE_LOG_CONTEXT)       : logsDirectory,
                                   @(PAINTER_LOG_CONTEXT)    : [logsDirectory stringByAppendingPathComponent:@"Painter"],
                                   @(NETWORKING_LOG_CONTEXT) : [logsDirectory stringByAppendingPathComponent:@"Networking"],
                                   @(REMOTE_LOG_CONTEXT)     : [logsDirectory stringByAppendingPathComponent:@"Remote"],
                                   @(COREDATA_LOG_CONTEXT)   : [logsDirectory stringByAppendingPathComponent:@"CoreData"],
                                   @(UITESTING_LOG_CONTEXT)  : [logsDirectory stringByAppendingPathComponent:@"UITesting"],
                                   @(EDITOR_LOG_CONTEXT)     : [logsDirectory stringByAppendingPathComponent:@"Editor"]};

    [fileLoggers enumerateKeysAndObjectsUsingBlock:^(NSNumber * key, NSString * obj, BOOL *stop) {
                     addFileLoggerForContextAndDirectory(UInteger(key), obj);
                 }];

}  /* attachLoggers */

/*
 * Creates the application's loggers and registers default settings
 */
+ (void)initialize {
    nsprintf(@"\u00ABversion\u00BB %@\n", [self versionInfo]);

    // Create loggers
    [self attachLoggers];

    // Register default settings
    [SettingsManager registerDefaults];
}

- (void)showLaunchScreen {
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
    _launchScreenVC = (LaunchScreenViewController*)[self.window rootViewController];
    _launchScreenVC.view.userInteractionEnabled = NO;

    // Apply user defined settings and observe status bar setting changes
    [SettingsManager applyUserSettings];

    [NotificationCenter addObserverForName:MSSettingsManagerStatusBarSettingDidChangeNotification
                                    object:[SettingsManager sharedSettingsManager]
                                     queue:nil
                                usingBlock:^(NSNotification * note){
                                    SharedApp.statusBarHidden = [SettingsManager boolForSetting:kStatusBarKey];
                                }];

    if (![CoreDataManager setUpCoreDataStack]) DDLogError(@"%@ failed to setup core data stack", ClassTagSelectorString);

    _workQueue      = [[NSOperationQueue alloc] init];
    _workQueue.name = @"com.moondeerstudios.initialization";

    __block BOOL             error           = NO;
    NSManagedObjectContext * context         = [DataManager mainObjectContext];
    NSOperation            * rebuildDatabase =
        [NSBlockOperation blockOperationWithBlock:^{
            if (!error && [UserDefaults boolForKey:@"rebuild"])
            {
                [context performBlock:^{
                    if (  [DatabaseLoader loadDataIntoContext:context]
                        && [DataManager saveMainContext])
                        DDLogDebug(@"%@ data loaded and saved successfully",
                                   ClassTagSelectorString);
                    else
                    {
                        DDLogError(@"%@ failed to load and save data", ClassTagSelectorString);
                        error = YES;
                    }
                }];
            }
        }];
    
    NSOperation * rebuildRemote =
        [NSBlockOperation blockOperationWithBlock:^{
            if (!error && ([UserDefaults boolForKey:@"rebuild"] || [UserDefaults boolForKey:@"remote"]))
            {
                [context performBlock:^{
                    if (  [ConstructionManager buildRemoteControllerInContext:context]
                        && [DataManager saveMainContext])
                        DDLogDebug(@"%@ remote controller constructed and saved successfully",
                                   ClassTagSelectorString);
                    else
                    {
                        DDLogError(@"%@ failed to construct and save remote controller",
                                   ClassTagSelectorString);
                        error = YES;
                    }
                }];
            }
        }];

    [rebuildRemote addDependency:rebuildDatabase];

    NSOperation * runUITests = [NSBlockOperation blockOperationWithBlock:^{
                                                     if (!error && [UserDefaults boolForKey:@"uitest"])
                                                     {
                                                     MSRunAsyncOnMain (^{ [self runUITests]; });
                                                     }
                                                 }];

    [runUITests addDependency:rebuildRemote];

    NSOperation * readyApplication = [NSBlockOperation blockOperationWithBlock:^{
                                                           MSRunAsyncOnMain (^{ _launchScreenVC.view.userInteractionEnabled = YES; });
                                                       }];

    [readyApplication addDependency:runUITests];

    [_workQueue addOperations:@[rebuildDatabase, rebuildRemote, runUITests,
                                readyApplication]
            waitUntilFinished:NO];

    return YES;
}
  /* application */

/*
 * Dispatches various methods for initializing the application.
 */
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Carry out any methods dependent on the state of top level defines.

    // Listen for available devices
    // [[ConnectionManager sharedConnectionManager] logStatus];
}

/*
 * Saves the primary managed object context
 */
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [DataManager saveMainContext];
}

@end
