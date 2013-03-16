//
// GalleryPreview.m
// iPhonto
//
// Created by Jason Cardwell on 4/18/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "GalleryPreview.h"
#import "GalleryPreview_Private.h"
#import "CoreDataManager.h"

@implementation GalleryPreview

@dynamic imageData, tag, name;

@synthesize image = _image;

+ (GalleryPreview *)previewWithName:(NSString *)name
                            context:(NSManagedObjectContext *)context {
    if (StringIsEmpty(name) || ValueIsNil(context)) return nil;

    GalleryPreview * preview =
        [NSEntityDescription insertNewObjectForEntityForName:ClassString([self class])
                                      inManagedObjectContext:context];

    if (ValueIsNotNil(preview)) {
        preview.name = name;
        preview.tag  = [preview nextTag];
    }

    return preview;
}

+ (NSArray *)previewImages {
    __block NSArray * fetchedObjects = nil;

    [[DataManager mainObjectContext] performBlockAndWait:^{
                                         NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ClassString([self class])];

                                         NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc]                                  initWithKey:@"tag"
                                                                                                         ascending:YES];
                                         NSArray * sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
                                         [fetchRequest setSortDescriptors:sortDescriptors];

                                         NSError * error = nil;
                                         fetchedObjects = [[DataManager mainObjectContext]                                  executeFetchRequest:fetchRequest
                                                                                                         error:&error];
                                     }

    ];

    if (fetchedObjects == nil)

        // Handle the error
        return nil;
    else
        return [fetchedObjects valueForKeyPath:@"image"];
}

- (int16_t)nextTag {
    __block int16_t   tag = 1;

    [self.managedObjectContext
     performBlockAndWait:^{
         NSFetchRequest * request = [[NSFetchRequest alloc] init];
         NSEntityDescription * entity = self.entity;
         [request setEntity:entity];

         // Specify that the request should return dictionaries.
         [request setResultType:NSDictionaryResultType];

         // Create an expression for the key path.
         NSExpression * keyPathExpression = [NSExpression expressionForKeyPath:@"tag"];

         // Create an expression to represent the minimum value at the key path 'creationDate'
         NSExpression * maxExpression =
            [NSExpression expressionForFunction:@"max:"
                                      arguments:@[keyPathExpression]];

         // Create an expression description using the minExpression and returning a date.
         NSExpressionDescription * expressionDescription = [[NSExpressionDescription alloc] init];

         // The name is the key that will be used in the dictionary for the return value.
         [expressionDescription setName:@"tag"];
         [expressionDescription setExpression:maxExpression];
         [expressionDescription setExpressionResultType:NSInteger16AttributeType];

         // Set the request's properties to fetch just the property represented by the expressions.
         [request setPropertiesToFetch:@[expressionDescription]];

         // Execute the fetch.
         NSError * error = nil;
         NSArray * objects = [self.managedObjectContext
                             executeFetchRequest:request
                                           error:&error];
         if (objects && objects.count) {
            NSNumber * maxTag = [objects[0]
                                 valueForKey:@"tag"];
            tag = [maxTag integerValue] + 1;
         }
     }

    ];

    return tag;
}

- (void)setImage:(UIImage *)image {
    if (ValueIsNil(image)) return;

    _image         = image;
    self.imageData = UIImagePNGRepresentation(_image);
}

- (UIImage *)image {
    if (ValueIsNotNil(_image) || ValueIsNil(self.imageData)) return _image;

    _image = [UIImage imageWithData:self.imageData scale:MainScreenScale];

    return _image;
}

@end
