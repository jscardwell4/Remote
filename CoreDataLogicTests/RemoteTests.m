//
//  RemoteTests.m
//  Remote
//
//  Created by Jason Cardwell on 4/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteTests.h"
#define CTX [RemoteTests defaultContext]
#import "RemoteConstruction.h"
#import "RELayoutConfiguration.h"

static const int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

@implementation RemoteTests

/**
 * Creates a new `RERemote` object, verifies various attributes, saves the context, resets the context,
 * fetches the remote created and verifies various attributes.
 */
- (void)testCreateRERemote
{
    RERemote * remote = [RERemote remoteElementInContext:self.defaultContext];

    assertThat(remote, notNilValue());

    NSString * displayName = @"RERemote for 'testCreateRERemote'";
    remote.displayName = displayName;

    assertThat(remote.displayName,           is(displayName));
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

    assertThat(error, nilValue());

    [self.defaultContext performBlockAndWait:^{ [self.defaultContext reset]; }];

    remote = [RERemote objectWithUUID:remoteUUID inContext:self.defaultContext];

    assertThat(remote,                            notNilValue()                );
    assertThat(remote.layoutConfiguration,        notNilValue()                );
    assertThat(remote.configurationDelegate,      notNilValue()                );
    assertThat(remote.layoutConfiguration.uuid,   is(layoutConfigurationUUID)  );
    assertThat(remote.configurationDelegate.uuid, is(configurationDelegateUUID));
}

+ (NSArray *)arrayOfInvocationSelectors
{
    return @[ NSValueWithPointer(@selector(testCreateRERemote)) ];
}

@end
