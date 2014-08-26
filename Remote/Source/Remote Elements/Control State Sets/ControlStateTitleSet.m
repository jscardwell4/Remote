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
#import "TitleAttributes.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;

#pragma unused(ddLogLevel,msLogContext)

@implementation ControlStateTitleSet

@synthesize suppressNormalStateAttributes = _suppressNormalStateAttributes;


////////////////////////////////////////////////////////////////////////////////
#pragma mark Creation
////////////////////////////////////////////////////////////////////////////////


+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)context
                             withObjects:(NSDictionary *)objects {
  if (!context) return nil;

  ControlStateTitleSet * stateSet = [self controlStateSetInContext:context];

  [objects enumerateKeysAndObjectsUsingBlock:^(NSString * key, id obj, BOOL * stop) {
     stateSet[key] = [TitleAttributes importObjectFromData:obj context:context];
   }];

  return stateSet;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////


- (void)setObject:(id)object forKeyedSubscript:(NSString *)key {
  NSArray * keys = [key keyPathComponents];

  switch ([keys count]) {
    case 2:     // set a specific attribute value for the specified state
    {
      NSString * stateKey = keys[0];

      if ([ControlStateSet validState:stateKey]) {

        TitleAttributes * titleAttributes = self[stateKey];

        if (!titleAttributes) titleAttributes = [TitleAttributes createInContext:self.managedObjectContext];

        NSString * attributeKey = keys[1];

        if (  [[TitleAttributes propertyKeys] containsObject:attributeKey]
           && isKind(object, [TitleAttributes validClassForProperty:attributeKey]))
        {
          [titleAttributes setValue:object forKey:attributeKey];
        }
      }

      break;
    }

    case 1:     // create attribute dictionary using object and set via super
    {
      if ([ControlStateSet validState:key] && [object isKindOfClass:[TitleAttributes class]]) {
        [self setValue:object forKey:[ControlStateSet attributeKeyFromKey:key]];
      }

      break;
    }

    default:     // invalid key path
    {
      ThrowInvalidArgument(key, "contains illegal key path");
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
        TitleAttributes * titleAttributes = [self valueForKey:stateKey];

        NSString * attributeKey = keys[1];
        if ([[TitleAttributes propertyKeys] containsObject:attributeKey])
          return [titleAttributes valueForKey:attributeKey];

      }

    }  break;

    case 1:     // return an attributed string with attributes for specified state
    {
      if ([ControlStateSet validState:key])
        return [self valueForKey:key];
    }  break;

    default:     // invalid key path
      ThrowInvalidArgument(key, contains illegal key path);
  }

  return nil;
}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)state {
  if ([ControlStateSet validState:@(state)])
    [self setObject:object forKeyedSubscript:[ControlStateSet attributeKeyFromKey:@(state)]];
}

- (NSAttributedString *)objectAtIndexedSubscript:(NSUInteger)state {

  NSAttributedString * string = nil;

  if ([ControlStateSet validState:@(state)]) {

    NSString * key = [ControlStateSet propertyForState:state];
    TitleAttributes * attributes = [self valueForKey:key];
    MSDictionary * values = [MSDictionary dictionaryWithDictionary:
                             [attributes dictionaryWithValuesForKeys:[TitleAttributes propertyKeys]]];
    [values compact];

    if (!(_suppressNormalStateAttributes || [@"normal" isEqualToString:key])) {
      TitleAttributes * defaults = [self valueForKey:@"normal"];

      if (attributes && defaults) {

        NSArray * keys = [[[[TitleAttributes propertyKeys] set]
                           setByRemovingObjectsFromArray:[values allKeys]] allObjects];

        [values setValuesForKeysWithDictionary:[defaults dictionaryWithValuesForKeys:keys]];

      }
    }

    string = [[StringAttributesValueTransformer new] transformedValue:values];

  }

  return string;

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////


- (void)updateWithData:(NSDictionary *)data {
  NSManagedObjectContext * moc = self.managedObjectContext;

  [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
    if ([ControlStateSet validState:key] && isDictionaryKind(obj))
      self[key] = [TitleAttributes importObjectFromData:obj context:moc];
  }];
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
    dictionary[key] = CollectionSafe(((TitleAttributes *)[self valueForKey:key]).JSONDictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Debugging
////////////////////////////////////////////////////////////////////////////////


/*
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
  NSString * highlightedSelectedString         = attributesDescription([stateSet valueForKey:@"highlightedSelected"]);
  NSString * highlightedDisabledString         = attributesDescription([stateSet valueForKey:@"highlightedDisabled"]);
  NSString * disabledSelectedString            = attributesDescription([stateSet valueForKey:@"disabledSelected"]);
  NSString * selectedHighlightedDisabledString = attributesDescription([stateSet valueForKey:@"selectedHighlightedDisabled"]);

  dd[@"normal"]                         = normalString;
  dd[@"selected"]                       = selectedString;
  dd[@"highlighted"]                    = highlightedString;
  dd[@"disabled"]                       = disabledString;
  dd[@"highlightedSelected"]         = highlightedSelectedString;
  dd[@"highlightedDisabled"]         = highlightedDisabledString;
  dd[@"disabledSelected"]            = disabledSelectedString;
  dd[@"selectedHighlightedDisabled"] = selectedHighlightedDisabledString;

  return (MSDictionary *)dd;
}
*/

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
