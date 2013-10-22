//
//  ButtonTests.m
//  Remote
//
//  Created by Jason Cardwell on 4/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "ButtonTests.h"
#define CTX [ButtonTests defaultContext]
#import "RemoteConstruction.h"
#import "RELayoutConfiguration.h"

static int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

@implementation ButtonTests

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

    assertThat(error, nilValue());

    [self.defaultContext performBlockAndWait:^{ [self.defaultContext reset]; }];

    button = [REButton objectWithUUID:buttonUUID inContext:self.defaultContext];

    assertThat(button,                            notNilValue()                );
    assertThat(button.layoutConfiguration,        notNilValue()                );
    assertThat(button.configurationDelegate,      notNilValue()                );
    assertThat(button.layoutConfiguration.uuid,   is(layoutConfigurationUUID)  );
    assertThat(button.configurationDelegate.uuid, is(configurationDelegateUUID));
}

+ (NSArray *)arrayOfInvocationSelectors
{
    return @[ NSValueWithPointer(@selector(testCreateREButton)) ];
}

@end
