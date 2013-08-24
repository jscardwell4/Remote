//
// MacroCommandEditingViewController.h
// Remote
//
// Created by Jason Cardwell on 4/5/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "CommandDetailViewController.h"

@interface MacroCommandEditingViewController : CommandDetailViewController <UITableViewDataSource,
                                                                            MSPickerInputButtonDelegate,
                                                                            UITableViewDelegate>
@property (nonatomic, strong) REMacroCommand * command;
@end
