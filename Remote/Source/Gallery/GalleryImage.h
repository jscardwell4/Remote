//
// GalleryImage.h
// iPhonto
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "BankObject.h"

@class   GalleryGroup, Remote, ButtonGroup;

#pragma mark - GalleryImage

@interface GalleryImage : BankObject <MSCaching>

+ (GalleryImage *)imageWithFileName:(NSString *)name context:(NSManagedObjectContext *)context;
+ (GalleryImage *)imageWithFileName:(NSString *)name group:(GalleryGroup *)group;

@property (nonatomic, weak, readonly) NSString  * fileName;
@property (nonatomic, strong) NSString          * name;
@property (nonatomic, strong) GalleryGroup      * group;
@property (nonatomic, weak, readonly) UIImage   * image;
@property (nonatomic, strong, readonly) UIImage * thumbnail;
@property (nonatomic, assign) CGSize              thumbnailSize;
@property (nonatomic, assign) int16_t             tag;
@property (nonatomic, strong) NSNumber          * leftCap;
@property (nonatomic, strong) NSNumber          * topCap;
@property (nonatomic, strong, readonly) UIImage * stretchableImage;
@property (nonatomic, assign) CGSize              size;
@property (nonatomic, assign, readonly) BOOL      useRetinaScale;

- (UIImage *)imageWithColor:(UIColor *)color;

- (void)flushThumbnail;

@end

#pragma mark - GalleryIconImage

@interface GalleryIconImage : GalleryImage

+ (GalleryIconImage *)iconImageForFile:(NSString *)name context:(NSManagedObjectContext *)context;

+ (GalleryIconImage *)iconImageForFile:(NSString *)name group:(GalleryGroup *)group;

+ (GalleryIconImage *)fetchIconWithTag:(NSInteger)tag context:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSString          * iconSet;
@property (nonatomic, strong) NSString          * subcategory;
@property (nonatomic, strong, readonly) UIImage * preview;

@end

#pragma mark - GalleryBackgroundImage

@interface GalleryBackgroundImage : GalleryImage

+ (GalleryBackgroundImage *)backgroundImageForFile:(NSString *)name
                                           context:(NSManagedObjectContext *)context;

+ (GalleryBackgroundImage *)backgroundImageForFile:(NSString *)name group:(GalleryGroup *)group;

+ (GalleryBackgroundImage *)fetchBackgroundImageWithTag:(NSInteger)tag
                                                context:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSSet * buttonGroups;
@property (nonatomic, strong) NSSet * remotes;

@end

typedef NS_ENUM (BOOL, ButtonImageState) {
    ButtonImageStateReleased = NO,
    ButtonImageStatePressed  = YES
};

#pragma mark - GalleryButtonImage

@interface GalleryButtonImage : GalleryImage

+ (GalleryButtonImage *)buttonImageForFile:(NSString *)name
                                   context:(NSManagedObjectContext *)context;

+ (GalleryButtonImage *)buttonImageForFile:(NSString *)name group:(GalleryGroup *)group;

+ (GalleryButtonImage *)fetchButtonWithTag:(NSInteger)tag
                                     state:(ButtonImageState)state
                                   context:(NSManagedObjectContext *)context;

@property (nonatomic, assign) int16_t   state;

@end
