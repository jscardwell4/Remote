//
//  REBackgroundEditingViewController.m
//  Remote
//
//  Created by Jason Cardwell on 4/1/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REBackgroundCollectionViewController.h"
#import "Remote-Swift.h"

@interface REBackgroundCollectionViewController ()

//- (void)setBorderForView:(UIView *)view selected:(BOOL)selected;
//- (void)handleTap:(UIGestureRecognizer *)gestureRecognizer;
//- (IBAction)dismissPreview:(UITapGestureRecognizer *)sender;

@property (nonatomic, strong) NSArray * backgrounds;

@end

@implementation REBackgroundCollectionViewController

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"
                                                                            forIndexPath:indexPath];

    if (!cell.selectedBackgroundView)
    {
        UIView * view = [[UIView alloc] initWithFrame:cell.bounds];
        view.backgroundColor = [UIColor colorWithRed:0 green:175.0 / 255.0 blue:1.0 alpha:1.0];
        cell.selectedBackgroundView = view;
    }

    UIImage * image = nil;

    if (indexPath.row)
    {
        Image * backgroundImage = self.backgrounds[indexPath.row - 1];
        assert(backgroundImage);
        image = backgroundImage.image;
    }

    else
        image = [UIImage imageNamed:@"NoBackground.png"];

    UIImageView * imageView = (UIImageView *)[cell viewWithNametag:@"BOBackgroundImage"];

    if (!imageView)
    {
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.nametag = @"BOBackgroundImage";
        imageView.frame = CGRectInset(cell.bounds, 3, 3);
        [cell.contentView addSubview:imageView];
    }

    else
    {
        imageView.image = image;
        imageView.frame = CGRectInset(cell.bounds, 3, 3);
    }


    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.backgrounds.count + 1;
}

- (NSArray *)backgrounds
{
    if (!_backgrounds && _context)
    {
        __block NSArray * fetchedObjects = nil;
        [_context performBlockAndWait:^{
          fetchedObjects = [[[ImageCategory findFirstByAttribute:@"name"
                                                       withValue:@"Backgrounds"
                                                         context: _context] images] allObjects];
         }];
        _backgrounds = fetchedObjects;
    }
    return _backgrounds;
}

- (void)selectBackgroundImage:(Image *)backgroundImage
{
//    NSIndexPath * indexPath = nil;
//    if (!backgroundImage)
//    {
//        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    }

    if (backgroundImage)
    {
        NSUInteger index = 0;
//        [self.backgrounds indexOfObjectPassingTest:
//                            ^BOOL (BOImage * obj, NSUInteger idx, BOOL * stop)
//                            {
//                                    return (backgroundImage.tag == obj.tag);
//                            }];

        if (index != NSNotFound)
        {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index + 1 inSection:0];

            [self.collectionView
                 selectItemAtIndexPath:indexPath
                              animated:YES
                        scrollPosition: UICollectionViewScrollPositionCenteredVertically];
        }
    }
}

- (Image *)selectedImage
{
    NSArray * selection = [self.collectionView indexPathsForSelectedItems];
    if (selection.count == 1 && ((NSIndexPath *)selection[0]).row > 0)
        return _backgrounds[((NSIndexPath *)selection[0]).row - 1];
    else
        return nil;
}

- (void)setInitialImage:(Image *)initialImage
{
    _initialImage = initialImage;
    if (self.isViewLoaded)
        [self selectBackgroundImage:_initialImage];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![self.collectionView indexPathsForSelectedItems].count && _initialImage)
        [self selectBackgroundImage:_initialImage];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDelegate
////////////////////////////////////////////////////////////////////////////////

- (BOOL)       collectionView:(UICollectionView *)collectionView
  shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)          collectionView:(UICollectionView *)collectionView
  shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)    collectionView:(UICollectionView *)collectionView
  didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
