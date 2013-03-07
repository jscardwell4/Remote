#import "RockerButton.h"

MSKIT_STRING_CONST          kRockerButtonPlusButtonKey  = @"plus";
MSKIT_STRING_CONST          kRockerButtonMinusButtonKey = @"minus";
static NSArray          * keysByTag;
static const NSUInteger   kTagMax    = 1;
static int                ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation RockerButton
@dynamic plus;
@dynamic minus;

/*
 * initialize
 */
+ (void)initialize {
    if (ValueIsNotNil(keysByTag)) return;

    keysByTag = @[kRockerButtonPlusButtonKey, kRockerButtonMinusButtonKey];
}

/*
 * isValidKey:
 */
+ (BOOL)isValidKey:(NSString *)key {
    return [keysByTag containsObject:key];
}

/*
 * newRockerButtonInContext:
 */
+ (RockerButton *)newRockerButtonInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:@"RockerButton" inManagedObjectContext:context];
}

@end
