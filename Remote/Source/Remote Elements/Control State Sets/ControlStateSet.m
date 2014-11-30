//
// ControlStateSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ControlStateSet.h"
#import "CoreDataManager.h"

@interface ControlStateSet (Abstract)
@property (nonatomic) id normal;
@property (nonatomic) id disabled;
@property (nonatomic) id selected;
@property (nonatomic) id highlighted;
@property (nonatomic) id highlightedDisabled;
@property (nonatomic) id highlightedSelected;
@property (nonatomic) id highlightedSelectedDisabled;
@property (nonatomic) id selectedDisabled;
@end

@implementation ControlStateSet


/**
 *
 * valid UIControlState bit combinations:
 * UIControlStateNormal: 0
 * UIControlStateHighlighted: 1
 * UIControlStateDisabled: 2
 * UIControlStateHighlighted|UIControlStateDisabled: 3
 * UIControlStateSelected: 4
 * UIControlStateHighlighted|UIControlStateSelected: 5
 * UIControlStateDisabled|UIControlStateSelected: 6
 * UIControlStateSelected|UIControlStateHighlighted|UIControlStateDisabled: 7
 *
 */
+ (BOOL)validState:(id)state {
  static const NSSet   * validNumbers, * validKeys;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    validNumbers = [@[@0, @1, @2, @3, @4, @5, @6, @7] set];
    validKeys    = [@[@"normal",
                      @"highlighted",
                      @"disabled",
                      @"highlightedDisabled",
                      @"selected",
                      @"highlightedSelected",
                      @"selectedDisabled",
                      @"highlightedSelectedDisabled"] set];
  });

  return (isNumberKind(state)
          ? [validNumbers containsObject:state]
          : (isStringKind(state)
             ? [validKeys containsObject:state]
             : NO
          )
  );
}

+ (NSString *)attributeKeyFromKey:(id)key {
  return ([self validState:key]
          ? (isStringKind(key) ? key : [self propertyForState:key])
          : nil) ;
}

+ (NSString *)propertyForState:(NSNumber *)state {

  static const NSDictionary * states;
  static dispatch_once_t      onceToken;

  dispatch_once(&onceToken, ^{
    states = @{ @0 : @"normal",
                @1 : @"highlighted",
                @2 : @"disabled",
                @3 : @"highlightedDisabled",
                @4 : @"selected",
                @5 : @"highlightedSelected",
                @6 : @"selectedDisabled",
                @7 : @"highlightedSelectedDisabled" };
  });

  return states[state];
}

+ (NSUInteger)stateForProperty:(NSString *)property {
  static const NSDictionary * properties = nil;
  static dispatch_once_t      onceToken;

  dispatch_once(&onceToken, ^{
    properties = @{ @"normal"                      : @0,
                    @"highlighted"                 : @1,
                    @"disabled"                    : @2,
                    @"highlightedDisabled"         : @3,
                    @"selected"                    : @4,
                    @"highlightedSelected"         : @5,
                    @"selectedDisabled"            : @6,
                    @"highlightedSelectedDisabled" : @7 };
  });
  NSNumber * state = properties[property];

  return (state ? UnsignedIntegerValue(state) : NSUIntegerMax);
}

+ (NSSet *)validProperties {
  static dispatch_once_t onceToken;
  static NSSet const   * validProperties;

  dispatch_once(&onceToken, ^{
    validProperties = [@[@"normal",
                         @"highlighted",
                         @"disabled",
                         @"highlightedDisabled",
                         @"selected",
                         @"highlightedSelected",
                         @"selectedDisabled",
                         @"highlightedSelectedDisabled"] set];
  });

  return (NSSet *)validProperties;
}

- (id)valueForUndefinedKey:(NSString *)key {
  switch ([key characterAtIndex:0]) {
    case '0': return self.normal;
    case '1': return self.highlighted;
    case '2': return self.disabled;
    case '3': return self.highlightedDisabled;
    case '4': return self.selected;
    case '5': return self.highlightedSelected;
    case '6': return self.selectedDisabled;
    case '7': return self.highlightedSelectedDisabled;
    default: return [super valueForUndefinedKey:key];
  }
}

- (NSDictionary *)dictionaryFromSetObjects:(BOOL)useJSONKeys {

  MSDictionary * dictionary = [MSDictionary dictionary];

  for (NSUInteger i = 0; i < 8; i++) {
    NSString * property = [ControlStateSet propertyForState:@(i)];

    NSString * key = useJSONKeys ? [property camelCaseToDashCase] : property;
    dictionary[key] = CollectionSafe([self valueForKey:property]);
  }

  [dictionary compact];

  return dictionary;
}

- (NSArray *)allValues {

  NSMutableArray * values = [@[] mutableCopy];

  for (NSString * property in [ControlStateSet validProperties]) {
    id value = [self valueForKey:property];
    if (value) [values addObject:value];
  }

  return values;
}

- (BOOL)isEmptySet { return ([[self dictionaryFromSetObjects:NO] count] == 0); }

- (id)objectAtIndexedSubscript:(NSUInteger)state {

  if (![ControlStateSet validState:@(state)])
    return nil;

  id object = [self valueForKey:[ControlStateSet propertyForState:@(state)]];

  if (!object && (state & UIControlStateSelected))
    object = [self valueForKey:[ControlStateSet propertyForState:@(state & ~UIControlStateSelected)]];

  if (!object && (state & UIControlStateHighlighted))
    object = [self valueForKey:[ControlStateSet propertyForState:@(state & ~UIControlStateHighlighted)]];

  if (!object)
    object = [self valueForKey:@"normal"];

  return object;
}

- (void)setObject:(id)object forStates:(NSArray *)states {

  for (id state in states) {

    if (isNumberKind(state))
      self[[state unsignedIntegerValue]] = object;

    else if (isStringKind(state))
      self[state] = object;

  }

}

- (id)objectForKeyedSubscript:(NSString *)key {
  return ([ControlStateSet validState:key] ? [self valueForKey:key] : nil);
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key {

  if (![ControlStateSet validState:key])
    ThrowInvalidArgument(key, "is not a valid state key");

  else
    [self setValue:object forKey:key];

}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)state {

  if (![ControlStateSet validState:@(state)])
    ThrowInvalidIndexArgument(state);

  else
    [self setValue:object forKey:[ControlStateSet propertyForState:@(state)]];

}

- (instancetype)copyWithZone:(NSZone *)zone {
  __block ControlStateSet * controlStateSet      = nil;
  Class                     controlStateSetClass = [self class];
  __weak ControlStateSet  * sourceSet            = self;
  NSManagedObjectContext  * moc                  = self.managedObjectContext;

  [moc performBlockAndWait:^{
    controlStateSet = [controlStateSetClass createInContext:moc];
    [controlStateSet setValuesForKeysWithDictionary:
     [sourceSet dictionaryWithValuesForKeys:[[ControlStateSet validProperties] allObjects]]];
  }];

  return controlStateSet;
}

- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];
  [dictionary addEntriesFromDictionary:[self dictionaryFromSetObjects:YES]];

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

@end
