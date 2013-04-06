//
// IRCodeFunctions.m
// Remote
//
// Created by Jason Cardwell on 3/19/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "IRCodeFunctions.h"
#import "BankObject.h"
enum ProntoHexFormatParts {
    PatternType                 = 0,
    Frequency                   = 1,
    SequenceOneBurstPairCount   = 2,
    SequenceTwoBurstPairCount   = 3,
    LeadInBurstPairFirstNumber  = 4,
    LeadInBurstPairSecondNumber = 5,

};
struct   HexPair {
    unsigned int   num1;
    unsigned int   num2;
};
NSDictionary * getProntoHexFormatPartsFromString(NSString * prontoHex);
NSDictionary * getProntoHexFormatPartsFromString(NSString * prontoHex) {
    NSMutableDictionary * prontoParts = [NSMutableDictionary dictionary];

    // Create a scanner for extracting hex values
    NSScanner * hexScanner = [NSScanner scannerWithString:prontoHex];

    // Declare variables for holding Pronto Hex preamble (not the same as iTach preamble)
    unsigned int   patternTypeHex, frequencyHex, seq1BurstPairCountHex, seq2BurstPairCountHex;
    unsigned int   leadInBurstFirstHex, leadInBurstSecondHex;

    // Scan first six words into variables
    [hexScanner scanHexInt:&patternTypeHex];

    // Calculate frequency
    [hexScanner scanHexInt:&frequencyHex];

    NSUInteger   frequency = 1000000 / (frequencyHex * 0.241246);

    [prontoParts setValue:@(frequency) forKey:@"frequency"];

    // Pair counts
    [hexScanner scanHexInt:&seq1BurstPairCountHex];
    [hexScanner scanHexInt:&seq2BurstPairCountHex];

    // Lead in
    [hexScanner scanHexInt:&leadInBurstFirstHex];
    [hexScanner scanHexInt:&leadInBurstSecondHex];

    struct HexPair   leadin = {.num1 = leadInBurstFirstHex, .num2 = leadInBurstSecondHex};

    [prontoParts setValue:[NSValue   value:&leadin
                              withObjCType:@encode(struct HexPair)]
                   forKey:@"leadin"];

    // Declare arrays for holding number pairs
    NSMutableArray * preamblePairsArray   = [NSMutableArray array];
    NSMutableArray * repeatablePairsArray = [NSMutableArray array];

    // Capture burst pair sequence one, which serves as iTach preamble
    if (seq1BurstPairCountHex > 0)
        for (int i = 0; i < seq1BurstPairCountHex; i++) {
            // scan pairs and add to array
            struct HexPair   currentPair;

            if (  [hexScanner scanHexInt:&currentPair.num1]
               && [hexScanner scanHexInt:&currentPair.num2])
                [preamblePairsArray addObject:[NSValue   value:&currentPair
                                                  withObjCType:@encode(struct HexPair)]];
        }

    [prontoParts setValue:preamblePairsArray forKey:@"preamblePairs"];

    // Capture burst pair sequence two, which is the repeatable portion of iTach format
    if (seq2BurstPairCountHex > 0)
        for (int i = 0; i < seq2BurstPairCountHex; i++) {
            struct HexPair   currentPair;

            if (  [hexScanner scanHexInt:&currentPair.num1]
               && [hexScanner scanHexInt:&currentPair.num2])
                [repeatablePairsArray addObject:[NSValue   value:&currentPair
                                                    withObjCType:@encode(struct HexPair)]];
        }

    [prontoParts setValue:repeatablePairsArray forKey:@"repeatablePairs"];

    return prontoParts;
}  /* getProntoHexFormatPartsFromString */

IRCode * codeFromProntoHexInContext(NSString * prontoHex, NSManagedObjectContext * context) {
    IRCode * code =
        [NSEntityDescription insertNewObjectForEntityForName:@"IRCode"
                                      inManagedObjectContext:context];
    NSDictionary * prontoParts = getProntoHexFormatPartsFromString(prontoHex);

    return code;
}

NSString * iTachIRFormatWithRepeatOffsetIDFromProntoHex(NSUInteger repeat,
                                                        NSUInteger offset,
                                                        NSUInteger tag,
                                                        NSString * prontoHex) {
    ddLogLevel = LOG_LEVEL_OFF;

    // Create a scanner for extracting hex values
    NSScanner * hexScanner = [NSScanner scannerWithString:prontoHex];

    // Declare variables for holding Pronto Hex preamble (not the same as iTach preamble)
    unsigned int   patternTypeHex, frequencyHex, seq1BurstPairCountHex, seq2BurstPairCountHex;
    unsigned int   leadInBurstFirstHex, leadInBurstSecondHex;

    // Scan first six words into variables
    [hexScanner scanHexInt:&patternTypeHex];
    [hexScanner scanHexInt:&frequencyHex];
    [hexScanner scanHexInt:&seq1BurstPairCountHex];
    [hexScanner scanHexInt:&seq2BurstPairCountHex];
    [hexScanner scanHexInt:&leadInBurstFirstHex];
    [hexScanner scanHexInt:&leadInBurstSecondHex];

    // Calculate frequency
    NSUInteger   frequency = 1000000 / (frequencyHex * 0.241246);

    // Declare arrays for holding number pairs
    NSMutableArray * preamblePairsArray   = [NSMutableArray array];
    NSMutableArray * repeatablePairsArray = [NSMutableArray array];

    // Create bool for exiting loops
    BOOL   done = NO;

    // Capture burst pair sequence one, which serves as iTach preamble
    if (seq1BurstPairCountHex > 0)
        for (int i = 0; i < seq1BurstPairCountHex; i++) {
            // scan pairs and add to array
            struct HexPair   currentPair;

            if (  [hexScanner scanHexInt:&currentPair.num1]
               && [hexScanner scanHexInt:&currentPair.num2])
                [preamblePairsArray addObject:[NSValue   value:&currentPair
                                                  withObjCType:@encode(struct HexPair)]];
        }

    // Capture burst pair sequence two, which is the repeatable portion of iTach format
    if (seq2BurstPairCountHex > 0)
        for (int i = 0; i < seq2BurstPairCountHex; i++) {
            struct HexPair   currentPair;

            if (  [hexScanner scanHexInt:&currentPair.num1]
               && [hexScanner scanHexInt:&currentPair.num2])
                [repeatablePairsArray addObject:[NSValue   value:&currentPair
                                                    withObjCType:@encode(struct HexPair)]];
        }

    NSMutableString * iTachFormat =
        [NSMutableString stringWithFormat:@"sendir,<connectoraddress>,%u,%u,%u,%u",
         tag, frequency, repeat, offset];

    for (NSValue * hexPairValue in preamblePairsArray) {
        struct HexPair   currentPair;

        [hexPairValue getValue:&currentPair];
        [iTachFormat appendFormat:@",%u,%u", currentPair.num1, currentPair.num2];
    }

    for (NSValue * hexPairValue in repeatablePairsArray) {
        struct HexPair   currentPair;

        [hexPairValue getValue:&currentPair];
        [iTachFormat appendFormat:@",%u,%u", currentPair.num1, currentPair.num2];
    }

    [iTachFormat appendFormat:@"\r"];

    return iTachFormat;
}  /* iTachIRFormatWithRepeatOffsetIDFromProntoHex */

NSString * iTachIRFormatFromProntoHex(NSString * prontoHex) {
    return iTachIRFormatWithRepeatOffsetIDFromProntoHex(1, 1, 1, prontoHex);
}

