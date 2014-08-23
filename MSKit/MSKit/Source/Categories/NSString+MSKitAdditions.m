//
// NSString+MSKitAdditions.m
// MSKit
//
// Created by Jason Cardwell on 5/2/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "MSKitMacros.h"
#import "MSKitLoggingFunctions.h"
#import "NSString+MSKitAdditions.h"
#import "NSNull+MSKitAdditions.h"
#import "NSArray+MSKitAdditions.h"
#import "NSObject+MSKitAdditions.h"
//#import "NSAttributedString+MSKitAdditions.h"
#import <CoreText/CoreText.h>
#import "NSValue+MSKitAdditions.h"

static int ddLogLevel = LOG_LEVEL_WARN;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@implementation NSString (MSKitAdditions)

+ (NSString *)stringWithData:(NSData *)data
{
    return (data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil);
}

- (NSString *)join:(NSArray *)array
{
    return [array componentsJoinedByString:self];
}

- (NSString *)quotedString { return [NSString stringWithFormat:@"\"%@\"", self]; }

+ (BOOL)isEmptyString:(NSString *)string
{
    return [NSNull valueIsNil:string] || string.length == 0;
}

+ (BOOL)isNotEmptyString:(NSString *)string
{
    return ![self isEmptyString:string];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    if (idx >= self.length) [[NSException exceptionWithName:NSRangeException
                                                     reason:@"index out of range" userInfo:nil] raise];

    return @([self characterAtIndex:idx]);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Creating/Formatting
////////////////////////////////////////////////////////////////////////////////

- (NSString *)stringByShiftingRight:(NSUInteger)shiftAmount
{
    return [self stringByShiftingRight:shiftAmount shiftFirstLine:YES];
}

- (NSString *)stringByShiftingRight:(NSUInteger)shiftAmount shiftFirstLine:(BOOL)shiftFirstLine
{
    NSString * padding = [NSString stringWithCharacter:' ' count:shiftAmount];

    return (shiftFirstLine
            ? [padding stringByAppendingString:
               [self stringByReplacingOccurrencesOfString:@"\n" withString:$(@"\n%@",padding)]]
            : [self stringByReplacingOccurrencesOfString:@"\n" withString:$(@"\n%@",padding)]);
}

- (NSString *)stringByShiftingLeft:(NSUInteger)shiftAmount
{
    return [self stringByShiftingLeft:shiftAmount shiftFirstLine:YES];
}

- (NSString *)stringByShiftingLeft:(NSUInteger)shiftAmount shiftFirstLine:(BOOL)shiftFirstLine
{
    NSMutableString * shiftedString = [self mutableCopy];
    [shiftedString replaceRegEx:$(@"\n {%lu}", (unsigned long)shiftAmount)
                     withString:@"\n"];
    if (shiftFirstLine)
        [shiftedString replaceRegEx:$(@"^ {%lu}", (unsigned long)shiftAmount)
                         withString:@""];
    return shiftedString;
}

+ (NSString *)stringWithCharacter:(unichar)character count:(NSUInteger)count
{
    NSString  *returnString = @"";
    NSString * (^addCharacter)(NSString *) = ^(NSString * str){
        return [str stringByAppendingFormat:@"%c",character];
    };

    for (int i = 0; i < count; i++)
    {
        returnString = addCharacter(returnString);
    }

    return returnString;
}

- (NSString *)stringByRemovingLineBreaks
{
    return [self stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}

+ (NSString *)stringWithString:(NSString *)string count:(NSUInteger)count
{
    NSMutableString * s = [@"" mutableCopy];

    for (int i = 0; i < count; i++)
        [s appendString:string];

    return s;
}

- (NSString *)stringByEscapingControlCharacters
{
    unichar    newLineCharacters[] = { 0x000A, 0x000B, 0x000C, 0x000D, 0x0085 };
    NSString * escapedString       = [self copy];

    for (int i = 0; i < 5; i++)
    {
        escapedString = [escapedString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%C", newLineCharacters[i]] withString:@"\\n"];
    }

    escapedString = [escapedString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%d", 0x0009] withString:@"\\t"];

    return escapedString;
}

- (NSString *)stringByUnescapingControlCharacters
{
    return [[[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
             stringByReplacingRegEx:@"%5C(?:(%[0-9A-F]{2})|(n))" withString:@"$1$2=%0A="]
            stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)stringByTrimmingLeadingWhitespace
{
    NSInteger   i = 0;

    while (  [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[self characterAtIndex:i]]
          || [[NSCharacterSet newlineCharacterSet] characterIsMember:[self characterAtIndex:i]])
        i++;

    return [self substringFromIndex:i];
}

- (NSString *)stringByTrimmingTrailingWhitespace
{
    NSInteger   i = [self length] - 1;

    while (  [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[self characterAtIndex:i]]
          || [[NSCharacterSet newlineCharacterSet] characterIsMember:[self characterAtIndex:i]])
        i--;

    return [self substringToIndex:i + 1];
}

- (NSString *)stringByTrimmingWhitespace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)stringByRightPaddingToLength:(NSUInteger)length withCharacter:(unichar)character
{
    if (self.length >= length) return self;
    else return $(@"%@%@", self, [NSString stringWithCharacter:character count:length - self.length]);
}

- (NSString *)stringByLeftPaddingToLength:(NSUInteger)length withCharacter:(unichar)character
{
    if (self.length >= length) return self;
    else return $(@"%@%@", [NSString stringWithCharacter:character count:length - self.length], self);
}

- (NSString *)stringByStrippingTrailingZeroes
{
    return [self stringByReplacingRegEx:@"(?:([0-9]+\\.[0-9]*[1-9])0+)|(?:([0-9]+)\\.0+)" withString:@"$1$2"];
}

- (NSString *)camelCaseString
{
    if (!self.length) return self;

    NSMutableString * string = [@"" mutableCopy];
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                             options:NSStringEnumerationByWords
                          usingBlock:^(NSString * substring,
                                       NSRange substringRange,
                                       NSRange enclosingRange,
                                       BOOL * stop)
                                     {
                                         NSMutableString * s = [substring mutableCopy];
                                         s[0] = @(toupper([s[0] charValue]));
                                         [string appendString:s];
                                     }
     ];
    string[0] = @(tolower([string[0] charValue]));

    return string;
}

- (NSString *)stringByReplacingReturnsWithSymbol
{
    return [self stringByReplacingRegEx:@"[\n\r]" withString:@"⏎"];  // \u23CE
}

- (NSString *)stringByRemovingCharacter:(unichar)character
{
    return [self stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c",character]
                                           withString:@""];
}

- (NSString *)stringByRemovingCharactersFromSet:(NSCharacterSet *)characterSet
{
    return [[self componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];
}

- (NSArray *)componentsSplitWithMaxCharactersPerLine:(NSUInteger)charactersPerLine
{
    NSInteger   length = [self length];

    if (length <= 0) return nil;

    else if (length < charactersPerLine)
        return @[self];
    else
    {
        NSMutableArray  *components = [@[] mutableCopy];
        [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                                 options:NSStringEnumerationByLines
                              usingBlock:^(NSString *line, NSRange lineRange, NSRange enclosingRange, BOOL *stop){
             if (line.length < charactersPerLine)
                 [components addObject:[line copy]];
             else
             {
                 NSMutableString * currentLine = [NSMutableString stringWithCapacity:charactersPerLine];
                 [line enumerateSubstringsInRange:NSMakeRange(0, line.length)
                                          options:NSStringEnumerationByWords
                                       usingBlock:^(NSString * word, NSRange wordRange, NSRange enclosingRange, BOOL *stop){
                      if (currentLine.length + word.length + 1 < charactersPerLine)
                          [currentLine appendFormat:@" %@", word];
                      else
                      {
                          [components addObject:[currentLine copy]];
                          [currentLine setString:word];
                      }
                  }

                 ];
                 [components addObject:[currentLine copy]];
             }
         }

        ];

        return components;
    }
}

- (NSArray *)componentsSplitNearCenterOfString
{
    NSArray    *components = nil;
    NSInteger   length     = [self length];

    if (length <= 0) return nil;

    NSInteger   midPoint = length / 2;

    __block NSInteger   splitPoint = 0;

    [self enumerateSubstringsInRange:NSMakeRange(0, length)
                             options:NSStringEnumerationByWords
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
         if (substringRange.location <= midPoint) splitPoint = substringRange.location;
         else if (substringRange.location > midPoint && substringRange.location < length)
         {
             if (splitPoint == 0 || substringRange.location - midPoint < midPoint - splitPoint)
                 splitPoint = substringRange.location;

             *stop = YES;
         }
     }

    ];
    components = @[[[self substringToIndex:splitPoint] stringByTrimmingWhitespace],[[self substringFromIndex:splitPoint] stringByTrimmingWhitespace]];

//    // NSLog(@"splitPoint = %i, components = %@",splitPoint,components);
    return components;
}

- (NSString *)stringByReplacingOccurrencesWithDictionary:(NSDictionary *)replacements
{
    NSMutableString * newString = [self mutableCopy];
    [newString replaceOccurrencesOfStringsWithDictionary:replacements];

    return newString;
}

- (NSArray *)keyPathComponents { return [self componentsSeparatedByString:@"."]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark Logging Headers/Footers
////////////////////////////////////////////////////////////////////////////////

// vertical bar: \u2502
// horizontal bar: \u2500
// down and right: \u250C
// down and left: \u2510
// up, down, and right: \u251C
// up, down, and left: \u2524
// up and right: \u2514
// up and left: \u2518

MSSTATIC_STRING_CONST   kBoxTop = @"\u250C\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                      "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                      "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                      "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                      "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                      "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                      "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                      "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2510";

MSSTATIC_STRING_CONST   kBoxBottom = @"\u2514\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                         "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                         "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                         "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                         "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                         "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                         "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                         "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2518";

MSSTATIC_STRING_CONST   kHeaderBottom = @"\u251C\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                            "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                            "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                            "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                            "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                            "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                            "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                            "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2524";

MSSTATIC_STRING_CONST   kBoxMiddle = @"\u2502                                                         "
                                         "                     \u2502";

- (NSString *)singleBarMessage
{
    return [[[self componentsSplitWithMaxCharactersPerLine:76] arrayByMappingToBlock:^NSString *(NSString * obj, NSUInteger idx){
                 return [NSString stringWithFormat:@"\u2502 %@\u2502", [obj stringByPaddingToLength:77 withString:@" " startingAtIndex:0]];
             }

            ] componentsJoinedByString:@"\n"];
}

- (NSString *)dividerWithCharacterString:(NSString *)characterString
{
    return [[NSString stringWithFormat:@"%@ %@ ",
             [NSString stringWithString:characterString count:(78 - self.length)/2],
             self] stringByPaddingToLength:80 withString:characterString startingAtIndex:0];
}

- (NSString *)singleBarColumns:(NSUInteger)padLength
{
    NSArray * titles = [self componentsSeparatedByString:@"\t"];
    titles = [titles arrayByMappingToBlock:^NSString *(NSString * obj, NSUInteger idx){
                  if (idx == titles.count - 1) return obj;
                  else return [obj stringByPaddingToLength:padLength withString:@" " startingAtIndex:0];
              }

             ];

    return [[titles componentsJoinedByString:@""] singleBarMessage];
}

- (NSString *)columnValues:(NSUInteger)padLength
{
    NSArray * lines = [self componentsSeparatedByString:@"\n"];
    lines = [lines arrayByMappingToBlock:^NSString *(NSString * obj, NSUInteger idx){
                 return [obj singleBarColumns:padLength];
             }

            ];

    return [[lines componentsJoinedByString:@"\n"] singleBarMessage];
}

- (NSString *)singleBarHeaderBox:(NSUInteger)padLength
{
    NSArray * lines = [self componentsSeparatedByString:@"\n"];
    lines = [lines arrayByMappingToBlock:^NSString *(NSString * obj, NSUInteger idx){
                 if (idx == 0)
                     return [obj singleBarHeaders:padLength];
                 else if (idx == lines.count - 1)
                     return [NSString stringWithFormat:@"%@\n%@", [obj singleBarColumns:padLength], kBoxBottom];
                 else
                     return [obj singleBarColumns:padLength];
             }

            ];

    return [lines componentsJoinedByString:@"\n"];
}

- (NSString *)singleBarHeaders:(NSUInteger)padLength
{
    return [NSString stringWithFormat:@"%1$@\n%2$@\n%3$@",
            kBoxTop,
            [self singleBarColumns:padLength], kHeaderBottom];
}

- (NSString *)singleBarMessageBox
{
    return [NSString stringWithFormat:@"%1$@\n%2$@\n%3$@\n%2$@\n%4$@\n",
            kBoxTop,
            kBoxMiddle,
            [self singleBarMessage],
            kBoxBottom];
}

- (BOOL)writeToFile:(NSString *)filePath
{
    NSError * error;
    [self writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    MSHandleErrors(error);
    return (!error);
}

@end

@implementation NSMutableString (MSKitAdditions)

- (void)insertString:(NSString *)aString atIndexes:(NSIndexSet *)indexes
{
    __block NSUInteger offset = 0;
    NSUInteger offsetLength = [aString length];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
     {
         NSUInteger insertionIndex = idx + offset;
         if (insertionIndex < [self length])
         {
             [self insertString:aString atIndex:insertionIndex];
             offset += offsetLength;
         }

         else if (insertionIndex == [self length])
         {
             [self appendString:aString];
             *stop = YES;
         }

         else
         {
             *stop = YES;
         }
     }];
}

- (void)wrapLinesAtColumn:(NSUInteger)column
{
    if ([self length] < column) return;
    
    NSLinguisticTagger * tagger = [[NSLinguisticTagger alloc]
                                   initWithTagSchemes:@[NSLinguisticTagSchemeTokenType]
                                              options:0];
    [tagger setString:self];
    __block NSRange range = NSMakeRange(0, column);
    NSMutableIndexSet * lineBreaks = [NSMutableIndexSet indexSet];
    while(range.location < [self length] - column)
    {
        NSArray * tokenRanges = nil;
        NSArray * rangeTags = [tagger tagsInRange:range
                                           scheme:NSLinguisticTagSchemeTokenType
                                          options:0
                                      tokenRanges:&tokenRanges];
        [rangeTags enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:
         ^(NSString * tag, NSUInteger idx, BOOL *stop)
         {
             if ([NSLinguisticTagPunctuation isEqualToString:tag])
             {
                 NSRange tagRange = RangeValue(tokenRanges[idx]);
                 NSUInteger insertionIndex = NSMaxRange(tagRange);
                 [lineBreaks addIndex:insertionIndex];
                 range.location = insertionIndex;
                 *stop = YES;
             }
         }];
    }

    [self insertString:@"\n" atIndexes:lineBreaks];

}

- (void)setObject:(NSNumber *)object atIndexedSubscript:(NSUInteger)idx
{
    if (idx >= self.length) [[NSException exceptionWithName:NSRangeException
                                                     reason:@"index out of range" userInfo:nil] raise];

    [self replaceCharactersInRange:NSMakeRange(idx, 1) withString:$(@"%c",[object charValue])];
}

- (void)removeCharacter:(unichar)character
{
    [self replaceOccurrencesOfString:[NSString stringWithFormat:@"%c",character]
                          withString:@""
                             options:0 range:NSMakeRange(0, self.length)];
}

- (void)removeCharactersFromSet:(NSCharacterSet *)characterSet
{
    self.string = [self stringByRemovingCharactersFromSet:characterSet];
}

- (void)replaceOccurrencesOfStringsWithDictionary:(NSDictionary *)replacements
{
    if (!replacements) return;

    [replacements enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
         NSRange range = [self rangeOfString:(NSString*)key];

         while (range.location != NSNotFound)
         {
             [self replaceCharactersInRange:range withString:(NSString*)obj];
             range = [self rangeOfString:(NSString*)key];
         }
     }

    ];
}

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Regular expressions
////////////////////////////////////////////////////////////////////////////////


@implementation NSString (MSKitRegularExpressionAdditions)

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Regular Expressions
////////////////////////////////////////////////////////////////////////////////

// Range of regular expression
- (NSRange)rangeOfRegEX:(NSString *)regex { return [self rangeOfMatch:0 forRegEx:regex]; }

- (NSRange)rangeOfMatch:(NSUInteger)match forRegEx:(NSString *)regex
{
    return [self rangeOfCapture:0 inMatch:match forRegEx:regex];
}

- (NSRange)rangeOfCapture:(NSUInteger)capture forRegEx:(NSString *)regex
{
    return [self rangeOfCapture:capture inMatch:0 forRegEx:regex];
}

- (NSRange)rangeOfCapture:(NSUInteger)capture inMatch:(NSUInteger)match forRegEx:(NSString *)regex
{
    NSError             * error;
    NSRegularExpression * re = [NSRegularExpression
                                regularExpressionWithPattern:regex
                                options:NSRegularExpressionAnchorsMatchLines
                                error:&error];
    if (error) { MSHandleErrors(error); return NSNotFoundRange; }

    NSArray  *matches = [re matchesInString:self options:0 range:NSMakeRange(0, [self length])];

    return ([matches count] > match && [matches[match] numberOfRanges] > capture
            ?[matches[match] rangeAtIndex:capture]
            : NSNotFoundRange);
}

- (NSArray *)rangesOfMatchesForRegEx:(NSString *)regex
{
    NSError             * error;
    NSRegularExpression * re = [NSRegularExpression
                                regularExpressionWithPattern:regex
                                options:NSRegularExpressionAnchorsMatchLines
                                error:&error];
    if (error) { MSHandleErrors(error); return nil; }

    return [[re matchesInString:self options:0 range:NSMakeRange(0, [self length])]
            valueForKeyPath:@"range"];
}

- (NSArray *)componentsSeparatedByRegEx:(NSString *)regex
{
    NSMutableString     * string = [NSMutableString stringWithString:self];
    NSError             * error;
    NSRegularExpression * re = [NSRegularExpression regularExpressionWithPattern:regex
                                                                         options:NSRegularExpressionAnchorsMatchLines
                                                                           error:&error];
    if (error) { MSHandleErrors(error); return nil; }

    [re replaceMatchesInString:string options:0 range:NSMakeRange(0, self.length) withTemplate:@"<match>"];

    return [string componentsSeparatedByString:@"<match>"];
}

- (NSString *)stringByMatchingFirstOccurrenceOfRegEx:(NSString *)regex capture:(NSUInteger)capture
{
    return [self stringByMatchingRegEx:regex match:0 capture:capture];
}

- (NSString *)stringByMatchingRegEx:(NSString *)regex
                              match:(NSUInteger)match
                            capture:(NSUInteger)capture
{
    NSRange   range = [self rangeOfCapture:capture inMatch:match forRegEx:regex];

    return (range.location == NSNotFound ? nil : [self substringWithRange:range]);
}

- (NSArray *)matchingSubstringsForRegEx:(NSString *)regex
{
    return [[self rangesOfMatchesForRegEx:regex]
            arrayByMappingToBlock:^NSString *(NSValue * range, NSUInteger idx)
            {
                NSRange r = RangeValue(range);
                return (r.location == NSNotFound ? @"" : [self substringWithRange:r]);
            }];
}

- (NSUInteger)numberOfMatchesForRegEx:(NSString *)regex
{
    return [self numberOfMatchesForRegEx:regex options:0];
}

- (NSUInteger)numberOfMatchesForRegEx:(NSString *)regex options:(NSRegularExpressionOptions)opts
{
    NSError             * error = NULL;
    NSRegularExpression * re    = [NSRegularExpression regularExpressionWithPattern:regex
                                                                            options:opts
                                                                              error:&error];
    if (error) { MSHandleErrors(error); return 0; }

    return [re numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];
}

- (BOOL)hasSubstring:(NSString *)substring options:(NSRegularExpressionOptions)options
{
    return ([self numberOfMatchesForRegEx:substring//[NSRegularExpression escapedPatternForString:substring]
                                  options:options]);
}

- (BOOL)hasSubstring:(NSString *)substring { return [self hasSubstring:substring options:0]; }

- (NSArray *)matchesForRegEx:(NSString *)regex
{
    NSError             * error = NULL;
    NSRegularExpression * re = [NSRegularExpression
                                regularExpressionWithPattern:regex
                                options:NSRegularExpressionAnchorsMatchLines
                                error:&error];

    if (error) { MSHandleErrors(error); return nil; }

    NSArray  *matches = [re matchesInString:self options:0 range:NSMakeRange(0, [self length])];

    return matches;
}

- (NSString *)sub:(NSString *)regex template:(NSString *)temp options:(NSRegularExpressionOptions)opts
{
    NSError * error = nil;
    NSRegularExpression * exp = [NSRegularExpression regularExpressionWithPattern:regex
                                                                          options:opts
                                                                            error:&error];
    if (error) { MSHandleErrors(error); return nil; }

    return [exp stringByReplacingMatchesInString:self
                                         options:0
                                           range:NSMakeRange(0, self.length)
                                    withTemplate:temp];
}

- (NSString *)stringByReplacingRegEx:(NSString *)regex withString:(NSString *)string
{
    NSMutableString * newString = [self mutableCopy];
    [newString replaceRegEx:regex withString:string];

    return newString;
}

- (NSArray *)capturedStringsByMatchingFirstOccurrenceOfRegex:(NSString *)regex
{
    return [self capturedStringsByMatchingFirstOccurrenceOfRegex:regex options:0];
}

- (NSArray *)capturedStringsByMatchingFirstOccurrenceOfRegex:(NSString *)regex
                                                     options:(NSRegularExpressionOptions)options
{
    NSError * error = nil;
    NSRegularExpression * exp = [NSRegularExpression regularExpressionWithPattern:regex
                                                                          options:options
                                                                            error:&error];
    if (error) { MSHandleErrors(error); return nil; }

    NSTextCheckingResult * match = [exp firstMatchInString:self
                                                   options:0
                                                     range:NSMakeRange(0, [self length])];

    NSMutableArray * captures = [NSMutableArray arrayWithNullCapacity:exp.numberOfCaptureGroups];
    if (match)
    {
        for (NSUInteger i = 0; i < exp.numberOfCaptureGroups; i++)
        {
            NSRange captureGroupRange = [match rangeAtIndex:i+1];
            if (captureGroupRange.location == NSNotFound) continue;

            captures[i] = [self substringWithRange:captureGroupRange];
        }
    }

    return captures;
}

@end

@implementation NSMutableString (MSKitRegularExpressionAdditions)

- (void)replaceRegEx:(NSString *)regex withString:(NSString *)string
{
    NSInteger   startingLength = self.length;
    NSArray   * matches        = [self matchesForRegEx:regex];
    NSArray   * captures       = [string matchingSubstringsForRegEx:@"\\$[0-9]([=][^=]+[=])?"];

    for (NSTextCheckingResult * match in matches)
    {
        NSRange   matchRange = [match range];
        matchRange.location -= startingLength - self.length;
        NSMutableString * replaceString = [string mutableCopy];

        for (NSString * capture in captures)
        {
            NSString * capReplace = [capture stringByMatchingFirstOccurrenceOfRegEx:@"\\$[0-9][=]([^=]+)[=]" capture:1];
            NSString * capNum     = [capture stringByRemovingCharacter:'$'];

            if (capNum)
            {
                NSInteger   n       = [capNum integerValue];
                NSString  * rString = @"";
                NSRange     r       = [match rangeAtIndex:n];

                if (n <= [match numberOfRanges] && r.location != NSNotFound)
                {
                    r.location -= startingLength - self.length;

                    if (capReplace)
                        rString = capReplace;
                    else
                        rString = [self substringWithRange:r];
                }

                [replaceString replaceOccurrencesOfString:capture withString:rString options:0 range:NSMakeRange(0, replaceString.length)];
            }
        }

        [self replaceCharactersInRange:matchRange withString:replaceString];
    }
}

- (void)sub:(NSString *)regex template:(NSString *)temp options:(NSRegularExpressionOptions)opts
{
    NSError * error = nil;
    NSRegularExpression * regularExpression = [NSRegularExpression regularExpressionWithPattern:regex
                                                                                        options:opts
                                                                                          error:&error];
    if (error) { MSHandleErrors(error); return; }

    [regularExpression replaceMatchesInString:self
                                      options:0
                                        range:NSMakeRange(0, self.length)
                                 withTemplate:temp];
}

@end