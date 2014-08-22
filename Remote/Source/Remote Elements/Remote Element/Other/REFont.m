//
//  REFont.m
//  Remote
//
//  Created by Jason Cardwell on 10/30/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REFont.h"

@implementation REFont


////////////////////////////////////////////////////////////////////////////////
#pragma mark Creation
////////////////////////////////////////////////////////////////////////////////


+ (instancetype)fontWithName:(NSString *)name size:(NSNumber *)size
{
    REFont * font = [self new];
    font.fontName = name;
    font.pointSize = size;
    return font;
}

+ (instancetype)fontFromString:(NSString *)string
{
    NSArray * components = [string fontComponents];
    NSString * fontName  = (StringIsEmpty(components[0]) ? nil : components[0]);
    NSNumber * pointSize = (StringIsEmpty(components[1]) ? nil : @([(NSString *)components[1] floatValue]));
    return [self fontWithName:fontName size:pointSize];
}

+ (instancetype)fontFromFont:(UIFont *)font
{
    return (font ? [self fontWithName:font.fontName size:@(font.pointSize)] : nil);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark Derived properties
////////////////////////////////////////////////////////////////////////////////


- (NSString *)stringValue
{
    if (_fontName && _pointSize) return $(@"%@@%@", _fontName, StringValue(_pointSize));
    else if (_fontName) return _fontName;
    else if (_pointSize) return StringValue(_pointSize);
    else return nil;
}

//???: Should empty REFont object return nil or default system font for UIFontValue?
- (UIFont *)UIFontValue
{
    NSString * fontName  = (_fontName ?: @"Helvetica Neue");
    CGFloat    pointSize = (_pointSize ? FloatValue(_pointSize) : [UIFont systemFontSize]);
    return [UIFont fontWithName:fontName size:pointSize];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark NSCoding
////////////////////////////////////////////////////////////////////////////////


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init])
    {
        _fontName  = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"fontName"];
        _pointSize = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"pointSize"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_fontName forKey:@"fontName"];
    [aCoder encodeObject:_pointSize forKey:@"pointSize"];
}

@end

@implementation NSString (REFont)
- (NSArray *)fontComponents
{
    NSString * pattern = @"^([^@]*)@?([0-9]*\\.?[0-9]*)";
    NSArray * components = [self capturedStringsByMatchingFirstOccurrenceOfRegex:pattern];
    return components;
}
@end
