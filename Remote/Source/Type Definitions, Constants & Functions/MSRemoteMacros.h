//
// iPhontoMacros.h
// iPhonto
//
// Created by Jason Cardwell on 6/13/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#define DefaultDDLogLevel LOG_LEVEL_WARN

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lumberjack Extensions
////////////////////////////////////////////////////////////////////////////////

#define DEFAULT_LOG_CONTEXT    (0 << 0)
#define TTY_LOG_CONTEXT        (1 << 0)
#define ASL_LOG_CONTEXT        (1 << 1)
#define CONSOLE_LOG_CONTEXT    (TTY_LOG_CONTEXT|ASL_LOG_CONTEXT)
#define FILE_LOG_CONTEXT       (1 << 2)
#define EDITOR_LOG_CONTEXT     (1 << 3)
#define PAINTER_LOG_CONTEXT    (1 << 4)
#define NETWORKING_LOG_CONTEXT (1 << 5)
#define REMOTE_LOG_CONTEXT     (1 << 6)
#define COREDATA_LOG_CONTEXT   (1 << 7)
#define UITESTING_LOG_CONTEXT  (1 << 8)

#define DEFAULT_LC    DEFAULT_LOG_CONTEXT
#define TTY_LC        TTY_LOG_CONTEXT
#define ASL_LC        ASL_LOG_CONTEXT
#define FILE_LC       FILE_LOG_CONTEXT
#define EDITOR_LC     EDITOR_LOG_CONTEXT
#define PAINTER_LC    PAINTER_LOG_CONTEXT
#define NETWORKING_LC NETWORKING_LOG_CONTEXT
#define REMOTE_LC     REMOTE_LOG_CONTEXT
#define COREDATA_LC   COREDATA_LOG_CONTEXT
#define UITESTING_LC  UITESTING_LOG_CONTEXT

#define REMOTE_F_C     REMOTE_LC|TTY_LC|ASL_LC|FILE_LC
#define REMOTE_F       REMOTE_LC
#define PAINTER_F_C    PAINTER_LC|TTY_LC|ASL_LC|FILE_LC
#define PAINTER_F      PAINTER_LC
#define COREDATA_F_C   COREDATA_LC|TTY_LC|ASL_LC|FILE_LC
#define COREDATA_F     COREDATA_LC
#define NETWORKING_F_C NETWORKING_LC|TTY_LC|ASL_LC|FILE_LC
#define NETWORKING_F   NETWORKING_LC
#define EDITOR_F_C     EDITOR_LC|TTY_LC|ASL_LC|FILE_LC
#define EDITOR_F       EDITOR_LC
#define UITESTING_F_C  UITESTING_LC|TTY_LC|ASL_LC|FILE_LC
#define UITESTING_F    UITESTING_LC
#define REMOTE_C       CONSOLE_LOG_CONTEXT
#define PAINTER_C      CONSOLE_LOG_CONTEXT
#define COREDATA_C     CONSOLE_LOG_CONTEXT
#define NETWORKING_C   CONSOLE_LOG_CONTEXT
#define EDITOR_C       CONSOLE_LOG_CONTEXT
#define UITESTING_C    CONSOLE_LOG_CONTEXT

#define MSLogError(ctx, frmt, ...)    LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,    ddLogLevel, LOG_FLAG_ERROR,    ctx, frmt, ##__VA_ARGS__)
#define MSLogWarn(ctx, frmt, ...)     LOG_OBJC_MAYBE(LOG_ASYNC_WARN,     ddLogLevel, LOG_FLAG_WARN,     ctx, frmt, ##__VA_ARGS__)
#define MSLogInfo(ctx, frmt, ...)     LOG_OBJC_MAYBE(LOG_ASYNC_INFO,     ddLogLevel, LOG_FLAG_INFO,     ctx, frmt, ##__VA_ARGS__)
#define MSLogVerbose(ctx, frmt, ...)  LOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE,  ddLogLevel, LOG_FLAG_VERBOSE,  ctx, frmt, ##__VA_ARGS__)
#define MSLogDebug(ctx, frmt, ...)    LOG_OBJC_MAYBE(LOG_ASYNC_DEBUG,    ddLogLevel, LOG_FLAG_DEBUG,    ctx, frmt, ##__VA_ARGS__)
#define MSLogSelector(ctx, frmt, ...) LOG_OBJC_MAYBE(LOG_ASYNC_SELECTOR, ddLogLevel, LOG_FLAG_SELECTOR, ctx, frmt, ##__VA_ARGS__)

#define MSLogCError(ctx, frmt, ...)    LOG_C_MAYBE(LOG_ASYNC_ERROR,    ddLogLevel, LOG_FLAG_ERROR,    ctx, frmt, ##__VA_ARGS__)
#define MSLogCWarn(ctx, frmt, ...)     LOG_C_MAYBE(LOG_ASYNC_WARN,     ddLogLevel, LOG_FLAG_WARN,     ctx, frmt, ##__VA_ARGS__)
#define MSLogCInfo(ctx, frmt, ...)     LOG_C_MAYBE(LOG_ASYNC_INFO,     ddLogLevel, LOG_FLAG_INFO,     ctx, frmt, ##__VA_ARGS__)
#define MSLogCVerbose(ctx, frmt, ...)  LOG_C_MAYBE(LOG_ASYNC_VERBOSE,  ddLogLevel, LOG_FLAG_VERBOSE,  ctx, frmt, ##__VA_ARGS__)
#define MSLogCDebug(ctx, frmt, ...)    LOG_C_MAYBE(LOG_ASYNC_DEBUG,    ddLogLevel, LOG_FLAG_INFO,     ctx, frmt, ##__VA_ARGS__)
#define MSLogCSelector(ctx, frmt, ...) LOG_C_MAYBE(LOG_ASYNC_SELECTOR, ddLogLevel, LOG_FLAG_VERBOSE,  ctx, frmt, ##__VA_ARGS__)

#define MSLogErrorIf(expr, ctx, frmt, ...)    \
	do { if ((expr)) LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,    ddLogLevel, LOG_FLAG_ERROR,    ctx, frmt, ##__VA_ARGS__); } while (0)
#define MSLogWarnIf(expr, ctx, frmt, ...)     \
	do { if ((expr)) LOG_OBJC_MAYBE(LOG_ASYNC_WARN,     ddLogLevel, LOG_FLAG_WARN,     ctx, frmt, ##__VA_ARGS__); } while (0)
#define MSLogInfoIf(expr, ctx, frmt, ...)     \
	do { if ((expr)) LOG_OBJC_MAYBE(LOG_ASYNC_INFO,     ddLogLevel, LOG_FLAG_INFO,     ctx, frmt, ##__VA_ARGS__); } while (0)
#define MSLogVerboseIf(expr, ctx, frmt, ...)  \
	do { if ((expr)) LOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE,  ddLogLevel, LOG_FLAG_VERBOSE,  ctx, frmt, ##__VA_ARGS__); } while (0)
#define MSLogDebugIf(expr, ctx, frmt, ...)    \
	do { if ((expr)) LOG_OBJC_MAYBE(LOG_ASYNC_DEBUG,    ddLogLevel, LOG_FLAG_DEBUG,    ctx, frmt, ##__VA_ARGS__); } while (0)
#define MSLogSelectorIf(expr, ctx, frmt, ...) \
	do { if ((expr)) LOG_OBJC_MAYBE(LOG_ASYNC_SELECTOR, ddLogLevel, LOG_FLAG_SELECTOR, ctx, frmt, ##__VA_ARGS__); } while (0)

#define MSLogCErrorIf(expr, ctx, frmt, ...)    \
	do { if ((expr)) LOG_C_MAYBE(LOG_ASYNC_ERROR,    ddLogLevel, LOG_FLAG_ERROR,    ctx, frmt, ##__VA_ARGS__); } while (0)
#define MSLogCWarnIf(expr, ctx, frmt, ...)     \
	do { if ((expr)) LOG_C_MAYBE(LOG_ASYNC_WARN,     ddLogLevel, LOG_FLAG_WARN,     ctx, frmt, ##__VA_ARGS__); } while (0)
#define MSLogCInfoIf(expr, ctx, frmt, ...)     \
	do { if ((expr)) LOG_C_MAYBE(LOG_ASYNC_INFO,     ddLogLevel, LOG_FLAG_INFO,     ctx, frmt, ##__VA_ARGS__); } while (0)
#define MSLogCVerboseIf(expr, ctx, frmt, ...)  \
	do { if ((expr)) LOG_C_MAYBE(LOG_ASYNC_VERBOSE,  ddLogLevel, LOG_FLAG_VERBOSE,  ctx, frmt, ##__VA_ARGS__); } while (0)
#define MSLogCDebugIf(expr, ctx, frmt, ...)    \
	do { if ((expr)) LOG_C_MAYBE(LOG_ASYNC_DEBUG,    ddLogLevel, LOG_FLAG_INFO,     ctx, frmt, ##__VA_ARGS__); } while (0)
#define MSLogCSelectorIf(expr, ctx, frmt, ...) \
    do { if ((expr)) LOG_C_MAYBE(LOG_ASYNC_SELECTOR, ddLogLevel, LOG_FLAG_VERBOSE,  ctx, frmt, ##__VA_ARGS__); } while (0)

