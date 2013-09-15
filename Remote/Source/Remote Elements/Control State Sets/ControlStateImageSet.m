//
// ControlStateImageSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ControlStateSet.h"
#import "Image.h"

static const int ddLogLevel   = LOG_LEVEL_WARN;
static const int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

@implementation ControlStateImageSet

@dynamic  colors;

/**
 * For some reason using `setValuesForKeysWithDictionary:`, as is done in the `ControlStateSet`
 * implementation of this method, calls `encodeWithCoder:` leading to a crash
 */
+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)moc
                             withObjects:(NSDictionary *)objects
{
    assert(moc);
    __block ControlStateImageSet * imageSet = nil;

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

+ (ControlStateImageSet *)imageSetWithImages:(NSDictionary *)images
                                       context:(NSManagedObjectContext *)moc
{
    return [self imageSetWithColors:@{} images:images context:moc];
}

+ (ControlStateImageSet *)imageSetWithColors:(id)colors
                                         images:(NSDictionary *)images
                                       context:(NSManagedObjectContext *)moc
{

    __block ControlStateImageSet * imageSet = nil;
    NSMutableDictionary * filteredImages = [images mutableCopy];
    [images enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop) {
         if ([obj isKindOfClass:[NSString class]])
             filteredImages[key] = [Image fetchImageNamed:(NSString *)obj context:moc];
     }];

    [moc performBlockAndWait:
     ^{
         imageSet = [self controlStateSetInContext:moc withObjects:filteredImages];

         if ([colors isKindOfClass:[ControlStateColorSet class]])
             [imageSet.colors copyObjectsFromSet:colors];
         else if ([colors isKindOfClass:[NSDictionary class]])
             [imageSet.colors setValuesForKeysWithDictionary:colors];
     }];
    
    return imageSet;
}


- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (ModelObjectShouldInitialize)
        self.colors = [ControlStateColorSet controlStateSetInContext:self.managedObjectContext];
}

- (UIImage *)UIImageForState:(NSUInteger)state
{
    Image * image = self[state];
    UIColor * color = self.colors[state];
    return [image imageWithColor:color];
}

- (Image *)objectAtIndexedSubscript:(NSUInteger)state
{
    id object = (validState(state) ? [super objectAtIndexedSubscript:state] : nil);

    if ([object isKindOfClass:[Image class]]) return (Image *)object;

    else if ([object isKindOfClass:[NSURL class]])
        return (Image *)[self.managedObjectContext objectForURI:object];

    else return nil;
}


- (void)setObject:(Image *)image atIndexedSubscript:(NSUInteger)state
{
    assert(image);
    [super setObject:[image permanentURI] atIndexedSubscript:state];
}

- (MSDictionary *)deepDescriptionDictionary
{
    ControlStateImageSet * stateSet = [self faultedObject];
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

- (void)copyObjectsFromSet:(ControlStateImageSet *)set
{
    for (int i = 0; i < 8; i++) self[i] = set[i];
    [self.colors copyObjectsFromSet:set.colors];
}

@end
