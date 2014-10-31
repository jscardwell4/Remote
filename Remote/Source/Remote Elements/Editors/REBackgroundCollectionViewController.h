//
//  REBackgroundEditingViewController.h
//  Remote
//
//  Created by Jason Cardwell on 4/1/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
@import CocoaLumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"

@class Image;

@interface REBackgroundCollectionViewController : UICollectionViewController

@property (nonatomic, strong)   NSManagedObjectContext * context;
@property (nonatomic, strong)   Image                  * initialImage;
@property (nonatomic, readonly) Image                  * selectedImage;

- (void)selectBackgroundImage:(Image *)backgroundImage;

@end
