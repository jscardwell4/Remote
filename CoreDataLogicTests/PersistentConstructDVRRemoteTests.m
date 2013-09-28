//
//  PersistentConstructDVRRemoteTests.m
//  Remote
//
//  Created by Jason Cardwell on 4/19/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "PersistentConstructDVRRemoteTests.h"
#define CTX [PersistentConstructDVRRemoteTests defaultContext]
#import "RemoteConstruction.h"

#import "RERemoteController.h"
#import "RELayoutConfiguration.h"

static const int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

MSKEY_DEFINITION(PersistentConstructDVRRemoteTestsButtonGroupUUID);

@implementation PersistentConstructDVRRemoteTests

- (void)testFetchExistingREButtonGroup
{
    NSString * buttonGroupUUID = self[PersistentConstructDVRRemoteTestsButtonGroupUUIDKey];

    if (!buttonGroupUUID)
    {
        MSLogInfoTag(@"no stored value for button group uuid");
        return;
    }


    REButtonGroup * buttonGroup = [REButtonGroup objectWithUUID:buttonGroupUUID inContext:self.defaultContext];

    assertThat(buttonGroup,                       notNilValue());
    assertThat(buttonGroup.layoutConfiguration,   notNilValue());
    assertThat(buttonGroup.configurationDelegate, notNilValue());
    assertThat(buttonGroup.uuid,                  is(buttonGroupUUID));


    MSLogInfoTag(@"stored button group uuid: %@\nfetched button group:\n%@",
                 buttonGroupUUID, [buttonGroup deepDescription]);
    
}

- (void)testCreateDVRRemote
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
                                                                       context:self.defaultContext];

            if 		([@"AV Receiver" isEqualToString:deviceName]) 	device.port = 2;
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
                                   constructDVRGroupOfThreeButtonsInContext:self.defaultContext];
    assertThat(buttonGroup, notNilValue());

    __block NSError * error = nil;
    [self.defaultContext performBlockAndWait:^{ [self.defaultContext save:&error]; }];

    if (error) [MagicalRecord handleErrors:error];

    else if (self.rootSavingContext)
        [self.rootSavingContext performBlockAndWait:
         ^{
             [self.rootSavingContext save:&error];
         }];

    if (error) [MagicalRecord handleErrors:error];

    assertThat(error, nilValue());


    self[PersistentConstructDVRRemoteTestsButtonGroupUUIDKey] = buttonGroup.uuid;
    MSLogInfoTag(@"group of three buttons:\n%@", [buttonGroup deepDescription]);

    // background image with tag: 8
    // component devices: Dish Hopper and Samsung TV
}

+ (MSCoreDataTestOptions)options
{
    return ([super options] | MSCoreDataTestPersistentStore | MSCoreDataTestBackgroundSavingContext);
}

+ (NSArray *)arrayOfInvocationSelectors
{
    return @[ NSValueWithPointer(@selector(testFetchExistingREButtonGroup)),
              NSValueWithPointer(@selector(testCreateDVRRemote)) ];
}

@end
