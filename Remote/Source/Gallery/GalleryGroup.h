//
// GalleryGroup.h
// iPhonto
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class   GalleryImage;

@interface GalleryGroup : NSManagedObject {
    @private
}

+ (GalleryGroup *)defaultGalleryGroupInContext:(NSManagedObjectContext *)context;
+ (GalleryGroup *)newGalleryGroupWithName:(NSString *)name inContext:(NSManagedObjectContext *)context;
+ (GalleryGroup *)fetchGalleryGroupWithName:(NSString *)name inContext:(NSManagedObjectContext *)context;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSSet    * images;
@property (nonatomic, strong) NSSet    * presets;
// @property (nonatomic, readonly) NSArray * buttons;
// @property (nonatomic, readonly) NSArray * backgrounds;

@end
