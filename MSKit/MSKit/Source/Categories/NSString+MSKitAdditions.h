//
// NSString+MSKitAdditions.h
// MSKit
//
// Created by Jason Cardwell on 5/2/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//
#import "MSKitLoggingFunctions.h"

// Convenience macros
#define NSStringFromBOOL(bool) (bool ? @"YES" : @"NO")
#define StringIsEmpty(s)       [NSString isEmptyString:s]
#define StringIsNotEmpty(s)    [NSString isNotEmptyString:s]
#define $(...)                 [NSString stringWithFormat:__VA_ARGS__]
#define UTF8(s)                [s UTF8String]
#define StripTrailingZeros(s)  [s stringByStrippingTrailingZeroes]

#define BOOLString(bool)                  NSStringFromBOOL(bool)
#define CGPointString(v)                  NSStringFromCGPoint(v)
#define CGSizeString(v)                   NSStringFromCGSize(v)
#define CGRectString(v)                   NSStringFromCGRect(v)
#define CGAffineTransformString(v)        NSStringFromCGAffineTransform(v)
#define UIEdgeInsetsString(v)             NSStringFromUIEdgeInsets(v)
#define UIOffsetString(v)                 NSStringFromUIOffset(v)
#define ClassString(v)                    NSStringFromClass(v)
#define SelectorString(v)                 NSStringFromSelector(v)
#define NSRangeString(v)                  NSStringFromRange(v)
#define MSBoundaryString(v)               NSStringFromMSBoundary(v)
#define CATransform3DString(v)            NSStringFromCATransform3D(v)
#define CATransform3DTString(v)           NSStringFromCATransform3DT(v)
#define NSAttributeTypeString(v)          NSStringFromNSAttributeType(v)
#define NSDeleteRuleString(v)             NSStringFromNSDeleteRule(v)
#define CGImageAlphaInfoString(v)         NSStringFromCGImageAlphaInfo(v)
#define CGBitmapInfoByteOrderString(v)    NSStringFromCGBitmapInfoByteOrder(v)
#define CGColorRenderingIntentString(v)   NSStringFromCGColorRenderingIntent(v)
#define ImageInfoString(v)                NSStringFromImageInfo(v)
#define UIControlStateString(v)           NSStringFromUIControlState(v)
#define UIGestureRecognizerStateString(v) NSStringFromUIGestureRecognizerState(v)
#define CGColorSpaceModelString(v)        NSStringFromCGColorSpaceModel(v)
#define vImage_ErrorString(v)             NSStringFromvImage_Error(v)


@interface NSString (MSKitAdditions)

+ (NSString *)stringWithData:(NSData *)data;

/// Returns the character at the specified index wrapped by boxed expression
- (id)objectAtIndexedSubscript:(NSUInteger)idx;

- (NSString *)dashCaseToCamelCase;
- (NSString *)camelCaseToDashCase;

- (NSString *)join:(NSArray *)array;

- (NSString *)quotedString;

- (NSString *)stringByReplacingOccurrencesWithDictionary:(NSDictionary *)replacements;

/// Right shifts all lines by the specified amount using leading spaces
- (NSString *)stringByShiftingRight:(NSUInteger)shiftAmount;

/// Right shifts all lines by the specified amount with the option to leave first line unshifted
- (NSString *)stringByShiftingRight:(NSUInteger)shiftAmount shiftFirstLine:(BOOL)shiftFirstLine;

/// Left shifts all lines by the specified amount removing leading spaces
- (NSString *)stringByShiftingLeft:(NSUInteger)shiftAmount;

/// Left shifts all lines by the specified amount with the option to leave first line unshifted
- (NSString *)stringByShiftingLeft:(NSUInteger)shiftAmount shiftFirstLine:(BOOL)shiftFirstLine;

/// Replace returns with ⏎
- (NSString *)stringByReplacingReturnsWithSymbol;

/// Escape control characters
- (NSString *)stringByEscapingControlCharacters;

/// Unescape control characters
- (NSString *)stringByUnescapingControlCharacters;

/// Remove leading whitespace and line breaks
- (NSString *)stringByTrimmingLeadingWhitespace;

/// Remove trailing whitespace and line breaks
- (NSString *)stringByTrimmingTrailingWhitespace;

/// Remove leading and trailing whitespace and line breaks
- (NSString *)stringByTrimmingWhitespace;

/// String by right padding to specified length with specified character
- (NSString *)stringByRightPaddingToLength:(NSUInteger)length withCharacter:(unichar)character;

/// String by left padding to specified length with specified character
- (NSString *)stringByLeftPaddingToLength:(NSUInteger)length withCharacter:(unichar)character;

/// Remove trailing '0's
- (NSString *)stringByStrippingTrailingZeroes;

/// Remove the specified character
- (NSString *)stringByRemovingCharacter:(unichar)character;

/// Remove characters from the specified set of characters
- (NSString *)stringByRemovingCharactersFromSet:(NSCharacterSet *)characterSet;

/// Turn the string into a camelCase string
- (NSString *)camelCase;

/// Remove line break characters
- (NSString *)stringByRemovingLineBreaks;

/// Divide the string in two near the middle
- (NSArray *)componentsSplitNearCenterOfString;

/// Divide the string into segements no longer than the specified width
- (NSArray *)componentsSplitWithMaxCharactersPerLine:(NSUInteger)charactersPerLine;

/// String containing the specified number of the specified character
+ (NSString *)stringWithCharacter:(unichar)character count:(NSUInteger)count;

/// String containing the specified number of the specified string
+ (NSString *)stringWithString:(NSString *)string count:(NSUInteger)count;

/// String encased in box characters
- (NSString *)singleBarMessageBox;

/// String with divided headers for a unicode character table
- (NSString *)singleBarHeaders:(NSUInteger)padLength;

/// String with header box for a unicode character table
- (NSString *)singleBarHeaderBox:(NSUInteger)padLength;

/// String with columns for a unicode character table
- (NSString *)singleBarColumns:(NSUInteger)padLength;

/// Something along the lines of the last few methods
- (NSString *)singleBarMessage;

/// String filled with specified string of sufficient length to visually divide content
- (NSString *)dividerWithCharacterString:(NSString *)characterString;

/// Returns `YES` if the string has zero length or is null or is the null object
+ (BOOL)isEmptyString:(NSString *)string;

/// Returns `YES` if the string has length greater than zero 
+ (BOOL)isNotEmptyString:(NSString *)string;
- (NSArray *)keyPathComponents;

- (BOOL)writeToFile:(NSString *)filePath;

@end

@interface NSMutableString (MSKitAdditions)

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)idx;

- (void)wrapLinesAtColumn:(NSUInteger)column;

- (void)insertString:(NSString *)aString atIndexes:(NSIndexSet *)indexes;

- (void)removeCharacter:(unichar)character;

- (void)removeCharactersFromSet:(NSCharacterSet *)characterSet;

- (void)replaceOccurrencesOfStringsWithDictionary:(NSDictionary *)replacements;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Regular Expressions
////////////////////////////////////////////////////////////////////////////////


@interface NSString (MSKitRegularExpressionAdditions)

- (NSRange)rangeOfCapture:(NSUInteger)capture forRegEx:(NSString *)regex;
- (NSRange)rangeOfCapture:(NSUInteger)capture inMatch:(NSUInteger)match forRegEx:(NSString *)regex;

- (NSRange)rangeOfRegEX:(NSString *)regex;
- (NSRange)rangeOfMatch:(NSUInteger)match forRegEx:(NSString *)regex;
- (NSArray *)rangesOfMatchesForRegEx:(NSString *)regex;

- (NSString *)stringByMatchingFirstOccurrenceOfRegEx:(NSString *)regex capture:(NSUInteger)capture;
- (NSString *)stringByMatchingRegEx:(NSString *)regex
                              match:(NSUInteger)match
                            capture:(NSUInteger)capture;

//- (NSString *)sub:(NSString *)regex
//         template:(NSString *)temp
//          options:(NSRegularExpressionOptions)opts;

- (NSString *)stringByReplacingRegEx:(NSString *)regex withString:(NSString *)string;

- (NSArray *)componentsSeparatedByRegEx:(NSString *)regex;
- (NSArray *)matchesForRegEx:(NSString *)regex;
- (NSArray *)matchingSubstringsForRegEx:(NSString *)regex;
- (NSArray *)capturedStringsByMatchingFirstOccurrenceOfRegex:(NSString *)regex;
- (NSArray *)capturedStringsByMatchingFirstOccurrenceOfRegex:(NSString *)regex
                                                     options:(NSRegularExpressionOptions)opts;

- (NSUInteger)numberOfMatchesForRegEx:(NSString *)regex;
- (NSUInteger)numberOfMatchesForRegEx:(NSString *)regex options:(NSRegularExpressionOptions)opts;

- (BOOL)hasSubstring:(NSString *)substring;
- (BOOL)hasSubstring:(NSString *)substring options:(NSRegularExpressionOptions)options;

@end

@interface NSMutableString (MSKitRegularExpressionAdditions)

/**
 Replacement strings can include captures using $(capture). i.e. @"$1"
 Text can be specifed for a particular capture with $(capture)=(text)=. i.e. @"$1 $2=%0A="
 */
- (void)replaceRegEx:(NSString *)regex withString:(NSString *)string;
- (void)sub:(NSString *)regex template:(NSString *)temp options:(NSRegularExpressionOptions)opts;

@end
