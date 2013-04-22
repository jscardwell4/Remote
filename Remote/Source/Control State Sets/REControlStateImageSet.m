//
// ControlStateImageSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "REControlStateSet.h"
#import "BankObject.h"

static const int ddLogLevel   = LOG_LEVEL_WARN;
static const int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

@implementation REControlStateImageSet

/**
 * For some reason using `setValuesForKeysWithDictionary:`, as is done in the `REControlStateSet`
 * implementation of this method, calls `encodeWithCoder:` leading to a crash
 */
+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)context
                             withObjects:(NSDictionary *)objects
{
    assert(context);
    __block REControlStateImageSet * imageSet = nil;

    [context performBlockAndWait:
     ^{
         imageSet = [self controlStateSetInContext:context];
         [objects enumerateKeysAndObjectsUsingBlock:
          ^(id key, id obj, BOOL *stop)
          {
              imageSet[stateForProperty(key)] = obj;
          }];
     }];
    return imageSet;
}

- (UIImage *)UIImageForState:(NSUInteger)state { return self[state].image; }

- (BOImage *)objectAtIndexedSubscript:(NSUInteger)state
{
    id object = (validState(state) ? [super objectAtIndexedSubscript:state] : nil);

    if ([object isKindOfClass:[BOImage class]]) return (BOImage *)object;

    else if ([object isKindOfClass:[NSURL class]])
        return (BOImage *)[self.managedObjectContext objectForURI:object];

    else return nil;
}


- (void)setObject:(BOImage *)image atIndexedSubscript:(NSUInteger)state
{
    assert(image);
    [super setObject:[image permanentURI] atIndexedSubscript:state];
}
 

@end
