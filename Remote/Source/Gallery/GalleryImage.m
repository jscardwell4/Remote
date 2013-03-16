//
// Image.m
// iPhonto
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "GalleryImage.h"
#import "GalleryImage_Private.h"
#import "GalleryGroup.h"
#import "Remote.h"

// #import "RegexKitLite.h"

static int   ddLogLevel = DefaultDDLogLevel;

// static BOOL useCache = NO;
static NSMutableDictionary const * iconImageCache;
static NSMutableDictionary const * backgroundImageCache;
static NSMutableDictionary const * buttonImageCache;

@implementation GalleryImage

@dynamic
imageData,
size,
fileDirectory,
baseFileName,
fileNameExtension,
useRetinaScale,
name,
group,
leftCap,
topCap,
tag;

@synthesize
thumbnail        = _thumbnail,
stretchableImage = _stretchableImage,
shouldUseCache   = useCache,
thumbnailSize    = _thumbnailSize;

+ (void)initialize {
    if (self == [GalleryImage class]) {
        iconImageCache       = [NSMutableDictionary dictionary];
        buttonImageCache     = [NSMutableDictionary dictionary];
        backgroundImageCache = [NSMutableDictionary dictionary];
    }
}

+ (GalleryImage *)imageWithFileName:(NSString *)name group:(GalleryGroup *)group {
    if (StringIsEmpty(name) || ValueIsNil(group)) return nil;

    GalleryImage * image =
        [NSEntityDescription insertNewObjectForEntityForName:ClassString([self class])
                                      inManagedObjectContext:group.managedObjectContext];

    if (ValueIsNotNil(image)) {
        image.fileName = name;
        image.group    = group;
        [image generateImageData];
    }

    return image;
}

+ (GalleryImage *)imageWithFileName:(NSString *)name context:(NSManagedObjectContext *)context {
    if (StringIsEmpty(name) || ValueIsNil(context)) return nil;

    return [self imageWithFileName:name
                             group:[GalleryGroup defaultGalleryGroupInContext:context]];
}

#pragma mark - File name methods

- (NSString *)fileName {
    return [NSString stringWithFormat:@"%@.%@", self.baseFileName, self.fileNameExtension];
}

- (void)setFileName:(NSString *)fileName {
    if (StringIsEmpty(fileName)) return;

    NSArray  * fileNameComponents = [fileName pathComponents];
    NSString * fileNameComponent  = [fileNameComponents lastObject];

    if ([fileNameComponents count] > 1)
        self.fileDirectory =
            NilSafeValue(fileNameComponents[[fileNameComponents count] - 2]);

    NSString * fileNameExtension = [fileNameComponent pathExtension];

    if (StringIsNotEmpty(fileNameExtension)) self.fileNameExtension = fileNameExtension;

// NSError *error = NULL;
// NSRegularExpression *regex = [NSRegularExpression
// regularExpressionWithPattern:@"\\[([0-9]{1,4})\\]"
// options:NSRegularExpressionCaseInsensitive
// error:&error];
// NSUInteger numberOfMatches = [regex numberOfMatchesInString:fileNameComponent
// options:0
// range:NSMakeRange(0, [fileNameComponent length])];
// NSRange matchRange = [[regex firstMatchInString:fileNameComponent
// options:0
// range:NSMakeRange(0, [fileNameComponent length])]
// rangeAtIndex:0];
// NSString * tagString;
// if (matchRange.length > 0) {
// tagString = [fileNameComponent substringWithRange:matchRange];
// }
    NSString * tagString = [fileNameComponent stringByMatchingFirstOccurrenceOfRegEx:@"\\[([0-9]{1,4})\\]" capture:1];

    if (tagString) self.tag = [tagString integerValue];

    NSString * baseName = [fileNameComponent stringByDeletingPathExtension];

    if ([baseName hasSuffix:@"@2x"]) {
        self.useRetinaScale = YES;
        self.baseFileName   = [baseName stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
    } else {
        self.baseFileName = baseName;

        NSFileManager * fileManager = [[NSFileManager alloc] init];
        NSString      * searchPath  =
            [[[MainBundle resourcePath] stringByAppendingPathComponent:self.fileDirectory]
             stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x.%@",
                                             self.baseFileName, self.fileNameExtension]];

        self.useRetinaScale = [fileManager fileExistsAtPath:searchPath];
    }

// error = NULL;
// regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[0-9]{1,4}\\](.*)\\.(png|jpg)$"
// options:NSRegularExpressionCaseInsensitive
// error:&error];
// numberOfMatches = [regex numberOfMatchesInString:fileNameComponent
// options:0
// range:NSMakeRange(0, [fileNameComponent length])];
// matchRange = [[regex firstMatchInString:fileNameComponent
// options:0
// range:NSMakeRange(0, [fileNameComponent length])]
// rangeAtIndex:0];
//
// NSString * displayName;
// if (matchRange.length > 0) {
// displayName = [fileNameComponent substringWithRange:matchRange];
// }
    NSString * displayName = [fileNameComponent stringByMatchingFirstOccurrenceOfRegEx:@"\\[[0-9]{1,4}\\](.*)\\.(png|jpg)$" capture:1];

    if (displayName) self.name = displayName;
}  /* setFileName */

#pragma mark - Image caching

+ (void)emptyCache {
    [iconImageCache removeAllObjects];
    [buttonImageCache removeAllObjects];
    [backgroundImageCache removeAllObjects];
}

- (void)emptyCache {
    [GalleryImage emptyCache];
}

+ (UIImage *)cachedIconImageForTag:(int16_t)iconTag {
    return iconImageCache[[NSString stringWithFormat:@"%i", iconTag]];
}

+ (void)cacheIconImage:(UIImage *)iconImage forTag:(int16_t)iconTag {
    [iconImageCache setValue:CollectionSafeValue(iconImage)
                      forKey:[NSString stringWithFormat:@"%i", iconTag]];
}

+ (UIImage *)cachedBackgroundImageForTag:(int16_t)backgroundTag {
    return backgroundImageCache[[NSString stringWithFormat:@"%i", backgroundTag]];
}

+ (void)cacheBackgroundImage:(UIImage *)backgroundImage forTag:(int16_t)backgroundTag {
    [backgroundImageCache setValue:CollectionSafeValue(backgroundImage)
                            forKey:[NSString stringWithFormat:@"%i", backgroundTag]];
}

+ (UIImage *)cachedButtonImageForTag:(int16_t)buttonTag {
    return buttonImageCache[[NSString stringWithFormat:@"%i", buttonTag]];
}

+ (void)cacheButtonImage:(UIImage *)buttonImage forTag:(int16_t)buttonTag {
    [buttonImageCache setValue:CollectionSafeValue(buttonImage)
                        forKey:[NSString stringWithFormat:@"%i", buttonTag]];
}

#pragma mark - Getting and sizing UIImages

- (void)generateImageData {
    NSString * file =
        [[[(self.fileDirectory ? self.fileDirectory : @"")
           stringByAppendingPathComponent: self.baseFileName]
          stringByAppendingString:(self.useRetinaScale ? @"@2x" : @"")]
         stringByAppendingPathExtension:self.fileNameExtension];
    UIImage * image = [UIImage imageNamed:file];

    if (ValueIsNil(image)) {
        DDLogWarn(@"%@ failed to create UIImage from file",
                  ClassTagStringForInstance(self.name));

        return;
    }

    self.size = image.size;

    NSData * imageData = UIImagePNGRepresentation(image);

    if (ValueIsNil(imageData)) {
        DDLogWarn(@"%@ failed to create data respresentation from UIImage",
                  ClassTagStringForInstance(self.name));

        return;
    }

    self.imageData = imageData;
}

- (UIImage *)image {
    if (ValueIsNil(self.imageData)) [self generateImageData];

    if (ValueIsNil(self.imageData)) return nil;

    UIImage * image = [UIImage imageWithData:self.imageData scale:self.useRetinaScale ? 2.0:1.0];

    return image;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    if ([color isPatternBased]) return nil;

    return [self.image recoloredImageWithColor:color];
}

- (CGSize)size {
    [self willAccessValueForKey:@"size"];

    NSValue * imageSizeValue = [self primitiveValueForKey:@"size"];

    [self didAccessValueForKey:@"size"];

    CGSize   imageSize = CGSizeZero;

    if (ValueIsNotNil(imageSizeValue)) imageSize = [imageSizeValue CGSizeValue];

    return imageSize;
}

- (void)setSize:(CGSize)imageSize {
    [self willChangeValueForKey:@"size"];
    [self setPrimitiveValue:[NSValue valueWithCGSize:imageSize] forKey:@"size"];
    [self didChangeValueForKey:@"size"];
}

- (CGSize)thumbnailSize {
    if (CGSizeEqualToSize(CGSizeZero, _thumbnailSize)) _thumbnailSize = CGSizeMake(44, 44);

    return _thumbnailSize;
}

- (void)flushThumbnail {
    self.thumbnail = nil;
}

- (UIImage *)thumbnail {
    if (ValueIsNotNil(_thumbnail)) return _thumbnail;

    CGSize   thumbSize = [self.image sizeThatFits:self.thumbnailSize];
    CGRect   thumbRect;

    thumbRect.size     = thumbSize;
    thumbRect.origin.x = (_thumbnailSize.width - thumbSize.width) / 2.0;
    thumbRect.origin.y = (_thumbnailSize.height - thumbSize.height) / 2.0;

    void   (^ createThumbnail)(void) = ^(void) {
        UIGraphicsBeginImageContext(self.thumbnailSize);

        // draw scaled image into thumbnail context
        [self.image drawInRect:thumbRect];

        self.thumbnail = UIGraphicsGetImageFromCurrentImageContext();

        // pop the context
        UIGraphicsEndImageContext();
    };

    if ([NSThread isMainThread]) createThumbnail();
    else dispatch_sync(dispatch_get_main_queue(), createThumbnail);

    if (ValueIsNil(_thumbnail)) DDLogWarn(@"%@ could not scale image for thumbnail", ClassTagString);

    return _thumbnail;
}

- (UIImage *)stretchableImage {
    if (ValueIsNotNil(_stretchableImage)) return _stretchableImage;

    self.stretchableImage = [self.image
                             stretchableImageWithLeftCapWidth:[self.leftCap floatValue]
                                                 topCapHeight:[self.topCap floatValue]];

    return _stretchableImage;
}

@end
