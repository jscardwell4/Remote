//
//  MagicalConstructDVRRemoteTests.m
//  Remote
//
//  Created by Jason Cardwell on 4/19/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MagicalConstructDVRRemoteTests.h"
#define CTX [MagicalConstructDVRRemoteTests defaultContext]
#import "RemoteConstruction.h"

#import "RERemoteController.h"
#import "RELayoutConfiguration.h"

static int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

@implementation MagicalConstructDVRRemoteTests

- (void)testCreateDVRRemote
{
    __block NSString * buttonGroupUUID;
    [MagicalRecord saveWithBlockAndWait:
     ^(NSManagedObjectContext *localContext)
     {
         // load devices and IR codes
         // Create devices
         NSString * testedUnitPath = [UserDefaults stringForKey:@"SenTestedUnitPath"];
         NSURL    * plistURL       = [NSURL fileURLWithPath:
                                      [testedUnitPath stringByAppendingPathComponent:@"UserCodes.plist"]];
         
         NSDictionary * codeBankPlist = [NSDictionary dictionaryWithContentsOfURL:plistURL];
         assertThat(codeBankPlist, notNilValue());
         
         @autoreleasepool
         {
             for (NSString * deviceName in [codeBankPlist allKeys])
             {
                 // Create codes for this device
                 BOComponentDevice * device = [BOComponentDevice bankObjectWithName:deviceName
                                                                            context:localContext];
                 
                 if 		 ([@"AV Receiver" isEqualToString:deviceName]) 	device.port = 2;
                 else if ([@"Dish Hopper" isEqualToString:deviceName]) 	device.port = 1;
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
                     }
                 }
             }
         }
         
         REButtonGroup * buttonGroup = [REButtonGroupBuilder
                                        constructDVRGroupOfThreeButtonsInContext:localContext];
         assertThat(buttonGroup, notNilValue());
         
         buttonGroupUUID = [buttonGroup.uuid copy];
         buttonGroup = nil;
     }];

    REButtonGroup * buttonGroup = [REButtonGroup objectWithUUID:buttonGroupUUID
                                                      inContext:self.defaultContext];
    assertThat(buttonGroup, notNilValue());
    MSLogInfoTag(@"group of three buttons:\n%@", [buttonGroup deepDescription]);

    // background image with tag: 8
    // component devices: Dish Hopper and Samsung TV
}

+ (NSArray *)arrayOfInvocationSelectors
{
    return @[ NSValueWithPointer(@selector(testCreateDVRRemote)) ];
}

@end
