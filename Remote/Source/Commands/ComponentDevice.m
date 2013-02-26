//
// ComponentDevice.m
// iPhonto
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "ComponentDevice.h"
#import "IRCode.h"
#import "Button.h"
#import "Command.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation ComponentDevice
@dynamic name, port, codes, power, inputPowersOn, alwaysOn, offCommand, onCommand;

@synthesize ignoreNextPowerCommand;

+ (ComponentDevice *)fetchComponentDeviceWithName:(NSString *)componentDeviceName
                                        inContext:(NSManagedObjectContext *)context {
    __block NSArray * fetchedObjects = nil;

    [context performBlockAndWait:^{
                 NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ComponentDevice"];

                 NSPredicate * predicate =
                 [NSPredicate predicateWithFormat:@"name == %@", componentDeviceName];
                 [fetchRequest setPredicate:predicate];

                 NSError * error = nil;
                 fetchedObjects = [context          executeFetchRequest:fetchRequest
                                                         error:&error];
             }

    ];

    return (fetchedObjects.count ?[fetchedObjects lastObject] : nil);
}

- (void)setPowerStateToState:(ComponentDevicePowerState)powerState
                      sender:(id <CommandDelegate> )sender {
    if (self.ignoreNextPowerCommand) {
        [sender commandDidComplete:nil success:YES];
        self.ignoreNextPowerCommand = NO;
    }

    if (powerState == ComponentDevicePowerOff)
        // turn off device
        [self.offCommand execute:sender];
    else
        // turn on device
        [self.onCommand execute:sender];
}

- (IRCode *)codeWithName:(NSString *)codeName {
    NSSet * passingCodes =
        [self.codes
         objectsPassingTest:^BOOL (id obj, BOOL * stop) {
        IRCode * testObj = (IRCode *)obj;
        if ([codeName isEqualToString:testObj.name]) {
            *stop = YES;

            return YES;
        } else
            return NO;
    }

        ];

    if (ValueIsNil(passingCodes)) return nil;
    else return [passingCodes anyObject];
}

- (void)commandDidComplete:(Command *)command success:(BOOL)success {
    if (command == self.offCommand) self.power = ComponentDevicePowerOff;
    else if (command == self.onCommand) self.power = ComponentDevicePowerOn;
    else if (  [command isKindOfClass:[SendIRCommand class]]
            && self.inputPowersOn
            && ((SendIRCommand *)command).code.device == self
            && ((SendIRCommand *)command).code.setsDeviceInput) self.power = ComponentDevicePowerOn;
}

@end
