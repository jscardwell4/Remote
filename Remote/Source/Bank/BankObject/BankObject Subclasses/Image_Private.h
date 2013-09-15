//
// Image_Private.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "Image.h"

@interface Image ()

@property (nonatomic, strong, readwrite) NSString * fileName;
@property (nonatomic, strong, readwrite) UIImage  * thumbnail;
@property (nonatomic, strong, readwrite) UIImage  * stretchableImage;
@property (nonatomic, assign, readwrite) CGSize     size;
@property (nonatomic, strong) NSData * previewData;

- (void)generatePreviewData;

@end

@interface Image (CoreDataGeneratedAccessors)

@property (nonatomic, strong) NSValue * primitiveSize;

@end

@interface BOBundledImage ()

@end

@interface BOCustomImage ()

@property (nonatomic, strong) NSString * fileNameExtension;
@property (nonatomic, strong) NSString * fileDirectory;


@end