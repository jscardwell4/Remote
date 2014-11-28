//
// DataBaseLoader.m
// Remote
//
// Created by Jason Cardwell on 2/19/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@import UIKit;
@import CoreData;
@import CocoaLumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"
#import "DatabaseLoader.h"
//#import "RemoteElement.h"
#import "RemoteController.h"
//#import "Remote.h"
#import "Activity.h"
#import "Remote-Swift.h"

#define USER_CODES_PLIST    @"UserCodes"
#define CODE_DATABASE_PLIST @"CodeDatabase-Pruned"

#define LOG_IMPORT_FILE      1
#define LOG_PARSED_FILE      2
#define LOG_RESULTING_OBJECT 4

#define PARSE_ONLY NO

#define REMOTECONTROLLER_LOG_FLAG 0
#define REMOTE_LOG_FLAG           0
#define PRESET_LOG_FLAG           0
#define IMAGES_LOG_FLAG           0
#define POWERCOMMANDS_LOG_FLAG    0
#define MANUFACTURERS_LOG_FLAG    0
#define COMPONENTDEVICES_LOG_FLAG 0
#define NETWORKDEVICES_LOG_FLAG   0
#define IRCODES_LOG_FLAG          0

static int       ddLogLevel       = LOG_LEVEL_DEBUG;
static const int msLogContext     = (LOG_CONTEXT_BUILDING | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);
static const int importLogContext = (LOG_CONTEXT_IMPORT | LOG_CONTEXT_FILE);
#pragma unused(ddLogLevel, msLogContext)

void logImportFile(NSString * fileName, NSString * fileContent, int flag) {
  if ((flag & LOG_IMPORT_FILE) == LOG_IMPORT_FILE)
    MSLogCDebugInContext(importLogContext, @"%@.json:\n%@\n", fileName, fileContent);
}

void logParsedImportFile(NSString * fileName, id parsedObject, int flag) {
  if ((flag & LOG_PARSED_FILE) == LOG_PARSED_FILE)
    MSLogCDebugInContext(importLogContext,
                         @"object parsed from %@.json:\n%@\n",
                         fileName,
                         [MSJSONSerialization JSONFromObject:parsedObject]);
}

void logImportedObject(id importedObject, int flag) {
  if ((flag & LOG_RESULTING_OBJECT) == LOG_RESULTING_OBJECT)
    MSLogCDebugInContextIf((importedObject != nil),
                           importLogContext,
                           @"JSON from imported object(s):\n%@\n",
                           [MSJSONSerialization JSONFromObject:[importedObject JSONObject]]);
}

@implementation DatabaseLoader

/// loadData
/// @return BOOL
+ (BOOL)loadData {
  MSLogDebug(@"beginning data load...");

  [CoreDataManager backgroundSaveWithBlockAndWait:^(NSManagedObjectContext *context) {
    @autoreleasepool { [self loadPresets:context]; }
  }];

  [CoreDataManager backgroundSaveWithBlockAndWait:^(NSManagedObjectContext * context) {
    @autoreleasepool { [self loadImages:context]; }
  }];

  [CoreDataManager backgroundSaveWithBlockAndWait:^(NSManagedObjectContext * context) {
    @autoreleasepool { [self loadManufacturers:context]; }
  }];

  [CoreDataManager saveWithBlockAndWait:^(NSManagedObjectContext * context) {
    @autoreleasepool {
      [self loadComponentDevices:context];
      [self loadNetworkDevices:context];
    }
  }];

  [CoreDataManager backgroundSaveWithBlockAndWait:^(NSManagedObjectContext * context) {
    @autoreleasepool {
      [self loadRemoteController:context];
      [self loadActivities:context];
      [self loadRemotes:context];
    }
  }];

  MSLogDebug(@"data load complete");

  return YES;
}

/// loadRemotes:
/// @param context
+ (void)loadRemotes:(NSManagedObjectContext *)context {
  MSLogDebug(@"loading remotes...");

  NSString * fileName = @"Remote_Demo";
  NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

  NSError        * error = nil;
  NSStringEncoding encoding;
  NSString       * fileContent = [NSString stringWithContentsOfFile:filePath
                                                       usedEncoding:&encoding
                                                              error:&error];

  assert(fileContent);
  if (MSHandleErrors(error)) return;

  logImportFile(fileName, fileContent, REMOTE_LOG_FLAG);
  NSArray * importObjects = [JSONSerialization objectByParsingString:fileContent options:1 error:&error];

  if (MSHandleErrors(error)) return;

  logParsedImportFile(fileName, importObjects, REMOTE_LOG_FLAG);
  if (PARSE_ONLY) return;

  NSArray * remotes = [Remote importObjectsFromData:importObjects context:context];
  MSLogDebug(@"%lu remotes imported", (unsigned long)[remotes count]);

  error = nil;
  [context save:&error];
  MSHandleErrors(error);

  logImportedObject(remotes, REMOTE_LOG_FLAG);
}

/// loadRemoteController:
/// @param context
+ (void)loadRemoteController:(NSManagedObjectContext *)context {
  MSLogDebug(@"loading remote controller...");

  NSString * fileName = @"RemoteController";
  NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

  NSError        * error = nil;
  NSStringEncoding encoding;
  NSString       * fileContent = [NSString stringWithContentsOfFile:filePath
                                                       usedEncoding:&encoding
                                                              error:&error];
  assert(fileContent);

  if (MSHandleErrors(error)) return;

  logImportFile(fileName, fileContent, REMOTECONTROLLER_LOG_FLAG);
  MSDictionary * importObject = [JSONSerialization objectByParsingString:fileContent options:1 error:&error];

  if (MSHandleErrors(error)) return;

  logParsedImportFile(fileName, importObject, REMOTECONTROLLER_LOG_FLAG);
  if (PARSE_ONLY) return;

  RemoteController * remoteController = [RemoteController importObjectFromData:importObject
                                                                       context:context];
  MSLogDebug(@"remote controller imported? %@", BOOLString((remoteController != nil)));

  logImportedObject(remoteController, REMOTECONTROLLER_LOG_FLAG);
}


/// loadPresets:
/// @param context
+ (void)loadPresets:(NSManagedObjectContext *)context {
  MSLogDebug(@"loading presets...");

  NSString * fileName = @"Preset";
  NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

  NSError        * error = nil;
  NSStringEncoding encoding;
  NSString       * fileContent = [NSString stringWithContentsOfFile:filePath
                                                       usedEncoding:&encoding
                                                              error:&error];
  assert(fileContent);

  if (MSHandleErrors(error)) return;

  logImportFile(fileName, fileContent, PRESET_LOG_FLAG);
  NSArray * importObjects = [JSONSerialization objectByParsingFile:filePath options:1 error:&error];

  if (MSHandleErrors(error)) return;

  logParsedImportFile(fileName, importObjects, PRESET_LOG_FLAG);
  if (PARSE_ONLY) return;

  NSArray * presets = [PresetCategory importObjectsFromData:importObjects context:context];
  MSLogDebug(@"%@ presets imported", [presets valueForKeyPath:@"@sum.totalItemCount"]);

  error = nil;
  [context save:&error];
  MSHandleErrors(error);

  logImportedObject(presets, PRESET_LOG_FLAG);
}

/// loadActivities:
/// @param context
+ (void)loadActivities:(NSManagedObjectContext *)context {
  MSLogDebug(@"loading activities...");

  NSString * fileName = @"Activity";
  NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

  NSError        * error = nil;
  NSStringEncoding encoding;
  NSString       * fileContent = [NSString stringWithContentsOfFile:filePath
                                                       usedEncoding:&encoding
                                                              error:&error];
  assert(fileContent);

  if (MSHandleErrors(error)) return;

  logImportFile(fileName, fileContent, REMOTE_LOG_FLAG);
  NSArray * importObjects = [JSONSerialization objectByParsingString:fileContent options:1 error:&error];

  if (MSHandleErrors(error)) return;

  logParsedImportFile(fileName, importObjects, REMOTE_LOG_FLAG);
  if (PARSE_ONLY) return;

  NSArray * activities = [Activity importObjectsFromData:importObjects context:context];
  MSLogDebug(@"%lu activities imported", (unsigned long)[activities count]);

  error = nil;
  [context save:&error];
  MSHandleErrors(error);

  logImportedObject(activities, REMOTE_LOG_FLAG);
}

/// loadManufacturers:
/// @param context
+ (void)loadManufacturers:(NSManagedObjectContext *)context {
  MSLogDebug(@"loading manufacturers...");

 #define MANUFACTURER_TEST_CODES
  #ifdef MANUFACTURER_TEST_CODES
    NSString * fileName = @"Manufacturer_Test";
  #else
    NSString * fileName = @"Manufacturer";
  #endif
  NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

  NSError        * error = nil;
  NSStringEncoding encoding;
  NSString       * fileContent = [NSString stringWithContentsOfFile:filePath
                                                       usedEncoding:&encoding
                                                              error:&error];
  assert(fileContent);

  if (MSHandleErrors(error)) return;

  logImportFile(fileName, fileContent, MANUFACTURERS_LOG_FLAG);
  NSArray * importObjects = [JSONSerialization objectByParsingFile:filePath options:1 error:&error];

  if (MSHandleErrors(error)) return;

  logParsedImportFile(fileName, importObjects, MANUFACTURERS_LOG_FLAG);
  if (PARSE_ONLY) return;

  NSArray * manufacturers = [Manufacturer importObjectsFromData:importObjects context:context];
  MSLogDebug(@"%lu manufacturers imported", (unsigned long)[manufacturers count]);

  logImportedObject(manufacturers, MANUFACTURERS_LOG_FLAG);
}

/// loadComponentDevices:
/// @param context
+ (void)loadComponentDevices:(NSManagedObjectContext *)context {
  MSLogDebug(@"loading component devices...");

  NSString * fileName = @"ComponentDevice";
  NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

  NSError        * error = nil;
  NSStringEncoding encoding;
  NSString       * fileContent = [NSString stringWithContentsOfFile:filePath
                                                       usedEncoding:&encoding
                                                              error:&error];
  assert(fileContent);

  if (MSHandleErrors(error)) return;

  logImportFile(fileName, fileContent, COMPONENTDEVICES_LOG_FLAG);
  NSArray * importObjects = [JSONSerialization objectByParsingString:fileContent options:1 error:&error];

  if (MSHandleErrors(error)) return;

  logParsedImportFile(fileName, importObjects, COMPONENTDEVICES_LOG_FLAG);
  if (PARSE_ONLY) return;

  NSArray * componentDevices = [ComponentDevice importObjectsFromData:importObjects context:context];
  MSLogDebug(@"%lu component devices imported", (unsigned long)[componentDevices count]);

  logImportedObject(componentDevices, COMPONENTDEVICES_LOG_FLAG);
}

/// loadNetworkDevices:
/// @param context
+ (void)loadNetworkDevices:(NSManagedObjectContext *)context {
  MSLogDebug(@"loading network devices...");

  NSString * fileName = @"NetworkDevice";
  NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

  NSError        * error = nil;
  NSStringEncoding encoding;
  NSString       * fileContent = [NSString stringWithContentsOfFile:filePath
                                                       usedEncoding:&encoding
                                                              error:&error];
  assert(fileContent);

  if (MSHandleErrors(error)) return;

  logImportFile(fileName, fileContent, NETWORKDEVICES_LOG_FLAG);
  NSArray * importObjects = [JSONSerialization objectByParsingString:fileContent options:1 error:&error];

  if (MSHandleErrors(error)) return;

  logParsedImportFile(fileName, importObjects, NETWORKDEVICES_LOG_FLAG);
  if (PARSE_ONLY) return;

  NSArray * networkDevices = [NetworkDevice importObjectsFromData:importObjects context:context];
  MSLogDebug(@"%lu network devices imported", (unsigned long)[networkDevices count]);

  logImportedObject(networkDevices, NETWORKDEVICES_LOG_FLAG);
}

/// loadImages:
/// @param context
+ (void)loadImages:(NSManagedObjectContext *)context {
  MSLogDebug(@"loading images...");
//  #define GLYPHISH_TEST_IMAGES
  #ifdef GLYPHISH_TEST_IMAGES
    NSString * fileName = @"Glyphish_Test";
  #else
    NSString * fileName = @"Glyphish";
  #endif
  NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

  NSError        * error = nil;
  NSStringEncoding encoding;
  NSString       * fileContent = [NSString stringWithContentsOfFile:filePath
                                                       usedEncoding:&encoding
                                                              error:&error];
  assert(fileContent);

  if (MSHandleErrors(error)) return;

  logImportFile(fileName, fileContent, IMAGES_LOG_FLAG);

  NSArray * importObjects = [JSONSerialization objectByParsingString:fileContent options:1 error:&error];
  if (MSHandleErrors(error)) return;

  logParsedImportFile(fileName, importObjects, IMAGES_LOG_FLAG);
  if (PARSE_ONLY) return;

  NSArray * images = [ImageCategory importObjectsFromData:importObjects context:context];
  MSLogDebug(@"%@ images imported", [images valueForKeyPath:@"@sum.totalItemCount"]);

  logImportedObject(images, IMAGES_LOG_FLAG);
}

@end
