//
//  BankCollectionViewFlowLayout.m
//  Remote
//
//  Created by Jason Cardwell on 9/28/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankCollectionViewFlowLayout.h"

static int       ddLogLevel   = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)


@implementation BankCollectionViewFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
  NSMutableArray         * a             = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
  UICollectionView * const cv            = self.collectionView;
  CGPoint const            contentOffset = cv.contentOffset;

  NSMutableIndexSet * missingSections = [NSMutableIndexSet indexSet];

  for (UICollectionViewLayoutAttributes * layoutAttributes in a)
    if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell)
      [missingSections addIndex:layoutAttributes.indexPath.section];



  for (UICollectionViewLayoutAttributes * layoutAttributes in a)
    if ([layoutAttributes.representedElementKind
         isEqualToString:UICollectionElementKindSectionHeader])
      [missingSections removeIndex:layoutAttributes.indexPath.section];



  [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * stop) {

    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
    
    UICollectionViewLayoutAttributes * layoutAttributes =
      [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                           atIndexPath:indexPath];

    if (layoutAttributes) [a addObject:layoutAttributes];
  }];
  
  CGFloat topLayoutGuideLength = ([cv.delegate isKindOfClass:[UIViewController class]]
                                  ? ((UIViewController *)cv.delegate).topLayoutGuide.length
                                  : 0);

  for (UICollectionViewLayoutAttributes * layoutAttributes in a) {

    if ([layoutAttributes.representedElementKind
         isEqualToString:UICollectionElementKindSectionHeader])
    {

      NSInteger section   = layoutAttributes.indexPath.section;
      NSInteger itemCount = [cv numberOfItemsInSection:section];

      if (itemCount) {
        NSIndexPath * firstCell = [NSIndexPath indexPathForItem:0 inSection:section];
        NSIndexPath * lastCell  = [NSIndexPath indexPathForItem:MAX(0, (itemCount - 1))
                                                      inSection:section];

        UICollectionViewLayoutAttributes * firstCellAttrs =
          [self layoutAttributesForItemAtIndexPath:firstCell];
        UICollectionViewLayoutAttributes * lastCellAttrs =
          [self layoutAttributesForItemAtIndexPath:lastCell];

        CGFloat headerHeight = CGRectGetHeight(layoutAttributes.frame);
        CGPoint origin       = layoutAttributes.frame.origin;
        origin.y = MIN(MAX(contentOffset.y + topLayoutGuideLength,
                           (CGRectGetMinY(firstCellAttrs.frame) - headerHeight)),
                       (CGRectGetMaxY(lastCellAttrs.frame) - headerHeight));

        layoutAttributes.zIndex = 1024;
        layoutAttributes.frame  = (CGRect) {
          .origin = origin,
          .size   = layoutAttributes.frame.size
        };
      }
    }
  }

  return a;

}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound { return YES; }

@end
