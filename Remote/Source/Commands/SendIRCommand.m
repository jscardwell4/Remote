//
// SendIR.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "Command.h"
#import "Command_Private.h"
#import "IRCode.h"
#import "ComponentDevice.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

static NSInteger   commandID = 1;

@interface SendIRCommand ()

/**
 * Produces the next integer to be used in tagging commands sent through the `ConnectionManager`
 * using the class variable `commandID`.
 */
+ (NSInteger)nextCommandID;

/**
 * <ConnectionManagerResponse> method invoked by the `ConnectionManager` after it has sent the
 * command to the networked device and received feedback.
 * @param tag The integer assigned to the completed command.
 * @param success Whether the command was sent to the networked device successfully.
 */
- (void)commandWithTag:(NSUInteger)tag didCompleteWithStatus:(BOOL)success;

@property (nonatomic, strong, readwrite) NSString * commandString;

@end

@implementation SendIRCommand

@dynamic code, portOverride;
@synthesize commandString, notifyDevice;

- (void)awakeFromFetch {
    [super awakeFromFetch];
    self.notifyDevice = ([self primitiveValueForKey:@"onDevice"] || [self primitiveValueForKey:@"offDevice"]);
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.notifyDevice = ([self primitiveValueForKey:@"onDevice"] || [self primitiveValueForKey:@"offDevice"]);
}

+ (SendIRCommand *)sendIRCommandInContext:(NSManagedObjectContext *)context {
    return (SendIRCommand *)[super commandInContext:context];
}

/// @name ￼Tagging commands

+ (NSInteger)nextCommandID {
    if (commandID == 100) commandID = 1;

    return commandID++;
}

/// @name ￼Methods relating to the command's `IRCode` object

- (ComponentDevice *)device {
    return ValueIsNotNil(self.code) ? self.code.device : nil;
}

- (NSInteger)port {
    return (self.portOverride
            ? self.portOverride
            : (ValueIsNil(self.code) ? -1 : self.code.device.port));
}

- (NSString *)commandString {
    if (ValueIsNil(self.code)) return nil;

    self.commandString =
        [NSString stringWithFormat:
         @"sendir,1:%i,%i,%lld,%i,%i,%@\r",
         (self.portOverride ? self.portOverride : self.code.device.port),
         [SendIRCommand nextCommandID],
         self.code.frequency,
         self.code.repeatCount,
         self.code.offset,
         [self.code
          valueForKey:@"onOffPattern"]];

    return commandString;
}

/// @name ￼Creating a SendIRCommand

+ (SendIRCommand *)sendIRCommandWithIRCode:(IRCode *)code {
    SendIRCommand * sendIR =
        [NSEntityDescription insertNewObjectForEntityForName:@"SendIRCommand"
                                      inManagedObjectContext:code.managedObjectContext];

    sendIR.code = code;

    return sendIR;
}

/// @name ￼Executing commands

/**
 * Sends `sendCommand:ofType:toDeviceAtIndex:sender:` message to <ConnectionManager>. If `options`
 * includes the `CommandOptionsNotifyComponentDevice` flag, `notifyDevice` is set to `YES`.
 * @param sender Object to be notifed after execution completes.
 * @param options Options to apply when executing command.
 */
- (void)execute:(id <CommandDelegate> )sender {
    [super execute:sender];

    NSString * comString = self.commandString;

    if (ValueIsNil(comString)) return;

    [[ConnectionManager sharedConnectionManager] sendCommand:comString
                                                      ofType:IRConnectionCommandType
                                                    toDevice:0
                                                      sender:self];
}

- (void)commandWithTag:(NSUInteger)tag didCompleteWithStatus:(BOOL)success {
    [super commandDidComplete:self success:success];

    if (self.notifyDevice) [self.code.device commandDidComplete:self success:success];
}

@end
