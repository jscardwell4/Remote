//
// ControlStateColorSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ControlStateColorSet.h"
#import "RemoteElementExportSupportFunctions.h"
#import "RemoteElementImportSupportFunctions.h"

@interface ControlStateColorSet ()
@property (nonatomic) UIColor * normal;
@property (nonatomic) UIColor * disabled;
@property (nonatomic) UIColor * selected;
@property (nonatomic) UIColor * highlighted;
@property (nonatomic) UIColor * highlightedDisabled;
@property (nonatomic) UIColor * highlightedSelected;
@property (nonatomic) UIColor * highlightedSelectedDisabled;
@property (nonatomic) UIColor * selectedDisabled;
@end

@implementation ControlStateColorSet

@dynamic normal;
@dynamic disabled, selected, selectedDisabled;
@dynamic highlighted, highlightedDisabled, highlightedSelected;
@dynamic highlightedSelectedDisabled;

- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];


  [(NSDictionary *)data enumerateKeysAndObjectsUsingBlock :^(id key, id obj, BOOL * stop) {
    NSString * property = [key dashCaseToCamelCase];
    if ([ControlStateSet validState:property]) {
      UIColor * color = colorFromImportValue(obj);
      if (color) self[property] = color;
    }
  }];
}

- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];


  for (NSString * key in [ControlStateSet validProperties])
    dictionary[[key camelCaseToDashCase]] =
      CollectionSafe(normalizedColorJSONValueForColor([self valueForKey:key]));

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

- (NSString *)debugDescription {
  return $(@"normal:%@\n"
           "selected:%@\n"
           "highlighted:%@\n"
           "disabled:%@\n"
           "highlightedSelected:%@\n"
           "highlightedDisabled:%@\n"
           "selectedDisabled:%@\n"
           "highlightedSelectedDisabled:%@",
           ((UIColor *)self[0]).string,
           ((UIColor *)self[4]).string,
           ((UIColor *)self[1]).string,
           ((UIColor *)self[2]).string,
           ((UIColor *)self[5]).string,
           ((UIColor *)self[3]).string,
           ((UIColor *)self[6]).string,
           ((UIColor *)self[7]).string);
}

@end
