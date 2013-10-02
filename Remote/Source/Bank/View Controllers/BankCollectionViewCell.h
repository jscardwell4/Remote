//
//  BankCollectionViewCell.h
//  Remote
//
//  Created by Jason Cardwell on 9/29/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "Bank.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankCollectionViewCell
////////////////////////////////////////////////////////////////////////////////


@class BankCollectionViewController;

@interface BankCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) UIImage * thumbnailImage;
@property (nonatomic, weak) NSString * name;
@property (nonatomic, assign) BankFlags bankFlags;

@property (nonatomic, weak) IBOutlet UIImageView                  * thumbnailImageView;
@property (nonatomic, weak) IBOutlet UILabel                      * nameLabel;
@property (nonatomic, weak) IBOutlet UIButton                     * editButton;
@property (nonatomic, weak) IBOutlet UIButton                     * detailButton;
@property (nonatomic, weak) IBOutlet BankCollectionViewController * controller;

@end

MSEXTERN_IDENTIFIER(ListCell);
MSEXTERN_IDENTIFIER(ThumbnailCell);

