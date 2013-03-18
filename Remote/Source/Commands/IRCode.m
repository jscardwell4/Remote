//
// IRCode.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "IRCode.h"
#import "ComponentDevice.h"
#import "IRCodeSet.h"
#import "IRCode_Private.h"

#pragma mark - Class extension

static int   ddLogLevel = DefaultDDLogLevel;

/*
 * @interface IRCode ()
 *
 * - (id)initWithProntoHex:(NSString *)hex;
 *
 * @end
 *
 */
#pragma mark - Enumerations, structs, and static variables

enum ProntoHexFormatParts {
    PatternType                 = 0,
    Frequency                   = 1,
    SequenceOneBurstPairCount   = 2,
    SequenceTwoBurstPairCount   = 3,
    LeadInBurstPairFirstNumber  = 4,
    LeadInBurstPairSecondNumber = 5,

};
struct                    HexPair {unsigned int   num1; unsigned int num2; };
MSKIT_STATIC_STRING_CONST   kIRCodeFrequencyKey       = @"frequency";
MSKIT_STATIC_STRING_CONST   kIRCodeOffsetKey          = @"offset";
MSKIT_STATIC_STRING_CONST   kIRCodePreamblePairsKey   = @"preamblePairs";
MSKIT_STATIC_STRING_CONST   kIRCodeRepeatablePairsKey = @"repeatablePairs";
MSKIT_STATIC_STRING_CONST   kIRCodeLeadInKey          = @"leadIn";

#pragma mark - Helper functions

// Helper function declarations
NSDictionary * getProntoHexFormatPartsFromString(NSString * prontoHex);

// Helper function definitions
NSDictionary * getProntoHexFormatPartsFromString(NSString * prontoHex) {
    NSMutableDictionary * prontoParts = [NSMutableDictionary dictionary];

    // Create a scanner for extracting hex values
    NSScanner * hexScanner = [NSScanner scannerWithString:prontoHex];

    // Declare variables for holding Pronto Hex preamble (not the same as iTach preamble)
    unsigned int   patternTypeHex, frequencyHex, seq1BurstPairCountHex, seq2BurstPairCountHex;
    unsigned int   leadInBurstFirstHex, leadInBurstSecondHex;

    // Scan first six words into variables
    [hexScanner scanHexInt:&patternTypeHex];
    if (patternTypeHex != 0) return nil;

    // Calculate frequency
    [hexScanner scanHexInt:&frequencyHex];

    NSUInteger   frequency = 1000000 / (frequencyHex * 0.241246);

    [prontoParts setValue:@(frequency)
                   forKey:kIRCodeFrequencyKey];

    // Pair counts
    [hexScanner scanHexInt:&seq1BurstPairCountHex];
    [hexScanner scanHexInt:&seq2BurstPairCountHex];

    // Lead in
    [hexScanner scanHexInt:&leadInBurstFirstHex];
    [hexScanner scanHexInt:&leadInBurstSecondHex];

    struct HexPair   leadin = {.num1 = leadInBurstFirstHex, .num2 = leadInBurstSecondHex};

    [prontoParts setValue:[NSValue   value:&leadin
                              withObjCType:@encode(struct HexPair)]
                   forKey:kIRCodeLeadInKey];

    // Capture burst pair sequence one, which serves as iTach preamble
    NSMutableArray * preamblePairsArray = [NSMutableArray array];

    if (seq1BurstPairCountHex > 0)
        for (int i = 0; i < seq1BurstPairCountHex; i++) {
            // scan pairs and add to array
            struct HexPair   currentPair;

            if (  [hexScanner scanHexInt:&currentPair.num1]
               && [hexScanner scanHexInt:&currentPair.num2])
                [preamblePairsArray addObject:[NSValue   value:&currentPair
                                                  withObjCType:@encode(struct HexPair)]];
        }

    if ([preamblePairsArray count] > 0) [prontoParts setValue:preamblePairsArray forKey:kIRCodePreamblePairsKey];

    // Capture burst pair sequence two, which is the repeatable portion of iTach format
    NSMutableArray * repeatablePairsArray = [NSMutableArray array];

    if (seq2BurstPairCountHex > 0)
        for (int i = 0; i < seq2BurstPairCountHex; i++) {
            struct HexPair   currentPair;

            if (  [hexScanner scanHexInt:&currentPair.num1]
               && [hexScanner scanHexInt:&currentPair.num2])
                [repeatablePairsArray addObject:[NSValue   value:&currentPair
                                                    withObjCType:@encode(struct HexPair)]];
        }

    if ([repeatablePairsArray count] > 0) [prontoParts setValue:repeatablePairsArray forKey:kIRCodeRepeatablePairsKey];

    return prontoParts;
}  /* getProntoHexFormatPartsFromString */

#pragma mark - Class implementation

@implementation IRCode
@dynamic frequency, offset, repeatCount, onOffPattern, name, device, sendCommands, setsDeviceInput,
/*codeSet,*/ alternateName, prontoHex;  // , userCode;

- (BOOL)validateForInsert:(NSError **)error {
    BOOL   propertiesValid = [super validateForInsert:error];

    // could stop here if invalid
    if (!propertiesValid)
        DDLogError(@"<IRCode> validation failed, error:%@, %@",
                   *error, [*error userInfo]);


    return propertiesValid;
}

- (BOOL)validateForUpdate:(NSError **)error {
    BOOL   propertiesValid = [super validateForUpdate:error];

    // could stop here if invalid
    if (!propertiesValid)
        DDLogError(@"<IRCode> validation failed, error:%@, %@",
                   *error, [*error userInfo]);


    return propertiesValid;
}

+ (IRCode *)newCodeForDevice:(ComponentDevice *)componentDevice {
    if (ValueIsNil(componentDevice)) return nil;

    IRCode * code = [NSEntityDescription insertNewObjectForEntityForName:@"IRCode"
                                                  inManagedObjectContext:componentDevice.managedObjectContext];

    code.device = componentDevice;

    return code;
}

/*
 + (IRCode *)newCodeInCodeSet:(IRCodeSet *)set {
 +      if (ValueIsNil(set)) return nil;
 +
 +      IRCode *code = [NSEntityDescription insertNewObjectForEntityForName:@"IRCode"
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +                                                 inManagedObjectContext:set.managedObjectContext];
 +      code.codeSet = set;
 +      return code;
 + }
 +
 */

/*
 + (IRCode *)newCodeFromProntoHex:(NSString *)hex inCodeSet:(IRCodeSet *)set {
 +      if (ValueIsNil(set)) return nil;
 +
 +      IRCode *code = [NSEntityDescription insertNewObjectForEntityForName:@"IRCode"
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +
 +                                                 inManagedObjectContext:set.managedObjectContext];
 +      code.codeSet = set;
 +      code = [code initWithProntoHex:hex];
 +
 +      return code;
 + }
 */

+ (IRCode *)newCodeFromProntoHex:(NSString *)hex forDevice:(ComponentDevice *)componentDevice {
    IRCode * code = [[self newCodeForDevice:componentDevice] initWithProntoHex:hex];

    return code;
}

- (id)initWithProntoHex:(NSString *)hex {
    if (ValueIsNotNil(self)) {
        self.prontoHex = hex;

        NSDictionary * prontoParts = getProntoHexFormatPartsFromString(hex);

        if (ValueIsNil(prontoParts)) {
            [self.managedObjectContext deleteObject:self];

            return nil;
        }

        // Set the code's frequency
        self.frequency = [prontoParts[kIRCodeFrequencyKey] unsignedIntegerValue];

        struct HexPair   leadInPair;

        [prontoParts[kIRCodeLeadInKey] getValue:&leadInPair];

        NSMutableString * pattern =
            [NSMutableString stringWithFormat:@"%u,%u", leadInPair.num1, leadInPair.num2];

        // Determine if there is a preamble
        NSArray * preamblePairs = prontoParts[kIRCodePreamblePairsKey];

        if (ValueIsNotNil(preamblePairs)) {
            //
        }

        // Add repeatable portion
        NSArray * repeatablePairs = prontoParts[kIRCodeRepeatablePairsKey];

        if (ValueIsNotNil(repeatablePairs))
            for (NSValue * hexPairValue in repeatablePairs) {
                struct HexPair   hexPair;

                [hexPairValue getValue:&hexPair];
                [pattern appendFormat:@",%u,%u", hexPair.num1, hexPair.num2];
            }

        self.onOffPattern = pattern;
    }

    return self;
}  /* initWithProntoHex */

- (NSString *)globalCacheFromProntoHex {
    if (ValueIsNil(self.prontoHex)) return nil;

    NSDictionary * prontoParts = getProntoHexFormatPartsFromString(self.prontoHex);

    if (ValueIsNil(prontoParts)) {
        [self.managedObjectContext deleteObject:self];

        return nil;
    }

    // Set the code's frequency
    self.frequency = [prontoParts[kIRCodeFrequencyKey] unsignedIntegerValue];

    struct HexPair   leadInPair = {0, 0};

    [prontoParts[kIRCodeLeadInKey] getValue:&leadInPair];

    NSMutableString * pattern =
        [NSMutableString stringWithFormat:@"%u,%u", leadInPair.num1, leadInPair.num2];

    // Determine if there is a preamble
    NSArray * preamblePairs = prontoParts[kIRCodePreamblePairsKey];

    if (ValueIsNotNil(preamblePairs)) {
        //
    }

    // Add repeatable portion
    NSArray * repeatablePairs = prontoParts[kIRCodeRepeatablePairsKey];

    if (ValueIsNotNil(repeatablePairs))
        for (NSValue * hexPairValue in repeatablePairs) {
            struct HexPair   hexPair;

            [hexPairValue getValue:&hexPair];
            [pattern appendFormat:@",%u,%u", hexPair.num1, hexPair.num2];
        }


    return pattern;
}

@end
