//
// BOIRCode.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "BOIRCode.h"
#import "BOComponentDevice.h"
#import "BankObjectGroup.h"

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

struct HexPair {unsigned int   num1; unsigned int num2; };

MSKIT_STATIC_STRING_CONST   BOIRCodeFrequencyKey       = @"frequency";
MSKIT_STATIC_STRING_CONST   BOIRCodeOffsetKey          = @"offset";
MSKIT_STATIC_STRING_CONST   BOIRCodePreamblePairsKey   = @"preamblePairs";
MSKIT_STATIC_STRING_CONST   BOIRCodeRepeatablePairsKey = @"repeatablePairs";
MSKIT_STATIC_STRING_CONST   BOIRCodeLeadInKey          = @"leadIn";

NSDictionary * getProntoHexFormatPartsFromString(NSString * prontoHex)
{
    NSMutableDictionary * prontoParts = [@{} mutableCopy];

    // Create a scanner for extracting hex values
    NSScanner * hexScanner = [NSScanner scannerWithString:prontoHex];

    // Declare variables for holding Pronto Hex preamble (not the same as iTach preamble)
    unsigned int patternTypeHex, frequencyHex, seq1BurstPairCountHex, seq2BurstPairCountHex;
    unsigned int leadInBurstFirstHex, leadInBurstSecondHex;

    // Scan first six words into variables
    [hexScanner scanHexInt:&patternTypeHex];
    if (patternTypeHex != 0) return nil;

    // Calculate frequency
    [hexScanner scanHexInt:&frequencyHex];
    prontoParts[BOIRCodeFrequencyKey] = @(1000000 / (frequencyHex * 0.241246));

    // Pair counts
    [hexScanner scanHexInt:&seq1BurstPairCountHex];
    [hexScanner scanHexInt:&seq2BurstPairCountHex];

    // Lead in
    [hexScanner scanHexInt:&leadInBurstFirstHex];
    [hexScanner scanHexInt:&leadInBurstSecondHex];

    struct HexPair leadin = {.num1 = leadInBurstFirstHex, .num2 = leadInBurstSecondHex};

    prontoParts[BOIRCodeLeadInKey] = [NSValue value:&leadin withObjCType:@encode(struct HexPair)];

    // Capture burst pair sequence one, which serves as iTach preamble
    NSMutableArray * preamblePairsArray = [@[] mutableCopy];

    if (seq1BurstPairCountHex > 0)
        for (int i = 0; i < seq1BurstPairCountHex; i++)
        {
            // scan pairs and add to array
            struct HexPair currentPair;

            if (  [hexScanner scanHexInt:&currentPair.num1]
               && [hexScanner scanHexInt:&currentPair.num2])
                [preamblePairsArray addObject:[NSValue value:&currentPair
                                                withObjCType:@encode(struct HexPair)]];
        }

    if ([preamblePairsArray count] > 0)
        prontoParts[BOIRCodePreamblePairsKey] = preamblePairsArray;

    // Capture burst pair sequence two, which is the repeatable portion of iTach format
    NSMutableArray * repeatablePairsArray = [@[] mutableCopy];

    if (seq2BurstPairCountHex > 0)
        for (int i = 0; i < seq2BurstPairCountHex; i++)
        {
            struct HexPair currentPair;

            if (  [hexScanner scanHexInt:&currentPair.num1]
               && [hexScanner scanHexInt:&currentPair.num2])
                [repeatablePairsArray addObject:[NSValue value:&currentPair
                                                  withObjCType:@encode(struct HexPair)]];
        }

    if ([repeatablePairsArray count] > 0)
        prontoParts[BOIRCodeRepeatablePairsKey] = repeatablePairsArray;

    return prontoParts;
}

@implementation BOIRCode

@dynamic frequency, offset, repeatCount, onOffPattern;
@dynamic device, setsDeviceInput, prontoHex;

+ (instancetype)codeForDevice:(BOComponentDevice *)device
{
    assert(device);
    __block BOIRCode * code = nil;
    [device.managedObjectContext performBlockAndWait:
     ^{
         code = [self bankObjectInContext:device.managedObjectContext];
         code.device = device;
     }];

    return code;
}

+ (instancetype)codeFromProntoHex:(NSString *)hex context:(NSManagedObjectContext *)context
{
    assert(context && hex);
    __block BOIRCode * code = nil;
    [context performBlockAndWait:
     ^{
         code = [[self bankObjectInContext:context] initWithProntoHex:hex];
     }];

    return code;
}

+ (instancetype)codeFromProntoHex:(NSString *)hex device:(BOComponentDevice *)device
{
    assert(device && hex);
    __block BOIRCode * code = nil;
    [device.managedObjectContext performBlockAndWait:
     ^{
         code = [[self codeForDevice:device] initWithProntoHex:hex];
     }];

    return code;
}

- (id)initWithProntoHex:(NSString *)hex
{
    if (self)
    {
        self.prontoHex = hex;

        NSDictionary * prontoParts = getProntoHexFormatPartsFromString(hex);

        if (ValueIsNil(prontoParts))
        {
            [self.managedObjectContext deleteObject:self];
            return nil;
        }

        // Set the code's frequency
        self.frequency = [prontoParts[BOIRCodeFrequencyKey] unsignedIntegerValue];

        struct HexPair   leadInPair;

        [prontoParts[BOIRCodeLeadInKey] getValue:&leadInPair];

        NSMutableString * pattern = [$(@"%u,%u", leadInPair.num1, leadInPair.num2) mutableCopy];

        // Determine if there is a preamble
        NSArray * preamblePairs = prontoParts[BOIRCodePreamblePairsKey];

        if (ValueIsNotNil(preamblePairs)) {
            //???: Why was this here?
        }

        // Add repeatable portion
        NSArray * repeatablePairs = prontoParts[BOIRCodeRepeatablePairsKey];

        if (ValueIsNotNil(repeatablePairs))
            for (NSValue * hexPairValue in repeatablePairs)
            {
                struct HexPair hexPair;
                [hexPairValue getValue:&hexPair];
                [pattern appendFormat:@",%u,%u", hexPair.num1, hexPair.num2];
            }

        self.onOffPattern = pattern;
    }

    return self;
}

- (NSString *)globalCacheFromProntoHex
{
    if (!self.prontoHex) return nil;

    NSDictionary * prontoParts = getProntoHexFormatPartsFromString(self.prontoHex);

    if (ValueIsNil(prontoParts)) return nil;

    // Set the code's frequency
    self.frequency = [prontoParts[BOIRCodeFrequencyKey] unsignedIntegerValue];

    struct HexPair   leadInPair = {0, 0};

    [prontoParts[BOIRCodeLeadInKey] getValue:&leadInPair];

    NSMutableString * pattern =
        [NSMutableString stringWithFormat:@"%u,%u", leadInPair.num1, leadInPair.num2];

    // Determine if there is a preamble
    NSArray * preamblePairs = prontoParts[BOIRCodePreamblePairsKey];

    if (ValueIsNotNil(preamblePairs)) {
        //
    }

    // Add repeatable portion
    NSArray * repeatablePairs = prontoParts[BOIRCodeRepeatablePairsKey];

    if (ValueIsNotNil(repeatablePairs))
        for (NSValue * hexPairValue in repeatablePairs) {
            struct HexPair   hexPair;

            [hexPairValue getValue:&hexPair];
            [pattern appendFormat:@",%u,%u", hexPair.num1, hexPair.num2];
        }


    return pattern;
}

- (MSDictionary *)deepDescriptionDictionary
{
    BOIRCode * code = [self faultedObject];
    assert(code);

    MSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"name"]            = code.name;
    dd[@"device"]          = $(@"'%@':%@", code.device.name, code.device.uuid);
    dd[@"setsDeviceInput"] = BOOLString(code.setsDeviceInput);
    dd[@"offset"]          = $(@"%i",code.offset);
    dd[@"repeatCount"]     = $(@"%i", code.repeatCount);
    dd[@"frequency"]       = $(@"%llu", code.frequency);
    dd[@"onOffPattern"]    = code.onOffPattern;
    return dd;
}

@end
