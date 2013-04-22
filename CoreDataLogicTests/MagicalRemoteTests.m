//
//  MagicalRemoteTests.m
//  Remote
//
//  Created by Jason Cardwell on 4/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MagicalRemoteTests.h"
#define CTX [MagicalRemoteTests defaultContext]
#import "RemoteConstruction.h"
#import "RELayoutConfiguration.h"

static const int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

@implementation MagicalRemoteTests

/**
 * Creates a new `RERemote` object, verifies various attributes, saves the context, resets the context,
 * fetches the remote created and verifies various attributes.
 */
- (void)testCreateRERemote
{
    __block NSString * remoteUUID, * layoutConfigurationUUID, * configurationDelegateUUID;
    
    [MagicalRecord saveWithBlockAndWait:
     ^(NSManagedObjectContext *localContext)
     {
         RERemote * remote = [RERemote remoteElementInContext:localContext];

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

         remoteUUID                = [remote.uuid copy];
         layoutConfigurationUUID   = [remote.layoutConfiguration.uuid copy];
         configurationDelegateUUID = [remote.configurationDelegate.uuid copy];
         remote = nil;
     }];

    RERemote * remote = [RERemote objectWithUUID:remoteUUID inContext:self.defaultContext];

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
