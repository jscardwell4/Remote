//
// Image.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "Image.h"

static int ddLogLevel = LOG_LEVEL_WARN;
static const int msLogContext = LOG_CONTEXT_DEFAULT;
#pragma unused(ddLogLevel, msLogContext)

@interface Image ()

@property (nonatomic, strong, readwrite) UIImage  * thumbnail;
@property (nonatomic, strong, readwrite) UIImage  * stretchableImage;
@property (nonatomic, assign, readwrite) CGSize     size;

@end

@interface Image (CoreDataGeneratedAccessors)

@property (nonatomic, strong) NSValue * primitiveSize;

@end

@implementation Image

@dynamic size, fileName, info;

@synthesize thumbnail        = _thumbnail,
            stretchableImage = _stretchableImage,
            thumbnailSize    = _thumbnailSize;

+ (instancetype)imageWithFileName:(NSString *)name
                         category:(NSString *)category
                          context:(NSManagedObjectContext *)context
{
    Image * image = [self MR_createInContext:context];
    if (image) [image.managedObjectContext performBlockAndWait:
                ^{
                    image.fileName = name;
                    image.info.category = category;
                }];
    return image;
}

- (void)setFileName:(NSString *)fileName
{
    UIImage * image = [UIImage imageNamed:fileName];
    if (image)
    {
        [self willChangeValueForKey:@"fileName"];
        [self setPrimitiveValue:fileName forKey:@"fileName"];
        [self didChangeValueForKey:@"fileName"];
        self.size = image.size;
    }
}


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

    return (imageSizeValue ? CGSizeValue(imageSizeValue) : CGSizeZero);
}

- (void)setSize:(CGSize)imageSize
{
    [self willChangeValueForKey:@"size"];
    self.primitiveSize = NSValueWithCGSize(imageSize);
    [self didChangeValueForKey:@"size"];
}

- (CGSize)thumbnailSize
{
    if (CGSizeEqualToSize(CGSizeZero, _thumbnailSize)) _thumbnailSize = CGSizeMake(100, 100);

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
        UIGraphicsBeginImageContextWithOptions(self.thumbnailSize, NO, MainScreenScale);

        // draw scaled image into thumbnail context
        [self.image drawInRect:thumbRect];

        self.thumbnail = UIGraphicsGetImageFromCurrentImageContext();

        // pop the context
        UIGraphicsEndImageContext();
    };

    if ([NSThread isMainThread]) createThumbnail();
    else dispatch_sync(dispatch_get_main_queue(), createThumbnail);

    if (ValueIsNil(_thumbnail)) MSLogWarn(@"%@ could not scale image for thumbnail", ClassTagString);

    return _thumbnail;
}

- (UIImage *)stretchableImage
{
    if (ValueIsNotNil(_stretchableImage)) return _stretchableImage;

    self.stretchableImage = [self.image
                             stretchableImageWithLeftCapWidth:self.leftCap
                                                 topCapHeight:self.topCap];

    return _stretchableImage;
}

- (void)setLeftCap:(float)leftCap
{
    [self willChangeValueForKey:@"leftCap"];
    [self setPrimitiveValue:@(leftCap) forKey:@"leftCap"];
    [self didChangeValueForKey:@"leftCap"];
}

- (float)leftCap
{
    [self willAccessValueForKey:@"leftCap"];
    NSNumber * leftCap = [self primitiveValueForKey:@"leftCap"];
    [self didAccessValueForKey:@"leftCap"];
    return [leftCap floatValue];
}


- (void)setTopCap:(float)topCap
{
    [self willChangeValueForKey:@"topCap"];
    [self setPrimitiveValue:@(topCap) forKey:@"topCap"];
    [self didChangeValueForKey:@"topCap"];
}

- (float)topCap
{
    [self willAccessValueForKey:@"topCap"];
    NSNumber * topCap = [self primitiveValueForKey:@"topCap"];
    [self didAccessValueForKey:@"topCap"];
    return [topCap floatValue];
}

- (UIImage *)preview { return [self image]; }

- (NSDictionary *)JSONDictionary
{
    id(^defaultForKey)(NSString *) = ^(NSString * key)
    {
        static const NSDictionary * index;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken,
                      ^{
                          MSDictionary * dictionary = [MSDictionary dictionary];
                          for (NSString * attribute in @[@"fileName", @"leftCap", @"topCap"])
                              dictionary[attribute] =
                              CollectionSafeValue([self defaultValueForAttribute:attribute]);
                          [dictionary removeKeysWithNullObjectValues];
                          index = dictionary;
                      });

        return index[key];
    };

    void(^addIfCustom)(id, MSDictionary*, NSString*, id) =
    ^(id object, MSDictionary *dictionary, NSString *attribute, id addition )
    {
        BOOL isCustom = YES;

        id defaultValue = defaultForKey(attribute);
        id setValue = [object valueForKey:attribute];

        if (defaultValue && setValue)
        {
            if ([setValue isKindOfClass:[NSNumber class]])
                isCustom = ![defaultValue isEqualToNumber:setValue];

            else if ([setValue isKindOfClass:[NSString class]])
                isCustom = ![defaultValue isEqualToString:setValue];

            else
                isCustom = ![defaultValue isEqual:setValue];
        }

        if (isCustom)
            dictionary[attribute] = CollectionSafeValue(addition);
    };

    MSDictionary * dictionary = [[super JSONDictionary] mutableCopy];

    addIfCustom(self, dictionary, @"fileName", self.fileName);
    addIfCustom(self, dictionary, @"leftCap",  @(self.leftCap));
    addIfCustom(self, dictionary, @"topCap",   @(self.topCap));

    [dictionary removeKeysWithNullObjectValues];
    
    return dictionary;
}

- (MSDictionary *)deepDescriptionDictionary
{
    Image * image = [self faultedObject];
    assert(image);

    MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"name"]              = (image.name ?: @"");
    dd[@"fileName"]          = (image.fileName ?: @"");
    dd[@"leftCap"]           = $(@"%f", image.leftCap);
    dd[@"topCap"]            = $(@"%f", image.topCap);
    dd[@"size"]              = CGSizeString(image.size);
    return (MSDictionary *)dd;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Bankable
////////////////////////////////////////////////////////////////////////////////

+ (BankFlags)bankFlags { return (BankPreview|BankThumbnail|BankDetail|BankEditable); }
+ (NSString *)directoryLabel { return @"Images"; }

- (BOOL)isEditable { return ([super isEditable] && self.user); }


@end