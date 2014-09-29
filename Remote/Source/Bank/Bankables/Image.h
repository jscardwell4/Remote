//
// Image.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
@import Lumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"
#import "BankableModelObject.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Image
////////////////////////////////////////////////////////////////////////////////

@class ImageCategory;

@interface Image : BankableModelObject

- (UIImage *)imageWithColor:(UIColor *)color;

- (void)flushThumbnail;

@property (nonatomic, weak,   readonly) UIImage       * image;
@property (nonatomic, assign)           CGSize          thumbnailSize;
@property (nonatomic, strong)           NSString      * assetName;
@property (nonatomic, strong)           NSNumber      * leftCap;
@property (nonatomic, strong)           NSNumber      * topCap;
@property (nonatomic, strong, readonly) UIImage       * stretchableImage;
@property (nonatomic, assign, readonly) CGSize          size;
@property (nonatomic, strong)           ImageCategory * category;

@end

