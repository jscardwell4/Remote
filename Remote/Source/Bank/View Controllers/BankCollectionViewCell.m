//
//  BankCollectionViewCell.m
//  Remote
//
//  Created by Jason Cardwell on 9/29/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankCollectionViewCell.h"
#import "BankCollectionViewController.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)


MSIDENTIFIER_DEFINITION(ListCell);
MSIDENTIFIER_DEFINITION(ThumbnailCell);

typedef NS_ENUM (uint8_t, BankCollectionViewCellType) {
  BankCollectionViewCellListType      = 0,
  BankCollectionViewCellThumbnailType = 1
};

@interface BankCollectionViewCell ()<UIScrollViewDelegate>

@property (nonatomic, weak, readwrite) IBOutlet UIImageView                  * thumbnailImageView;
@property (nonatomic, weak, readwrite) IBOutlet UILabel                      * nameLabel;
@property (nonatomic, weak, readwrite) IBOutlet UIButton                     * editButton;
@property (nonatomic, weak, readwrite) IBOutlet UIButton                     * detailButton;
@property (nonatomic, weak, readwrite) IBOutlet UIButton                     * deleteButton;
@property (nonatomic, weak, readwrite) IBOutlet BankCollectionViewController * controller;
@property (nonatomic, weak, readwrite) IBOutlet NSLayoutConstraint           * leadingConstraint;
@property (nonatomic, weak, readwrite) IBOutlet UIScrollView                 * scrollView;

@end

@implementation BankCollectionViewCell
{
  BankCollectionViewCellType _cellType;
  NSTimer                  * _swipeToDeleteTimer;
}


- (void)prepareForReuse {
  [super prepareForReuse];
  self.bankFlags      = BankDefault;
  self.thumbnailImage = nil;
  self.name           = nil;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  _cellType = ([self.reuseIdentifier isEqualToString:ThumbnailCellIdentifier]
               ? BankCollectionViewCellThumbnailType
               : BankCollectionViewCellListType);

  UITapGestureRecognizer * tap = [UITapGestureRecognizer
                                  gestureWithTarget:self
                                             action:@selector(thumbnailImageViewAction:)];
  [_thumbnailImageView addGestureRecognizer:tap];


  UISwipeGestureRecognizer * swipe = [UISwipeGestureRecognizer
                                      gestureWithTarget:self
                                                 action:@selector(swipeToDeleteAnimation:)];
  swipe.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
  [self addGestureRecognizer:swipe];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
////////////////////////////////////////////////////////////////////////////////

- (void)setThumbnailImage:(UIImage *)thumbnailImage { _thumbnailImageView.image = thumbnailImage; }
- (UIImage *)thumbnailImage { return _thumbnailImageView.image; }

- (void)setName:(NSString *)name { _nameLabel.text = name; }
- (NSString *)name { return _nameLabel.text; }

- (void)setBankFlags:(BankFlags)bankFlags {
  _bankFlags = bankFlags;

  _thumbnailImageView.userInteractionEnabled = (_bankFlags & BankPreview);
  _editButton.enabled                        = (_bankFlags & BankEditable);
  _detailButton.enabled                      = (_bankFlags & BankDetail);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Animations
////////////////////////////////////////////////////////////////////////////////


- (void)swipeToDeleteAnimation:(UISwipeGestureRecognizer *)gesture {
  static const CGFloat kDefaultConstant = 8, kShiftedConstant = -58;

  if ([_controller collectionView:_controller.collectionView
                 canPerformAction:@selector(deleteItemForCell:)
               forItemAtIndexPath:[_controller.collectionView indexPathForCell:self]
                       withSender:self])
  {
    CGFloat newConstant = (_leadingConstraint.constant == kDefaultConstant
                           ? kShiftedConstant
                           : kDefaultConstant);
    _leadingConstraint.constant = newConstant;
    __weak BankCollectionViewCell * weakself = self;

    [UIView animateWithDuration:0.5 animations:^{ [weakself layoutIfNeeded]; }];
  }

}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////


- (IBAction)thumbnailImageViewAction:(id)sender {
  if (_cellType == BankCollectionViewCellListType) [self.controller previewItemForCell:self];
  else [self.controller zoomItemForCell:self];
}

- (IBAction)deleteButtonAction:(id)sender { [self.controller deleteItemForCell:self]; }

- (IBAction)detailButtonAction:(id)sender { [self.controller detailItemForCell:self]; }

- (IBAction)editButtonAction:(id)sender { [self.controller editItemForCell:self]; }

@end
