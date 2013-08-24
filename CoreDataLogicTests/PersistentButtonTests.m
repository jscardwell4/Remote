//
//  PersistentButtonTests.m
//  Remote
//
//  Created by Jason Cardwell on 4/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "PersistentButtonTests.h"
#define CTX [PersistentButtonTests defaultContext]
#import "RemoteConstruction.h"
#import "RELayoutConfiguration.h"

static const int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

MSKIT_KEY_DEFINITION(PersistentButtonTestsButtonUUID);

@implementation PersistentButtonTests

- (void)testFetchExistingREButton
{
    NSString * buttonUUID = self[PersistentButtonTestsButtonUUIDKey];

    if (!buttonUUID)
    {
        MSLogInfoTag(@"no stored value for button uuid");
        return;
    }


    REButton * button = [REButton objectWithUUID:buttonUUID inContext:self.defaultContext];

    assertThat(button,                       notNilValue());
    assertThat(button.layoutConfiguration,   notNilValue());
    assertThat(button.configurationDelegate, notNilValue());
    assertThat(button.uuid,                  is(buttonUUID));


    MSLogInfoTag(@"stored button uuid: %@\nfetched button:\n%@", buttonUUID, [button deepDescription]);
}

- (void)testCreateREButton
{
    REButton * button = [REButton remoteElementInContext:self.defaultContext];

    assertThat(button, notNilValue());

    NSString * name = @"REButton for 'testCreateREButton'";
    button.name = name;

    assertThat(button.name,           is(name));
    assertThat(button.title,                 nilValue()     );
    assertThat(button.subelements,           empty()        );
    assertThat(button.constraints,           empty()        );
    assertThat(button.parentElement,         nilValue()     );
    assertThat(button.appliedTheme,          nilValue()     );
    assertThat(button.backgroundImage,       nilValue()     );
    assertThat(button.parentElement,         nilValue()     );
    assertThat(button.uuid,                  notNilValue()  );
    assertThat(button.layoutConfiguration,   notNilValue()  );
    assertThat(button.configurationDelegate, notNilValue()  );

    NSString * buttonUUID                = [button.uuid copy];
    NSString * layoutConfigurationUUID   = [button.layoutConfiguration.uuid copy];
    NSString * configurationDelegateUUID = [button.configurationDelegate.uuid copy];
    button = nil;


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

    button = [REButton objectWithUUID:buttonUUID inContext:self.defaultContext];

    assertThat(button,                            notNilValue()                );
    assertThat(button.layoutConfiguration,        notNilValue()                );
    assertThat(button.configurationDelegate,      notNilValue()                );
    assertThat(button.layoutConfiguration.uuid,   is(layoutConfigurationUUID)  );
    assertThat(button.configurationDelegate.uuid, is(configurationDelegateUUID));

    MSLogInfoTag(@"button created:\n%@", [button deepDescription]);
    self[PersistentButtonTestsButtonUUIDKey] = buttonUUID;
}

+ (MSCoreDataTestOptions)options
{
    return ([super options] | MSCoreDataTestPersistentStore | MSCoreDataTestBackgroundSavingContext);
}

+ (NSArray *)arrayOfInvocationSelectors
{
    return @[ NSValueWithPointer(@selector(testFetchExistingREButton)),
              NSValueWithPointer(@selector(testCreateREButton)) ];
}

@end
