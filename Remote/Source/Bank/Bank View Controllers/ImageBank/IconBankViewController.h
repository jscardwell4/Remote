//
// IconBankViewController.h
// Remote
//
// Created by Jason Cardwell on 6/14/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IconBankSelection <NSObject>

- (void)didSelectIconFile:(NSString *)iconFile;

@end

@interface IconBankViewController : UITableViewController {
    NSArray      * _categories;
    NSDictionary * _plist;

    id <MSModalViewControllerDelegate, IconBankSelection> __unsafe_unretained   _modalDelegate;
}
@property (nonatomic, strong) NSArray                                                          * categories;
@property (nonatomic, unsafe_unretained) id <MSModalViewControllerDelegate, IconBankSelection>   modalDelegate;
@end
