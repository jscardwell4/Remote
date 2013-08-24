//
// IconBankSubCategoriesViewController.h
// Remote
//
// Created by Jason Cardwell on 6/14/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconBankViewController.h"

@interface IconBankSubCategoriesViewController : UITableViewController {
    NSString     * _iconSet;
    NSDictionary * _plist;
    NSArray      * _subcategories;

    id <MSModalViewControllerDelegate, IconBankSelection> __unsafe_unretained   _modalDelegate;
}
- (id)initWithPlist:(NSDictionary *)plist iconSet:(NSString *)iconSet;
@property (nonatomic, unsafe_unretained) id <MSModalViewControllerDelegate, IconBankSelection>   modalDelegate;
@end
