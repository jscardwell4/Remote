//
// PresetInfo.m
// iPhonto
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "PresetInfo.h"
#import "GalleryGroup.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation PresetInfo
@dynamic presetName;
@dynamic galleryGroup;

/*
 * newPresetInfoWithName:andGalleryGroup:inContext:
 */
+ (PresetInfo *)newPresetInfoWithName:(NSString *)presetName andGalleryGroup:(GalleryGroup *)galleryGroup inContext:(NSManagedObjectContext *)context {
    PresetInfo * presetInfo = [NSEntityDescription insertNewObjectForEntityForName:@"PresetInfo" inManagedObjectContext:context];

    presetInfo.presetName   = presetName;
    presetInfo.galleryGroup = galleryGroup;

    return presetInfo;
}

@end
