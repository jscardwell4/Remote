//
// DataBaseLoader.m
// iPhonto
//
// Created by Jason Cardwell on 2/19/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "DatabaseLoader.h"
#import "IRCode.h"
#import "FactoryIRCode.h"
#import "UserIRCode.h"
#import "GalleryGroup.h"
#import "IRCodeSet.h"
#import "GalleryImage.h"
#import "ComponentDevice.h"
#import "Manufacturer.h"
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

- (void)saveAndResetContext;

@end

@implementation DatabaseLoader
@synthesize managedObjectContext;

+ (DatabaseLoader *)sharedDatabaseLoader {
    static dispatch_once_t   pred          = 0;
    __strong static id       _sharedObject = nil;

    dispatch_once(&pred, ^{_sharedObject = [[self alloc] init]; }

                  );

    return _sharedObject;
}

/// @name ￼Loading data into the database

+ (BOOL)loadDataIntoContext:(NSManagedObjectContext *)context {
    self.sharedDatabaseLoader.managedObjectContext = (context
                                                      ? context
                                                      :[DataManager mainObjectContext]);

    [context performBlockAndWait:^{
                 [self.sharedDatabaseLoader loadDataIntoDatabase];
             }

    ];

    return YES;
}

- (void)loadDataIntoDatabase {
    @autoreleasepool {[self loadUserCodeBankIntoDatabase]; }

    [self saveAndResetContext];

    @autoreleasepool {[self loadBackgroundImagesFromBundleIntoDatabase]; }

    [self saveAndResetContext];

    @autoreleasepool {[self loadIconsFromBundleIntoDatabase]; }

    [self saveAndResetContext];

    @autoreleasepool {[self loadProntoHexCodeBankIntoDatabase]; }

// [self saveAndResetContext];
}

- (void)saveAndResetContext {
    __block NSError * error   = nil;
    __block BOOL      savedOK = NO;

    [self.managedObjectContext
     performBlockAndWait:^{
         savedOK = [self.managedObjectContext
                   save:&error];
     }

    ];

    if (!savedOK)
        DDLogError(@"error:%@, %@", error, [error userInfo]);
    else {
        DDLogDebug(@"%@\n\tresetting context after successful save...", ClassTagString);
        [self.managedObjectContext
         performBlockAndWait:^{[self.managedObjectContext reset]; }

        ];
    }
}

- (void)loadProntoHexCodeBankIntoDatabase {
    // Keys for plist entries
    static NSString * const   databaseKey     = @"Pronto Hex Database";
    static NSString * const   manufacturerKey = @"Manufacturer";
    static NSString * const   codesetKey      = @"Codeset";
// static NSString * const name1Key = @"Name 1";
// static NSString * const name2Key = @"Name 2";
// static NSString * const hexcodeKey = @"Hex Code";

// static const int plistCount = 56;
    NSArray * codesArray =
        [[NSDictionary dictionaryWithContentsOfURL:
          [MainBundle URLForResource:CODE_DATABASE_PLIST
                       withExtension:@"plist"]]
         objectForKey:databaseKey];
    IRCodeSet * codeSet         = nil;
    CGFloat     currentProgress = 0.0;
    NSInteger   codeCount       = [codesArray count];
    CGFloat     increment       = 1.0 / codeCount;

    @autoreleasepool {
        // Enumerate list content creating a code for each entry
        for (NSDictionary * codeAttributes in codesArray) {
            // Get the code set for this entry
            NSString * codeSetName = codeAttributes[codesetKey];

            // Create a CodeSet object if necessary and set its manufacturer attribute
            if (ValueIsNil(codeSet) || ![codeSet.name isEqualToString:codeSetName]) {
                codeSet              = [IRCodeSet newCodeSetInContext:managedObjectContext withName:codeSetName];
                codeSet.manufacturer =
                    [Manufacturer manufacturerWithName:codeAttributes[manufacturerKey]
                                             inContext:codeSet.managedObjectContext];
            }

            // Create an IRCode object for this code with attributes from the list entry
            FactoryIRCode * code = [FactoryIRCode newCodeFromProntoHex:codeAttributes[@"Hex Code"]
                                                             inCodeSet:codeSet];

            code.name          = codeAttributes[@"Name 1"];
            code.alternateName = codeAttributes[@"Name 2"];
            if ([code.name isEqualToString:code.alternateName]) code.alternateName = nil;

// code.userCode = NO;

            currentProgress += increment;
        }
    }
}  /* loadProntoHexCodeBankIntoDatabase */

- (void)loadUserCodeBankIntoDatabase {
    // Create devices
    NSDictionary * codeBankPlist =
        [NSDictionary dictionaryWithContentsOfURL:
         [MainBundle URLForResource:USER_CODES_PLIST
                      withExtension:@"plist"]];
    CGFloat     currentProgress = 0.0;
    NSInteger   codeCount       = 0;

    for (NSString * key in[codeBankPlist allKeys]) {
        codeCount += [codeBankPlist[key] count];
    }

    CGFloat   increment = 1.0 / codeCount;

    @autoreleasepool {
        for (NSString * deviceName in[codeBankPlist allKeys]) {
            // Create codes for this device
            ComponentDevice * device =
                [NSEntityDescription insertNewObjectForEntityForName:@"ComponentDevice"
                                              inManagedObjectContext:self.managedObjectContext];

            device.name = deviceName;

            if ([@"AV Receiver" isEqualToString : deviceName]) device.port = 2;
            else if ([@"Comcast DVR" isEqualToString : deviceName]) device.port = 1;
            else if ([@"Samsung TV" isEqualToString : deviceName]) device.port = 3;
            else if ([@"PS3" isEqualToString : deviceName]) device.port = 3;

            NSDictionary * deviceCodes = codeBankPlist[deviceName];

            @autoreleasepool {
                for (NSString * codeName in[deviceCodes allKeys]) {
                    // Create this code
                    UserIRCode * code =
                        [NSEntityDescription insertNewObjectForEntityForName:@"UserIRCode"
                                                      inManagedObjectContext:self.managedObjectContext];
                    NSDictionary * codeDict = deviceCodes[codeName];

                    code.name            = codeName;
                    code.frequency       = [codeDict[@"Frequency"] unsignedIntegerValue];
                    code.repeatCount     = [codeDict[@"Repeat Count"] unsignedIntegerValue];
                    code.offset          = [codeDict[@"Offset"] unsignedIntegerValue];
                    code.onOffPattern    = codeDict[@"On-Off Pattern"];
                    code.setsDeviceInput = [codeDict[@"Input"] boolValue];
                    code.device          = device;
// code.userCode = YES;

                    currentProgress += increment;
                }
            }
        }
    }
}  /* loadUserCodeBankIntoDatabase */

- (void)loadIconsFromBundleIntoDatabase {
    NSError  * error        = nil;
    NSString * iconFileList =
        [NSString stringWithContentsOfFile:[MainBundle pathForResource:@"iconList"
                                                                ofType:@"txt"]
                                  encoding:NSUTF8StringEncoding
                                     error:&error];

    if (ValueIsNotNil(error)) DDLogError(@"%@\n\tcould not read icon list file", ClassTagString);

    NSArray * iconFileNames =
        [iconFileList componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

// CGFloat currentProgress = 0.0;

// NSInteger fileCount = [iconFileNames count];

// CGFloat increment = 1.0 / fileCount;

    @autoreleasepool {
        for (NSString * fileName in iconFileNames) {
            if (StringIsEmpty(fileName)) continue;

            // Create entry for this file
            GalleryIconImage * iconImage =
                [GalleryIconImage iconImageForFile:fileName
                                           context:self.managedObjectContext];

            if (!iconImage) DDLogError(@"%@\n\tcould not create UIImage for icon image:%@", ClassTagString, iconImage);
        }
    }
}

- (void)loadBackgroundImagesFromBundleIntoDatabase {
    nsprintf(@"MainBundlePath: %@", MainBundlePath);
    NSError  * error              = nil;
    NSString * backgroundFileList =
        [NSString stringWithContentsOfFile:[MainBundle pathForResource:@"backgroundList"
                                                                ofType:@"txt"]
                                  encoding:NSUTF8StringEncoding
                                     error:&error];

    if (error) DDLogError(@"%@\n\tcould not read background list file", ClassTagString);

    NSArray * backgroundFileNames =
        [backgroundFileList componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    CGFloat     currentProgress = 0.0;
    NSInteger   fileCount       = [backgroundFileNames count];
    CGFloat     increment       = 1.0 / fileCount;

    @autoreleasepool {
        for (NSString * fileName in backgroundFileNames) {
            if (StringIsEmpty(fileName)) continue;

            // Create entry for this file
            GalleryBackgroundImage * image =
                [GalleryBackgroundImage backgroundImageForFile:fileName
                                                       context:self.managedObjectContext];

            if (!image) DDLogError(@"%@\n\tcould not create UIImage for icon image:%@", ClassTagString, image);

            currentProgress += increment;
        }
    }
}

/// @name ￼Logging database content

+ (void)logCodeBank {
    if (ValueIsNil(self.sharedDatabaseLoader) || ValueIsNil(self.sharedDatabaseLoader.managedObjectContext)) DDLogWarn(@"missing database loader or the context");

    [self.sharedDatabaseLoader.managedObjectContext
     performBlockAndWait:^{
         NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ComponentDevice"];

         NSError * error = nil;
         NSArray * fetchedObjects =
            [self.sharedDatabaseLoader.managedObjectContext
             executeFetchRequest:fetchRequest
                           error:&error];

         if (ValueIsNil(fetchedObjects)) {
            DDLogWarn(@"failed to retrieve ComponentDevice objects");

            return;
         }

         NSMutableString * logString =
            [NSMutableString stringWithString:@"\nIRCodes by ComponentDevice\n"];

         for (ComponentDevice * device in fetchedObjects) {
            [logString appendFormat:@"deviceName: %@\n", device.name];

            for (IRCode * irCode in device.codes) {
                [logString appendFormat:@"\t%@\n", irCode.name];
            }
         }

         fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IRCodeSet"];

         fetchedObjects =
            [self.sharedDatabaseLoader.managedObjectContext
             executeFetchRequest:fetchRequest
                           error:&error];

         if (ValueIsNil(fetchedObjects)) {
            DDLogWarn(@"failed to retrieve IRCodeSet objects");

            return;
         }

         [logString appendString:@"\nIRCodes by IRCodeSet\n"];

         for (IRCodeSet * codeSet in fetchedObjects) {
            [logString appendFormat:@"codeSet: %@\n", codeSet.name];

            for (IRCode * irCode in codeSet.codes) {
                [logString appendFormat:@"\t%@\n", irCode.name];
            }
         }

         DDLogInfo(@"%@", logString);
     }

    ];
}  /* logCodeBank */

@end
