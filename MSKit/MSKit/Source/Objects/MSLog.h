//
//  MSLog.h
//  MSKit
//
//  Created by Jason Cardwell on 2/23/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSKitMacros.h"
#import "MSError.h"

#import <Lumberjack/Lumberjack.h>
#import "NSObject+MSKitAdditions.h"
// keys
MSEXTERN_STRING MSLogClassNameKey;
MSEXTERN_STRING MSLogObjectNameKey;
MSEXTERN_STRING MSLogObjectKey;
MSEXTERN_STRING MSLogContextKey;

/*

 log flags

 from DDLog.h:
  #define LOG_FLAG_ERROR   (1 << 0)   // 0...0001
  #define LOG_FLAG_WARN    (1 << 1)   // 0...0010
  #define LOG_FLAG_INFO    (1 << 2)   // 0...0100
  #define LOG_FLAG_VERBOSE (1 << 3)   // 0...1000

 */
#undef LOG_FLAG_ERROR
#undef LOG_FLAG_WARN
#undef LOG_FLAG_INFO
#undef LOG_FLAG_VERBOSE

#define LOG_FLAG_ERROR                 0b0000000000000001
#define LOG_FLAG_WARN                  0b0000000000000010
#define LOG_FLAG_INFO                  0b0000000000000100
#define LOG_FLAG_VERBOSE               0b0000000000001000
#define LOG_FLAG_DEBUG                 0b0000000000010000
#define LOG_FLAG_TTY                   0b0000000000100000
#define LOG_FLAG_ASL                   0b0000000001000000
#define LOG_FLAG_CONSOLE               0b0000000001100000
#define LOG_FLAG_FILE                  0b0000000010000000
#define LOG_FLAG_UNITTEST              0b0000000100000000
#define LOG_FLAG_UNITTESTPASS          0b0000001000000000
#define LOG_FLAG_UNITTESTFAIL          0b0000010000000000
#define LOG_FLAG_MSKIT                 0b0000100000000000
#define LOG_FLAG_MAGICALRECORD         0b0001000000000000

/*

 log levels

 from DDLog.h:
  #define LOG_LEVEL_OFF     0
  #define LOG_LEVEL_ERROR   (LOG_FLAG_ERROR)                                               // 0001
  #define LOG_LEVEL_WARN    (LOG_FLAG_ERROR|LOG_FLAG_WARN)                                 // 0011
  #define LOG_LEVEL_INFO    (LOG_FLAG_ERROR|LOG_FLAG_WARN|LOG_FLAG_INFO)                   // 0111
  #define LOG_LEVEL_VERBOSE (LOG_FLAG_ERROR|LOG_FLAG_WARN|LOG_FLAG_INFO|LOG_FLAG_VERBOSE)  // 1111

  #define LOG_ERROR         (ddLogLevel & LOG_FLAG_ERROR)
  #define LOG_WARN          (ddLogLevel & LOG_FLAG_WARN)
  #define LOG_INFO          (ddLogLevel & LOG_FLAG_INFO)
  #define LOG_VERBOSE       (ddLogLevel & LOG_FLAG_VERBOSE)

  #define LOG_ASYNC_ERROR   (NO && LOG_ASYNC_ENABLED)
  #define LOG_ASYNC_WARN    (YES && LOG_ASYNC_ENABLED)
  #define LOG_ASYNC_INFO    (YES && LOG_ASYNC_ENABLED)
  #define LOG_ASYNC_VERBOSE (YES && LOG_ASYNC_ENABLED)
*/

#undef LOG_LEVEL_OFF
#undef LOG_LEVEL_ERROR
#undef LOG_LEVEL_WARN
#undef LOG_LEVEL_INFO
#undef LOG_LEVEL_VERBOSE

#define LOG_LEVEL_OFF       0b0000000000000000
#define LOG_LEVEL_ERROR     0b0000000000000001 // LOG_FLAG_ERROR
#define LOG_LEVEL_WARN      0b0000000000000011 // LOG_FLAG_ERROR|LOG_FLAG_WARN
#define LOG_LEVEL_INFO      0b0000000000000111 // LOG_FLAG_ERROR|LOG_FLAG_WARN|LOG_FLAG_INFO
#define LOG_LEVEL_VERBOSE   0b0000000000001111 // LOG_FLAG_ERROR|LOG_FLAG_WARN|LOG_FLAG_INFO|LOG_FLAG_VERBOSE
#define LOG_LEVEL_DEBUG     0b0000000000010011 // LOG_FLAG_ERROR|LOG_FLAG_WARN|LOG_FLAG_DEBUG
#define LOG_LEVEL_UNITTEST  0b1111111111111111

#undef LOG_ERROR
#undef LOG_WARN
#undef LOG_INFO
#undef LOG_VERBOSE

#define LOG_ERROR    (ddLogLevel & LOG_FLAG_ERROR   )
#define LOG_WARN     (ddLogLevel & LOG_FLAG_WARN    )
#define LOG_INFO     (ddLogLevel & LOG_FLAG_INFO    )
#define LOG_VERBOSE  (ddLogLevel & LOG_FLAG_VERBOSE )
#define LOG_DEBUG    (ddLogLevel & LOG_FLAG_DEBUG   )
#define LOG_UNITTEST (ddLogLevel & LOG_FLAG_UNITTEST)

#undef LOG_ASYNC_ERROR
#undef LOG_ASYNC_WARN
#undef LOG_ASYNC_INFO
#undef LOG_ASYNC_VERBOSE

#define LOG_ASYNC_ERROR    (NO  && LOG_ASYNC_ENABLED)
#define LOG_ASYNC_WARN     (YES && LOG_ASYNC_ENABLED)
#define LOG_ASYNC_INFO     (YES && LOG_ASYNC_ENABLED)
#define LOG_ASYNC_VERBOSE  (YES && LOG_ASYNC_ENABLED)
#define LOG_ASYNC_DEBUG    (NO  && LOG_ASYNC_ENABLED)
#define LOG_ASYNC_UNITTEST (NO  && LOG_ASYNC_ENABLED)

/*
 contexts
 */
#define LOG_CONTEXT_DEFAULT  0b0000000000000000
#define LOG_CONTEXT_FILE     0b0000000000000001
#define LOG_CONTEXT_TTY      0b0000000000000010
#define LOG_CONTEXT_ASL      0b0000000000000100
#define LOG_CONTEXT_CONSOLE  0b0000000000000110
#define LOG_CONTEXT_MSKIT    0b0000000000001000
#define LOG_CONTEXT_UNITTEST 0b0000000000010111
#define LOG_CONTEXT_ANY      0b1111111111111111

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Base Logging Macros
////////////////////////////////////////////////////////////////////////////////

// Wrapper for Lumberjack's `LOG_MACRO` through which all following macros are funneled,
// in case I ever want to alter behavior
#define MSLOG_MACRO(isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
    LOG_MACRO(isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ##__VA_ARGS__)

// Objective-C macro funnel
#define  MSLOG_OBJC_MACRO(async, lvl, flg, ctx, frmt, ...) \
    MSLOG_MACRO(async, lvl, flg, ctx, nil, sel_getName(_cmd), frmt, ##__VA_ARGS__)

// Synchronous Objective-C macro funnel
#define  MSSYNC_LOG_OBJC_MACRO(lvl, flg, ctx, frmt, ...)   \
    MSLOG_OBJC_MACRO( NO, lvl, flg, ctx, frmt, ##__VA_ARGS__)

// Asynchronous Objective-C macro funnel
#define  MSASYNC_LOG_OBJC_MACRO(lvl, flg, ctx, frmt, ...)  \
    MSLOG_OBJC_MACRO(YES, lvl, flg, ctx, frmt, ##__VA_ARGS__)

// C function macro funnel
#define  MSLOG_C_MACRO(async, lvl, flg, ctx, frmt, ...)    \
    MSLOG_MACRO(async, lvl, flg, ctx, nil, __FUNCTION__, frmt, ##__VA_ARGS__)

// Synchronous C function macro funnel
#define  MSSYNC_LOG_C_MACRO(lvl, flg, ctx, frmt, ...)      \
    MSLOG_C_MACRO( NO, lvl, flg, ctx, frmt, ##__VA_ARGS__)

// Asynchronous C function macro funnel
#define  MSASYNC_LOG_C_MACRO(lvl, flg, ctx, frmt, ...)     \
    MSLOG_C_MACRO(YES, lvl, flg, ctx, frmt, ##__VA_ARGS__)

// Level dependent macro funnel
#define  MSLOG_MAYBE(async, lvl, flg, ctx, fnct, frmt, ...) \
    do { if(lvl & flg) MSLOG_MACRO(async, lvl, flg, ctx, nil, fnct, frmt, ##__VA_ARGS__); } while(0)

// Objective-C level dependent macro funnel
#define  MSLOG_OBJC_MAYBE(async, lvl, flg, ctx, frmt, ...)  \
    MSLOG_MAYBE(async, lvl, flg, ctx, sel_getName(_cmd), frmt, ##__VA_ARGS__)

// Synchronous Objective-C level dependent macro funnel
#define  MSSYNC_LOG_OBJC_MAYBE(lvl, flg, ctx, frmt, ...)    \
    MSLOG_OBJC_MAYBE( NO, lvl, flg, ctx, frmt, ##__VA_ARGS__)

// Asynchronous Objective-C level dependent macro funnel
#define  MSASYNC_LOG_OBJC_MAYBE(lvl, flg, ctx, frmt, ...)   \
    MSLOG_OBJC_MAYBE(YES, lvl, flg, ctx, frmt, ##__VA_ARGS__)

// C function level dependent macro funnel
#define  MSLOG_C_MAYBE(async, lvl, flg, ctx, frmt, ...)     \
    MSLOG_MAYBE(async, lvl, flg, ctx, __FUNCTION__, frmt, ##__VA_ARGS__)

// Synchronous C function level dependent macro funnel
#define  MSSYNC_LOG_C_MAYBE(lvl, flg, ctx, frmt, ...)       \
    MSLOG_C_MAYBE( NO, lvl, flg, ctx, frmt, ##__VA_ARGS__)

// Asynchronous C function level dependent macro funnel
#define  MSASYNC_LOG_C_MAYBE(lvl, flg, ctx, frmt, ...)      \
    MSLOG_C_MAYBE(YES, lvl, flg, ctx, frmt, ##__VA_ARGS__)

// Objective-C with tag macro funnel
#define MSLOG_OBJC_TAG_MACRO(async, lvl, flg, ctx, tag, frmt, ...) \
    MSLOG_MACRO(async, lvl, flg, ctx, tag, sel_getName(_cmd), frmt, ##__VA_ARGS__)

// C function with tag macro funnel
#define MSLOG_C_TAG_MACRO(async, lvl, flg, ctx, tag, frmt, ...) \
    MSLOG_MACRO(async, lvl, flg, ctx, tag, __FUNCTION__, frmt, ##__VA_ARGS__)

// Level dependent with tag macro funnel
#define MSLOG_TAG_MAYBE(async, lvl, flg, ctx, tag, fnct, frmt, ...) \
    do { if(lvl & flg) MSLOG_MACRO(async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

// Objective-C level dependent with tag macro funnel
#define MSLOG_OBJC_TAG_MAYBE(async, lvl, flg, ctx, tag, frmt, ...) \
    MSLOG_TAG_MAYBE(async, lvl, flg, ctx, tag, sel_getName(_cmd), frmt, ##__VA_ARGS__)

// C function level dependent with tag macro funnel
#define MSLOG_C_TAG_MAYBE(async, lvl, flg, ctx, tag, frmt, ...) \
    MSLOG_TAG_MAYBE(async, lvl, flg, ctx, tag, __FUNCTION__, frmt, ##__VA_ARGS__)


// Log Objective-C with LOG_FLAG_ERROR
#define MSLogErrorInContext(ctx, frmt, ...) \
    MSLOG_OBJC_MAYBE(LOG_ASYNC_ERROR, ddLogLevel,  LOG_FLAG_ERROR, ctx, frmt, ##__VA_ARGS__)

// Log Objective-C with LOG_FLAG_WARN
#define MSLogWarnInContext(ctx, frmt, ...) \
    MSLOG_OBJC_MAYBE(LOG_ASYNC_WARN, ddLogLevel, LOG_FLAG_WARN, ctx, frmt, ##__VA_ARGS__)

// Log Objective-C with LOG_FLAG_INFO
#define MSLogInfoInContext(ctx, frmt, ...) \
    MSLOG_OBJC_MAYBE(LOG_ASYNC_INFO, ddLogLevel, LOG_FLAG_INFO, ctx, frmt, ##__VA_ARGS__)

// Log Objective-C with LOG_FLAG_VERBOSE
#define MSLogVerboseInContext(ctx, frmt, ...) \
    MSLOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE, ddLogLevel, LOG_FLAG_VERBOSE, ctx, frmt, ##__VA_ARGS__)

// Log Objective-C with LOG_FLAG_DEBUG
#define MSLogDebugInContext(ctx, frmt, ...) \
    MSLOG_OBJC_MAYBE(LOG_ASYNC_DEBUG, ddLogLevel, LOG_FLAG_DEBUG, ctx, frmt, ##__VA_ARGS__)

// Log Objective-C with LOG_FLAG_UNITTEST
#define MSLogUnitTestInContext(ctx, frmt, ...) \
    MSLOG_OBJC_MAYBE(LOG_ASYNC_UNITTEST, ddLogLevel, LOG_FLAG_UNITTEST, ctx, frmt, ##__VA_ARGS__)

// Log C function with LOG_FLAG_ERROR
#define MSLogCErrorInContext(ctx, frmt, ...)   \
    MSLOG_C_MAYBE(LOG_ASYNC_ERROR,   ddLogLevel, LOG_FLAG_ERROR, ctx, frmt, ##__VA_ARGS__)

// Log C function with LOG_FLAG_WARN
#define MSLogCWarnInContext(ctx, frmt, ...)    \
    MSLOG_C_MAYBE(LOG_ASYNC_WARN,    ddLogLevel, LOG_FLAG_WARN, ctx, frmt, ##__VA_ARGS__)

// Log C function with LOG_FLAG_INFO
#define MSLogCInfoInContext(ctx, frmt, ...)    \
    MSLOG_C_MAYBE(LOG_ASYNC_INFO,    ddLogLevel, LOG_FLAG_INFO, ctx, frmt, ##__VA_ARGS__)

// Log C function with LOG_FLAG_VERBOSE
#define MSLogCVerboseInContext(ctx, frmt, ...) \
    MSLOG_C_MAYBE(LOG_ASYNC_VERBOSE, ddLogLevel, LOG_FLAG_VERBOSE, ctx, frmt, ##__VA_ARGS__)

// Log C function with LOG_FLAG_DEBUG
#define MSLogCDebugInContext(ctx, frmt, ...)   \
    MSLOG_C_MAYBE(LOG_ASYNC_DEBUG,   ddLogLevel, LOG_FLAG_DEBUG, ctx, frmt, ##__VA_ARGS__)

// Log C function with LOG_FLAG_UNITTEST
#define MSLogCUnitTestInContext(ctx, frmt, ...)   \
    MSLOG_C_MAYBE(LOG_ASYNC_UNITTEST,   ddLogLevel, LOG_FLAG_UNITTEST, ctx, frmt, ##__VA_ARGS__)


#define MSLogErrorInContextTag(ctx, frmt, ...)                                                         \
    MSLOG_OBJC_TAG_MAYBE(LOG_ASYNC_ERROR,                                                              \
                         ddLogLevel,                                                                   \
                         LOG_FLAG_ERROR,                                                               \
                         ctx,                                                                          \
                         (@{ MSLogObjectNameKey : CollectionSafeValue([[self shortDescription] copy]), \
                             MSLogClassNameKey  : CollectionSafeValue(ClassString([self class])) } ),  \
                         frmt,                                                                         \
                         ##__VA_ARGS__)

#define MSLogWarnInContextTag(ctx, frmt, ...)                                                          \
    MSLOG_OBJC_TAG_MAYBE(LOG_ASYNC_WARN,                                                               \
                         ddLogLevel,                                                                   \
                         LOG_FLAG_WARN,                                                                \
                         ctx,                                                                          \
                         (@{ MSLogObjectNameKey : CollectionSafeValue([[self shortDescription] copy]), \
                             MSLogClassNameKey  : CollectionSafeValue(ClassString([self class])) } ),  \
                         frmt,                                                                         \
                         ##__VA_ARGS__)

#define MSLogInfoInContextTag(ctx, frmt, ...)                                                          \
    MSLOG_OBJC_TAG_MAYBE(LOG_ASYNC_INFO,                                                               \
                         ddLogLevel,                                                                   \
                         LOG_FLAG_INFO,                                                                \
                         ctx,                                                                          \
                         (@{ MSLogObjectNameKey : CollectionSafeValue([[self shortDescription] copy]), \
                             MSLogClassNameKey  : CollectionSafeValue(ClassString([self class])) } ),  \
                         frmt,                                                                         \
                         ##__VA_ARGS__)

#define MSLogVerboseInContextTag(ctx, frmt, ...)                                                       \
    MSLOG_OBJC_TAG_MAYBE(LOG_ASYNC_VERBOSE,                                                            \
                         ddLogLevel,                                                                   \
                         LOG_FLAG_VERBOSE,                                                             \
                         ctx,                                                                          \
                         (@{ MSLogObjectNameKey : CollectionSafeValue([[self shortDescription] copy]), \
                             MSLogClassNameKey  : CollectionSafeValue(ClassString([self class])) } ),  \
                         frmt,                                                                         \
                         ##__VA_ARGS__)

#define MSLogDebugInContextTag(ctx, frmt, ...)                                                         \
    MSLOG_OBJC_TAG_MAYBE(LOG_ASYNC_DEBUG,                                                              \
                         ddLogLevel,                                                                   \
                         LOG_FLAG_DEBUG,                                                               \
                         ctx,                                                                          \
                         (@{ MSLogObjectNameKey : CollectionSafeValue([[self shortDescription] copy]), \
                             MSLogClassNameKey  : CollectionSafeValue(ClassString([self class])) } ),  \
                         frmt,                                                                         \
                         ##__VA_ARGS__)

#define MSLogCErrorInContextTag(ctx, frmt, ...)  \
    MSLOG_C_TAG_MAYBE(LOG_ASYNC_ERROR,           \
                         ddLogLevel,             \
                         LOG_FLAG_ERROR,         \
                         ctx,                    \
                         @{},                    \
                         frmt,                   \
                         ##__VA_ARGS__)

#define MSLogCWarnInContextTag(ctx, frmt, ...)   \
    MSLOG_C_TAG_MAYBE(LOG_ASYNC_WARN,            \
                         ddLogLevel,             \
                         LOG_FLAG_WARN,          \
                         ctx,                    \
                         @{},                    \
                         frmt,                   \
                         ##__VA_ARGS__)

#define MSLogCInfoInContextTag(ctx, frmt, ...)   \
    MSLOG_C_TAG_MAYBE(LOG_ASYNC_INFO,            \
                         ddLogLevel,             \
                         LOG_FLAG_INFO,          \
                         ctx,                    \
                         @{},                    \
                         frmt,                   \
                         ##__VA_ARGS__)

#define MSLogCVerboseInContextTag(ctx, frmt, ...)  \
    MSLOG_C_TAG_MAYBE(LOG_ASYNC_VERBOSE,           \
                         ddLogLevel,               \
                         LOG_FLAG_VERBOSE,         \
                         ctx,                      \
                         @{},                      \
                         frmt,                     \
                         ##__VA_ARGS__)

#define MSLogCDebugInContextTag(ctx, frmt, ...)  \
    MSLOG_C_TAG_MAYBE(LOG_ASYNC_DEBUG,           \
                         ddLogLevel,             \
                         LOG_FLAG_DEBUG,         \
                         ctx,                    \
                         @{},                    \
                         frmt,                   \
                         ##__VA_ARGS__)


#define MSLogErrorInContextIf(expr, ctx, frmt, ...)                  \
    do                                                               \
    {                                                                \
        if ((expr))                                                  \
            MSLOG_OBJC_MAYBE(LOG_ASYNC_ERROR,                        \
                             ddLogLevel,                             \
                             LOG_FLAG_ERROR,                         \
                             ctx,                                    \
                             frmt,                                   \
                             ##__VA_ARGS__);                         \
    }                                                                \
    while (0)

#define MSLogWarnInContextIf(expr, ctx, frmt, ...)                   \
    do                                                               \
    {                                                                \
        if ((expr))                                                  \
            MSLOG_OBJC_MAYBE(LOG_ASYNC_WARN,                         \
                             ddLogLevel,                             \
                             LOG_FLAG_WARN,                          \
                             ctx,                                    \
                             frmt,                                   \
                             ##__VA_ARGS__);                         \
    }                                                                \
    while (0)

#define MSLogInfoInContextIf(expr, ctx, frmt, ...)                   \
    do                                                               \
    {                                                                \
        if ((expr))                                                  \
            MSLOG_OBJC_MAYBE(LOG_ASYNC_INFO,                         \
                             ddLogLevel,                             \
                             LOG_FLAG_INFO,                          \
                             ctx,                                    \
                             frmt,                                   \
                             ##__VA_ARGS__);                         \
    }                                                                \
    while (0)

#define MSLogVerboseInContextIf(expr, ctx, frmt, ...)                \
    do                                                               \
    {                                                                \
        if ((expr))                                                  \
            MSLOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE,                      \
                             ddLogLevel,                             \
                             LOG_FLAG_VERBOSE,                       \
                             ctx,                                    \
                             frmt,                                   \
                             ##__VA_ARGS__);                         \
    }                                                                \
    while (0)

#define MSLogDebugInContextIf(expr, ctx, frmt, ...)                  \
    do                                                               \
    {                                                                \
        if ((expr))                                                  \
            MSLOG_OBJC_MAYBE(LOG_ASYNC_DEBUG,                        \
                             ddLogLevel,                             \
                             LOG_FLAG_DEBUG,                         \
                             ctx,                                    \
                             frmt,                                   \
                             ##__VA_ARGS__);                         \
    }                                                                \
    while (0)

#define MSLogErrorInContextTagIf(expr, ctx, frmt, ...)                                                        \
    do {                                                                                                      \
        if ((expr))                                                                                           \
            MSLOG_OBJC_TAG_MAYBE(LOG_ASYNC_ERROR,                                                             \
                                 ddLogLevel,                                                                  \
                                 LOG_FLAG_ERROR,                                                              \
                                 ctx,                                                                         \
                                 @{ MSLogObjectNameKey : CollectionSafeValue([[self shortDescription] copy]), \
                                    MSLogClassNameKey  : CollectionSafeValue(ClassString([self class])) },    \
                                 frmt,                                                                        \
                                 ##__VA_ARGS__);                                                              \
    } while (0)

#define MSLogWarnInContextTagIf(expr, ctx, frmt, ...)                                                         \
    do {                                                                                                      \
        if ((expr))                                                                                           \
            MSLOG_OBJC_TAG_MAYBE(LOG_ASYNC_WARN,                                                              \
                                 ddLogLevel,                                                                  \
                                 LOG_FLAG_WARN,                                                               \
                                 ctx,                                                                         \
                                 @{ MSLogObjectNameKey : CollectionSafeValue([[self shortDescription] copy]), \
                                    MSLogClassNameKey  : CollectionSafeValue(ClassString([self class])) },    \
                                 frmt,                                                                        \
                                 ##__VA_ARGS__);                                                              \
    } while (0)

#define MSLogInfoInContextTagIf(expr, ctx, frmt, ...)                                                         \
    do {                                                                                                      \
        if ((expr))                                                                                           \
            MSLOG_OBJC_TAG_MAYBE(LOG_ASYNC_INFO,                                                              \
                                 ddLogLevel,                                                                  \
                                 LOG_FLAG_INFO,                                                               \
                                 ctx,                                                                         \
                                 @{ MSLogObjectNameKey : CollectionSafeValue([[self shortDescription] copy]), \
                                    MSLogClassNameKey  : CollectionSafeValue(ClassString([self class])) },    \
                                 frmt,                                                                        \
                                 ##__VA_ARGS__);                                                              \
    } while (0)

#define MSLogVerboseInContextTagIf(expr, ctx, frmt, ...)                                                      \
    do {                                                                                                      \
        if ((expr))                                                                                           \
            MSLOG_OBJC_TAG_MAYBE(LOG_ASYNC_VERBOSE,                                                           \
                                 ddLogLevel,                                                                  \
                                 LOG_FLAG_VERBOSE,                                                            \
                                 ctx,                                                                         \
                                 @{ MSLogObjectNameKey : CollectionSafeValue([[self shortDescription] copy]), \
                                    MSLogClassNameKey  : CollectionSafeValue(ClassString([self class])) },    \
                                 frmt,                                                                        \
                                 ##__VA_ARGS__);                                                              \
    } while (0)

#define MSLogDebugInContextTagIf(expr, ctx, frmt, ...)                                                         \
    do {                                                                                                       \
        if ((expr))                                                                                            \
            MSLOG_OBJC_TAG_MAYBE(LOG_ASYNC_DEBUG,                                                              \
                                 ddLogLevel,                                                                  \
                                 LOG_FLAG_DEBUG,                                                               \
                                 ctx,                                                                          \
                                 (@{ MSLogObjectNameKey : CollectionSafeValue([[self shortDescription] copy]), \
                                     MSLogClassNameKey  : CollectionSafeValue(ClassString([self class])) }),   \
                                 frmt,                                                                         \
                                 ##__VA_ARGS__);                                                               \
    } while (0)

#define MSLogCErrorInContextIf(expr, ctx, frmt, ...) \
    do                                               \
    {                                                \
        if ((expr))                                  \
            MSLOG_C_MAYBE(LOG_ASYNC_ERROR,           \
                          ddLogLevel,                \
                          LOG_FLAG_ERROR,            \
                          ctx,                       \
                          frmt,                      \
                          ##__VA_ARGS__);            \
    }                                                \
    while (0)

#define MSLogCWarnInContextIf(expr, ctx, frmt, ...) \
    do                                              \
    {                                               \
        if ((expr))                                 \
            MSLOG_C_MAYBE(LOG_ASYNC_WARN,           \
                          ddLogLevel,               \
                          LOG_FLAG_WARN,            \
                          ctx,                      \
                          frmt,                     \
                          ##__VA_ARGS__);           \
    }                                               \
    while (0)

#define MSLogCInfoInContextIf(expr, ctx, frmt, ...) \
    do                                              \
    {                                               \
        if ((expr))                                 \
            MSLOG_C_MAYBE(LOG_ASYNC_INFO,           \
                          ddLogLevel,               \
                          LOG_FLAG_INFO,            \
                          ctx,                      \
                          frmt,                     \
                          ##__VA_ARGS__);           \
    }                                               \
    while (0)

#define MSLogCVerboseInContextIf(expr, ctx, frmt, ...) \
    do                                                 \
    {                                                  \
        if ((expr))                                    \
            MSLOG_C_MAYBE(LOG_ASYNC_VERBOSE,           \
                          ddLogLevel,                  \
                          LOG_FLAG_VERBOSE,            \
                          ctx,                         \
                          frmt,                        \
                          ##__VA_ARGS__);              \
    }                                                  \
    while (0)

#define MSLogCDebugInContextIf(expr, ctx, frmt, ...) \
    do                                               \
    {                                                \
        if ((expr))                                  \
            MSLOG_C_MAYBE(LOG_ASYNC_DEBUG,           \
                          ddLogLevel,                \
                          LOG_FLAG_DEBUG,            \
                          ctx,                       \
                          frmt,                      \
                          ##__VA_ARGS__);            \
    }                                                \
    while (0)

#define MSLogCErrorInContextTagIf(expr, ctx, frmt, ...) \
    do                                                  \
    {                                                   \
        if ((expr))                                     \
            MSLOG_C_TAG_MAYBE(LOG_ASYNC_ERROR,          \
                              ddLogLevel,               \
                              LOG_FLAG_ERROR,           \
                              ctx,                      \
                              nil,                      \
                              frmt, ##__VA_ARGS__);     \
    }                                                   \
    while (0)

#define MSLogCWarnInContextTagIf(expr, ctx, frmt, ...) \
    do                                                 \
    {                                                  \
        if ((expr))                                    \
            MSLOG_C_TAG_MAYBE(LOG_ASYNC_WARN,          \
                              ddLogLevel,              \
                              LOG_FLAG_WARN,           \
                              ctx,                     \
                              nil,                     \
                              frmt, ##__VA_ARGS__);    \
    }                                                  \
    while (0)

#define MSLogCInfoInContextTagIf(expr, ctx, frmt, ...) \
    do                                                 \
    {                                                  \
        if ((expr))                                    \
            MSLOG_C_TAG_MAYBE(LOG_ASYNC_INFO,          \
                              ddLogLevel,              \
                              LOG_FLAG_INFO,           \
                              ctx,                     \
                              nil,                     \
                              frmt, ##__VA_ARGS__);    \
    }                                                  \
    while (0)

#define MSLogCVerboseInContextTagIf(expr, ctx, frmt, ...) \
    do                                                    \
    {                                                     \
        if ((expr))                                       \
            MSLOG_C_TAG_MAYBE(LOG_ASYNC_VERBOSE,          \
                              ddLogLevel,                 \
                              LOG_FLAG_VERBOSE,           \
                              ctx,                        \
                              nil,                        \
                              frmt, ##__VA_ARGS__);       \
    }                                                     \
    while (0)

#define MSLogCDebugInContextTagIf(expr, ctx, frmt, ...) \
    do                                                  \
    {                                                   \
        if ((expr))                                     \
            MSLOG_C_TAG_MAYBE(LOG_ASYNC_DEBUG,          \
                              ddLogLevel,               \
                              LOG_FLAG_DEBUG,           \
                              ctx,                      \
                              nil,                      \
                              frmt, ##__VA_ARGS__);     \
    }                                                   \
    while (0)

#define MSLogError(frmt, ...)    \
    MSLogErrorInContext(  msLogContext, frmt, ##__VA_ARGS__)
#define MSLogWarn(frmt, ...)     \
    MSLogWarnInContext(   msLogContext, frmt, ##__VA_ARGS__)
#define MSLogInfo(frmt, ...)     \
    MSLogInfoInContext(   msLogContext, frmt, ##__VA_ARGS__)
#define MSLogVerbose(frmt, ...)  \
    MSLogVerboseInContext(msLogContext, frmt, ##__VA_ARGS__)
#define MSLogDebug(frmt, ...)    \
    MSLogDebugInContext(  msLogContext, frmt, ##__VA_ARGS__)

#define MSLogCError(frmt, ...)   \
    MSLogCErrorInContext(  msLogContext, frmt, ##__VA_ARGS__)
#define MSLogCWarn(frmt, ...)    \
    MSLogCWarnInContext(   msLogContext, frmt, ##__VA_ARGS__)
#define MSLogCInfo(frmt, ...)    \
    MSLogCInfoInContext(   msLogContext, frmt, ##__VA_ARGS__)
#define MSLogCVerbose(frmt, ...) \
    MSLogCVerboseInContext(msLogContext, frmt, ##__VA_ARGS__)
#define MSLogCDebug(frmt, ...)   \
    MSLogCDebugInContext(  msLogContext, frmt, ##__VA_ARGS__)

#define MSLogErrorTag(frmt, ...)    \
    MSLogErrorInContextTag(  msLogContext, frmt, ##__VA_ARGS__)
#define MSLogWarnTag(frmt, ...)     \
    MSLogWarnInContextTag(   msLogContext, frmt, ##__VA_ARGS__)
#define MSLogInfoTag(frmt, ...)     \
    MSLogInfoInContextTag(   msLogContext, frmt, ##__VA_ARGS__)
#define MSLogVerboseTag(frmt, ...)  \
    MSLogVerboseInContextTag(msLogContext, frmt, ##__VA_ARGS__)
#define MSLogDebugTag(frmt, ...)    \
    MSLogDebugInContextTag(  msLogContext, frmt, ##__VA_ARGS__)

#define MSLogCErrorTag(frmt, ...)   \
    MSLogCErrorInContextTag(  msLogContext, frmt, ##__VA_ARGS__)
#define MSLogCWarnTag(frmt, ...)    \
    MSLogCWarnInContextTag(   msLogContext, frmt, ##__VA_ARGS__)
#define MSLogCInfoTag(frmt, ...)    \
    MSLogCInfoInContextTag(   msLogContext, frmt, ##__VA_ARGS__)
#define MSLogCVerboseTag(frmt, ...) \
    MSLogCVerboseInContextTag(msLogContext, frmt, ##__VA_ARGS__)
#define MSLogCDebugTag(frmt, ...)   \
    MSLogCDebugInContextTag(  msLogContext, frmt, ##__VA_ARGS__)

#define MSLogErrorIf(expr, frmt, ...)    \
    MSLogErrorInContextIf(  expr, msLogContext,  frmt, ##__VA_ARGS__)
#define MSLogWarnIf(expr, frmt, ...)     \
    MSLogWarnInContextIf(   expr, msLogContext,  frmt, ##__VA_ARGS__)
#define MSLogInfoIf(expr, frmt, ...)     \
    MSLogInfoInContextIf(   expr, msLogContext,  frmt, ##__VA_ARGS__)
#define MSLogVerboseIf(expr, frmt, ...)  \
    MSLogVerboseInContextIf(expr, msLogContext,  frmt, ##__VA_ARGS__)
#define MSLogDebugIf(expr, frmt, ...)    \
    MSLogDebugInContextIf(  expr, msLogContext,  frmt, ##__VA_ARGS__)

#define MSLogErrorTagIf(expr, frmt, ...)    \
    MSLogErrorInContextTagIf(  expr, msLogContext,  frmt, ##__VA_ARGS__)
#define MSLogWarnTagIf(expr, frmt, ...)     \
    MSLogWarnInContextTagIf(   expr, msLogContext,  frmt, ##__VA_ARGS__)
#define MSLogInfoTagIf(expr, frmt, ...)     \
    MSLogInfoInContextTagIf(   expr, msLogContext,  frmt, ##__VA_ARGS__)
#define MSLogVerboseTagIf(expr, frmt, ...)  \
    MSLogVerboseInContextTagIf(expr, msLogContext,  frmt, ##__VA_ARGS__)
#define MSLogDebugTagIf(expr, frmt, ...)    \
    MSLogDebugInContextTagIf(  expr, msLogContext,  frmt, ##__VA_ARGS__)

#define MSLogCErrorIf(expr, frmt, ...)   \
    MSLogCErrorInContextIf(  expr, msLogContext, frmt, ##__VA_ARGS__)
#define MSLogCWarnIf(expr, frmt, ...)    \
    MSLogCWarnInContextIf(   expr, msLogContext, frmt, ##__VA_ARGS__)
#define MSLogCInfoIf(expr, frmt, ...)    \
    MSLogCInfoInContextIf(   expr, msLogContext, frmt, ##__VA_ARGS__)
#define MSLogCVerboseIf(expr, frmt, ...) \
    MSLogCVerboseInContextIf(expr, msLogContext, frmt, ##__VA_ARGS__)
#define MSLogCDebugIf(expr, frmt, ...)   \
    MSLogCDebugInContextIf(  expr, msLogContext, frmt, ##__VA_ARGS__)

#define LOG_BLOCK_MAYBE(lvl, flg, ctx, block) \
    do { if (lvl & flg) { [[MSLog loggingQueue] addOperationWithBlock:block]; } } while(0)

#define MSLogBlockError(block)                              \
    LOG_BLOCK_MAYBE(ddLogLevel,                             \
                    LOG_FLAG_ERROR,                         \
                    msLogContext,                           \
                    block)

#define MSLogBlockWarn(block)                               \
    LOG_BLOCK_MAYBE(ddLogLevel,                             \
                    LOG_FLAG_WARN,                          \
                    msLogContext,                           \
                    block)

#define MSLogBlockDebug(block)                              \
    LOG_BLOCK_MAYBE(ddLogLevel,                             \
                    LOG_FLAG_DEBUG,                         \
                    msLogContext,                           \
                    block)


#define MSLogBlockInfo(block)                               \
    LOG_BLOCK_MAYBE(ddLogLevel,                             \
                    LOG_FLAG_INFO,                          \
                    msLogContext,                           \
                    block)

#define MSLogBlockVerbose(block)                            \
    LOG_BLOCK_MAYBE(ddLogLevel,                             \
                    LOG_FLAG_VERBOSE,                       \
                    msLogContext,                           \
                    block)

#define MSLogBlockError(block)                              \
    LOG_BLOCK_MAYBE(ddLogLevel,                             \
                    LOG_FLAG_ERROR,                         \
                    msLogContext,                           \
                    block)
#define MSAggrogateErrorMessage(error)                                                               \
    ({                                                                                               \
        NSMutableString * errorMessage = [@"MSHandleErrors--\n" mutableCopy];                        \
        if ([error isKindOfClass:[MSError class]])                                                   \
        {                                                                                            \
            NSString * message = ((MSError*)error).message;                                          \
            if (message) [errorMessage appendFormat:@"!!! %@ !!!", message];                         \
            error = ((MSError*)error).error;                                                         \
        }                                                                                            \
                                                                                                     \
        NSDictionary  *userInfo = [error userInfo];                                                  \
        for (NSArray *detailedError in [userInfo allValues])                                         \
        {                                                                                            \
            if ([detailedError isKindOfClass:[NSArray class]])                                       \
            {                                                                                        \
                for (NSError *e in detailedError)                                                    \
                {                                                                                    \
                    if ([e respondsToSelector:@selector(userInfo)])                                  \
                        [errorMessage appendFormat:@"Error Details: %@\n", [e userInfo]];            \
                                                                                                     \
                    else                                                                             \
                        [errorMessage appendFormat:@"Error Details: %@\n", e];                       \
                }                                                                                    \
            }                                                                                        \
                                                                                                     \
            else                                                                                     \
                [errorMessage appendFormat:@"Error: %@", detailedError];                             \
        }                                                                                            \
        [errorMessage appendFormat:@"Error Message: %@\n", [error localizedDescription]];            \
        [errorMessage appendFormat:@"Error Domain: %@\n", [error domain]];                           \
        [errorMessage appendFormat:@"Recovery Suggestion: %@", [error localizedRecoverySuggestion]]; \
        [errorMessage replaceOccurrencesOfString:@"\\\\"                                             \
                                      withString:@"\\"                                               \
                                         options:0                                                   \
                                           range:NSMakeRange(0,errorMessage.length)];                \
        errorMessage;\
    })

#define MSHandleErrors(error)  MSLogErrorTag(@"%@", MSAggrogateErrorMessage(error))
#define MSHandleCErrors(error) MSLogCErrorTag(@"%@", MSAggrogateErrorMessage(error))
/*
\
    do {                                                                                             \
        NSMutableString * errorMessage = [@"MSHandleErrors--\n" mutableCopy];                        \
        if ([error isKindOfClass:[MSError class]])                                                   \
        {                                                                                            \
            NSString * message = ((MSError*)error).message;                                          \
            if (message) [errorMessage appendFormat:@"!!! %@ !!!", message];                         \
            error = ((MSError*)error).error;                                                         \
        }                                                                                            \
                                                                                                     \
        NSDictionary  *userInfo = [error userInfo];                                                  \
        for (NSArray *detailedError in [userInfo allValues])                                         \
        {                                                                                            \
            if ([detailedError isKindOfClass:[NSArray class]])                                       \
            {                                                                                        \
                for (NSError *e in detailedError)                                                    \
                {                                                                                    \
                    if ([e respondsToSelector:@selector(userInfo)])                                  \
                        [errorMessage appendFormat:@"Error Details: %@\n", [e userInfo]];            \
                                                                                                     \
                    else                                                                             \
                        [errorMessage appendFormat:@"Error Details: %@\n", e];                       \
                }                                                                                    \
            }                                                                                        \
                                                                                                     \
            else                                                                                     \
                [errorMessage appendFormat:@"Error: %@", detailedError];                             \
        }                                                                                            \
        [errorMessage appendFormat:@"Error Message: %@\n", [error localizedDescription]];            \
        [errorMessage appendFormat:@"Error Domain: %@\n", [error domain]];                           \
        [errorMessage appendFormat:@"Recovery Suggestion: %@", [error localizedRecoverySuggestion]]; \
        MSLogErrorTag(@"%@", errorMessage);                                                          \
    }                                                                                                \
    while(0)

*/

@interface MSLog : NSObject

+ (void)addDefaultFileLoggerForContext:(NSUInteger)context directory:(NSString *)directory;
+ (DDFileLogger *)defaultFileLoggerForContext:(NSUInteger)context directory:(NSString *)directory;
+ (void)addTTYLogger;
+ (void)addASLLogger;
+ (void)addTaggingTTYLogger;
+ (void)addTaggingASLLogger;
+ (NSString *)defaultLogDirectory;
+ (NSOperationQueue const *)loggingQueue;

+ (BOOL)isRegisteredClass:(Class)class;

@end


@protocol MSRegisteredDynamicLogging <DDRegisteredDynamicLogging>

/**
 * Implement these methods to allow a file's log level to be managed from a central location.
 *
 * This is useful if you'd like to be able to change log levels for various parts
 * of your code from within the running application.
 *
 * Imagine pulling up the settings for your application,
 * and being able to configure the logging level on a per file basis.
 *
 * The implementation can be very straight-forward:
 *
 * + (int)ddLogLevel
 * {
 *     return ddLogLevel;
 * }
 *
 * + (void)ddSetLogLevel:(int)logLevel
 * {
 *     ddLogLevel = logLevel;
 * }
 **/

+ (int)msLogContext;
+ (void)msSetLogContext:(int)logContext;

@end

@interface MSLogMessage : DDLogMessage {
}

@end

@interface MSFileLogger : DDFileLogger

@property (nonatomic, assign, readwrite) BOOL reopenLastFile;

@end

@interface MSLogFileManager : DDLogFileManagerDefault
@property (nonatomic, copy, readonly   ) NSString * currentLogFile;
@property (nonatomic, copy, readwrite  ) NSString * fileNamePrefix;

- (void)setLogsDirectory:(NSString *)logsDirectory;

@end

@interface MSLogFormatter : NSObject <DDLogFormatter>

+ (MSLogFormatter *)logFormatterForContext:(int)context;
+ (MSLogFormatter *)taggingLogFormatterForContext:(int)context;

- (id)initWithContext:(int)context;

@property (nonatomic, assign)                                 int        context;
@property (nonatomic, getter = shouldIncludeLogLevel)         BOOL       includeLogLevel;
@property (nonatomic, getter = shouldIncludeContext)          BOOL       includeContext;
@property (nonatomic, getter = shouldIncludeTimestamp)        BOOL       includeTimestamp;
@property (nonatomic, getter = shouldAddReturnAfterPrefix)    BOOL       addReturnAfterPrefix;
@property (nonatomic, getter = shouldAddReturnAfterSEL)       BOOL       addReturnAfterSEL;
@property (nonatomic, getter = shouldAddReturnAfterObj)       BOOL       addReturnAfterObj;
@property (nonatomic, getter = shouldAddReturnAfterMessage)   BOOL       addReturnAfterMessage;
@property (nonatomic, getter = shouldCollapseTrailingReturns) BOOL       collapseTrailingReturns;
@property (nonatomic, getter = shouldIndentMessageBody)       BOOL       indentMessageBody;
@property (nonatomic, getter = shouldIncludeSEL)              BOOL       includeSEL;
@property (nonatomic, getter = shouldIncludeObjectName)       BOOL       includeObjectName;
@property (nonatomic, copy)                                   NSString * includePrompt;

@end

@interface MSASLFileLogger : DDAbstractLogger <DDLogger>

- (id)initWithLogFormatter:(MSLogFormatter *)logFormatter filePath:(NSString *)filePath;
@end
