//
// IconImage.m
// Remote
//
// Created by Jason Cardwell on 6/16/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "REImage_Private.h"
#import "BankObjectGroup.h"
#import <QuartzCore/QuartzCore.h>

// #define GENERATE_PREVIEW_ON_CREATION

static int   ddLogLevel = DefaultDDLogLevel;

@implementation REIconImage

@dynamic
previewData,
iconSet,
subcategory;

+ (REIconImage *)iconImageForFile:(NSString *)name
                               context:(NSManagedObjectContext *)context {
    REIconImage * image = (REIconImage *)[super imageWithFileName:name context:context];

#ifdef GENERATE_PREVIEW_ON_CREATION
    if (image) [image generatePreviewData];
#endif

    return image;
}

+ (REIconImage *)iconImageForFile:(NSString *)name
                                 group:(BankObjectGroup *)group {
    REIconImage * image = (REIconImage *)[super imageWithFileName:name group:group];

#ifdef GENERATE_PREVIEW_ON_CREATION
    if (ValueIsNotNil(image)) [image generatePreviewData];
#endif

    return image;
}

+ (REIconImage *)fetchIconWithTag:(NSInteger)tag context:(NSManagedObjectContext *)context {
    __block NSArray * fetchedObjects = nil;

// [context performBlockAndWait:^{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"REIconImage"];
    NSPredicate    * predicate    = [NSPredicate predicateWithFormat:@"tag == %i", tag];

    [fetchRequest setPredicate:predicate];

    NSError * error = nil;

    fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

    if (ValueIsNil(fetchedObjects)) DDLogWarn(@"No icons with tag %i were found", tag);

// }];

    return fetchedObjects.count ?[fetchedObjects lastObject] : nil;
}

- (void)generatePreviewData {
    self.previewData = UIImagePNGRepresentation([self imageWithColor:[UIColor whiteColor]]);
}

- (UIImage *)preview {
    NSData * previewData = self.previewData;

    if (!previewData) {
        DDLogWarn(@"%@ no preview data exists", ClassTagStringForInstance(self.name));

        return nil;
    }

    UIImage * preview = [UIImage imageWithData:previewData scale:self.useRetinaScale ? 2.0:1.0];

    return preview;
}

- (UIImage *)image {
    UIImage * image = nil;

    if (self.shouldUseCache) image = [REImage cachedIconImageForTag:self.tag];

    if (!image) {
        image = [super image];

        if (self.shouldUseCache && ValueIsNotNil(image)) [REImage cacheIconImage:image forTag:self.tag];
    }

    return image;
}

@end
