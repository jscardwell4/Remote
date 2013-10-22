//
//  RemoteControllerTests.m
//  Remote
//
//  Created by Jason Cardwell on 4/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteControllerTests.h"
#define CTX [RemoteControllerTests defaultContext]
#import "RemoteConstruction.h"

static int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

@implementation RemoteControllerTests

- (void)testCreateRERemoteController
{
    RERemoteController * controller = [RERemoteController MR_findFirstInContext:self.defaultContext];
    assertThat(controller, nilValue());

    controller = [RERemoteController remoteControllerInContext:self.defaultContext];

    assertThat(controller,                 notNilValue());
    assertThat(controller.remotes,         empty()      );
    assertThat(controller.homeRemote,      nilValue()   );
    assertThat(controller.currentRemote,   nilValue()   );
    assertThat(controller.currentActivity, nilValue()   );
    assertThat(controller.uuid,            notNilValue());

    NSString * uuid = [controller.uuid copy];
    controller = nil;

    __block NSError * error = nil;
    [self.defaultContext performBlockAndWait:^{ [self.defaultContext save:&error]; }];
    
    if (error) [MagicalRecord handleErrors:error];
    
    assertThat(error, nilValue());

    [self.defaultContext performBlockAndWait:^{ [self.defaultContext reset]; }];

    controller = [RERemoteController MR_findFirstInContext:self.defaultContext];
    
    assertThat(controller,      notNilValue());
    assertThat(controller.uuid, is(uuid)     );
}

+ (NSArray *)arrayOfInvocationSelectors
{
    return @[ NSValueWithPointer(@selector(testCreateRERemoteController)) ];
}

@end