//
//  NSAttributedString+MSKitAdditions.h
//  MSKit
//
//  Created by Jason Cardwell on 3/24/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (MSKitAdditions)

+ (NSAttributedString *)attributedStringWithString:(NSString *)string
                                        attributes:(NSDictionary *)attributes;

+ (NSAttributedString *)attributedStringWithString:(NSString *)string;

- (NSAttributedString *)attributedStringWithAttribute:(NSString *)attribute value:(id)value;
- (NSAttributedString *)attributedStringWithAttributes:(NSDictionary *)attributes;

- (NSAttributedString *)attributedStringWithForegroundColor:(UIColor *)color;
- (NSAttributedString *)attributedStringWithBackgroundColor:(UIColor *)color;
- (NSAttributedString *)attributedStringWithFont:(UIFont *)font;
- (NSAttributedString *)attributedStringWithParagraphStyle:(NSParagraphStyle *)paragraphStyle;
- (NSAttributedString *)attributedStringWithLigature:(NSNumber *)ligature;
- (NSAttributedString *)attributedStringWithKern:(NSNumber *)kern;
- (NSAttributedString *)attributedStringWithStrikethroughStyle:(NSNumber *)strikethroughStyle;
- (NSAttributedString *)attributedStringWithUnderlineStyle:(NSNumber *)underlineStyle;
- (NSAttributedString *)attributedStringWithStrokeColor:(UIColor *)color;
- (NSAttributedString *)attributedStringWithStrokeWidth:(NSNumber *)strokeWidth;
- (NSAttributedString *)attributedStringWithShadow:(NSShadow *)shadow;

@end

@interface NSMutableAttributedString (MSKitAdditions)

- (void)applyAttribute:(NSString *)attribute value:(id)value;
- (void)applyAttributes:(NSDictionary *)attributes;

- (void)applyFont:(UIFont *)font;
- (void)applyParagraphStyle:(NSParagraphStyle *)paragraphStyle;
- (void)applyForegroundColor:(UIColor *)color;
- (void)applyBackgroundColor:(UIColor *)color;
- (void)applyLigature:(NSNumber *)ligature;
- (void)applyKern:(NSNumber *)kern;
- (void)applyStrikethroughStyle:(NSNumber *)strikethroughStyle;
- (void)applyUnderlineStyle:(NSNumber *)underlineStyle;
- (void)applyStrokeColor:(UIColor *)color;
- (void)applyStrokeWidth:(NSNumber *)strokeWidth;
- (void)applyShadow:(NSShadow *)shadow;

@end
