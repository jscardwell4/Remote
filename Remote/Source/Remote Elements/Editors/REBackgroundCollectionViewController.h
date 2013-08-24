//
//  REBackgroundEditingViewController.h
//  Remote
//
//  Created by Jason Cardwell on 4/1/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

@class BOImage;

@interface REBackgroundCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) BOImage      * initialImage;

- (void)selectBackgroundImage:(BOImage *)backgroundImage;
- (BOImage *)selectedImage;

@end
