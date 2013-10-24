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
#import "MSLogMacros.h"
#import "NSObject+MSKitAdditions.h"

// keys
MSEXTERN_KEY(MSLogClassName);
MSEXTERN_KEY(MSLogObjectName);
MSEXTERN_KEY(MSLogObject);
MSEXTERN_KEY(MSLogContext);

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

+ (int)msLogContext;
+ (void)msSetLogContext:(int)logContext;

@end

@interface MSLogMessage : DDLogMessage @end

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

/*
@interface MSASLFileLogger : DDAbstractLogger <DDLogger>

- (id)initWithLogFormatter:(MSLogFormatter *)logFormatter filePath:(NSString *)filePath;
@end
*/
