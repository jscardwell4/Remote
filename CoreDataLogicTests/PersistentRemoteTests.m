//
//  PersistentRemoteTests.m
//  Remote
//
//  Created by Jason Cardwell on 4/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "PersistentRemoteTests.h"
#define CTX [PersistentRemoteTests defaultContext]
#import "RemoteConstruction.h"
#import "RELayoutConfiguration.h"

static const int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

MSKIT_KEY_DEFINITION(PersistentRemoteTestsRemoteUUID);

@implementation PersistentRemoteTests

- (void)testFetchExistingRERemote
{
    NSString * remoteUUID = self[PersistentRemoteTestsRemoteUUIDKey];

    if (!remoteUUID)
    {
        MSLogInfoTag(@"no stored value for remote uuid");
        return;
    }


    RERemote * remote = [RERemote objectWithUUID:remoteUUID inContext:self.defaultContext];

    assertThat(remote,                       notNilValue());
    assertThat(remote.layoutConfiguration,   notNilValue());
    assertThat(remote.configurationDelegate, notNilValue());
    assertThat(remote.uuid,                  is(remoteUUID));


    MSLogInfoTag(@"stored remote uuid: %@\nfetched remote:\n%@",
                 remoteUUID, [remote deepDescription]);

}

/**
 * Creates a new `RERemote` object, verifies various attributes, saves the context, resets the context,
 * fetches the remote created and verifies various attributes.
 */
- (void)testCreateRERemote
{
    RERemote * remote = [RERemote remoteElementInContext:self.defaultContext];

    assertThat(remote, notNilValue());

    NSString * name = @"RERemote for 'testCreateRERemote'";
    remote.name = name;

    assertThat(remote.name,           is(name));
    assertThat(remote.subelements,           empty()        );
    assertThat(remote.constraints,           empty()        );
    assertThat(remote.parentElement,         nilValue()     );
    assertThat(remote.appliedTheme,          nilValue()     );
    assertThat(remote.backgroundImage,       nilValue()     );
    assertThat(remote.parentElement,         nilValue()     );
    assertThat(remote.uuid,                  notNilValue()  );
    assertThat(remote.layoutConfiguration,   notNilValue()  );
    assertThat(remote.configurationDelegate, notNilValue()  );

    NSString * remoteUUID                = [remote.uuid copy];
    NSString * layoutConfigurationUUID   = [remote.layoutConfiguration.uuid copy];
    NSString * configurationDelegateUUID = [remote.configurationDelegate.uuid copy];
    remote = nil;

    __block NSError * error = nil;
    [self.defaultContext performBlockAndWait:^{ [self.defaultContext save:&error]; }];
    
    if (error) [MagicalRecord handleErrors:error];

    else if (self.rootSavingContext)
        [self.rootSavingContext performBlockAndWait:
         ^{
             [self.rootSavingContext save:&error];
         }];

    if (error) [MagicalRecord handleErrors:error];

    [self.defaultContext performBlockAndWait:^{ [self.defaultContext reset]; }];

    remote = [RERemote objectWithUUID:remoteUUID inContext:self.defaultContext];

    assertThat(remote,                            notNilValue()                );
    assertThat(remote.layoutConfiguration,        notNilValue()                );
    assertThat(remote.configurationDelegate,      notNilValue()                );
    assertThat(remote.layoutConfiguration.uuid,   is(layoutConfigurationUUID)  );
    assertThat(remote.configurationDelegate.uuid, is(configurationDelegateUUID));

    MSLogInfoTag(@"remote created:\n%@", [remote deepDescription]);
    self[PersistentRemoteTestsRemoteUUIDKey] = remoteUUID;
}

+ (MSCoreDataTestOptions)options
{
    return ([super options] | MSCoreDataTestPersistentStore | MSCoreDataTestBackgroundSavingContext);
}

+ (NSArray *)arrayOfInvocationSelectors
{
    return @[ NSValueWithPointer(@selector(testFetchExistingRERemote)),
              NSValueWithPointer(@selector(testCreateRERemote)) ];
}

@end
