//
// ControlStateImageSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ControlStateImageSet.h"
#import "ControlStateColorSet.h"
#import "RemoteElementImportSupportFunctions.h"
#import "RemoteElementExportSupportFunctions.h"
#import "Remote-Swift.h"

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
  [super setObject:imageView.permanentURI atIndexedSubscript:state];
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

          //FIXME: Disabled
/*
          if (image) {
            ImageView *imageView = [ImageView imageViewWithImage:image color:color];

            if (imageView)
              self[key] = imageView;
          }

*/        }
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
