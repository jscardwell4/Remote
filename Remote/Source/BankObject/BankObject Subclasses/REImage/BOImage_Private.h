//
// BOImage_Private.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "BankObject.h"

@interface BOImage ()

@property (nonatomic, weak,   readwrite) NSString * fileName;
@property (nonatomic, strong, readwrite) UIImage  * thumbnail;
@property (nonatomic, strong, readwrite) UIImage  * stretchableImage;
@property (nonatomic, strong)            NSString * baseFileName;
@property (nonatomic, strong)            NSString * fileDirectory;
@property (nonatomic, strong)            NSString * fileNameExtension;
@property (nonatomic, assign, readwrite) BOOL       useRetinaScale;
@property (nonatomic, strong)            NSData   * imageData;
@property (nonatomic, assign, readwrite) CGSize     size;

+ (UIImage *)cachedImageForTag:(int16_t)tag;
+ (void)cacheImage:(BOImage *)image forTag:(int16_t)tag;

- (void)generateImageData;

@end

@interface BOIconImage ()

@property (nonatomic, strong) NSData * previewData;

- (void)generatePreviewData;

@end

@interface BOImage (CoreDataGeneratedAccessors)

- (NSValue *)primitiveSize;
- (void)setPrimitiveSize:(NSValue *)size;

@end