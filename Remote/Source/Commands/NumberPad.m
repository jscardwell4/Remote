#import "NumberPad.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

MSKIT_STRING_CONST          kDigitZeroButtonKey  = @"digit0";
MSKIT_STRING_CONST          kDigitOneButtonKey   = @"digit1";
MSKIT_STRING_CONST          kDigitTwoButtonKey   = @"digit2";
MSKIT_STRING_CONST          kDigitThreeButtonKey = @"digit3";
MSKIT_STRING_CONST          kDigitFourButtonKey  = @"digit4";
MSKIT_STRING_CONST          kDigitFiveButtonKey  = @"digit5";
MSKIT_STRING_CONST          kDigitSixButtonKey   = @"digit6";
MSKIT_STRING_CONST          kDigitSevenButtonKey = @"digit7";
MSKIT_STRING_CONST          kDigitEightButtonKey = @"digit8";
MSKIT_STRING_CONST          kDigitNineButtonKey  = @"digit9";
MSKIT_STRING_CONST          kAuxOneButtonKey     = @"aux1";
MSKIT_STRING_CONST          kAuxTwoButtonKey     = @"aux2";
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
