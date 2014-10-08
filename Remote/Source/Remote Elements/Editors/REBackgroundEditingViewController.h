//
//  REBackgroundEditingViewController.h
//  Remote
//
//  Created by Jason Cardwell on 4/2/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
@import CocoaLumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"

@class Image;

@protocol REEditableBackground <NSObject>

@property (nonatomic, strong) UIColor * backgroundColor;
@property (nonatomic, strong) Image * backgroundImage;

@end

@interface REBackgroundEditingViewController : UIViewController

@property (nonatomic, strong) NSManagedObject<REEditableBackground> * subject;

@end
