//
// RemoteElementViewConstraintManager.m
// iPhonto
//
// Created by Jason Cardwell on 1/17/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementViewConstraintManager.h"
#import "RemoteElementConstraintManager.h"
#import "RemoteElementView_Private.h"
#import "RemoteElement_Private.h"
#import "RemoteElementLayoutConstraint.h"

static const int   msLogContext = CONSTRAINT_LC;
static const int   ddLogLevel   = LOG_LEVEL_DEBUG;

// static const int ddLogLevel = DefaultDDLogLevel;
#pragma unused(ddLogLevel,msLogContext)


NSDictionary * viewFramesByIdentifier(RemoteElementView * remoteElementView) {
    NSMutableDictionary * dict =
        [NSMutableDictionary
         dictionaryWithObjects:[remoteElementView.subelementViews valueForKeyPath:@"frame"]
         forKeys:[remoteElementView.subelementViews valueForKeyPath:@"identifier"]];
    dict[remoteElementView.identifier] = RectValue(remoteElementView.frame);
    return dict;
}


static NSSet     * kAlignmentAttributes, *kSizeAttributes;
MSKIT_STRING_CONST   RemoteElementModelConstraintNametag = @"RemoteElementModelConstraintNametag";

@implementation RemoteElementViewConstraintManager {
    MSKVOReceptionist * _modelReceptionist;
    MSKVOReceptionist * _viewReceptionist;
    __weak RemoteElement * _model;
    __weak RemoteElementConstraintManager * _modelManager;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Creation
///@name Creation
////////////////////////////////////////////////////////////////////////////////

+ (void)initialize {
    if (self == [RemoteElementViewConstraintManager class]) {
        kAlignmentAttributes = [@[@(NSLayoutAttributeBottom),
                                  @(NSLayoutAttributeTop),
                                  @(NSLayoutAttributeLeft),
                                  @(NSLayoutAttributeRight),
                                  @(NSLayoutAttributeCenterX),
                                  @(NSLayoutAttributeCenterY)] set];
        kSizeAttributes      = [@[@(NSLayoutAttributeWidth),
                                @(NSLayoutAttributeHeight)] set];
    }
}

+ (RemoteElementViewConstraintManager *)constraintManagerForView:(RemoteElementView *)view {
    return [[self alloc] initWithView:view];
}

- (id)initWithView:(RemoteElementView *)view
{
    if ((self = [super init])) {
        _remoteElementView = view;
        _model             = _remoteElementView.remoteElement;
        _modelManager      = _model.constraintManager;
        
        [NotificationCenter addObserverForName:$(@"%@-%@",
                                                 REConstraintsDidChangeNotification,
                                                 _remoteElementView.identifier)
                                        object:nil
                                         queue:MainQueue
                                    usingBlock:^(NSNotification *note) {
                                        [_remoteElementView setNeedsUpdateConstraints];
                                    }];
    }

    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Manipulating constraints
///@name Manipulating constraints
////////////////////////////////////////////////////////////////////////////////

- (void)updateConstraints
{
    // TODO: Only replace constraints that have changed, etc.
    // TODO: Might be a good place to check for conflicts
    [_remoteElementView
     replaceConstraintsOfType:[RELayoutConstraint class]
     withConstraints:[[_remoteElementView.remoteElement.constraints setByMappingToBlock:
                      ^RELayoutConstraint * (RemoteElementLayoutConstraint * constraint) {
                          return [RELayoutConstraint constraintWithModel:constraint
                                                                 forView:_remoteElementView];
                      }] allObjects]];
}

- (void)resizeSubelements:(NSSet *)subelementViews
                toSibling:(RemoteElementView *)siblingView
                attribute:(NSLayoutAttribute)attribute
{
    [_modelManager resizeSubelements:[subelementViews valueForKeyPath:@"remoteElement"]
                           toSibling:siblingView.remoteElement
                           attribute:attribute
                             metrics:viewFramesByIdentifier(_remoteElementView)];
//    if (_shrinkWrap) [self shrinkWrapSubelementViews];
}

- (void)translateSubelements:(NSSet *)subelementViews translation:(CGPoint)translation
{
    [_modelManager translateSubelements:[subelementViews valueForKeyPath:@"remoteElement"]
                            translation:translation
                                metrics:viewFramesByIdentifier(_remoteElementView)];
    if (_shrinkWrap) [self shrinkWrapSubelementViews];
}

- (void)alignSubelements:(NSSet *)subelementViews
               toSibling:(RemoteElementView *)siblingView
               attribute:(NSLayoutAttribute)attribute
{
    [_modelManager alignSubelements:[subelementViews valueForKeyPath:@"remoteElement"]
                          toSibling:siblingView.remoteElement
                          attribute:attribute
                            metrics:viewFramesByIdentifier(_remoteElementView)];
//    if (_shrinkWrap) [self shrinkWrapSubelementViews];
}

- (void)scaleSubelements:(NSSet *)subelementViews scale:(CGFloat)scale
{
    for (RemoteElementView * subelementView in subelementViews) {
        CGSize   maxSize    = subelementView.maximumSize;
        CGSize   minSize    = subelementView.minimumSize;
        CGSize   scaledSize = CGSizeApplyScale(subelementView.bounds.size, scale);
        CGSize   newSize    = (CGSizeContainsSize(maxSize, scaledSize)
                               ? (CGSizeContainsSize(scaledSize, minSize)
                                  ? scaledSize
                                  : minSize
                                  )
                               : maxSize
                               );

        [_modelManager resizeElement:subelementView.remoteElement
                            fromSize:subelementView.bounds.size
                              toSize:newSize
                             metrics:viewFramesByIdentifier(_remoteElementView)];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Size Adjustments
///@name Size Adjustments
////////////////////////////////////////////////////////////////////////////////

/**
 * Convenience method that makes calls to `calculateShrinkWrap:expand:contract:offset:`,
 * `resizeView:`, and `removeMultipliers`.
 * Called from `shrinkWrapSubelementViews`
 *
 * @param size Upon return, `size` will point to a `CGSize` struct holding the calculated size to
 * shrink wrap
 *
 * @param expand Upon return, `expand` will point to a `CGPoint` struct holding the amount of x and
 * y expansion
 *
 * @param contract Upon return, `contract` will point a the `CGPoint` struct holding the amount of x
 * and y contraction
 *
 * @param offset Upon return, `offset` will point to a `CGPoint` struct holding the x and y offset
 * from current size
 *
 * @see calculateShrinkWrap:expand:contract:offset:
 */
- (void)sizeToFitSubelementViews:(CGSize *)newSize
                          expand:(CGPoint *)expand
                        contract:(CGPoint *)contract
                          offset:(CGPoint *)offset
{
//    [self calculateShrinkWrap:newSize expand:expand contract:contract offset:offset];
    [_remoteElementView updateConstraintsIfNeeded];

    // contract or expand button group to match buttons
    ////////////////////////////////////////////////////////////////////////////////
    CGFloat   minX = [[_remoteElementView.subelementViews valueForKeyPath:@"@min.minX"] floatValue];
    CGFloat   maxX = [[_remoteElementView.subelementViews valueForKeyPath:@"@max.maxX"] floatValue];
    CGFloat   minY = [[_remoteElementView.subelementViews valueForKeyPath:@"@min.minY"] floatValue];
    CGFloat   maxY = [[_remoteElementView.subelementViews valueForKeyPath:@"@max.maxY"] floatValue];

    CGSize    currentSize = _remoteElementView.bounds.size;

    CGFloat   contractX = (minX > 0                        // left edge needs to come in ?
                           ? -minX                         // move edge to left-most origin
                           : (maxX < currentSize.width     // right edge needs to push out?
                              ? currentSize.width - maxX   // push out the difference
                              : 0.0f));
    CGFloat   contractY = (minY > 0                        // top edge needs to come in?
                           ? -minY                         // move edge to top-most origin
                           : (maxY < currentSize.height    // bottom edge needs to push out?
                              ? currentSize.height - maxY  // push out the difference
                              : 0.0f));
    CGFloat   expandX = (maxX > currentSize.width          // right edge needs to push out?
                         ? maxX - currentSize.width        // move edge out the difference
                         : (minX < 0                       // left edge needs to push out?
                            ? minX                         // move edge out the difference
                            : 0.0f));
    CGFloat   expandY = (maxY > currentSize.height         // top edge needs to push out?
                         ? maxY - currentSize.height       // move edge out the difference
                         : (minY < 0                       // bottom edge needs to push out?
                            ? minY                         // move edge out the difference
                            : 0.0f));
    CGFloat   offsetX = (contractX < 0
                         ? contractX
                         : (expandX < 0
                            ? -expandX
                            : 0.0f));
    CGFloat   offsetY = (contractY < 0
                         ? contractY
                         : (expandY < 0
                            ? -expandY
                            : 0.0f));

    *contract = CGPointMake(contractX, contractY);
    *expand   = CGPointMake(expandX, expandY);
    *offset   = CGPointMake(offsetX, offsetY);
    *newSize  = CGSizeMake(MIN(_remoteElementView.parentElementView.bounds.size.width,
                               maxX - minX),
                           MIN(_remoteElementView.parentElementView.bounds.size.height,
                               maxY - minY));

    if (CGSizeEqualToSize(*newSize, _remoteElementView.bounds.size)) return;

    NSDictionary * metrics = viewFramesByIdentifier(_remoteElementView);

    // adjust size
    [_modelManager resizeElement:_model
                        fromSize:_remoteElementView.bounds.size
                          toSize:*newSize
                         metrics:metrics];

    // normalize constraint multipliers
    [_modelManager removeMultipliers:metrics];
}

/**
 * Method used to "shrink wrap" the `remoteElementView` around its `subelementViews` by
 * being exactly as big as it needs to full hold them all.
 */
- (void)shrinkWrapSubelementViews
{
    CGPoint   contract, expand, offset;
    CGSize    newSize;

    [self sizeToFitSubelementViews:&newSize expand:&expand contract:&contract offset:&offset];

    CGSize   delta = CGSizeGetDelta(newSize, _remoteElementView.bounds.size);

    // adjust constants to account for shift in button group size
    for (RemoteElementLayoutConstraint * constraint
         in _remoteElementView.remoteElement.dependentChildConstraints)
    {
        switch (constraint.firstAttribute)
        {
            // TODO: Handle all cases
            case NSLayoutAttributeBaseline:
            case NSLayoutAttributeBottom:
            case NSLayoutAttributeTop:
            case NSLayoutAttributeCenterY:
                constraint.constant += (contract.y == 0
                                        ? (offset.y
                                           ? offset.y / 2.0f
                                           : -expand.y / 2.0f
                                           )
                                        : offset.y - delta.height / 2.0f
                                        );
                break;

            case NSLayoutAttributeLeft:
            case NSLayoutAttributeLeading:
            case NSLayoutAttributeRight:
            case NSLayoutAttributeTrailing:
            case NSLayoutAttributeCenterX:
                constraint.constant += (contract.x == 0
                                        ? (offset.x
                                           ? offset.x / 2.0f
                                           : -expand.x / 2.0f
                                           )
                                        : offset.x - delta.width / 2.0f
                                        );
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

}

- (void)dealloc
{
    [NotificationCenter removeObserver:self];
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RELayoutConstraint Implementation
////////////////////////////////////////////////////////////////////////////////

@interface RELayoutConstraint ()

@property (nonatomic, assign, readwrite, getter = isValid) BOOL valid;

@end

@implementation RELayoutConstraint

+ (RELayoutConstraint *)constraintWithModel:(RemoteElementLayoutConstraint *)modelConstraint
                                    forView:(RemoteElementView *)view
{
    assert(  view
           && modelConstraint
           && ValueIsNotNil(modelConstraint.firstItem)
           && modelConstraint.firstAttribute
           && (  !modelConstraint.secondItem
               || [modelConstraint.secondItem.identifier
                   isEqualToString:view.identifier]
               || view[modelConstraint.secondItem.identifier]));

    RemoteElementView * firstItem = ([modelConstraint.firstItem.identifier
                                      isEqualToString:view.identifier]
                                     ? view
                                     : view[modelConstraint.firstItem.identifier]);
    RemoteElementView * secondItem = (modelConstraint.secondItem
                                      ? ([modelConstraint.secondItem.identifier
                                          isEqualToString:view.identifier]
                                         ? view
                                         : view[modelConstraint.secondItem.identifier])
                                      : nil);
    RELayoutConstraint * constraint = [RELayoutConstraint
                                       constraintWithItem:firstItem
                                       attribute:modelConstraint.firstAttribute
                                       relatedBy:modelConstraint.relation
                                       toItem:secondItem
                                       attribute:modelConstraint.secondAttribute
                                       multiplier:modelConstraint.multiplier
                                       constant:modelConstraint.constant];

    assert(constraint);

    constraint.priority        = modelConstraint.priority;
    constraint.tag             = modelConstraint.tag;
    constraint.nametag         = modelConstraint.key;
    constraint.modelConstraint = modelConstraint;
    constraint.view            = view;
    constraint.valid           = YES;
    [modelConstraint addObserver:constraint
                     forKeyPaths:@[@"constant",
                                   @"multiplier",
                                   @"firstAttribute",
                                   @"secondAttribute",
                                   @"firstItem",
                                   @"secondItem"]
                         options:NSKeyValueObservingOptionNew
                         context:NULL];

    return constraint;
}

/*
 * Observes model properties. Changes to `constant` are reflected by the constraint. Any other
 * changes cause the constraint to remove itself from its `view`.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == _modelConstraint && self.isValid) {
        if (   [_modelConstraint isDeleted]
            || !_modelConstraint.managedObjectContext
            || ![@"constant" isEqualToString:keyPath])
        {
            self.valid = NO;
        }

        else if (self.isValid)
        {
            id value = change[NSKeyValueChangeNewKey];
            self.constant = ValueIsNotNil(value)
                            ? Float(value)
                            : 0.0f;
        }
    }
}

- (NSString *)description {
    static NSString * (^ itemNameForView)(UIView *) = ^(UIView * view){
        return (view
                ? ([view isKindOfClass:[RemoteElementView class]]
                   ? [((RemoteElementView*)view).displayName camelCaseString]
                   : (view.accessibilityIdentifier
                      ? view.accessibilityIdentifier
                      : $(@"<%@:%p>", NSStringFromClass([view class]), view)
                      )
                   )
                : (NSString*)nil
                );
    };
    NSString * firstItem       = itemNameForView(self.firstItem);
    NSString * firstAttribute  = [NSLayoutConstraint pseudoNameForAttribute:self.firstAttribute];
    NSString * relation        = [NSLayoutConstraint pseudoNameForRelation:self.relation];
    NSString * secondItem      = itemNameForView(self.secondItem);
    NSString * secondAttribute = (self.secondAttribute != NSLayoutAttributeNotAnAttribute
                                  ? [NSLayoutConstraint pseudoNameForAttribute:self.secondAttribute]
                                  : nil);
    NSString * multiplier = (self.multiplier == 1.0f
                             ? nil
                             : [[NSString stringWithFormat:@"%f", self.multiplier]
                               stringByStrippingTrailingZeroes]);
    NSString * constant = (self.constant == 0.0f
                           ? nil
                           : [[NSString stringWithFormat:@"%f", self.constant]
                             stringByStrippingTrailingZeroes]);
    NSString * priority = (self.priority == UILayoutPriorityRequired
                           ? nil
                           : [NSString stringWithFormat:@"@%d", (int)self.priority]);
    NSMutableString * stringRep = [NSMutableString stringWithFormat:@"%@.%@ %@ ",
                                                                    firstItem,
                                                                    firstAttribute,
                                                                    relation];

    if (secondItem && secondAttribute)
    {
        [stringRep appendFormat:@"%@.%@", secondItem, secondAttribute];

        if (multiplier) [stringRep appendFormat:@" * %@", multiplier];

        if (constant)
        {
            if (self.constant < 0)
            {
                constant = [constant substringFromIndex:1];
                [stringRep appendString:@" - "];
            }
            else
                [stringRep appendString:@" + "];
        }
    }

    if (constant) [stringRep appendString:constant];

    if (priority) [stringRep appendFormat:@" %@", priority];

    return stringRep;
}

- (void)dealloc
{
    [_modelConstraint removeObserver:self
                         forKeyPaths:@[@"constant",
                                       @"multiplier",
                                       @"firstAttribute",
                                       @"secondAttribute",
                                       @"firstItem",
                                       @"secondItem"]];
}

@end
