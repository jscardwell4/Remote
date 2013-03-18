//
// ControlStateImageSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ControlStateSet.h"
#import "ControlStateSet_Private.h"

static int    ddLogLevel = LOG_LEVEL_OFF;
static BOOL   useCache   = NO;

#pragma mark - ControlStateImageSet

@implementation ControlStateImageSet

@synthesize
shouldUseCache = _shouldUseCache,
imageCache     = _imageCache;

+ (void)setClassShouldUseCache:(BOOL)shouldUseCache {
    useCache = shouldUseCache;
}

+ (BOOL)classShouldUseCache {
    return useCache;
}

- (void)setShouldUseCache:(BOOL)shouldUseCache {
    if (shouldUseCache && useCache) _shouldUseCache = YES;
    else _shouldUseCache = NO;
}

- (BOOL)shouldUseCache {
    if (_shouldUseCache && !useCache) _shouldUseCache = NO;

    return _shouldUseCache;
}

- (UIImage *)UIImageForState:(NSUInteger)state {
    return [self UIImageForState:state substituteIfNil:NO substitutedState:NULL];
}

- (UIImage *)UIImageForState:(NSUInteger)state
           substituteIfNil:(BOOL)substitute
          substitutedState:(NSUInteger *)substitutedState {
    // Check state validity
    if (IsInvalidControlState(state)) return nil;

    // Check cache for image and return if found

    UIImage * image = nil;

    if (self.shouldUseCache) {
        image = self.imageCache[state];
        if (ValueIsNotNil(image)) return image;
    }

    // No substitutes, look for original image and return results
    if (!substitute) {
        image = [[self imageForState:state] image];

        if (self.shouldUseCache)
            // Insert image into cache if valid
            if (ValueIsNotNil(image)) [self.imageCache insertObject:image atIndex:state];
    }
    // Substitution is okay, check original and alternate states
    else {
        id   imageURIData = [self alternateObjectStateForState:state
                                              substitutedState:substitutedState];

        // Return if couldn't find a substitute
        if (ValueIsNil(imageURIData)) return nil;

        if (self.shouldUseCache)
            // Otherwise check the cache for the substitute
            image = self.imageCache[*substitutedState];

        // Get image if not in cache
        if (ValueIsNil(image)) {
            image = [[self imageForState:*substitutedState] image];

            if (self.shouldUseCache)
                // Stick in cache for substituted state as well
                [self.imageCache insertObject:image atIndex:*substitutedState];
        }

        if (self.shouldUseCache)
            // Stick in original state cache slot
            [self.imageCache insertObject:CollectionSafeValue(image) atIndex:state];
    }

    // Return what we have
    return NilSafeValue(image);
}  /* imageForState */

- (REImage *)imageForState:(NSUInteger)state {
    NSData * imageURIData = (NSData *)[super objectForState:state];
    NSURL  * imageURI     = nil;

    if (ValueIsNotNil(imageURIData)) imageURI = (NSURL *)[NSKeyedUnarchiver unarchiveObjectWithData:imageURIData];

    NSManagedObjectID * imageID = [self.managedObjectContext.persistentStoreCoordinator
                                   managedObjectIDForURIRepresentation:imageURI];
    REImage * image = nil;

    if (imageID) image = (REImage *)[self.managedObjectContext objectWithID:imageID];

    return image;
}

- (REImage *)imageForState:(NSUInteger)state
                       substituteIfNil:(BOOL)substitute
                      substitutedState:(NSUInteger *)substitutedState {
    UIControlState   localSubstitutedState = state;
    id               imageURIData          = [self alternateObjectStateForState:state
                                                               substitutedState:&localSubstitutedState];

    if (ValueIsNil(imageURIData) || (state != localSubstitutedState && !substitute)) return nil;

    REImage * image = [self imageForState:localSubstitutedState];

    if (substitutedState != NULL) *substitutedState = localSubstitutedState;

    return NilSafeValue(image);
}

- (void)setImage:(REImage *)image forState:(NSUInteger)state {
    if (ValueIsNil(image)) {
        [super setObject:nil forState:state];

        return;
    }

    if ([image.objectID isTemporaryID]) {
        NSError * error = nil;

        [image.managedObjectContext
         obtainPermanentIDsForObjects:@[image]
                                error:&error];
        if (error) {
            DDLogWarn(@"%@\n\tfailed to obtain permanent id for gallery image: %@, %@",
                      ClassTagString, error, [error localizedDescription]);
            [super setObject:nil forState:state];

            return;
        }
    }

    NSURL  * uriURL       = [image.objectID URIRepresentation];
    NSData * imageURIData = [NSKeyedArchiver archivedDataWithRootObject:uriURL];

    [super setObject:imageURIData forState:state];
}

- (NSMutableArray *)imageCache {
    if (!self.shouldUseCache) return nil;

    if (ValueIsNotNil(_imageCache)) return _imageCache;

    DDLogDebug(@"%@\n\tcreating empty image cache...", ClassTagString);
    self.imageCache = [NSMutableArray arrayWithNullCapacity:8];

    return _imageCache;
}

- (void)emptyCache {
    if (ValueIsNotNil(_imageCache)) [self.imageCache replaceAllObjectsWithNull];
}

@end
