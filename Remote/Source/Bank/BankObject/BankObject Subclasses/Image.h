//
// Image.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "Bank.h"
#import "ModelObject.h"

@class BOImageGroup;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Image
////////////////////////////////////////////////////////////////////////////////

@interface Image : ModelObject<Bankable>

+ (instancetype)imageWithFileName:(NSString *)name context:(NSManagedObjectContext *)context;
+ (instancetype)imageWithFileName:(NSString *)name group:(BOImageGroup *)group;

- (UIImage *)imageWithColor:(UIColor *)color;

+ (instancetype)fetchImageNamed:(NSString *)name context:(NSManagedObjectContext *)context;

- (void)flushThumbnail;

@property (nonatomic, strong, readonly) NSString        * fileName;
@property (nonatomic, strong)           NSString        * name;
@property (nonatomic, strong)           BOImageGroup * group;

@property (nonatomic, weak,   readonly) UIImage         * image;
@property (nonatomic, strong, readonly) UIImage         * thumbnail;

@property (nonatomic, assign)           CGSize            thumbnailSize;
@property (nonatomic, strong)           NSNumber        * leftCap;
@property (nonatomic, strong)           NSNumber        * topCap;
@property (nonatomic, strong, readonly) UIImage         * stretchableImage;
@property (nonatomic, assign, readonly) CGSize            size;
@property (nonatomic, strong, readonly) UIImage         * preview;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Bundled Image
////////////////////////////////////////////////////////////////////////////////


@interface BOBundledImage : Image

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Custom Image
////////////////////////////////////////////////////////////////////////////////


@interface BOCustomImage : Image

@end

