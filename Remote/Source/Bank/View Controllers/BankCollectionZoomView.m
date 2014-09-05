//
//  BankCollectionZoomView.m
//  Remote
//
//  Created by Jason Cardwell on 9/29/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

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

+ (BOOL)requiresConstraintBasedLayout { return YES; }

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame])
    self.translatesAutoresizingMaskIntoConstraints = NO;

  return self;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)updateConstraints {
  MSLogDebug(@"before super...\n%@", [self prettyConstraintsDescription]);
  [super updateConstraints];
  MSLogDebug(@"after super...\n%@", [self prettyConstraintsDescription]);
}

- (CGSize)intrinsicContentSize {
  static const CGSize kMaxImageSize = (CGSize) {
    .width = 200, .height = 200
  },
                      kMinImageSize = (CGSize) {
    .width = 44, .height = 44
  };

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

- (void)setImage:(UIImage *)image {
  _imageSize                 = image.size;
  self.imageView.contentMode = (CGSizeGreaterThanOrEqualToSize(_imageSize, self.imageView.bounds.size)
                                ? UIViewContentModeScaleAspectFit
                                : UIViewContentModeCenter);
  self.imageView.image = image;
  [self.imageView sizeToFit];
  [self invalidateIntrinsicContentSize];
}

- (UIImage *)image { return self.imageView.image; }

- (void)setName:(NSString *)name {
  self.nameLabel.text = name;
  [self invalidateIntrinsicContentSize];
}

- (NSString *)name { return self.nameLabel.text; }

- (void)setEditDisabled:(BOOL)editDisabled {
  _editDisabled           = editDisabled;
  self.editButton.enabled = !_editDisabled;
}

- (void)setDetailDisabled:(BOOL)detailDisabled {
  _detailDisabled           = detailDisabled;
  self.detailButton.enabled = !_detailDisabled;
}

@end
