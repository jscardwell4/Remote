//
// Image.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "Image.h"

static int       ddLogLevel   = LOG_LEVEL_WARN;
static const int msLogContext = LOG_CONTEXT_DEFAULT;

#pragma unused(ddLogLevel, msLogContext)

@interface Image ()

@property (nonatomic, strong, readwrite) UIImage * thumbnail;
@property (nonatomic, strong, readwrite) UIImage * stretchableImage;
@property (nonatomic, assign, readwrite) CGSize    size;

@end

@interface Image (CoreDataGeneratedAccessors)

@property (nonatomic, strong) NSValue * primitiveSize;

@end

@implementation Image

@dynamic size, fileName, leftCap, topCap;

@synthesize thumbnail = _thumbnail, stretchableImage = _stretchableImage, thumbnailSize = _thumbnailSize;

+ (instancetype)imageWithFileName:(NSString *)fileName
                         category:(NSString *)category
                          context:(NSManagedObjectContext *)moc {
  Image * image = [self createInContext:moc];

  image.fileName = fileName; // Will throw exception if can't generate UIImage from `fileName`
  image.category = category;

  return image;
}

- (void)setFileName:(NSString *)fileName {
  UIImage * image = [UIImage imageNamed:fileName];

  if (image) {
    [self willChangeValueForKey:@"fileName"];
    [self setPrimitiveValue:fileName forKey:@"fileName"];
    [self didChangeValueForKey:@"fileName"];
    self.size = image.size;
  } else
    ThrowInvalidArgument(fileName, "could not produce image for file");
}

- (void)updateWithData:(NSDictionary *)data {
  /*
     example json:

     {
       "uuid": "4BC42EF3-8799-453D-BA50-9C2486B4B511",
       "info": {
           "name": "Speedometer",
           "category": "Icons/Glyphish 7/White Selected"
       },
       "fileName": "917-white-speedometer-selected.png"
       }
   */


  [super updateWithData:data];

  self.fileName = data[@"file-name"] ?: self.fileName;
  self.leftCap  = data[@"left-cap"]  ?: self.leftCap;
  self.topCap   = data[@"top-cap"]   ?: self.topCap;
}

- (UIImage *)image { return [UIImage imageNamed:self.fileName]; }

- (UIImage *)imageWithColor:(UIColor *)color {
  return [color isPatternBased] ? nil : [self.image recoloredImageWithColor:color];
}

- (CGSize)size {
  [self willAccessValueForKey:@"size"];
  NSValue * imageSizeValue = self.primitiveSize;
  [self didAccessValueForKey:@"size"];
  return (imageSizeValue ? CGSizeValue(imageSizeValue) : CGSizeZero);
}

- (void)setSize:(CGSize)imageSize {
  [self willChangeValueForKey:@"size"];
  self.primitiveSize = NSValueWithCGSize(imageSize);
  [self didChangeValueForKey:@"size"];
}

- (CGSize)thumbnailSize {
  if (CGSizeEqualToSize(CGSizeZero, _thumbnailSize))
    _thumbnailSize = CGSizeMake(100, 100);
  return _thumbnailSize;
}

- (void)flushThumbnail { self.thumbnail = nil; }

- (UIImage *)thumbnail {
  if (!_thumbnail) {

    CGSize thumbSize = [self.image sizeThatFits:self.thumbnailSize];
    CGRect thumbRect;

    thumbRect.size     = thumbSize;
    thumbRect.origin.x = (_thumbnailSize.width - thumbSize.width) / 2.0;
    thumbRect.origin.y = (_thumbnailSize.height - thumbSize.height) / 2.0;

    void (^createThumbnail)(void) = ^(void) {
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

  }

  return _thumbnail;
}

- (UIImage *)stretchableImage {
  if (!_stretchableImage)
    self.stretchableImage = [self.image
                             stretchableImageWithLeftCapWidth:self.leftCap
                                                 topCapHeight:self.topCap];

  return _stretchableImage;
}

- (UIImage *)preview { return [self image]; }

- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];

  dictionary[@"file-name"] = CollectionSafe(self.fileName);
  dictionary[@"left-cap"]  = CollectionSafe(self.leftCap);
  dictionary[@"top-cap"]   = CollectionSafe(self.topCap);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

- (MSDictionary *)deepDescriptionDictionary {
  Image * image = [self faultedObject];

  assert(image);

  MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

  dd[@"name"]     = (image.name ?: @"");
  dd[@"fileName"] = (image.fileName ?: @"");
  dd[@"leftCap"]  = image.leftCap ?: @0;
  dd[@"topCap"]   = image.topCap ?: @0;
  dd[@"size"]     = CGSizeString(image.size);

  return (MSDictionary *)dd;
}

- (NSString *)commentedUUID {
  NSString * uuid = self.uuid;

  if (uuid) {
    NSString * filename = self.fileName;

    if (filename) uuid.comment = MSSingleLineComment(filename);
  }

  return uuid;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Bankable
////////////////////////////////////////////////////////////////////////////////

+ (BankFlags)bankFlags { return (BankPreview | BankThumbnail | BankDetail | BankEditable); }
+ (NSString *)directoryLabel { return @"Images"; }

- (BOOL)isEditable { return ([super isEditable] && self.user); }


@end
