//
//  REPresetCollectionViewController.m
//  Remote
//
//  Created by Jason Cardwell on 4/2/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "REPresetCollectionViewController.h"
#import "BOPreset.h"
#import "BankObjectPreview.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - BOPresetCell
////////////////////////////////////////////////////////////////////////////////

@interface BOPresetCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView * imageView;

@end

@implementation BOPresetCell

- (id)init
{
    if (self = [super init])
        [self initialize];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
        [self initialize];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
        [self initialize];
        return self;
}

- (void)initialize
{
    self.imageView = [UIImageView new];
    [self.contentView addSubview:_imageView];
}

- (void)setImage:(UIImage *)image
{
    _imageView.image = image;
    [_imageView sizeToFit];
}

@end

@interface REPresetCollectionViewController () {
    NSArray          * _presetImages;
}

@property (nonatomic, strong) NSArray * presets;

@end

MSKIT_STATIC_STRING_CONST reuseIdentifier = @"BOPresetCell";

@implementation REPresetCollectionViewController

+ (REPresetCollectionViewController *)presetControllerWithLayout:(UICollectionViewLayout *)layout
{
    return [[self alloc] initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerClass:[BOPresetCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.backgroundColor = [WhiteColor colorWithAlphaComponent:0.75];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDataSource
////////////////////////////////////////////////////////////////////////////////

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeAspectMappedToHeight(((UIImage *)_presetImages[indexPath.row]).size,
                                             self.collectionView.height);
}

- (BOPresetCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOPresetCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                    forIndexPath:indexPath];

    [cell setImage:_presetImages[indexPath.row]];

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.presets.count;
}

- (NSArray *)presets
{
    if (!_presets && _context)
    {
        [_context performBlockAndWait:
         ^{
             _presets =
                 [_context
                  executeFetchRequest:[NSFetchRequest
                                       fetchRequestWithEntityName:ClassString([BOPreset class])]
                               error:nil];
             if (_presets.count) _presetImages = [_presets valueForKeyPath:@"preview.image"];
         }];
    }
    return _presets;
}



@end
