//
//  BankCollectionZoomView.m
//  Remote
//
//  Created by Jason Cardwell on 9/29/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "BankableModelObject.h"
#import "BankCollectionZoomView.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@interface BankCollectionZoomView ()

@property (nonatomic, weak, readwrite) IBOutlet UIButton    * detailButton;
@property (nonatomic, weak, readwrite) IBOutlet UIButton    * editButton;
@property (nonatomic, weak, readwrite) IBOutlet UILabel     * nameLabel;
@property (nonatomic, weak, readwrite) IBOutlet UIImageView * imageView;
@property (nonatomic, weak, readwrite) IBOutlet UIImageView * backgroundImageView;

@property (nonatomic, strong) CAScrollLayer * scrollLayer;

@end

@implementation BankCollectionZoomView
{
  CGSize _imageSize;
}

/// requiresConstraintBasedLayout
/// @return BOOL
+ (BOOL)requiresConstraintBasedLayout { return YES; }

/// initWithFrame:
/// @param frame
/// @return id
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.style = MSViewStyleBorderLine | MSViewStyleDrawShadow;
    self.borderThickness = 2.0;
    self.borderRadii = CGSizeZero;
    self.nametag = @"zoom";
  }

  return self;
}

/// setItem:
/// @param item
- (void)setItem:(BankableModelObject *)item {
  _item = item;
  self.image = item.preview;
  self.name = item.name;
  self.editDisabled = ![item isEditable];
  self.detailDisabled = ![[item class] isDetailable];
}

/// awakeFromNib
- (void)awakeFromNib {
  [super awakeFromNib];
  self.translatesAutoresizingMaskIntoConstraints = NO;
}

/// intrinsicContentSize
/// @return CGSize
- (CGSize)intrinsicContentSize {
  static const CGSize kMaxImageSize = (CGSize) {  .width = 200, .height = 200 },
                      kMinImageSize = (CGSize) { .width = 44, .height = 44 };

  static const CGFloat kVerticalPadding   = 10,
                       kHorizontalPadding = 32,
                       kLabelHeight       = 21,
                       kButtonHeight      = 44,
                       kMaxContentWidth   = 256;

  CGSize intrinsicSize = CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);

  if (self.imageView.image) {
    CGSize imageSize = (CGSizeGreaterThanOrEqualToSize(_imageSize, kMaxImageSize)
                        ? CGSizeAspectMappedToSize(_imageView.image.size, kMaxImageSize, YES)
                        : _imageSize);

    imageSize = (CGSizeGreaterThanOrEqualToSize(imageSize, kMinImageSize) ? imageSize : kMinImageSize);

    CGFloat contentWidth = MAX(self.nameLabel.intrinsicContentSize.width, imageSize.width);
    contentWidth = MIN(contentWidth, kMaxContentWidth);

    CGFloat w = kHorizontalPadding + contentWidth + kHorizontalPadding;
    CGFloat h = kVerticalPadding + kLabelHeight + kButtonHeight + imageSize.height + kButtonHeight + kVerticalPadding;

    intrinsicSize = CGSizeMake(w, h);
  }

  return intrinsicSize;
}

/// setImage:
/// @param image
- (void)setImage:(UIImage *)image {
  _imageSize                 = image.size;
  self.imageView.contentMode = (CGSizeGreaterThanOrEqualToSize(_imageSize, self.imageView.bounds.size)
                                ? UIViewContentModeScaleAspectFit
                                : UIViewContentModeCenter);
  self.imageView.image = image;
  [self.imageView sizeToFit];
  [self invalidateIntrinsicContentSize];
}

/// image
/// @return UIImage *
- (UIImage *)image { return self.imageView.image; }

/// setName:
/// @param name
- (void)setName:(NSString *)name {
  self.nameLabel.text = name;
  [self invalidateIntrinsicContentSize];
}

/// name
/// @return NSString *
- (NSString *)name { return self.nameLabel.text; }

/// setEditDisabled:
/// @param editDisabled
- (void)setEditDisabled:(BOOL)editDisabled {
  _editDisabled           = editDisabled;
  self.editButton.enabled = !_editDisabled;
}

/// setDetailDisabled:
/// @param detailDisabled
- (void)setDetailDisabled:(BOOL)detailDisabled {
  _detailDisabled           = detailDisabled;
  self.detailButton.enabled = !_detailDisabled;
}

@end
