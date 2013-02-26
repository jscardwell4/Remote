#import "Transport.h"

NSString * const          kTransportRewindButtonKey      = @"rewind";
NSString * const          kTransportRecordButtonKey      = @"record";
NSString * const          kTransportNextButtonKey        = @"next";
NSString * const          kTransportStopButtonKey        = @"stop";
NSString * const          kTransportFastForwardButtonKey = @"fastForward";
NSString * const          kTransportPreviousButtonKey    = @"previous";
NSString * const          kTransportPauseButtonKey       = @"pause";
NSString * const          kTransportPlayButtonKey        = @"play";
static NSArray          * keysByTag;
static const NSUInteger   kTagMax    = 7;
static int                ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation Transport
@dynamic rewind;
@dynamic record;
@dynamic next;
@dynamic stop;
@dynamic fastForward;
@dynamic previous;
@dynamic pause;
@dynamic play;

/*
 * initialize
 */
+ (void)initialize {
    if (ValueIsNotNil(keysByTag)) return;

    keysByTag = @[kTransportRewindButtonKey, kTransportRecordButtonKey, kTransportNextButtonKey, kTransportStopButtonKey, kTransportFastForwardButtonKey, kTransportPreviousButtonKey, kTransportPauseButtonKey, kTransportPlayButtonKey];
}

/*
 * isValidKey:
 */
+ (BOOL)isValidKey:(NSString *)key {
    return [keysByTag containsObject:key];
}

/*
 * newTransportInContext:
 */
+ (Transport *)newTransportInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:@"Transport" inManagedObjectContext:context];
}

@end
