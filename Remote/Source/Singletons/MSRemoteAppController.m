//
// MSRemoteAppController.m
// Remote
//
// Created by Jason Cardwell on 5/3/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "RemoteElementConstructionManager.h"
#import "RemoteViewController.h"
#import "MainMenuViewController.h"
#import "CoreDataManager.h"
#import "DatabaseLoader.h"
#import "SettingsManager.h"
#import "ConnectionManager.h"
#import "MSRemoteAppController.h"
#import "RemoteControl.h"
#import "Bank.h"
#import "Editor.h"
#import "UITestRunner.h"
#import "StoryboardProxy.h"
#import "RemoteController.h"
#import "Remote.h"
#import "ComponentDevice.h"
#import "Manufacturer.h"
#import "Image.h"


static int ddLogLevel   = LOG_LEVEL_DEBUG;
static const int   msLogContext = 0;
#pragma unused(ddLogLevel, msLogContext)

@implementation MSRemoteAppController
{
    NSOperationQueue       * _workQueue;
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
        if ([UserDefaults boolForKey:@"loadData"])  [s appendString:@"-loadData"];
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
       @(LOG_CONTEXT_MAGICALRECORD) : $(@"%@/MagicalRecord", logsDirectory),
       @(LOG_CONTEXT_IMPORT)        : $(@"%@/Import",        logsDirectory)
    };

    [fileLoggers enumerateKeysAndObjectsUsingBlock:^(NSNumber * key, NSString * obj, BOOL *stop)
    {
        NSUInteger context = UnsignedIntegerValue(key);
        if (context == LOG_CONTEXT_MAGICALRECORD)
        {
            DDFileLogger * fileLogger = [MSLog defaultFileLoggerForContext:context directory:obj];
            MSLogFormatter * formatter = fileLogger.logFormatter;
            formatter.includeSEL = NO;
            [DDLog addLogger:fileLogger];
        }

        else if (context == LOG_CONTEXT_IMPORT)
        {
            DDFileLogger * fileLogger = [MSLog defaultFileLoggerForContext:context directory:obj];
            fileLogger.rollingFrequency = 30;
            MSLogFormatter * formatter = fileLogger.logFormatter;
            formatter.includeSEL = NO;
            [DDLog addLogger:fileLogger];
        }

        else if (context == LOG_CONTEXT_REMOTE)
        {
            DDFileLogger * fileLogger = [MSLog defaultFileLoggerForContext:context directory:obj];
            fileLogger.rollingFrequency = 30;
            MSLogFormatter * formatter = fileLogger.logFormatter;
            formatter.includeObjectName = NO;
//            formatter.includeSEL = NO;
            [DDLog addLogger:fileLogger];
        }


        else [MSLog addDefaultFileLoggerForContext:context directory:obj];
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

/*
 * Assigns the window's root view controller to static variable `launchScreenVC` and sets up Core
 * Data stack.
 */
- (BOOL)              application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    // set a reference to our launch screen view controller
    MainMenuViewController * mainMenuVC = (MainMenuViewController*)[self.window rootViewController];
    mainMenuVC.view.userInteractionEnabled = NO;
    [mainMenuVC toggleSpinner];

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
                                         if (!errorOccurred && [UserDefaults boolForKey:@"loadData"]) {
                                             NSManagedObjectContext * moc = [CoreDataManager defaultContext];
                                             [moc performBlockAndWait:^{
                                                 errorOccurred = (![DatabaseLoader loadData]);
                                                 if (!errorOccurred) {
                                                     NSManagedObjectContext * defaultContext = [CoreDataManager defaultContext];
                                                     __block NSError *error = nil;
                                                     [defaultContext performBlock:^{
                                                         [defaultContext save:&error];
                                                     }];
                                                     MSHandleErrors(error);
                                                 }
                                             }];
                                         }
                                     }];

/*
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
*/

/*
    NSOperation * runUITests = [NSBlockOperation blockOperationWithBlock:
                                ^{
                                    if (!errorOccurred && [UserDefaults boolForKey:@"uitest"])
                                        MSRunAsyncOnMain (^{ [self runUITests]; });
                                }];

    [runUITests addDependency:rebuildRemote];
*/

//#define OUTPUT_JSON_FILES
//#define LOG_JSON_FILES

#ifdef OUTPUT_JSON_FILES
    NSOperation * dumpJSON = [NSBlockOperation blockOperationWithBlock:^{

        [[CoreDataManager defaultContext] performBlock:^{

            NSString * filePath = [@"/" join:@[DocumentsFilePath, @"RemoteController.json"]];
            [MSJSONSerialization writeJSONObject:[RemoteController remoteController]
                                        filePath:filePath];
#ifdef LOG_JSON_FILES
            nsprintf(@"%@", [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]);
#endif

            filePath = [@"/" join:@[DocumentsFilePath, @"Remote.json"]];
            [MSJSONSerialization writeJSONObject:[[Remote findAllSortedBy:@"name" ascending:YES]
                                                  valueForKeyPath:@"JSONDictionary"]
                                        filePath:filePath];
#ifdef LOG_JSON_FILES
            nsprintf(@"%@", [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]);
#endif

            filePath = [@"/" join:@[DocumentsFilePath, @"ComponentDevice.json"]];
            [MSJSONSerialization writeJSONObject:[[ComponentDevice findAllSortedBy:@"info.name" ascending:YES]
                                                  valueForKeyPath:@"JSONDictionary"]
                                        filePath:filePath];
#ifdef LOG_JSON_FILES
            nsprintf(@"%@", [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]);
#endif

            filePath = [@"/" join:@[DocumentsFilePath, @"Manufacturer.json"]];
            [MSJSONSerialization writeJSONObject:[[Manufacturer findAllSortedBy:@"info.name" ascending:YES]
                                                  valueForKeyPath:@"JSONDictionary"]
                                        filePath:filePath];
#ifdef LOG_JSON_FILES
            nsprintf(@"%@", [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]);
#endif

            filePath = [@"/" join:@[DocumentsFilePath, @"Image.json"]];
            [MSJSONSerialization writeJSONObject:[[Image findAll] valueForKeyPath:@"JSONDictionary"]
                                        filePath:filePath];
#ifdef LOG_JSON_FILES
            nsprintf(@"%@", [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]);
#endif
        }];
    }];
#endif

    NSOperation * readyApplication = [NSBlockOperation blockOperationWithBlock:
                                      ^{
                                          [MainQueue addOperationWithBlock:
                                           ^{
                                               [mainMenuVC toggleSpinner];
                                               mainMenuVC.view. userInteractionEnabled = YES;

                                           }];
                                      }];

    [readyApplication addDependency:rebuildDatabase];

    [_workQueue addOperations:@[
                                rebuildDatabase,
//                                rebuildRemote,
//                                runUITests,
                                readyApplication
#ifdef OUTPUT_JSON_FILES
                                ,
                                dumpJSON
#endif
                                ]
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



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setting Root View Controller
////////////////////////////////////////////////////////////////////////////////

- (void)showRemote { [self.window setRootViewController:[RemoteControl viewController]]; }

- (void)showEditor { [self.window setRootViewController:[Editor viewController]]; }

- (void)showMainMenu { [self.window setRootViewController:[StoryboardProxy mainMenuViewController]]; }

- (void)showBank { [self.window setRootViewController:[Bank viewController]]; }

- (void)showSettings { [self.window setRootViewController:[SettingsManager viewController]]; }

- (void)dismissViewController:(UIViewController *)viewController completion:(void (^)(void))completion
{
    if (self.window.rootViewController == viewController) [self showMainMenu];
    else [viewController dismissViewControllerAnimated:YES completion:completion];
}

- (void)showHelp
{

}

@end
