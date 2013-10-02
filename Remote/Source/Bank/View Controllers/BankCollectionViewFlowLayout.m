//
//  BankCollectionViewFlowLayout.m
//  Remote
//
//  Created by Jason Cardwell on 9/28/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankCollectionViewFlowLayout.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)


@implementation BankCollectionViewFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray * attributes = [super layoutAttributesForElementsInRect:rect];

/*
    if (self.zoomIndexPath)
    {
        UICollectionViewLayoutAttributes * a = [attributes objectPassingTest:
                                                ^BOOL(UICollectionViewLayoutAttributes * obj, NSUInteger idx) {
                                                    return [obj.indexPath isEqual:_zoomIndexPath];
                                                }];
        assert(a);
        a.zIndex = 1;
        a.size = CGSizeMake(300, 300);
        a.center = CGRectGetCenter(self.collectionView.bounds);
    }
*/

    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes * attributes = [super layoutAttributesForItemAtIndexPath:indexPath];

    if ([indexPath isEqual:self.zoomIndexPath])
        MSLogDebug(@"zoomIndexPath: %@", indexPath);

    return attributes;
}

@end
