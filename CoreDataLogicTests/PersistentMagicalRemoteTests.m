//
//  PersistentMagicalRemoteTests.m
//  Remote
//
//  Created by Jason Cardwell on 4/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "PersistentMagicalRemoteTests.h"
#define CTX [PersistentMagicalRemoteTests defaultContext]
#import "RemoteConstruction.h"
#import "RELayoutConfiguration.h"

static const int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

@implementation PersistentMagicalRemoteTests

/**
 * Creates a new `RERemote` object, verifies various attributes, saves the context, resets the context,
 * fetches the remote created and verifies various attributes.
 */
- (void)testCreateRERemote
{
    __block NSString * remoteUUID, * layoutConfigurationUUID, * configurationDelegateUUID;
    
    [NSManagedObjectContext saveWithBlockAndWait:
     ^(NSManagedObjectContext * localContext)
     {
         RERemote * remote = [RERemote remoteElementInContext:localContext];

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

         remoteUUID                = [remote.uuid copy];
         layoutConfigurationUUID   = [remote.layoutConfiguration.uuid copy];
         configurationDelegateUUID = [remote.configurationDelegate.uuid copy];
         remote = nil;
     }];

    [NSManagedObjectContext MR_resetDefaultContext];

    RERemote * remote = [RERemote objectWithUUID:remoteUUID inContext:self.defaultContext];

    assertThat(remote,                            notNilValue()                );
    assertThat(remote.layoutConfiguration,        notNilValue()                );
    assertThat(remote.configurationDelegate,      notNilValue()                );
    assertThat(remote.layoutConfiguration.uuid,   is(layoutConfigurationUUID)  );
    assertThat(remote.configurationDelegate.uuid, is(configurationDelegateUUID));

    MSLogInfoTag(@"remote created:\n%@", [remote deepDescription]);
}

+ (MSCoreDataTestOptions)options { return [super options]|MSCoreDataTestPersistentStore; }

+ (NSArray *)arrayOfInvocationSelectors
{
    return @[ NSValueWithPointer(@selector(testCreateRERemote)) ];
}

@end
