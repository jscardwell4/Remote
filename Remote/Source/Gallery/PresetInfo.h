//
// PresetInfo.h
// Remote
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class   BankObjectGroup;

@interface PresetInfo : NSManagedObject {
    @private
}
+ (PresetInfo *)newPresetInfoWithName:(NSString *)presetName
                      andGalleryGroup:(BankObjectGroup *)galleryGroup
                            inContext:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSString     * presetName;
@property (nonatomic, strong) BankObjectGroup * galleryGroup;

@end
