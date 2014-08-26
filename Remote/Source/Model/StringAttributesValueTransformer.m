//
//  StringAttributesValueTransformer.m
//  Remote
//
//  Created by Jason Cardwell on 11/7/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "StringAttributesValueTransformer.h"
#import "RemoteElementExportSupportFunctions.h"
#import "RemoteElementImportSupportFunctions.h"
#import "RemoteElementKeys.h"
#import "REFont.h"
#import "JSONObjectKeys.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Dictionary to attributed string
////////////////////////////////////////////////////////////////////////////////


@implementation StringAttributesValueTransformer

+ (BOOL)allowsReverseTransformation { return YES; }

/// Transforms dictionary with remote element keys-values into an attributed string
- (id)transformedValue:(id)value
{
    if (isDictionaryKind(value))
    {
        id titleText = value[RETitleTextAttributeKey];
        if (!titleText) return nil;
        else if (isNumberKind(titleText)) titleText = [titleText stringValue];

        NSMutableAttributedString * string = [NSMutableAttributedString
                                              attributedStringWithString:titleText];

        NSSet * keysToSkip = [@[RETitleTextAttributeKey,
                                REStrikethroughStyleAttributeKey,
                                REUnderlineStyleAttributeKey] set];

        [value enumerateKeysAndObjectsUsingBlock:
         ^(NSString * key, id obj, BOOL *stop)
         {
             if ([keysToSkip containsObject:key]) return;

             [string addAttribute:remoteElementAttributeNameForKey(key)
                            value:([key isEqualToString:REFontAttributeKey]
                                   ? ((REFont *)obj).UIFontValue
                                   : obj)
                            range:NSMakeRange(0, [string length])];
         }];

        return string;
    }

    else
        return value;
}

/// Transforms attributed string into dicitionary with remote element keys-values
/// @warn Not yet implemented, will halt execution
- (id)reverseTransformedValue:(id)value
{
    assert(NO);

    if (isKind(value, UIFont))
        return [REFont fontFromFont:value];

    if (isAttributedStringKind(value))
    {
        NSAttributedString * string = (NSAttributedString *)value;

        MSDictionary * dictionary = [MSDictionary dictionaryWithObject:string.string
                                                                forKey:RETitleTextAttributeKey];

        // retrieve the attributes from the string
        NSDictionary * attributes = [string attributesAtIndex:0 effectiveRange:NULL];

        [attributes enumerateKeysAndObjectsUsingBlock:
         ^(id key, id obj, BOOL *stop)
         {

         }];

        // iterate over all valid attribute names
        for (NSString * attributeName in remoteElementAttributeNames())
        {
            NSString * key = remoteElementAttributeKeyForName(attributeName);
            dictionary[key] = CollectionSafe([self transformedValue:attributes[attributeName]]);
        }
        
        [dictionary compact];
        
        return dictionary;
    }
    
}

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - JSON import/export transformations
////////////////////////////////////////////////////////////////////////////////


@implementation StringAttributesJSONValueTransformer

+ (BOOL)allowsReverseTransformation { return YES; }

/// Transforms a dictionary with remote element keys-values into a dictionary suitable for JSON export
- (id)transformedValue:(id)value
{
    static MSDictionary *(^dictionaryFromParagraphStyle)(NSParagraphStyle*) =
    ^MSDictionary *(NSParagraphStyle *style)
    {
        if (!style) return nil;

        MSDictionary * styleDictionary = [MSDictionary dictionary];

        [[style dictionaryWithValuesForKeys:remoteElementParagraphAttributeNames()]
         enumerateKeysAndObjectsUsingBlock:
         ^(NSString * key, id obj, BOOL *stop)
         {
             if ([key isEqualToString:RETabStopsAttributeName]) return; // tab stop export unsupported

             NSString * jsonKey = titleSetAttributeJSONKeyForName(key);

             if ([key isEqualToString:RETextAlignmentAttributeName] && ![obj isEqualToNumber:@4])
                 styleDictionary[jsonKey] = textAlignmentJSONValueForAlignment(IntegerValue(obj));

             else if ([key isEqualToString:RELineBreakModeAttributeName] && ![obj isEqualToNumber:@0])
                 styleDictionary[jsonKey] = lineBreakModeJSONValueForMode(IntegerValue(obj));

             else if (   (   [key isEqualToString:REUnderlineStyleAttributeKey]
                          || [key isEqualToString:REStrikethroughStyleAttributeKey])
                      && ![obj isEqualToNumber:@0])
                 styleDictionary[jsonKey] = underlineStrikethroughStyleJSONValueForStyle(IntegerValue(obj));

             else if (![obj isEqualToNumber:@0])
                 styleDictionary[jsonKey] = obj;
         }];

        return styleDictionary;
    };


    if (isDictionaryKind(value))
    {
        MSDictionary * dictionary = [MSDictionary dictionary];

        // iterate through key value pairs
        [value enumerateKeysAndObjectsUsingBlock:
         ^(NSString * key, id obj, BOOL *stop)
         {
             NSString * jsonKey = titleSetAttributeJSONKeyForKey(key);

             // color
             if (isKind(obj, UIColor))
                 dictionary[jsonKey] = normalizedColorJSONValueForColor(obj);

             // paragraph style
             else if (isKind(obj, NSParagraphStyle))
                 dictionary[jsonKey] = CollectionSafe(dictionaryFromParagraphStyle(obj));

             // shadow
             //TODO: Handle NSShadow to JSON transformation
             else if (isKind(obj, NSShadow))
                 MSLogWarn(@"NSShadow export not yet supported");

             // font
             else if (isKind(obj, REFont))
                 dictionary[jsonKey] = ((REFont *)obj).stringValue;

             // strings
             else if (isKind(obj, NSString))
             {
                 if ([obj isEqualToString:NSTextEffectLetterpressStyle])
                     dictionary[jsonKey] = RETextEffectLetterPressJSONKey;

                 else if (   [[UIFont fontAwesomeIconCharacters] containsObject:obj]
                          && ({ REFont * font = value[REFontAttributeKey];
                     (font && [font.fontName isEqualToString:@"FontAwesome"]);})
                          )
                     dictionary[REFontAwesomeIconJSONKey] = [UIFont fontAwesomeNameForIcon:obj];

                 else
                     dictionary[jsonKey] = obj;
             }

             // numbers
             else if (isKind(obj, NSNumber))
             {
                 NSSet * underlineStyleKeys = [@[REUnderlineStyleAttributeKey,
                                                 REStrikethroughStyleAttributeKey] set];

                 if ([underlineStyleKeys containsObject:key])
                     dictionary[jsonKey] = underlineStrikethroughStyleJSONValueForStyle(IntegerValue(obj));

                 else
                     dictionary[jsonKey] = obj;
             }
         }];

        [dictionary compact];
        [dictionary compress];

        return dictionary;
    }

    else
        return value;
}

/// Transforms a dictionary with imported JSON values into a dictionary with remote element keys-values
- (id)reverseTransformedValue:(id)value
{
    if (isStringKind(value))
    {
        NSString * string = (NSString *)value;

        if ([string isEqualToString:RETextEffectLetterPressJSONKey])
            return NSTextEffectLetterpressStyle;

        if ([[UIFont fontAwesomeIconNames] containsObject:string])
            return [UIFont fontAwesomeIconForName:string];

        if (   [remoteElementJSONUnderlineStyleKeys() containsObject:string]
            || (   [string rangeOfString:@"-"].location != NSNotFound
                && [[[string componentsSeparatedByString:@"-"] set]
                    isSubsetOfSet:remoteElementJSONUnderlineStyleKeys()]
                )
            )
            return @(underlineStrikethroughStyleForJSONKey(string));

        // Use regular expression matching to determine transformation
        NSUInteger length = [string length];

        // check for a number
        NSCharacterSet * numberCharacterSet =
        [NSCharacterSet characterSetWithCharactersInString:@"0123456789.-+"];
        if (length && [[string stringByRemovingCharactersFromSet:numberCharacterSet] length] == 0)
            return @([string doubleValue]);

        // check for a font
        NSSet * fontNames = [[[[UIFont familyNames] arrayByMappingToBlock:
                               ^id(id obj, NSUInteger idx)
                               {
                                   return [UIFont fontNamesForFamilyName:obj];
                               }] flattenedArray] set];
        NSString * fontName =
        [string stringByMatchingFirstOccurrenceOfRegEx:@"([a-zA-Z0-9 -]+)(@[0-9]+\\.?[0-9]*)?"
                                               capture:1];
        if (fontName && [fontNames containsObject:fontName])
            return [REFont fontFromString:string];

        NSRange stringRange = NSMakeRange(0, length);
        NSRange matchRange = [string rangeOfRegEX:@"^#[0-9A-F]{8}(@[0-9]*\\.?[0-9]*%)?"];
        if (NSEqualRanges(stringRange, matchRange)) return colorFromImportValue(string);

        NSString * colorName =
        [string stringByMatchingFirstOccurrenceOfRegEx:@"([a-zA-Z0-9 ]+)(@[0-9]*\\.?[0-9]*%)?"
                                               capture:1];
        if (colorName && [[[UIColor colorNames] set] containsObject:colorName])
            return colorFromImportValue(string);
    }

    else if (isDictionaryKind(value))
    {
        // Use key matching to determine transformation
        NSDictionary * dictionary = (NSDictionary *)value;

        if ([remoteElementJSONAttributeKeys() intersectsSet:[[dictionary allKeys] set]])
        {
            // transform dictionary into storage dictionary
            MSDictionary * transformedDictionary = [MSDictionary dictionary];
            for (NSString * key in dictionary)
            {
                id v = dictionary[key];
                NSString * mappedKey = titleSetAttributeKeyForJSONKey(key);
                if (v && mappedKey)
                {
                    id transV = [self reverseTransformedValue:v];
                    if (transV) transformedDictionary[mappedKey] = transV;
                }
            }

            [transformedDictionary compact];

            return transformedDictionary;
        }

        else if ([remoteElementJSONParagraphAttributeKeys() intersectsSet:[[dictionary allKeys] set]])
        {
            // transform into paragraph style
            NSMutableParagraphStyle * paragraphStyle = [NSMutableParagraphStyle new];
            for (NSString * key in dictionary)
            {
                id v = dictionary[key];
                NSString * mappedKey = titleSetAttributeKeyForJSONKey(key);

                if ([mappedKey isEqualToString:RETextAlignmentAttributeKey])
                    v = @(textAlignmentForJSONKey(v));

                else if ([mappedKey isEqualToString:RELineBreakModeAttributeKey])
                    v = @(lineBreakModeForJSONKey(v));
                
                if (v && mappedKey)
                    [paragraphStyle setValue:v forKey:remoteElementParagraphAttributeNameForKey(mappedKey)];
            }
            
            return paragraphStyle;
        }
    }
    
    return value;
}

@end