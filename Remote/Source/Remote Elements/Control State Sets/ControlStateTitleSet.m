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
#import "RemoteElementKeys.h"
#import "REFont.h"
#import "StringAttributesValueTransformer.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;

#pragma unused(ddLogLevel,msLogContext)


@implementation ControlStateTitleSet

@synthesize suppressNormalStateAttributes = _suppressNormalStateAttributes;


////////////////////////////////////////////////////////////////////////////////
#pragma mark Helpers
////////////////////////////////////////////////////////////////////////////////


NSDictionary*storageDictionaryFromObject(id object) {
  if (isStringKind(object))
    return [MSDictionary dictionaryWithObject:object forKey:RETitleTextAttributeKey];

  else if (isDictionaryKind(object))
    return [MSDictionary dictionaryWithValuesForKeys:(NSArray *)remoteElementAttributeKeys()
                                      fromDictionary:object];
  else if (isAttributedStringKind(object))
    return [[StringAttributesValueTransformer new] transformedValue:object];

  else return nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Validating attribute classes
////////////////////////////////////////////////////////////////////////////////


/*******************************************************************************
   Returns the appropriate class for an attribute key's value
*******************************************************************************/
+ (Class)validClassForAttributeKey:(NSString *)key {
  static dispatch_once_t    onceToken;
  static NSMapTable const * index;

  dispatch_once(&onceToken,
                ^{
    Class number    = [NSNumber class];
    Class string    = [NSString class];
    Class color     = [UIColor class];
    Class paragraph = [NSParagraphStyle class];
    Class shadow    = [NSShadow class];
    Class font      = [REFont class];
    index = [NSMapTable weakToWeakObjectsMapTableFromDictionary:
             @{ REFontAttributeKey               : font,
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
                RETitleTextAttributeKey          : string }];
  });

  return index[key];
}

/*******************************************************************************
   Returns the appropriate class for a paragraph attribute key's value
*******************************************************************************/
+ (Class)validClassForParagraphAttributeKey:(NSString *)key {
  static dispatch_once_t    onceToken;
  static NSMapTable const * index;

  dispatch_once(&onceToken,
                ^{
    Class number = [NSNumber class];
    Class array  = [NSArray class];
    index = [NSMapTable weakToWeakObjectsMapTableFromDictionary:
             @{ RELineSpacingAttributeKey            : number,
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
+ (Class)validClassForAttributeName:(NSString *)name {
  static dispatch_once_t    onceToken;
  static NSMapTable const * index;

  dispatch_once(&onceToken,
                ^{
    Class font      = [UIFont class];
    Class number    = [NSNumber class];
    Class string    = [NSString class];
    Class color     = [UIColor class];
    Class paragraph = [NSParagraphStyle class];
    Class shadow    = [NSShadow class];
    index = [NSMapTable weakToWeakObjectsMapTableFromDictionary:
             @{ NSFontAttributeName               : font,
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
                NSExpansionAttributeName          : number }];
  });

  return index[name];
}

/*******************************************************************************
   Returns the appropriate class for a paragraph attribute name's value
*******************************************************************************/
+ (Class)validClassForParagraphAttributeName:(NSString *)name {
  static dispatch_once_t    onceToken;
  static NSMapTable const * index;

  dispatch_once(&onceToken,
                ^{
    Class number = [NSNumber class];
    Class array  = [NSArray class];
    index = [NSMapTable weakToWeakObjectsMapTableFromDictionary:
             @{ RELineSpacingAttributeName            : number,
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
                             withObjects:(NSDictionary *)objects {
  ControlStateTitleSet * stateSet = [self controlStateSetInContext:context];

  [objects enumerateKeysAndObjectsUsingBlock:
   ^(NSString * key, id obj, BOOL * stop) { stateSet[key] = obj; }];

  return stateSet;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////

- (NSAttributedString *)_attributedStringForState:(id)state {
  if (![ControlStateSet validState:state]) return nil;

  NSString * key = (isNumberKind(state)
                    ? [ControlStateSet propertyForState:UnsignedIntegerValue(state)]
                    : state);
  MSDictionary * attributes = [self valueForKey:key];

  if (!(_suppressNormalStateAttributes || [@"normal" isEqualToString:key])) {
    MSDictionary * defaults = [self valueForKey:@"normal"];

    if (attributes && defaults) {
      NSSet * keys = [[[defaults allKeys] set]
                      setByRemovingObjectsFromSet:[[attributes allKeys] set]];

      [attributes
             setValuesForKeysWithDictionary:[defaults dictionaryWithValuesForKeys:[keys allObjects]]];
    }
  }

  return [[StringAttributesValueTransformer new] transformedValue:attributes];
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key {
  NSArray * keys = [key keyPathComponents];

  switch ([keys count]) {
    case 2:     // set a specific attribute value for the specified state
    {
      NSString * stateKey = keys[0];

      if ([ControlStateSet validState:stateKey]) {
        NSMutableDictionary * dictionary = [[self valueForKey:stateKey] mutableCopy];

        if (!dictionary) dictionary = [@{} mutableCopy];

        NSString * attributeKey = keys[1];

        if (  [remoteElementAttributeKeys() containsObject:attributeKey]
           && isKind(object, [ControlStateTitleSet validClassForAttributeKey:attributeKey]))
        {
          dictionary[attributeKey] = object;
          [self setValue:dictionary forKey:stateKey];
        }
      }

      break;
    }

    case 1:     // create attribute dictionary using object and set via super
    {
      if ([ControlStateSet validState:key]) {
        NSDictionary * dictionary = storageDictionaryFromObject(object);

        [self setValue:dictionary forKey:key];
      }

      break;
    }

    default:     // invalid key path
    {
      ThrowInvalidArgument(key, contains illegal key path);
      break;
    }
  }
}

- (id)objectForKeyedSubscript:(NSString *)key {
  NSArray * keys = [key keyPathComponents];

  switch ([keys count]) {
    case 2:     // return an attribute value from the attributes of the specified state
    {
      NSString * stateKey = keys[0];

      if ([ControlStateSet validState:stateKey]) {
        NSDictionary * dictionary = [self valueForKey:stateKey];

        if (dictionary) {
          NSString * attributeKey = keys[1];

          if ([remoteElementAttributeKeys() containsObject:attributeKey])
            return dictionary[attributeKey];
        }
      }

      break;
    }

    case 1:     // return an attributed string with attributes for specified state
    {
      return [self _attributedStringForState:key];
    }

    default:     // invalid key path
    {
      ThrowInvalidArgument(key, contains illegal key path);
      break;
    }
  }

  return nil;
}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)state {
  if ([ControlStateSet validState:@(state)]) {
    // Make sure we have a dictionary from whatever we are passed
    NSDictionary * dictionary = storageDictionaryFromObject(object);

    [self setValue:dictionary forKey:[ControlStateSet propertyForState:state]];
  } else
    ThrowInvalidArgument(state, is not a valid state);
}

- (id)objectAtIndexedSubscript:(NSUInteger)state {
  if (![ControlStateTitleSet validState:@(state)]) {
    ThrowInvalidArgument(state, is not a valid state);

    return nil;
  } else
    return [self _attributedStringForState:@(state)];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////


- (void)updateWithData:(NSDictionary *)data {
  NSManagedObjectContext * moc = self.managedObjectContext;

  [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
    if ([ControlStateSet validState:key] && isDictionaryKind(obj)) {
      [self importDictionary:obj forKey:key];
    }
  }];
}

- (void)importDictionary:(NSDictionary *)dictionary forKey:(NSString *)key {
  [self setValue:[[StringAttributesJSONValueTransformer new] reverseTransformedValue:dictionary]
          forKey:key];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Exporting
////////////////////////////////////////////////////////////////////////////////


- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];

  // remove entries for state dictionaries
  for (NSString * key in [dictionary copy])
    if ([ControlStateSet validState:[key keyPathComponents][0]])
      [dictionary removeObjectForKey:key];



  for (NSString * key in [ControlStateSet validProperties])
    dictionary[key] = CollectionSafe([[StringAttributesJSONValueTransformer new]
                                      transformedValue:[self valueForKey:key]]);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Debugging
////////////////////////////////////////////////////////////////////////////////


- (MSDictionary *)deepDescriptionDictionary {
  ControlStateTitleSet * stateSet = [self faultedObject];

  assert(stateSet);

  NSString *(^attributesDescription)(NSDictionary *) = ^(NSDictionary * attributes) {
    NSDictionary * attributeKeys = @{
      REFontAttributeKey               : @0,
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
      REExpansionAttributeKey          : @18
    };

    if (!attributes) return @"nil";

    NSString * description = nil;

    MSDictionary * attributeDescriptions = [MSDictionary dictionaryWithCapacity:[attributes count]];

    for (NSString * attribute in attributes) {
      NSNumber * attributeIndex = attributeKeys[attribute];

      if (!attributeIndex) continue;

      id attributeValue = NilSafe(attributes[attribute]);

      if (!attributeValue) continue;

      switch ([attributeIndex shortValue]) {
        case 0:         // font name
          attributeDescriptions[@"fontName"] = attributeValue;
          break;

        case 2:         // paragraph style
        {
          NSParagraphStyle * paragraphStyle       = (NSParagraphStyle *)attributeValue;
          NSString         * paragraphStyleString = $(@"alignment:%@\nlineSpacing:%@\nlineBreakMode:%@",
                                                      NSStringFromNSTextAlignment(paragraphStyle.alignment),
                                                      [@(paragraphStyle.lineSpacing)stringValue],
                                                      NSStringFromNSLineBreakMode(paragraphStyle.lineBreakMode));
          attributeDescriptions[@"paragraph"] = paragraphStyleString;
        }   break;

        case 3:         // foreground color
          attributeDescriptions[@"foreground color"] = NSStringFromUIColor((UIColor *)attributeValue);
          break;

        case 4:         // background color
          attributeDescriptions[@"background color"] = NSStringFromUIColor((UIColor *)attributeValue);
          break;

        case 5:         // ligature
          attributeDescriptions[@"ligature"] = [(NSNumber *)attributeValue stringValue];
          break;

        case 6:         // kern
          attributeDescriptions[@"kern"] = [(NSNumber *)attributeValue stringValue];
          break;

        case 7:         // strikethrough style
          attributeDescriptions[@"strikethrough"] = NSStringFromBOOL([(NSNumber *)attributeValue boolValue]);
          break;

        case 8:         // underline style
          attributeDescriptions[@"underline"] = NSStringFromBOOL([(NSNumber *)attributeValue boolValue]);
          break;

        case 9:         // stroke color
          attributeDescriptions[@"stroke color"] = NSStringFromUIColor((UIColor *)attributeValue);
          break;

        case 10:         // stroke width
          attributeDescriptions[@"stroke width"] = [(NSNumber *)attributeValue stringValue];
          break;

        case 11:         // shadow
          attributeDescriptions[@"shadow"] = $(@"offset = %@, blur = %f, %@",
                                               NSStringFromCGSize(((NSShadow *)attributeValue).shadowOffset),
                                               ((NSShadow *)attributeValue).shadowBlurRadius,
                                               NSStringFromUIColor(((NSShadow *)attributeValue).shadowColor));
          break;

        case 12:         // title text
          attributeDescriptions[@"title text"] = attributeValue;
          break;

        case 13:         // text effect
          attributeDescriptions[@"text effect"] = ([attributeValue isEqualToString:NSTextEffectLetterpressStyle]
                                                   ? @"letter press"
                                                   : @"none");
          break;

        case 14:         // baseline offset
          attributeDescriptions[@"baseline offset"] = [(NSNumber *)attributeValue stringValue];
          break;

        case 15:         // underline color
          attributeDescriptions[@"underline color"] = NSStringFromUIColor((UIColor *)attributeValue);
          break;

        case 16:         // strikethrough color
          attributeDescriptions[@"strikethrough color"] = NSStringFromUIColor((UIColor *)attributeValue);
          break;

        case 17:         // obliqueness
          attributeDescriptions[@"obliqueness"] = [(NSNumber *)attributeValue stringValue];
          break;

        case 18:         // expansion
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
