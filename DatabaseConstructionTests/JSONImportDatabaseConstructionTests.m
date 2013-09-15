//
//  JSONImportDatabaseConstructionTests.m
//  Remote
//
//  Created by Jason Cardwell on 4/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "JSONImportDatabaseConstructionTests.h"
#import "BankObject.h"
#import "BankObjectGroup.h"
#import "RemoteController.h"
#import "Activity.h"
#import "Command.h"
#import "RemoteElement.h"
#import "MSRemoteImportSupportFunctions.h"

#define JSONFilePath(n) \
    [[UserDefaults stringForKey:@"SenTestedUnitPath"] \
        stringByAppendingPathComponent:n".json"]

static const int   ddLogLevel    = LOG_LEVEL_UNITTEST;
static const int   msLogContext  = LOG_CONTEXT_UNITTEST;
static uint8_t     msTestOptions = MSCoreDataTestLogCreatedObjects;
#pragma unused(ddLogLevel, msLogContext, msTestOptions)

static MSJSONParser const * parser_ = nil;

@implementation JSONImportDatabaseConstructionTests

+ (void)setUp
{
    [super setUp];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ parser_ = [MSJSONParser parser]; });
}

+ (void)tearDown
{
    parser_ = nil;
    [super tearDown];
}

- (void)testImportBOComponentDevice
{
    NSError * error = nil;
    NSArray * importObjects = [parser_ arrayByParsingContentsOfFile:JSONFilePath(@"BOComponentDevice")
                                                         error:&error];
    if (error) MSHandleErrors(error);
    assertThat(importObjects, notNilValue());

    __block NSArray * deviceUUIDs = nil;

    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         NSArray * componentDevices = [ComponentDevice MR_importFromArray:importObjects
                                                                  inContext:context];
         assertThat(componentDevices, hasCountOf([importObjects count]));

         deviceUUIDs = [componentDevices valueForKeyPath:@"uuid"];
     }];

    [self.rootSavingContext performBlockAndWait:
     ^{
         NSMutableArray * fetchedObjects = [@[] mutableCopy];
         NSDictionary * deviceImportDataDirectory = [NSDictionary
                                                     dictionaryWithObjects:importObjects
                                                                   forKeys:[importObjects
                                                                            valueForKeyPath:@"name"]];
         for (NSString * uuid in deviceUUIDs)
         {
             ComponentDevice * device = [ComponentDevice objectWithUUID:uuid
                                                                  context:self.rootSavingContext];
             assertThat(device, notNilValue());

             [fetchedObjects addObject:device];

             NSDictionary * deviceImportData = deviceImportDataDirectory[device.name];

             assertThat(deviceImportData,        notNilValue()                                 );
             assertThat(@(device.port),          is(deviceImportData[@"port"])                 );
             assertThat(@(device.alwaysOn),      is(deviceImportData[@"alwaysOn"])             );
             assertThat(@(device.inputPowersOn), is(deviceImportData[@"inputPowersOn"])        );
             assertThat(device.codes,            hasCountOf([deviceImportData[@"codes"] count]));

             NSDictionary * codeImportDataDirectory = [NSDictionary
                                                       dictionaryWithObjects:deviceImportData[@"codes"]
                                                                     forKeys:[deviceImportData[@"codes"]
                                                                              valueForKeyPath:@"name"]];
             for (IRCode * code in device.codes)
             {
                 NSDictionary * codeImportData = codeImportDataDirectory[code.name];
                 assertThat(codeImportData,          notNilValue()                         );
                 assertThat(@(code.frequency),       is(codeImportData[@"frequency"])      );
                 assertThat(@(code.repeatCount),     is(codeImportData[@"repeatCount"])    );
                 assertThat(@(code.offset),          is(codeImportData[@"offset"])         );
                 assertThat(@(code.setsDeviceInput), is(codeImportData[@"setsDeviceInput"]));
                 assertThat(code.onOffPattern,       is(codeImportData[@"onOffPattern"])   );
             }
         }
         MSLogCreatedObjectsInContext(LOG_CONTEXT_FILE,
                                      @"created component devices:\n%@",
                                      [[fetchedObjects valueForKeyPath:@"deepDescription"]
                                       componentsJoinedByString:@"\n"]);
     }];
}

- (void)testImportBOBackgroundImage
{
    NSError * error = nil;
    NSDictionary * importObject = [parser_ dictionaryByParsingContentsOfFile:JSONFilePath(@"BOBackgroundImage")
                                                                   error:&error];
    if (error) MSHandleErrors(error);
    assertThat(importObject, notNilValue());

    __block NSString * imageGroupUUID = nil;

    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         BOImageGroup * imageGroup = [BOImageGroup MR_importFromObject:importObject inContext:context];
         assertThat(imageGroup.images, hasCountOf([importObject[@"images"] count]));

         imageGroupUUID = imageGroup.uuid;
         assertThat(imageGroupUUID, is(importObject[@"uuid"]));
     }];

    [self.rootSavingContext performBlockAndWait:
     ^{
         BOImageGroup * fetchedGroup = [BOImageGroup objectWithUUID:imageGroupUUID
                                                          context:self.rootSavingContext];
         assertThat(fetchedGroup, notNilValue());
         assertThat(fetchedGroup.images, hasCountOf([importObject[@"images"] count]));

         MSLogCreatedObjectsInContext(LOG_CONTEXT_FILE,
                                      @"image group created:\n%@", [fetchedGroup deepDescription]);

         for (NSDictionary * imageImportData in importObject[@"images"])
         {
             BOBackgroundImage * image = (BOBackgroundImage *)fetchedGroup[imageImportData[@"uuid"]];
             assertThat(image, notNilValue());
             assertThat(@(image.tag), is(imageImportData[@"tag"]));
             assertThat(image.fileName, is($(@"%@.%@",
                                             imageImportData[@"baseFileName"],
                                             imageImportData[@"fileNameExtension"])));
             assertThat(image.name, is(imageImportData[@"name"]));
         }

         MSLogCreatedObjectsInContext(LOG_CONTEXT_FILE,
                                      @"background images created:\n%@",
                                      [[fetchedGroup.images valueForKeyPath:@"deepDescription"]
                                       componentsJoinedByString:@"\n"]);
     }];
}

- (void)testImportBOIconImage
{
    NSError * error = nil;
    NSDictionary * importObject = [parser_ dictionaryByParsingContentsOfFile:JSONFilePath(@"BOIconImage")
                                                                  error:&error];
    if (error) MSHandleErrors(error);
    assertThat(importObject, notNilValue());

    __block NSString * imageGroupUUID = nil;

    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         BOImageGroup * imageGroup = [BOImageGroup MR_importFromObject:importObject inContext:context];
         assertThat(imageGroup.images, hasCountOf([importObject[@"images"] count]));

         imageGroupUUID = imageGroup.uuid;
         assertThat(imageGroupUUID, is(importObject[@"uuid"]));
     }];

    [self.rootSavingContext performBlockAndWait:
     ^{
         BOImageGroup * fetchedGroup = [BOImageGroup objectWithUUID:imageGroupUUID
                                                          context:self.rootSavingContext];
         assertThat(fetchedGroup, notNilValue());
         assertThat(fetchedGroup.images, hasCountOf([importObject[@"images"] count]));

         MSLogCreatedObjectsInContext(LOG_CONTEXT_FILE,
                                      @"image group created:\n%@", [fetchedGroup deepDescription]);

         for (NSDictionary * imageImportData in importObject[@"images"])
         {
             BOIconImage * image = (BOIconImage *)fetchedGroup[imageImportData[@"uuid"]];
             assertThat(image, notNilValue());
             assertThat(@(image.tag), is(imageImportData[@"tag"]));
             assertThat(image.fileName, is($(@"%@.%@",
                                             imageImportData[@"baseFileName"],
                                             imageImportData[@"fileNameExtension"])));
             assertThat(image.name, is(imageImportData[@"name"]));
         }

         MSLogCreatedObjectsInContext(LOG_CONTEXT_FILE,
                                      @"icon images created:\n%@",
                                      [[fetchedGroup.images valueForKeyPath:@"deepDescription"]
                                       componentsJoinedByString:@"\n"]);
     }];
}

- (void)testImportRERemoteController
{
    NSError * error = nil;
    NSDictionary * importObject = [parser_
                                   dictionaryByParsingContentsOfFile:JSONFilePath(@"RERemoteController")
                                                          error:&error];
    if (error) MSHandleErrors(error);
    assertThat(importObject, notNilValue());

    __block NSString * controllerUUID = nil;

    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         RemoteController * controller = [RemoteController MR_importFromObject:importObject
                                                                         inContext:context];
         assertThat(controller, notNilValue());

         controllerUUID = controller.uuid;
     }];

    [self.rootSavingContext performBlockAndWait:
     ^{
         RemoteController * controller = [RemoteController objectWithUUID:controllerUUID
                                                                    context:self.rootSavingContext];
         assertThat(controller, notNilValue());

         ButtonGroup * topToolbar = controller.topToolbar;
         assertThat(topToolbar, notNilValue());

         NSDictionary * toolbarImportData = importObject[@"topToolbar"];
         assertThat(topToolbar.uuid, is(toolbarImportData[@"uuid"]));
         assertThat(topToolbar.name, is(toolbarImportData[@"name"]));
         assertThat(topToolbar.backgroundColor,
                    is([UIColor colorWithName:toolbarImportData[@"backgroundColor"]]));
         assertThat(topToolbar.constraints,
                    hasCountOf([toolbarImportData[@"constraints"][@"format"] count]));
         assertThat(@(remoteElementTypeFromImportKey(toolbarImportData[@"type"])),
                    is(@(topToolbar.type)));
         assertThat(topToolbar.subelements, hasCountOf([toolbarImportData[@"subelements"] count]));

         NSDictionary * buttonIndex = [NSDictionary
                                       dictionaryWithObjects:toolbarImportData[@"subelements"]
                                                     forKeys:[toolbarImportData[@"subelements"]
                                                              valueForKeyPath:@"uuid"]];
         for (Button * button in topToolbar.subelements)
         {
             NSDictionary * buttonImportData = buttonIndex[button.uuid];
             assertThat(buttonImportData, notNilValue());
             assertThat(button.name, is(buttonImportData[@"name"]));
             assertThat(button.constraints,
                        hasCountOf([buttonImportData[@"constraints"][@"format"] count]));
             assertThat(@(remoteElementTypeFromImportKey(buttonImportData[@"type"])),
                        is(@(button.type)));

             NSString * commandUUID = buttonImportData[@"command"][@"uuid"];
             if (commandUUID) assertThat(button.command.uuid, is(commandUUID));

             if ([buttonImportData hasKey:@"icons"])
             {
                 //
             }

             if ([buttonImportData hasKey:@"backgroundColor"])
                 assertThat(button.backgroundColor,
                            is([UIColor colorWithName:buttonImportData[@"backgroundColor"]]));
         }
     }];
}

- (void)testImportREActivity
{
    NSError * error = nil;
    NSArray * importObject = [parser_ arrayByParsingContentsOfFile:JSONFilePath(@"REActivity") error:&error];
    if (error) MSHandleErrors(error);
    assertThat(importObject, notNilValue());

    __block NSArray * activityUUIDs = nil;
    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         NSArray * activities = [Activity MR_importFromArray:importObject inContext:context];
         assertThat(activities, hasCountOf([importObject count]));

         activityUUIDs = [activities valueForKeyPath:@"uuid"];
     }];

    [self.rootSavingContext performBlockAndWait:
     ^{
         NSMutableArray * fetchedActivities = [@[] mutableCopy];
         for (NSString * uuid in activityUUIDs)
         {
             NSDictionary * importData = [importObject objectPassingTest:
                                          ^BOOL(NSDictionary * obj, NSUInteger idx)
                                          {
                                              return [obj[@"uuid"] isEqualToString:uuid];
                                          }];
             assertThat(importData, notNilValue());

             Activity * activity = [Activity objectWithUUID:uuid context:self.rootSavingContext];
             assertThat(activity, notNilValue());
             assertThat(activity.name, is(importData[@"name"]));

             if ([importData hasKey:@"launchMacro"])
             {
                 REMacroCommand * launchMacro = activity.launchMacro;
                 assertThat(launchMacro, notNilValue());
                 assertThat(launchMacro, hasCountOf([importData[@"launchMacro"][@"commands"] count]));

                 NSArray * commands = importData[@"launchMacro"][@"commands"];
                 NSDictionary * commandDataIndex = [NSDictionary
                                                    dictionaryWithObjects:commands
                                                                  forKeys:[commands
                                                                           valueForKeyPath:@"uuid"]];
                 for (NSUInteger i = 0; i < commands.count; i++)
                 {
                     Command * command = launchMacro[i];

                     NSDictionary * commandData = commandDataIndex[command.uuid];
                     assertThat(commandData, notNilValue());

                     NSString * commandType = commandData[@"type"];
                     Class commandClass = classForCommandImportType(commandType);
                     assertThat(commandClass, notNilValue());

                     assertThat(command, isA(commandClass));
                     assertThat(command.uuid, is(commandData[@"uuid"]));

                     if ([@"ir" isEqualToString:commandType])
                     {
                         IRCode * code = ((RESendIRCommand *)command).code;
                         assertThat(code, notNilValue());

                         IRCode * fetchedCode = [IRCode objectWithUUID:commandData[@"code"][@"uuid"]
                                                                 context:self.rootSavingContext];
                         assertThat(fetchedCode, notNilValue());
                         assertThat(code, is(fetchedCode));
                         assertThat(code.uuid, is(fetchedCode.uuid));
                     }

                     else if ([@"power" isEqualToString:commandType])
                     {
                         ComponentDevice * device = ((REPowerCommand *)command).device;
                         assertThat(device, notNilValue());

                         ComponentDevice * fetchedDevice = [ComponentDevice
                                                              objectWithUUID:commandData[@"device"][@"uuid"]
                                                                   context:self.rootSavingContext];
                         assertThat(fetchedDevice, notNilValue());
                         assertThat(device, is(fetchedDevice));
                         assertThat(device.uuid, is(fetchedDevice.uuid)); //FIXME: This assertion fails
                     }

                     else if ([@"delay" isEqualToString:commandType])
                         assertThat(@(((REDelayCommand *)command).duration), is(commandData[@"duration"]));
                 }

             }

             if ([importData hasKey:@"haltMacro"])
             {
                 REMacroCommand * haltMacro = activity.haltMacro;
                 assertThat(haltMacro, notNilValue());
                 assertThat(haltMacro, hasCountOf([importData[@"haltMacro"][@"commands"] count]));

                 NSArray * commands = importData[@"haltMacro"][@"commands"];
                 NSDictionary * commandDataIndex = [NSDictionary
                                                    dictionaryWithObjects:commands
                                                                  forKeys:[commands
                                                                           valueForKeyPath:@"uuid"]];

                 for (NSUInteger i = 0; i < commands.count; i++)
                 {
                     Command * command = haltMacro[i];

                     NSDictionary * commandData = commandDataIndex[command.uuid];
                     assertThat(commandData, notNilValue());

                     NSString * commandType = commandData[@"type"];
                     Class commandClass = classForCommandImportType(commandType);
                     assertThat(commandClass, notNilValue());

                     assertThat(command, isA(commandClass));
                     assertThat(command.uuid, is(commandData[@"uuid"]));

                     if ([@"ir" isEqualToString:commandType])
                     {
                         IRCode * code = ((RESendIRCommand *)command).code;
                         assertThat(code, notNilValue());

                         IRCode * fetchedCode = [IRCode objectWithUUID:commandData[@"code"][@"uuid"]
                                                                 context:self.rootSavingContext];
                         assertThat(fetchedCode, notNilValue());
                         assertThat(code, is(fetchedCode));
                         assertThat(code.uuid, is(fetchedCode.uuid)); //FIXME: This assertion fails
                     }

                     else if ([@"power" isEqualToString:commandType])
                     {
                         ComponentDevice * device = ((REPowerCommand *)command).device;
                         assertThat(device, notNilValue());

                         ComponentDevice * fetchedDevice = [ComponentDevice
                                                              objectWithUUID:commandData[@"device"][@"uuid"]
                                                                   context:self.rootSavingContext];
                         assertThat(fetchedDevice, notNilValue());
                         assertThat(device, is(fetchedDevice));
                         assertThat(device.uuid, is(fetchedDevice.uuid)); //FIXME: This assertion fails
                     }

                     else if ([@"delay" isEqualToString:commandType])
                         assertThat(@(((REDelayCommand *)command).duration), is(commandData[@"duration"]));
                 }
             }

             [fetchedActivities addObject:activity];
         }

         MSLogCreatedObjectsInContext(LOG_CONTEXT_FILE,
                                      @"activities created:\n%@",
                                      [[fetchedActivities valueForKeyPath:@"deepDescription"]
                                       componentsJoinedByString:@"\n"]);

     }];
}

- (void)testExtendedJSONParser
{
    NSError * error = nil;
    id importObject = [parser_ objectByParsingContentsOfFile:JSONFilePath(@"ExtendedJSONTest") error:&error];
    if (error) MSHandleErrors(error);
    assertThat(importObject, notNilValue());
    MSLogCreatedObjectsInContext(LOG_CONTEXT_FILE, @"parsed import object:\n%@", importObject);
}

- (void)testImportHomeRERemote
{
    NSError * error = nil;
    NSDictionary * importObject = [parser_ dictionaryByParsingContentsOfFile:JSONFilePath(@"HomeRERemote")
                                                                  error:&error];
    if (error) MSHandleErrors(error);
    assertThat(importObject, notNilValue());

    __block NSString * homeRemoteUUID = nil;

    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         Remote * homeRemote = [Remote MR_importFromObject:importObject inContext:context];
         assertThat(homeRemote, notNilValue());

         homeRemoteUUID = homeRemote.uuid;
     }];

    [self.rootSavingContext performBlockAndWait:
     ^{
         Remote * homeRemote = [Remote objectWithUUID:homeRemoteUUID
                                                context:self.rootSavingContext];
         assertThat(homeRemote, notNilValue());
         assertThat(homeRemote.name, is(importObject[@"name"]));
         assertThat(homeRemote.backgroundImage.uuid, is(importObject[@"backgroundImage"][@"uuid"]));
         assertThat(homeRemote.constraints, hasCountOf([importObject[@"constraints"][@"format"] count]));
         assertThat(homeRemote.subelements, hasCountOf([importObject[@"subelements"] count]));

         NSMutableArray * elements = [@[homeRemote] mutableCopy];

         for (NSDictionary * buttonGroupData in importObject[@"subelements"])
         {
             ButtonGroup * buttonGroup =
             (ButtonGroup *)memberOfCollectionWithUUID(homeRemote.subelements, buttonGroupData[@"uuid"]);
             assertThat(buttonGroup, notNilValue());
             assertThat(buttonGroup.name, is(buttonGroupData[@"name"]));
             assertThat(buttonGroup.constraints,
                        hasCountOf([buttonGroupData[@"constraints"][@"format"] count]));
             assertThat(buttonGroup.subelements, hasCountOf([buttonGroupData[@"subelements"] count]));
             [elements addObject:buttonGroup];
             for (NSDictionary * buttonData in buttonGroupData[@"subelements"])
             {
                 Button * button = (Button *)memberOfCollectionWithUUID(buttonGroup.subelements,
                                                                            buttonData[@"uuid"]);
                 assertThat(button, notNilValue());
                 assertThat(button.name, is(buttonData[@"name"]));
                 assertThat(button.constraints, hasCountOf([buttonData[@"constraints"][@"format"] count]));
                 [elements addObject:button];
             }
         }

         MSLogCreatedObjectsInContext(LOG_CONTEXT_FILE,
                                      @"home remote elements created:\n%@",
                                      [[elements valueForKeyPath:@"deepDescription"]
                                       componentsJoinedByString:@"\n"]);
     }];
}

/// Overridden by subclasses to provide separate sqlite persistent store name.
+ (NSString *)storeName { return @"JSONImportDatabaseConstructionTests.sqlite"; }

/// Overridden to include persistent store
+ (MSCoreDataTestOptions)options { return ([super options] | MSCoreDataTestPersistentStore); }

+ (NSArray *)arrayOfInvocationSelectors
{
    return @[ NSValueWithPointer(@selector(testImportBOComponentDevice)),
              NSValueWithPointer(@selector(testImportBOBackgroundImage)),
              NSValueWithPointer(@selector(testImportBOIconImage)),
              NSValueWithPointer(@selector(testImportRERemoteController)),
              NSValueWithPointer(@selector(testImportREActivity)),
              NSValueWithPointer(@selector(testExtendedJSONParser)),
              NSValueWithPointer(@selector(testImportHomeRERemote))];
}

@end
