//
//  MSJSONParser+Rules.m
//  MSKit
//
//  Created by Jason Cardwell on 5/6/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSJSONParser.h"
#import <ParseKit/ParseKit.h>
#import <objc/runtime.h>
#import "MSStack.h"
#import "MSLog.h"
#import "MSKitLoggingFunctions.h"
#import "NSArray+MSKitAdditions.h"
#import "MSError.h"
#import "MSDictionary.h"
#import "MSKitMiscellaneousFunctions.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros
////////////////////////////////////////////////////////////////////////////////

#define LT(i) [self LT : (i)]
#define LA(i) [self LA : (i)]
#define LS(i) [self LS : (i)]
#define LF(i) [self LF : (i)]

#define POP()       [self.assembly pop]
#define POP_STR()   [self _popString]
#define POP_TOK()   [self _popToken]
#define POP_BOOL()  [self _popBool]
#define POP_INT()   [self _popInteger]
#define POP_FLOAT() [self _popDouble]

#define PUSH(obj)     [self.assembly push : (id)(obj)]
#define PUSH_BOOL(yn) [self _pushBool : (BOOL)(yn)]
#define PUSH_INT(i)   [self _pushInteger : (NSInteger)(i)]
#define PUSH_FLOAT(f) [self _pushDouble : (double)(f)]

#define EQ(a, b)             [(a)isEqual : (b)]
#define NE(a, b)             (![(a)isEqual : (b)])
#define EQ_IGNORE_CASE(a, b) (NSOrderedSame == [(a)compare : (b)])

#define ABOVE(fence) [self.assembly objectsAbove : (fence)]

#define LOG(obj)   do { NSLog(@"%@", (obj)); } while (0);
#define PRINT(str) do { printf("%s\n", (str)); } while (0);

#define EXECUTE(BLOCK) [self execute : (id)^{ BLOCK; return nil; }]


////////////////////////////////////////////////////////////////////////////////
#pragma mark - PKSParser Extension
////////////////////////////////////////////////////////////////////////////////
@interface PKSParser ()
@property (nonatomic, strong) NSMutableDictionary  *_tokenKindTab;
@property (nonatomic, strong) NSMutableArray       *_tokenKindNameTab;

- (BOOL)      _popBool;
- (NSInteger) _popInteger;
- (double)    _popDouble;
- (PKToken *) _popToken;
- (NSString *)_popString;

- (void)_pushBool:(BOOL)yn;
- (void)_pushInteger:(NSInteger)i;
- (void)_pushDouble:(double)d;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - PKToken Extension
////////////////////////////////////////////////////////////////////////////////

@interface PKToken ()

@property (nonatomic, readonly, getter = isArray)        BOOL   array;
@property (nonatomic, readonly, getter = isObject)       BOOL   object;
@property (nonatomic, readonly, getter = isCloseCurly)   BOOL   closeCurly;
@property (nonatomic, readonly, getter = isOpenCurly)    BOOL   openCurly;
@property (nonatomic, readonly, getter = isCloseBracket) BOOL   closeBracket;
@property (nonatomic, readonly, getter = isOpenBracket)  BOOL   openBracket;
@property (nonatomic, readonly, getter = isComma)        BOOL   comma;
@property (nonatomic, readonly, getter = isColon)        BOOL   colon;
@property (nonatomic, readonly, getter = isFalseLiteral) BOOL   falseLiteral;
@property (nonatomic, readonly, getter = isTrueLiteral)  BOOL   trueLiteral;
@property (nonatomic, readonly, getter = isNullLiteral)  BOOL   nullLiteral;
@property (nonatomic, readonly, getter = isKey)          BOOL   key;
@property (nonatomic, readonly, getter = isKeyPath)      BOOL   keypath;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Helper Functions
////////////////////////////////////////////////////////////////////////////////

NSString *paddingForDepth(NSUInteger depth)
{
    return [NSString stringWithCharacter:' ' count:depth * 4];
}

PKToken *paddingTokenForDepth(NSUInteger depth)
{
    NSString * padding = [NSString stringWithCharacter:' ' count:depth * 4];
    PKToken  * token   = [PKToken tokenWithTokenType:PKTokenTypeWhitespace
                                         stringValue:padding
                                          floatValue:0];
    return token;
}

void pushIndentForDepth(PKAssembly * assembly, NSUInteger depth)
{
    [assembly push:paddingForDepth(depth)];
}

void pushIndentTokenForDepth(PKAssembly * assembly, NSUInteger depth)
{
    [assembly push:paddingTokenForDepth(depth)];
}

void pushNewLine(PKAssembly * assembly){ [assembly push:@"\n"]; }

void pushNewLineToken(PKAssembly * assembly)
{
    [assembly push:[PKToken tokenWithTokenType:PKTokenTypeSymbol
                                   stringValue:@"\n"
                                    floatValue:0.0]];
}

BOOL pushWhitespaceForFlag(PKAssembly        * assembly,
                           NSUInteger          depth,
                           MSJSONFormatOptions flag,
                           MSJSONFormatOptions options)
{
    if (options & flag)
    {
        pushNewLine(assembly);

        if (options & MSJSONFormatIndentByDepth) pushIndentForDepth(assembly, depth);

        return YES;
    }

    else
        return NO;
}

void pushPostColonWhitespace(PKAssembly        * assembly,
                             NSInteger           nextTok,
                             NSUInteger          depth,
                             MSJSONFormatOptions options)
{
    BOOL   didPush = NO;

    switch (nextTok)
    {
        case MSJSONPARSER_TOKEN_KIND_OPEN_BRACKET:
            didPush = pushWhitespaceForFlag(assembly,
                                            depth,
                                            MSJSONFormatLineBreakBetweenColonAndArray,
                                            options);
            break;

        case MSJSONPARSER_TOKEN_KIND_OPEN_CURLY:
            didPush = pushWhitespaceForFlag(assembly,
                                            depth,
                                            MSJSONFormatLineBreakBetweenColonAndObject,
                                            options);
            break;

        default:
            break;
    }

    if (!didPush) [assembly push:@" "];
}

NSUInteger splitKeyPath(PKAssembly        * assembly,
                        PKToken           * tok,
                        NSUInteger          depth,
                        MSJSONFormatOptions options)
{
    NSUInteger       localDepth = depth;
    NSMutableArray * keys       = [[[tok quotedStringValue] componentsSeparatedByString:@"."]
                                   mutableCopy];
    assert([keys count] > 1);

    PKToken * colonToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol
                                           stringValue:@":"
                                            floatValue:0.0];
    PKToken * openCurly = [PKToken tokenWithTokenType:PKTokenTypeSymbol
                                          stringValue:@"{"
                                           floatValue:0.0];

    PKToken * valuedKeyToken = [PKToken tokenWithTokenType:PKTokenTypeQuotedString
                                               stringValue:$(@"\"%@\"", [keys lastObject])
                                                floatValue:0.0];
    [keys removeLastObject];

    for (NSString * key in keys)
    {
        PKToken * keyToken = [PKToken tokenWithTokenType:PKTokenTypeQuotedString
                                             stringValue:$(@"\"%@\"", key)
                                              floatValue:0.0];
        [assembly push:keyToken];
        [assembly push:colonToken];
        pushPostColonWhitespace(assembly, MSJSONPARSER_TOKEN_KIND_OPEN_CURLY, localDepth, options);
        [assembly push:openCurly];
        localDepth++;
        pushWhitespaceForFlag(assembly, localDepth, MSJSONFormatLineBreakAfterOpenBrace, options);
    }

    [assembly push:valuedKeyToken];
    return localDepth - depth;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - MSJSONParser Extension
////////////////////////////////////////////////////////////////////////////////

@interface MSJSONParser ()

@property (nonatomic, strong) NSMutableDictionary * root_memo;
@property (nonatomic, strong) NSMutableDictionary * object_memo;
@property (nonatomic, strong) NSMutableDictionary * array_memo;
@property (nonatomic, strong) NSMutableDictionary * value_memo;
@property (nonatomic, strong) NSMutableDictionary * key_value_memo;

@end

@implementation MSJSONParser (Rules)

+ (void)load
{
    Class   tokenClass = [PKToken class];

    IMP   imp = imp_implementationWithBlock (^(id _self)
                                             {
                                                 PKTokenType t = [(PKToken*)_self tokenType];
                                                 return (t == MSJSONPARSER_TOKEN_KIND_FALSE);
                                             });
    class_addMethod(tokenClass, @selector(isFalseLiteral), imp, "c@:");

    imp = imp_implementationWithBlock (^(id _self)
                                       {
                                           PKTokenType t = [(PKToken*)_self tokenType];
                                           return (t == MSJSONPARSER_TOKEN_KIND_CLOSE_CURLY);
                                       });
    class_addMethod(tokenClass, @selector(isCloseCurly), imp, "c@:");

    imp = imp_implementationWithBlock (^(id _self)
                                       {
                                           PKTokenType t = [(PKToken*)_self tokenType];
                                           return ((NSInteger)t == MSJSONPARSER_TOKEN_KIND_OPEN_BRACKET);
                                       });
    class_addMethod(tokenClass, @selector(isOpenBracket), imp, "c@:");

    imp = imp_implementationWithBlock (^(id _self)
                                       {
                                           PKTokenType t = [(PKToken*)_self tokenType];
                                           return ((NSInteger)t == MSJSONPARSER_TOKEN_KIND_NULL);
                                       });
    class_addMethod(tokenClass, @selector(isNullLiteral), imp, "c@:");

    imp = imp_implementationWithBlock (^(id _self)
                                       {
                                           PKTokenType t = [(PKToken*)_self tokenType];
                                           return ((NSInteger)t == MSJSONPARSER_TOKEN_KIND_COMMA);
                                       });
    class_addMethod(tokenClass, @selector(isComma), imp, "c@:");

    imp = imp_implementationWithBlock (^(id _self)
                                       {
                                           PKTokenType t = [(PKToken*)_self tokenType];
                                           return ((NSInteger)t == MSJSONPARSER_TOKEN_KIND_TRUE);
                                       });
    class_addMethod(tokenClass, @selector(isTrueLiteral), imp, "c@:");

    imp = imp_implementationWithBlock (^(id _self)
                                       {
                                           PKTokenType t = [(PKToken*)_self tokenType];
                                           return ((NSInteger)t == MSJSONPARSER_TOKEN_KIND_CLOSE_BRACKET);
                                       });
    class_addMethod(tokenClass, @selector(isCloseBracket), imp, "c@:");

    imp = imp_implementationWithBlock (^(id _self)
                                       {
                                           PKTokenType t = [(PKToken*)_self tokenType];
                                           return ((NSInteger)t == MSJSONPARSER_TOKEN_KIND_OPEN_CURLY);
                                       });
    class_addMethod(tokenClass, @selector(isOpenCurly), imp, "c@:");

    imp = imp_implementationWithBlock (^(id _self)
                                       {
                                           PKTokenType t = [(PKToken*)_self tokenType];
                                           return ((NSInteger)t == MSJSONPARSER_TOKEN_KIND_COLON);
                                       });
    class_addMethod(tokenClass, @selector(isColon), imp, "c@:");

    imp = imp_implementationWithBlock (^(id _self)
                                       {
                                           if ([(PKToken*)_self tokenType] != PKTokenTypeQuotedString)
                                               return NO;

                                           NSCharacterSet * validChars =
                                               [NSCharacterSet characterSetWithCharactersInString:
                                                @"abcdefghijklmnopqrstuvwxyz"
                                                "ABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890_"];

                                           NSCharacterSet * selfChars =
                                               [NSCharacterSet characterSetWithCharactersInString:
                                                [(PKToken*)_self quotedStringValue]];

                                           return [validChars isSupersetOfSet:selfChars];
                                       });
    class_addMethod(tokenClass, @selector(isKey), imp, "c@:");

    imp = imp_implementationWithBlock (^(id _self)
                                       {
                                           if ([(PKToken*)_self tokenType] != PKTokenTypeQuotedString)
                                               return NO;

                                           NSString * quotedString = [(PKToken*)_self quotedStringValue];
                                           NSArray  * keys         = [quotedString
                                                                      componentsSeparatedByString:@"."];

                                           if ([keys count] < 2) return NO;

                                           NSCharacterSet * validChars =
                                               [NSCharacterSet characterSetWithCharactersInString:
                                                @"abcdefghijklmnopqrstuvwxyz"
                                                "ABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890_"];

                                           for (NSString * key in keys)
                                           {
                                               NSCharacterSet * keyChars =
                                                   [NSCharacterSet
                                                        characterSetWithCharactersInString:key];

                                               if (![validChars isSupersetOfSet:keyChars]) return NO;
                                           }

                                           return YES;
                                       });
    class_addMethod(tokenClass, @selector(isKeyPath), imp, "c@:");
}

- (id)init
{
    if (self = [super init])
    {
        self._tokenKindTab[@"false"] = @(MSJSONPARSER_TOKEN_KIND_FALSE        );
        self._tokenKindTab[@"}"    ] = @(MSJSONPARSER_TOKEN_KIND_CLOSE_CURLY  );
        self._tokenKindTab[@"["    ] = @(MSJSONPARSER_TOKEN_KIND_OPEN_BRACKET );
        self._tokenKindTab[@"null" ] = @(MSJSONPARSER_TOKEN_KIND_NULL         );
        self._tokenKindTab[@","    ] = @(MSJSONPARSER_TOKEN_KIND_COMMA        );
        self._tokenKindTab[@":"    ] = @(MSJSONPARSER_TOKEN_KIND_COLON        );
        self._tokenKindTab[@"]"    ] = @(MSJSONPARSER_TOKEN_KIND_CLOSE_BRACKET);
        self._tokenKindTab[@"{"    ] = @(MSJSONPARSER_TOKEN_KIND_OPEN_CURLY   );
        self._tokenKindTab[@"true" ] = @(MSJSONPARSER_TOKEN_KIND_TRUE         );

        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_FALSE        ] = @"false";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_CLOSE_CURLY  ] = @"}";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_OPEN_BRACKET ] = @"[";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_NULL         ] = @"null";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_COMMA        ] = @",";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_COLON        ] = @":";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_CLOSE_BRACKET] = @"]";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_OPEN_CURLY   ] = @"{";
        self._tokenKindNameTab[MSJSONPARSER_TOKEN_KIND_TRUE         ] = @"true";

        self.root_memo      = [NSMutableDictionary dictionary];
        self.object_memo    = [NSMutableDictionary dictionary];
        self.array_memo     = [NSMutableDictionary dictionary];
        self.value_memo     = [NSMutableDictionary dictionary];
        self.key_value_memo = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)_clearMemo
{
    [self.root_memo      removeAllObjects];
    [self.object_memo    removeAllObjects];
    [self.array_memo     removeAllObjects];
    [self.value_memo     removeAllObjects];
    [self.key_value_memo removeAllObjects];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Rule matching
////////////////////////////////////////////////////////////////////////////////

- (void)_start
{
    [self execute:(id)^{
        PKTokenizer * t = self.tokenizer;
        self.silentlyConsumesWhitespace           = YES;
        t.whitespaceState.reportsWhitespaceTokens = (_options & MSJSONFormatPreserveWhitespace);
        self.assembly.preservesWhitespaceTokens   = (_options & MSJSONFormatPreserveWhitespace);
        t.commentState.reportsCommentTokens       = (_options & MSJSONFormatKeepComments);
        return nil;
    }];

    [self matchCommentMaybe];
    [self matchRoot];
    [self matchCommentMaybe];
    [self matchEOF:YES];
}

- (void)matchRoot { [self parseRule:@selector(__matchRoot) withMemo:self.root_memo]; }

- (void)__matchRoot
{
    if ([self predicts:MSJSONPARSER_TOKEN_KIND_OPEN_BRACKET, 0])
    {
        _parsedObject = [@[] mutableCopy];
        [self matchArray];
    }

    else if ([self predicts:MSJSONPARSER_TOKEN_KIND_OPEN_CURLY, 0])
    {
        _parsedObject = [MSDictionary dictionary];
        [self matchObject];
    }

    else
        [self raise:@"No viable alternative found in rule 'root'."];
}

- (void)matchObject { [self parseRule:@selector(__matchObject) withMemo:self.object_memo]; }

- (void)__matchObject
{
    [self matchCommentMaybe];

    [self execute:(id)^{
        if (_options & MSJSONFormatLineBreakBetweenColonAndObject)
        {
            PKToken * tok = [self.assembly pop];
            [self.assembly push:tok];

            if ([@":" isEqualToString:[tok stringValue]])
                pushWhitespaceForFlag(self.assembly, _depth, _options, _options);
        }
        return nil;
    }];

    [self match:MSJSONPARSER_TOKEN_KIND_OPEN_CURLY discard:NO];

    _depth++;

    [self matchCommentMaybe];

    [self execute:(id)^{
        pushWhitespaceForFlag(self.assembly,
                              _depth,
                              MSJSONFormatLineBreakAfterOpenBrace,
                              _options);
        return nil;
    }];

    [self matchKeyValue];

    [self matchCommentMaybe];

    while ([self predicts:MSJSONPARSER_TOKEN_KIND_COMMA, 0])
    {
        if ([self speculate:^{
                 [self match:MSJSONPARSER_TOKEN_KIND_COMMA discard:NO];
                 [self matchCommentMaybe];
                 [self matchKeyValue];
             }])
        {
            [self match:MSJSONPARSER_TOKEN_KIND_COMMA discard:NO];

            [self matchCommentMaybe];

            [self execute:(id)^{ pushWhitespaceForFlag(self.assembly,
                                            _depth,
                                            MSJSONFormatLineBreakAfterComma,
                                            _options); }];

            [self matchKeyValue];
        }

        else
            break;
    }

    _depth--;

    [self execute:(id)^{
        pushWhitespaceForFlag(self.assembly,
                              _depth,
                              MSJSONFormatLineBreakBeforeCloseBrace,
                              _options);
        return nil;
    }];
    
    [self matchCommentMaybe];

    [self match:MSJSONPARSER_TOKEN_KIND_CLOSE_CURLY discard:NO];

    [self matchCommentMaybe];
}

- (void)matchKeyValue { [self parseRule:@selector(__matchKeyValue) withMemo:self.key_value_memo]; }

- (void)__matchKeyValue
{
    [self matchCommentMaybe];

    [self matchQuotedString:NO];

    __block NSUInteger   bracesPushed = 0;

    if (!(_options & MSJSONFormatKeepKeyPaths))
        [self execute:(id)^{
            PKToken * tok = [self.assembly pop];

            if ([tok isKeyPath])
            {
                bracesPushed = splitKeyPath(self.assembly, tok, _depth, _options);
                _depth += bracesPushed;
            }
            
            else
                [self.assembly push:tok];

            return nil;
        }];

    [self match:MSJSONPARSER_TOKEN_KIND_COLON discard:NO];

    [self matchCommentMaybe];

    [self matchValue];

    [self matchCommentMaybe];

    [self execute:(id)^{
        PKToken * closeCurly = [PKToken tokenWithTokenType:PKTokenTypeSymbol
                                               stringValue:@"}"
                                                floatValue:0.0];

        while (bracesPushed-- > 0)
        {
            pushWhitespaceForFlag(self.assembly,
                                  --_depth,
                                  MSJSONFormatLineBreakBeforeCloseBrace,
                                  _options);

            [self.assembly push:closeCurly];
        }
        return nil;
    }];
}

- (void)matchArray { [self parseRule:@selector(__matchArray) withMemo:self.array_memo]; }

- (void)__matchArray
{
    [self execute:(id)^{
        if (_options & MSJSONFormatLineBreakBetweenColonAndArray)
        {
            PKToken * tok = [self.assembly pop];
            [self.assembly push:tok];

            if ([@":" isEqualToString:[tok stringValue]])
                pushWhitespaceForFlag(self.assembly, _depth, _options, _options);
        }
        return nil;
    }];

    [self match:MSJSONPARSER_TOKEN_KIND_OPEN_BRACKET discard:NO];

    _depth++;

    [self execute:(id)^{
        pushWhitespaceForFlag(self.assembly,
                              _depth,
                              MSJSONFormatLineBreakAfterOpenBracket,
                              _options);
        return nil;
    }];

    [self matchCommentMaybe];

    [self matchValue];

    while ([self predicts:MSJSONPARSER_TOKEN_KIND_COMMA, 0])
    {
        if ([self speculate:^{
                 [self match:MSJSONPARSER_TOKEN_KIND_COMMA discard:NO];
                 [self matchCommentMaybe];
                 [self matchValue];
             }])
        {
            [self match:MSJSONPARSER_TOKEN_KIND_COMMA discard:NO];
            [self execute:(id)^{
                pushWhitespaceForFlag(self.assembly,
                                      _depth,
                                      MSJSONFormatLineBreakAfterComma,
                                      _options);
                return nil;
            }];
            
            [self matchCommentMaybe];

            [self matchValue];
        }

        else
            break;
    }

    [self matchCommentMaybe];

    _depth--;

    [self execute:(id)^{
        pushWhitespaceForFlag(self.assembly,
                              _depth,
                              MSJSONFormatLineBreakBeforeCloseBracket,
                              _options);
        return nil;
    }];

    [self match:MSJSONPARSER_TOKEN_KIND_CLOSE_BRACKET discard:NO];
}

- (void)matchCommentMaybe
{
    if ((_options & MSJSONFormatKeepComments) && [self predicts:TOKEN_KIND_BUILTIN_COMMENT, 0])
    {
        [self execute:(id)^{
            pushWhitespaceForFlag(self.assembly, _depth, _options, _options);
            return nil;
        }];
        [self matchComment:NO];
        [self execute:(id)^{
            pushWhitespaceForFlag(self.assembly, _depth, _options, _options);
            return nil;
        }];
    }
}

- (void)matchValue { [self parseRule:@selector(__matchValue) withMemo:self.value_memo]; }

- (void)__matchValue
{
    if ([self predicts:MSJSONPARSER_TOKEN_KIND_NULL, 0])
        [self match:MSJSONPARSER_TOKEN_KIND_NULL discard:NO];

    else if ([self predicts:MSJSONPARSER_TOKEN_KIND_TRUE, 0])
        [self match:MSJSONPARSER_TOKEN_KIND_TRUE discard:NO];

    else if ([self predicts:MSJSONPARSER_TOKEN_KIND_FALSE, 0])
        [self match:MSJSONPARSER_TOKEN_KIND_FALSE discard:NO];

    else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0])
        [self matchNumber:NO];

    else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0])
        [self matchQuotedString:NO];

    else if ([self predicts:MSJSONPARSER_TOKEN_KIND_OPEN_BRACKET, 0])
        [self matchArray];

    else if ([self predicts:MSJSONPARSER_TOKEN_KIND_OPEN_CURLY, 0])
        [self matchObject];

    else
        [self raise:@"No viable alternative found in rule 'value'."];
}

@end
