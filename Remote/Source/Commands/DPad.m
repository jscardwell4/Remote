#import "DPad.h"

#define kDPadTagMax 4

NSString   * kDPadUpButtonKey    = @"up";
NSString   * kDPadDownButtonKey  = @"down";
NSString   * kDPadLeftButtonKey  = @"left";
NSString   * kDPadRightButtonKey = @"right";
NSString   * kDPadOkButtonKey    = @"ok";
static int   ddLogLevel          = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

static NSArray          * keysByTag;
static const NSUInteger   kTagMax = 4;

@implementation DPad
@dynamic up;
@dynamic left;
@dynamic right;
@dynamic ok;
@dynamic down;
@dynamic buttonGroups;

/*
 * initialize
 */
+ (void)initialize {
    if (ValueIsNotNil(keysByTag)) return;

    keysByTag = @[kDPadUpButtonKey, kDPadDownButtonKey, kDPadLeftButtonKey, kDPadRightButtonKey, kDPadOkButtonKey];
}

/*
 * isValidKey:
 */
+ (BOOL)isValidKey:(NSString *)key {
    return [keysByTag containsObject:key];
}

/*
 * newDPadInContext:
 */
+ (DPad *)newDPadInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:@"DPad" inManagedObjectContext:context];
}

@end
