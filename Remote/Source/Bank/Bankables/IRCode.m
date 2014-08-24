//
// IRCode.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "IRCode.h"
#import "ComponentDevice.h"
#import "BankGroup.h"
#import "Manufacturer.h"


enum ProntoHexFormatParts {
    PatternType                 = 0,
    Frequency                   = 1,
    SequenceOneBurstPairCount   = 2,
    SequenceTwoBurstPairCount   = 3,
    LeadInBurstPairFirstNumber  = 4,
    LeadInBurstPairSecondNumber = 5,

};

struct HexPair {unsigned int   num1; unsigned int num2; };

MSSTATIC_STRING_CONST   IRCodeFrequencyKey       = @"frequency";
MSSTATIC_STRING_CONST   IRCodeOffsetKey          = @"offset";
MSSTATIC_STRING_CONST   IRCodePreamblePairsKey   = @"preamblePairs";
MSSTATIC_STRING_CONST   IRCodeRepeatablePairsKey = @"repeatablePairs";
MSSTATIC_STRING_CONST   IRCodeLeadInKey          = @"leadIn";

NSDictionary * parseIRCodeFromProntoHex(NSString * prontoHex)
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
    prontoParts[IRCodeFrequencyKey] = @(1000000 / (frequencyHex * 0.241246));

    // Pair counts
    [hexScanner scanHexInt:&seq1BurstPairCountHex];
    [hexScanner scanHexInt:&seq2BurstPairCountHex];

    // Lead in
    [hexScanner scanHexInt:&leadInBurstFirstHex];
    [hexScanner scanHexInt:&leadInBurstSecondHex];

    struct HexPair leadin = {.num1 = leadInBurstFirstHex, .num2 = leadInBurstSecondHex};

    prontoParts[IRCodeLeadInKey] = [NSValue value:&leadin withObjCType:@encode(struct HexPair)];

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
        prontoParts[IRCodePreamblePairsKey] = preamblePairsArray;

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
        prontoParts[IRCodeRepeatablePairsKey] = repeatablePairsArray;

    return prontoParts;
}

@implementation IRCode

@dynamic frequency, offset, repeatCount, onOffPattern;
@dynamic device, setsDeviceInput, prontoHex, manufacturer, codeset;


- (void)setProntoHex:(NSString *)prontoHex
{
    [self willChangeValueForKey:@"prontoHex"];
    [self setPrimitiveValue:prontoHex forKey:@"prontoHex"];
    [self didChangeValueForKey:@"prontoHex"];

    if (prontoHex)
    {
        NSDictionary * d = parseIRCodeFromProntoHex(prontoHex);
        self.frequency = d[IRCodeFrequencyKey];
        struct HexPair hexpair;
        [d[IRCodeLeadInKey] getValue:&hexpair];
        NSMutableString * pattern = [$(@"%u,%u", hexpair.num1, hexpair.num2) mutableCopy];
        //???: why wasn't the preamble used?
        for (NSValue * hexPairValue in d[IRCodeRepeatablePairsKey])
        {
            [hexPairValue getValue:&hexpair];
            [pattern appendFormat:@",%u,%u,", hexpair.num1, hexpair.num2];
        }
        self.onOffPattern = pattern;
    }
}

- (void)updateCategory
{
    NSString * manufacturerName = (self.manufacturer.name
                                   ? $(@"(%@) ", self.manufacturer.name)
                                   : @"");
    NSString * codesetName = (self.codeset ?: @"-");
    NSString * deviceName = (self.device.name ? $(@" [%@]", self.device.name) : @"");
    self.info.category = [@"" join:@[manufacturerName, codesetName, deviceName]];
}

- (void)setDevice:(ComponentDevice *)device
{
    [self willChangeValueForKey:@"device"];
    [self setPrimitiveValue:device forKey:@"device"];
    [self didChangeValueForKey:@"device"];

    self.manufacturer = device.manufacturer;
    self.codeset = nil;
}

- (void)setCodeset:(NSString *)codeset
{
    [self willChangeValueForKey:@"codeset"];
    [self setPrimitiveValue:codeset forKey:@"codeset"];
    [self didChangeValueForKey:@"codeset"];

    [self updateCategory];
}

- (void)setManufacturer:(Manufacturer *)manufacturer
{
    [self willChangeValueForKey:@"manufacturer"];
    [self setPrimitiveValue:manufacturer forKey:@"manufacturer"];
    [self didChangeValueForKey:@"manufacturer"];

    [self updateCategory];
}

- (void)updateWithData:(NSDictionary *)data {
    /*
         {
            "uuid": "AE33A7C2-3C7A-4BAE-B87A-E29D060B6436",
            "info": {
                "name": "Subtitle",
                "category": "(LG) 0828"
            },
            "codeset": "0828",
            "frequency": 39105,
            "onOffPattern": "344,176,22,3691,"
        }
     */

    [super updateWithData:data];

    self.info.name     = data[@"info"][@"name"]      ?: self.info.name    ;
    self.info.category = data[@"info"][@"category"]  ?: self.info.category;
    self.codeset       = data[@"codeset"]            ?: self.codeset      ;
    self.frequency     = data[@"frequency"]          ?: self.frequency    ;
    self.onOffPattern  = data[@"onOffPattern"]       ?: self.onOffPattern ;

}

- (MSDictionary *)JSONDictionary
{
    id(^defaultForKey)(NSString *) = ^(NSString * key)
    {
        static const NSDictionary * index;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken,
                      ^{
                          MSDictionary * dictionary = [MSDictionary dictionary];
                          for (NSString * attribute in @[@"device",
                                                         @"codeset",
                                                         @"setsDeviceInput",
                                                         @"offset",
                                                         @"repeatCount",
                                                         @"frequency",
                                                         @"onOffPattern",
                                                         @"prontoHex"])
                              dictionary[attribute] =
                                  CollectionSafe([self defaultValueForAttribute:attribute]);
                          [dictionary compact];
                          index = dictionary;
                      });

        return index[key];
    };

    void(^addIfCustom)(id, MSDictionary*, NSString*, id) =
    ^(id object, MSDictionary *dictionary, NSString *attribute, id addition )
    {
        BOOL isCustom = YES;

        id defaultValue = defaultForKey(attribute);
        id setValue = [object valueForKey:attribute];

        if (defaultValue && setValue)
        {
            if ([setValue isKindOfClass:[NSNumber class]])
                isCustom = ![defaultValue isEqualToNumber:setValue];

            else if ([setValue isKindOfClass:[NSString class]])
                isCustom = ![defaultValue isEqualToString:setValue];

            else
                isCustom = ![defaultValue isEqual:setValue];
        }

        if (isCustom)
            dictionary[attribute] = CollectionSafe(addition);
    };

    MSDictionary * dictionary = [super JSONDictionary];

    addIfCustom(self, dictionary, @"device",          self.device.uuid);
    addIfCustom(self, dictionary, @"codeset",         self.codeset);
    addIfCustom(self, dictionary, @"setsDeviceInput", @(self.setsDeviceInput));
    addIfCustom(self, dictionary, @"offset",          self.offset);
    addIfCustom(self, dictionary, @"repeatCount",     self.repeatCount);
    addIfCustom(self, dictionary, @"frequency",       self.frequency);
    addIfCustom(self, dictionary, @"onOffPattern",    self.onOffPattern);
    addIfCustom(self, dictionary, @"prontoHex",       self.prontoHex);

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}

- (MSDictionary *)deepDescriptionDictionary
{
    IRCode * code = [self faultedObject];
    assert(code);

    MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"name"]            = [code name];
    dd[@"device"]          = $(@"'%@':%@", code.device.name, code.device.uuid);
    dd[@"codeset"]         = code.codeset;
    dd[@"setsDeviceInput"] = BOOLString(code.setsDeviceInput);
    dd[@"offset"]          = $(@"%@",code.offset);
    dd[@"repeatCount"]     = $(@"%@", code.repeatCount);
    dd[@"frequency"]       = $(@"%@", code.frequency);
    dd[@"onOffPattern"]    = code.onOffPattern;
    return (MSDictionary *)dd;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Bankable
////////////////////////////////////////////////////////////////////////////////

+ (NSString *)directoryLabel { return @"IR Codes"; }

+ (BankFlags)bankFlags { return (BankDetail|BankEditable); }

- (BOOL)isEditable { return ([super isEditable] && self.user); }

- (void)setCategory:(NSString *)category {}

@end
