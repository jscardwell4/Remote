//
// ButtonImage.m
// iPhonto
//
// Created by Jason Cardwell on 6/16/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "GalleryImage.h"
#import "GalleryImage_Private.h"
#import "GalleryGroup.h"

static int   ddLogLevel = DefaultDDLogLevel;

@implementation GalleryButtonImage

@dynamic state;

+ (GalleryButtonImage *)buttonImageForFile:(NSString *)name
                                   context:(NSManagedObjectContext *)context {
    return (GalleryButtonImage *)[super imageWithFileName:name context:context];
}

+ (GalleryButtonImage *)buttonImageForFile:(NSString *)name
                                     group:(GalleryGroup *)group {
    return (GalleryButtonImage *)[super imageWithFileName:name group:group];
}

+ (GalleryButtonImage *)fetchButtonWithTag:(NSInteger)tag
                                     state:(ButtonImageState)state
                                   context:(NSManagedObjectContext *)context {
    __block NSArray * fetchedObjects = nil;

    [context performBlockAndWait:^{
                 NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"GalleryButtonImage"];

                 NSPredicate * predicate =
                 [NSPredicate predicateWithFormat:@"tag == %i && state == %i", tag, state];
                 [fetchRequest setPredicate:predicate];

                 NSError * error = nil;
                 fetchedObjects = [context          executeFetchRequest:fetchRequest
                                                         error:&error];
                 if (ValueIsNil(fetchedObjects)) DDLogError(@"No buttons with tag %i were found for state %i", tag, state);
             }

    ];

    return fetchedObjects.count ?[fetchedObjects lastObject] : nil;
}

- (void)setFileName:(NSString *)fileName {
    [super setFileName:fileName];
    // Handle state portion of name
}

- (UIImage *)image {
    UIImage * image = nil;

    if (self.shouldUseCache) image = [GalleryImage cachedButtonImageForTag:self.tag];

    if (ValueIsNil(image)) {
        image = [super image];

        if (self.shouldUseCache && ValueIsNotNil(image)) [GalleryImage cacheButtonImage:image forTag:self.tag];
    }

    return image;
}

@end
