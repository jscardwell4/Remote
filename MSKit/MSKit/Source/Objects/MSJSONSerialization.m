//
//  MSJSONSerialization.m
//  MSKit
//
//  Created by Jason Cardwell on 10/20/13.
//  Copyright (c) 2013 Jason Cardwell. All rights reserved.
//

#import "MSJSONSerialization.h"
#import <ParseKit/ParseKit.h>
#import "MSStack.h"
#import "MSDictionary.h"
#import "NSArray+MSKitAdditions.h"
#import "NSDictionary+MSKitAdditions.h"
#import "MSJSONParser.h"
#import "MSJSONAssembler.h"
#import "NSString+MSKitAdditions.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

MSKEY_DEFINITION(MSJSONComment);
MSKEY_DEFINITION(MSJSONLeadingComment);
MSKEY_DEFINITION(MSJSONTrailingComment);

@interface NSObject (MSJSONAssembler)

@property (nonatomic, copy) NSString * comment;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - MSJSONSerialization
////////////////////////////////////////////////////////////////////////////////


@implementation MSJSONSerialization

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utilities
////////////////////////////////////////////////////////////////////////////////


+ (BOOL)isValidJSONValue:(id)value
{
    return (   [value isKindOfClass:[NSString class]]
            || [value isKindOfClass:[NSArray class]]
            || [value isKindOfClass:[NSDictionary class]]
            || [value isKindOfClass:[NSNumber class]]
            || [value isKindOfClass:[NSNull class]]);
}

+ (NSString *)JSONFromObject:(id)object
{
    NSString *(^__weak __block weakStringFromObject)(id, NSUInteger);
    NSString *(^__block stringFromObject)(id, NSUInteger);
    weakStringFromObject = stringFromObject = ^(id object, NSUInteger depth)
    {
        NSString * indent = [NSString stringWithCharacter:' ' count:depth*4];
        NSMutableString * string = [indent mutableCopy];

        if ([object isKindOfClass:[NSArray class]])
        {
            [string appendString:@"["];
            NSArray * array = (NSArray *)object;

            NSString * comment = array.comment;

            if (comment) [string appendFormat:@" %@", comment];

            NSUInteger objectCount = [array count];
            for (NSUInteger i = 0; i < objectCount; i++)
            {
                NSString * valueString = weakStringFromObject(array[i], depth + 1);
                valueString = [valueString stringByTrimmingTrailingWhitespace];
                [string appendFormat:@"\n%@", valueString];
                if (i + 1 < objectCount) [string appendString:@","];
                comment = ((NSObject *)array[i]).comment;
                if (comment) [string appendFormat:@" %@", comment];
            }
            if (objectCount) [string appendFormat:@"\n%@", indent];
            [string appendString:@"]"];
        }

        else if ([object isKindOfClass:[NSDictionary class]])
        {
            [string appendString:@"{"];
            MSDictionary * comments = nil;
            
            if (isMSDictionary(object))
                comments = ((MSDictionary *)object).userInfo[MSJSONCommentKey];

            if ([comments hasKey:MSJSONLeadingCommentKey])
                [string appendFormat:@" /* %@ */", comments[MSJSONLeadingCommentKey]];

            else if (((NSObject *)object).comment)
                [string appendFormat:@" %@", ((NSObject *)object).comment];

            NSDictionary * dictionary = (NSDictionary *)object;
            NSArray * keys = [dictionary allKeys];
            NSUInteger keyCount = [keys count];

            for (NSUInteger i = 0; i < keyCount; i++)
            {
                id key = keys[i];
                NSString * keyString = weakStringFromObject(key, depth + 1);
                NSString * valueString = weakStringFromObject(dictionary[key], depth + 1);
                valueString = [valueString stringByTrimmingWhitespace];
                
                [string appendFormat:@"\n%@: %@", keyString, valueString];
                if (i + 1 < keyCount) [string appendString:@","];
                
                if ([comments hasKey:key]) [string appendFormat:@" /* %@ */", comments[key]];
                else if (((NSObject *)dictionary[key]).comment)
                    [string appendFormat:@" %@", ((NSObject *)dictionary[key]).comment];
            }

            if (keyCount) [string appendFormat:@"\n%@", indent];
            [string appendString:@"}"];

            if ([comments hasKey:MSJSONTrailingCommentKey])
                [string appendFormat:@" /* %@ */", comments[MSJSONTrailingCommentKey]];
        }

        else if ([object isKindOfClass:[NSNumber class]])
        {
            if (object == (void *)kCFBooleanFalse || object == (void *)kCFBooleanTrue)
                [string appendString:([object boolValue] ? @"true" : @"false")];

            else // num is not boolean
                [string appendString:[object stringValue]];
        }

        else if ([object isKindOfClass:[NSNull class]]) [string appendString:@"null"];

        else if ([object isKindOfClass:[NSString class]]) [string appendFormat:@"\"%@\"", object];

        return (NSString *)string;
    };

    if (![NSJSONSerialization isValidJSONObject:object]) return nil;

    return [stringFromObject(object, 0) stringByAppendingString:@"\n"];
}

+ (BOOL)writeJSONObject:(id<MSJSONExport>)object filePath:(NSString *)filePath
{
    id jsonObject = object.JSONObject;
    if (!jsonObject) ThrowInvalidArgument(object, is not a valid JSON object);

    NSString * jsonString = [self JSONFromObject:jsonObject];
    NSAssert(jsonString, @"failed to create JSON string for %@", ClassTagStringForInstance(object));

    return (jsonString ? [jsonString writeToFile:filePath] : NO);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Producing a string from JSON content
////////////////////////////////////////////////////////////////////////////////

+ (NSString *)parseFile:(NSString *)filePath error:(NSError *__autoreleasing *)error
{
    return [self parseFile:filePath options:MSJSONFormatKeepKeyPaths error:error];
}

+ (NSString *)parseString:(NSString *)string error:(NSError **)error
{
    return [self parseString:string options:MSJSONFormatKeepKeyPaths error:error];
}

+ (NSString *)parseFile:(NSString *)filePath
                options:(MSJSONFormatOptions)options
                  error:(NSError *__autoreleasing *)error
{
    NSString * string = [NSString stringWithContentsOfFile:filePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:error];

    return (string ? [self parseString:string error:error] : nil);
}

+ (NSString *)parseString:(NSString *)string
                  options:(MSJSONFormatOptions)options
                    error:(NSError *__autoreleasing *)error
{
    id assembledObject = [self objectByParsingString:string options:options error:error];

    return (assembledObject ? [self JSONFromObject:assembledObject] : nil);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Producing Objective-C objects from JSON content
////////////////////////////////////////////////////////////////////////////////

+ (id)objectByParsingString:(NSString *)string error:(NSError **)error
{
    return [self objectByParsingString:string options:MSJSONFormatDefault error:error];
}

+ (id)objectByParsingString:(NSString *)string
                    options:(MSJSONFormatOptions)options
                      error:(NSError *__autoreleasing *)error
{
    MSJSONParser * parser = [MSJSONParser parserWithOptions:options];
    MSJSONAssembler * assembler = [MSJSONAssembler assemblerWithOptions:options];
    PKAssembly * assembly =  [parser parseString:string assembler:assembler error:error];
    id assembledObject =  (assembly ? assembler.assembledObject : nil);
    return assembledObject;
}

+ (id)objectByParsingFile:(NSString *)filePath error:(NSError **)error
{
    return [self objectByParsingFile:filePath options:MSJSONFormatDefault error:error];
}

+ (id)objectByParsingFile:(NSString *)filePath
                  options:(MSJSONFormatOptions)options
                    error:(NSError *__autoreleasing *)error
{
    NSString * string = [NSString stringWithContentsOfFile:filePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:error];
    return (string ? [self objectByParsingString:string options:options error:error] : nil);
}

@end
