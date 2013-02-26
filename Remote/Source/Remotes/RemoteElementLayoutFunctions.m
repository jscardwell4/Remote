//
// RemoteElementLayoutFunctions.m
// iPhonto
//
// Created by Jason Cardwell on 1/20/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteElementLayoutFunctions.h"
#import "RemoteElement.h"

/*
 * BOOL isValidLayoutConfiguration(RemoteElementLayout configuration) {
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
 *  return [validConfigurations containsObject:@(configuration)];
 * }
 */

/*
 * NSArray * conflictsForLayoutAttribute(RemoteElementLayoutAttribute attribute) {
 *  switch (attribute) {
 *      case RemoteElementLayoutAttributeHeight:
 *          return @[@(RemoteElementLayoutAttributeTop|RemoteElementLayoutAttributeBottom),
 *                   @(RemoteElementLayoutAttributeTop|RemoteElementLayoutAttributeCenterY),
 *                   @(RemoteElementLayoutAttributeBottom|RemoteElementLayoutAttributeCenterY)];
 *      case RemoteElementLayoutAttributeWidth:
 *          return @[@(RemoteElementLayoutAttributeLeft|RemoteElementLayoutAttributeRight),
 *                   @(RemoteElementLayoutAttributeLeft|RemoteElementLayoutAttributeCenterX),
 *                   @(RemoteElementLayoutAttributeRight|RemoteElementLayoutAttributeCenterX)];
 *      case RemoteElementLayoutAttributeCenterY:
 *          return @[@(RemoteElementLayoutAttributeTop|RemoteElementLayoutAttributeBottom),
 *                   @(RemoteElementLayoutAttributeTop|RemoteElementLayoutAttributeHeight),
 *                   @(RemoteElementLayoutAttributeBottom|RemoteElementLayoutAttributeHeight)];
 *      case RemoteElementLayoutAttributeCenterX:
 *          return @[@(RemoteElementLayoutAttributeLeft|RemoteElementLayoutAttributeRight),
 *                   @(RemoteElementLayoutAttributeLeft|RemoteElementLayoutAttributeWidth),
 *                   @(RemoteElementLayoutAttributeRight|RemoteElementLayoutAttributeWidth)];
 *      case RemoteElementLayoutAttributeBottom:
 *          return @[@(RemoteElementLayoutAttributeTop|RemoteElementLayoutAttributeHeight),
 *                   @(RemoteElementLayoutAttributeTop|RemoteElementLayoutAttributeCenterY),
 *                   @(RemoteElementLayoutAttributeHeight|RemoteElementLayoutAttributeCenterY)];
 *      case RemoteElementLayoutAttributeTop:
 *          return @[@(RemoteElementLayoutAttributeHeight|RemoteElementLayoutAttributeBottom),
 *                   @(RemoteElementLayoutAttributeBottom|RemoteElementLayoutAttributeCenterY),
 *                   @(RemoteElementLayoutAttributeHeight|RemoteElementLayoutAttributeCenterY)];
 *      case RemoteElementLayoutAttributeRight:
 *          return @[@(RemoteElementLayoutAttributeWidth|RemoteElementLayoutAttributeLeft),
 *                   @(RemoteElementLayoutAttributeLeft|RemoteElementLayoutAttributeCenterX),
 *                   @(RemoteElementLayoutAttributeWidth|RemoteElementLayoutAttributeCenterX)];
 *      case RemoteElementLayoutAttributeLeft:
 *          return @[@(RemoteElementLayoutAttributeWidth|RemoteElementLayoutAttributeRight),
 *                   @(RemoteElementLayoutAttributeRight|RemoteElementLayoutAttributeCenterX),
 *                   @(RemoteElementLayoutAttributeWidth|RemoteElementLayoutAttributeCenterX)];
 *      default:
 *          assert(NO);
 *          return nil;
 *  }
 * }
 */

/*
 * RemoteElementLayoutAttribute configurationAttributeForAxisDimension(RemoteElementLayout
 * configuration,
 *                                                                  RemoteElementLayoutAxisDimension
 * axisDimension)
 * {
 *  assert(isValidLayoutConfiguration(configuration));
 *  switch (axisDimension) {
 *      case RemoteElementLayoutHeightDimension:
 *          return ((configuration & RemoteElementLayoutAttributeHeight)
 *                  ? RemoteElementLayoutAttributeHeight
 *                  : ((configuration & RemoteElementLayoutAttributeCenterY)
 *                     ? RemoteElementLayoutAttributeCenterY|((configuration &
 * RemoteElementLayoutAttributeTop)
 *                                                            ? RemoteElementLayoutAttributeTop
 *                                                            : RemoteElementLayoutAttributeBottom)
 *                     : RemoteElementLayoutAttributeTop|RemoteElementLayoutAttributeBottom));
 *      case RemoteElementLayoutWidthDimension:
 *          return ((configuration & RemoteElementLayoutAttributeWidth)
 *                  ? RemoteElementLayoutAttributeWidth
 *                  : ((configuration & RemoteElementLayoutAttributeCenterX)
 *                     ? RemoteElementLayoutAttributeCenterX|((configuration &
 * RemoteElementLayoutAttributeLeft)
 *                                                            ? RemoteElementLayoutAttributeLeft
 *                                                            : RemoteElementLayoutAttributeRight)
 *                     : RemoteElementLayoutAttributeLeft|RemoteElementLayoutAttributeRight));
 *      case RemoteElementLayoutXAxis:
 *          return ((configuration & RemoteElementLayoutAttributeCenterX)
 *                  ? RemoteElementLayoutAttributeCenterX
 *                  : ((configuration & RemoteElementLayoutAttributeWidth)
 *                     ? RemoteElementLayoutAttributeWidth|((configuration &
 * RemoteElementLayoutAttributeLeft)
 *                                                            ? RemoteElementLayoutAttributeLeft
 *                                                            : RemoteElementLayoutAttributeRight)
 *                     : RemoteElementLayoutAttributeLeft|RemoteElementLayoutAttributeRight));
 *      case RemoteElementLayoutYAxis:
 *          return ((configuration & RemoteElementLayoutAttributeCenterY)
 *                  ? RemoteElementLayoutAttributeCenterY
 *                  : ((configuration & RemoteElementLayoutAttributeHeight)
 *                     ? RemoteElementLayoutAttributeHeight|((configuration &
 * RemoteElementLayoutAttributeTop)
 *                                                            ? RemoteElementLayoutAttributeTop
 *                                                            : RemoteElementLayoutAttributeBottom)
 *                     : RemoteElementLayoutAttributeTop|RemoteElementLayoutAttributeBottom));
 *      default:
 *          assert(NO);
 *          return 0;
 *  }
 * }
 */

/*
 * NSString * NSStringFromRemoteElementLayoutConfiguration(RemoteElementLayoutConfiguration
 * configuration) {
 *  NSMutableString * s = [@"" mutableCopy];
 *  if (configuration & RemoteElementLayoutAttributeLeft)    [s appendString:@"L"];
 *  if (configuration & RemoteElementLayoutAttributeRight)   [s appendString:@"R"];
 *  if (configuration & RemoteElementLayoutAttributeTop)     [s appendString:@"T"];
 *  if (configuration & RemoteElementLayoutAttributeBottom)  [s appendString:@"B"];
 *  if (configuration & RemoteElementLayoutAttributeCenterX) [s appendString:@"X"];
 *  if (configuration & RemoteElementLayoutAttributeCenterY) [s appendString:@"Y"];
 *  if (configuration & RemoteElementLayoutAttributeWidth)   [s appendString:@"W"];
 *  if (configuration & RemoteElementLayoutAttributeHeight)  [s appendString:@"H"];
 *  return s;
 * }
 */
