//
// DataBaseLoader.m
// Remote
//
// Created by Jason Cardwell on 2/19/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "DatabaseLoader.h"
#import "Bankables.h"
#import "CoreDataManager.h"
#import <MSKit/MSLog.h>
#import "RemoteController.h"
#import "Remote.h"

#define USER_CODES_PLIST    @"UserCodes"
#define CODE_DATABASE_PLIST @"CodeDatabase-Pruned"

#define SHOULD_LOG_REMOTECONTROLLER
//#define SHOULD_LOG_REMOTE
//#define SHOULD_LOG_IMAGES
//#define SHOULD_LOG_POWERCOMMANDS
//#define SHOULD_LOG_MANUFACTURERS
//#define SHOULD_LOG_COMPONENTDEVICES
//#define SHOULD_LOG_IRCODES

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_BUILDING|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
static const int importLogContext = (LOG_CONTEXT_IMPORT|LOG_CONTEXT_FILE);
#pragma unused(ddLogLevel, msLogContext)

void logImportFile(NSString * fileName, NSString * fileContent)
{
    MSLogCDebugInContext(importLogContext, @"%@.json:\n%@\n", fileName, fileContent);
}

void logParsedImportFile(id parsedObject)
{
    MSLogCDebugInContext(importLogContext,
                         @"JSON from parsed object:\n%@\n",
                         [MSJSONSerialization JSONFromObject:parsedObject]);
}

void logImportedObject(id importedObject)
{
    MSLogCDebugInContextIf((importedObject != nil),
                           importLogContext,
                           @"JSON from imported object(s):\n%@\n",
                           [MSJSONSerialization JSONFromObject:[importedObject JSONObject]]);
}

@implementation DatabaseLoader

+ (BOOL)loadData
{
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
         @autoreleasepool { [self loadComponentDevices:context]; }
     }];

/*
     [CoreDataManager saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         @autoreleasepool { [self loadIRCodes:context]; }
     }];
*/

/*
    [CoreDataManager saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         @autoreleasepool { [self loadPowerCommands:context]; }
     }];
*/

    [CoreDataManager saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         @autoreleasepool { [self loadRemoteController:context]; }
     }];

    [CoreDataManager saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         @autoreleasepool { [self loadRemotes:context]; }
     }];


    MSLogDebug(@"data load complete");

    return YES;
}

+ (void)loadRemotes:(NSManagedObjectContext *)context
{
    MSLogDebug(@"loading remotes...");

    NSString * fileName = @"Remote";
    NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

    NSError * error = nil;
    NSStringEncoding encoding;
    NSString * fileContent = [NSString stringWithContentsOfFile:filePath
                                                   usedEncoding:&encoding
                                                          error:&error];
    if (error) { MSHandleErrors(error); return; }

#ifdef SHOULD_LOG_REMOTE
    logImportFile(fileName, fileContent);
#endif
    NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];
    if (error) { MSHandleErrors(error); return; }

#ifdef SHOULD_LOG_REMOTE
    logParsedImportFile(importObjects);
#endif
    NSArray * remotes = [Remote MR_importFromArray:importObjects inContext:context];
    MSLogDebug(@"%i remotes imported", [remotes count]);

    error = nil;
    [context save:&error];
    if (error) MSHandleErrors(error);

#ifdef SHOULD_LOG_REMOTE
    logImportedObject(remotes);
#endif
}

+ (void)loadRemoteController:(NSManagedObjectContext *)context
{
    MSLogDebug(@"loading remote controller...");

    NSString * fileName = @"RemoteController";
    NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

    NSError * error = nil;
    NSStringEncoding encoding;
    NSString * fileContent = [NSString stringWithContentsOfFile:filePath
                                                  usedEncoding:&encoding
                                                         error:&error];
    if (error) { MSHandleErrors(error); return; }

#ifdef SHOULD_LOG_REMOTECONTROLLER
    logImportFile(fileName, fileContent);
#endif
    MSDictionary * importObject = [MSJSONSerialization objectByParsingString:fileContent error:&error];
    if (error) { MSHandleErrors(error); return; }

#ifdef SHOULD_LOG_REMOTECONTROLLER
    logParsedImportFile(importObject);
#endif
    RemoteController * remoteController = [RemoteController MR_importFromObject:importObject
                                                                      inContext:context];
    MSLogDebug(@"remote controller imported? %@", BOOLString((remoteController != nil)));

#ifdef SHOULD_LOG_REMOTECONTROLLER
    logImportedObject(remoteController);
#endif
}

+ (void)loadManufacturers:(NSManagedObjectContext *)context
{
    MSLogDebug(@"loading manufacturers...");

    NSString * fileName = @"Manufacturer";
    NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

    NSError * error = nil;
    NSStringEncoding encoding;
    NSString * fileContent = [NSString stringWithContentsOfFile:filePath
                                                   usedEncoding:&encoding
                                                          error:&error];
    if (error) { MSHandleErrors(error); return; }

#ifdef SHOULD_LOG_MANUFACTURERS
    logImportFile(fileName, fileContent);
#endif
    NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];
    if (error) { MSHandleErrors(error); return; }

#ifdef SHOULD_LOG_MANUFACTURERS
    logParsedImportFile(importObjects);
#endif

    NSArray * manufacturers = [Manufacturer MR_importFromArray:importObjects inContext:context];
    MSLogDebug(@"%i manufacturers imported", [manufacturers count]);

#ifdef SHOULD_LOG_MANUFACTURERS
    logImportedObject(manufacturers);
#endif
}


+ (void)loadComponentDevices:(NSManagedObjectContext *)context
{
    MSLogDebug(@"loading component devices...");

    NSString * fileName = @"ComponentDevice";
    NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

    NSError * error = nil;
    NSStringEncoding encoding;
    NSString * fileContent = [NSString stringWithContentsOfFile:filePath
                                                   usedEncoding:&encoding
                                                          error:&error];
    if (error) { MSHandleErrors(error); return; }

#ifdef SHOULD_LOG_COMPONENTDEVICES
    logImportFile(fileName, fileContent);
#endif
    NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];
    if (error) { MSHandleErrors(error); return; }

#ifdef SHOULD_LOG_COMPONENTDEVICES
    logParsedImportFile(importObjects);
#endif    
    NSArray * componentDevices = [ComponentDevice MR_importFromArray:importObjects inContext:context];
    MSLogDebug(@"%i component devices imported", [componentDevices count]);

#ifdef SHOULD_LOG_COMPONENTDEVICES
    logImportedObject(componentDevices);
#endif
}

+ (void)loadIRCodes:(NSManagedObjectContext *)context
{
    MSLogDebug(@"loading ir codes...");

    NSString * fileName = @"IRCode";
    NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

    NSError * error = nil;
    NSStringEncoding encoding;
    NSString * fileContent = [NSString stringWithContentsOfFile:filePath
                                                   usedEncoding:&encoding
                                                          error:&error];
    if (error) { MSHandleErrors(error); return; }

#ifdef SHOULD_LOG_IRCODES
    logImportFile(fileName, fileContent);
#endif

    NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];
    if (error) { MSHandleErrors(error); return; }

#ifdef SHOULD_LOG_IRCODES
    logParsedImportFile(importObjects);
#endif
    NSArray * ircodes = [IRCode MR_importFromArray:importObjects inContext:context];
    MSLogDebug(@"%i ir codes imported", [ircodes count]);

#ifdef SHOULD_LOG_IRCODES
    logImportedObject(ircodes);
#endif
}

+ (void)loadPowerCommands:(NSManagedObjectContext *)context
{
    MSLogDebug(@"loading power commands...");

    NSString * fileName = @"PowerCommand";
    NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

    NSError * error = nil;
    NSStringEncoding encoding;
    NSString * fileContent = [NSString stringWithContentsOfFile:filePath
                                                   usedEncoding:&encoding
                                                          error:&error];
    if (error) { MSHandleErrors(error); return; }
#ifdef SHOULD_LOG_POWERCOMMANDS
    logImportFile(fileName, fileContent);
#endif
    NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];
    if (error) { MSHandleErrors(error); return; }

#ifdef SHOULD_LOG_POWERCOMMANDS
    logParsedImportFile(importObjects);
#endif
    NSArray * commands = [SendIRCommand MR_importFromArray:importObjects inContext:context];
    MSLogDebug(@"%i power commands imported", [commands count]);

#ifdef SHOULD_LOG_POWERCOMMANDS
    logImportedObject(commands);
#endif
}

+ (void)loadImages:(NSManagedObjectContext *)context
{
    MSLogDebug(@"loading images...");

    NSString * fileName = @"Glyphish";
    NSString * filePath = [MainBundle pathForResource:fileName ofType:@"json"];

    NSError * error = nil;
    NSStringEncoding encoding;
    NSString * fileContent = [NSString stringWithContentsOfFile:filePath
                                                   usedEncoding:&encoding
                                                          error:&error];
    if (error) { MSHandleErrors(error); return; }

#ifdef SHOULD_LOG_IMAGES
    logImportFile(fileName, fileContent);
#endif

    NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];
    if (error) { MSHandleErrors(error); return; }

#ifdef SHOULD_LOG_IMAGES
    logParsedImportFile(importObjects);
#endif
    NSArray * images = [Image MR_importFromArray:importObjects inContext:context];
    MSLogDebug(@"%i images imported", [images count]);

#ifdef SHOULD_LOG_IMAGES
    logImportedObject(images);
#endif
}


@end
