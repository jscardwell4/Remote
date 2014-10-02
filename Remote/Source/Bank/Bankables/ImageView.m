//
//  ImageView.m
//  Remote
//
//  Created by Jason Cardwell on 8/24/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

#import "ImageView.h"
#import "Remote-Swift.h"


@interface ImageView ()

@property (nonatomic, strong) UIImage * colorImage;
@property (nonatomic, strong) UIImage * rawImage;

@end

@implementation ImageView

@dynamic color, image;
@synthesize colorImage = _colorImage, rawImage = _rawImage;

+ (instancetype)imageViewWithImage:(Image *)image color:(UIColor *)color {
  if (!image) ThrowInvalidNilArgument(image);
  ImageView * imageView = [self createInContext:image.managedObjectContext];
  imageView.image = image;
  imageView.color = color;
  return imageView;
}

- (UIImage *)colorImage {
  if (self.rawImage && self.color && !_colorImage)
    self.colorImage = [self.rawImage recoloredImageWithColor:self.color];
  return _colorImage;
}

- (UIImage *)rawImage {
  if (self.image && !_rawImage) self.rawImage = self.image.image;
  return _rawImage;
}

- (void)setImage:(Image *)image {
  [self willChangeValueForKey:@"image"];
  [self setPrimitiveValue:image forKey:@"image"];
  [self didChangeValueForKey:@"image"];
  self.rawImage   = nil;
  self.colorImage = nil;
}

- (void)setColor:(UIColor *)color {
  [self willChangeValueForKey:@"color"];
  [self setPrimitiveValue:color forKey:@"color"];
  [self didChangeValueForKey:@"color"];
  self.colorImage = nil;
}

@end
