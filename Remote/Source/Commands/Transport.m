#import "Transport.h"

MSKIT_STRING_CONST          kTransportRewindButtonKey      = @"rewind";
MSKIT_STRING_CONST          kTransportRecordButtonKey      = @"record";
MSKIT_STRING_CONST          kTransportNextButtonKey        = @"next";
MSKIT_STRING_CONST          kTransportStopButtonKey        = @"stop";
MSKIT_STRING_CONST          kTransportFastForwardButtonKey = @"fastForward";
MSKIT_STRING_CONST          kTransportPreviousButtonKey    = @"previous";
MSKIT_STRING_CONST          kTransportPauseButtonKey       = @"pause";
MSKIT_STRING_CONST          kTransportPlayButtonKey        = @"play";
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
