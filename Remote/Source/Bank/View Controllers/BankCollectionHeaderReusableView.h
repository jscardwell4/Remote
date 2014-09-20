//
//  BankCollectionHeaderReusableView.h
//  Remote
//
//  Created by Jason Cardwell on 9/29/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
@import MoonKit;
#import "MSRemoteMacros.h"

@class BankCollectionViewController;

MSEXTERN_IDENTIFIER(BankCollectionHeader);

@interface BankCollectionHeaderReusableView : UICollectionReusableView

@property (nonatomic, weak) IBOutlet BankCollectionViewController * controller;
@property (nonatomic, weak)          NSString                     * title;
@property (nonatomic, assign)        NSInteger                      section;

@end
