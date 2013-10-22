//
//  MagicalButtonTests.m
//  Remote
//
//  Created by Jason Cardwell on 4/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MagicalButtonTests.h"
#define CTX [MagicalButtonTests defaultContext]
#import "RemoteConstruction.h"
#import "RELayoutConfiguration.h"

static int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

@implementation MagicalButtonTests

- (void)testCreateREButton
{
    __block NSString * buttonUUID, * layoutConfigurationUUID, * configurationDelegateUUID;

    [MagicalRecord saveWithBlockAndWait:
     ^(NSManagedObjectContext *localContext)
     {
         REButton * button = [REButton remoteElementInContext:localContext];

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
         
         buttonUUID                = [button.uuid                       copy];
         layoutConfigurationUUID   = [button.layoutConfiguration.uuid   copy];
         configurationDelegateUUID = [button.configurationDelegate.uuid copy];
         button = nil;
     }];

    REButton * button = [REButton objectWithUUID:buttonUUID inContext:self.defaultContext];

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