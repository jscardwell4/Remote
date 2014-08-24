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

#define USER_CODES_PLIST    @"UserCodes"
#define CODE_DATABASE_PLIST @"CodeDatabase-Pruned"

#define LOG_IMPORT_FILE      1
#define LOG_PARSED_FILE      2
#define LOG_RESULTING_OBJECT 4

#define REMOTECONTROLLER_LOG_FLAG 4
#define REMOTE_LOG_FLAG           4
#define IMAGES_LOG_FLAG           0
#define POWERCOMMANDS_LOG_FLAG    0
#define MANUFACTURERS_LOG_FLAG    0
#define COMPONENTDEVICES_LOG_FLAG 0
#define IRCODES_LOG_FLAG          0

static int       ddLogLevel       = LOG_LEVEL_DEBUG;
static const int msLogContext     = (LOG_CONTEXT_BUILDING | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);
static const int importLogContext = (LOG_CONTEXT_IMPORT | LOG_CONTEXT_FILE);
#pragma unused(ddLogLevel, msLogContext)

void logImportFile(NSString * fileName, NSString * fileContent, int flag)
{
    if ((flag & LOG_IMPORT_FILE) == LOG_IMPORT_FILE)
        MSLogCDebugInContext(importLogContext, @"%@.json:\n%@\n", fileName, fileContent);
}

void logParsedImportFile(id parsedObject, int flag)
{
    if ((flag & LOG_PARSED_FILE) == LOG_PARSED_FILE)
    MSLogCDebugInContext(importLogContext,
                         @"JSON from parsed file:\n%@\n",
                         [MSJSONSerialization JSONFromObject:parsedObject]);
}

void logImportedObject(id importedObject, int flag)
{
    if ((flag & LOG_RESULTING_OBJECT) == LOG_RESULTING_OBJECT)
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

 I think these are now loaded via manufacturers


     [CoreDataManager saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         @autoreleasepool { [self loadIRCodes:context]; }
     }];
*/

/*

 I think these are now loaded via component devices

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

    logImportFile(fileName, fileContent, REMOTE_LOG_FLAG);
    NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];
    if (error) { MSHandleErrors(error); return; }

    logParsedImportFile(importObjects, REMOTE_LOG_FLAG);
    NSArray * remotes = [Remote importObjectsFromData:importObjects inContext:context];
    MSLogDebug(@"%lu remotes imported", (unsigned long)[remotes count]);

    error = nil;
    [context save:&error];
    MSHandleErrors(error);

    logImportedObject(remotes, REMOTE_LOG_FLAG);
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

    logImportFile(fileName, fileContent, REMOTECONTROLLER_LOG_FLAG);
    MSDictionary * importObject = [MSJSONSerialization objectByParsingString:fileContent error:&error];
    if (error) { MSHandleErrors(error); return; }

    logParsedImportFile(importObject, REMOTECONTROLLER_LOG_FLAG);
    RemoteController * remoteController = [RemoteController importObjectFromData:importObject
                                                                      inContext:context];
    MSLogDebug(@"remote controller imported? %@", BOOLString((remoteController != nil)));

    logImportedObject(remoteController, REMOTECONTROLLER_LOG_FLAG);
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

    logImportFile(fileName, fileContent, MANUFACTURERS_LOG_FLAG);
    NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];
    if (error) { MSHandleErrors(error); return; }

    logParsedImportFile(importObjects, MANUFACTURERS_LOG_FLAG);

    NSArray * manufacturers = [Manufacturer importObjectsFromData:importObjects inContext:context];
    MSLogDebug(@"%lu manufacturers imported", (unsigned long)[manufacturers count]);

    logImportedObject(manufacturers, MANUFACTURERS_LOG_FLAG);
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

    logImportFile(fileName, fileContent, COMPONENTDEVICES_LOG_FLAG);
    NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];
    if (error) { MSHandleErrors(error); return; }

    logParsedImportFile(importObjects, COMPONENTDEVICES_LOG_FLAG);
    NSArray * componentDevices = [ComponentDevice importObjectsFromData:importObjects inContext:context];
    MSLogDebug(@"%lu component devices imported", (unsigned long)[componentDevices count]);

    logImportedObject(componentDevices, COMPONENTDEVICES_LOG_FLAG);
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

    logImportFile(fileName, fileContent, IRCODES_LOG_FLAG);

    NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];
    if (error) { MSHandleErrors(error); return; }

    logParsedImportFile(importObjects, IRCODES_LOG_FLAG);
    NSArray * ircodes = [IRCode importObjectsFromData:importObjects inContext:context];
    MSLogDebug(@"%lu ir codes imported", (unsigned long)[ircodes count]);

    logImportedObject(ircodes, IRCODES_LOG_FLAG);
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
    logImportFile(fileName, fileContent, POWERCOMMANDS_LOG_FLAG);
    NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];
    if (error) { MSHandleErrors(error); return; }

    logParsedImportFile(importObjects, POWERCOMMANDS_LOG_FLAG);
    NSArray * commands = [SendIRCommand importObjectsFromData:importObjects inContext:context];
    MSLogDebug(@"%lu power commands imported", (unsigned long)[commands count]);

    logImportedObject(commands, POWERCOMMANDS_LOG_FLAG);
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

    logImportFile(fileName, fileContent, IMAGES_LOG_FLAG);

    NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];
    if (error) { MSHandleErrors(error); return; }

    logParsedImportFile(importObjects, IMAGES_LOG_FLAG);
    NSArray * images = [Image importObjectsFromData:importObjects inContext:context];
    MSLogDebug(@"%lu images imported", (unsigned long)[images count]);

    logImportedObject(images, IMAGES_LOG_FLAG);
}


@end
