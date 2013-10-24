//
// ControlStateImageSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ControlStateImageSet.h"
#import "ControlStateColorSet.h"
#import "Image.h"

static int ddLogLevel   = LOG_LEVEL_WARN;
static const int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)

@implementation ControlStateImageSet

@dynamic  colors;

/**
 * For some reason using `setValuesForKeysWithDictionary:`, as is done in the `ControlStateSet`
 * implementation of this method, calls `encodeWithCoder:` leading to a crash
 * NOTE: not sure if this is still true
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
              imageSet[[ControlStateSet stateForProperty:key]] = obj;
          }];
     }];
    return imageSet;
}

+ (ControlStateImageSet *)imageSetWithImages:(NSDictionary *)images
                                     context:(NSManagedObjectContext *)moc
{
    return [self imageSetWithColors:nil images:images context:moc];
}

+ (ControlStateImageSet *)imageSetWithColors:(id)colors
                                      images:(NSDictionary *)images
                                     context:(NSManagedObjectContext *)moc
{

    if (!images) ThrowInvalidNilArgument(images);

    __block ControlStateImageSet * imageSet = nil;
    MSDictionary * filteredImages = [MSDictionary dictionaryWithDictionary:images];
    [images enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop)
     {
         if ([obj isKindOfClass:[NSString class]])
         {
             filteredImages[key] = CollectionSafe([Image objectWithUUID:obj context:moc]);
         }
     }];
    [filteredImages compact];

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
    id object = ([ControlStateSet validState:@(state)] ? [super objectAtIndexedSubscript:state] : nil);

    if ([object isKindOfClass:[Image class]]) return (Image *)object;

    else if ([object isKindOfClass:[NSURL class]])
        return (Image *)[self.managedObjectContext objectForURI:object];

    else return nil;
}

- (Image *)objectForKeyedSubscript:(NSString *)key
{
    NSURL * uri = [super objectForKeyedSubscript:key];
    return (uri ? [self.managedObjectContext objectForURI:uri] : nil);
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

    NSString *(^nameForValueForKey)(NSString*) = ^NSString *(NSString *key)
    {
        id value = [stateSet valueForKey:key];
        Image * image = nil;
        if ([value isKindOfClass:[NSURL class]])
        {
            image = (Image *)[stateSet.managedObjectContext objectForURI:(NSURL *)value];
        }

        else if ([value isKindOfClass:[Image class]])
            image = (Image *)value;

        return (image ? image.name : @"nil");
    };

    MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];
    dd[@"normal"]                         = nameForValueForKey(@"normal");
    dd[@"selected"]                       = nameForValueForKey(@"selected");
    dd[@"highlighted"]                    = nameForValueForKey(@"highlighted");
    dd[@"disabled"]                       = nameForValueForKey(@"disabled");
    dd[@"highlightedAndSelected"]         = nameForValueForKey(@"highlightedAndSelected");
    dd[@"highlightedAndDisabled"]         = nameForValueForKey(@"highlightedAndDisabled");
    dd[@"disabledAndSelected"]            = nameForValueForKey(@"disabledAndSelected");
    dd[@"selectedHighlightedAndDisabled"] = nameForValueForKey(@"selectedHighlightedAndDisabled");

    return (MSDictionary *)dd;
}

- (NSDictionary *)dictionaryFromSetObjects
{
    NSMutableDictionary * dictionary = [[super dictionaryFromSetObjects] mutableCopy];
    if (![self.colors isEmptySet])
        dictionary[@"colors"] = [self.colors dictionaryFromSetObjects];

    return dictionary;
}


- (MSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];
    dictionary.userInfo[MSJSONCommentKey] = [MSDictionary dictionary];

    NSArray * keys = [[self dictionaryFromSetObjects] allKeys];
    for (NSString * key in keys)
    {
        if ([@"colors" isEqualToString:key])
        {
            dictionary[key] = [self.colors JSONDictionary];
            continue;
        }

        else if (![ControlStateSet validState:key]) continue;

        Image * i = self[key];
        assert(i);
        [dictionary removeObjectForKey:key];

        NSString * keypath = [@"." join:@[key, @"uuid"]];
        dictionary[keypath] = i.uuid;
        dictionary.userInfo[MSJSONCommentKey][keypath] = i.fileName;
    }

    [dictionary compact];
    [dictionary compress];

    return dictionary;
}

- (void)copyObjectsFromSet:(ControlStateImageSet *)set
{
    for (int i = 0; i < 8; i++) self[i] = set[i];
    [self.colors copyObjectsFromSet:set.colors];
}


@end
