//
// ComponentDeviceListViewController.h
// Remote
//
// Created by Jason Cardwell on 5/23/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "UserCodesViewController.h"

@class   BOComponentDevice;

@interface ComponentDeviceListViewController : UITableViewController

@property (nonatomic, strong) BOComponentDevice * componentDevice;
@end
