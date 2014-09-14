//
// DataBaseLoader.m
// Remote
//
// Created by Jason Cardwell on 2/19/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "DatabaseLoader.h"
#import "RemoteElement.h"
#import "RemoteController.h"
#import "Bankables.h"
#import "Remote.h"
#import "Activity.h"
#import "NetworkDevice.h"

#define USER_CODES_PLIST    @"UserCodes"
#define CODE_DATABASE_PLIST @"CodeDatabase-Pruned"

#define LOG_IMPORT_FILE      1
#define LOG_PARSED_FILE      2
#define LOG_RESULTING_OBJECT 4

#define REMOTECONTROLLER_LOG_FLAG 0
#define REMOTE_LOG_FLAG           0
#define IMAGES_LOG_FLAG           0
#define POWERCOMMANDS_LOG_FLAG    0
#define MANUFACTURERS_LOG_FLAG    0
#define COMPONENTDEVICES_LOG_FLAG 0
#define NETWORKDEVICES_LOG_FLAG   0
#define IRCODES_LOG_FLAG          0

static int       ddLogLevel       = LOG_LEVEL_INFO;
static const int msLogContext     = (LOG_CONTEXT_BUILDING | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);
static const int importLogContext = (LOG_CONTEXT_IMPORT | LOG_CONTEXT_FILE);
#pragma unused(ddLogLevel, msLogContext)

void logImportFile(NSString * fileName, NSString * fileContent, int flag) {
  if ((flag & LOG_IMPORT_FILE) == LOG_IMPORT_FILE)
    MSLogCDebugInContext(importLogContext, @"%@.json:\n%@\n", fileName, fileContent);
}

void logParsedImportFile(id parsedObject, int flag) {
  if ((flag & LOG_PARSED_FILE) == LOG_PARSED_FILE)
    MSLogCDebugInContext(importLogContext,
                         @"JSON from parsed file:\n%@\n",
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

  [CoreDataManager saveWithBlockAndWait:
   ^(NSManagedObjectContext * context)
  {
    @autoreleasepool { [self loadImages:context]; }
  }];

  [CoreDataManager saveWithBlockAndWait:
   ^(NSManagedObjectContext * context)
  {
    @autoreleasepool { [self loadManufacturers:context]; }
  }];

  [CoreDataManager saveWithBlockAndWait:
   ^(NSManagedObjectContext * context)
  {
    @autoreleasepool {
      [self loadComponentDevices:context];
      [self loadNetworkDevices:context];
    }
  }];

  [CoreDataManager saveWithBlockAndWait:
   ^(NSManagedObjectContext * context)
  {
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
/// @param context description
+ (void)loadRemotes:(NSManagedObjectContext *)context {
  MSLogDebug(@"loading remotes...");

  NSString * fileName = @"Remote_Demo";
  NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

  NSError        * error = nil;
  NSStringEncoding encoding;
  NSString       * fileContent = [NSString stringWithContentsOfFile:filePath
                                                       usedEncoding:&encoding
                                                              error:&error];

  if (error) { MSHandleErrors(error); return; }

  logImportFile(fileName, fileContent, REMOTE_LOG_FLAG);
  NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];

  if (error) { MSHandleErrors(error); return; }

  logParsedImportFile(importObjects, REMOTE_LOG_FLAG);
  NSArray * remotes = [Remote importObjectsFromData:importObjects context:context];
  MSLogDebug(@"%lu remotes imported", (unsigned long)[remotes count]);

  error = nil;
  [context save:&error];
  MSHandleErrors(error);

  logImportedObject(remotes, REMOTE_LOG_FLAG);
}

/// loadRemoteController:
/// @param context description
+ (void)loadRemoteController:(NSManagedObjectContext *)context {
  MSLogDebug(@"loading remote controller...");

  NSString * fileName = @"RemoteController";
  NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

  NSError        * error = nil;
  NSStringEncoding encoding;
  NSString       * fileContent = [NSString stringWithContentsOfFile:filePath
                                                       usedEncoding:&encoding
                                                              error:&error];

  if (error) { MSHandleErrors(error); return; }

  logImportFile(fileName, fileContent, REMOTECONTROLLER_LOG_FLAG);
  MSDictionary * importObject = [MSJSONSerialization objectByParsingString:fileContent error:&error];

  if (error) { MSHandleErrors(error); return; }

  logParsedImportFile(importObject, REMOTECONTROLLER_LOG_FLAG);
  RemoteController * remoteController = [RemoteController importObjectFromData:importObject
                                                                       context:context];
  MSLogDebug(@"remote controller imported? %@", BOOLString((remoteController != nil)));

  logImportedObject(remoteController, REMOTECONTROLLER_LOG_FLAG);
}

/// loadActivities:
/// @param context description
+ (void)loadActivities:(NSManagedObjectContext *)context {
  MSLogDebug(@"loading activities...");

  NSString * fileName = @"Activity";
  NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

  NSError        * error = nil;
  NSStringEncoding encoding;
  NSString       * fileContent = [NSString stringWithContentsOfFile:filePath
                                                       usedEncoding:&encoding
                                                              error:&error];

  if (error) { MSHandleErrors(error); return; }

  logImportFile(fileName, fileContent, REMOTE_LOG_FLAG);
  NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];

  if (error) { MSHandleErrors(error); return; }

  logParsedImportFile(importObjects, REMOTE_LOG_FLAG);
  NSArray * activities = [Activity importObjectsFromData:importObjects context:context];
  MSLogDebug(@"%lu activities imported", (unsigned long)[activities count]);

  error = nil;
  [context save:&error];
  MSHandleErrors(error);

  logImportedObject(activities, REMOTE_LOG_FLAG);
}

/// loadManufacturers:
/// @param context description
+ (void)loadManufacturers:(NSManagedObjectContext *)context {
  MSLogDebug(@"loading manufacturers...");

// #define MANUFACTURER_TEST_CODES
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

  if (error) { MSHandleErrors(error); return; }

  logImportFile(fileName, fileContent, MANUFACTURERS_LOG_FLAG);
  NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];

  if (error) { MSHandleErrors(error); return; }

  logParsedImportFile(importObjects, MANUFACTURERS_LOG_FLAG);

  NSArray * manufacturers = [Manufacturer importObjectsFromData:importObjects context:context];
  MSLogDebug(@"%lu manufacturers imported", (unsigned long)[manufacturers count]);

  logImportedObject(manufacturers, MANUFACTURERS_LOG_FLAG);
}

/// loadComponentDevices:
/// @param context description
+ (void)loadComponentDevices:(NSManagedObjectContext *)context {
  MSLogDebug(@"loading component devices...");

  NSString * fileName = @"ComponentDevice";
  NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

  NSError        * error = nil;
  NSStringEncoding encoding;
  NSString       * fileContent = [NSString stringWithContentsOfFile:filePath
                                                       usedEncoding:&encoding
                                                              error:&error];

  if (error) { MSHandleErrors(error); return; }

  logImportFile(fileName, fileContent, COMPONENTDEVICES_LOG_FLAG);
  NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];

  if (error) { MSHandleErrors(error); return; }

  logParsedImportFile(importObjects, COMPONENTDEVICES_LOG_FLAG);
  NSArray * componentDevices = [ComponentDevice importObjectsFromData:importObjects context:context];
  MSLogDebug(@"%lu component devices imported", (unsigned long)[componentDevices count]);

  logImportedObject(componentDevices, COMPONENTDEVICES_LOG_FLAG);
}

/// loadNetworkDevices:
/// @param context description
+ (void)loadNetworkDevices:(NSManagedObjectContext *)context {
  MSLogDebug(@"loading component devices...");

  NSString * fileName = @"NetworkDevice";
  NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

  NSError        * error = nil;
  NSStringEncoding encoding;
  NSString       * fileContent = [NSString stringWithContentsOfFile:filePath
                                                       usedEncoding:&encoding
                                                              error:&error];

  if (error) { MSHandleErrors(error); return; }

  logImportFile(fileName, fileContent, NETWORKDEVICES_LOG_FLAG);
  NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];

  if (error) { MSHandleErrors(error); return; }

  logParsedImportFile(importObjects, NETWORKDEVICES_LOG_FLAG);
  NSArray * networkDevices = [NetworkDevice importObjectsFromData:importObjects context:context];
  MSLogDebug(@"%lu network devices imported", (unsigned long)[networkDevices count]);

  logImportedObject(networkDevices, NETWORKDEVICES_LOG_FLAG);
}

/// loadImages:
/// @param context description
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

  if (error) { MSHandleErrors(error); return; }

  logImportFile(fileName, fileContent, IMAGES_LOG_FLAG);

  NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];

  if (error) { MSHandleErrors(error); return; }

  logParsedImportFile(importObjects, IMAGES_LOG_FLAG);
  NSArray * images = [Image importObjectsFromData:importObjects context:context];
  MSLogDebug(@"%lu images imported", (unsigned long)[images count]);

  logImportedObject(images, IMAGES_LOG_FLAG);
}

@end
