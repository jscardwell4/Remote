#import "NumberPad.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

NSString * const          kDigitZeroButtonKey  = @"digit0";
NSString * const          kDigitOneButtonKey   = @"digit1";
NSString * const          kDigitTwoButtonKey   = @"digit2";
NSString * const          kDigitThreeButtonKey = @"digit3";
NSString * const          kDigitFourButtonKey  = @"digit4";
NSString * const          kDigitFiveButtonKey  = @"digit5";
NSString * const          kDigitSixButtonKey   = @"digit6";
NSString * const          kDigitSevenButtonKey = @"digit7";
NSString * const          kDigitEightButtonKey = @"digit8";
NSString * const          kDigitNineButtonKey  = @"digit9";
NSString * const          kAuxOneButtonKey     = @"aux1";
NSString * const          kAuxTwoButtonKey     = @"aux2";
static NSArray          * keysByTag;
static const NSUInteger   kTagMax = 11;

@implementation NumberPad
@dynamic digit0;
@dynamic digit1;
@dynamic digit2;
@dynamic digit3;
@dynamic digit4;
@dynamic digit5;
@dynamic digit6;
@dynamic digit7;
@dynamic digit8;
@dynamic digit9;
@dynamic aux1;
@dynamic aux2;

/*
 * initialize
 */
+ (void)initialize {
    if (ValueIsNotNil(keysByTag)) return;

    keysByTag = @[kDigitZeroButtonKey, kDigitOneButtonKey, kDigitTwoButtonKey, kDigitThreeButtonKey, kDigitFourButtonKey, kDigitFiveButtonKey, kDigitSixButtonKey, kDigitSevenButtonKey, kDigitEightButtonKey, kDigitNineButtonKey, kAuxOneButtonKey, kAuxTwoButtonKey];
}

/*
 * newNumberPadInContext:
 */
+ (NumberPad *)newNumberPadInContext:(NSManagedObjectContext *)context {
    NumberPad * numberPad = [NSEntityDescription insertNewObjectForEntityForName:@"NumberPad" inManagedObjectContext:context];

    return numberPad;
}

/*
 * isValidKey:
 */
+ (BOOL)isValidKey:(NSString *)key {
    return [keysByTag containsObject:key];
}

@end
