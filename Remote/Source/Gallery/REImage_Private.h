//
// REImage_Private.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "REImage.h"

@interface REImage ()

@property (nonatomic, weak, readwrite) NSString  * fileName;
@property (nonatomic, strong, readwrite) UIImage * thumbnail;
@property (nonatomic, strong, readwrite) UIImage * stretchableImage;
@property (nonatomic, strong) NSString           * baseFileName;
@property (nonatomic, strong) NSString           * fileDirectory;
@property (nonatomic, strong) NSString           * fileNameExtension;
@property (nonatomic, assign, readwrite) BOOL      useRetinaScale;
@property (nonatomic, strong) NSData             * imageData;

+ (UIImage *)cachedIconImageForTag:(int16_t)iconTag;
+ (void)cacheIconImage:(UIImage *)iconImage forTag:(int16_t)iconTag;

+ (UIImage *)cachedBackgroundImageForTag:(int16_t)backgroundTag;
+ (void)cacheBackgroundImage:(UIImage *)backgroundImage forTag:(int16_t)backgroundTag;

+ (UIImage *)cachedButtonImageForTag:(int16_t)buttonTag;
+ (void)cacheButtonImage:(UIImage *)buttonImage forTag:(int16_t)buttonTag;

- (void)generateImageData;

@end

@interface REIconImage ()

@property (nonatomic, strong) NSData * previewData;

- (void)generatePreviewData;

@end
