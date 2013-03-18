//
// REImage.h
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "BankObject.h"

@class   BankObjectGroup, RERemote, REButtonGroup;

#pragma mark - REImage

@interface REImage : BankObject <MSCaching>

+ (REImage *)imageWithFileName:(NSString *)name context:(NSManagedObjectContext *)context;
+ (REImage *)imageWithFileName:(NSString *)name group:(BankObjectGroup *)group;

@property (nonatomic, weak, readonly) NSString  * fileName;
@property (nonatomic, strong) NSString          * name;
@property (nonatomic, strong) BankObjectGroup      * group;
@property (nonatomic, weak, readonly) UIImage   * image;
@property (nonatomic, strong, readonly) UIImage * thumbnail;
@property (nonatomic, assign) CGSize              thumbnailSize;
@property (nonatomic, assign) int16_t             tag;
@property (nonatomic, strong) NSNumber          * leftCap;
@property (nonatomic, strong) NSNumber          * topCap;
@property (nonatomic, strong, readonly) UIImage * stretchableImage;
@property (nonatomic, assign) CGSize              size;
@property (nonatomic, assign, readonly) BOOL      useRetinaScale;

- (UIImage *)imageWithColor:(UIColor *)color;

- (void)flushThumbnail;

@end

#pragma mark - REIconImage

@interface REIconImage : REImage

+ (REIconImage *)iconImageForFile:(NSString *)name context:(NSManagedObjectContext *)context;

+ (REIconImage *)iconImageForFile:(NSString *)name group:(BankObjectGroup *)group;

+ (REIconImage *)fetchIconWithTag:(NSInteger)tag context:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSString          * iconSet;
@property (nonatomic, strong) NSString          * subcategory;
@property (nonatomic, strong, readonly) UIImage * preview;

@end

#pragma mark - REBackgroundImage

@interface REBackgroundImage : REImage

+ (REBackgroundImage *)backgroundImageForFile:(NSString *)name
                                           context:(NSManagedObjectContext *)context;

+ (REBackgroundImage *)backgroundImageForFile:(NSString *)name group:(BankObjectGroup *)group;

+ (REBackgroundImage *)fetchBackgroundImageWithTag:(NSInteger)tag
                                                context:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSSet * buttonGroups;
@property (nonatomic, strong) NSSet * remotes;

@end

typedef NS_ENUM (BOOL, ButtonImageState) {
    ButtonImageStateReleased = NO,
    ButtonImageStatePressed  = YES
};

#pragma mark - REButtonImage

@interface REButtonImage : REImage

+ (REButtonImage *)buttonImageForFile:(NSString *)name
                                   context:(NSManagedObjectContext *)context;

+ (REButtonImage *)buttonImageForFile:(NSString *)name group:(BankObjectGroup *)group;

+ (REButtonImage *)fetchButtonWithTag:(NSInteger)tag
                                     state:(ButtonImageState)state
                                   context:(NSManagedObjectContext *)context;

@property (nonatomic, assign) int16_t   state;

@end
