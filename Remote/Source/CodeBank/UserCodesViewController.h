//
// UserCodesViewController.h
// Remote
//
// Created by Jason Cardwell on 5/23/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

@class   RESendIRCommand;

@protocol CodeSelection <NSObject>

- (void)selectedSendIR:(RESendIRCommand *)sendIRCommand;

@end

@interface UserCodesViewController : UITableViewController

@end
