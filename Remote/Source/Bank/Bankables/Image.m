//
// Image.m
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "Image.h"
#import "Remote-Swift.h"

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

/// imageWithFileName:category:context:
/// @param fileName
/// @param category
/// @param moc
/// @return instancetype
+ (instancetype)imageWithFileName:(NSString *)fileName
                         category:(NSString *)category
                          context:(NSManagedObjectContext *)moc {
  Image * image = [self createInContext:moc];

  image.fileName = fileName; // Will throw exception if can't generate UIImage from `fileName`
  image.category = category;

  return image;
}

/// setFileName:
/// @param fileName
- (void)setFileName:(NSString *)fileName {
  UIImage * image = [UIImage imageNamed:fileName];
  [self willChangeValueForKey:@"fileName"];
  [self setPrimitiveValue:(image ? fileName : nil) forKey:@"fileName"];
  [self didChangeValueForKey:@"fileName"];
  self.size = (image ? image.size : CGSizeZero);
}

/// updateWithData:
/// @param data
- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

  self.fileName = data[@"file-name"] ?: self.fileName;
  self.leftCap  = data[@"left-cap"]  ?: self.leftCap;
  self.topCap   = data[@"top-cap"]   ?: self.topCap;
}

/// image
/// @return UIImage *
- (UIImage *)image { return [UIImage imageNamed:self.fileName]; }

/// imageWithColor:
/// @param color
/// @return UIImage *
- (UIImage *)imageWithColor:(UIColor *)color {
  return [color isPatternBased] ? nil : [self.image recoloredImageWithColor:color];
}

/// size
/// @return CGSize
- (CGSize)size {
  [self willAccessValueForKey:@"size"];
  NSValue * imageSizeValue = self.primitiveSize;
  [self didAccessValueForKey:@"size"];
  return (imageSizeValue ? CGSizeValue(imageSizeValue) : CGSizeZero);
}

/// setSize:
/// @param imageSize
- (void)setSize:(CGSize)imageSize {
  [self willChangeValueForKey:@"size"];
  self.primitiveSize = NSValueWithCGSize(imageSize);
  [self didChangeValueForKey:@"size"];
}

/// thumbnailSize
/// @return CGSize
- (CGSize)thumbnailSize {
  if (CGSizeEqualToSize(CGSizeZero, _thumbnailSize))
    _thumbnailSize = CGSizeMake(100, 100);

  return _thumbnailSize;
}

/// flushThumbnail
- (void)flushThumbnail { self.thumbnail = nil; }

/// stretchableImage
/// @return UIImage *
- (UIImage *)stretchableImage {
  if (!_stretchableImage)
    self.stretchableImage = [self.image
                             stretchableImageWithLeftCapWidth:self.leftCap
                                                 topCapHeight:self.topCap];

  return _stretchableImage;
}

/// JSONDictionary
/// @return MSDictionary *
- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];

  SafeSetValueForKey(self.fileName, @"file-name", dictionary);
  SetValueForKeyIfNotDefault(self.leftCap, @"leftCap", dictionary);
  SetValueForKeyIfNotDefault(self.topCap,  @"topCap",  dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

/// deepDescriptionDictionary
/// @return MSDictionary *
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

/// commentedUUID
/// @return NSString *
- (NSString *)commentedUUID {
  NSString * uuid = self.uuid;

  if (uuid) {
    NSString * filename = self.fileName;

    if (filename) uuid.comment = MSSingleLineComment(filename);
  }

  return uuid;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankableModel
////////////////////////////////////////////////////////////////////////////////

/// isPreviewable
/// @return BOOL
+ (BOOL)isPreviewable { return YES;  }

/// isThumbnailable
/// @return BOOL
+ (BOOL)isThumbnailable { return YES;  }

/// directoryLabel
/// @return NSString *
+ (NSString *)directoryLabel { return @"Images"; }

+ (UIImage *)directoryIcon { return [UIImage imageNamed:@"926-gray-photos"]; }

/// isEditable
/// @return BOOL
- (BOOL)isEditable { return ([super isEditable] && self.user); }

/// detailViewController
/// @return ImageViewController *
- (ImageDetailController *)detailViewController {
  return [[ImageDetailController alloc] initWithItem:self editing:NO];
}

/// editingViewController
/// @return ImageViewController *
- (ImageDetailController *)editingViewController {
  return [[ImageDetailController alloc] initWithItem:self editing:YES];
}

/// preview
/// @return UIImage *
- (UIImage *)preview { return [self image]; }

/// thumbnail
/// @return UIImage *
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


@end
