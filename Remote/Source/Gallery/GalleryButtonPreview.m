//
// GalleryButtonPreview.m
// iPhonto
//
// Created by Jason Cardwell on 4/18/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "GalleryPreview.h"
#import "GalleryPreview_Private.h"

@implementation GalleryButtonPreview

+ (GalleryButtonPreview *)buttonPreviewWithName:(NSString *)name
                                        context:(NSManagedObjectContext *)context {
    return (GalleryButtonPreview *)[super previewWithName:name context:context];
}

@end
