//
//  TitleAttributes.m
//  Remote
//
//  Created by Jason Cardwell on 8/25/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

#import "TitleAttributes.h"
#import "ControlStateTitleSet.h"
#import "RemoteElementImportSupportFunctions.h"
#import "RemoteElementExportSupportFunctions.h"
#import "REFont.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@interface TitleAttributes (CoreDataGenerated)

@property (nonatomic) NSString * primitiveIconName;
@property (nonatomic) NSString * primitiveText;

@end

@implementation TitleAttributes

@dynamic iconName, text;
@dynamic font, ligature, kern, expansion, obliqueness, hyphenationFactor, baselineOffset;
@dynamic foregroundColor, backgroundColor, strikethroughColor, underlineColor, strokeColor;
@dynamic strokeWidth, underlineStyle, strikethroughStyle, shadow, textEffect;

@dynamic paragraphSpacingBefore, paragraphSpacing, lineSpacing;
@dynamic lineHeightMultiple, maximumLineHeight, minimumLineHeight;
@dynamic lineBreakMode, alignment;
@dynamic tailIndent, headIndent, firstLineHeadIndent;

/// This method provides the proper class for the value of the specified `TitleAttribute` property
/// @param property description
/// @return Class
+ (Class)validClassForProperty:(NSString *)property {
  static dispatch_once_t    onceToken;
  static NSMapTable const * index;

  dispatch_once(&onceToken, ^{

    Class number    = [NSNumber class];
    Class string    = [NSString class];
    Class color     = [UIColor  class];
    Class shadow    = [NSShadow class];
    Class font      = [REFont   class];

    index = [NSMapTable weakToWeakObjectsMapTableFromDictionary:@{ @"font"                    : font,
                                                                   @"foregroundColor"         : color,
                                                                   @"backgroundColor"         : color,
                                                                   @"ligature"                : number,
                                                                   @"iconName"                : string,
                                                                   @"text"                    : string,
                                                                   @"shadow"                  : shadow,
                                                                   @"expansion"               : number,
                                                                   @"obliqueness"             : number,
                                                                   @"strikethroughColor"      : color,
                                                                   @"underlineColor"          : color,
                                                                   @"baselineOffset"          : number,
                                                                   @"textEffect"              : string,
                                                                   @"strokeWidth"             : number,
                                                                   @"strokeColor"             : color,
                                                                   @"underlineStyle"          : number,
                                                                   @"strikethroughStyle"      : number,
                                                                   @"kern"                    : number,
                                                                   @"hyphenationFactor"       : number,
                                                                   @"paragraphSpacingBefore"  : number,
                                                                   @"lineHeightMultiple"      : number,
                                                                   @"maximumLineHeight"       : number,
                                                                   @"minimumLineHeight"       : number,
                                                                   @"lineBreakMode"           : number,
                                                                   @"tailIndent"              : number,
                                                                   @"headIndent"              : number,
                                                                   @"firstLineHeadIndent"     : number,
                                                                   @"alignment"               : number,
                                                                   @"paragraphSpacing"        : number,
                                                                   @"lineSpacing"             : number }];

  });

  return property ? index[property] : nil;
}

/// This method provides the proper class for the value of the specified `TitleAttribute` property
/// @param property description
/// @return NSString *
+ (NSString *)attributeNameForProperty:(NSString *)property {
  static dispatch_once_t    onceToken;
  static NSMapTable const * index;

  dispatch_once(&onceToken, ^{

    index = [NSMapTable weakToWeakObjectsMapTableFromDictionary:
             @{ @"font"                    : NSFontAttributeName,
                @"foregroundColor"         : NSForegroundColorAttributeName,
                @"backgroundColor"         : NSBackgroundColorAttributeName,
                @"ligature"                : NSLigatureAttributeName,
                @"shadow"                  : NSShadowAttributeName,
                @"expansion"               : NSExpansionAttributeName,
                @"obliqueness"             : NSObliquenessAttributeName,
                @"strikethroughColor"      : NSStrikethroughColorAttributeName,
                @"underlineColor"          : NSUnderlineColorAttributeName,
                @"baselineOffset"          : NSBaselineOffsetAttributeName,
                @"textEffect"              : NSTextEffectAttributeName,
                @"strokeWidth"             : NSStrokeWidthAttributeName,
                @"strokeColor"             : NSStrokeColorAttributeName,
                @"underlineStyle"          : NSUnderlineStyleAttributeName,
                @"strikethroughStyle"      : NSStrikethroughStyleAttributeName,
                @"kern"                    : NSKernAttributeName }];

  });

  return property ? index[property] : nil;
}

+ (NSArray *)propertyKeys {
	static dispatch_once_t onceToken;
	static NSArray * keys;
	dispatch_once(&onceToken, ^{

		keys = @[@"font",
						 @"foregroundColor",
						 @"backgroundColor",
						 @"ligature",
						 @"iconName",
						 @"text",
						 @"shadow",
						 @"expansion",
						 @"obliqueness",
						 @"strikethroughColor",
						 @"underlineColor",
						 @"baselineOffset",
						 @"textEffect",
						 @"strokeWidth",
						 @"strokeColor",
						 @"underlineStyle",
						 @"strikethroughStyle",
						 @"kern",
						 @"hyphenationFactor",
						 @"paragraphSpacingBefore",
						 @"lineHeightMultiple",
						 @"maximumLineHeight",
						 @"minimumLineHeight",
						 @"lineBreakMode",
						 @"tailIndent",
						 @"headIndent",
						 @"firstLineHeadIndent",
						 @"alignment",
						 @"paragraphSpacing",
						 @"lineSpacing"];

	});

	return keys;
}

+ (NSArray *)paragraphKeys {
	static dispatch_once_t onceToken;
	static NSArray * keys;
	dispatch_once(&onceToken, ^{

		keys = @[@"hyphenationFactor",
						 @"paragraphSpacingBefore",
						 @"lineHeightMultiple",
						 @"maximumLineHeight",
						 @"minimumLineHeight",
						 @"lineBreakMode",
						 @"tailIndent",
						 @"headIndent",
						 @"firstLineHeadIndent",
						 @"alignment",
						 @"paragraphSpacing",
						 @"lineSpacing"];

	});

	return keys;

}

- (NSAttributedString *)string {

  NSAttributedString * string = nil;

  if (self.text || self.iconName) {
    NSString * stringText = self.text;
    NSMutableDictionary * attributes = [@{} mutableCopy];
    NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    for (NSString * attribute in [TitleAttributes propertyKeys]) {
      if ([[TitleAttributes paragraphKeys] containsObject:attribute])
        [paragraphStyle setValue:self[attribute] forKey:attribute];
      else if ([@"font" isEqualToString:attribute] && self.font)
        attributes[NSFontAttributeName] = self.font.UIFontValue;
      else if ([@"iconName" isEqualToString:attribute] && self.iconName)
        stringText = [UIFont fontAwesomeIconForName:self.iconName];
      else
        attributes[[TitleAttributes attributeNameForProperty:attribute]] = self[attribute];
    }
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    string = [NSAttributedString attributedStringWithString:stringText attributes:attributes];
  }

  return string;

}

NS_ENUM(int, Property) {
	FONT,
	FOREGROUNDCOLOR,
	BACKGROUNDCOLOR,
	LIGATURE,
	ICONNAME,
	TEXT,
	SHADOW,
	EXPANSION,
	OBLIQUENESS,
	STRIKETHROUGHCOLOR,
	UNDERLINECOLOR,
	BASELINEOFFSET,
	TEXTEFFECT,
	STROKEWIDTH,
	STROKECOLOR,
	UNDERLINESTYLE,
	STRIKETHROUGHSTYLE,
	KERN,
	HYPHENATIONFACTOR,
	PARAGRAPHSPACINGBEFORE,
	LINEHEIGHTMULTIPLE,
	MAXIMUMLINEHEIGHT,
	MINIMUMLINEHEIGHT,
	LINEBREAKMODE,
	TAILINDENT,
	HEADINDENT,
	FIRSTLINEHEADINDENT,
	ALIGNMENT,
	PARAGRAPHSPACING,
	LINESPACING
};

- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

  [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

    NSString * property = [key dashCaseToCamelCase];
    if (property && [[TitleAttributes propertyKeys] containsObject:property]) {

      switch ([[TitleAttributes propertyKeys] indexOfObject:property]) {

        case FOREGROUNDCOLOR:
        case BACKGROUNDCOLOR:
        case STRIKETHROUGHCOLOR:
        case UNDERLINECOLOR:
        case STROKECOLOR: {
          if (isStringKind(obj)) {
            self[property] = colorFromImportValue(obj);
          }
        } break;

        case FONT:{
          if (isStringKind(obj)) {
            self.font = [REFont fontFromString:obj];
          }
        } break;

        case LIGATURE: {
          if(isNumberKind(obj) && ([obj isEqualToNumber:@0] || [obj isEqualToNumber:@1])) {
            self.ligature = obj;
          }
        } break;

        case ICONNAME: {
          if (isStringKind(obj) && [[UIFont fontAwesomeIconNames] containsObject:obj])
            self.iconName = obj;
        } break;

        case TEXT: {
          if (isStringKind(obj)) self.text = obj;
        } break;

        case SHADOW: {
          MSLogWarnTag(@"shadow not yet supported");
        } break;

        case TEXTEFFECT: {
          self.textEffect = ([@"letterpress" isEqualToString:obj] ? NSTextEffectLetterpressStyle : nil);
        } break;


        case STRIKETHROUGHSTYLE:
        case UNDERLINESTYLE: {
          if (isStringKind(obj))
            self[property] = @(underlineStrikethroughStyleForJSONKey(obj));
          else if (isNumberKind(obj))
            self[property] = obj;
        } break;

        case STROKEWIDTH:
        case EXPANSION:
        case OBLIQUENESS:
        case BASELINEOFFSET:
        case KERN:
        case HYPHENATIONFACTOR:
        case PARAGRAPHSPACINGBEFORE:
        case LINEHEIGHTMULTIPLE:
        case MAXIMUMLINEHEIGHT:
        case MINIMUMLINEHEIGHT:
        case PARAGRAPHSPACING:
        case LINESPACING:
        case TAILINDENT:
        case HEADINDENT:
        case FIRSTLINEHEADINDENT: {
          if (isNumberKind(obj)) self[property] = obj;
        } break;

        case LINEBREAKMODE: {
          if (isStringKind(obj))
            self.lineBreakMode = @(lineBreakModeForJSONKey(obj));
          else if (isNumberKind(obj))
            self.lineBreakMode = obj;
        } break;

        case ALIGNMENT: {
          if (isStringKind(obj))
            self.alignment = @(underlineStrikethroughStyleForJSONKey(obj));
          else if (isNumberKind(obj))
            self.alignment = obj;
        } break;

      }
    }
  }];

}

- (id)objectForKeyedSubscript:(NSString *)key {
  return ([[TitleAttributes propertyKeys] containsObject:key] ? [self valueForKey:key] : nil);
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
  if (   [[TitleAttributes propertyKeys] containsObject:key]
      && (!obj || [obj isKindOfClass:[TitleAttributes validClassForProperty:key]]))
    [self setValue:obj forKeyPath:key];
}

- (void)setIconName:(NSString *)iconName {
  [self willChangeValueForKey:@"iconName"];
  if (!iconName || (iconName && [[UIFont fontAwesomeIconNames] containsObject:iconName])) {
    self.primitiveIconName = iconName;
    if (iconName && self.text) self.primitiveText = nil;
  }
  [self didChangeValueForKey:@"iconName"];
}

- (void)setText:(NSString *)text {
  [self willChangeValueForKey:@"text"];
  self.primitiveText = text;
  if (text && self.iconName) self.primitiveIconName = nil;
  [self didChangeValueForKey:@"text"];
}

- (MSDictionary *)JSONDictionary {

  MSDictionary * dictionary = [super JSONDictionary];

  for (NSString * property in [TitleAttributes propertyKeys]) {
    switch ([[TitleAttributes propertyKeys] indexOfObject:property]) {

			case FOREGROUNDCOLOR:
			case BACKGROUNDCOLOR:
			case STRIKETHROUGHCOLOR:
			case UNDERLINECOLOR:
			case STROKECOLOR: {
        dictionary[[property camelCaseToDashCase]] =
          CollectionSafe(normalizedColorJSONValueForColor(self[property]));
      } break;

			case FONT:{
        dictionary[@"font"] = CollectionSafe(self.font.stringValue);
      } break;

			case TEXTEFFECT: {
        if ([self.textEffect isEqualToString:NSTextEffectLetterpressStyle])
          dictionary[@"text-effect"] = @"letterpress";
      } break;


      case STRIKETHROUGHSTYLE:
			case UNDERLINESTYLE: {
        dictionary[[property camelCaseToDashCase]] =
          CollectionSafe(underlineStrikethroughStyleJSONValueForStyle(self[property]));
      } break;

			case ICONNAME:
			case TEXT:
			case LIGATURE:
			case STROKEWIDTH:
      case EXPANSION:
			case OBLIQUENESS:
			case BASELINEOFFSET:
			case KERN:
			case HYPHENATIONFACTOR:
			case PARAGRAPHSPACINGBEFORE:
			case LINEHEIGHTMULTIPLE:
			case MAXIMUMLINEHEIGHT:
			case MINIMUMLINEHEIGHT:
      case PARAGRAPHSPACING:
			case LINESPACING:
			case TAILINDENT:
			case HEADINDENT:
			case FIRSTLINEHEADINDENT: {
				dictionary[[property camelCaseToDashCase]] = CollectionSafe(self[property]);
			} break;

			case LINEBREAKMODE: {
        dictionary[@"line-break-mode"] =
          CollectionSafe(lineBreakModeJSONValueForMode(UnsignedIntegerValue(self.lineBreakMode)));
      } break;

			case ALIGNMENT: {
        dictionary[@"alignment"] = CollectionSafe(textAlignmentJSONValueForAlignment(IntegerValue(self.alignment)));
      } break;

    }
  }

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

@end
