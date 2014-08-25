//
//  ImageView.m
//  Remote
//
//  Created by Jason Cardwell on 8/24/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

#import "ImageView.h"
#import "Image.h"


@implementation ImageView

@dynamic color;
@dynamic image;


+ (instancetype)imageViewWithImage:(Image *)image color:(UIColor *)color {
  if (!image) ThrowInvalidNilArgument(image);
  ImageView * imageView = [self createInContext:image.managedObjectContext];
  imageView.image = image;
  imageView.color = color;
  return imageView;
}

- (UIImage *)colorImage {
  return (self.color ? [self.image imageWithColor:self.color] : self.image.image);
}

@end
