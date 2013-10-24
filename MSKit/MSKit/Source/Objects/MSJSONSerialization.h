//
//  MSJSONSerialization.h
//  MSKit
//
//  Created by Jason Cardwell on 10/20/13.
//  Copyright (c) 2013 Jason Cardwell. All rights reserved.
//

#import "MSKitProtocols.h"

typedef NS_OPTIONS(NSUInteger, MSJSONFormatOptions)
{
    /// default is to strip all whitespace and comments, and convert "keypath" keys
    MSJSONFormatDefault        					 = 0b00000000000000000000000000000000,

    /// don't remove or add any line breaks
    MSJSONFormatPreserveWhitespace			     = 0b00000000000000000000000000000001,

    /// keep "keypath" keys
    MSJSONFormatKeepKeyPaths    				 = 0b00000000000000000000000000000010,

    /// create "keypath" keys for single entry objects
    MSJSONFormatCreateKeyPaths    				 = 0b00000000000000000000000000000100,

    /// don't remove comments
    MSJSONFormatKeepComments    				 = 0b00000000000000000000000000001000,

    /// indent by nested depth
    MSJSONFormatIndentByDepth   				 = 0b00000000000000000000000000010000,

    /// keep one line arrays/objects
    MSJSONFormatKeepOneLiners   				 = 0b00000000000000000000000000100000,

    /// create one line arrays/objects for single entry/element
    MSJSONFormatForceOneLiners  				 = 0b00000000000000000000000001100000,

    /// options affecting line breaks around array brackets
    MSJSONFormatLineBreakAfterOpenBracket        = 0b00000000000000000000000010000000,
    MSJSONFormatLineBreakBeforeCloseBracket      = 0b00000000000000000000000100000000,
    MSJSONFormatLineBreaksInsideBrackets         = 0b00000000000000000000000110000000,

    /// options affecting line breaks around object braces
    MSJSONFormatLineBreakAfterOpenBrace          = 0b00000000000000000000001000000000,
    MSJSONFormatLineBreakBeforeCloseBrace        = 0b00000000000000000000010000000000,
    MSJSONFormatLineBreaksInsideBraces           = 0b00000000000000000000011000000000,

    /// between elements/key-value pairs
    MSJSONFormatLineBreakAfterComma              = 0b00000000000000000000100000000000,
    MSJSONFormatLineBreakBetweenColonAndArray    = 0b00000000000000000001000000000000,
    MSJSONFormatLineBreakBetweenColonAndObject   = 0b00000000000000000010000000000000
    
};

@interface MSJSONSerialization : NSObject

/// Returns whether value inherits from NSString, NSNumber, NSDictionary, NSArray, or NSNull
+ (BOOL)isValidJSONValue:(id)value;

+ (NSString *)JSONFromObject:(id)object;

/// Writes a valid json object to the specified file
+ (BOOL)writeJSONObject:(id<MSJSONExport>)object filePath:(NSString *)filePath;


+ (NSString *)parseString:(NSString *)string error:(NSError *__autoreleasing *)error;
+ (NSString *)parseFile:(NSString *)filePath error:(NSError *__autoreleasing *)error;

+ (NSString *)parseString:(NSString *)string
                  options:(MSJSONFormatOptions)options
                    error:(NSError *__autoreleasing *)error;
+ (NSString *)parseFile:(NSString *)filePath
                options:(MSJSONFormatOptions)options
                  error:(NSError *__autoreleasing *)error;

+ (id)objectByParsingString:(NSString *)string error:(NSError *__autoreleasing *)error;
+ (id)objectByParsingFile:(NSString *)filePath error:(NSError *__autoreleasing *)error;
+ (id)objectByParsingString:(NSString *)string
                    options:(MSJSONFormatOptions)options
                      error:(NSError *__autoreleasing *)error;
+ (id)objectByParsingFile:(NSString *)filePath
                  options:(MSJSONFormatOptions)options
                    error:(NSError *__autoreleasing *)error;

@end

MSEXTERN_KEY(MSJSONComment);
MSEXTERN_KEY(MSJSONLeadingComment);
MSEXTERN_KEY(MSJSONTrailingComment);

#import "MSDictionary.h"

MSSTATIC_INLINE NSString * NSStringFromMSJSONFormatOptions(MSJSONFormatOptions o)
{
    MSDictionary * d = [MSDictionary dictionary];

    d[@"preserveWhitespace"]             = BOOLString((o & MSJSONFormatPreserveWhitespace));
    d[@"keepKeyPaths"]                   = BOOLString((o & MSJSONFormatKeepKeyPaths));
    d[@"createKeyPaths"]                 = BOOLString((o & MSJSONFormatCreateKeyPaths));
    d[@"keepComments"]                   = BOOLString((o & MSJSONFormatKeepComments));
    d[@"indentByDepth"]                  = BOOLString((o & MSJSONFormatIndentByDepth));
    d[@"keepOneLiners"]                  = BOOLString((o & MSJSONFormatKeepOneLiners));
    d[@"forceOneLiners"]                 = BOOLString((o & MSJSONFormatForceOneLiners));
    d[@"lineBreakAfterOpenBracket"]      = BOOLString((o & MSJSONFormatLineBreakAfterOpenBracket));
    d[@"lineBreakBeforeCloseBracket"]    = BOOLString((o & MSJSONFormatLineBreakBeforeCloseBracket));
    d[@"lineBreakAfterOpenBrace"]        = BOOLString((o & MSJSONFormatLineBreakAfterOpenBrace));
    d[@"lineBreakBeforeCloseBrace"]      = BOOLString((o & MSJSONFormatLineBreakBeforeCloseBrace));
    d[@"lineBreakAfterComma"]            = BOOLString((o & MSJSONFormatLineBreakAfterComma));
    d[@"lineBreakBetweenColonAndArray"]  = BOOLString((o & MSJSONFormatLineBreakBetweenColonAndArray));
    d[@"lineBreakBetweenColonAndObject"] = BOOLString((o & MSJSONFormatLineBreakBetweenColonAndObject));


    return [d formattedDescriptionWithOptions:0 levelIndent:0];
}
