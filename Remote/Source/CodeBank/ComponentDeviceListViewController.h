//
// ComponentDeviceListViewController.h
// iPhonto
//
// Created by Jason Cardwell on 5/23/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "UserCodesViewController.h"

@class   ComponentDevice;

@interface ComponentDeviceListViewController : UITableViewController

@property (nonatomic, strong) ComponentDevice * componentDevice;
@end
