//
//  TitleAttributes.h
//  Remote
//
//  Created by Jason Cardwell on 8/25/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
@import CocoaLumberjack;
@import MoonKit;
#import "MSRemoteMacros.h"

@import Foundation;
#import <CoreData/CoreData.h>

#import "ModelObject.h"

@class ControlStateTitleSet, REFont;

@interface TitleAttributes : ModelObject

@property (nonatomic, strong) REFont   * font;
@property (nonatomic, strong) UIColor  * foregroundColor;
@property (nonatomic, strong) UIColor  * backgroundColor;
@property (nonatomic, strong) NSNumber * ligature;
@property (nonatomic, strong) NSString * iconName;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSShadow * shadow;
@property (nonatomic, strong) NSNumber * expansion;
@property (nonatomic, strong) NSNumber * obliqueness;
@property (nonatomic, strong) UIColor  * strikethroughColor;
@property (nonatomic, strong) UIColor  * underlineColor;
@property (nonatomic, strong) NSNumber * baselineOffset;
@property (nonatomic, strong) NSString * textEffect;
@property (nonatomic, strong) NSNumber * strokeWidth;
@property (nonatomic, strong) UIColor  * strokeColor;
@property (nonatomic, strong) NSNumber * underlineStyle;
@property (nonatomic, strong) NSNumber * strikethroughStyle;
@property (nonatomic, strong) NSNumber * kern;
@property (nonatomic, strong) NSNumber * hyphenationFactor;
@property (nonatomic, strong) NSNumber * paragraphSpacingBefore;
@property (nonatomic, strong) NSNumber * lineHeightMultiple;
@property (nonatomic, strong) NSNumber * maximumLineHeight;
@property (nonatomic, strong) NSNumber * minimumLineHeight;
@property (nonatomic, strong) NSNumber * lineBreakMode;
@property (nonatomic, strong) NSNumber * tailIndent;
@property (nonatomic, strong) NSNumber * headIndent;
@property (nonatomic, strong) NSNumber * firstLineHeadIndent;
@property (nonatomic, strong) NSNumber * alignment;
@property (nonatomic, strong) NSNumber * paragraphSpacing;
@property (nonatomic, strong) NSNumber * lineSpacing;

@property (nonatomic, readonly) NSAttributedString * string;
@property (nonatomic, readonly) MSDictionary       * attributes;

+ (NSArray *)propertyKeys;
+ (Class)validClassForProperty:(NSString *)property;
+ (NSString *)attributeNameForProperty:(NSString *)property;

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;
- (id)objectForKeyedSubscript:(NSString *)key;

@end
