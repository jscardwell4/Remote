//
// ControlStateSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ControlStateSet.h"
#import "CoreDataManager.h"

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

  dispatch_once(&onceToken,
                ^{
    validNumbers = [@[@0, @1, @2, @3, @4, @5, @6, @7] set];
    validKeys    = [@[@"normal",
                      @"highlighted",
                      @"disabled",
                      @"highlightedDisabled",
                      @"selected",
                      @"highlightedSelected",
                      @"disabledSelected",
                      @"selectedHighlightedDisabled"] set];
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
  if ([self validState:key])
    return isStringKind(key) ? key : [self propertyForState:key];
  else return nil;
}

+ (NSString *)propertyForState:(NSNumber *)state {
  static const NSDictionary * states;
  static dispatch_once_t      onceToken;

  dispatch_once(&onceToken,
                ^{
    states = @{ @0 : @"normal",
                @1 : @"highlighted",
                @2 : @"disabled",
                @3 : @"highlightedDisabled",
                @4 : @"selected",
                @5 : @"highlightedSelected",
                @6 : @"disabledSelected",
                @7 : @"selectedHighlightedDisabled" };
  });

  return states[state];
}

+ (NSUInteger)stateForProperty:(NSString *)property {
  static const NSDictionary * properties = nil;
  static dispatch_once_t      onceToken;

  dispatch_once(&onceToken,
                ^{
    properties = @{ @"normal"                      : @0,
                    @"highlighted"                 : @1,
                    @"disabled"                    : @2,
                    @"highlightedDisabled"         : @3,
                    @"selected"                    : @4,
                    @"highlightedSelected"         : @5,
                    @"disabledSelected"            : @6,
                    @"selectedHighlightedDisabled" : @7 };
  });
  NSNumber * state = properties[property];

  return (state ? UnsignedIntegerValue(state) : NSUIntegerMax);
}

+ (NSSet *)validProperties {
  static dispatch_once_t onceToken;
  static NSSet const   * validProperties;

  dispatch_once(&onceToken,
                ^{
    validProperties = [@[@"normal",
                         @"highlighted",
                         @"disabled",
                         @"highlightedDisabled",
                         @"selected",
                         @"highlightedSelected",
                         @"disabledSelected",
                         @"selectedHighlightedDisabled"] set];
  });

  return (NSSet *)validProperties;
}

/*
   @dynamic disabled;
   @dynamic disabledSelected;
   @dynamic highlighted;
   @dynamic highlightedDisabled;
   @dynamic highlightedSelected;
   @dynamic normal;
   @dynamic selected;
   @dynamic selectedHighlightedDisabled;
 */
+ (instancetype)controlStateSet {
  return [self controlStateSetInContext:[CoreDataManager defaultContext]];
}

+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)moc {
  return [self createInContext:moc];
}

+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)moc
                             withObjects:(NSDictionary *)objects {
  ControlStateSet * stateSet = [self controlStateSetInContext:moc];

  [stateSet setValuesForKeysWithDictionary:objects];

  return stateSet;
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

- (BOOL)isEmptySet { return ([[self dictionaryFromSetObjects:NO] count] == 0); }

- (void)copyObjectsFromSet:(ControlStateSet *)set {
  for (int i = 0; i < 8; i++) self[i] = [[set objectAtIndex:i] copy];
}

- (id)objectAtIndex:(NSUInteger)state {
  return ([ControlStateSet validState:@(state)]
          ? [self valueForKey:[ControlStateSet propertyForState:@(state)]]
          : nil);
}

- (id)objectForKey:(NSString *)key {
  return ([ControlStateSet validState:key] ? [self valueForKey:key] : nil);
}

- (id)objectAtIndexedSubscript:(NSUInteger)state {
  if (![ControlStateSet validState:@(state)])
    return nil;

  id object = [self valueForKey:[ControlStateSet propertyForState:@(state)]];

  if (!object && (state & UIControlStateSelected))
    object = self[state & ~UIControlStateSelected];

  if (!object && (state & UIControlStateHighlighted))
    object = self[state & ~UIControlStateHighlighted];

  if (!object)
    object = [self valueForKey:@"normal"];

  return object;
}

- (void)setObject:(id)object forStates:(NSArray *)states {
  for (id state in states) {
    if (isNumberKind(state)) self[[state unsignedIntegerValue]] = object;
    else if (isStringKind(state)) self[state] = object;
  }
}

- (id)objectForKeyedSubscript:(NSString *)key {
  return ([ControlStateSet validState:key] ? [self valueForKey:key] : nil);
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key {
  if (![ControlStateSet validState:key]) ThrowInvalidArgument(key, is not a valid state key);
  else [self setValue:object forKey:key];
}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)state {
  if (![ControlStateSet validState:@(state)]) ThrowInvalidIndexArgument(state);
  else [self setValue:object forKey:[ControlStateSet propertyForState:@(state)]];
}

- (instancetype)copyWithZone:(NSZone *)zone {
  __block ControlStateSet * controlStateSet      = nil;
  Class                     controlStateSetClass = [self class];
  __weak ControlStateSet  * sourceSet            = self;
  NSManagedObjectContext  * moc                  = self.managedObjectContext;

  [moc performBlockAndWait:
   ^{
    controlStateSet = [controlStateSetClass controlStateSetInContext:moc];
    [controlStateSet copyObjectsFromSet:sourceSet];
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
