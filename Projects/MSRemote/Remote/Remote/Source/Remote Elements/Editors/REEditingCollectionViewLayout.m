//
//  REEditingCollectionViewLayout.m
//  Remote
//
//  Created by Jason Cardwell on 4/2/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REEditingCollectionViewLayout.h"

@implementation REEditingCollectionViewLayout

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Subclassing Hooks
////////////////////////////////////////////////////////////////////////////////

- (CGSize)collectionViewContentSize
{
    assert(NO);
    return CGSizeZero;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    UICollectionViewLayoutAttributes * attributes = [UICollectionViewLayoutAttributes
                                                     layoutAttributesForCellWithIndexPath:path];
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)path
{
    UICollectionViewLayoutAttributes * attributes = [UICollectionViewLayoutAttributes
                                                     layoutAttributesForSupplementaryViewOfKind:kind
                                                                                  withIndexPath:path];
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)kind
                                                                  atIndexPath:(NSIndexPath *)path
{
    UICollectionViewLayoutAttributes * attributes = [UICollectionViewLayoutAttributes
                                                     layoutAttributesForDecorationViewOfKind:kind
                                                                               withIndexPath:path];
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    assert(NO);
    return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    assert(NO);
    return YES;
}

//+ (Class)layoutAttributesClass;
//- (void)prepareLayout;
//- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
//                                 withScrollingVelocity:(CGPoint)velocity;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Update Support Hooks
////////////////////////////////////////////////////////////////////////////////

//- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems;
//- (void)finalizeCollectionViewUpdates;
//- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds;
//- (void)finalizeAnimatedBoundsChange;
//- (UICollectionViewLayoutAttributes *)
//  initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath;
//- (UICollectionViewLayoutAttributes *)
//  finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath;
//- (UICollectionViewLayoutAttributes *)
//  initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind
//                                                    atIndexPath:(NSIndexPath *)elementIndexPath;
//- (UICollectionViewLayoutAttributes *)
//  finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind
//                                                     atIndexPath:(NSIndexPath *)elementIndexPath;
//- (UICollectionViewLayoutAttributes *)
//  initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind
//                                                 atIndexPath:(NSIndexPath *)decorationIndexPath;
//- (UICollectionViewLayoutAttributes *)
//  finalLayoutAttributesForDisappearingDecorationElementOfKind:(NSString *)elementKind
//                                                  atIndexPath:(NSIndexPath *)decorationIndexPath;

@end
