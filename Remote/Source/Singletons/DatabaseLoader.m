//
// DataBaseLoader.m
// Remote
//
// Created by Jason Cardwell on 2/19/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "DatabaseLoader.h"
#import "BankObjectGroup.h"
#import "BankObjectGroup.h"
#import "BankObject.h"
#import "BankObject.h"
#import "CoreDataManager.h"
#import "MSRemoteAppController.h"

#define USER_CODES_PLIST    @"UserCodes"
#define CODE_DATABASE_PLIST @"CodeDatabase-Pruned"

static int   ddLogLevel = LOG_LEVEL_WARN;

@interface DatabaseLoader ()

/// Creates <IconImage> objects for files located in the bundle's *icons* directory.
- (void)loadIconsFromBundleIntoDatabase;

/// Parses *CodeBank.plist* to create <ComponentDevice> objects and <IRCode> objects.
- (void)loadUserCodeBankIntoDatabase;

- (void)loadProntoHexCodeBankIntoDatabase;

/// Calls all the methods sequentially for loading the data.
- (void)loadDataIntoDatabase;

/// Creates <BackgroundImage> objects for files located in the bundle's *backgrounds* directory.
- (void)loadBackgroundImagesFromBundleIntoDatabase;

/// Stores a reference to the context passed to `loadDataIntoContext:`.
@property (nonatomic, weak) NSManagedObjectContext * managedObjectContext;

@end

@implementation DatabaseLoader

+ (DatabaseLoader *)sharedDatabaseLoader {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{_sharedObject = [[self alloc] init]; });
    return _sharedObject;
}

/// @name ￼Loading data into the database

+ (BOOL)loadDataIntoContext:(NSManagedObjectContext *)context
{
//    context = (context ? context : [[CoreDataManager sharedManager] mainObjectContext]);
    self.sharedDatabaseLoader.managedObjectContext = context;
    [context performBlockAndWait:^{ [self.sharedDatabaseLoader loadDataIntoDatabase]; }];
    return YES;
}

- (void)loadDataIntoDatabase
{
    [_managedObjectContext performBlockAndWait:^{
        @autoreleasepool { [self loadUserCodeBankIntoDatabase]; }
        if ([CoreDataManager saveContext:self.managedObjectContext asynchronous:NO completion:nil])
            [[CoreDataManager sharedManager] resetContext:self.managedObjectContext];

        @autoreleasepool { [self loadBackgroundImagesFromBundleIntoDatabase]; }
        if ([CoreDataManager saveContext:self.managedObjectContext asynchronous:NO completion:nil])
            [[CoreDataManager sharedManager] resetContext:self.managedObjectContext];

        @autoreleasepool { [self loadIconsFromBundleIntoDatabase]; }
        if ([CoreDataManager saveContext:self.managedObjectContext asynchronous:NO completion:nil])
            [[CoreDataManager sharedManager] resetContext:self.managedObjectContext];

        @autoreleasepool { [self loadProntoHexCodeBankIntoDatabase]; }
        if ([CoreDataManager saveContext:self.managedObjectContext asynchronous:NO completion:nil])
            [[CoreDataManager sharedManager] resetContext:self.managedObjectContext];
    }];
}

- (void)loadProntoHexCodeBankIntoDatabase
{
    // Keys for plist entries
    MSKIT_STATIC_STRING_CONST   databaseKey     = @"Pronto Hex Database";
    MSKIT_STATIC_STRING_CONST   manufacturerKey = @"Manufacturer";
    MSKIT_STATIC_STRING_CONST   codesetKey      = @"Codeset";
// MSKIT_STATIC_STRING_CONST name1Key = @"Name 1";
// MSKIT_STATIC_STRING_CONST name2Key = @"Name 2";
// MSKIT_STATIC_STRING_CONST hexcodeKey = @"Hex Code";

// static const int plistCount = 56;

    [_managedObjectContext performBlockAndWait:
     ^{

        NSArray * codesArray = [[NSDictionary dictionaryWithContentsOfURL:
                                 [MainBundle URLForResource:CODE_DATABASE_PLIST
                                              withExtension:@"plist"]]
                                objectForKey:databaseKey];

        BOIRCodeset * codeset       = nil;
        CGFloat     currentProgress = 0.0;
        NSInteger   codeCount       = [codesArray count];
        CGFloat     increment       = 1.0 / codeCount;

        @autoreleasepool
        {
            // Enumerate list content creating a code for each entry
            for (NSDictionary * codeAttributes in codesArray)
            {
                // Get the code set for this entry
                NSString * codesetName = codeAttributes[codesetKey];

                // Create a CodeSet object if necessary and set its manufacturer attribute
                if (ValueIsNil(codeset) || ![codeset.name isEqualToString:codesetName])
                {
                    codeset = [BOIRCodeset groupWithName:codesetName context:_managedObjectContext];
                    codeset.manufacturer =
                        [BOManufacturer manufacturerWithName:codeAttributes[manufacturerKey]
                                                 context:codeset.managedObjectContext];
                }

                // Create an IRCode object for this code with attributes from the list entry
                BOFactoryIRCode * code = [BOFactoryIRCode codeFromProntoHex:codeAttributes[@"Hex Code"]
                                                                    context:_managedObjectContext];
                code.codeset       = codeset;
                code.name          = codeAttributes[@"Name 1"];
                code.alternateName = codeAttributes[@"Name 2"];
                if ([code.name isEqualToString:code.alternateName]) code.alternateName = nil;
                currentProgress += increment;
            }
        }
     }];
}

- (void)loadUserCodeBankIntoDatabase
{
    [_managedObjectContext performBlockAndWait:
     ^{
        // Create devices
        NSDictionary * codeBankPlist = [NSDictionary dictionaryWithContentsOfURL:
                                        [MainBundle URLForResource:USER_CODES_PLIST
                                                     withExtension:@"plist"]];
        CGFloat   currentProgress = 0.0;
        NSInteger codeCount       = 0;

        for (NSString * key in[codeBankPlist allKeys])
            codeCount += [codeBankPlist[key] count];

        CGFloat increment = 1.0 / codeCount;

        @autoreleasepool
        {
            for (NSString * deviceName in [codeBankPlist allKeys])
            {
                // Create codes for this device
                BOComponentDevice * device = [BOComponentDevice bankObjectWithName:deviceName
                                                                           context:_managedObjectContext];

                if 		([@"AV Receiver" isEqualToString:deviceName]) 	device.port = 2;
                else if ([@"Comcast DVR" isEqualToString:deviceName]) 	device.port = 1;
                else if ([@"Samsung TV" isEqualToString:deviceName]) 	device.port = 3;
                else if ([@"PS3" isEqualToString:deviceName]) 			device.port = 3;

                NSDictionary * deviceCodes = codeBankPlist[deviceName];

                @autoreleasepool
                {
                    for (NSString * codeName in [deviceCodes allKeys])
                    {
                        NSDictionary * codeDict = deviceCodes[codeName];
                        
                        // Create this code
                        BOUserIRCode * code = [BOUserIRCode codeForDevice:device];
                        code.name            = codeName;
                        code.frequency       = [codeDict[@"Frequency"] unsignedIntegerValue];
                        code.repeatCount     = [codeDict[@"Repeat Count"] unsignedIntegerValue];
                        code.offset          = [codeDict[@"Offset"] unsignedIntegerValue];
                        code.onOffPattern    = codeDict[@"On-Off Pattern"];
                        code.setsDeviceInput = [codeDict[@"Input"] boolValue];
                        currentProgress += increment;
                    }
                }
            }
        }
     }];
}

- (void)loadIconsFromBundleIntoDatabase
{
    [_managedObjectContext performBlockAndWait:
     ^{
        NSError  * error = nil;
        NSString * iconFileList =
            [NSString stringWithContentsOfFile:[MainBundle pathForResource:@"iconList" ofType:@"txt"]
                                      encoding:NSUTF8StringEncoding
                                         error:&error];

        if (error) DDLogError(@"%@\n\tcould not read icon list file", ClassTagString);

        NSArray * iconFileNames =
            [iconFileList componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

        @autoreleasepool
        {
            for (NSString * fileName in iconFileNames)
            {
                if (StringIsEmpty(fileName)) continue;

                // Create entry for this file
                BOIconImage * iconImage = [BOIconImage imageWithFileName:fileName
                                                                 context:_managedObjectContext];

                if (!iconImage) DDLogError(@"%@\n\tcould not create UIImage for icon image:%@",
                                           ClassTagString, iconImage);
            }
        }
     }];
}

- (void)loadBackgroundImagesFromBundleIntoDatabase
{
    [_managedObjectContext performBlockAndWait:
     ^{
        NSError  * error = nil;
        NSString * backgroundFileList =
            [NSString stringWithContentsOfFile:[MainBundle pathForResource:@"backgroundList"
                                                                    ofType:@"txt"]
                                      encoding:NSUTF8StringEncoding
                                         error:&error];

        if (error) DDLogError(@"%@\n\tcould not read background list file", ClassTagString);

        NSArray * backgroundFileNames =
            [backgroundFileList
             componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        CGFloat     currentProgress = 0.0;
        NSInteger   fileCount       = [backgroundFileNames count];
        CGFloat     increment       = 1.0 / fileCount;

        @autoreleasepool
        {
            for (NSString * fileName in backgroundFileNames)
            {
                if (StringIsEmpty(fileName)) continue;

                // Create entry for this file
                BOBackgroundImage * image = [BOBackgroundImage imageWithFileName:fileName
                                                                         context:_managedObjectContext];

                if (!image) DDLogError(@"%@\n\tcould not create UIImage for icon image:%@",
                                       ClassTagString, image);

                currentProgress += increment;
            }
        }
     }];
}

/// @name ￼Logging database content

+ (void)logCodeBank
{
    if (   ValueIsNil(self.sharedDatabaseLoader)
        || ValueIsNil(self.sharedDatabaseLoader.managedObjectContext))
        DDLogWarn(@"missing database loader or the context");

    [self.sharedDatabaseLoader.managedObjectContext performBlockAndWait:
     ^{
         NSFetchRequest * fetchRequest = [NSFetchRequest
                                          fetchRequestWithEntityName:@"ComponentDevice"];

         NSError * error = nil;
         NSArray * fetchedObjects = [self.sharedDatabaseLoader.managedObjectContext
                                         executeFetchRequest:fetchRequest
                                                       error:&error];

         if (ValueIsNil(fetchedObjects))
         {
            DDLogWarn(@"failed to retrieve ComponentDevice objects");
            return;
         }

         NSMutableString * logString = [@"\nIRCodes by ComponentDevice\n" mutableCopy];

         for (BOComponentDevice * device in fetchedObjects)
         {
            [logString appendFormat:@"deviceName: %@\n", device.name];

            for (BOIRCode * irCode in device.codes)
                [logString appendFormat:@"\t%@\n", irCode.name];
         }

         fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"IRCodeSet"];

         fetchedObjects = [self.sharedDatabaseLoader.managedObjectContext
                               executeFetchRequest:fetchRequest
                                             error:&error];

         if (ValueIsNil(fetchedObjects))
         {
            DDLogWarn(@"failed to retrieve IRCodeSet objects");
            return;
         }

         [logString appendString:@"\nIRCodes by IRCodeSet\n"];

         for (BOIRCodeset * codeset in fetchedObjects)
         {
            [logString appendFormat:@"codeset: %@\n", codeset.name];

            for (BOIRCode * irCode in codeset.codes)
                [logString appendFormat:@"\t%@\n", irCode.name];
         }

         DDLogInfo(@"%@", logString);
     }];
}

@end
