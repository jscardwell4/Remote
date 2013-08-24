//
// ControlStateImageSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "REControlStateSet.h"
#import "BOImage.h"

static const int ddLogLevel   = LOG_LEVEL_WARN;
static const int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

@implementation REControlStateImageSet

@dynamic  colors;

/**
 * For some reason using `setValuesForKeysWithDictionary:`, as is done in the `REControlStateSet`
 * implementation of this method, calls `encodeWithCoder:` leading to a crash
 */
+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)moc
                             withObjects:(NSDictionary *)objects
{
    assert(moc);
    __block REControlStateImageSet * imageSet = nil;

    [moc performBlockAndWait:
     ^{
         imageSet = [self controlStateSetInContext:moc];
         [objects enumerateKeysAndObjectsUsingBlock:
          ^(id key, id obj, BOOL *stop)
          {
              imageSet[stateForProperty(key)] = obj;
          }];
     }];
    return imageSet;
}

+ (REControlStateImageSet *)imageSetWithImages:(NSDictionary *)images
                                       context:(NSManagedObjectContext *)moc
{
    return [self imageSetWithColors:@{} images:images context:moc];
}

+ (REControlStateImageSet *)imageSetWithColors:(id)colors
                                         images:(NSDictionary *)images
                                       context:(NSManagedObjectContext *)moc
{

    __block REControlStateImageSet * imageSet = nil;
    NSMutableDictionary * filteredImages = [images mutableCopy];
    [images enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop) {
         if ([obj isKindOfClass:[NSString class]])
             filteredImages[key] = [BOImage fetchImageNamed:(NSString *)obj context:moc];
     }];

    [moc performBlockAndWait:
     ^{
         imageSet = [self controlStateSetInContext:moc withObjects:filteredImages];

         if ([colors isKindOfClass:[REControlStateColorSet class]])
             [imageSet.colors copyObjectsFromSet:colors];
         else if ([colors isKindOfClass:[NSDictionary class]])
             [imageSet.colors setValuesForKeysWithDictionary:colors];
     }];
    
    return imageSet;
}


- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (MSModelObjectShouldInitialize)
        self.colors = [REControlStateColorSet controlStateSetInContext:self.managedObjectContext];
}

- (UIImage *)UIImageForState:(NSUInteger)state
{
    BOImage * image = self[state];
    UIColor * color = self.colors[state];
    return [image imageWithColor:color];
}

- (BOImage *)objectAtIndexedSubscript:(NSUInteger)state
{
    id object = (validState(state) ? [super objectAtIndexedSubscript:state] : nil);

    if ([object isKindOfClass:[BOImage class]]) return (BOImage *)object;

    else if ([object isKindOfClass:[NSURL class]])
        return (BOImage *)[self.managedObjectContext objectForURI:object];

    else return nil;
}


- (void)setObject:(BOImage *)image atIndexedSubscript:(NSUInteger)state
{
    assert(image);
    [super setObject:[image permanentURI] atIndexedSubscript:state];
}

- (MSDictionary *)deepDescriptionDictionary
{
    REControlStateImageSet * stateSet = [self faultedObject];
    assert(stateSet);

    MSMutableDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"normal"]                         = (stateSet[0].name ?: @"nil");
    dd[@"selected"]                       = (stateSet[1].name ?: @"nil");
    dd[@"highlighted"]                    = (stateSet[2].name ?: @"nil");
    dd[@"disabled"]                       = (stateSet[3].name ?: @"nil");
    dd[@"highlightedAndSelected"]         = (stateSet[4].name ?: @"nil");
    dd[@"highlightedAndDisabled"]         = (stateSet[5].name ?: @"nil");
    dd[@"disabledAndSelected"]            = (stateSet[6].name ?: @"nil");
    dd[@"selectedHighlightedAndDisabled"] = (stateSet[7].name ?: @"nil");

    return dd;
}

- (NSDictionary *)dictionaryFromSetObjects
{
    return [[super dictionaryFromSetObjects]
            dictionaryByAddingEntriesFromDictionary:@{@"colors":
                                                          [self.colors dictionaryFromSetObjects]}];
}

- (void)copyObjectsFromSet:(REControlStateImageSet *)set
{
    for (int i = 0; i < 8; i++) self[i] = set[i];
    [self.colors copyObjectsFromSet:set.colors];
}

@end
