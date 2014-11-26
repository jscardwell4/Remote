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
//#import "REFont.h"
#import "Remote-Swift.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@interface ControlStateTitleSet ()
@property (nonatomic) TitleAttributes * normal;
@property (nonatomic) TitleAttributes * disabled;
@property (nonatomic) TitleAttributes * selected;
@property (nonatomic) TitleAttributes * highlighted;
@property (nonatomic) TitleAttributes * highlightedDisabled;
@property (nonatomic) TitleAttributes * highlightedSelected;
@property (nonatomic) TitleAttributes * highlightedSelectedDisabled;
@property (nonatomic) TitleAttributes * selectedDisabled;
@end

@implementation ControlStateTitleSet

@dynamic normal;
@dynamic disabled, selected, selectedDisabled;
@dynamic highlighted, highlightedDisabled, highlightedSelected;
@dynamic highlightedSelectedDisabled;

// @synthesize suppressNormalStateAttributes = _suppressNormalStateAttributes;


////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////


- (void)setObject:(TitleAttributes *)object forKeyedSubscript:(NSString *)key {
  [super setObject:object forKeyedSubscript:key];
}

- (id)objectForKeyedSubscript:(NSString *)key {

  NSArray * keys = [key keyPathComponents];

  switch ([keys count]) {
    case 2:     // return an attribute value from the attributes of the specified state
    {
      assert(NO);
      return nil;
//      NSString * stateKey = keys[0];
//
//      if ([ControlStateSet validState:stateKey]) {
//        TitleAttributes * titleAttributes = [self valueForKey:stateKey];
//
//        NSString * attributeKey = keys[1];
//
//        if ([[TitleAttributes propertyKeys] containsObject:attributeKey])
//          return [titleAttributes valueForKey:attributeKey];
//
//      }

    }  break;

    case 1:     // return an attributed string with attributes for specified state
      return self[[ControlStateSet stateForProperty:key]];

    default:     // invalid key path
      ThrowInvalidArgument(key, contains illegal key path);
  }

  return nil;
}

- (void)setObject:(TitleAttributes *)object atIndexedSubscript:(NSUInteger)state {
  [super setObject:object atIndexedSubscript:state];
}

- (NSAttributedString *)objectAtIndexedSubscript:(NSUInteger)state {

  NSAttributedString * string = nil;

  TitleAttributes * attributes = [super objectAtIndexedSubscript:state];
  if (attributes) {
    string = (state ? [attributes stringWithFillers:self.normal.attributes] : attributes.string);
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
    SafeSetValueForKey(((TitleAttributes *)[self valueForKey:key]).JSONDictionary, key, dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

@end
