//
//  ButtonGroupTests.m
//  Remote
//
//  Created by Jason Cardwell on 4/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "ButtonGroupTests.h"
#define CTX [ButtonGroupTests defaultContext]
#import "RemoteConstruction.h"
#import "RELayoutConfiguration.h"

static const int ddLogLevel   = LOG_LEVEL_UNITTEST;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel, msLogContext)

@implementation ButtonGroupTests

- (void)testCreateREButtonGroup
{
    REButtonGroup * buttonGroup = [REButtonGroup remoteElementInContext:self.defaultContext];

    assertThat(buttonGroup, notNilValue());

    NSString * name = @"REButtonGroup for 'testCreateREButtonGroup'";
    buttonGroup.name = name;

    assertThat(buttonGroup.name,                  is(name)                                 );
    assertThatUnsignedInteger(buttonGroup.panelLocation, equalToUnsignedInteger(REPanelLocationNotAPanel));
    assertThat(buttonGroup.subelements,                  empty()                                         );
    assertThat(buttonGroup.constraints,                  empty()                                         );
    assertThat(buttonGroup.parentElement,                nilValue()                                      );
    assertThat(buttonGroup.appliedTheme,                 nilValue()                                      );
    assertThat(buttonGroup.backgroundImage,              nilValue()                                      );
    assertThat(buttonGroup.parentElement,                nilValue()                                      );
    assertThat(buttonGroup.label,                        nilValue()                                      );
    assertThat(buttonGroup.uuid,                         notNilValue()                                   );
    assertThat(buttonGroup.layoutConfiguration,          notNilValue()                                   );
    assertThat(buttonGroup.configurationDelegate,        notNilValue()                                   );

    NSString * buttonGroupUUID           = [buttonGroup.uuid copy];
    NSString * layoutConfigurationUUID   = [buttonGroup.layoutConfiguration.uuid copy];
    NSString * configurationDelegateUUID = [buttonGroup.configurationDelegate.uuid copy];

    buttonGroup = nil;

    __block NSError * error = nil;
    [self.defaultContext performBlockAndWait:^{ [self.defaultContext save:&error]; }];

    if (error) [MagicalRecord handleErrors:error];

    assertThat(error, nilValue());

    [self.defaultContext performBlockAndWait:^{ [self.defaultContext reset]; }];

    buttonGroup = [REButtonGroup objectWithUUID:buttonGroupUUID inContext:self.defaultContext];

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
