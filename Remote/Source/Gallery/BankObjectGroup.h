//
// BankObjectGroup.h
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class   REImage;

@interface BankObjectGroup : NSManagedObject {
    @private
}

+ (BankObjectGroup *)defaultGalleryGroupInContext:(NSManagedObjectContext *)context;
+ (BankObjectGroup *)newGalleryGroupWithName:(NSString *)name inContext:(NSManagedObjectContext *)context;
+ (BankObjectGroup *)fetchGalleryGroupWithName:(NSString *)name inContext:(NSManagedObjectContext *)context;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSSet    * images;
@property (nonatomic, strong) NSSet    * presets;
// @property (nonatomic, readonly) NSArray * buttons;
// @property (nonatomic, readonly) NSArray * backgrounds;

@end
