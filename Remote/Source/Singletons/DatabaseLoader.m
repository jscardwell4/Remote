//
// DataBaseLoader.m
// Remote
//
// Created by Jason Cardwell on 2/19/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "DatabaseLoader.h"
#import "BankObjectGroup.h"
#import "BankObjects.h"
#import "CoreDataManager.h"
#import "MSRemoteAppController.h"

#define USER_CODES_PLIST    @"UserCodes"
#define CODE_DATABASE_PLIST @"CodeDatabase-Pruned"

static const int   ddLogLevel   = LOG_LEVEL_DEBUG;
static const int   msLogContext = (LOG_CONTEXT_BUILDING|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

@implementation DatabaseLoader

+ (BOOL)loadData
{
    MSLogDebug(@"beginning data load...\nloading user codes...");
    
    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         @autoreleasepool { [self loadUsersCodes:context]; }
     }];

    MSLogDebug(@"loading background images...");
    
    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         @autoreleasepool { [self loadBackgroundImages:context]; }
     }];

    MSLogDebug(@"loading icon images...");
    
    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         @autoreleasepool { [self loadIconImages:context]; }
     }];

/*
    MSLogDebug(@"loading factory codes...");
    
    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         @autoreleasepool { [self loadFactoryCodesInContext:context]; }
     }];
*/

    MSLogDebug(@"data load complete");

    return YES;
}

+ (void)loadFactoryCodesInContext:(NSManagedObjectContext *)context
{
    // Keys for plist entries
    MSKIT_STATIC_STRING_CONST   kDatabaseKey     = @"Pronto Hex Database";
    MSKIT_STATIC_STRING_CONST   kManufacturerKey = @"Manufacturer";
    MSKIT_STATIC_STRING_CONST   kCodesetKey      = @"Codeset";
    MSKIT_STATIC_STRING_CONST   kName1           = @"Name 1";
//    MSKIT_STATIC_STRING_CONST   kName2           = @"Name 2";


     NSArray * codesArray = [NSDictionary dictionaryWithContentsOfURL:
                              [MainBundle URLForResource:CODE_DATABASE_PLIST
                                           withExtension:@"plist"]][kDatabaseKey];

     BOIRCodeset * codeset = nil;
     @autoreleasepool
     {
         // Enumerate list content creating a code for each entry
         for (NSDictionary * codeAttributes in codesArray)
         {
             // Get the code set for this entry
             NSString * codesetName = codeAttributes[kCodesetKey];

             // Create a CodeSet object if necessary and set its manufacturer attribute
             if (ValueIsNil(codeset) || ![codeset.name isEqualToString:codesetName])
             {
                 codeset = [BOIRCodeset groupWithName:codesetName context:context];
                 codeset.manufacturer =
                 [Manufacturer manufacturerWithName:codeAttributes[kManufacturerKey] context:context];
             }

             // Create an IRCode object for this code with attributes from the list entry
             FactoryIRCode * code = [FactoryIRCode codeFromProntoHex:codeAttributes[@"Hex Code"]
                                                                 context:context];
             code.codeset       = codeset;
             code.name          = codeAttributes[kName1];
//             code.alternateName = codeAttributes[kName2];
//             if ([code.name isEqualToString:code.alternateName]) code.alternateName = nil;
         }
     }
}

/// Parses *CodeBank.plist* to create <ComponentDevice> objects and <IRCode> objects.
+ (void)loadUsersCodes:(NSManagedObjectContext *)context
{
     // Create devices
     NSDictionary * codeBankPlist = [NSDictionary dictionaryWithContentsOfURL:
                                     [MainBundle URLForResource:USER_CODES_PLIST
                                                  withExtension:@"plist"]];
     assert(codeBankPlist);

     @autoreleasepool
     {
         for (NSString * deviceName in [codeBankPlist allKeys])
         {
             // Create codes for this device
             ComponentDevice * device = [ComponentDevice MR_createInContext:context];
             device.name = deviceName;
             
             if 		 ([@"AV Receiver" isEqualToString:deviceName]) 	device.port = 2;
             else if ([@"Comcast DVR" isEqualToString:deviceName]) 	device.port = 1;
             else if ([@"Samsung TV"  isEqualToString:deviceName]) 	device.port = 3;
             else if ([@"PS3"         isEqualToString:deviceName]) 	device.port = 3;

             NSDictionary * deviceCodes = codeBankPlist[deviceName];

             @autoreleasepool
             {
                 for (NSString * codeName in [deviceCodes allKeys])
                 {
                     NSDictionary * codeDict = deviceCodes[codeName];

                     // Create this code
                     UserIRCode * code = [UserIRCode codeForDevice:device];
                     code.name            = codeName;
                     code.frequency       = NSUIntegerValue(codeDict[@"Frequency"]);
                     code.repeatCount     = NSUIntegerValue(codeDict[@"Repeat Count"]);
                     code.offset          = NSUIntegerValue(codeDict[@"Offset"]);
                     code.onOffPattern    = codeDict[@"On-Off Pattern"];
                     code.setsDeviceInput = BOOLValue(codeDict[@"Input"]);
                 }
             }
         }
     }
}

/// Creates <IconImage> objects for files located in the bundle's *icons* directory.
+ (void)loadIconImages:(NSManagedObjectContext *)context
{
    for (NSString * indexFileName in @[@"Glyphish Icons"])
    {
        NSError  * error = nil;
        NSString * iconFileList =
        [NSString stringWithContentsOfFile:[MainBundle pathForResource:indexFileName ofType:@"txt"]
                                  encoding:NSUTF8StringEncoding
                                     error:&error];

        if (error) [MagicalRecord handleErrors:[MSError errorWithError:error
                                                               message:@"failed to get list of icons"]];

        NSArray * iconFileNames = [iconFileList
                                   componentsSeparatedByCharactersInSet:[NSCharacterSet
                                                                         newlineCharacterSet]];

        @autoreleasepool
        {
            for (NSString * fileName in iconFileNames)
            {
                if (StringIsEmpty(fileName)) continue;

                // Create entry for this file
                Image * iconImage = [Image imageWithFileName:fileName context:context];

                if (!iconImage) MSLogErrorTag(@"failed to create model for icon image:%@", iconImage);
            }
        }
    }
}

/// Creates <BackgroundImage> objects for files located in the bundle's *backgrounds* directory.
+ (void)loadBackgroundImages:(NSManagedObjectContext *)context
{
    NSError  * error = nil;
    NSString * list =
        [NSString stringWithContentsOfFile:[MainBundle pathForResource:@"Glyphish Backgrounds" ofType:@"txt"]
                                  encoding:NSUTF8StringEncoding
                                     error:&error];

    if (error) [MagicalRecord handleErrors:[MSError
                                            errorWithError:error
                                                   message:@"failed to get list of backgrounds"]];

    NSArray * names = [list componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    @autoreleasepool
    {
        for (NSString * fileName in names)
        {
            if (StringIsEmpty(fileName)) continue;

            // Create entry for this file
            Image * image = [Image imageWithFileName:fileName context:context];

            if (!image) MSLogErrorTag(@"failed to create model for background image:%@", image);
        }
    }
}

/// @name ￼Logging database content

+ (void)logCodeBank
{
    NSManagedObjectContext * context = [NSManagedObjectContext MR_defaultContext];

    [context performBlockAndWait:
     ^{
         NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ComponentDevice"];

         NSError * error = nil;
         NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

         if (error)
         {
             [MagicalRecord handleErrors:
              [MSError errorWithError:error message:@"failed to retrieve devices from database"]];
             return;
         }

         else if (ValueIsNil(fetchedObjects))
         {
            MSLogWarnTag(@"fetch returned zero component devices");
            return;
         }

         NSMutableString * logString = [@"\nIRCodes by ComponentDevice\n" mutableCopy];

         for (ComponentDevice * device in fetchedObjects)
         {
            [logString appendFormat:@"deviceName: %@\n", device.name];

            for (IRCode * irCode in device.codes)
                [logString appendFormat:@"\t%@\n", irCode.name];
         }

         fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IRCodeSet"];

         fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

         if (error)
         {
             [MagicalRecord handleErrors:
              [MSError errorWithError:error message:@"failed to retrieve codesets from database"]];
             return;
         }

         else if (ValueIsNil(fetchedObjects)) { MSLogWarnTag(@"fetch returned zero codesets"); return; }

         [logString appendString:@"\nIRCodes by IRCodeSet\n"];

         for (BOIRCodeset * codeset in fetchedObjects)
         {
            [logString appendFormat:@"codeset: %@\n", codeset.name];
            for (IRCode * irCode in codeset.codes) [logString appendFormat:@"\t%@\n", irCode.name];
         }

         MSLogInfo(@"%@", logString);
     }];
}

@end
