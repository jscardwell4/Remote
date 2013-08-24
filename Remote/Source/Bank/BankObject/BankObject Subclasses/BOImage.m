//
// BOImage.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "BOImage_Private.h"
#import "BankObjectGroup.h"


static const int ddLogLevel = LOG_LEVEL_WARN;
static const int msLogContext = LOG_CONTEXT_DEFAULT;
#pragma unused(ddLogLevel, msLogContext)

@implementation BOImage

@dynamic previewData, size, name, group, leftCap, topCap, fileName;

@synthesize thumbnail = _thumbnail, stretchableImage = _stretchableImage, thumbnailSize = _thumbnailSize;

+ (instancetype)imageWithFileName:(NSString *)fileName group:(BOImageGroup *)group
{
    assert(!(StringIsEmpty(fileName) || ValueIsNil(group)));

    NSManagedObjectContext * context = group.managedObjectContext;
    __block BOImage * image;
    [context performBlockAndWait:^{
        image = [self MR_createInContext:context];
        image.fileName = fileName;
        image.group    = group;
    }];

    return image;
}

+ (instancetype)imageWithFileName:(NSString *)name context:(NSManagedObjectContext *)context
{
    assert(context);
    __block BOImage * image;
    [context performBlockAndWait:
     ^{
        BOImageGroup * group = [BOImageGroup groupWithName:@"Default" context:context];
        image =  [self imageWithFileName:name group:group];
        assert(image);
    }];
    return image;
}

+ (instancetype)fetchImageNamed:(NSString *)name context:(NSManagedObjectContext *)context
{
    assert(context);
    __block BOImage * image = nil;
    [context performBlockAndWait:
     ^{
         image = [self MR_findFirstByAttribute:@"fileName" withValue:name inContext:context];
     }];
    return image;
}

//- (NSString *)fileName { return $(@"%@.%@", self.baseFileName, self.fileNameExtension); }

/*
- (void)setFileName:(NSString *)fileName
{
    assert(StringIsNotEmpty(fileName));
    
    NSString * pathToDirectory    = [fileName stringByDeletingLastPathComponent];
    NSString * fileNameComponent  = [fileName lastPathComponent];
    NSString * fileNameExtension  = [fileNameComponent pathExtension];
    

    self.fileDirectory     = (StringIsNotEmpty(pathToDirectory) ? pathToDirectory : nil);
    self.baseFileName      = (StringIsEmpty(fileNameExtension)
                              ? fileNameComponent
                              : [fileNameComponent stringByDeletingPathExtension]);
    self.fileNameExtension = (StringIsNotEmpty(fileNameExtension) ? fileNameExtension : nil);

    NSString * tagString = [self.baseFileName
                            stringByMatchingFirstOccurrenceOfRegEx:@"\\[([0-9]{1,4})\\]"
                                                           capture:1];

    self.tag = (tagString ? NSIntegerValue(tagString) : 0);

    if ([self.baseFileName hasSuffix:@"@2x"])
    {
        self.useRetinaScale = YES;
        self.baseFileName   = [self.baseFileName stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
    }

    else
    {
        NSFileManager * fileManager = [NSFileManager new];
        NSString * searchPath = [self.fileDirectory stringByAppendingFormat:@"/%@@2x.%@",
                                                                            self.baseFileName,
                                                                            self.fileNameExtension];
        if ([fileManager fileExistsAtPath:searchPath])
            self.useRetinaScale = YES;
        else
        {
            searchPath  = [[MainBundle resourcePath]
                           stringByAppendingPathComponent:$(@"%@/%@@2x.%@",
                                                            self.fileDirectory,
                                                            self.baseFileName,
                                                            self.fileNameExtension)];
            
            self.useRetinaScale = [fileManager fileExistsAtPath:searchPath];
        }
    }

    NSString * name =
        [self.baseFileName stringByMatchingFirstOccurrenceOfRegEx:@"\\[[0-9]{1,4}\\](.*)$"//\\.(png|jpg)$"
                                                          capture:1];

    if (name) self.name = name;
}
*/

#pragma mark - Getting and sizing UIImages

- (UIImage *)image { return [UIImage imageNamed:self.fileName]; }

- (UIImage *)imageWithColor:(UIColor *)color
{
    if ([color isPatternBased])
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"color cannot be pattern-based"
                                     userInfo:nil];

    return [self.image recoloredImageWithColor:color];
}

- (CGSize)size
{
    [self willAccessValueForKey:@"size"];
    NSValue * imageSizeValue = self.primitiveSize;
    [self didAccessValueForKey:@"size"];
    CGSize   imageSize = CGSizeZero;
    if (ValueIsNotNil(imageSizeValue))
        imageSize = [imageSizeValue CGSizeValue];
    return imageSize;
}

- (void)setSize:(CGSize)imageSize
{
    [self willChangeValueForKey:@"size"];
    self.primitiveSize = NSValueWithCGSize(imageSize);
    [self didChangeValueForKey:@"size"];
}

- (CGSize)thumbnailSize
{
    if (CGSizeEqualToSize(CGSizeZero, _thumbnailSize)) _thumbnailSize = CGSizeMake(44, 44);

    return _thumbnailSize;
}

- (void)flushThumbnail { self.thumbnail = nil; }

- (UIImage *)thumbnail
{
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

- (UIImage *)stretchableImage
{
    if (ValueIsNotNil(_stretchableImage)) return _stretchableImage;

    self.stretchableImage = [self.image
                             stretchableImageWithLeftCapWidth:[self.leftCap floatValue]
                                                 topCapHeight:[self.topCap floatValue]];

    return _stretchableImage;
}

- (void)generatePreviewData { self.previewData = UIImagePNGRepresentation([self imageWithColor:WhiteColor]); }

- (UIImage *)preview
{
    NSData * previewData = self.previewData;

    if (!previewData) {
        DDLogWarn(@"%@ no preview data exists", ClassTagStringForInstance(self.name));
        previewData = UIImagePNGRepresentation([self imageWithColor:WhiteColor]);
        assert(previewData);
        self.previewData = previewData;
    }

    UIImage * preview = [UIImage imageWithData:previewData scale:2.0];

    return preview;
}


- (MSDictionary *)deepDescriptionDictionary
{
    BOImage * image = [self faultedObject];
    assert(image);

    MSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"name"]              = (image.name ?: @"");
    dd[@"group"]             = $(@"'%@':%@",
                                 image.group.name,
                                 image.group.uuid);
    dd[@"baseFileName"]      = (image.fileName ?: @"");
    dd[@"leftCap"]           = $(@"%@", image.leftCap);
    dd[@"topCap"]            = $(@"%@", image.topCap);
    dd[@"size"]              = CGSizeString(image.size);
    return dd;
}

@end
