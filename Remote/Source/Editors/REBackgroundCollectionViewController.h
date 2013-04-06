//
//  REBackgroundEditingViewController.h
//  Remote
//
//  Created by Jason Cardwell on 4/1/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

@class BOBackgroundImage;

@interface REBackgroundCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) BOBackgroundImage      * initialImage;

- (void)selectBackgroundImage:(BOBackgroundImage *)backgroundImage;
- (BOBackgroundImage *)selectedImage;

@end
