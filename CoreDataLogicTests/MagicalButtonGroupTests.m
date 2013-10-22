//
//  MagicalButtonGroupTests.m
//  Remote
//
//  Created by Jason Cardwell on 4/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MagicalButtonGroupTests.h"
#define CTX [MagicalButtonGroupTests defaultContext]
#import "RemoteConstruction.h"
#import "RELayoutConfiguration.h"

static int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

@implementation MagicalButtonGroupTests

- (void)testCreateREButtonGroup
{
    __block NSString * buttonGroupUUID, * layoutConfigurationUUID, * configurationDelegateUUID;

    [MagicalRecord saveWithBlockAndWait:
     ^(NSManagedObjectContext *localContext)
     {

         REButtonGroup * buttonGroup = [REButtonGroup remoteElementInContext:localContext];
         
         assertThat(buttonGroup, notNilValue());
         
         NSString * name = @"REButtonGroup for 'testCreateREButtonGroup'";
         buttonGroup.name = name;
         
         assertThat(buttonGroup.name,                  is(name)          );
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
         
         buttonGroupUUID           = [buttonGroup.uuid                       copy];
         layoutConfigurationUUID   = [buttonGroup.layoutConfiguration.uuid   copy];
         configurationDelegateUUID = [buttonGroup.configurationDelegate.uuid copy];
         buttonGroup = nil;
     }];

    REButtonGroup * buttonGroup = [REButtonGroup objectWithUUID:buttonGroupUUID
                                                      inContext:self.defaultContext];

    assertThat(buttonGroup,                            notNilValue()                );
    assertThat(buttonGroup.layoutConfiguration,        notNilValue()                );
    assertThat(buttonGroup.configurationDelegate,      notNilValue()                );
    assertThat(buttonGroup.layoutConfiguration.uuid,   is(layoutConfigurationUUID)  );
    assertThat(buttonGroup.configurationDelegate.uuid, is(configurationDelegateUUID));
}

+ (NSArray *)arrayOfInvocationSelectors
{
    return @[ NSValueWithPointer(@selector(testCreateREButtonGroup)) ];
}

@end