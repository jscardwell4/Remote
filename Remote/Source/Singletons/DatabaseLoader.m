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

#define USER_CODES_PLIST    @"UserCodes"
#define CODE_DATABASE_PLIST @"CodeDatabase-Pruned"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static const int   msLogContext = (LOG_CONTEXT_BUILDING|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

@implementation DatabaseLoader

+ (BOOL)loadData
{
    MSLogDebug(@"beginning data load...");

 /*
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

    [CoreDataManager saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         @autoreleasepool { [self loadIRCodes:context]; }
     }];

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


    MSLogDebug(@"data load complete");

    return YES;
}

+ (void)loadRemoteController:(NSManagedObjectContext *)context
{
    MSLogDebug(@"loading remote controller...");

    NSString * filePath = [MainBundle pathForResource:@"RemoteController" ofType:@"json"];

    NSError * error = nil;
    MSDictionary * importObject = [MSJSONSerialization objectByParsingFile:filePath
                                                                   options:MSJSONFormatDefault
                                                                     error:&error];
    NSString * result = [MSJSONSerialization JSONFromObject:importObject];
    MSLogDebug(@"result:\n%@", result);

    if (error) MSHandleErrors(error);

    id remoteController = [RemoteController MR_importFromObject:importObject inContext:context];
    MSLogDebug(@"remote controller imported? %@", BOOLString((remoteController != nil)));
}

+ (void)loadManufacturers:(NSManagedObjectContext *)context
{
    MSLogDebug(@"loading manufacturers...");

    NSString * filePath = [MainBundle pathForResource:@"Manufacturer" ofType:@"json"];

    NSError * error = nil;
    NSArray * importObjects = [MSJSONSerialization objectByParsingFile:filePath error:&error];

    if (error) MSHandleErrors(error);

    NSArray * manufacturers = [Manufacturer MR_importFromArray:importObjects inContext:context];
    MSLogDebug(@"%i manufacturers imported", [manufacturers count]);
}


+ (void)loadComponentDevices:(NSManagedObjectContext *)context
{
    MSLogDebug(@"loading component devices...");

    NSString * filePath = [MainBundle pathForResource:@"ComponentDevice" ofType:@"json"];

    NSError * error = nil;
    NSArray * importObjects = [MSJSONSerialization objectByParsingFile:filePath error:&error];

    if (error) MSHandleErrors(error);

    NSArray * componentDevices = [ComponentDevice MR_importFromArray:importObjects inContext:context];
    MSLogDebug(@"%i component devices imported", [componentDevices count]);
}

+ (void)loadIRCodes:(NSManagedObjectContext *)context
{
    MSLogDebug(@"loading ir codes...");

    NSString * filePath = [MainBundle pathForResource:@"IRCode" ofType:@"json"];

    NSError * error = nil;
    NSArray * importObjects = [MSJSONSerialization objectByParsingFile:filePath error:&error];

    if (error) MSHandleErrors(error);

    NSArray * ircodes = [IRCode MR_importFromArray:importObjects inContext:context];
    MSLogDebug(@"%i ir codes imported", [ircodes count]);
}

+ (void)loadPowerCommands:(NSManagedObjectContext *)context
{
    MSLogDebug(@"loading power commands...");

    NSString * filePath = [MainBundle pathForResource:@"PowerCommand" ofType:@"json"];

    NSError * error = nil;
    NSArray * importObjects = [MSJSONSerialization objectByParsingFile:filePath error:&error];

    if (error) MSHandleErrors(error);

    NSArray * commands = [SendIRCommand MR_importFromArray:importObjects inContext:context];
    MSLogDebug(@"%i power commands imported", [commands count]);
}

+ (void)loadImages:(NSManagedObjectContext *)context
{
    MSLogDebug(@"loading images...");

    NSString * filePath = [MainBundle pathForResource:@"Image" ofType:@"json"];

    NSError * error = nil;
    NSArray * importObjects = [MSJSONSerialization objectByParsingFile:filePath error:&error];

    if (error) MSHandleErrors(error);

    NSArray * images = [Image MR_importFromArray:importObjects inContext:context];
    MSLogDebug(@"%i images imported", [images count]);
}


@end
