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

@interface ControlStateImageSet ()
@property (nonatomic) ImageView * normal;
@property (nonatomic) ImageView * disabled;
@property (nonatomic) ImageView * selected;
@property (nonatomic) ImageView * highlighted;
@property (nonatomic) ImageView * highlightedDisabled;
@property (nonatomic) ImageView * highlightedSelected;
@property (nonatomic) ImageView * selectedHighlightedDisabled;
@property (nonatomic) ImageView * disabledSelected;
@end

@implementation ControlStateImageSet

@dynamic normal;
@dynamic disabled, selected, disabledSelected;
@dynamic highlighted, highlightedDisabled, highlightedSelected;
@dynamic selectedHighlightedDisabled;

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

  ControlStateImageSet * imageSet = [self createInContext:moc];
  [images enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    if ([self validState:key] && isKind(obj, Image)) {
      UIColor * color = nil;
      id rawColor = colors[key];
      if (rawColor) {
        if ([rawColor isKindOfClass:[UIColor class]]) color = rawColor;
        else if (isStringKind(rawColor)) color = colorFromImportValue(rawColor);
      }
      ImageView * imageView = [ImageView imageViewWithImage:obj color:color];
      if (imageView) imageSet[key] = imageView;
    }

  }];

  return imageSet;
}

- (ImageView *)objectAtIndex:(NSUInteger)state {
  id value = [super objectAtIndex:state];
  if ([value isKindOfClass:[ImageView class]]) return value;
  else return [self.managedObjectContext objectForURI:value];
}

- (ImageView *)objectForKey:(NSString *)key {
  id value = [super objectForKey:key];
  if ([value isKindOfClass:[ImageView class]]) return value;
  else return [self.managedObjectContext objectForURI:value];
}

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
  dd[@"highlightedSelected"]         = nameForValueForKey(@"highlightedSelected");
  dd[@"highlightedDisabled"]         = nameForValueForKey(@"highlightedDisabled");
  dd[@"disabledSelected"]            = nameForValueForKey(@"disabledSelected");
  dd[@"selectedHighlightedDisabled"] = nameForValueForKey(@"selectedHighlightedDisabled");
*/

  return (MSDictionary *)dd;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Import/Export
////////////////////////////////////////////////////////////////////////////////


- (void)updateWithData:(NSDictionary *)data {

  NSManagedObjectContext * moc = self.managedObjectContext;

  [data enumerateKeysAndObjectsUsingBlock:^(id JSONkey, id obj, BOOL * stop) {

    NSString * key = [JSONkey dashCaseToCamelCase];
    
    if ([ControlStateSet validState:key])   {
      if (isDictionaryKind(obj)) {
        NSDictionary * imageData = obj[@"image"];

        if (isDictionaryKind(imageData)) {
          Image * image = [Image importObjectFromData:imageData context:moc];
          UIColor * color = colorFromImportValue(obj[@"color"]);

          if (image) {
            ImageView *imageView = [ImageView imageViewWithImage:image color:color];

            if (imageView)
              self[key] = imageView;
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

  NSArray * keys = [[self dictionaryFromSetObjects:YES] allKeys];

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
