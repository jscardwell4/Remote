//
// ConstraintManager.m
// Remote
//
// Created by Jason Cardwell on 2/9/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "ConstraintManager.h"
#import "RemoteElement_Private.h"

static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_CONSTRAINT | LOG_CONTEXT_FILE);
#pragma unused(ddLogLevel, msLogContext)

static NSSet * kAttributeDependenciesAll;
static NSSet * kAttributeDependenciesAlignment;
static NSSet * kAttributeDependenciesHorizontal;
static NSSet * kAttributeDependenciesVertical;

static NSArray * kConstraintPropertyKeys;

@interface ConstraintManager ()
@property (nonatomic, weak) NSManagedObjectContext        * context;
@property (nonatomic, strong) MSBitVector                 * bitVector;
@property (nonatomic, strong) NSMutableArray              * relationships;
@property (nonatomic, strong) MSContextChangeReceptionist * receptionist;
@end

@implementation ConstraintManager

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initializers
////////////////////////////////////////////////////////////////////////////////

+ (void)initialize {
  if (self == [ConstraintManager class]) {
    kAttributeDependenciesHorizontal = [@[@(NSLayoutAttributeLeft),
                                          @(NSLayoutAttributeRight),
                                          @(NSLayoutAttributeCenterX),
                                          @(NSLayoutAttributeWidth)] set];

    kAttributeDependenciesVertical = [@[@(NSLayoutAttributeBottom),
                                        @(NSLayoutAttributeTop),
                                        @(NSLayoutAttributeCenterY),
                                        @(NSLayoutAttributeHeight)] set];

    kAttributeDependenciesAll = [kAttributeDependenciesVertical
                                 setByAddingObjectsFromSet:kAttributeDependenciesHorizontal];

    kAttributeDependenciesAlignment = [kAttributeDependenciesAll
                                       setByRemovingObjectsFromArray:
                                       @[@(NSLayoutAttributeWidth),
                                         @(NSLayoutAttributeHeight)]];
    kConstraintPropertyKeys = [Constraint propertyList];
  }
}

+ (ConstraintManager *)constraintManagerForRemoteElement:(RemoteElement *)element {
  ConstraintManager * manager = [ConstraintManager new];
  manager->_remoteElement = element;
  manager->_context       = element.managedObjectContext;
  manager.bitVector       = BitVector8;
  manager.relationships   = [NSMutableArray arrayWithObject:@(REUnspecifiedRelation) count:8];
  return manager;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Notification
////////////////////////////////////////////////////////////////////////////////

MSSTRING_CONST REConstraintsDidChangeNotification = @"REConstraintsDidChangeNotification";

MSSTATIC_STRING_CONST REFirstItem       = @"firstItem";
MSSTATIC_STRING_CONST REFirstAttribute  = @"firstAttribute";
MSSTATIC_STRING_CONST RESecondItem      = @"secondItem";
MSSTATIC_STRING_CONST RESecondAttribute = @"secondAttribute";
MSSTATIC_STRING_CONST REOwner           = @"owner";
MSSTATIC_STRING_CONST RERelation        = @"relation";
MSSTATIC_STRING_CONST REMultiplier      = @"multiplier";
MSSTATIC_STRING_CONST REPriority        = @"priority";
MSSTATIC_STRING_CONST REConstant        = @"constant";


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constraints
////////////////////////////////////////////////////////////////////////////////

- (void)setConstraintsFromString:(NSString *)constraints {
  [_context performBlockAndWait:
   ^{   // wrap method in managed object context block

    if (_remoteElement.constraints.count)
      [_remoteElement removeConstraints:_remoteElement.constraints];

    NSArray * elements    = [[_remoteElement.subelements array]
                             arrayByAddingObject:_remoteElement];
    NSArray * identifiers = [elements valueForKeyPath:@"identifier"];

    NSDictionary * directory = [NSDictionary dictionaryWithObjects:elements
                                                           forKeys:identifiers];
    NSArray * constraintDictionaries = [NSLayoutConstraint
                                        constraintDictionariesByParsingString:constraints];

    [constraintDictionaries
          enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * stop)
    {
      NSString      * element1ID = obj[MSExtendedVisualFormatItem1Name];
      RemoteElement * element1   = directory[element1ID];
      NSString      * element2ID = obj[MSExtendedVisualFormatItem2Name];
      RemoteElement * element2   = (ValueIsNotNil(element2ID) ? directory[element2ID] : nil);
      CGFloat multiplier = (ValueIsNotNil(obj[MSExtendedVisualFormatMultiplierName])
                            ? FloatValue(obj[MSExtendedVisualFormatMultiplierName])
                            : 1.0f);
      CGFloat constant = (ValueIsNotNil(obj[MSExtendedVisualFormatConstantName])
                          ? FloatValue(obj[MSExtendedVisualFormatConstantName])
                          : 0.0f);

      if ([@"-" isEqualToString:obj[MSExtendedVisualFormatConstantOperatorName]])
        constant = -constant;

      NSLayoutAttribute attr1   = [NSLayoutConstraint attributeForPseudoName:
                                   obj[MSExtendedVisualFormatAttribute1Name]];
      NSLayoutAttribute attr2   = [NSLayoutConstraint attributeForPseudoName:
                                   obj[MSExtendedVisualFormatAttribute2Name]];
      NSLayoutRelation relation = [NSLayoutConstraint relationForPseudoName:
                                   obj[MSExtendedVisualFormatRelationName]];

      Constraint * constraint =
        [Constraint constraintWithItem:element1
                             attribute:attr1
                             relatedBy:relation
                                toItem:element2
                             attribute:attr2
                            multiplier:multiplier
                              constant:constant];

      if (ValueIsNotNil(obj[MSExtendedVisualFormatPriorityName]))
        constraint.priority = FloatValue(obj[MSExtendedVisualFormatPriorityName]);

      [_remoteElement addConstraint:constraint];
    }];
//         [_context MR_saveOnlySelfAndWait];
//         [CoreDataManager saveContext:_context asynchronous:NO completion:nil];
  }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////////////

- (void)resizeSubelements:(NSSet *)subelements
                toSibling:(RemoteElement *)sibling
                attribute:(NSLayoutAttribute)attribute
                  metrics:(NSDictionary *)metrics {

  NSSet * attributes = (attribute == NSLayoutAttributeWidth
                        ? [kAttributeDependenciesHorizontal
                           setByRemovingObject:@(NSLayoutAttributeCenterX)]
                        : [kAttributeDependenciesVertical
                           setByRemovingObject:@(NSLayoutAttributeCenterY)]);

  [_context performBlockAndWait:
   ^{   // wrap method in managed object context block

    // enumerate the views to adjust their constraints
    for (RemoteElement * element in subelements) {

      // adjust constraints that depend on the view being moved
      [self freezeConstraints:element.dependentSiblingConstraints
                forAttributes:attributes
                      metrics:metrics];

      [self removeProportionLockForElement:element
                               currentSize:CGRectValue(metrics[element.uuid]).size];

      // remove any existing constraints for attribute
      for (Constraint * constraint
           in [element.constraintManager constraintsForAttribute:attribute
               order:RELayoutConstraintFirstOrder])
        [constraint.owner removeConstraint:constraint];

      // Remove conflicting constraint and add new constraint for attribute
      Constraint * c = [Constraint
                        constraintWithItem:element
                                 attribute:attribute
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:sibling
                                 attribute:attribute
                                multiplier:1.0f
                                  constant:0.0f];

      [self resolveConflictsForConstraint:c metrics:metrics];
      [_remoteElement addConstraint:c];
    }

    [_context processPendingChanges];
  }];
}

- (void)translateSubelements:(NSSet *)subelements
                 translation:(CGPoint)translation
                     metrics:(NSDictionary *)metrics {
  [_context performBlockAndWait:
   ^{   // wrap method in managed object context block
    for (RemoteElement * subelement in subelements) {
      [self freezeConstraints:subelement.dependentSiblingConstraints
                forAttributes:kAttributeDependenciesAlignment
                      metrics:metrics];

      for (Constraint * constraint in subelement.firstItemConstraints) {
        switch (constraint.firstAttribute) {
          case NSLayoutAttributeBaseline:
          case NSLayoutAttributeBottom:
          case NSLayoutAttributeTop:
          case NSLayoutAttributeCenterY:
            constraint.constant += translation.y;
            break;

          case NSLayoutAttributeLeft:
          case NSLayoutAttributeLeading:
          case NSLayoutAttributeRight:
          case NSLayoutAttributeTrailing:
          case NSLayoutAttributeCenterX:
            constraint.constant += translation.x;
            break;

          case NSLayoutAttributeWidth:
          case NSLayoutAttributeHeight:
          case NSLayoutAttributeNotAnAttribute:
            break;
        }
      }
    }

    [_context processPendingChanges];
  }];
}

- (void)alignSubelements:(NSSet *)subelements
               toSibling:(RemoteElement *)sibling
               attribute:(NSLayoutAttribute)attribute
                 metrics:(NSDictionary *)metrics {
  [_context performBlockAndWait:
   ^{   // wrap method in managed object context block

    // determine attributes relevant to attribute being set
    UILayoutConstraintAxis axis = UILayoutConstraintAxisForAttribute(attribute);

    NSSet * attributes = [kAttributeDependenciesAlignment
                          setByIntersectingSet:(axis == UILayoutConstraintAxisHorizontal
                                                ? kAttributeDependenciesHorizontal
                                                : kAttributeDependenciesVertical)];


    // enumerate the views to adjust their constraints
    for (RemoteElement * element in subelements) { // freeze sibling constraints dependent on element, freeze element size, add new constraint
                                                   // adjust constraints that depend on the view being moved

      [self freezeConstraints:element.dependentSiblingConstraints
                forAttributes:attributes
                      metrics:metrics];

      // adjust size constraints to prevent move altering size calculations
      [self    freezeSize:CGRectValue(metrics[element.uuid]).size
            forSubelement:element
                attribute:attribute];

      // remove any existing constraints for attribute
      for (Constraint * constraint
           in [element.constraintManager constraintsForAttribute:attribute
               order:RELayoutConstraintFirstOrder])
        [constraint.owner removeConstraint:constraint];


      // Remove conflicting constraint and add new constraint for attribute
      Constraint * c = [Constraint
                        constraintWithItem:element
                                 attribute:attribute
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:sibling
                                 attribute:attribute
                                multiplier:1.0f
                                  constant:0.0f];

      [self resolveConflictsForConstraint:c metrics:metrics];
      [_remoteElement addConstraint:c];
      [_context processPendingChanges];
    }
  }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Utility Methods
////////////////////////////////////////////////////////////////////////////////

- (void)resizeElement:(RemoteElement *)element
             fromSize:(CGSize)currentSize
               toSize:(CGSize)newSize
              metrics:(NSDictionary *)metrics {
  [_context performBlockAndWait:
   ^{   // wrap method in managed object context block
    if (  element.constraintManager.proportionLock
       && currentSize.width / currentSize.height
        != newSize.width / newSize.height)
    {
      [self removeProportionLockForElement:element currentSize:currentSize];
    }

    CGSize deltaSize = CGSizeGetDelta(currentSize, newSize);

    for (Constraint * constraint in element.firstItemConstraints) {
      switch (constraint.firstAttribute) {
        case NSLayoutAttributeLeft:
        case NSLayoutAttributeLeading:
        case NSLayoutAttributeRight:
        case NSLayoutAttributeTrailing:
          constraint.constant -= deltaSize.width / 2.0f;
          break;

        case NSLayoutAttributeWidth:

          if (currentSize.width != newSize.width) {
            if (constraint.isStaticConstraint)
              constraint.constant = newSize.width;
            else if (constraint.firstItem != constraint.secondItem)
              constraint.constant -= deltaSize.width;
          }

          break;

        case NSLayoutAttributeCenterX:
          break;

        case NSLayoutAttributeBaseline:
        case NSLayoutAttributeBottom:
        case NSLayoutAttributeTop:
          constraint.constant -= deltaSize.height / 2.0f;
          break;

        case NSLayoutAttributeHeight:

          if (currentSize.height != newSize.height) {
            if (constraint.isStaticConstraint)
              constraint.constant = newSize.height;
            else if (constraint.firstItem != constraint.secondItem)
              constraint.constant -= deltaSize.height;
          }

          break;

        case NSLayoutAttributeCenterY:
          break;

        case NSLayoutAttributeNotAnAttribute:
        default:
          assert(NO);
          break;
      }
    }

    // save added because change notifications randomly not received otherwise
//         [CoreDataManager saveContext:element.managedObjectContext];
    [_context processPendingChanges];
  }];
}

- (void)shrinkWrapSubelements:(NSDictionary *)metrics {
  // contract or expand button group to match buttons
  ////////////////////////////////////////////////////////////////////////////////

  NSDictionary * subelementMetrics =
    [metrics dictionaryWithValuesForKeys:
     [[metrics allKeys]
      filteredArrayUsingPredicateWithFormat:@"self != %@ AND self != %@",
      _remoteElement.uuid,
      _remoteElement.parentElement.uuid]];

  __block CGFloat minX = CGFLOAT_MAX, maxX = CGFLOAT_MIN, minY = CGFLOAT_MAX, maxY = CGFLOAT_MIN;

  [subelementMetrics
     enumerateKeysAndObjectsUsingBlock:^(NSString * identifier, NSValue * rectValue, BOOL * stop)
  {
    CGRect frame = CGRectValue(rectValue);

    CGFloat frameMinX = CGRectGetMinX(frame);
    CGFloat frameMinY = CGRectGetMinY(frame);
    CGFloat frameMaxX = CGRectGetMaxX(frame);
    CGFloat frameMaxY = CGRectGetMaxY(frame);

    minX = MIN(minX, frameMinX);
    minY = MIN(minY, frameMinY);
    maxX = MAX(maxX, frameMaxX);
    maxY = MAX(maxY, frameMaxY);
  }];

  CGSize currentSize = CGRectValue(metrics[_remoteElement.uuid]).size;

  CGFloat contractX = (minX > 0                            // left edge needs to come in ?
                       ? -minX                             // move edge to left-most origin
                       : (maxX < currentSize.width         // right edge needs to push out?
                          ? currentSize.width - maxX       // push out the difference
                          : 0.0f));
  CGFloat contractY = (minY > 0                            // top edge needs to come in?
                       ? -minY                             // move edge to top-most origin
                       : (maxY < currentSize.height        // bottom edge needs to push out?
                          ? currentSize.height - maxY      // push out the difference
                          : 0.0f));
  CGFloat expandX = (maxX > currentSize.width              // right edge needs to push out?
                     ? maxX - currentSize.width            // move edge out the difference
                     : (minX < 0                           // left edge needs to push out?
                        ? minX                             // move edge out the difference
                        : 0.0f));
  CGFloat expandY = (maxY > currentSize.height             // top edge needs to push out?
                     ? maxY - currentSize.height           // move edge out the difference
                     : (minY < 0                           // bottom edge needs to push out?
                        ? minY                             // move edge out the difference
                        : 0.0f));
  CGFloat offsetX = (contractX < 0
                     ? contractX
                     : (expandX < 0
                        ? -expandX
                        : 0.0f));
  CGFloat offsetY = (contractY < 0
                     ? contractY
                     : (expandY < 0
                        ? -expandY
                        : 0.0f));

  CGPoint contract     = CGPointMake(contractX, contractY);
  CGPoint expand       = CGPointMake(expandX, expandY);
  CGPoint offset       = CGPointMake(offsetX, offsetY);
  CGSize  boundingSize =
    CGRectValue(metrics[_remoteElement.parentElement.uuid]).size;

  if (CGSizeEqualToSize(boundingSize, CGSizeZero))
    boundingSize = MainScreen.bounds.size;

  CGSize newSize = CGSizeMake(MIN(boundingSize.width, maxX - minX),
                              MIN(boundingSize.height, maxY - minY));

  if (CGSizeEqualToSize(newSize, currentSize)) return;


  // adjust size
  [self resizeElement:_remoteElement
             fromSize:currentSize
               toSize:newSize
              metrics:metrics];

  // normalize constraint multipliers
  [self removeMultipliers:metrics];

  CGSize delta = CGSizeGetDelta(newSize, currentSize);

  [_context performBlockAndWait:^{   // wrap in managed object context block
    // adjust constants to account for shift in button group size
    for (Constraint * constraint in _remoteElement.dependentChildConstraints) {
      switch (constraint.firstAttribute) {
        // TODO: Handle all cases
        case NSLayoutAttributeBaseline:
        case NSLayoutAttributeBottom:
        case NSLayoutAttributeTop:
        case NSLayoutAttributeCenterY:
          constraint.constant += (contract.y == 0
                                  ? (offset.y
                                     ? offset.y / 2.0f
                                     : -expand.y / 2.0f)
                                  : offset.y - delta.height / 2.0f);
          break;

        case NSLayoutAttributeLeft:
        case NSLayoutAttributeLeading:
        case NSLayoutAttributeRight:
        case NSLayoutAttributeTrailing:
        case NSLayoutAttributeCenterX:
          constraint.constant += (contract.x == 0
                                  ? (offset.x
                                     ? offset.x / 2.0f
                                     : -expand.x / 2.0f)
                                  : offset.x - delta.width / 2.0f);
          break;

        case NSLayoutAttributeWidth:
          constraint.constant -= delta.width;
          break;

        case NSLayoutAttributeHeight:
          constraint.constant -= delta.height;
          break;

        case NSLayoutAttributeNotAnAttribute:
          assert(NO);
          break;
      }
    }

    [_context processPendingChanges];
  }];
}

- (void)removeProportionLockForElement:(RemoteElement *)element
                           currentSize:(CGSize)currentSize {
  [_context performBlockAndWait:
   ^{   // wrap method in managed object context block
    if (element.constraintManager.proportionLock) {
      Constraint * c =
        [element.intrinsicConstraints objectPassingTest:
         ^BOOL (Constraint * obj) {
        return (obj.secondItem == element);
      }];

      assert(c);
      // TODO: handle cases where element has constraints on proportion locked element

      NSLayoutAttribute firstAttribute = c.firstAttribute;
      [element removeConstraint:c];

      [element addConstraint:
       [Constraint
              constraintWithItem:element
                       attribute:firstAttribute
                       relatedBy:NSLayoutRelationEqual
                          toItem:nil
                       attribute:NSLayoutAttributeNotAnAttribute
                      multiplier:1.0f
                        constant:(firstAttribute == NSLayoutAttributeHeight
                                  ? currentSize.height
                                  : currentSize.width)]];
    }

    [_context processPendingChanges];
  }];
}

/**
 * Normalizes `remoteElementView.remoteElement.dependentChildConstraints` to have a multiplier of
 * `1.0`.
 */
- (void)removeMultipliers:(NSDictionary *)metrics {
  [_context performBlockAndWait:
   ^{   // wrap method in managed object context block
    for (Constraint * constraint in _remoteElement.dependentChildConstraints) {
      if (constraint.multiplier != 1.0f) {
        NSMutableDictionary * constraintValues =
          [[constraint dictionaryWithValuesForKeys:kConstraintPropertyKeys] mutableCopy];

        constraintValues[@"multiplier"] = @1.0f;
        [_remoteElement removeConstraint:constraint];
        CGRect frame = CGRectValue(metrics[constraint.firstItem.uuid]);
        CGRect bounds = (CGRect) {.
                                  size = CGRectValue(metrics[_remoteElement.uuid]).size };

        switch (constraint.firstAttribute) {
          case NSLayoutAttributeBaseline:
          case NSLayoutAttributeBottom:
            constraintValues[@"constant"] =
              @(CGRectGetMaxY(frame) - bounds.size.height);
            break;

          case NSLayoutAttributeTop:
            constraintValues[@"constant"] = @(frame.origin.y);
            break;

          case NSLayoutAttributeCenterY:
            constraintValues[@"constant"] =
              @(CGRectGetMidY(frame) - bounds.size.height / 2.0);
            break;

          case NSLayoutAttributeLeft:
          case NSLayoutAttributeLeading:
            constraintValues[@"constant"] = @(frame.origin.x);
            break;

          case NSLayoutAttributeCenterX:
            constraintValues[@"constant"] =
              @(CGRectGetMidX(frame) - bounds.size.width / 2.0);
            break;

          case NSLayoutAttributeRight:
          case NSLayoutAttributeTrailing:
            constraintValues[@"constant"] = @(CGRectGetMaxX(frame) - bounds.size.width);
            break;

          case NSLayoutAttributeWidth:
            constraintValues[@"constant"] = @(frame.size.width - bounds.size.width);
            break;

          case NSLayoutAttributeHeight:
            constraintValues[@"constant"] = @(frame.size.height - bounds.size.height);
            break;

          case NSLayoutAttributeNotAnAttribute:
          default:
            assert(NO);
            break;
        }

        [_remoteElement addConstraint:[Constraint
                                       constraintWithAttributeValues:constraintValues]];
      }
    }

    [_context processPendingChanges];
  }];
}

- (void)freezeConstraints:(NSSet *)constraints
            forAttributes:(NSSet *)attributes
                  metrics:(NSDictionary *)metrics {
  [_context performBlockAndWait:
   ^{   // wrap method in managed object context block
    for (Constraint * constraint in constraints) {
      if (![attributes containsObject:@(constraint.firstAttribute)]) continue;

      NSMutableDictionary * constraintValues =
        [[constraint dictionaryWithValuesForKeys:kConstraintPropertyKeys] mutableCopy];

      assert(ValueIsNotNil(constraint.owner));
      [constraint.owner removeConstraint:constraint];

      CGRect bounds = (CGRect) {.size = CGRectValue(metrics[_remoteElement.uuid]).size };
      CGRect frame  = CGRectValue(metrics[constraint.firstItem.uuid]);

      switch (UnsignedIntegerValue(constraintValues[@"firstAttribute"])) {
        case NSLayoutAttributeBottom:
          constraintValues[@"constant"] = @(CGRectGetMaxY(frame) - bounds.size.height);
          constraintValues[@"secondAttribute"] = @(NSLayoutAttributeBottom);
          constraintValues[@"secondItem"] =
            ((RemoteElement *)constraintValues[@"firstItem"]).parentElement;
          break;

        case NSLayoutAttributeTop:
          constraintValues[@"constant"] = @(frame.origin.y);
          constraintValues[@"secondAttribute"] = @(NSLayoutAttributeTop);
          constraintValues[@"secondItem"] =
            ((RemoteElement *)constraintValues[@"firstItem"]).parentElement;
          break;

        case NSLayoutAttributeLeft:
        case NSLayoutAttributeLeading:
          constraintValues[@"constant"] = @(frame.origin.x);
          constraintValues[@"secondAttribute"] = @(NSLayoutAttributeLeft);
          constraintValues[@"secondItem"] =
            ((RemoteElement *)constraintValues[@"firstItem"]).parentElement;
          break;

        case NSLayoutAttributeRight:
        case NSLayoutAttributeTrailing:
          constraintValues[@"constant"] = @(CGRectGetMaxX(frame) - bounds.size.width);
          constraintValues[@"secondAttribute"] = @(NSLayoutAttributeRight);
          constraintValues[@"secondItem"] =
            ((RemoteElement *)constraintValues[@"firstItem"]).parentElement;
          break;

        case NSLayoutAttributeCenterX:
          constraintValues[@"constant"] = @(CGRectGetMidX(frame) - CGRectGetMidX(bounds));
          constraintValues[@"secondAttribute"] = @(NSLayoutAttributeCenterX);
          constraintValues[@"secondItem"] =
            ((RemoteElement *)constraintValues[@"firstItem"]).parentElement;
          break;

        case NSLayoutAttributeCenterY:
          constraintValues[@"constant"] = @(CGRectGetMidY(frame) - CGRectGetMidY(bounds));
          constraintValues[@"secondAttribute"] = @(NSLayoutAttributeCenterY);
          constraintValues[@"secondItem"] =
            ((RemoteElement *)constraintValues[@"firstItem"]).parentElement;
          break;

        case NSLayoutAttributeWidth:
          constraintValues[@"constant"] = @(frame.size.width);
          constraintValues[@"owner"] = constraintValues[@"firstItem"];
          constraintValues[@"secondAttribute"] = @(NSLayoutAttributeNotAnAttribute);
          constraintValues[@"secondItem"] = NullObject;
          break;

        case NSLayoutAttributeHeight:
          constraintValues[@"constant"] = @(frame.size.height);
          constraintValues[@"owner"] = constraintValues[@"firstItem"];
          constraintValues[@"secondAttribute"] = @(NSLayoutAttributeNotAnAttribute);
          constraintValues[@"secondItem"] = NullObject;
          break;

        case NSLayoutAttributeBaseline:
        case NSLayoutAttributeNotAnAttribute:
          assert(NO);
          break;
      }

      RemoteElement * owner = constraintValues[@"owner"];
      assert(ValueIsNotNil(owner));
      [owner addConstraint:
       [Constraint constraintWithAttributeValues:constraintValues]];
    }

    [_context processPendingChanges];
  }];
}

- (void)freezeSize:(CGSize)size
     forSubelement:(RemoteElement *)subelement
         attribute:(NSLayoutAttribute)attribute {

  UILayoutConstraintAxis axis = UILayoutConstraintAxisForAttribute(attribute);
  CGFloat                constant;
  NSLayoutAttribute      firstAttribute;

  if (axis == UILayoutConstraintAxisHorizontal) {
    if (subelement.constraintManager[NSLayoutAttributeWidth]) return;

    constant       = size.width;
    firstAttribute = NSLayoutAttributeWidth;
  } else   {
    if (subelement.constraintManager[NSLayoutAttributeHeight]) return;

    constant       = size.height;
    firstAttribute = NSLayoutAttributeHeight;
  }

  [_context performBlockAndWait:
   ^{   // wrap method in managed object context block

    NSSet * constraintsToRemove;

    switch (attribute) {
      case NSLayoutAttributeBaseline:
      case NSLayoutAttributeBottom:

        // remove top
        if (subelement.constraintManager[NSLayoutAttributeTop])
          constraintsToRemove = [subelement.constraintManager
                                 constraintsForAttribute:NSLayoutAttributeTop
                                                   order:RELayoutConstraintFirstOrder];

        break;

      case NSLayoutAttributeTop:

        // remove bottom
        if (subelement.constraintManager[NSLayoutAttributeBottom])
          constraintsToRemove = [subelement.constraintManager
                                 constraintsForAttribute:NSLayoutAttributeBottom
                                                   order:RELayoutConstraintFirstOrder];

        break;

      case NSLayoutAttributeLeft:
      case NSLayoutAttributeLeading:

        // remove right
        if (subelement.constraintManager[NSLayoutAttributeRight])
          constraintsToRemove = [subelement.constraintManager
                                 constraintsForAttribute:NSLayoutAttributeRight
                                                   order:RELayoutConstraintFirstOrder];

        break;

      case NSLayoutAttributeRight:
      case NSLayoutAttributeTrailing:

        // remove left
        if (subelement.constraintManager[NSLayoutAttributeLeft])
          constraintsToRemove = [subelement.constraintManager
                                 constraintsForAttribute:NSLayoutAttributeLeft
                                                   order:RELayoutConstraintFirstOrder];

        break;

      case NSLayoutAttributeCenterX:

        // remove left and right
        if (  subelement.constraintManager[NSLayoutAttributeRight]
           || subelement.constraintManager[NSLayoutAttributeLeft])
          constraintsToRemove =
            [[subelement.constraintManager
              constraintsForAttribute:NSLayoutAttributeRight
                                order:RELayoutConstraintFirstOrder]
                      setByAddingObjectsFromSet:[subelement.constraintManager
                                                 constraintsForAttribute:NSLayoutAttributeLeft
                                                                   order:RELayoutConstraintFirstOrder]];

        break;

      case NSLayoutAttributeCenterY:

        // remove top and bottom
        if (  subelement.constraintManager[NSLayoutAttributeTop]
           || subelement.constraintManager[NSLayoutAttributeBottom])
          constraintsToRemove =
            [[subelement.constraintManager
              constraintsForAttribute:NSLayoutAttributeTop
                                order:RELayoutConstraintFirstOrder]
                      setByAddingObjectsFromSet:[subelement.constraintManager
                                                 constraintsForAttribute:NSLayoutAttributeBottom
                                                                   order:RELayoutConstraintFirstOrder]];

        break;

      case NSLayoutAttributeWidth:
      case NSLayoutAttributeHeight:
      case NSLayoutAttributeNotAnAttribute:
      default:
        assert(NO);
        break;
    }

    for (Constraint * constraint in constraintsToRemove)
      [constraint.owner removeConstraint:constraint];

    [subelement addConstraint:[Constraint constraintWithItem:subelement
                                                   attribute:firstAttribute
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:nil
                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                  multiplier:1.0f
                                                    constant:constant]];
    [_context processPendingChanges];
  }];
}

- (void)resolveConflictsForConstraint:(Constraint *)constraint
                              metrics:(NSDictionary *)metrics {
  [_context performBlockAndWait:
   ^{   // wrap method in managed object context block
    NSArray * additions = nil;

    NSArray * replacements = [constraint.manager
                              replacementCandidatesForAddingAttribute:constraint.firstAttribute
                                                            additions:&additions];

    NSSet * removal = [constraint.firstItem.firstItemConstraints
                       objectsPassingTest:^BOOL (Constraint * obj, BOOL * stop) {
      return [replacements containsObject:@(obj.firstAttribute)];
    }];

    CGRect frame = CGRectValue(metrics[constraint.firstItem.uuid]);
    CGRect bounds = (CGRect) {
      .size = CGRectValue(metrics[constraint.firstItem.parentElement.uuid]).size
    };

    for (Constraint * constraint in removal)
      [constraint.owner removeConstraint:constraint];

    for (NSNumber * n in additions) {
      NSLayoutAttribute firstAttribute = UnsignedIntegerValue(n), secondAttribute;
      CGFloat constant;
      RemoteElement * owner, *firstItem = constraint.firstItem, *secondItem = nil;

      switch (firstAttribute) {
        case NSLayoutAttributeCenterX: {
          secondAttribute = NSLayoutAttributeCenterX;
          owner = _remoteElement;
          secondItem = _remoteElement;
          constant = CGRectGetMidX(frame) - CGRectGetMidX(bounds);
          break;
        }

        case NSLayoutAttributeCenterY: {
          secondAttribute = NSLayoutAttributeCenterY;
          owner = _remoteElement;
          secondItem = _remoteElement;
          constant = CGRectGetMidY(frame) - CGRectGetMidY(bounds);
          break;
        }

        case NSLayoutAttributeWidth: {
          secondAttribute = NSLayoutAttributeNotAnAttribute;
          owner = firstItem;
          constant = frame.size.width;
          break;
        }

        case NSLayoutAttributeHeight: {
          secondAttribute = NSLayoutAttributeNotAnAttribute;
          owner = firstItem;
          constant = frame.size.height;
          break;
        }

        default:
          assert(NO);
          break;
      }

      [owner addConstraint:[Constraint constraintWithItem:firstItem
                                                attribute:firstAttribute
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:secondItem
                                                attribute:secondAttribute
                                               multiplier:1.0f
                                                 constant:constant]];
    }

    [_context processPendingChanges];
  }];
}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - Layout
////////////////////////////////////////////////////////////////////////////////

NSUInteger bitIndexForNSLayoutAttribute(NSLayoutAttribute attribute);
NSLayoutAttribute attributeForBitIndex(NSUInteger index);

- (NSNumber *)objectForKeyedSubscript:(NSString *)key {
  return self[[NSLayoutConstraint attributeForPseudoName:key]];
}

- (void)setObject:(NSNumber *)object forKeyedSubscript:(NSString *)key {
  self[[NSLayoutConstraint attributeForPseudoName:key]] = object;
}

- (NSNumber *)objectAtIndexedSubscript:(NSLayoutAttribute)idx {
  NSUInteger bitIndex = bitIndexForNSLayoutAttribute(idx);

  return (bitIndex == NSNotFound ? @NO : self.bitVector[bitIndex]);
}

- (void)setObject:(NSNumber *)object atIndexedSubscript:(NSLayoutAttribute)idx {
  if (!object) object = @NO;

  NSUInteger bitIndex = bitIndexForNSLayoutAttribute(idx);
  assert(bitIndex != NSNotFound);
  self.bitVector[bitIndex] = object;
}

- (NSSet *)intrinsicConstraints {
  return [_remoteElement.constraints
          filteredSetUsingPredicateWithBlock:
          ^BOOL (Constraint * constraint, NSDictionary * bindings)
  {
    return (  constraint.firstItem == self.remoteElement
           && (!constraint.secondItem || constraint.secondItem == self.remoteElement));
  }];
}

- (NSSet *)subelementConstraints {
  return [self.remoteElement.constraints setByRemovingObjectsFromSet:self.intrinsicConstraints];
}

- (NSSet *)dependentChildConstraints {
  return [self.dependentConstraints
          objectsPassingTest:
          ^BOOL (Constraint * constraint, BOOL * stop)
  {
    return [self.remoteElement.subelements containsObject:constraint.firstItem];
  }];
}

- (NSSet *)dependentConstraints {
  return [self.remoteElement.secondItemConstraints setByRemovingObjectsFromSet:self.intrinsicConstraints];
}

- (NSSet *)dependentSiblingConstraints {
  return [self.dependentConstraints setByRemovingObjectsFromSet:self.dependentChildConstraints];
}

- (void)refreshConfig {
  _proportionLock = NO;
  MSBitVector * bv = BitVector8;
  [self.remoteElement.firstItemConstraints
     enumerateObjectsUsingBlock:^(Constraint * constraint, BOOL * stop)
  {
    uint8_t bitIndex = bitIndexForNSLayoutAttribute(constraint.firstAttribute);
    bv[bitIndex] = @YES;
    _relationships[bitIndex] = @(remoteElementRelationshipTypeForConstraint(self.remoteElement, constraint));

    if (  constraint.firstItem == constraint.secondItem
       && (  constraint.firstAttribute == NSLayoutAttributeWidth
          || constraint.firstAttribute == NSLayoutAttributeHeight))
      _proportionLock = YES;
  }];

  if (self.bitVector != bv) _bitVector.bits = bv.bits;

  if (!_receptionist) {
    _receptionist = [MSContextChangeReceptionist
                     receptionistWithObserver:self
                                    forObject:self.remoteElement
                             notificationName:NSManagedObjectContextObjectsDidChangeNotification
                                updateHandler:^(MSContextChangeReceptionist * receptionist) {
                                  if ([receptionist.object hasChangesForKey:@"firstItemConstraints"])
                                    [(ConstraintManager *)receptionist.observer refreshConfig];
                                }

                                deleteHandler:nil];
  }
}

- (RELayoutConfigurationDependencyType)dependencyTypeForAttribute:(NSLayoutAttribute)attribute {
  if (!self[attribute])
    return RELayoutConfigurationUnspecifiedDependency;
  else
    return [_relationships[bitIndexForNSLayoutAttribute(attribute)] unsignedShortValue];
}

- (NSArray *)replacementCandidatesForAddingAttribute:(NSLayoutAttribute)attribute
                                           additions:(NSArray **)additions {
  switch (attribute) {
    case NSLayoutAttributeBaseline:
    case NSLayoutAttributeBottom:

      if (self[@"height"])
        return (self[@"centerY"] ? @[@(NSLayoutAttributeCenterY)] : @[@(NSLayoutAttributeTop)]);
      else {
        *additions = @[@(NSLayoutAttributeHeight)];
        return @[@(NSLayoutAttributeCenterY), @(NSLayoutAttributeTop)];
      }

    case NSLayoutAttributeTop:

      if (self[@"height"])
        return (self[@"centerY"] ? @[@(NSLayoutAttributeCenterY)] : @[@(NSLayoutAttributeBottom)]);
      else {
        *additions = @[@(NSLayoutAttributeHeight)];
        return @[@(NSLayoutAttributeCenterY), @(NSLayoutAttributeBottom)];
      }

    case NSLayoutAttributeLeft:
    case NSLayoutAttributeLeading:

      if (self[@"width"])
        return (self[@"centerX"] ? @[@(NSLayoutAttributeCenterX)] : @[@(NSLayoutAttributeRight)]);
      else {
        *additions = @[@(NSLayoutAttributeWidth)];
        return @[@(NSLayoutAttributeCenterX), @(NSLayoutAttributeRight)];
      }

    case NSLayoutAttributeRight:
    case NSLayoutAttributeTrailing:

      if (self[@"width"])
        return (self[@"centerX"] ? @[@(NSLayoutAttributeCenterX)] : @[@(NSLayoutAttributeLeft)]);
      else {
        *additions = @[@(NSLayoutAttributeWidth)];
        return @[@(NSLayoutAttributeCenterX), @(NSLayoutAttributeLeft)];
      }

    case NSLayoutAttributeCenterX:

      if (self[@"width"])
        return (self[@"left"] ? @[@(NSLayoutAttributeLeft)] : @[@(NSLayoutAttributeRight)]);
      else {
        *additions = @[@(NSLayoutAttributeWidth)];
        return @[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight)];
      }

    case NSLayoutAttributeCenterY:

      if (self[@"height"])
        return (self[@"top"] ? @[@(NSLayoutAttributeTop)] : @[@(NSLayoutAttributeBottom)]);
      else {
        *additions = @[@(NSLayoutAttributeHeight)];
        return @[@(NSLayoutAttributeTop), @(NSLayoutAttributeBottom)];
      }

    case NSLayoutAttributeWidth:

      if (self[@"centerX"])
        return (self[@"left"] ? @[@(NSLayoutAttributeLeft)] : @[@(NSLayoutAttributeRight)]);
      else {
        *additions = @[@(NSLayoutAttributeCenterX)];
        return @[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight)];
      }

    case NSLayoutAttributeHeight:

      if (self[@"centerY"])
        return (self[@"top"] ? @[@(NSLayoutAttributeTop)] : @[@(NSLayoutAttributeBottom)]);
      else {
        *additions = @[@(NSLayoutAttributeCenterY)];
        return @[@(NSLayoutAttributeTop), @(NSLayoutAttributeBottom)];
      }

    case NSLayoutAttributeNotAnAttribute:
    default:
      return nil;
  }
}

- (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute {
  return [self constraintsForAttribute:attribute order:RELayoutConstraintUnspecifiedOrder];
}

- (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute order:(RELayoutConstraintOrder)order {
  if (!self[attribute]) return nil;

  NSMutableSet * constraints = [NSMutableSet set];

  if (!order || order == RELayoutConstraintFirstOrder)
    [constraints unionSet:[self.remoteElement.firstItemConstraints
                           objectsPassingTest:
                           ^BOOL (Constraint * obj, BOOL * stop)
    {
      return (obj.firstAttribute == attribute);
    }]];

  if (!order || order == RELayoutConstraintSecondOrder)
    [constraints unionSet:[self.remoteElement.secondItemConstraints
                           objectsPassingTest:
                           ^BOOL (Constraint * obj, BOOL * stop)
    {
      return (obj.secondAttribute == attribute);
    }]];

  return (constraints.count ? constraints : nil);
}

- (Constraint *)constraintWithValues:(NSDictionary *)attributes {
  return [self.remoteElement.firstItemConstraints objectPassingTest:
          ^BOOL (Constraint * obj)
  {
    return [obj hasAttributeValues:attributes];
  }];
}

- (NSSet *)constraintsAffectingAxis:(UILayoutConstraintAxis)axis order:(RELayoutConstraintOrder)order {
  NSMutableSet * constraints = [NSMutableSet set];

  if (!order || order == RELayoutConstraintFirstOrder)
    [constraints unionSet:
     [self.remoteElement.firstItemConstraints objectsPassingTest:
          ^BOOL (Constraint * obj, BOOL * stop)
    {
      return (axis == UILayoutConstraintAxisForAttribute(obj.firstAttribute));
    }]];

  if (!order || order == RELayoutConstraintSecondOrder)
    [constraints unionSet:
     [self.remoteElement.secondItemConstraints objectsPassingTest:
          ^BOOL (Constraint * obj, BOOL * stop)
    {
      return (axis == UILayoutConstraintAxisForAttribute(obj.secondAttribute));
    }]];

  return (constraints.count ? constraints : nil);
}

////////////////////////////////////////////////////////////////////////////////
/// MARK: - Descriptions
////////////////////////////////////////////////////////////////////////////////

- (NSString *)layoutDescription {
  NSMutableString * s = [@"" mutableCopy];

  if (!UnsignedIntegerValue(_bitVector.bits)) [self refreshConfig];

  if ([_bitVector[7] boolValue]) [s appendString:@"L"];

  if ([_bitVector[6] boolValue]) [s appendString:@"R"];

  if ([_bitVector[5] boolValue]) [s appendString:@"T"];

  if ([_bitVector[4] boolValue]) [s appendString:@"B"];

  if ([_bitVector[3] boolValue]) [s appendString:@"X"];

  if ([_bitVector[2] boolValue]) [s appendString:@"Y"];

  if ([_bitVector[1] boolValue]) [s appendString:@"W"];

  if ([_bitVector[0] boolValue]) [s appendString:@"H"];

  return s;
}

- (NSString *)binaryDescription { return [_bitVector binaryDescription]; }

@end

UILayoutConstraintAxis UILayoutConstraintAxisForAttribute(NSLayoutAttribute attribute) {
  static dispatch_once_t onceToken;
  static const NSSet   * horizontalAxisAttributes = nil, * verticalAxisAttributes = nil;

  dispatch_once(&onceToken, ^{
    horizontalAxisAttributes = [@[@(NSLayoutAttributeWidth),
                                  @(NSLayoutAttributeLeft),
                                  @(NSLayoutAttributeLeading),
                                  @(NSLayoutAttributeRight),
                                  @(NSLayoutAttributeTrailing),
                                  @(NSLayoutAttributeCenterX)] set];
    verticalAxisAttributes   = [@[@(NSLayoutAttributeHeight),
                                  @(NSLayoutAttributeTop),
                                  @(NSLayoutAttributeBottom),
                                  @(NSLayoutAttributeBaseline),
                                  @(NSLayoutAttributeCenterY)] set];
  }

  );

  if ([horizontalAxisAttributes containsObject:@(attribute)])
    return UILayoutConstraintAxisHorizontal;
  else if ([verticalAxisAttributes containsObject:@(attribute)])
    return UILayoutConstraintAxisVertical;
  else
    return -1;
}

RELayoutConstraintAffiliation remoteElementAffiliationWithConstraint(RemoteElement * element, Constraint * constraint)                               {
  RELayoutConstraintAffiliation affiliation = RELayoutConstraintUnspecifiedAffiliation;

  RemoteElement * owner, * firstItem, * secondItem;

  if ([constraint isDeleted]) {
    NSDictionary * dict = [constraint committedValuesForKeys:@[REOwner,
                                                               REFirstItem,
                                                               RESecondItem]];
    owner      = dict[REOwner];
    firstItem  = dict[REFirstItem];
    secondItem = dict[RESecondItem];
  } else   {
    owner      = constraint.owner;
    firstItem  = constraint.firstItem;
    secondItem = constraint.secondItem;
  }

  if (owner == element) affiliation |= RELayoutConstraintOwnerAffiliation;

  if (firstItem == element) affiliation |= RELayoutConstraintFirstItemAffiliation;

  if (secondItem == element) affiliation |= RELayoutConstraintSecondItemAffiliation;

  return affiliation;
}

RERelationshipType remoteElementRelationshipTypeForConstraint(RemoteElement * element, Constraint * constraint)                    {
  RemoteElement * firstItem, * secondItem;

  if ([constraint isDeleted]) {
    NSDictionary * dict = [constraint committedValuesForKeys:@[REFirstItem, RESecondItem]];
    firstItem  = dict[REFirstItem];
    secondItem = dict[RESecondItem];
  } else {
    firstItem  = constraint.firstItem;
    secondItem = constraint.secondItem;
  }

  RELayoutConstraintAffiliation affiliation = remoteElementAffiliationWithConstraint(firstItem,
                                                                                     constraint);

  if (  (affiliation & RELayoutConstraintFirstItemAffiliation)
     && (!secondItem || (affiliation & RELayoutConstraintSecondItemAffiliation)))
    return REIntrinsicRelationship;
  else if (  (affiliation & RELayoutConstraintFirstItemAffiliation)
          && firstItem.parentElement == secondItem)
    return REChildRelationship;
  else if (  (affiliation & RELayoutConstraintSecondItemAffiliation)
          && firstItem.parentElement == secondItem)
    return REParentRelationship;
  else if (firstItem.parentElement == secondItem.parentElement)
    return RESiblingRelationship;
  else
    return REUnspecifiedRelation;
}

NSUInteger bitIndexForNSLayoutAttribute(NSLayoutAttribute attribute) {
  switch (attribute) {
    case NSLayoutAttributeLeft:
    case NSLayoutAttributeLeading:          return 7;
    case NSLayoutAttributeRight:
    case NSLayoutAttributeTrailing:         return 6;
    case NSLayoutAttributeTop:              return 5;
    case NSLayoutAttributeBaseline:
    case NSLayoutAttributeBottom:           return 4;
    case NSLayoutAttributeCenterX:          return 3;
    case NSLayoutAttributeCenterY:          return 2;
    case NSLayoutAttributeWidth:            return 1;
    case NSLayoutAttributeHeight:           return 0;
    case NSLayoutAttributeNotAnAttribute:   return NSNotFound;
  }
}

NSLayoutAttribute attributeForBitIndex(NSUInteger index) {
  switch (index) {
    case 7:  return NSLayoutAttributeLeft;
    case 6:  return NSLayoutAttributeRight;
    case 5:  return NSLayoutAttributeTop;
    case 4:  return NSLayoutAttributeBottom;
    case 3:  return NSLayoutAttributeCenterX;
    case 2:  return NSLayoutAttributeCenterY;
    case 1:  return NSLayoutAttributeWidth;
    case 0:  return NSLayoutAttributeHeight;
    default: return NSLayoutAttributeNotAnAttribute;
  }
}
