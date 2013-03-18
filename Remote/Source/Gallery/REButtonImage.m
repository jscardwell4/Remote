//
// ButtonImage.m
// Remote
//
// Created by Jason Cardwell on 6/16/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "REImage_Private.h"
#import "BankObjectGroup.h"

static int   ddLogLevel = DefaultDDLogLevel;

@implementation REButtonImage

@dynamic state;

+ (REButtonImage *)buttonImageForFile:(NSString *)name
                                   context:(NSManagedObjectContext *)context {
    return (REButtonImage *)[super imageWithFileName:name context:context];
}

+ (REButtonImage *)buttonImageForFile:(NSString *)name
                                     group:(BankObjectGroup *)group {
    return (REButtonImage *)[super imageWithFileName:name group:group];
}

+ (REButtonImage *)fetchButtonWithTag:(NSInteger)tag
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

    if (self.shouldUseCache) image = [REImage cachedButtonImageForTag:self.tag];

    if (ValueIsNil(image)) {
        image = [super image];

        if (self.shouldUseCache && ValueIsNotNil(image)) [REImage cacheButtonImage:image forTag:self.tag];
    }

    return image;
}

@end
