//
//  BankCollectionZoomView.h
//  Remote
//
//  Created by Jason Cardwell on 9/29/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import Moonkit;
#import "MSRemoteMacros.h"

@interface BankCollectionZoomView : MSView

@property (nonatomic, weak) UIImage * image;
@property (nonatomic, weak) NSString * name;

@property (nonatomic, getter = isEditDisabled) BOOL editDisabled;
@property (nonatomic, getter = isDetailDisabled) BOOL detailDisabled;

@property (nonatomic, weak, readonly) IBOutlet UIButton     * detailButton;
@property (nonatomic, weak, readonly) IBOutlet UIButton     * editButton;
@property (nonatomic, weak, readonly) IBOutlet UILabel      * nameLabel;
@property (nonatomic, weak, readonly) IBOutlet UIImageView  * imageView;
@property (nonatomic, weak, readonly) IBOutlet UIImageView  * backgroundImageView;

@end
