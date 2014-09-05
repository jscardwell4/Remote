//
//  BankableDetailTableViewController.h
//  Remote
//
//  Created by Jason Cardwell on 9/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"

#import "Bank.h"

@interface BankableDetailTableViewController : UITableViewController  <BankableDetailDelegate>

@property (nonatomic, strong) NSManagedObject<Bankable> * item;

@end
