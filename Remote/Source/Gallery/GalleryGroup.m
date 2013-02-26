//
// GalleryGroup.m
// iPhonto
//
// Created by Jason Cardwell on 6/1/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "GalleryGroup.h"
#import "GalleryImage.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@implementation GalleryGroup
@dynamic name;
@dynamic images;
@dynamic presets;

static GalleryGroup * defaultGalleryGroup;

+ (GalleryGroup *)defaultGalleryGroupInContext:(NSManagedObjectContext *)context {
    if (ValueIsNotNil(defaultGalleryGroup) && defaultGalleryGroup.managedObjectContext == context) return defaultGalleryGroup;

    [context performBlockAndWait:^{
                 NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
                 NSEntityDescription * entity = [NSEntityDescription entityForName:@"GalleryGroup"
                                                   inManagedObjectContext:context];
                 [fetchRequest setEntity:entity];

                 NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == %@", @"Default"];
                 [fetchRequest setPredicate:predicate];

                 NSError * error = nil;
                 NSArray * fetchedObjects = [context          executeFetchRequest:fetchRequest
                                                                   error:&error];
                 if (ValueIsNil(fetchedObjects) || [fetchedObjects count] == 0)
                 defaultGalleryGroup = [self      newGalleryGroupWithName:@"Default"
                                                           inContext:context];
                 else defaultGalleryGroup = [fetchedObjects lastObject];
             }

    ];

    return defaultGalleryGroup;
}

+ (GalleryGroup *)newGalleryGroupWithName:(NSString *)name
                                inContext:(NSManagedObjectContext *)context {
    GalleryGroup * galleryGroup =
        [NSEntityDescription insertNewObjectForEntityForName:@"GalleryGroup" inManagedObjectContext:context];

    galleryGroup.name = name;

    return galleryGroup;
}

/*
 * fetchGalleryGroupWithName:inContext:
 */
+ (GalleryGroup *)fetchGalleryGroupWithName:(NSString *)name inContext:(NSManagedObjectContext *)context {
    __block NSArray * fetchedObjects = nil;

    [context performBlockAndWait:^{
                 NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
                 NSEntityDescription * entity = [NSEntityDescription entityForName:@"GalleryGroup"
                                                   inManagedObjectContext:context];

                 [fetchRequest setEntity:entity];

                 NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
                 [fetchRequest setPredicate:predicate];

                 NSError * error = nil;
                 fetchedObjects = [context          executeFetchRequest:fetchRequest
                                                         error:&error];
             }

    ];

    return fetchedObjects.count ?[fetchedObjects lastObject] : nil;
}

/*- (NSArray *)buttons {
 *  NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary
 * *bindings) {
 *      Image *image = (Image *)evaluatedObject;
 *      return [@"Button" isEqualToString:image.type ];
 *  }];
 *  return [[self.images filteredSetUsingPredicate:filter] allObjects];
 * }
 * - (NSArray *)backgrounds {
 *  NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary
 * *bindings) {
 *      Image *image = (Image *)evaluatedObject;
 *      return [@"Background" isEqualToString:image.type];
 *  }];
 *  return [[self.images filteredSetUsingPredicate:filter] allObjects];
 * }*/

- (void)addImagesObject:(GalleryImage *)value {
    NSSet * changedObjects = [[NSSet alloc] initWithObjects:&value count:1];

    [self willChangeValueForKey:@"images" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"images"] addObject:value];
    [self didChangeValueForKey:@"images" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

/*
 * removeImagesObject:
 */
- (void)removeImagesObject:(GalleryImage *)value {
    NSSet * changedObjects = [[NSSet alloc] initWithObjects:&value count:1];

    [self willChangeValueForKey:@"images" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"images"] removeObject:value];
    [self didChangeValueForKey:@"images" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

/*
 * addImages:
 */
- (void)addImages:(NSSet *)value {
    [self willChangeValueForKey:@"images" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"images"] unionSet:value];
    [self didChangeValueForKey:@"images" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

/*
 * removeImages:
 */
- (void)removeImages:(NSSet *)value {
    [self willChangeValueForKey:@"images" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"images"] minusSet:value];
    [self didChangeValueForKey:@"images" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

/*
 * addPresetsObject:
 */
- (void)addPresetsObject:(NSManagedObject *)value {
    NSSet * changedObjects = [[NSSet alloc] initWithObjects:&value count:1];

    [self willChangeValueForKey:@"presets" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"presets"] addObject:value];
    [self didChangeValueForKey:@"presets" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

/*
 * removePresetsObject:
 */
- (void)removePresetsObject:(NSManagedObject *)value {
    NSSet * changedObjects = [[NSSet alloc] initWithObjects:&value count:1];

    [self willChangeValueForKey:@"presets" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"presets"] removeObject:value];
    [self didChangeValueForKey:@"presets" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

/*
 * addPresets:
 */
- (void)addPresets:(NSSet *)value {
    [self willChangeValueForKey:@"presets" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"presets"] unionSet:value];
    [self didChangeValueForKey:@"presets" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

/*
 * removePresets:
 */
- (void)removePresets:(NSSet *)value {
    [self willChangeValueForKey:@"presets" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"presets"] minusSet:value];
    [self didChangeValueForKey:@"presets" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

@end
