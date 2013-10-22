//
// Image.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BankableModelObject.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Image
////////////////////////////////////////////////////////////////////////////////

@interface Image : BankableModelObject

+ (instancetype)imageWithFileName:(NSString *)name
                         category:(NSString *)category
                          context:(NSManagedObjectContext *)context;

- (UIImage *)imageWithColor:(UIColor *)color;

- (void)flushThumbnail;


@property (nonatomic, weak,   readonly) UIImage  * image;
@property (nonatomic, assign)           CGSize     thumbnailSize;
@property (nonatomic, strong)           NSString * fileName;
@property (nonatomic, assign)           float      leftCap;
@property (nonatomic, assign)           float      topCap;
@property (nonatomic, strong, readonly) UIImage  * stretchableImage;
@property (nonatomic, assign, readonly) CGSize     size;

@end

