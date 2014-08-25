//
//  ImageView.h
//  Remote
//
//  Created by Jason Cardwell on 8/24/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ModelObject.h"
@class Image;

@interface ImageView : ModelObject

@property (nonatomic, strong) UIColor * color;
@property (nonatomic, strong) Image   * image;
@property (nonatomic, readonly) UIImage * colorImage;

+ (instancetype)imageViewWithImage:(Image *)image color:(UIColor *)color;

@end
