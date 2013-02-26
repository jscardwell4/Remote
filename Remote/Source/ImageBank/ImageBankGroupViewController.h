//
// ImageBankGroupViewController.h
// iPhonto
//
// Created by Jason Cardwell on 5/29/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class   GalleryGroup;
@class   GalleryImage;

@protocol ImageSelection <NSObject>

- (void)selectedImage:(GalleryImage *)image;

@end

@interface ImageBankGroupViewController : UITableViewController
    <NSFetchedResultsControllerDelegate> {
    GalleryGroup * _group;
    UIImageView  * _imageView;
    UIView       * _imageViewContainer;
    GalleryImage * _mutatingImage;
// id <MSModalViewControllerDelegate, ImageSelection>__unsafe_unretained   _modalDelegate;
}
- (id)initWithGroup:(GalleryGroup *)group;
@property (nonatomic, strong) IBOutlet UIView            * imageViewContainer;
@property (nonatomic, strong) IBOutlet UIImageView       * imageView;
@property (nonatomic, strong) GalleryGroup               * group;
@property (nonatomic, strong) NSFetchedResultsController * fetchedBackgroundsResultsController;
@property (nonatomic, strong) NSFetchedResultsController * fetchedIconsResultsController;
@property (nonatomic, strong) NSManagedObjectContext     * managedObjectContext;
// @property (nonatomic, unsafe_unretained) id <MSModalViewControllerDelegate, ImageSelection>
//   modalDelegate;
@end
