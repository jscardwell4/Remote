//
// ControlStateTitleSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "REControlStateSet.h"

MSKIT_KEY_DEFINITION(REForegroundColor);
MSKIT_KEY_DEFINITION(REBackgroundColor);
MSKIT_KEY_DEFINITION(REShadow);
MSKIT_KEY_DEFINITION(REStrokeColor);
MSKIT_KEY_DEFINITION(REStrokeWidth);
MSKIT_KEY_DEFINITION(REStrikethroughStyle);
MSKIT_KEY_DEFINITION(REUnderlineStyle);
MSKIT_KEY_DEFINITION(REKern);
MSKIT_KEY_DEFINITION(RELigature);
MSKIT_KEY_DEFINITION(REParagraphStyle);
MSKIT_KEY_DEFINITION(REFontName);
MSKIT_KEY_DEFINITION(REFontSize);
MSKIT_KEY_DEFINITION(RETitleText);

@implementation REControlStateTitleSet

NSDictionary * dictionaryFromObject(id obj)
{
    NSDictionary * attributesDictionary = nil;

    if ([obj isKindOfClass:[NSAttributedString class]])
        attributesDictionary = dictionaryFromAttributedString(obj);

    else if ([obj isKindOfClass:[NSString class]])
        attributesDictionary = @{RETitleTextKey: obj};

    else if ([obj isKindOfClass:[NSDictionary class]])
        attributesDictionary = obj;

    return attributesDictionary;
}

NSDictionary *dictionaryFromAttributedString(NSAttributedString * string)
{
    if (![string isKindOfClass:[NSAttributedString class]]) return nil;
    else
    {
        NSString * titleText = string.string;
        NSDictionary * attributes = [string attributesAtIndex:0 effectiveRange:NULL];

        UIColor          * foregroundColor = attributes[NSForegroundColorAttributeName];
        UIColor          * backgroundColor = attributes[NSBackgroundColorAttributeName];
        NSShadow         * shadow          = attributes[NSShadowAttributeName];
        UIColor          * strokeColor     = attributes[NSStrokeColorAttributeName];
        NSNumber         * strokeWidth     = attributes[NSStrokeWidthAttributeName];
        NSNumber         * strikethrough   = attributes[NSStrikethroughStyleAttributeName];
        NSNumber         * underline       = attributes[NSUnderlineStyleAttributeName];
        NSNumber         * kern            = attributes[NSKernAttributeName];
        NSNumber         * ligature        = attributes[NSLigatureAttributeName];
        UIFont           * font            = attributes[NSFontAttributeName];
        NSParagraphStyle * paragraph       = attributes[NSParagraphStyleAttributeName];

        NSMutableDictionary * convertedAttributes = [@{} mutableCopy];
        if (titleText)       convertedAttributes[RETitleTextKey]          = titleText;
        if (foregroundColor) convertedAttributes[REForegroundColorKey]    = foregroundColor;
        if (backgroundColor) convertedAttributes[REBackgroundColorKey]    = backgroundColor;
        if (shadow)          convertedAttributes[REShadowKey]             = shadow;
        if (strokeColor)     convertedAttributes[REStrokeColorKey]        = strokeColor;
        if (strokeWidth)     convertedAttributes[REStrokeWidthKey]        = strokeWidth;
        if (strikethrough)   convertedAttributes[REStrikethroughStyleKey] = strikethrough;
        if (underline)       convertedAttributes[REUnderlineStyleKey]     = underline;
        if (kern)            convertedAttributes[REKernKey]               = kern;
        if (ligature)        convertedAttributes[RELigatureKey]           = ligature;
        if (paragraph)       convertedAttributes[REParagraphStyleKey]     = paragraph;
        if (font)
        {
            convertedAttributes[REFontNameKey] = font.fontName;
            convertedAttributes[REFontSizeKey] = @(font.pointSize);
        }

        return convertedAttributes;
    }
}

+ (NSSet const *)validAttributeKeys
{
    static dispatch_once_t onceToken;
    static NSSet const * keys;
    dispatch_once(&onceToken, ^{
        keys = [@[REForegroundColorKey,
                  REBackgroundColorKey,
                  REShadowKey,
                  REStrokeColorKey,
                  REStrokeWidthKey,
                  REStrikethroughStyleKey,
                  REUnderlineStyleKey,
                  REKernKey,
                  RELigatureKey,
                  REParagraphStyleKey,
                  REFontNameKey,
                  REFontSizeKey,
                  RETitleTextKey] set];
    });

    return keys;
}

+ (Class)validClassForAttributeKey:(NSString *)key
{
    static dispatch_once_t onceToken;
    static NSDictionary const * index;
    dispatch_once(&onceToken, ^{
        index = @{ REForegroundColorKey    : @"UIColor",
                   REBackgroundColorKey    : @"UIColor",
                   REShadowKey             : @"NSShadow",
                   REStrokeColorKey        : @"UIColor",
                   REStrokeWidthKey        : @"NSNumber",
                   REStrikethroughStyleKey : @"NSNumber",
                   REUnderlineStyleKey     : @"NSNumber",
                   REKernKey               : @"NSNumber",
                   RELigatureKey           : @"NSNumber",
                   REParagraphStyleKey     : @"NSParagraphStyle",
                   REFontNameKey           : @"NSString",
                   REFontSizeKey           : @"NSNumber",
                   RETitleTextKey          : @"NSString" };
    });

    return ([[self validAttributeKeys] containsObject:key]
            ? NSClassFromString(index[key])
            : NULL);
}

+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)context
                             withObjects:(NSDictionary *)objects
{
    REControlStateTitleSet * stateSet = [self controlStateSetInContext:context];
    [objects enumerateKeysAndObjectsUsingBlock:
     ^(NSString * key, id obj, BOOL *stop)
     {
         NSDictionary * attributesDictionary = dictionaryFromObject(obj);
         if (attributesDictionary) stateSet[key] = attributesDictionary;
     }];

    return stateSet;
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key
{
    NSArray * keypathComponents = [key componentsSeparatedByString:@"."];
    NSUInteger count = [keypathComponents count];
    if (!count || count > 2)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"illegal keypath"
                                     userInfo:nil];
    else if (count == 1)
        [super setObject:obj forKeyedSubscript:key];

    else if (count == 2)
    {
        NSString * stateKey = keypathComponents[0];
        NSString * attributeKey = keypathComponents[1];
        NSMutableDictionary * dict = [self[stateKey] mutableCopy];
        if (!dict) dict = [@{} mutableCopy];
        Class attributeClass = [REControlStateTitleSet validClassForAttributeKey:attributeKey];
        if (attributeClass)
        {
            dict[attributeKey] = obj;
            [super setObject:dict forKeyedSubscript:stateKey];
        }
    }
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    NSArray * keypathComponents = [key componentsSeparatedByString:@"."];
    NSUInteger count = [keypathComponents count];
    if (!count || count > 2)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"illegal keypath"
                                     userInfo:nil];
        return nil;
    }

    else if (count == 1)
        return [super objectForKeyedSubscript:key];

    else if (count == 2)
    {
        NSString * stateKey = keypathComponents[0];
        NSString * attributeKey = keypathComponents[1];
        return self[stateKey][attributeKey];
    }

    assert(NO);
    return nil;
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)state
{
    NSDictionary * attributesDictionary = dictionaryFromObject(obj);
    if (attributesDictionary)
        [super setObject:attributesDictionary atIndexedSubscript:state];
}

- (NSDictionary *)objectAtIndexedSubscript:(REState)state
{
    return (NSDictionary *)[super objectAtIndexedSubscript:state];
}

- (void)setObject:(id)obj forTitleAttribute:(NSString *)attributeKey
{
    Class attributeClass = [REControlStateTitleSet validClassForAttributeKey:attributeKey];
    if (attributeClass && [obj isKindOfClass:attributeClass])
    {
        for (NSUInteger i = 0; i < 8; i++)
        {
            NSMutableDictionary * dict = [self[i] mutableCopy];
            if (!dict) dict = [@{} mutableCopy];
            dict[attributeKey] = obj;
            self[i] = dict;
        }
    }
}

- (MSDictionary *)deepDescriptionDictionary
{
    REControlStateTitleSet * stateSet = [self faultedObject];
    assert(stateSet);

    NSString *(^attributesDescription)(NSDictionary *) =
    ^(NSDictionary * attributes)
    {
        NSDictionary * attributeKeys = @{ REFontNameKey           : @0,
                                          REFontSizeKey           : @1,
                                          REParagraphStyleKey     : @2,
                                          REForegroundColorKey    : @3,
                                          REBackgroundColorKey    : @4,
                                          RELigatureKey           : @5,
                                          REKernKey               : @6,
                                          REStrikethroughStyleKey : @7,
                                          REUnderlineStyleKey     : @8,
                                          REStrokeColorKey        : @9,
                                          REStrokeWidthKey        : @10,
                                          REShadowKey             : @11,
                                          RETitleTextKey          : @12};

        NSString * description = nil;
        if (attributes)
        {

            MSMutableDictionary * attributeDescriptions = [MSMutableDictionary dictionaryWithCapacity:[attributes count]];
            for (NSString * attribute in attributes)
            {
                NSNumber * attributeIndex = attributeKeys[attribute];
                if (attributeIndex)
                {
                    id attributeValue = NilSafeValue(attributes[attribute]);
                    if (attributeValue)
                        switch ([attributeIndex shortValue])
                        {
                            case 0: // font name
                                attributeDescriptions[@"fontName"] = attributeValue;
                                break;

                            case 1: // font size
                                attributeDescriptions[@"fontSize"] = [(NSNumber *)attributeValue stringValue];
                                break;

                            case 2: // paragraph style
                            {
                                NSParagraphStyle * paragraphStyle = (NSParagraphStyle *)attributeValue;
                                NSString * paragraphStyleString = $(@"alignment:%@\nlineSpacing:%@\nlineBreakMode:%@",
                                                                    NSStringFromNSTextAlignment(paragraphStyle.alignment),
                                                                    [@(paragraphStyle.lineSpacing) stringValue],
                                                                    NSStringFromNSLineBreakMode(paragraphStyle.lineBreakMode));
                                attributeDescriptions[@"paragraph"] = paragraphStyleString;
                            }   break;

                            case 3: // foreground color
                                attributeDescriptions[@"foreground color"] = NSStringFromUIColor((UIColor *)attributeValue);
                                break;

                            case 4: // background color
                                attributeDescriptions[@"background color"] = NSStringFromUIColor((UIColor *)attributeValue);
                                break;

                            case 5: // ligature
                                attributeDescriptions[@"ligature"] = [(NSNumber *)attributeValue stringValue];
                                break;

                            case 6: // kern
                                attributeDescriptions[@"kern"] = [(NSNumber *)attributeValue stringValue];
                                break;

                            case 7: // strikethrough style
                                attributeDescriptions[@"strikethrough"] = NSStringFromBOOL([(NSNumber *)attributeValue boolValue]);
                                break;

                            case 8: // underline style
                                attributeDescriptions[@"underline"] = NSStringFromBOOL([(NSNumber *)attributeValue boolValue]);
                                break;

                            case 9: // stroke color
                                attributeDescriptions[@"stroke color"] = NSStringFromUIColor((UIColor *)attributeValue);
                                break;

                            case 10: // stroke width
                                attributeDescriptions[@"stroke width"] = [(NSNumber *)attributeValue stringValue];
                                break;

                            case 11: // shadow
                                attributeDescriptions[@"shadow"] = $(@"offset = %@, blur = %f, %@",
                                                                     NSStringFromCGSize(((NSShadow *)attributeValue).shadowOffset),
                                                                     ((NSShadow *)attributeValue).shadowBlurRadius,
                                                                     NSStringFromUIColor(((NSShadow *)attributeValue).shadowColor));
                                break;

                            case 12: // title text
                                attributeDescriptions[@"title text"] = attributeValue;
                                break;

                            default:
                                assert(NO);
                                break;
                        }
                    }
            }

            description = [attributeDescriptions formattedDescriptionWithOptions:0 levelIndent:0];
        }

        return (description ? : @"nil");
    };

    MSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

    NSString * normalString                         = attributesDescription(stateSet[0]);
    NSString * selectedString                       = attributesDescription(stateSet[1]);
    NSString * highlightedString                    = attributesDescription(stateSet[2]);
    NSString * disabledString                       = attributesDescription(stateSet[3]);
    NSString * highlightedAndSelectedString         = attributesDescription(stateSet[4]);
    NSString * highlightedAndDisabledString         = attributesDescription(stateSet[5]);
    NSString * disabledAndSelectedString            = attributesDescription(stateSet[6]);
    NSString * selectedHighlightedAndDisabledString = attributesDescription(stateSet[7]);

    dd[@"normal"]                         = normalString;
    dd[@"selected"]                       = selectedString;
    dd[@"highlighted"]                    = highlightedString;
    dd[@"disabled"]                       = disabledString;
    dd[@"highlightedAndSelected"]         = highlightedAndSelectedString;
    dd[@"highlightedAndDisabled"]         = highlightedAndDisabledString;
    dd[@"disabledAndSelected"]            = disabledAndSelectedString;
    dd[@"selectedHighlightedAndDisabled"] = selectedHighlightedAndDisabledString;

    return dd;
}

- (NSString *)shortDescription
{
    NSMutableString * description = [@"" mutableCopy];
    for (int i = 0; i < 8; i++)
    {
        NSDictionary * s = self[i];
        if (s)
            [description appendFormat:@"%@: '%@'\n", NSStringFromUIControlState(i), s];
    }
    return description;
}

@end
