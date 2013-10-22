//
//  MSJSONParser.m
//  MSKit
//
//  Created by Jason Cardwell on 5/2/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "MSJSONParser.h"
#import <ParseKit/ParseKit.h>

static int ddLogLevel   = LOG_LEVEL_WARN;
static int   msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@interface PKSParser ()

@property (nonatomic, retain) NSMutableDictionary  *_tokenKindTab;
@property (nonatomic, retain) NSMutableArray       *_tokenKindNameTab;

- (BOOL)_popBool;
- (NSInteger)_popInteger;
- (double)_popDouble;
- (PKToken *)_popToken;
- (NSString *)_popString;

- (void)_pushBool:(BOOL)yn;
- (void)_pushInteger:(NSInteger)i;
- (void)_pushDouble:(double)d;

@end

/*
 @symbolState = '"';

 @start            = array | object;

 object            = openCurly (Empty | keyPath colon value (comma keyPath colon value)*) closeCurly;
 keyPath           = quote key (dot key)* quote;
 key               = Word;

 array             = openBracket (Empty | value (comma value)*) closeBracket;

 value             = (nullLiteral | trueLiteral | falseLiteral | number | string | array | object);

 string            = QuotedString;
 number            = Number;
 nullLiteral       = 'null';
 trueLiteral       = 'true';
 falseLiteral      = 'false';

 openCurly         = '{';
 closeCurly        = '}';
 openBracket       = '[';
 closeBracket      = ']';
 comma             = ',';
 colon             = ':';
 quote             = '"';
 dot               = '.';
 */

@interface MSJSONParser ()

@property (nonatomic, retain) NSMutableDictionary *object_memo;
@property (nonatomic, retain) NSMutableDictionary *keyPath_memo;
@property (nonatomic, retain) NSMutableDictionary *array_memo;
@property (nonatomic, retain) NSMutableDictionary *value_memo;
@property (nonatomic, retain) NSMutableDictionary *string_memo;
@property (nonatomic, retain) NSMutableDictionary *number_memo;
@property (nonatomic, retain) NSMutableDictionary *nullLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *trueLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *falseLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *openCurly_memo;
@property (nonatomic, retain) NSMutableDictionary *closeCurly_memo;
@property (nonatomic, retain) NSMutableDictionary *openBracket_memo;
@property (nonatomic, retain) NSMutableDictionary *closeBracket_memo;
@property (nonatomic, retain) NSMutableDictionary *comma_memo;
@property (nonatomic, retain) NSMutableDictionary *colon_memo;

@end

@implementation MSJSONParser

+ (MSJSONParser *)parserWithOptions:(MSJSONFormatOptions)options
{
    MSJSONParser * parser = [self new];
    parser.options = options;
    return parser;
}

- (id)init
{
    if (self = [super init])
    {
        self.enableAutomaticErrorRecovery = YES;

        self._tokenKindTab[@"false"] = @(MSJSONPARSER_TOKEN_KIND_FALSELITERAL);
        self._tokenKindTab[@"}"]     = @(MSJSONPARSER_TOKEN_KIND_CLOSECURLY);
        self._tokenKindTab[@"["]     = @(MSJSONPARSER_TOKEN_KIND_OPENBRACKET);
        self._tokenKindTab[@"null"]  = @(MSJSONPARSER_TOKEN_KIND_NULLLITERAL);
        self._tokenKindTab[@","]     = @(MSJSONPARSER_TOKEN_KIND_COMMA);
        self._tokenKindTab[@"true"]  = @(MSJSONPARSER_TOKEN_KIND_TRUELITERAL);
        self._tokenKindTab[@"]"]     = @(MSJSONPARSER_TOKEN_KIND_CLOSEBRACKET);
        self._tokenKindTab[@"{"]     = @(MSJSONPARSER_TOKEN_KIND_OPENCURLY);
        self._tokenKindTab[@":"]     = @(MSJSONPARSER_TOKEN_KIND_COLON);

        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_FALSELITERAL] = @"false";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_CLOSECURLY]   = @"}";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_OPENBRACKET]  = @"[";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_NULLLITERAL]  = @"null";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_COMMA]        = @",";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_TRUELITERAL]  = @"true";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_CLOSEBRACKET] = @"]";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_OPENCURLY]    = @"{";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_COLON]        = @":";

        self.object_memo       = [NSMutableDictionary dictionary];
        self.keyPath_memo      = [NSMutableDictionary dictionary];
        self.array_memo        = [NSMutableDictionary dictionary];
        self.value_memo        = [NSMutableDictionary dictionary];
        self.string_memo       = [NSMutableDictionary dictionary];
        self.number_memo       = [NSMutableDictionary dictionary];
        self.nullLiteral_memo  = [NSMutableDictionary dictionary];
        self.trueLiteral_memo  = [NSMutableDictionary dictionary];
        self.falseLiteral_memo = [NSMutableDictionary dictionary];
        self.openCurly_memo    = [NSMutableDictionary dictionary];
        self.closeCurly_memo   = [NSMutableDictionary dictionary];
        self.openBracket_memo  = [NSMutableDictionary dictionary];
        self.closeBracket_memo = [NSMutableDictionary dictionary];
        self.comma_memo        = [NSMutableDictionary dictionary];
        self.colon_memo        = [NSMutableDictionary dictionary];

    }

    return self;
}

- (void)_clearMemo
{
    [_object_memo removeAllObjects];
    [_keyPath_memo removeAllObjects];
    [_array_memo removeAllObjects];
    [_value_memo removeAllObjects];
    [_string_memo removeAllObjects];
    [_number_memo removeAllObjects];
    [_nullLiteral_memo removeAllObjects];
    [_trueLiteral_memo removeAllObjects];
    [_falseLiteral_memo removeAllObjects];
    [_openCurly_memo removeAllObjects];
    [_closeCurly_memo removeAllObjects];
    [_openBracket_memo removeAllObjects];
    [_closeBracket_memo removeAllObjects];
    [_comma_memo removeAllObjects];
    [_colon_memo removeAllObjects];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Start
////////////////////////////////////////////////////////////////////////////////

- (void)_start
{
    [self fireAssemblerSelector:@selector(parser:willStart:)];
    [self tryAndRecover:TOKEN_KIND_BUILTIN_EOF
                  block:^{
                              if ([self predicts:MSJSONPARSER_TOKEN_KIND_OPENBRACKET, 0])
                                  [self array];
                              else if ([self predicts:MSJSONPARSER_TOKEN_KIND_OPENCURLY, 0])
                                  [self object];
                              else [self raise:@"No viable alternative found in rule '_start'."];

                              [self matchEOF:YES];
                          }
             completion:^{ [self matchEOF:YES]; }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Object
////////////////////////////////////////////////////////////////////////////////

- (void)__object
{
    [self openCurly];
    [self tryAndRecover:MSJSONPARSER_TOKEN_KIND_CLOSECURLY
                  block:^{
                      if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0])
                      {
                          [self keyPath];

                          [self tryAndRecover:MSJSONPARSER_TOKEN_KIND_COLON
                                        block:^{ [self colon]; }
                                   completion:^{ [self colon]; }];

                          [self value];

                          while ([self predicts:MSJSONPARSER_TOKEN_KIND_COMMA, 0])
                          {
                              BOOL commaKeyValue =
                                  [self speculate:
                                   ^{
                                       [self comma];

                                       [self tryAndRecover:MSJSONPARSER_TOKEN_KIND_COLON
                                                     block:^{ [self keyPath]; [self colon]; }
                                                completion:^{ [self colon]; }];[self value];
                                   }];

                              if (commaKeyValue)
                              {
                                  [self comma];

                                  [self tryAndRecover:MSJSONPARSER_TOKEN_KIND_COLON
                                                block:^{ [self keyPath]; [self colon]; }
                                           completion:^{ [self colon]; }];

                                  [self value];
                              }

                              else break;
                          }
                      }

                      [self closeCurly];
                  }
             completion:^{ [self closeCurly]; }];

    [self fireAssemblerSelector:@selector(parser:didMatchObject:)];
}

- (void)object { [self parseRule:@selector(__object) withMemo:_object_memo]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark Object keys and keypaths
////////////////////////////////////////////////////////////////////////////////

- (void)__keyPath
{
    [self match:TOKEN_KIND_BUILTIN_QUOTEDSTRING discard:NO];
    [self fireAssemblerSelector:@selector(parser:didMatchKeyPath:)];
}
- (void)keyPath { [self parseRule:@selector(__keyPath) withMemo:_keyPath_memo]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark Arrays
////////////////////////////////////////////////////////////////////////////////

- (void)__array
{
    [self openBracket];
    [self tryAndRecover:MSJSONPARSER_TOKEN_KIND_CLOSEBRACKET
                  block:^{
                      if ([self predicts:MSJSONPARSER_TOKEN_KIND_FALSELITERAL,
                                         MSJSONPARSER_TOKEN_KIND_NULLLITERAL,
                                         MSJSONPARSER_TOKEN_KIND_OPENBRACKET,
                                         MSJSONPARSER_TOKEN_KIND_OPENCURLY,
                                         MSJSONPARSER_TOKEN_KIND_TRUELITERAL,
                                         TOKEN_KIND_BUILTIN_NUMBER,
                                         TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0])
                      {
                          [self value];

                          while ([self predicts:MSJSONPARSER_TOKEN_KIND_COMMA, 0])
                          {
                              if ([self speculate:^{ [self comma]; [self value]; }])
                              {
                                  [self comma];
                                  [self value];
                              }

                              else  break;
                          }
                      }

                      [self closeBracket];
                  }
             completion:^{ [self closeBracket]; }
     ];

    [self fireAssemblerSelector:@selector(parser:didMatchArray:)];
}
- (void)array { [self parseRule:@selector(__array) withMemo:_array_memo]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark Object and array value
////////////////////////////////////////////////////////////////////////////////

- (void)__value
{
    if      ([self predicts:MSJSONPARSER_TOKEN_KIND_NULLLITERAL, 0])  [self nullLiteral];
    else if ([self predicts:MSJSONPARSER_TOKEN_KIND_TRUELITERAL, 0])  [self trueLiteral];
    else if ([self predicts:MSJSONPARSER_TOKEN_KIND_FALSELITERAL, 0]) [self falseLiteral];
    else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0])            [self number];
    else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0])      [self string];
    else if ([self predicts:MSJSONPARSER_TOKEN_KIND_OPENBRACKET, 0])  [self array];
    else if ([self predicts:MSJSONPARSER_TOKEN_KIND_OPENCURLY, 0])    [self object];
    else
        [self raise:@"No viable alternative found in rule 'value'."];
}
- (void)value { [self parseRule:@selector(__value) withMemo:_value_memo]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark String, number, and boolean terminals
////////////////////////////////////////////////////////////////////////////////

- (void)__string
{
    [self matchQuotedString:NO];
    [self fireAssemblerSelector:@selector(parser:didMatchString:)];
}
- (void)string { [self parseRule:@selector(__string) withMemo:_string_memo]; }

- (void)__number
{
    [self matchNumber:NO];
    [self fireAssemblerSelector:@selector(parser:didMatchNumber:)];
}
- (void)number { [self parseRule:@selector(__number) withMemo:_number_memo]; }

- (void)__nullLiteral
{
    [self match:MSJSONPARSER_TOKEN_KIND_NULLLITERAL discard:NO];
    [self fireAssemblerSelector:@selector(parser:didMatchNullLiteral:)];
}
- (void)nullLiteral { [self parseRule:@selector(__nullLiteral) withMemo:_nullLiteral_memo]; }

- (void)__trueLiteral
{
    [self match:MSJSONPARSER_TOKEN_KIND_TRUELITERAL discard:NO];
    [self fireAssemblerSelector:@selector(parser:didMatchTrueLiteral:)];
}
- (void)trueLiteral { [self parseRule:@selector(__trueLiteral) withMemo:_trueLiteral_memo]; }

- (void)__falseLiteral
{
    [self match:MSJSONPARSER_TOKEN_KIND_FALSELITERAL discard:NO];
    [self fireAssemblerSelector:@selector(parser:didMatchFalseLiteral:)];
}
- (void)falseLiteral { [self parseRule:@selector(__falseLiteral) withMemo:_falseLiteral_memo]; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark Punction terminals - {}[],:".
////////////////////////////////////////////////////////////////////////////////

- (void)__openCurly
{
    [self match:MSJSONPARSER_TOKEN_KIND_OPENCURLY discard:NO];
    [self fireAssemblerSelector:@selector(parser:didMatchOpenCurly:)];
}
- (void)openCurly { [self parseRule:@selector(__openCurly) withMemo:_openCurly_memo]; }

- (void)__closeCurly
{
    [self match:MSJSONPARSER_TOKEN_KIND_CLOSECURLY discard:NO];
    [self fireAssemblerSelector:@selector(parser:didMatchCloseCurly:)];
}
- (void)closeCurly { [self parseRule:@selector(__closeCurly) withMemo:_closeCurly_memo]; }

- (void)__openBracket
{
    [self match:MSJSONPARSER_TOKEN_KIND_OPENBRACKET discard:NO];
    [self fireAssemblerSelector:@selector(parser:didMatchOpenBracket:)];
}
- (void)openBracket { [self parseRule:@selector(__openBracket) withMemo:_openBracket_memo]; }

- (void)__closeBracket
{
    [self match:MSJSONPARSER_TOKEN_KIND_CLOSEBRACKET discard:NO];
    [self fireAssemblerSelector:@selector(parser:didMatchCloseBracket:)];
}
- (void)closeBracket { [self parseRule:@selector(__closeBracket) withMemo:_closeBracket_memo]; }

- (void)__comma { [self match:MSJSONPARSER_TOKEN_KIND_COMMA discard:NO]; }
- (void)comma { [self parseRule:@selector(__comma) withMemo:_comma_memo]; }

- (void)__colon { [self match:MSJSONPARSER_TOKEN_KIND_COLON discard:NO]; }
- (void)colon { [self parseRule:@selector(__colon) withMemo:_colon_memo]; }

@end
