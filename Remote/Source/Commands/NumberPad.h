//
// NumberPad.h
// Remote
//
// Created by Jason Cardwell on 6/9/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "CommandSet.h"

MSKIT_EXTERN_STRING   kDigitZeroButtonKey;
MSKIT_EXTERN_STRING   kDigitOneButtonKey;
MSKIT_EXTERN_STRING   kDigitTwoButtonKey;
MSKIT_EXTERN_STRING   kDigitThreeButtonKey;
MSKIT_EXTERN_STRING   kDigitFourButtonKey;
MSKIT_EXTERN_STRING   kDigitFiveButtonKey;
MSKIT_EXTERN_STRING   kDigitSixButtonKey;
MSKIT_EXTERN_STRING   kDigitSevenButtonKey;
MSKIT_EXTERN_STRING   kDigitEightButtonKey;
MSKIT_EXTERN_STRING   kDigitNineButtonKey;
MSKIT_EXTERN_STRING   kAuxOneButtonKey;
MSKIT_EXTERN_STRING   kAuxTwoButtonKey;

@interface NumberPad : CommandSet {
    @private
}
+ (NumberPad *)newNumberPadInContext:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSURL * digit0;
@property (nonatomic, strong) NSURL * digit1;
@property (nonatomic, strong) NSURL * digit2;
@property (nonatomic, strong) NSURL * digit3;
@property (nonatomic, strong) NSURL * digit4;
@property (nonatomic, strong) NSURL * digit5;
@property (nonatomic, strong) NSURL * digit6;
@property (nonatomic, strong) NSURL * digit7;
@property (nonatomic, strong) NSURL * digit8;
@property (nonatomic, strong) NSURL * digit9;
@property (nonatomic, strong) NSURL * aux1;
@property (nonatomic, strong) NSURL * aux2;

@end
