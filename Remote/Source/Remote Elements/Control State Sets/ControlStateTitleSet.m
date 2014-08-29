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

// @synthesize suppressNormalStateAttributes = _suppressNormalStateAttributes;


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

        if (!titleAttributes)
          titleAttributes = [TitleAttributes createInContext:self.managedObjectContext];

        NSString * attributeKey = keys[1];

        if (  [[TitleAttributes propertyKeys] containsObject:attributeKey]
           && isKind(object, [TitleAttributes validClassForProperty:attributeKey]))

          [titleAttributes setValue:object forKey:attributeKey];

      }

      break;
    }

    case 1:     // create attribute dictionary using object and set via super
      if ([ControlStateSet validState:key] && [object isKindOfClass:[TitleAttributes class]])
        [self setValue:object forKey:[ControlStateSet attributeKeyFromKey:key]];
      break;

    default:     // invalid key path
      ThrowInvalidArgument(key, "contains illegal key path");

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
      return self[[ControlStateSet stateForProperty:key]];

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

  NSAttributedString * string     = nil;
  MSDictionary       * attributes = nil;

  if ([ControlStateSet validState:@(state)]) {

    NSString * key = [ControlStateSet propertyForState:@(state)];
    attributes = ((TitleAttributes *)[self valueForKey:key]).attributes;

    if (![@"normal" isEqualToString:key]) {

      MSDictionary * defaultAttributes = ((TitleAttributes *)[self valueForKey:@"normal"]).attributes;

      if (attributes && defaultAttributes)
        [attributes setValuesForKeysWithDictionary:defaultAttributes];
    }

    if (attributes) {

      NSString * text = attributes[RETitleTextAttributeKey];

      if (text) {

        [attributes removeObjectForKey:RETitleTextAttributeKey];
        string = [NSAttributedString attributedStringWithString:text attributes:attributes];

      }

    }

  }

  return string;
}

- (NSAttributedString *)objectAtIndex:(NSUInteger)state {

  NSAttributedString * string = nil;

  if ([ControlStateSet validState:@(state)]) {

    NSString        * key             = [ControlStateSet propertyForState:@(state)];
    TitleAttributes * titleAttributes = [self valueForKey:key];
    MSDictionary    * attributes      = titleAttributes.attributes;

    if (attributes) {
      NSString * text = attributes[RETitleTextAttributeKey];

      if (text) {

        [attributes removeObjectForKey:RETitleTextAttributeKey];
        string = [NSAttributedString attributedStringWithString:text attributes:attributes];

      }

    }

  }

  return string;
}

- (id)objectForKey:(NSString *)key {
  return [[key keyPathComponents] count] > 1 ? self[key] : [super objectForKey:key];
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
    SafeSetValueForKey(((TitleAttributes *)[self valueForKey:key]).JSONDictionary, key, dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

@end
