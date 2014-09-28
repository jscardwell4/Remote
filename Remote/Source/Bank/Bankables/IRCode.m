//
// IRCode.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "IRCode.h"
#import "ComponentDevice.h"
#import "Manufacturer.h"
#import "Remote-Swift.h"

enum ProntoHexFormatParts {
  PatternType                 = 0,
  Frequency                   = 1,
  SequenceOneBurstPairCount   = 2,
  SequenceTwoBurstPairCount   = 3,
  LeadInBurstPairFirstNumber  = 4,
  LeadInBurstPairSecondNumber = 5,

};

struct HexPair {
  unsigned int num1; unsigned int num2;
};

MSSTATIC_STRING_CONST IRCodeFrequencyKey       = @"frequency";
MSSTATIC_STRING_CONST IRCodeOffsetKey          = @"offset";
MSSTATIC_STRING_CONST IRCodePreamblePairsKey   = @"preamblePairs";
MSSTATIC_STRING_CONST IRCodeRepeatablePairsKey = @"repeatablePairs";
MSSTATIC_STRING_CONST IRCodeLeadInKey          = @"leadIn";

NSDictionary *parseIRCodeFromProntoHex(NSString * prontoHex) {
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

  struct HexPair leadin = { .num1 = leadInBurstFirstHex, .num2 = leadInBurstSecondHex };

  prontoParts[IRCodeLeadInKey] = [NSValue value:&leadin withObjCType:@encode(struct HexPair)];

  // Capture burst pair sequence one, which serves as iTach preamble
  NSMutableArray * preamblePairsArray = [@[] mutableCopy];

  if (seq1BurstPairCountHex > 0)
    for (int i = 0; i < seq1BurstPairCountHex; i++) {
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
    for (int i = 0; i < seq2BurstPairCountHex; i++) {
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
@dynamic device, setsDeviceInput, prontoHex, manufacturer, codeSet;

/// isValidOnOffPattern:
/// @param pattern
/// @return BOOL
+ (BOOL)isValidOnOffPattern:(NSString *)pattern {
  return ([self compressedOnOffPatternFromPattern:pattern] != nil);
}

/// compressedOnOffPatternFromPattern:
/// @param pattern
/// @return NSString *
+ (NSString *)compressedOnOffPatternFromPattern:(NSString *)pattern {

  static const int max = 65635;

  NSMutableString * compressed = [@"" mutableCopy];

  NSScanner * scanner = [NSScanner scannerWithString:pattern];
  scanner.caseSensitive = YES;
  scanner.charactersToBeSkipped = NSWhitespaceAndNewlineCharacters;


  NSMutableCharacterSet * availableCompressionCharacters = NSMutableCharacterSetMake("");
  NSCharacterSet        * commaCharacterSet              = NSCharacterSetMake(",");
  NSString * compressionCharacters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  NSUInteger compressionIndex = 0;

  while (!scanner.atEnd) {

    NSString * scannedCompressionCharacters = nil;
    if ([scanner scanCharactersFromSet:availableCompressionCharacters intoString:&scannedCompressionCharacters])
      [compressed appendString:scannedCompressionCharacters];

    else {
      int on = 0, off = 0;

      if (![scanner scanInt:&on] || on <= 0 || on > max) break;
      if (![scanner scanCharactersFromSet:commaCharacterSet intoString:NULL]) break;
      if (![scanner scanInt:&off] || off <= 0 || on > max) break;

      if (compressionIndex < [compressionCharacters length]) {

        NSString * availableCompressionCharacter =
        [compressionCharacters substringWithRange:NSMakeRange(compressionIndex, 1)];

        [availableCompressionCharacters addCharactersInString:availableCompressionCharacter];

      }

      if ([compressed numberOfMatchesForRegEx:@"^.*[0-9]$"])
        [compressed appendString:@","];

      [compressed appendFormat:@"%i,%i", on, off];

    }

  }

  return (scanner.atEnd ? compressed : nil);

}

/// setProntoHex:
/// @param prontoHex
- (void)setProntoHex:(NSString *)prontoHex {
  [self willChangeValueForKey:@"prontoHex"];
  [self setPrimitiveValue:prontoHex forKey:@"prontoHex"];
  [self didChangeValueForKey:@"prontoHex"];

  if (prontoHex) {
    NSDictionary * d = parseIRCodeFromProntoHex(prontoHex);
    self.frequency = d[IRCodeFrequencyKey];
    struct HexPair hexpair = {0, 0};
    [d[IRCodeLeadInKey] getValue:&hexpair];
    NSMutableString * pattern = [$(@"%u,%u", hexpair.num1, hexpair.num2) mutableCopy];

    // ???: why wasn't the preamble used?
    for (NSValue * hexPairValue in d[IRCodeRepeatablePairsKey]) {
      [hexPairValue getValue:&hexpair];
      [pattern appendFormat:@",%u,%u,", hexpair.num1, hexpair.num2];
    }

    self.onOffPattern = pattern;
  }
}

/// updateCategory
- (void)updateCategory {
  //FIXME: Come back after adding category stuff to model
//  NSString * manufacturerName = (self.manufacturer.name
//                                 ? $(@"(%@) ", self.manufacturer.name)
//                                 : @"");
//  NSString * codesetName = (self.codeset ?: @"-");
//  NSString * deviceName  = (self.device.name ? $(@" [%@]", self.device.name) : @"");
//  self.category = [@"" join:@[manufacturerName, codesetName, deviceName]];
}

/// setDevice:
/// @param device
- (void)setDevice:(ComponentDevice *)device {
  [self willChangeValueForKey:@"device"];
  [self setPrimitiveValue:device forKey:@"device"];
  [self didChangeValueForKey:@"device"];

  self.manufacturer = device.manufacturer;
  //TODO: Revisit this after implementing categories
  //  self.codeSet      = nil;
}

/// setManufacturer:
/// @param manufacturer
- (void)setManufacturer:(Manufacturer *)manufacturer {
  [self willChangeValueForKey:@"manufacturer"];
  [self setPrimitiveValue:manufacturer forKey:@"manufacturer"];
  [self didChangeValueForKey:@"manufacturer"];

  [self updateCategory];
}

/// updateWithData:
/// @param data
- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

  MSDictionary * codeSetData = data[@"codeset"];
  if (codeSetData)  self.codeSet = [IRCodeSet importObjectFromData:codeSetData context:self.managedObjectContext];
  self.frequency    = data[@"frequency"]       ?: self.frequency;
  self.onOffPattern = data[@"on-off-pattern"]  ?: self.onOffPattern;

}

/// JSONDictionary
/// @return MSDictionary *
- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];

  SafeSetValueForKey(self.device.commentedUUID,  @"device",  dictionary);
  SafeSetValueForKey(self.codeSet.commentedUUID, @"codeset", dictionary);
  SetValueForKeyIfNotDefault(@(self.setsDeviceInput), @"setsDeviceInput", dictionary);
  SetValueForKeyIfNotDefault(self.offset,             @"offset",          dictionary);
  SetValueForKeyIfNotDefault(self.repeatCount,        @"repeatCount",     dictionary);
  SetValueForKeyIfNotDefault(self.frequency,          @"frequency",       dictionary);

  SafeSetValueForKey(self.onOffPattern, @"on-off-pattern", dictionary);
  SafeSetValueForKey(self.prontoHex,    @"pronto-hex",     dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

/// deepDescriptionDictionary
/// @return MSDictionary *
- (MSDictionary *)deepDescriptionDictionary {
  IRCode * code = [self faultedObject];
  assert(code);

  MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
  dd[@"name"]            = [code name];
  dd[@"device"]          = $(@"'%@':%@", code.device.name, code.device.uuid);
  dd[@"codeset"]         = $(@"'%@':%@", code.codeSet.name, code.codeSet.uuid);
  dd[@"setsDeviceInput"] = BOOLString(code.setsDeviceInput);
  dd[@"offset"]          = $(@"%@", code.offset);
  dd[@"repeatCount"]     = $(@"%@", code.repeatCount);
  dd[@"frequency"]       = $(@"%@", code.frequency);
  dd[@"onOffPattern"]    = code.onOffPattern;
  return (MSDictionary *)dd;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankableModel
////////////////////////////////////////////////////////////////////////////////

/// detailViewController
/// @return IRCodeViewController *
- (IRCodeDetailController *)detailViewController { return [[IRCodeDetailController alloc] initWithItem:self editing:NO]; }

/// editingViewController
/// @return IRCodeViewController *
- (IRCodeDetailController *)editingViewController {
  return [[IRCodeDetailController alloc] initWithItem:self editing:YES];
}

/// isCategorized
/// @return BOOL
+ (BOOL)isCategorized { return YES; }

/// directoryLabel
/// @return NSString *
+ (NSString *)directoryLabel { return @"IR Codes"; }

/// directoryIcon
/// @return UIImage *
+ (UIImage *)directoryIcon { return [UIImage imageNamed:@"tv-remote"]; }

/// isEditable
/// @return BOOL
- (BOOL)isEditable { return ([super isEditable] && self.user); }

/// category
/// @return id<BankableCategory>
- (id<BankableCategory>)category { return self.codeSet; }

/// setCategory:
/// @param category
- (void)setCategory:(id<BankableCategory>)category {
  if ([category isKindOfClass:[IRCodeSet class]]) self.codeSet = (IRCodeSet *)category;
}

@end
