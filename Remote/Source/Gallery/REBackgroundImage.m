//
// BackgroundImage.m
// Remote
//
// Created by Jason Cardwell on 6/16/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "REImage_Private.h"
#import "BankObjectGroup.h"

static int   ddLogLevel = DefaultDDLogLevel;

@implementation REBackgroundImage
@dynamic
buttonGroups,
remotes;

+ (REBackgroundImage *)backgroundImageForFile:(NSString *)name
                                           context:(NSManagedObjectContext *)context {
    return (REBackgroundImage *)[super imageWithFileName:name context:context];
}

+ (REBackgroundImage *)backgroundImageForFile:(NSString *)name
                                             group:(BankObjectGroup *)group {
    return (REBackgroundImage *)[super imageWithFileName:name group:group];
}

+ (REBackgroundImage *)fetchBackgroundImageWithTag:(NSInteger)tag
                                                context:(NSManagedObjectContext *)context {
    __block NSArray * fetchedObjects = nil;

    [context performBlockAndWait:^{
                 NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"REBackgroundImage"];

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

    if (self.shouldUseCache) image = [REImage cachedBackgroundImageForTag:self.tag];

    if (ValueIsNil(image)) {
        image = [super image];

        if (self.shouldUseCache && ValueIsNotNil(image)) [REImage cacheBackgroundImage:image forTag:self.tag];
    }

    return image;
}

@end
