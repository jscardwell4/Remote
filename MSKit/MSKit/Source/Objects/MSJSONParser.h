//
//  MSJSONParser.h
//  MSKit
//
//  Created by Jason Cardwell on 5/2/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import <ParseKit/ParseKit.h>
#import "MSJSONSerialization.h"

enum {
    MSJSONPARSER_TOKEN_KIND_FALSELITERAL = 14,
    MSJSONPARSER_TOKEN_KIND_CLOSECURLY,
    MSJSONPARSER_TOKEN_KIND_OPENBRACKET,
    MSJSONPARSER_TOKEN_KIND_NULLLITERAL,
    MSJSONPARSER_TOKEN_KIND_COMMA,
    MSJSONPARSER_TOKEN_KIND_TRUELITERAL,
    MSJSONPARSER_TOKEN_KIND_CLOSEBRACKET,
    MSJSONPARSER_TOKEN_KIND_OPENCURLY,
    MSJSONPARSER_TOKEN_KIND_COLON,
};

@interface MSJSONParser:PKSParser

+ (MSJSONParser *)parserWithOptions:(MSJSONFormatOptions)options;

@property (nonatomic, assign) MSJSONFormatOptions options;

@end
