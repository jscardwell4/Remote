//
//  BankCollectionViewCell.m
//  Remote
//
//  Created by Jason Cardwell on 9/29/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankCollectionViewCell.h"
#import "BankCollectionViewController.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

MSIDENTIFIER_DEFINITION(ListCell);
MSIDENTIFIER_DEFINITION(ThumbnailCell);

typedef NS_ENUM(uint8_t, BankCollectionViewCellType)
{
    BankCollectionViewCellListType       = 0,
    BankCollectionViewCellThumbnailType  = 1
};

@implementation BankCollectionViewCell
{
    BankCollectionViewCellType _cellType;
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    self.bankFlags = BankDefault;
    self.thumbnailImage = nil;
    self.name = nil;
}

/*
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {

    }

    return self;
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    _cellType = ([self.reuseIdentifier isEqualToString:ThumbnailCellIdentifier]
                 ? BankCollectionViewCellThumbnailType
                 : BankCollectionViewCellListType);

    UITapGestureRecognizer * tap = [UITapGestureRecognizer
                                    gestureWithTarget:self
                                               action:@selector(thumbnailImageViewAction:)];
    [_thumbnailImageView addGestureRecognizer:tap];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
////////////////////////////////////////////////////////////////////////////////

- (void)setThumbnailImage:(UIImage *)thumbnailImage { _thumbnailImageView.image = thumbnailImage; }
- (UIImage *)thumbnailImage { return _thumbnailImageView.image; }

- (void)setName:(NSString *)name { _nameLabel.text = name; }
- (NSString *)name { return _nameLabel.text; }

- (void)setBankFlags:(BankFlags)bankFlags
{
    _bankFlags = bankFlags;

    _thumbnailImageView.userInteractionEnabled = (_bankFlags & BankPreview);
    _editButton.enabled                        = (_bankFlags & BankEditable);
    _detailButton.enabled                      = (_bankFlags & BankDetail);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////


- (IBAction)thumbnailImageViewAction:(id)sender
{
    MSLogDebug(@"");
    switch (_cellType)
    {
        case BankCollectionViewCellThumbnailType: [self.controller zoomItemForCell:self];    break;
        default:                                  [self.controller previewItemForCell:self]; break;
    }
}

- (IBAction)detailButtonAction:(id)sender { [self.controller detailItemForCell:self]; }

- (IBAction)editButtonAction:(id)sender { [self.controller editItemForCell:self]; }

@end

