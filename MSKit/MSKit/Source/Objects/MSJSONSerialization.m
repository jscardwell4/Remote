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
#import "MSJSONParser.h"
#import "MSJSONAssembler.h"
#import "NSString+MSKitAdditions.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)


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
        NSString * indent = [NSString stringWithCharacter:' ' count:depth*2];
        NSMutableString * string = [indent mutableCopy];

        if ([object isKindOfClass:[NSArray class]])
        {
            [string appendString:@"["];
            NSArray * array = (NSArray *)object;
            if ([array count] > 1)
                [array enumerateObjectsAtIndexes:NSIndexSetMake(0, ([array count] - 1))
                                         options:0
                                      usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                          [string appendFormat:@"\n%@,",
                                           [weakStringFromObject(obj, depth + 1)
                                            stringByTrimmingTrailingWhitespace]];
                                      }];

            if ([array count])
                [string appendFormat:@"\n%@", [weakStringFromObject([array lastObject], depth + 1)
                                                    stringByTrimmingTrailingWhitespace]];
            [string appendFormat:@"\n%@]", indent];
        }

        else if ([object isKindOfClass:[NSDictionary class]])
        {
            [string appendString:@"{"];
            NSDictionary * dictionary = (NSDictionary *)object;
            NSArray * keys = [dictionary allKeys];
            if ([keys count] > 1)
                [keys enumerateObjectsAtIndexes:NSIndexSetMake(0, ([keys count] - 1))
                                        options:0
                                     usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                         [string appendFormat:@"\n%@: %@,",
                                                              weakStringFromObject(obj, depth + 1),
                                                              [weakStringFromObject(dictionary[obj], depth + 1)
                                                               stringByTrimmingWhitespace]];
                                     }];

            if ([keys count])
                [string appendFormat:@"\n%@: %@",
                                     weakStringFromObject([keys lastObject], depth + 1),
                                     [weakStringFromObject(dictionary[[keys lastObject]], depth + 1)
                                      stringByTrimmingWhitespace]];

            [string appendFormat:@"\n%@}", indent];
        }

        else if ([object isKindOfClass:[NSNumber class]])
        {
            NSNumber *number = (NSNumber *)object;
            if (number == (void*)kCFBooleanFalse || number == (void*)kCFBooleanTrue)
            {
                [string appendString:([number boolValue] ? @"true" : @"false")];
            } else {
                // num is not boolean
                [string appendString:[(NSNumber *)object stringValue]];
            }
        }

        else if ([object isKindOfClass:[NSNull class]])
            [string appendString:@"null"];
        else if ([object isKindOfClass:[NSString class]])
            [string appendFormat:@"\"%@\"", object];

        return (NSString *)string;
    };

    if (![NSJSONSerialization isValidJSONObject:object]) return nil;

    NSString * jsonString = stringFromObject(object, 0);

    return jsonString;
}

//#define CUSTOM_STRING_GENERATION

+ (NSString *)stringFromTopLevelJSONObject:(id)jsonObject
{

    NSString *(^stringFromObject)(id) = ^(id obj)
    {
        if ([obj isKindOfClass:[NSArray class]])
        {
            return (NSString *)nil;
        }

        else if ([obj isKindOfClass:[NSDictionary class]])
        {
            return (NSString *)nil;
        }

        else
            return (NSString *)nil;
    };


    if (![NSJSONSerialization isValidJSONObject:jsonObject]) return nil;

    else return stringFromObject(jsonObject);
}

+ (BOOL)writeJSONObject:(id<MSJSONExport>)object toFileNamed:(NSString *)name
{
    id jsonObject = object.JSONObject;
    NSAssert(jsonObject, @"failed to get JSON object for %@", ClassTagStringForInstance(object));

    NSString * jsonString = nil;

    if (jsonObject)
    {
#ifdef CUSTOM_STRING_GENERATION
        jsonString = [self stringFromTopLevelJSONObject:jsonObject];
#else
        NSError * error = nil;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:&error];
        if (error) MSHandleErrors(error);
        else jsonString = [[NSString stringWithData:jsonData]
                           stringByReplacingOccurrencesOfRegEx:@"^(\\s*\"[^\"]+\") :" withString:@"$1:"];
#endif
    }

    else
        return NO;

    NSAssert(jsonString, @"failed to create JSON string for %@", ClassTagStringForInstance(object));

    if (!jsonString) return NO;

    NSString * filePath = [DocumentsFilePath stringByAppendingPathComponent:name];
    NSError * error;
    [jsonString writeToFile:filePath
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:&error];

    if (error)
    {
        MSHandleErrors(error);
        return NO;
    }

    else
        return YES;
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
