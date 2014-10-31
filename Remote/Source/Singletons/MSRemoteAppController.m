//
// MSRemoteAppController.m
// Remote
//
// Created by Jason Cardwell on 5/3/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
//#import "RemoteElementConstructionManager.h"
@import CoreData;
@import CocoaLumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"

#import "RemoteViewController.h"
#import "MainMenuViewController.h"
#import "CoreDataManager.h"
#import "DatabaseLoader.h"
#import "SettingsManager.h"
#import "ConnectionManager.h"
#import "MSRemoteAppController.h"
#import "StoryboardProxy.h"
#import "RemoteController.h"
#import "Remote.h"
#import "SettingsViewController.h"
#import "Remote-Swift.h"
@import CoreImage;

int msLogLevel = LOG_LEVEL_DEBUG;
void setGlobalLogLevel(int level) { msLogLevel = level; }
int getGlobalLogLevel() { return msLogLevel; }


static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = 0;

#pragma unused(ddLogLevel, msLogContext)

@interface MSRemoteAppController () <EditingDelegate>

@end

@implementation MSRemoteAppController 
{
  NSOperationQueue * _workQueue;
}

+ (NSString const *)versionInfo {

  static NSString const * kVersionInfo = nil;

  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{

    #ifdef DEBUG
      NSString * prefix = @"debug";
    #else
      NSString * prefix = @"release";
    #endif

    NSMutableString * s = [@"" mutableCopy];

    if ([UserDefaults boolForKey:@"loadData"]) [s appendString:@"-loadData"];
    if ([UserDefaults boolForKey:@"rebuild"])  [s appendString:@"-rebuild"];
    if ([UserDefaults boolForKey:@"replace"])  [s appendString:@"-replace"];
    if ([UserDefaults boolForKey:@"remote"])   [s appendString:@"-remote"];
    if ([UserDefaults boolForKey:@"uitest"])   [s appendString:@"-uitest"];
    if ([UserDefaults boolForKey:@"simulate"]) [s appendString:@"-simulate"];

    kVersionInfo = [prefix stringByAppendingString:s];

  });

  return kVersionInfo;

}

#pragma mark - Shared controller and Storyboard controllers

+ (MSRemoteAppController *)sharedAppController {
  static dispatch_once_t                  pred          = 0;
  __strong static MSRemoteAppController * _sharedObject = nil;

  dispatch_once(&pred, ^{ _sharedObject = (MSRemoteAppController *)UIApp.delegate; });

  return _sharedObject;
}

+ (void)attachLoggers {

  [MSLog addTaggingTTYLogger];
  DDTTYLogger * ttyLogger = [DDTTYLogger sharedInstance];
  ((MSLogFormatter *)ttyLogger.logFormatter).includeObjectName = NO;

  assert(ttyLogger);
  assert([ttyLogger colorsEnabled]);

  UIColor * errorColor = [UIColor colorWithR:217 G:30 B:0 A:255];

  [ttyLogger setForegroundColor:errorColor
                backgroundColor:nil
                        forFlag:LOG_FLAG_ERROR
                        context:LOG_CONTEXT_ANY];

  [MSLog addTaggingASLLogger];

  NSString * logsDirectory = [MSLog defaultLogDirectory];
  nsprintf(@"creating logs with base directory '%@'\n", logsDirectory);

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

  [fileLoggers enumerateKeysAndObjectsUsingBlock:^(NSNumber * key, NSString * obj, BOOL * stop)
  {
    NSUInteger context = UnsignedIntegerValue(key);

    if (context == LOG_CONTEXT_MAGICALRECORD) {
      DDFileLogger * fileLogger = [MSLog defaultFileLoggerForContext:context directory:obj];
      MSLogFormatter * formatter = fileLogger.logFormatter;
      formatter.includeSEL = NO;
      [DDLog addLogger:fileLogger];
    } else if (context == LOG_CONTEXT_IMPORT)   {
      DDFileLogger * fileLogger = [MSLog defaultFileLoggerForContext:context directory:obj];
      fileLogger.rollingFrequency = 30;
      MSLogFormatter * formatter = fileLogger.logFormatter;
      formatter.includeSEL = NO;
      [DDLog addLogger:fileLogger];
    } else if (context == LOG_CONTEXT_REMOTE)   {
      DDFileLogger * fileLogger = [MSLog defaultFileLoggerForContext:context directory:obj];
      fileLogger.rollingFrequency = 30;
      MSLogFormatter * formatter = fileLogger.logFormatter;
      formatter.includeObjectName = NO;
//            formatter.includeSEL = NO;
      [DDLog addLogger:fileLogger];
    } else [MSLog addDefaultFileLoggerForContext:context directory:obj];
  }];

}

/*
 * Creates the application's loggers and registers default settings
 */
+ (void)initialize {
  nsprintf(@"\u00ABversion\u00BB %@\n", [self versionInfo]);

  // Create loggers
  [self attachLoggers];

}

/*
 * Assigns the window's root view controller to static variable `launchScreenVC` and sets up Core
 * Data stack.
 */
- (BOOL)            application:(UIApplication *)application
  didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  // check if we should bypass setup because of testing
  BOOL isUnderXCTest = [UserDefaults boolForKey:@"skipDataStack"];
  if (isUnderXCTest) {
    MSLogInfo(@"skipDataStack argument detected, skipping setup...");
    return YES;
  }

//  nsprintf(@"CIFitlers…\n\t%@", [@"\n\t" join:[CIFilter filterNamesInCategories:nil]]);
//  nsprintf(@"available fonts…\n\t%@", [@"\n\t" join:[UIFont familyNames]]);
//  nsprintf(@"elysio fonts…\n\t%@", [@"\n\t" join:[UIFont fontNamesForFamilyName:@"Elysio"]]);

  // set a reference to our launch screen view controller
  MainMenuViewController * mainMenuVC = (MainMenuViewController *)[self.window rootViewController];

  mainMenuVC.view.userInteractionEnabled = NO;
  [mainMenuVC toggleSpinner];

  // Apply user defined settings and observe status bar setting changes
  UIApp.statusBarHidden = [[SettingsManager valueForSetting:SMSettingStatusBar] boolValue];
  [NotificationCenter addObserverForName:SMSettingStatusBarDidChangeNotification
                                  object:[SettingsManager class]
                                   queue:MainQueue
                              usingBlock:^(NSNotification * note)
  {
    
    UIApp.statusBarHidden = [[SettingsManager valueForSetting:SMSettingStatusBar] boolValue];
  }];

  // intialize core data statck
  BOOL coreDataStackInitializedSuccessfully = [CoreDataManager initializeDatabase];

  assert(coreDataStackInitializedSuccessfully);

  // create our work queue for database loading and building
  _workQueue = [NSOperationQueue operationQueueWithName:@"com.moondeerstudios.initialization"];

  // create block operations for our work queue
  __block BOOL errorOccurred = NO;   // if set to YES, remaining operations should cancel

  NSOperation * rebuildDatabase = [NSBlockOperation blockOperationWithBlock:
                                   ^{
    if (!errorOccurred && [UserDefaults boolForKey:@"loadData"]) {
      NSManagedObjectContext * moc = [CoreDataManager defaultContext];
      [moc performBlockAndWait:^{
        errorOccurred = (![DatabaseLoader loadData]);

        if (!errorOccurred) {
          NSManagedObjectContext * defaultContext = [CoreDataManager defaultContext];
          __block NSError * error = nil;
          [defaultContext performBlock:^{
            [defaultContext save:&error];
          }];
          MSHandleErrors(error);
        }
      }];
    }
  }];

//  #define OUTPUT_JSON_FILES
// #define LOG_JSON_FILES

    NSOperation * dumpJSON = [NSBlockOperation blockOperationWithBlock:^{
      #ifdef OUTPUT_JSON_FILES
      NSManagedObjectContext * moc = [CoreDataManager defaultContext];
      NSMutableDictionary * jsonStrings = [@{} mutableCopy];
      [moc performBlockAndWait:^{

        NSString * filePath = [@"/" join:@[DocumentsFilePath, @"RemoteController-export.json"]];
        RemoteController * controller = [RemoteController remoteController:moc];
        assert(controller);
        jsonStrings[filePath] = controller.JSONString;

        NSArray * remotes = [Remote findAllInContext:moc];
        assert(remotes.count);
        for (Remote * remote in remotes) {
          filePath = [@"/" join:@[DocumentsFilePath, $(@"Remote-%@-export.json", remote.name)]];
          jsonStrings[filePath] = remote.JSONString;
        }

        filePath = [@"/" join:@[DocumentsFilePath, @"ComponentDevice-export.json"]];
        NSArray * componentDevices = [ComponentDevice findAllSortedBy:@"name" ascending:YES context:moc];
        assert(componentDevices.count);
        jsonStrings[filePath] = componentDevices.JSONString;

        filePath = [@"/" join:@[DocumentsFilePath, @"Manufacturer-export.json"]];
        NSArray * manufacturers = [Manufacturer findAllSortedBy:@"name" ascending:YES context:moc];
        assert(manufacturers.count);
        jsonStrings[filePath] = manufacturers.JSONString;

        filePath = [@"/" join:@[DocumentsFilePath, @"Image-export.json"]];
        NSArray * images = [Image findAllInContext:moc];
        assert(images.count);
        jsonStrings[filePath] = images.JSONString;
      }];

      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [jsonStrings enumerateKeysAndObjectsUsingBlock:^(NSString * filePath, NSString *jsonString, BOOL *stop) {
          NSError * error = nil;
          [jsonString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
          MSHandleErrors(error);
        }];
      });

    #endif
  }];

  [dumpJSON addDependency:rebuildDatabase];

  NSOperation * readyApplication = [NSBlockOperation blockOperationWithBlock:^{
    [MainQueue addOperationWithBlock:^{
      [mainMenuVC toggleSpinner];
      mainMenuVC.view.userInteractionEnabled = YES;
    }];
  }];

  [readyApplication addDependency:dumpJSON];

  [_workQueue addOperations:@[
     rebuildDatabase,
     readyApplication,
     dumpJSON
   ]
          waitUntilFinished:NO];

  return YES;
}

// - (void)applicationDidBecomeActive:(UIApplication *)application {
// Carry out any methods dependent on the state of top level defines.

// Listen for available devices
// [[ConnectionManager sharedConnectionManager] logStatus];
// }

// ???: Why are random saves like these crashing with -[NSNull countByEnumeratingWithState:objects:count:] message sends?
// - (void)applicationWillResignActive:(UIApplication *)application
// {
//    [CoreDataManager saveMainContext];
// }

/*
 * Saves the primary managed object context
 */
// - (void)applicationDidEnterBackground:(UIApplication *)application {
//    [CoreDataManager saveMainContext];
// }


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setting Root View Controller
////////////////////////////////////////////////////////////////////////////////

/// showViewController:
/// @param viewController
- (void)showViewController:(UIViewController *)viewController {
  if (!viewController) ThrowInvalidNilArgument(viewController);
  if ([self.window.rootViewController isKindOfClass:[MainMenuViewController class]])
    self.window.rootViewController = viewController;
  else [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
}

/// showRemote
- (void)showRemote {
  [self showViewController:[RemoteController remoteController:[CoreDataManager defaultContext]].viewController];
}

/// showEditor
- (void)showEditor {
  RemoteEditingController * editorVC = [RemoteEditingController new];
  editorVC.delegate  = self;

  if ([self.window.rootViewController isKindOfClass:[RemoteViewController class]]) {
    editorVC.remoteElement = [self.window valueForKeyPath:@"rootViewController.remoteController.currentRemote"];
  } else {
    RemoteController * controller = [RemoteController remoteController:[CoreDataManager defaultContext]];
    Remote * remote = controller.homeRemote;
    editorVC.remoteElement = remote ?: [Remote createInContext:[CoreDataManager defaultContext]];
  }

  [self showViewController:editorVC];
}

/// remoteElementEditorDidCancel:
/// @param editor
- (void)remoteElementEditorDidCancel:(RemoteElementEditingViewController *)editor {
  [self dismissViewController:editor completion:nil];
}

/// remoteElementEditorDidSave:
/// @param editor
- (void)remoteElementEditorDidSave:(RemoteElementEditingViewController *)editor {
  [self dismissViewController:editor completion:nil];
}

/// editorDidCancel:
/// @param editor
- (void)editorDidCancel:(RemoteElementEditingController *)editor {
  [self dismissViewController:editor completion:nil];
}

/// editorDidSave:
/// @param editor
- (void)editorDidSave:(RemoteElementEditingController *)editor {
  [self dismissViewController:editor completion:nil];
}

/// showMainMenu
- (void)showMainMenu {
  if (![self.window.rootViewController isKindOfClass:[MainMenuViewController class]])
    self.window.rootViewController = [StoryboardProxy mainMenuViewController];
}

/// showBank
- (void)showBank {
  [self showViewController:[[UINavigationController alloc] initWithRootViewController:[BankRootController new]]];
}

/// showSettings
- (void)showSettings { [self showViewController:[StoryboardProxy settingsViewController]]; }

/// dismissViewController:completion:
/// @param viewController
/// @param completion
- (void)dismissViewController:(UIViewController *)viewController completion:(void (^)(void))completion {
  if (self.window.rootViewController == viewController) [self showMainMenu];
  else [viewController dismissViewControllerAnimated:YES completion:completion];
}

/// showHelp
- (void)showHelp { MSLogWarn(@"help has not been implemented yet"); }

@end
