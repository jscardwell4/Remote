//
//  REBackgroundEditingViewController.h
//  Remote
//
//  Created by Jason Cardwell on 4/2/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REEditableBackground.h"

@interface REBackgroundEditingViewController : UIViewController

@property (nonatomic, strong) NSManagedObject<REEditableBackground> * subject;

@end
