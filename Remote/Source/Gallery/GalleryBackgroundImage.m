//
// BackgroundImage.m
// iPhonto
//
// Created by Jason Cardwell on 6/16/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "GalleryImage.h"
#import "GalleryImage_Private.h"
#import "GalleryGroup.h"

static int   ddLogLevel = DefaultDDLogLevel;

@implementation GalleryBackgroundImage
@dynamic
buttonGroups,
remotes;

+ (GalleryBackgroundImage *)backgroundImageForFile:(NSString *)name
                                           context:(NSManagedObjectContext *)context {
    return (GalleryBackgroundImage *)[super imageWithFileName:name context:context];
}

+ (GalleryBackgroundImage *)backgroundImageForFile:(NSString *)name
                                             group:(GalleryGroup *)group {
    return (GalleryBackgroundImage *)[super imageWithFileName:name group:group];
}

+ (GalleryBackgroundImage *)fetchBackgroundImageWithTag:(NSInteger)tag
                                                context:(NSManagedObjectContext *)context {
    __block NSArray * fetchedObjects = nil;

    [context performBlockAndWait:^{
                 NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"GalleryBackgroundImage"];

                 NSPredicate * predicate = [NSPredicate predicateWithFormat:@"tag == %i", tag];
                 [fetchRequest setPredicate:predicate];

                 NSError * error = nil;
                 fetchedObjects = [context          executeFetchRequest:fetchRequest
                                                         error:&error];
                 if (ValueIsNil(fetchedObjects)) DDLogWarn(@"%@\n\tNo icons with tag %i were found", ClassTagString, tag);
             }

    ];

    return fetchedObjects.count ?[fetchedObjects lastObject] : nil;
}

- (UIImage *)image {
    UIImage * image = nil;

    if (self.shouldUseCache) image = [GalleryImage cachedBackgroundImageForTag:self.tag];

    if (ValueIsNil(image)) {
        image = [super image];

        if (self.shouldUseCache && ValueIsNotNil(image)) [GalleryImage cacheBackgroundImage:image forTag:self.tag];
    }

    return image;
}

@end
