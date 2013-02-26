//
// GalleryPreview.h
// iPhonto
//
// Created by Jason Cardwell on 4/18/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@interface GalleryPreview : NSManagedObject

@property (nonatomic) int16_t            tag;
@property (nonatomic, strong) NSString * name;

+ (GalleryPreview *)previewWithName:(NSString *)name context:(NSManagedObjectContext *)context;

+ (NSArray *)previewImages;

@property (nonatomic, strong) UIImage * image;

@end

@interface GalleryButtonPreview : GalleryPreview

+ (GalleryButtonPreview *)buttonPreviewWithName:(NSString *)name
                                        context:(NSManagedObjectContext *)context;

@end
