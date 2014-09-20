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
#import "Lumberjack/Lumberjack.h"
@import MoonKit;
#import "MSRemoteMacros.h"

@class Image;

@interface REBackgroundCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) Image      * initialImage;

- (void)selectBackgroundImage:(Image *)backgroundImage;
- (Image *)selectedImage;

@end
