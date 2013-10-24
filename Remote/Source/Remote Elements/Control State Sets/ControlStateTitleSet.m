//
// ControlStateTitleSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ControlStateTitleSet.h"
#import "RemoteElementExportSupportFunctions.h"
#import "RemoteElementImportSupportFunctions.h"
#import "JSONObjectKeys.h"
#import "REFont.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

MSKEY_DEFINITION(REFontAttribute);            
MSKEY_DEFINITION(REParagraphStyleAttribute);      
MSKEY_DEFINITION(REForegroundColorAttribute);     
MSKEY_DEFINITION(REBackgroundColorAttribute);     
MSKEY_DEFINITION(RELigatureAttribute);            
MSKEY_DEFINITION(REKernAttribute);                
MSKEY_DEFINITION(REStrikethroughStyleAttribute);  
MSKEY_DEFINITION(REUnderlineStyleAttribute);      
MSKEY_DEFINITION(REStrokeColorAttribute);         
MSKEY_DEFINITION(REStrokeWidthAttribute);         
MSKEY_DEFINITION(REShadowAttribute);              
MSKEY_DEFINITION(RETextEffectAttribute);          
MSKEY_DEFINITION(REBaselineOffsetAttribute);      
MSKEY_DEFINITION(REUnderlineColorAttribute);      
MSKEY_DEFINITION(REStrikethroughColorAttribute);  
MSKEY_DEFINITION(REObliquenessAttribute);         
MSKEY_DEFINITION(REExpansionAttribute);           
MSKEY_DEFINITION(RETitleTextAttribute);           

MSKEY_DEFINITION(RELineSpacingAttribute);             
MSKEY_DEFINITION(REParagraphSpacingAttribute);        
MSKEY_DEFINITION(RETextAlignmentAttribute);           
MSKEY_DEFINITION(REFirstLineHeadIndentAttribute);     
MSKEY_DEFINITION(REHeadIndentAttribute);              
MSKEY_DEFINITION(RETailIndentAttribute);              
MSKEY_DEFINITION(RELineBreakModeAttribute);           
MSKEY_DEFINITION(REMinimumLineHeightAttribute);       
MSKEY_DEFINITION(REMaximumLineHeightAttribute);       
MSKEY_DEFINITION(RELineHeightMultipleAttribute);      
MSKEY_DEFINITION(REParagraphSpacingBeforeAttribute);  
MSKEY_DEFINITION(REHyphenationFactorAttribute);       
MSKEY_DEFINITION(RETabStopsAttribute);                
MSKEY_DEFINITION(REDefaultTabIntervalAttribute);

MSSTRING_CONST   RELineSpacingAttributeName            = @"lineSpacing";
MSSTRING_CONST   REParagraphSpacingAttributeName       = @"paragraphSpacing";
MSSTRING_CONST   RETextAlignmentAttributeName          = @"alignment";
MSSTRING_CONST   REFirstLineHeadIndentAttributeName    = @"firstLineHeadIndent";
MSSTRING_CONST   REHeadIndentAttributeName             = @"headIndent";
MSSTRING_CONST   RETailIndentAttributeName             = @"tailIndent";
MSSTRING_CONST   RELineBreakModeAttributeName          = @"lineBreakMode";
MSSTRING_CONST   REMinimumLineHeightAttributeName      = @"minimumLineHeight";
MSSTRING_CONST   REMaximumLineHeightAttributeName      = @"maximumLineHeight";
MSSTRING_CONST   RELineHeightMultipleAttributeName     = @"lineHeightMultiple";
MSSTRING_CONST   REParagraphSpacingBeforeAttributeName = @"paragraphSpacingBefore";
MSSTRING_CONST   REHyphenationFactorAttributeName      = @"hyphenationFactor";
MSSTRING_CONST   RETabStopsAttributeName               = @"tabStops";
MSSTRING_CONST   REDefaultTabIntervalAttributeName     = @"defaultTabInterval";


static NSArray const * kAttributeKeys,
                     * kParagraphAttributeKeys,
                     * kAttributeNames,
                     * kParagraphAttributeNames;

static NSDictionary const * kAttributeKeyToNameIndex,
                          * kAttributeNameToKeyIndex,
                          * kParagraphAttributeKeyToNameIndex,
                          * kParagraphAttributeNameToKeyIndex;

static NSSet const * kJSONAttributeKeys,
                   * kJSONParagraphAttributeKeys,
                   * kJSONUnderlineStyleKeys,
                   * kJSONLineBreakModeKeys;

@interface TitleSetValueTransformer : NSValueTransformer @end
@interface TitleSetJSONValueTransformer : NSValueTransformer @end

@implementation ControlStateTitleSet

@synthesize suppressNormalStateAttributes = _suppressNormalStateAttributes;

+ (void)initialize
{
    if (self == [ControlStateTitleSet class])
    {
        kAttributeKeys = @[REFontAttributeKey,
                           REParagraphStyleAttributeKey,
                           REForegroundColorAttributeKey,
                           REBackgroundColorAttributeKey,
                           RELigatureAttributeKey,
                           REKernAttributeKey,
                           REStrikethroughStyleAttributeKey,
                           REUnderlineStyleAttributeKey,
                           REStrokeColorAttributeKey,
                           REStrokeWidthAttributeKey,
                           REShadowAttributeKey,
                           RETextEffectAttributeKey,
                           REBaselineOffsetAttributeKey,
                           REUnderlineColorAttributeKey,
                           REStrikethroughColorAttributeKey,
                           REObliquenessAttributeKey,
                           REExpansionAttributeKey,
                           RETitleTextAttributeKey];

        kParagraphAttributeKeys = @[RELineSpacingAttributeKey,
                                    REParagraphSpacingAttributeKey,
                                    RETextAlignmentAttributeKey,
                                    REFirstLineHeadIndentAttributeKey,
                                    REHeadIndentAttributeKey,
                                    RETailIndentAttributeKey,
                                    RELineBreakModeAttributeKey,
                                    REMinimumLineHeightAttributeKey,
                                    REMaximumLineHeightAttributeKey,
                                    RELineHeightMultipleAttributeKey,
                                    REParagraphSpacingBeforeAttributeKey,
                                    REHyphenationFactorAttributeKey,
                                    RETabStopsAttributeKey,
                                    REDefaultTabIntervalAttributeKey];

        kAttributeNames = @[NSFontAttributeName,
                            NSParagraphStyleAttributeName,
                            NSForegroundColorAttributeName,
                            NSBackgroundColorAttributeName,
                            NSLigatureAttributeName,
                            NSKernAttributeName,
                            NSStrikethroughStyleAttributeName,
                            NSUnderlineStyleAttributeName,
                            NSStrokeColorAttributeName,
                            NSStrokeWidthAttributeName,
                            NSShadowAttributeName,
                            NSTextEffectAttributeName,
                            NSBaselineOffsetAttributeName,
                            NSUnderlineColorAttributeName,
                            NSStrikethroughColorAttributeName,
                            NSObliquenessAttributeName,
                            NSExpansionAttributeName,
                            NullObject];

        kParagraphAttributeNames = @[RELineSpacingAttributeName,
                                     REParagraphSpacingAttributeName,
                                     RETextAlignmentAttributeName,
                                     REFirstLineHeadIndentAttributeName,
                                     REHeadIndentAttributeName,
                                     RETailIndentAttributeName,
                                     RELineBreakModeAttributeName,
                                     REMinimumLineHeightAttributeName,
                                     REMaximumLineHeightAttributeName,
                                     RELineHeightMultipleAttributeName,
                                     REParagraphSpacingBeforeAttributeName,
                                     REHyphenationFactorAttributeName,
                                     RETabStopsAttributeName,
                                     REDefaultTabIntervalAttributeName];

        kAttributeKeyToNameIndex = [NSDictionary dictionaryWithObjects:(NSArray *)kAttributeNames
                                                               forKeys:(NSArray *)kAttributeKeys];

        kAttributeNameToKeyIndex = [NSDictionary dictionaryWithObjects:(NSArray *)kAttributeKeys
                                                               forKeys:(NSArray *)kAttributeNames];

        kParagraphAttributeKeyToNameIndex =
            [NSDictionary dictionaryWithObjects:(NSArray *)kParagraphAttributeNames
                                        forKeys:(NSArray *)kParagraphAttributeKeys];

        kParagraphAttributeNameToKeyIndex =
            [NSDictionary dictionaryWithObjects:(NSArray *)kParagraphAttributeKeys
                                        forKeys:(NSArray *)kParagraphAttributeNames];

        kJSONAttributeKeys = [[[kAttributeKeys arrayByMappingToBlock:
                               ^id(id obj, NSUInteger idx) {
                                   return titleSetAttributeJSONKeyForKey(obj);
                               }] arrayByAddingObject:REFontAwesomeIconJSONKey] set];

        kJSONParagraphAttributeKeys = [[kParagraphAttributeKeys arrayByMappingToBlock:
                                        ^id(id obj, NSUInteger idx) {
                                            return titleSetAttributeJSONKeyForKey(obj);
                                        }] set];

        kJSONUnderlineStyleKeys = [@[REUnderlineStyleNoneJSONKey,
                                     REUnderlineStyleSingleJSONKey,
                                     REUnderlineStyleThickJSONKey,
                                     REUnderlineStyleDoubleJSONKey,
                                     REUnderlinePatternSolidJSONKey,
                                     REUnderlinePatternDotJSONKey,
                                     REUnderlinePatternDashJSONKey,
                                     REUnderlinePatternDashDotJSONKey,
                                     REUnderlinePatternDashDotDotJSONKey,
                                     REUnderlineByWordJSONKey] set];

        kJSONLineBreakModeKeys = [@[RELineBreakByWordWrappingJSONKey,
                                    RELineBreakByCharWrappingJSONKey,
                                    RELineBreakByClippingJSONKey,
                                    RELineBreakByTruncatingHeadJSONKey,
                                    RELineBreakByTruncatingTailJSONKey,
                                    RELineBreakByTruncatingMiddleJSONKey] set];

    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Helpers
////////////////////////////////////////////////////////////////////////////////


NSDictionary * storageDictionaryFromObject(id object)
{
    if (isStringKind(object))
        return [MSDictionary dictionaryWithObject:object forKey:RETitleTextAttributeKey];

    else if (isDictionaryKind(object))
        return[MSDictionary dictionaryWithValuesForKeys:(NSArray *)kAttributeKeys
                                                   fromDictionary:object];
    else if (isAttributedStringKind(object))
    {
        TitleSetValueTransformer * transformer = [TitleSetValueTransformer new];
        return [transformer transformedValue:object];
    }

    else return nil;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Validating attribute classes
////////////////////////////////////////////////////////////////////////////////


/*******************************************************************************
 Returns the appropriate class for an attribute key's value
 *******************************************************************************/
+ (Class)validClassForAttributeKey:(NSString *)key
{
    static dispatch_once_t onceToken;
    static NSMapTable const * index;
    dispatch_once(&onceToken,
                  ^{
                      Class   number    = [NSNumber class];
                      Class   string    = [NSString class];
                      Class   color     = [UIColor class];
                      Class   paragraph = [NSParagraphStyle class];
                      Class   shadow    = [NSShadow class];
                      Class   font      = [REFont class];
                      index = [NSMapTable weakToWeakObjectsMapTableFromDictionary:
                               @{REFontAttributeKey               : font,
                                 REParagraphStyleAttributeKey     : paragraph,
                                 REForegroundColorAttributeKey    : color,
                                 REBackgroundColorAttributeKey    : color,
                                 RELigatureAttributeKey           : number,
                                 REKernAttributeKey               : number,
                                 REStrikethroughStyleAttributeKey : number,
                                 REUnderlineStyleAttributeKey     : number,
                                 REStrokeColorAttributeKey        : color,
                                 REStrokeWidthAttributeKey        : number,
                                 REShadowAttributeKey             : shadow,
                                 RETextEffectAttributeKey         : string,
                                 REBaselineOffsetAttributeKey     : number,
                                 REUnderlineColorAttributeKey     : color,
                                 REStrikethroughColorAttributeKey : color,
                                 REObliquenessAttributeKey        : number,
                                 REExpansionAttributeKey          : number,
                                 RETitleTextAttributeKey          : string}];
                  });
    return index[key];
}

/*******************************************************************************
 Returns the appropriate class for a paragraph attribute key's value
 *******************************************************************************/
+ (Class)validClassForParagraphAttributeKey:(NSString *)key
{
    static dispatch_once_t onceToken;
    static NSMapTable const * index;
    dispatch_once(&onceToken,
                  ^{
                      Class   number = [NSNumber class];
                      Class   array  = [NSArray class];
                      index = [NSMapTable weakToWeakObjectsMapTableFromDictionary:
                               @{RELineSpacingAttributeKey            : number,
                                 REParagraphSpacingAttributeKey       : number,
                                 RETextAlignmentAttributeKey          : number,
                                 REFirstLineHeadIndentAttributeKey    : number,
                                 REHeadIndentAttributeKey             : number,
                                 RETailIndentAttributeKey             : number,
                                 RELineBreakModeAttributeKey          : number,
                                 REMinimumLineHeightAttributeKey      : number,
                                 REMaximumLineHeightAttributeKey      : number,
                                 RELineHeightMultipleAttributeKey     : number,
                                 REParagraphSpacingBeforeAttributeKey : number,
                                 REHyphenationFactorAttributeKey      : number,
                                 RETabStopsAttributeKey               : array,
                                 REDefaultTabIntervalAttributeKey     : number }];
                  });
    return index[key];
}

/*******************************************************************************
 Returns the appropriate class for an attribute name's value
 *******************************************************************************/
+ (Class)validClassForAttributeName:(NSString *)name
{
    static dispatch_once_t onceToken;
    static NSMapTable const * index;
    dispatch_once(&onceToken,
                  ^{
                      Class   font      = [UIFont class];
                      Class   number    = [NSNumber class];
                      Class   string    = [NSString class];
                      Class   color     = [UIColor class];
                      Class   paragraph = [NSParagraphStyle class];
                      Class   shadow    = [NSShadow class];
                      index = [NSMapTable weakToWeakObjectsMapTableFromDictionary:
                               @{NSFontAttributeName               : font,
                                 NSParagraphStyleAttributeName     : paragraph,
                                 NSForegroundColorAttributeName    : color,
                                 NSBackgroundColorAttributeName    : color,
                                 NSLigatureAttributeName           : number,
                                 NSKernAttributeName               : number,
                                 NSStrikethroughStyleAttributeName : number,
                                 NSUnderlineStyleAttributeName     : number,
                                 NSStrokeColorAttributeName        : color,
                                 NSStrokeWidthAttributeName        : number,
                                 NSShadowAttributeName             : shadow,
                                 NSTextEffectAttributeName         : string,
                                 NSBaselineOffsetAttributeName     : number,
                                 NSUnderlineColorAttributeName     : color,
                                 NSStrikethroughColorAttributeName : color,
                                 NSObliquenessAttributeName        : number,
                                 NSExpansionAttributeName          : number}];
                  });
    return index[name];
}

/*******************************************************************************
 Returns the appropriate class for a paragraph attribute name's value
 *******************************************************************************/
+ (Class)validClassForParagraphAttributeName:(NSString *)name
{
    static dispatch_once_t onceToken;
    static NSMapTable const * index;
    dispatch_once(&onceToken,
                  ^{
                      Class   number = [NSNumber class];
                      Class   array  = [NSArray class];
                      index = [NSMapTable weakToWeakObjectsMapTableFromDictionary:
                               @{RELineSpacingAttributeName            : number,
                                 REParagraphSpacingAttributeName       : number,
                                 RETextAlignmentAttributeName          : number,
                                 REFirstLineHeadIndentAttributeName    : number,
                                 REHeadIndentAttributeName             : number,
                                 RETailIndentAttributeName             : number,
                                 RELineBreakModeAttributeName          : number,
                                 REMinimumLineHeightAttributeName      : number,
                                 REMaximumLineHeightAttributeName      : number,
                                 RELineHeightMultipleAttributeName     : number,
                                 REParagraphSpacingBeforeAttributeName : number,
                                 REHyphenationFactorAttributeName      : number,
                                 RETabStopsAttributeName               : array,
                                 REDefaultTabIntervalAttributeName     : number }];
                  });
    return index[name];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Creation
////////////////////////////////////////////////////////////////////////////////


+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)context
                             withObjects:(NSDictionary *)objects
{
    TitleSetValueTransformer * transformer = [TitleSetValueTransformer new];
    ControlStateTitleSet * stateSet = [self controlStateSetInContext:context];
    [objects enumerateKeysAndObjectsUsingBlock:
     ^(NSString * key, id obj, BOOL *stop) { stateSet[key] = obj; }];

    return stateSet;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////

- (NSAttributedString *)_attributedStringForState:(id)state
{
    if (![ControlStateSet validState:state]) return nil;

    NSString * key = (isNumberKind(state)
                      ? [ControlStateSet propertyForState:UnsignedIntegerValue(state)]
                      : state);
    MSDictionary * attributes = [self valueForKey:key];
    if (!(_suppressNormalStateAttributes || [@"normal" isEqualToString:key]))
    {
        MSDictionary * defaults = [self valueForKey:@"normal"];
        if (attributes && defaults)
        {
            NSSet * keys = [[[defaults allKeys] set]
                            setByRemovingObjectsFromSet:[[attributes allKeys] set]];
            [attributes
             setValuesForKeysWithDictionary:[defaults dictionaryWithValuesForKeys:[keys allObjects]]];
        }
    }

    NSAttributedString * string = [[TitleSetValueTransformer new] transformedValue:attributes];
    return string;
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    NSArray * keys = [key keyPathComponents];

    switch ([keys count])
    {
        case 2: // set a specific attribute value for the specified state
        {
             NSString * stateKey = keys[0];
            if ([ControlStateSet validState:stateKey])
            {
                NSMutableDictionary * dictionary = [[self valueForKey:stateKey] mutableCopy];
                if (!dictionary) dictionary = [@{} mutableCopy];

                NSString * attributeKey = keys[1];
                if (   [kAttributeKeys containsObject:attributeKey]
                    && isKind(object, [ControlStateTitleSet validClassForAttributeKey:attributeKey]))
                {
                    dictionary[attributeKey] = object;
                    [self setValue:dictionary forKey:stateKey];
                }
            }
            break;
        }
        case 1: // create attribute dictionary using object and set via super
        {
            if ([ControlStateSet validState:key])
            {
                NSDictionary * dictionary = storageDictionaryFromObject(object);
                [self setValue:dictionary forKey:key];
            }
            break;
        }
        default: // invalid key path
        {
            ThrowInvalidArgument(key, contains illegal key path);
            break;
        }
    }
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    NSArray * keys = [key keyPathComponents];
    switch ([keys count])
    {
        case 2: // return an attribute value from the attributes of the specified state
        {
            NSString * stateKey = keys[0];
            if ([ControlStateSet validState:stateKey])
            {
                NSDictionary * dictionary = [self valueForKey:stateKey];
                if (dictionary)
                {
                    NSString * attributeKey = keys[1];
                    if ([kAttributeKeys containsObject:attributeKey])
                        return dictionary[attributeKey];
                }
            }
            break;
        }
        case 1: // return an attributed string with attributes for specified state
        {
            return [self _attributedStringForState:key];
        }
        default: // invalid key path
        {
            ThrowInvalidArgument(key, contains illegal key path);
            break;
        }
    }
    return nil;
}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)state
{
    if ([ControlStateSet validState:@(state)])
    {
        // Make sure we have a dictionary from whatever we are passed
        NSDictionary * dictionary = storageDictionaryFromObject(object);
        [self setValue:dictionary forKey:[ControlStateSet propertyForState:state]];
    }

    else
        ThrowInvalidArgument(state, is not a valid state);
}

- (id)objectAtIndexedSubscript:(NSUInteger)state
{
    if (![ControlStateTitleSet validState:@(state)])
    {
        ThrowInvalidArgument(state, is not a valid state);
        return nil;
    }
    else
        return [self _attributedStringForState:@(state)];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////

- (void)importDictionary:(NSDictionary *)dictionary forKey:(NSString *)key
{
    TitleSetJSONValueTransformer * transformer = [TitleSetJSONValueTransformer new];
    [self setValue:[transformer reverseTransformedValue:dictionary] forKey:key];
}


- (void)importNormal:(NSDictionary *)data
{
    [self importDictionary:data forKey:@"normal"];
}

- (void)importHighlighted:(NSDictionary *)data
{
    [self importDictionary:data forKey:@"highlighted"];
}

- (void)importDisabled:(NSDictionary *)data
{
    [self importDictionary:data forKey:@"disabled"];
}

- (void)importHighlightedAndDisabled:(NSDictionary *)data
{
    [self importDictionary:data forKey:@"highlightedAndDisabled"];
}

- (void)importSelected:(NSDictionary *)data
{
    [self importDictionary:data forKey:@"selected"];
}

- (void)importHighlightedAndSelected:(NSDictionary *)data
{
    [self importDictionary:data forKey:@"highlightedAndSelected"];
}

- (void)importDisabledAndSelected:(NSDictionary *)data
{
    [self importDictionary:data forKey:@"disabledAndSelected"];
}

- (void)importSelectedHighlightedAndDisabled:(NSDictionary *)data
{
    [self importDictionary:data forKey:@"selectedHighlightedAndDisabled"];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////


- (MSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];
    TitleSetJSONValueTransformer * transformer = [TitleSetJSONValueTransformer new];

    for (NSString * key in [ControlStateSet validProperties])
    {
        MSDictionary * dictionaryForKey = [self valueForKey:key];
        if (dictionaryForKey)
        {
            id value = CollectionSafe([transformer transformedValue:dictionaryForKey]);
            dictionary[key] = value;
        }
    }

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Debugging
////////////////////////////////////////////////////////////////////////////////


- (MSDictionary *)deepDescriptionDictionary
{
    ControlStateTitleSet * stateSet = [self faultedObject];
    assert(stateSet);

    NSString *(^attributesDescription)(NSDictionary *) =
    ^(NSDictionary * attributes)
    {
        NSDictionary * attributeKeys = @{ REFontAttributeKey               : @0,
                                          REParagraphStyleAttributeKey     : @2,
                                          REForegroundColorAttributeKey    : @3,
                                          REBackgroundColorAttributeKey    : @4,
                                          RELigatureAttributeKey           : @5,
                                          REKernAttributeKey               : @6,
                                          REStrikethroughStyleAttributeKey : @7,
                                          REUnderlineStyleAttributeKey     : @8,
                                          REStrokeColorAttributeKey        : @9,
                                          REStrokeWidthAttributeKey        : @10,
                                          REShadowAttributeKey             : @11,
                                          RETitleTextAttributeKey          : @12,
                                          RETextEffectAttributeKey         : @13,
                                          REBaselineOffsetAttributeKey     : @14,
                                          REUnderlineColorAttributeKey     : @15,
                                          REStrikethroughColorAttributeKey : @16,
                                          REObliquenessAttributeKey        : @17,
                                          REExpansionAttributeKey          : @18 };

        if (!attributes) return @"nil";
        NSString * description = nil;

        MSDictionary * attributeDescriptions = [MSDictionary dictionaryWithCapacity:[attributes count]];
        for (NSString * attribute in attributes)
        {
            NSNumber * attributeIndex = attributeKeys[attribute];
            if (!attributeIndex) continue;
            id attributeValue = NilSafe(attributes[attribute]);
            if (!attributeValue) continue;
            switch ([attributeIndex shortValue])
            {
                case 0: // font name
                    attributeDescriptions[@"fontName"] = attributeValue;
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

                case 13: // text effect
                    attributeDescriptions[@"text effect"] = ([attributeValue isEqualToString:NSTextEffectLetterpressStyle]
                                                             ? @"letter press"
                                                             : @"none");
                    break;

                case 14: // baseline offset
                    attributeDescriptions[@"baseline offset"] = [(NSNumber *)attributeValue stringValue];
                    break;

                case 15: // underline color
                    attributeDescriptions[@"underline color"] = NSStringFromUIColor((UIColor *)attributeValue);
                    break;

                case 16: // strikethrough color
                    attributeDescriptions[@"strikethrough color"] = NSStringFromUIColor((UIColor *)attributeValue);
                    break;

                case 17: // obliqueness
                    attributeDescriptions[@"obliqueness"] = [(NSNumber *)attributeValue stringValue];
                    break;

                case 18: // expansion
                    attributeDescriptions[@"expansion"] = [(NSNumber *)attributeValue stringValue];
                    break;

                default:
                    assert(NO);
                    break;
            }
        }

        description = [attributeDescriptions formattedDescriptionWithOptions:0 levelIndent:1];
        return (description ?: @"nil");
    };

    MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

    NSString * normalString                         = attributesDescription([stateSet valueForKey:@"normal"]);
    NSString * selectedString                       = attributesDescription([stateSet valueForKey:@"selected"]);
    NSString * highlightedString                    = attributesDescription([stateSet valueForKey:@"highlighted"]);
    NSString * disabledString                       = attributesDescription([stateSet valueForKey:@"disabled"]);
    NSString * highlightedAndSelectedString         = attributesDescription([stateSet valueForKey:@"highlightedAndSelected"]);
    NSString * highlightedAndDisabledString         = attributesDescription([stateSet valueForKey:@"highlightedAndDisabled"]);
    NSString * disabledAndSelectedString            = attributesDescription([stateSet valueForKey:@"disabledAndSelected"]);
    NSString * selectedHighlightedAndDisabledString = attributesDescription([stateSet valueForKey:@"selectedHighlightedAndDisabled"]);

    dd[@"normal"]                         = normalString;
    dd[@"selected"]                       = selectedString;
    dd[@"highlighted"]                    = highlightedString;
    dd[@"disabled"]                       = disabledString;
    dd[@"highlightedAndSelected"]         = highlightedAndSelectedString;
    dd[@"highlightedAndDisabled"]         = highlightedAndDisabledString;
    dd[@"disabledAndSelected"]            = disabledAndSelectedString;
    dd[@"selectedHighlightedAndDisabled"] = selectedHighlightedAndDisabledString;

    return (MSDictionary *)dd;
}

/*
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
*/

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Value transformers
////////////////////////////////////////////////////////////////////////////////

@implementation TitleSetValueTransformer

+ (BOOL)allowsReverseTransformation { return YES; }

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

             [string addAttribute:kAttributeKeyToNameIndex[key]
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
        for (NSString * attributeName in kAttributeNames)
        {
            NSString * key = kAttributeNameToKeyIndex[attributeName];
            dictionary[key] = CollectionSafe([self transformedValue:attributes[attributeName]]);
        }

        [dictionary compact];

        return dictionary;
    }

}

@end

//FIXME: Underline Style keeps text from showing up, also need to test line break mode

@implementation TitleSetJSONValueTransformer

//+ (Class)transformedValueClass { return [NSObject class]; }

+ (BOOL)allowsReverseTransformation { return YES; }

- (id)transformedValue:(id)value
{

    static MSDictionary *(^dictionaryFromParagraphStyle)(NSParagraphStyle*) =
    ^MSDictionary *(NSParagraphStyle *style)
    {
        if (!style) return nil;

        MSDictionary * styleDictionary = [MSDictionary dictionary];

        [[style dictionaryWithValuesForKeys:(NSArray *)kParagraphAttributeNames]
         enumerateKeysAndObjectsUsingBlock:
         ^(NSString * key, id obj, BOOL *stop)
         {
             if ([key isEqualToString:RETabStopsAttributeName]) return; // tab stop export unsupported

             NSString * jsonKey = titleSetAttributeJSONKeyForName(key);

             if (   ([key isEqualToString:RETextAlignmentAttributeName] && ![obj isEqualToNumber:@4])
                 || (![key isEqualToString:RETextAlignmentAttributeName] && ![obj isEqualToNumber:@0]))
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
                     dictionary[jsonKey] = titleSetUnderlineStyleJSONValueForStyle(IntegerValue(obj));

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

- (id)reverseTransformedValue:(id)value
{
    if (isStringKind(value))
    {
        NSString * string = (NSString *)value;

        if ([string isEqualToString:RETextEffectLetterPressJSONKey])
            return NSTextEffectLetterpressStyle;

        if ([[UIFont fontAwesomeIconNames] containsObject:string])
            return [UIFont fontAwesomeIconForName:string];

        if (   [kJSONUnderlineStyleKeys containsObject:string]
            || (   [string rangeOfString:@"-"].location != NSNotFound
                && [[[string componentsSeparatedByString:@"-"] set]
                    isSubsetOfSet:(NSSet *)kJSONUnderlineStyleKeys]
                )
            )
            return @(titleSetUnderlineStyleForJSONKey(string));

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

        if ([kJSONAttributeKeys intersectsSet:[[dictionary allKeys] set]])
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

        else if ([kJSONParagraphAttributeKeys intersectsSet:[[dictionary allKeys] set]])
        {
            // transform into paragraph style
            NSMutableParagraphStyle * paragraphStyle = [NSMutableParagraphStyle new];
            for (NSString * key in dictionary)
            {
                id v = dictionary[key];
                NSString * mappedKey = titleSetAttributeKeyForJSONKey(key);

                if ([mappedKey isEqualToString:RETextAlignmentAttributeKey])
                    v = @(titleSetAlignmentForJSONKey(v));

                else if ([mappedKey isEqualToString:RELineBreakModeAttributeKey])
                    v = @(titleSetLineBreakModeForJSONKey(v));

                if (v && mappedKey)
                    [paragraphStyle setValue:v forKey:kParagraphAttributeKeyToNameIndex[mappedKey]];
            }

            return paragraphStyle;
        }
    }

    return value;
}

@end

