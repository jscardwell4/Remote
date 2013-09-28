//
//  DatabaseConstructionTests.m
//  DatabaseConstructionTests
//
//  Created by Jason Cardwell on 4/23/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "DatabaseConstructionTests.h"
#import "BankObject.h"

static const int   ddLogLevel    = LOG_LEVEL_UNITTEST;
static const int   msLogContext  = LOG_CONTEXT_UNITTEST;
static uint8_t     msTestOptions = 0;
#pragma unused(ddLogLevel, msLogContext, msTestOptions)


@implementation DatabaseConstructionTests

- (void)testLoadComponentDevices
{
    MSDictionary * componentDeviceNamePortsAssignments =
    [MSDictionary dictionaryWithDictionary:@{ @"AV Receiver" : @2,
                                              @"Dish Hopper" : @1,
                                              @"Samsung TV"  : @3,
                                              @"PS3"         : @3 }];

    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext *context)
     {
         NSString * devicePortPairsDescription = [componentDeviceNamePortsAssignments
                                                  formattedDescriptionWithOptions:0
                                                                      levelIndent:0];
         MSLogInfoInContextTag(LOG_CONTEXT_FILE,
                               @"device name-port pairs to be created:  %@",
                               [devicePortPairsDescription
                                stringByReplacingOccurrencesOfString:@"\n"
                                                          withString:$(@"\n%@",
                                                                       [NSString
                                                                        stringWithCharacter:' '
                                                                                      count:43])]);

         [componentDeviceNamePortsAssignments enumerateKeysAndObjectsUsingBlock:
          ^(NSString * deviceName, NSNumber * portNumber, BOOL *stop)
          {
              BOComponentDevice * device = [BOComponentDevice bankObjectWithName:deviceName
                                                                         context:context];
              assertThat(device, notNilValue());

              device.port = NSUIntegerValue(portNumber);
              assertThat(@(device.port), is(portNumber));
          }];
     }];

    [self.rootSavingContext performBlockAndWait:
     ^{
         for (NSString * deviceName in componentDeviceNamePortsAssignments)
         {
             BOComponentDevice * device = [BOComponentDevice
                                           fetchDeviceWithName:deviceName
                                                       context:self.rootSavingContext];
             assertThat(device, notNilValue());
         }
     }];
}

- (void)testLoadUserCodes
{

    NSString     * filePath      = [[UserDefaults stringForKey:@"SenTestedUnitPath"]
                                    stringByAppendingPathComponent:@"UserCodes.plist"];

    NSDictionary * codeBankPlist = [NSDictionary dictionaryWithContentsOfURL:
                                    [NSURL fileURLWithPath:filePath]];

    assertThat(codeBankPlist, notNilValue());

     MSDictionary * codeDirectory = [MSDictionary
                                     dictionaryWithObjects:@[@[@"Volume Down",
                                                               @"Volume Up",
                                                               @"DVD",
                                                               @"MD/Tape",
                                                               @"Mute",
                                                               @"Power",
                                                               @"TV/SAT",
                                                               @"Video 2",
                                                               @"Video 3"],
                                                             @[@"Channel Down",
                                                               @"Channel Up",
                                                               @"Down",
                                                               @"DVR",
                                                               @"Eight",
                                                               @"Exit",
                                                               @"Fast Forward",
                                                               @"Five",
                                                               @"Four",
                                                               @"Guide",
                                                               @"Info",
                                                               @"Last",
                                                               @"Left",
                                                               @"Menu",
                                                               @"Next",
                                                               @"Nine",
                                                               @"OK",
                                                               @"On Demand",
                                                               @"One",
                                                               @"Page Down",
                                                               @"Page Up",
                                                               @"Pause",
                                                               @"Play",
                                                               @"Prev",
                                                               @"Record",
                                                               @"Rewind",
                                                               @"Right",
                                                               @"Seven",
                                                               @"Six",
                                                               @"Stop",
                                                               @"Three",
                                                               @"Two",
                                                               @"Up",
                                                               @"Zero"],
                                                             @[@"Down",
                                                               @"Enter",
                                                               @"Exit",
                                                               @"Fast Forward",
                                                               @"HDMI 2",
                                                               @"HDMI 3",
                                                               @"HDMI 4",
                                                               @"Info",
                                                               @"Internet@TV",
                                                               @"Left",
                                                               @"Menu",
                                                               @"Pause",
                                                               @"Play",
                                                               @"Power Off",
                                                               @"Power On",
                                                               @"Record",
                                                               @"Return",
                                                               @"Rewind",
                                                               @"Right",
                                                               @"Source",
                                                               @"Tools",
                                                               @"Up"],
                                                             @[@"0",
                                                               @"1",
                                                               @"2",
                                                               @"3",
                                                               @"4",
                                                               @"5",
                                                               @"6",
                                                               @"7",
                                                               @"8",
                                                               @"9",
                                                               @"Discrete Off",
                                                               @"Discrete On",
                                                               @"Display",
                                                               @"Down",
                                                               @"Enter",
                                                               @"Left",
                                                               @"Next",
                                                               @"Pause",
                                                               @"Play",
                                                               @"Popup Menu",
                                                               @"Previous",
                                                               @"Right",
                                                               @"Scan Forward",
                                                               @"Scan Reverse",
                                                               @"Stop",
                                                               @"Top Menu",
                                                               @"Up"]]
                                                   forKeys:@[@"AV Receiver",
                                                             @"Dish Hopper",
                                                             @"Samsung TV",
                                                             @"PS3"]];
    

     NSString * codeDirectoryDescription = [codeDirectory formattedDescriptionWithOptions:0
                                                                              levelIndent:0];
     MSLogInfoInContextTag(LOG_CONTEXT_FILE,
                           @"codes by device to be created:  %@",
                           [codeDirectoryDescription
                            stringByReplacingOccurrencesOfString:@"\n"
                                                      withString:$(@"\n%@",
                                                                   [NSString
                                                                    stringWithCharacter:' '
                                                                                  count:36])]);

    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         NSArray * componentDevices = [BOComponentDevice MR_findAllInContext:context];
         assertThat(componentDevices, hasCountOf(4));

         NSArray * componentDeviceNames = [componentDevices valueForKeyPath:@"name"];
         assertThat(componentDeviceNames, hasCountOf(4));

         NSDictionary * deviceDirectory = [NSDictionary dictionaryWithObjects:componentDevices
                                                                      forKeys:componentDeviceNames];

         assertThat(deviceDirectory, HC_hasKey(@"AV Receiver"));
         assertThat(deviceDirectory, HC_hasKey(@"Dish Hopper"));
         assertThat(deviceDirectory, HC_hasKey(@"Samsung TV") );
         assertThat(deviceDirectory, HC_hasKey(@"PS3")        );

         [codeDirectory enumerateKeysAndObjectsUsingBlock:
          ^(NSString * deviceName, NSArray * codeNames, BOOL *stop)
          {
              NSDictionary * codes = [codeBankPlist[deviceName] dictionaryWithValuesForKeys:codeNames];
              assertThat(codes, hasCountOf([codeNames count]));
              [codes enumerateKeysAndObjectsUsingBlock:
               ^(NSString * codeName, NSDictionary * codeAttributes, BOOL *stop)
               {
                   BOUserIRCode * code = [BOUserIRCode codeForDevice:deviceDirectory[deviceName]];
                   code.name            = codeName;
                   code.frequency       = NSUIntegerValue(codeAttributes[@"Frequency"]);
                   code.repeatCount     = NSUIntegerValue(codeAttributes[@"Repeat Count"]);
                   code.offset          = NSUIntegerValue(codeAttributes[@"Offset"]);
                   code.onOffPattern    = codeAttributes[@"On-Off Pattern"];
                   code.setsDeviceInput = BOOLValue(codeAttributes[@"Input"]);
                   
                   assertThat(code,                    notNilValue()                        );
                   assertThat(@(code.frequency),       is(codeAttributes[@"Frequency"])     );
                   assertThat(@(code.repeatCount),     is(codeAttributes[@"Repeat Count"])  );
                   assertThat(@(code.offset),          is(codeAttributes[@"Offset"])        );
                   assertThat(code.onOffPattern,       is(codeAttributes[@"On-Off Pattern"]));
                   assertThat(@(code.setsDeviceInput), is(codeAttributes[@"Input"])         );
               }];
          }];
         
     }];

    [self.rootSavingContext performBlockAndWait:
     ^{
         [codeBankPlist enumerateKeysAndObjectsUsingBlock:
          ^(NSString * deviceName, NSDictionary *deviceCodes, BOOL *stop)
          {
              NSDictionary * filteredCodes = [deviceCodes
                                              dictionaryWithValuesForKeys:codeDirectory[deviceName]];
              [filteredCodes enumerateKeysAndObjectsUsingBlock:
               ^(NSString * codeName, NSDictionary * codeAttributes, BOOL *stop)
               {
                   BOUserIRCode * code = [BOUserIRCode MR_findFirstWithPredicate:
                                          [NSPredicate predicateWithFormat:
                                           @"(SELF.name == %@ ) && (SELF.device.name == %@)",
                                           codeName, deviceName]];
                   
                   assertThat(code,                    notNilValue()                        );
                   assertThat(@(code.frequency),       is(codeAttributes[@"Frequency"])     );
                   assertThat(@(code.repeatCount),     is(codeAttributes[@"Repeat Count"])  );
                   assertThat(@(code.offset),          is(codeAttributes[@"Offset"])        );
                   assertThat(code.onOffPattern,       is(codeAttributes[@"On-Off Pattern"]));
                   assertThat(@(code.setsDeviceInput), is(codeAttributes[@"Input"])         );
               }];
          }];

     }];
}

- (void)testLoadIconImages
{
    NSArray * fileNames = @[@"[140]house.png",
                            @"[155]minus.png",
                            @"[168]power.png",
                            @"[182]wifi.png",
                            @"[1]Lightbulb.png",
                            @"[224]palette.png",
                            @"[4000]LargerIcons_FastForward.png",
                            @"[4001]LargerIcons_Pause.png",
                            @"[4002]LargerIcons_Play.png",
                            @"[4003]LargerIcons_Record.png",
                            @"[4004]LargerIcons_Rewind.png",
                            @"[4005]LargerIcons_SkipBackward.png",
                            @"[4006]LargerIcons_SkipForward.png",
                            @"[4007]LargerIcons_Stop.png",
                            @"[40]plus.png",
                            @"[4]batteryChargingPlug.png",
                            @"[5]batteryFrame.png",
                            @"[6]batteryLightning.png",
                            @"[83]gear.png"];

    MSLogInfoInContextTag(LOG_CONTEXT_FILE,
                          @"file names for icons to be created:  %@",
                          [fileNames componentsJoinedByString:$(@"\n%@",
                                                                [NSString
                                                                 stringWithCharacter:' '
                                                                               count:41])]);
    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext *context)
     {
         for (NSString * fileName in fileNames)
         {
             NSString * filePath = [[UserDefaults stringForKey:@"SenTestedUnitPath"]
                                    stringByAppendingPathComponent:fileName];
             BOImage * iconImage = [BOImage imageWithFileName:filePath context:context];
             assertThat(iconImage, notNilValue());
         }
     }];

    [self.rootSavingContext performBlockAndWait:
     ^{
         for (NSString * fileName in fileNames)
         {
             NSInteger tag = NSIntegerValue([fileName
                                             stringByMatchingFirstOccurrenceOfRegEx:@"\\[([0-9]{1,4})\\]"
                                                                            capture:1]);
             BOImage * iconImage = [BOImage fetchImageWithTag:tag
                                                              context:self.rootSavingContext];
             assertThat(iconImage, notNilValue());
         }
     }];
}

- (void)testLoadBackgroundImages
{
    NSArray * fileNames = @[@"[8]Pro Leather.jpg"];

    MSLogInfoInContextTag(LOG_CONTEXT_FILE,
                          @"file names for backgrounds to be created:  %@",
                          [fileNames componentsJoinedByString:$(@"\n%@",
                                                                [NSString stringWithCharacter:' '
                                                                                        count:46])]);
    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * context)
     {
         for (NSString * fileName in fileNames)
         {
             NSString * filePath = [[UserDefaults stringForKey:@"SenTestedUnitPath"]
                                    stringByAppendingPathComponent:fileName];
             BOBackgroundImage * backgroundImage = [BOBackgroundImage imageWithFileName:filePath
                                                                                context:context];
             assertThat(backgroundImage, notNilValue());
         }
     }];
}

- (void)testDefaultContextHasObjects
{
    [self.defaultContext performBlockAndWait:
     ^{
         NSArray * allObjects = [MSModelObject MR_findAllInContext:self.defaultContext];
         assertThat(allObjects, isNot(empty()));

         NSArray * allObjectDescriptions = [allObjects valueForKeyPath:@"deepDescription"];
         MSLogInfoInContextTag(LOG_CONTEXT_FILE,
                               @"all model objects fetched in default context:\n%@",
                               [allObjectDescriptions componentsJoinedByString:@"\n"]);
     }];
}

- (void)testRootContextHasObjects
{
    [self.rootSavingContext performBlockAndWait:
     ^{
         NSArray * allObjects = [MSModelObject MR_findAllInContext:self.rootSavingContext];
         assertThat(allObjects, isNot(empty()));

         NSArray * allObjectDescriptions = [allObjects valueForKeyPath:@"deepDescription"];
         MSLogInfoInContextTag(LOG_CONTEXT_FILE,
                               @"all model objects fetched in root saving context:\n%@",
                               [allObjectDescriptions componentsJoinedByString:@"\n"]);
     }];
}

/// Overridden to include persistent store
+ (MSCoreDataTestOptions)options { return [super options]|MSCoreDataTestPersistentStore; }

+ (NSArray *)arrayOfInvocationSelectors
{
    return @[ NSValueWithPointer(@selector(testLoadComponentDevices)),
              NSValueWithPointer(@selector(testLoadUserCodes)),
              NSValueWithPointer(@selector(testLoadIconImages)),
              NSValueWithPointer(@selector(testLoadBackgroundImages)),
              NSValueWithPointer(@selector(testDefaultContextHasObjects)),
              NSValueWithPointer(@selector(testRootContextHasObjects))];
}


@end
