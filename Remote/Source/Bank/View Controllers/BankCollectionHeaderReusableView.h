//
//  BankCollectionHeaderReusableView.h
//  Remote
//
//  Created by Jason Cardwell on 9/29/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

@class BankCollectionViewController;

@interface BankCollectionHeaderReusableView : UICollectionReusableView

@property (nonatomic, weak) IBOutlet UIButton                     * button;
@property (nonatomic, weak) IBOutlet BankCollectionViewController * controller;
@property (nonatomic, weak)          NSString                     * title;
@property (nonatomic, assign)        NSInteger                      section;

@end
