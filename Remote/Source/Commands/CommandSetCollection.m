//
// CommandSetCollection.m
// Remote
//
// Created by Jason Cardwell on 6/29/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "CommandSetCollection.h"
#import "CommandSet.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation CommandSetCollection
@dynamic commandSets;

/*
 * newCommandSetCollectionInContext:
 */
+ (CommandSetCollection *)newCommandSetCollectionInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:@"CommandSetCollection" inManagedObjectContext:context];
}

/*
 * isValidKey:
 */
- (BOOL)isValidKey:(NSString *)key {
    NSArray * validKeys = [self.commandSets allKeys];

    if (ValueIsNil(key) || ValueIsNil(validKeys)) return NO;
    else return [validKeys containsObject:key];
}

/*
 * addCommandSet:
 */
- (void)addCommandSet:(CommandSet *)commandSet {
    if (ValueIsNil(commandSet) || ValueIsNil(commandSet.name)) return;

    if ([commandSet.objectID isTemporaryID]) [commandSet.managedObjectContext obtainPermanentIDsForObjects:@[commandSet] error:nil];

    NSURL * commandSetURI = [commandSet.objectID URIRepresentation];

    [self.commandSets setObject:commandSetURI forKey:commandSet.name];
}

@end
