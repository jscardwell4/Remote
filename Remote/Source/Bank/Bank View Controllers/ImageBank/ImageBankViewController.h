//
// ImageBankViewController.h
// Remote
//
// Created by Jason Cardwell on 5/29/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageBankGroupViewController.h"

@interface ImageBankViewController : UITableViewController {
    NSArray * _fetchedGroups;

    id <MSModalViewControllerDelegate, ImageSelection> __unsafe_unretained   _modalDelegate;
}
@property (nonatomic, strong) NSArray                                                       * fetchedGroups;
@property (nonatomic, unsafe_unretained) id <MSModalViewControllerDelegate, ImageSelection>   modalDelegate;
@end
