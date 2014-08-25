//
// ControlStateImageSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ControlStateImageSet.h"
#import "ControlStateColorSet.h"
#import "ImageView.h"
#import "Image.h"
#import "RemoteElementImportSupportFunctions.h"
#import "RemoteElementExportSupportFunctions.h"

static int       ddLogLevel   = LOG_LEVEL_WARN;
static const int msLogContext = (LOG_CONTEXT_REMOTE | LOG_CONTEXT_FILE | LOG_CONTEXT_CONSOLE);

#pragma unused(ddLogLevel, msLogContext)

@implementation ControlStateImageSet

/**
 * For some reason using `setValuesForKeysWithDictionary:`, as is done in the `ControlStateSet`
 * implementation of this method, calls `encodeWithCoder:` leading to a crash
 * NOTE: not sure if this is still true
 */
+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)moc
                             withObjects:(NSDictionary *)objects {
  assert(NO);
  assert(moc);
  __block ControlStateImageSet * imageSet = nil;

  [moc performBlockAndWait:
   ^{
    imageSet = [self controlStateSetInContext:moc];
    [objects enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL * stop)
    {
      imageSet[[ControlStateSet stateForProperty:key]] = obj;
    }];
  }];

  return imageSet;
}

+ (ControlStateImageSet *)imageSetWithImages:(NSDictionary *)images
                                     context:(NSManagedObjectContext *)moc {
  return [self imageSetWithColors:nil images:images context:moc];
}

+ (ControlStateImageSet *)imageSetWithColors:(NSDictionary *)colors
                                      images:(NSDictionary *)images
                                     context:(NSManagedObjectContext *)moc {

  if (!images) ThrowInvalidNilArgument(images);
  assert(NO);

  __block ControlStateImageSet * imageSet       = nil;

  //TODO: Update since themes currently use this method

  return imageSet;
}

- (UIImage *)UIImageForState:(NSUInteger)state { return self[state].colorImage; }

- (ImageView *)objectAtIndexedSubscript:(NSUInteger)state {
  id value = [super objectAtIndexedSubscript:state];
  if ([value isKindOfClass:[ImageView class]]) return value;
  else return [self.managedObjectContext objectForURI:value];
}

- (ImageView *)objectForKeyedSubscript:(NSString *)key {
  id value = [super objectForKeyedSubscript:key];
  if ([value isKindOfClass:[ImageView class]]) return value;
  else return [self.managedObjectContext objectForURI:value];
}

- (void)setObject:(ImageView *)imageView atIndexedSubscript:(NSUInteger)state {
  assert(imageView);
  [super setObject:imageView.permanentURI atIndexedSubscript:state];
}

- (MSDictionary *)deepDescriptionDictionary {
/*
  ControlStateImageSet * stateSet = [self faultedObject];

  assert(stateSet);

  NSString *(^nameForValueForKey)(NSString *) = ^NSString *(NSString * key)
  {
    id      value = [stateSet valueForKey:key];
    Image * image = nil;

    if ([value isKindOfClass:[NSURL class]]) {
      image = (Image *)[stateSet.managedObjectContext objectForURI:(NSURL *)value];
    } else if ([value isKindOfClass:[Image class]])
      image = (Image *)value;

    return (image ? image.name : @"nil");
  };
*/

  MSDictionary * dd = [[super deepDescriptionDictionary] mutableCopy];

/*
  dd[@"normal"]                         = nameForValueForKey(@"normal");
  dd[@"selected"]                       = nameForValueForKey(@"selected");
  dd[@"highlighted"]                    = nameForValueForKey(@"highlighted");
  dd[@"disabled"]                       = nameForValueForKey(@"disabled");
  dd[@"highlightedAndSelected"]         = nameForValueForKey(@"highlightedAndSelected");
  dd[@"highlightedAndDisabled"]         = nameForValueForKey(@"highlightedAndDisabled");
  dd[@"disabledAndSelected"]            = nameForValueForKey(@"disabledAndSelected");
  dd[@"selectedHighlightedAndDisabled"] = nameForValueForKey(@"selectedHighlightedAndDisabled");
*/

  return (MSDictionary *)dd;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Import/Export
////////////////////////////////////////////////////////////////////////////////


- (void)updateWithData:(NSDictionary *)data {

  NSManagedObjectContext * moc = self.managedObjectContext;

  [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
    if ([ControlStateSet validState:key])   {
      if (isDictionaryKind(obj)) {
        NSDictionary * imageData = obj[@"image"];

        if (isDictionaryKind(imageData)) {
          Image * image = [Image importObjectFromData:imageData inContext:moc];
          UIColor * color = colorFromImportValue(obj[@"color"]);

          if (image) {
            ImageView *imageView = [ImageView imageViewWithImage:image color:color];

            if (imageView)
              self[key] = imageView.permanentURI;
          }
        }
      }
    }
  }];
}

- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];

  // remove entries for state dictionaries
  for (NSString * key in [dictionary copy])
    if ([ControlStateSet validState:[key keyPathComponents][0]])
      [dictionary removeObjectForKey:key];



  dictionary.userInfo[MSJSONCommentKey] = [MSDictionary dictionary];

  NSArray * keys = [[self dictionaryFromSetObjects] allKeys];

  for (NSString * key in keys) {
    if ([ControlStateSet validState:key]) {
      ImageView * imageView = self[key];
      MSDictionary * imageViewJSON = [MSDictionary dictionaryWithObject:imageView.image.commentedUUID
                                                                 forKey:@"image"];
      UIColor * color = imageView.color;
      if (color) imageViewJSON[@"color"] = CollectionSafe(normalizedColorJSONValueForColor(color));
      
      dictionary[key] = imageViewJSON;
    }
  }

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

@end
