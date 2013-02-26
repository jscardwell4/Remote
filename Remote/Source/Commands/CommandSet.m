//
// CommandSet.m
// iPhonto
//
// Created by Jason Cardwell on 6/9/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "CommandSet.h"
#import "Command.h"
#import "IRCode.h"

#import "ComponentDevice.h"
#import "ButtonGroup.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

static const NSUInteger   kTagMax = 0;
static NSArray * const    keysByTag;

@implementation CommandSet
@dynamic name;
@dynamic buttonGroup;

- (BOOL)validateForInsert:(NSError **)error {
    BOOL   propertiesValid = [super validateForInsert:error];

    // could stop here if invalid

    return propertiesValid;
}

- (BOOL)validateForUpdate:(NSError **)error {
    BOOL   propertiesValid = [super validateForUpdate:error];

    // could stop here if invalid

    return propertiesValid;
}

/*
 * setCommand:forKey:
 */
- (void)setCommand:(Command *)command forKey:(NSString *)key {
    // Test validity of parameters
    if (ValueIsNil(command)) return;

    if ([command.objectID isTemporaryID]) [command.managedObjectContext obtainPermanentIDsForObjects:@[command] error:nil];

    NSURL * commandURI = [command.objectID URIRepresentation];

    [self setValue:commandURI forKey:key];
}

/*
 * setCommand:forTag:
 */
- (void)setCommand:(Command *)command forTag:(NSUInteger)tag {
    if (tag > kTagMax) return;

    [self setCommand:command forKey:keysByTag[tag]];
}

/*
 * setCommandFromIRCode:forKey:
 */
- (void)setCommandFromIRCode:(IRCode *)irCode forKey:(NSString *)key {
    SendIRCommand * sendIR = [SendIRCommand sendIRCommandWithIRCode:irCode];

    [self setCommand:sendIR forKey:key];
}

/*
 * setCommandFromIRCode:forTag:
 */
- (void)setCommandFromIRCode:(IRCode *)irCode forTag:(NSUInteger)tag {
    if (tag > kTagMax) return;

    [self setCommandFromIRCode:irCode forKey:keysByTag[tag]];
}

/*
 * keyForTag:
 */
+ (NSString *)keyForTag:(NSUInteger)tag {
    if (ValueIsNil(keysByTag) || tag > kTagMax) return nil;
    else return keysByTag[tag];
}

/*
 * commandForTag:
 */
- (Command *)commandForTag:(NSUInteger)tag {
    if (tag > kTagMax) return nil;
    else return [self commandForKey:keysByTag[tag]];
}

/*
 * commandForKey:
 */
- (Command *)commandForKey:(NSString *)key {
    NSURL * commandURI = [self valueForKey:key];

    if (ValueIsNil(commandURI)) return nil;

    return [self commandForURI:commandURI];
}

/*
 * commandForURI:
 */
- (Command *)commandForURI:(NSURL *)commandURI {
    NSManagedObjectID * commandID = [[self.managedObjectContext persistentStoreCoordinator] managedObjectIDForURIRepresentation:commandURI];

    if (ValueIsNil(commandID)) return nil;

    return (Command *)[self.managedObjectContext objectWithID:commandID];
}

@end
