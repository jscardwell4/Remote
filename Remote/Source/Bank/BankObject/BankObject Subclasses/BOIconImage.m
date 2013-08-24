//
// IconImage.m
// Remote
//
// Created by Jason Cardwell on 6/16/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "BOImage_Private.h"

static int   ddLogLevel = DefaultDDLogLevel;

@implementation BOIconImage

@dynamic previewData, iconSet, subcategory;

- (void)generatePreviewData {
    self.previewData = UIImagePNGRepresentation([self imageWithColor:WhiteColor]);
}

- (UIImage *)preview {
    NSData * previewData = self.previewData;
    
    if (!previewData) {
        DDLogWarn(@"%@ no preview data exists", ClassTagStringForInstance(self.name));
        previewData = UIImagePNGRepresentation([self imageWithColor:WhiteColor]);
        assert(previewData);
        self.previewData = previewData;
    }

    UIImage * preview = [UIImage imageWithData:previewData scale:2.0];

    return preview;
}

@end
