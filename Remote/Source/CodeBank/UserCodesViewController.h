//
// UserCodesViewController.h
// iPhonto
//
// Created by Jason Cardwell on 5/23/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

@class   SendIRCommand;

@protocol CodeSelection <NSObject>

- (void)selectedSendIR:(SendIRCommand *)sendIRCommand;

@end

@interface UserCodesViewController : UITableViewController

@end
