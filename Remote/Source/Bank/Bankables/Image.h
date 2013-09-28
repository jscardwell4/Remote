//
// Image.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BankableModelObject.h"

@class ImageGroup;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Image
////////////////////////////////////////////////////////////////////////////////

@interface Image : BankableModelObject

+ (instancetype)imageWithFileName:(NSString *)name
                         category:(NSString *)category
                          context:(NSManagedObjectContext *)context;
+ (instancetype)imageWithFileName:(NSString *)name context:(NSManagedObjectContext *)context;
+ (instancetype)imageWithFileName:(NSString *)name group:(ImageGroup *)group;

- (UIImage *)imageWithColor:(UIColor *)color;

+ (instancetype)fetchImageNamed:(NSString *)name context:(NSManagedObjectContext *)context;

- (void)flushThumbnail;

@property (nonatomic, strong, readonly) NSString   * fileName;
@property (nonatomic, strong)           ImageGroup * group;

@property (nonatomic, weak,   readonly) UIImage  * image;
@property (nonatomic, assign)           CGSize     thumbnailSize;
@property (nonatomic, strong)           NSNumber * leftCap;
@property (nonatomic, strong)           NSNumber * topCap;
@property (nonatomic, strong, readonly) UIImage  * stretchableImage;
@property (nonatomic, assign, readonly) CGSize     size;

@end

