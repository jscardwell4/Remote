//
// IconBankSubcategoryDetailViewController.h
// iPhonto
//
// Created by Jason Cardwell on 6/14/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconBankViewController.h"

@interface IconBankSubcategoryDetailViewController : UITableViewController {
    NSDictionary * _plist;
    NSString     * _iconSet;
    NSString     * _subcategory;
    NSArray      * _icons;

    id <MSModalViewControllerDelegate, IconBankSelection> __unsafe_unretained   _modalDelegate;
}
- (id)initWithPlist:(NSDictionary *)plist iconSet:(NSString *)iconSet subcategory:(NSString *)subcategory;
@property (nonatomic, unsafe_unretained) id <MSModalViewControllerDelegate, IconBankSelection>   modalDelegate;

@end
