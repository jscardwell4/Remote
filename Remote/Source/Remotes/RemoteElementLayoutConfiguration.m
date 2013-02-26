//
// RemoteElementLayoutConfiguraiton.m
// iPhonto
//
// Created by Jason Cardwell on 1/21/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementLayoutConstraint.h"
#import "RemoteElementLayoutConfiguration.h"
#import "RemoteElement_Private.h"
#import "RemoteElementView_Private.h"

// UILayoutConstraintAxis UILayoutConstraintAxisForAttribute(NSLayoutAttribute attribute) {
// static dispatch_once_t onceToken;
// static const NSSet   * horizontalAxisAttributes = nil, * verticalAxisAttributes = nil;
//
// dispatch_once(&onceToken, ^{
// horizontalAxisAttributes = [NSSet setWithObjects:
// @(NSLayoutAttributeWidth),
// @(NSLayoutAttributeLeft),
// @(NSLayoutAttributeLeading),
// @(NSLayoutAttributeRight),
// @(NSLayoutAttributeTrailing),
// @(NSLayoutAttributeCenterX), nil];
// verticalAxisAttributes = [NSSet setWithObjects:
// @(NSLayoutAttributeHeight),
// @(NSLayoutAttributeTop),
// @(NSLayoutAttributeBottom),
// @(NSLayoutAttributeBaseline),
// @(NSLayoutAttributeCenterY), nil];
// }
// );
// if ([horizontalAxisAttributes containsObject:@(attribute)]) return
// UILayoutConstraintAxisHorizontal;
// else if ([verticalAxisAttributes containsObject:@(attribute)]) return
// UILayoutConstraintAxisVertical;
// else return -1;
// }
////////////////////////////////////////////////////////////////////////////////
#pragma mark - RemoteElementLayoutConfiguration
////////////////////////////////////////////////////////////////////////////////

/*
 * @implementation RemoteElementLayoutConfiguration {
 *  MSBitVector          * _bits;
 *  __weak RemoteElement * _element;
 * }
 *
 * ////////////////////////////////////////////////////////////////////////////////
 * #pragma mark Initializers
 * ////////////////////////////////////////////////////////////////////////////////
 *
 + (RemoteElementLayoutConfiguration *)layoutConfigurationForRemoteElement:(RemoteElement *)element
 ++{
 +  RemoteElementLayoutConfiguration * config = [[RemoteElementLayoutConfiguration
 ++alloc]initWithElement:element];
 +
 +  config->_element = element;
 +
 +  return config;
 + }
 + - (id)initWithElement:(RemoteElement *)element {
 +  if ((self = [super init])) {
 +      _bits    = [MSBitVector bitVectorWithSize:MSBitVectorSize8];
 +      _element = element;
 +
 +      __weak RemoteElementLayoutConfiguration * weakSelf = self;
 +
 +      [_element.managedObjectContext
 +       performBlock:^{
 +           for (RemoteElementLayoutConstraint * constraint in _element.firstItemConstraints) {
 +              [weakSelf processConstraint:constraint];
 +           }
 +       }
 +      ];
 +  }
 +  return self;
 + }
 + - (RemoteElementLayoutConfiguration *)copyWithZone:(NSZone *)zone {
 +  RemoteElementLayoutConfiguration * config = [RemoteElementLayoutConfiguration
 ++layoutConfigurationForRemoteElement:_element];
 +  uint8_t bits = (uint8_t)[_bits.bits unsignedIntegerValue];
 +
 +  config->_bits = [MSBitVector bitVectorWithBytes:&bits];
 +
 +  return config;
 + }
 + ////////////////////////////////////////////////////////////////////////////////
 ++#pragma mark Syntax Support
 + ////////////////////////////////////////////////////////////////////////////////
 +
 + - (NSNumber *)objectForKeyedSubscript:(NSString *)key {
 +  switch ([NSLayoutConstraint attributeForPseudoName:key]) {
 +  case NSLayoutAttributeBaseline:
 +  case NSLayoutAttributeBottom:
 +
 +      return _bits[4];
 +
 +  case NSLayoutAttributeTop:
 +
 +      return _bits[5];
 +
 +  case NSLayoutAttributeLeft:
 +  case NSLayoutAttributeLeading:
 +
 +      return _bits[7];
 +
 +  case NSLayoutAttributeRight:
 +  case NSLayoutAttributeTrailing:
 +
 +      return _bits[6];
 +
 +  case NSLayoutAttributeCenterX:
 +
 +      return _bits[3];
 +
 +  case NSLayoutAttributeCenterY:
 +
 +      return _bits[2];
 +
 +  case NSLayoutAttributeWidth:
 +
 +      return _bits[1];
 +
 +  case NSLayoutAttributeHeight:
 +
 +      return _bits[0];
 +
 +  case NSLayoutAttributeNotAnAttribute:
 +
 +      return @NO;
 +  }   switch
 + }
 + - (void)setObject:(NSNumber *)object forKeyedSubscript:(NSString *)key {
 +  if (!object) object = @NO;
 +  switch ([NSLayoutConstraint attributeForPseudoName:key]) {
 +  case NSLayoutAttributeBaseline:
 +  case NSLayoutAttributeBottom:
 +      _bits[4] = object; break;
 +
 +  case NSLayoutAttributeTop:
 +      _bits[5] = object; break;
 +
 +  case NSLayoutAttributeLeft:
 +  case NSLayoutAttributeLeading:
 +      _bits[7] = object; break;
 +
 +  case NSLayoutAttributeRight:
 +  case NSLayoutAttributeTrailing:
 +      _bits[6] = object; break;
 +
 +  case NSLayoutAttributeCenterX:
 +      _bits[3] = object; break;
 +
 +  case NSLayoutAttributeCenterY:
 +      _bits[2] = object; break;
 +
 +  case NSLayoutAttributeWidth:
 +      _bits[1] = object; break;
 +
 +  case NSLayoutAttributeHeight:
 +      _bits[0] = object; break;
 +
 +  case NSLayoutAttributeNotAnAttribute:
 +      break;
 +  }   switch
 + }
 + - (NSNumber *)objectAtIndexedSubscript:(NSLayoutAttribute)idx {
 +  switch (idx) {
 +  case NSLayoutAttributeBaseline:
 +  case NSLayoutAttributeBottom:
 +
 +      return _bits[4];
 +
 +  case NSLayoutAttributeTop:
 +
 +      return _bits[5];
 +
 +  case NSLayoutAttributeLeft:
 +  case NSLayoutAttributeLeading:
 +
 +      return _bits[7];
 +
 +  case NSLayoutAttributeRight:
 +  case NSLayoutAttributeTrailing:
 +
 +      return _bits[6];
 +
 +  case NSLayoutAttributeCenterX:
 +
 +      return _bits[3];
 +
 +  case NSLayoutAttributeCenterY:
 +
 +      return _bits[2];
 +
 +  case NSLayoutAttributeWidth:
 +
 +      return _bits[1];
 +
 +  case NSLayoutAttributeHeight:
 +
 +      return _bits[0];
 +
 +  case NSLayoutAttributeNotAnAttribute:
 +
 +      return @NO;
 +  }   switch
 + }
 + - (void)setObject:(NSNumber *)object atIndexedSubscript:(NSLayoutAttribute)idx {
 +  if (!object) object = @NO;
 +  switch (idx) {
 +  case NSLayoutAttributeBaseline:
 +  case NSLayoutAttributeBottom:
 +      _bits[4] = object; break;
 +
 +  case NSLayoutAttributeTop:
 +      _bits[5] = object; break;
 +
 +  case NSLayoutAttributeLeft:
 +  case NSLayoutAttributeLeading:
 +      _bits[7] = object; break;
 +
 +  case NSLayoutAttributeRight:
 +  case NSLayoutAttributeTrailing:
 +      _bits[6] = object; break;
 +
 +  case NSLayoutAttributeCenterX:
 +      _bits[3] = object; break;
 +
 +  case NSLayoutAttributeCenterY:
 +      _bits[2] = object; break;
 +
 +  case NSLayoutAttributeWidth:
 +      _bits[1] = object; break;
 +
 +  case NSLayoutAttributeHeight:
 +      _bits[0] = object; break;
 +
 +  case NSLayoutAttributeNotAnAttribute:
 +      break;
 +  }   switch
 + }
 + ////////////////////////////////////////////////////////////////////////////////
 ++#pragma mark Manipulation Helper Methods
 + ////////////////////////////////////////////////////////////////////////////////
 +
 + - (NSArray *)replacementCandidatesForAddingAttribute:(NSLayoutAttribute)attribute
 +                                         additions:(NSArray **)additions {
 +  switch (attribute) {
 +  case NSLayoutAttributeBaseline:
 +  case NSLayoutAttributeBottom: {
 +      if (self[@"height"]) {
 +          return (self[@"centerY"]
 +                  ? @[@(NSLayoutAttributeCenterY)]
 +                  : @[@(NSLayoutAttributeTop)]);
 +      } else {
 * additions = @[@(NSLayoutAttributeHeight)];
 *
 *          return @[@(NSLayoutAttributeCenterY), @(NSLayoutAttributeTop)];
 *      }
 *  }
 *
 *  case NSLayoutAttributeTop: {
 *      if (self[@"height"]) {
 *          return (self[@"centerY"]
 *                  ? @[@(NSLayoutAttributeCenterY)]
 *                  : @[@(NSLayoutAttributeBottom)]);
 *      } else {
 * additions = @[@(NSLayoutAttributeHeight)];
 *
 *          return @[@(NSLayoutAttributeCenterY), @(NSLayoutAttributeBottom)];
 *      }
 *  }
 *
 *  case NSLayoutAttributeLeft:
 *  case NSLayoutAttributeLeading: {
 *      if (self[@"width"]) {
 *          return (self[@"centerX"]
 *                  ? @[@(NSLayoutAttributeCenterX)]
 *                  : @[@(NSLayoutAttributeRight)]);
 *      } else {
 * additions = @[@(NSLayoutAttributeWidth)];
 *
 *          return @[@(NSLayoutAttributeCenterX), @(NSLayoutAttributeRight)];
 *      }
 *  }
 *
 *  case NSLayoutAttributeRight:
 *  case NSLayoutAttributeTrailing: {
 *      if (self[@"width"]) {
 *          return (self[@"centerX"]
 *                  ? @[@(NSLayoutAttributeCenterX)]
 *                  : @[@(NSLayoutAttributeLeft)]);
 *      } else {
 * additions = @[@(NSLayoutAttributeWidth)];
 *
 *          return @[@(NSLayoutAttributeCenterX), @(NSLayoutAttributeLeft)];
 *      }
 *  }
 *
 *  case NSLayoutAttributeCenterX: {
 *      if (self[@"width"]) {
 *          return (self[@"left"]
 *                  ? @[@(NSLayoutAttributeLeft)]
 *                  : @[@(NSLayoutAttributeRight)]);
 *      } else {
 * additions = @[@(NSLayoutAttributeWidth)];
 *
 *          return @[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight)];
 *      }
 *  }
 *
 *  case NSLayoutAttributeCenterY: {
 *      if (self[@"height"]) {
 *          return (self[@"top"]
 *                  ? @[@(NSLayoutAttributeTop)]
 *                  : @[@(NSLayoutAttributeBottom)]);
 *      } else {
 * additions = @[@(NSLayoutAttributeHeight)];
 *
 *          return @[@(NSLayoutAttributeTop), @(NSLayoutAttributeBottom)];
 *      }
 *  }
 *
 *  case NSLayoutAttributeWidth: {
 *      if (self[@"centerX"]) {
 *          return (self[@"left"]
 *                  ? @[@(NSLayoutAttributeLeft)]
 *                  : @[@(NSLayoutAttributeRight)]);
 *      } else {
 * additions = @[@(NSLayoutAttributeWidth)];
 *
 *          return @[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight)];
 *      }
 *  }
 *
 *  case NSLayoutAttributeHeight: {
 *      if (self[@"centerY"]) {
 *          return (self[@"top"]
 *                  ? @[@(NSLayoutAttributeTop)]
 *                  : @[@(NSLayoutAttributeBottom)]);
 *      } else {
 * additions = @[@(NSLayoutAttributeHeight)];
 *
 *          return @[@(NSLayoutAttributeTop), @(NSLayoutAttributeBottom)];
 *      }
 *  }
 *
 *  case NSLayoutAttributeNotAnAttribute:
 *  default:
 *
 *      return nil;
 *  }  switch
 * }      replacementCandidatesForAddingAttribute
 * - (NSSet *)constraintsAffectingAxis:(UILayoutConstraintAxis)axis
 * order:(RELayoutConstraintOrder)order {
 *  NSMutableSet * constraints = [NSMutableSet set];
 *
 *  if (!order || order == RELayoutConstraintFirstOrder) {
 *      [constraints unionSet:[_element.firstItemConstraints
 *                             objectsPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL *
 * stop) {
 *              return (axis == UILayoutConstraintAxisForAttribute(obj.firstAttribute));
 *          }
 *       ]];
 *  }
 *  if (!order || order == RELayoutConstraintSecondOrder) {
 *      [constraints unionSet:[_element.secondItemConstraints
 *                             objectsPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL *
 * stop) {
 *              return (axis == UILayoutConstraintAxisForAttribute(obj.secondAttribute));
 *          }
 *       ]];
 *  }
 *  return (constraints.count
 *          ? constraints
 *          : nil);
 * }
 * - (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute {
 *  return [self constraintsForAttribute:attribute
 *                                 order:RELayoutConstraintUnspecifiedOrder];
 * }
 * - (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute
 * order:(RELayoutConstraintOrder)order {
 *  if (!self[[NSLayoutConstraint pseudoNameForAttribute:attribute]]) return nil;
 *
 *  NSMutableSet * constraints = [NSMutableSet set];
 *
 *  if (!order || order == RELayoutConstraintFirstOrder) {
 *      [constraints unionSet:[_element.firstItemConstraints
 *                             objectsPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL *
 * stop) {
 *              return (obj.firstAttribute == attribute);
 *          }
 *       ]];
 *  }
 *  if (!order || order == RELayoutConstraintSecondOrder) {
 *      [constraints unionSet:[_element.secondItemConstraints
 *                             objectsPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL *
 * stop) {
 *              return (obj.secondAttribute == attribute);
 *          }
 *       ]];
 *  }
 *  return (constraints.count
 *          ? constraints
 *          : nil);
 * }
 * - (void)processConstraint:(RemoteElementLayoutConstraint *)constraint {
 *  if (constraint.firstItem == _element && constraint.relation == NSLayoutRelationEqual)
 * self[[NSLayoutConstraint pseudoNameForAttribute:constraint.firstAttribute]] = @YES;
 * }
 * ////////////////////////////////////////////////////////////////////////////////
 **#pragma mark Properties
 * ////////////////////////////////////////////////////////////////////////////////
 *
 *
 * - (RemoteElementLayout)layout { return [_bits.bits unsignedIntegerValue]; }
 *
 *
 * - (BOOL)isValid {
 *  // Fixme: Needs replacing
 *
 *  static const NSSet * validConfigurations;
 *  static dispatch_once_t onceToken;
 *  dispatch_once(&onceToken, ^{
 *      validConfigurations = [NSSet setWithObjects:
 *                             @(RemoteElementLayoutConfigurationXYWH),
 *                             @(RemoteElementLayoutConfigurationXYWT),
 *                             @(RemoteElementLayoutConfigurationXYWB),
 *                             @(RemoteElementLayoutConfigurationXYLH),
 *                             @(RemoteElementLayoutConfigurationXYLT),
 *                             @(RemoteElementLayoutConfigurationXYLB),
 *                             @(RemoteElementLayoutConfigurationXYRH),
 *                             @(RemoteElementLayoutConfigurationXYRT),
 *                             @(RemoteElementLayoutConfigurationXYRB),
 *                             @(RemoteElementLayoutConfigurationXTBW),
 *                             @(RemoteElementLayoutConfigurationXTBL),
 *                             @(RemoteElementLayoutConfigurationXTBR),
 *                             @(RemoteElementLayoutConfigurationXTHW),
 *                             @(RemoteElementLayoutConfigurationXTHL),
 *                             @(RemoteElementLayoutConfigurationXTHR),
 *                             @(RemoteElementLayoutConfigurationXBHW),
 *                             @(RemoteElementLayoutConfigurationXBHL),
 *                             @(RemoteElementLayoutConfigurationXBHR),
 *                             @(RemoteElementLayoutConfigurationLRYH),
 *                             @(RemoteElementLayoutConfigurationLRYT),
 *                             @(RemoteElementLayoutConfigurationLRYB),
 *                             @(RemoteElementLayoutConfigurationLRTB),
 *                             @(RemoteElementLayoutConfigurationLRTH),
 *                             @(RemoteElementLayoutConfigurationLRBH),
 *                             @(RemoteElementLayoutConfigurationLWYH),
 *                             @(RemoteElementLayoutConfigurationLWYT),
 *                             @(RemoteElementLayoutConfigurationLWYB),
 *                             @(RemoteElementLayoutConfigurationLWTB),
 *                             @(RemoteElementLayoutConfigurationLWTH),
 *                             @(RemoteElementLayoutConfigurationLWBH),
 *                             @(RemoteElementLayoutConfigurationRWYL),
 *                             @(RemoteElementLayoutConfigurationRWYT),
 *                             @(RemoteElementLayoutConfigurationRWYB),
 *                             @(RemoteElementLayoutConfigurationRWTB),
 *                             @(RemoteElementLayoutConfigurationRWTH),
 *                             @(RemoteElementLayoutConfigurationRWBH),
 *                             nil];
 *  });
 *
 *
 *  return YES;  // [validConfigurations containsObject:_bits.bits];
 * }
 * ////////////////////////////////////////////////////////////////////////////////
 **#pragma mark Logging
 * ////////////////////////////////////////////////////////////////////////////////
 *
 * - (NSString *)description {
 *  NSMutableString * s = [@"" mutableCopy];
 *
 *  if ([_bits[7] boolValue]) [s appendString:@"L"];
 *  if ([_bits[6] boolValue]) [s appendString:@"R"];
 *  if ([_bits[5] boolValue]) [s appendString:@"T"];
 *  if ([_bits[4] boolValue]) [s appendString:@"B"];
 *  if ([_bits[3] boolValue]) [s appendString:@"X"];
 *  if ([_bits[2] boolValue]) [s appendString:@"Y"];
 *  if ([_bits[1] boolValue]) [s appendString:@"W"];
 *  if ([_bits[0] boolValue]) [s appendString:@"H"];
 *  return s;
 * }
 * - (NSString *)binaryDescription {
 *  return [_bits binaryDescription];
 * }
 * @end
 */
