//
// BOImage.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "BOImage_Private.h"
#import "BankObjectGroup.h"


static int   ddLogLevel = DefaultDDLogLevel;

// static BOOL useCache = NO;
static NSMutableDictionary const * imageCache;

@implementation BOImage

@dynamic imageData, size,  useRetinaScale, name, group, leftCap, topCap, tag;
@dynamic fileDirectory, baseFileName, fileNameExtension;

@synthesize thumbnail        = _thumbnail;
@synthesize stretchableImage = _stretchableImage;
@synthesize shouldUseCache   = useCache;
@synthesize thumbnailSize    = _thumbnailSize;

+ (void)initialize
{
    if (self == [BOImage class]) {
        imageCache                                         = [@{} mutableCopy];
        imageCache[ClassString([BOBackgroundImage class])] = [@{} mutableCopy];
        imageCache[ClassString([BOIconImage class])]       = [@{} mutableCopy];
        imageCache[ClassString([BOButtonImage class])]     = [@{} mutableCopy];
    }
}

+ (instancetype)imageWithFileName:(NSString *)name group:(BOImageGroup *)group
{
    assert(!(StringIsEmpty(name) || ValueIsNil(group)));

    NSManagedObjectContext * context = group.managedObjectContext;
    __block BOImage * image;
    [context performBlockAndWait:^{
        image = [NSEntityDescription insertNewObjectForEntityForName:ClassString(self)
                                              inManagedObjectContext:context];
        assert(image);
        image.fileName = name;
        image.group    = group;
        [image generateImageData];
    }];

    return image;
}

+ (instancetype)imageWithFileName:(NSString *)name context:(NSManagedObjectContext *)context
{
    assert(context);
    __block BOImage * image;
    [context performBlockAndWait:^{
        BOImageGroup * group = [BOImageGroup defaultGroupInContext:context];
        image =  [self imageWithFileName:name group:group];
        assert(image);
    }];
    return image;
}

+ (instancetype)fetchImageWithTag:(NSInteger)tag context:(NSManagedObjectContext *)context
{
    assert(context);
    __block BOImage * image = nil;
    [context performBlockAndWait:^{
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ClassString(self)];
        NSPredicate    * predicate    = [NSPredicate predicateWithFormat:@"tag == %i", tag];
        fetchRequest.predicate = predicate;
        NSError * error;
        NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (!fetchedObjects.count) DDLogWarn(@"No icons with tag %i were found", tag);
        else image = [fetchedObjects lastObject];
    }];
    return image;
}

- (NSString *)fileName { return $(@"%@.%@", self.baseFileName, self.fileNameExtension); }

- (void)setFileName:(NSString *)fileName
{
    assert(StringIsNotEmpty(fileName));

    NSArray  * fileNameComponents = [fileName pathComponents];
    NSString * fileNameComponent  = [fileNameComponents lastObject];

    if ([fileNameComponents count] > 1)
        self.fileDirectory = NilSafeValue(fileNameComponents[[fileNameComponents count] - 2]);

    NSString * fileNameExtension = [fileNameComponent pathExtension];

    if (StringIsNotEmpty(fileNameExtension)) self.fileNameExtension = fileNameExtension;

    NSString * tagString = [fileNameComponent
                            stringByMatchingFirstOccurrenceOfRegEx:@"\\[([0-9]{1,4})\\]"
                                                           capture:1];

    if (tagString) self.tag = NSIntegerValue(tagString);

    NSString * baseName = [fileNameComponent stringByDeletingPathExtension];

    if ([baseName hasSuffix:@"@2x"])
    {
        self.useRetinaScale = YES;
        self.baseFileName   = [baseName stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
    }

    else
    {
        self.baseFileName = baseName;

        NSFileManager * fileManager = [[NSFileManager alloc] init];
        NSString      * searchPath  = [[MainBundle resourcePath]
                                       stringByAppendingPathComponent:$(@"%@/%@@2x.%@",
                                                                        self.fileDirectory,
                                                                        self.baseFileName,
                                                                        self.fileNameExtension)];

        self.useRetinaScale = [fileManager fileExistsAtPath:searchPath];
    }

    NSString * displayName =
        [fileNameComponent stringByMatchingFirstOccurrenceOfRegEx:@"\\[[0-9]{1,4}\\](.*)\\.(png|jpg)$"
                                                          capture:1];

    if (displayName) self.name = displayName;
}

- (void)emptyCache
{
    [imageCache enumerateKeysAndObjectsUsingBlock:
     ^(id key, NSMutableDictionary * obj, BOOL *stop) {
         [obj removeAllObjects];
     }];
}

+ (UIImage *)cachedImageForTag:(int16_t)tag {
    return imageCache[ClassString(self)][@(tag)];
}

+ (void)cacheImage:(BOImage *)image forTag:(int16_t)tag {
    imageCache[ClassString(self)][@(tag)] = CollectionSafeValue(image);
}

#pragma mark - Getting and sizing UIImages

- (void)generateImageData {
    NSString * file =
        [[[(self.fileDirectory  ? : @"")
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
    assert(imageData);
    self.imageData = imageData;
}

- (UIImage *)image {
    UIImage * image = imageCache[ClassString([self class])][@(self.tag)];
    if (image) return image;

    if (ValueIsNil(self.imageData)) [self generateImageData];
    assert(self.imageData);

    return [UIImage imageWithData:self.imageData scale:2.0];
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
    if (ValueIsNotNil(imageSizeValue))
        imageSize = [imageSizeValue CGSizeValue];
    return imageSize;
}

- (void)setSize:(CGSize)imageSize {
    [self willChangeValueForKey:@"size"];
    [self setPrimitiveSize:NSValueWithCGSize(imageSize)];
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
