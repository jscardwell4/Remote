//
//  MSKeyPath.m
//  MSKit
//
//  Created by Jason Cardwell on 9/6/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

#import "MSKeyPath.h"
#import "MSKitMacros.h"
#import "NSArray+MSKitAdditions.h"

@interface MSKeyPath ()

@property (nonatomic, strong) NSMutableArray * keys;

@end

@implementation MSKeyPath

/// keyPathFromString:
/// @param string description
/// @return instancetype
+ (instancetype)keyPathFromString:(NSString *)string {
  if (!string) ThrowInvalidNilArgument(string);
  MSKeyPath * keyPath = [self new];
  [keyPath.keys addObjectsFromArray:[string componentsSeparatedByString:@"."]];
  return keyPath;
}

/// objectAtIndexedSubscript:
/// @param idx description
/// @return NSString *
- (NSString *)objectAtIndexedSubscript:(NSUInteger)idx { return self.keys[idx]; }

/// setObject:atIndexedSubscript:
/// @param obj description
/// @param idx description
- (void)setObject:(NSString *)key atIndexedSubscript:(NSUInteger)idx { self.keys[idx] = key; }

/// insertKey:atIndex:
/// @param key description
/// @param idx description
- (void)insertKey:(NSString *)key atIndex:(NSUInteger)idx { [self.keys insertObject:key atIndex:idx]; }

/// countByEnumeratingWithState:objects:count:
/// @param state description
/// @param buffer description
/// @param len description
/// @return NSUInteger
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id [])buffer
                                    count:(NSUInteger)len
{
  return [self.keys countByEnumeratingWithState:state objects:buffer count:len];
}

/// stringValue
/// @return NSString *
- (NSString *)stringValue { return [self.keys componentsJoinedByString:@"."]; }

/// stringValueToIndex:
/// @param idx Index of the first key to not include. Passing a negative value counts from the end with -1
///            includes all keys but that last key, -2 includes all but the last two keys, etc., ect.
/// @return NSString *
- (NSString *)stringValueToIndex:(NSInteger)idx {

  if (ABS(idx) > self.count) ThrowInvalidIndexArgument(idx);

  NSUInteger length = (idx >= 0 ? idx : self.count + idx);
  NSArray * includedKeys = [self.keys subarrayWithRange:NSMakeRange(0, length)];
  return [includedKeys componentsJoinedByString:@"."];

}

/// Key path string value with the selected number keys from the front omitted
/// @param idx Index of the first key to include. Passing a negative value counts from the end with -1
///            includes only the last key, -2 includes only the last two keys, etc., ect.
/// @return NSString *
- (NSString *)stringValueFromIndex:(NSInteger)idx {

  if (ABS(idx) > self.count) ThrowInvalidIndexArgument(idx);

  NSUInteger location = (idx >= 0 ? idx : self.count - 1 + idx);
  NSUInteger length   = self.count - location;
  NSArray * includedKeys = [self.keys subarrayWithRange:NSMakeRange(location, length)];
  return [includedKeys componentsJoinedByString:@"."];
  
}

/// firstKey
/// @return NSString *
- (NSString *)firstKey { return [self.keys firstObject]; }

/// lastKey
/// @return NSString *
- (NSString *)lastKey { return [self.keys lastObject]; }

/// appendKey:
/// @param key description
- (void)appendKey:(NSString *)key { if (isStringKind(key)) [self.keys addObject:key]; }

/// appendKeys:
/// @param keys description
- (void)appendKeys:(NSArray *)keys {
  [self.keys addObjectsFromArray:[keys filtered:^BOOL(id obj){ return isStringKind(obj); }]];
}

/// popFirst
/// @return NSString *
- (NSString *)popFirst {
  if ([self.keys isEmpty]) return nil;
  else {
    NSString * key = self.firstKey;
    [self.keys removeObjectAtIndex:0];
    return key;
  }
}

/// keys
/// @return NSMutableArray *
- (NSMutableArray *)keys { if (!_keys) _keys = [@[] mutableCopy]; return _keys; }

/// isEmpty
/// @return BOOL
- (BOOL)isEmpty { return [self.keys isEmpty]; }

/// count
/// @return NSUInteger
- (NSUInteger)count { return [self.keys count]; }

/// isSingleKey
/// @return BOOL
- (BOOL)isSingleKey { return (self.count == 1); }

/// popLast
/// @return NSString *
- (NSString *)popLast {
  if ([self.keys isEmpty]) return nil;
  else {
    NSString * key = self.lastKey;
    [self.keys removeLastObject];
    return key;
  }
}

/// description
/// @return NSString *
- (NSString *)description { return self.stringValue; }

@end
