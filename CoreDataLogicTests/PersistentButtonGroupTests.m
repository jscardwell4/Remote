//
//  PersistentButtonGroupTests.m
//  Remote
//
//  Created by Jason Cardwell on 4/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "PersistentButtonGroupTests.h"
#define CTX [PersistentButtonGroupTests defaultContext]
#import "RemoteConstruction.h"
#import "RELayoutConfiguration.h"

static const int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

MSKIT_KEY_DEFINITION(PersistentButtonGroupTestsButtonGroupUUID);

@implementation PersistentButtonGroupTests

- (void)testFetchExistingREButtonGroup
{
    NSString * buttonGroupUUID = self[PersistentButtonGroupTestsButtonGroupUUIDKey];

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

- (void)testCreateREButtonGroup
{
    REButtonGroup * buttonGroup = [REButtonGroup remoteElementInContext:self.defaultContext];

    assertThat(buttonGroup, notNilValue());

    NSString * name = @"REButtonGroup for 'testCreateREButtonGroup'";
    buttonGroup.name = name;

    assertThat(buttonGroup.name,                  is(name)                                 );
    assertThatUnsignedInteger(buttonGroup.panelLocation, equalToUnsignedInteger(0));
    assertThat(buttonGroup.subelements,                  empty()                  );
    assertThat(buttonGroup.constraints,                  empty()                  );
    assertThat(buttonGroup.parentElement,                nilValue()               );
    assertThat(buttonGroup.appliedTheme,                 nilValue()               );
    assertThat(buttonGroup.backgroundImage,              nilValue()               );
    assertThat(buttonGroup.parentElement,                nilValue()               );
    assertThat(buttonGroup.label,                        nilValue()               );
    assertThat(buttonGroup.uuid,                         notNilValue()            );
    assertThat(buttonGroup.layoutConfiguration,          notNilValue()            );
    assertThat(buttonGroup.configurationDelegate,        notNilValue()            );

    NSString * buttonGroupUUID           = [buttonGroup.uuid copy];
    NSString * layoutConfigurationUUID   = [buttonGroup.layoutConfiguration.uuid copy];
    NSString * configurationDelegateUUID = [buttonGroup.configurationDelegate.uuid copy];

    buttonGroup = nil;

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

    [self.defaultContext performBlockAndWait:^{ [self.defaultContext reset]; }];

    buttonGroup = [REButtonGroup objectWithUUID:buttonGroupUUID inContext:self.defaultContext];

    assertThat(buttonGroup,                            notNilValue()                );
    assertThat(buttonGroup.layoutConfiguration,        notNilValue()                );
    assertThat(buttonGroup.configurationDelegate,      notNilValue()                );
    assertThat(buttonGroup.layoutConfiguration.uuid,   is(layoutConfigurationUUID)  );
    assertThat(buttonGroup.configurationDelegate.uuid, is(configurationDelegateUUID));

    MSLogInfoTag(@"button group created:\n%@", [buttonGroup deepDescription]);
    self[PersistentButtonGroupTestsButtonGroupUUIDKey] = buttonGroupUUID;
}

+ (MSCoreDataTestOptions)options
{
    return ([super options] | MSCoreDataTestPersistentStore | MSCoreDataTestBackgroundSavingContext);
}

+ (NSArray *)arrayOfInvocationSelectors
{
    return @[ NSValueWithPointer(@selector(testFetchExistingREButtonGroup)),
              NSValueWithPointer(@selector(testCreateREButtonGroup)) ];
}

@end
