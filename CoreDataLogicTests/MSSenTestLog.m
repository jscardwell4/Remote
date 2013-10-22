//
//  MSSenTestLog.m
//  Remote
//
//  Created by Jason Cardwell on 4/16/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSSenTestLog.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "CoreDataManager.h"

static int ddLogLevel   = LOG_LEVEL_ERROR;
static const int msLogContext = LOG_CONTEXT_UNITTEST;
#pragma unused(ddLogLevel,msLogContext)

static BOOL loggersAttached_ = NO;

static MSFileLogger * baseFileLogger_   = nil;
static MSFileLogger * bundleFileLogger_ = nil;
static MSFileLogger * suiteFileLogger_  = nil;
static MSFileLogger * testFileLogger_   = nil;

static SenTestSuiteRun  * bundleTestSuiteRun_ = nil;
static SenTestSuiteRun  * caseTestSuiteRun_   = nil;

static MSLogFileManager * baseFileManager_    = nil;
static MSLogFileManager * bundleFileManager_  = nil;
static MSLogFileManager * suiteFileManager_   = nil;
static MSLogFileManager * testFileManager_    = nil;

static NSString         * bundleName_         = nil;
static NSString         * suiteName_          = nil;
static NSString         * testName_           = nil;

@implementation MSSenTestLog

+ (void)testSuiteDidStart:(NSNotification *)aNotification
{
    // Make sure loggers have been added
    if (!loggersAttached_) { [self attachLoggers]; loggersAttached_ = YES; }

    // Suffix for ocunit test bundle suite runs
    static NSString const * bundleSuiteSuffix = @".octest(Tests)";

    // Get the name of the suit run that has started
    SenTestSuiteRun * testSuiteRun = (SenTestSuiteRun*)[aNotification run];
    SenTest         * test         = [testSuiteRun test];
    NSString        * testName     = [test name];


    // Update the log directory if suite is from a test bundle
    if ([testName hasSuffix:(NSString *)bundleSuiteSuffix])
    {
        bundleTestSuiteRun_ = testSuiteRun;
        bundleName_ = [[testName lastPathComponent]
                       stringByReplacingOccurrencesOfString:(NSString *)bundleSuiteSuffix
                       withString:@""];
        bundleFileManager_ = [[MSLogFileManager alloc]
                              initWithLogsDirectory:[[baseFileManager_ logsDirectory]
                                                     stringByAppendingPathComponent:bundleName_]];
        bundleFileManager_.maximumNumberOfLogFiles = 5;

        ((MSLogFormatter *)baseFileLogger_.logFormatter).context = -1;
        if (bundleFileLogger_) [DDLog removeLogger:bundleFileLogger_];
        bundleFileLogger_ = [[MSFileLogger alloc] initWithLogFileManager:bundleFileManager_];
        bundleFileLogger_.rollingFrequency = 0;
        bundleFileLogger_.maximumFileSize  = 0;
        bundleFileLogger_.logFormatter = [MSLogFormatter taggingLogFormatterForContext:LOG_CONTEXT_FILE];
        [DDLog addLogger:bundleFileLogger_];
    }

    else if (![testName hasSubstring:@" "])
    {
        caseTestSuiteRun_ = testSuiteRun;
        suiteName_ = testName;


        suiteFileManager_ = [[MSLogFileManager alloc]
                              initWithLogsDirectory:[[bundleFileManager_ logsDirectory]
                                                     stringByAppendingPathComponent:suiteName_]];
        suiteFileManager_.maximumNumberOfLogFiles = 5;
        ((MSLogFormatter *)bundleFileLogger_.logFormatter).context = -1;
        if (suiteFileLogger_) [DDLog removeLogger:suiteFileLogger_];
        suiteFileLogger_ = [[MSFileLogger alloc] initWithLogFileManager:suiteFileManager_];
        suiteFileLogger_.rollingFrequency = 0;
        suiteFileLogger_.maximumFileSize  = 0;
        suiteFileLogger_.logFormatter = [MSLogFormatter taggingLogFormatterForContext:LOG_CONTEXT_FILE];
        [DDLog addLogger:suiteFileLogger_];
    }


    [super testSuiteDidStart:aNotification];
}

+ (void)testSuiteDidStop:(NSNotification *)aNotification
{
    // Get the name of the suit run that has started
    SenTestSuiteRun * testSuiteRun = (SenTestSuiteRun*)[aNotification run];

    if (testSuiteRun == caseTestSuiteRun_)
    {
      [DDLog removeLogger:suiteFileLogger_];
      suiteFileLogger_ = nil;
      ((MSLogFormatter *)bundleFileLogger_.logFormatter).context = LOG_CONTEXT_FILE;
    }

    else if (testSuiteRun == bundleTestSuiteRun_)
    {
        [DDLog removeLogger:bundleFileLogger_];
        bundleFileLogger_ = nil;
        ((MSLogFormatter *)baseFileLogger_.logFormatter).context = LOG_CONTEXT_FILE;
    }

    [super testSuiteDidStop:aNotification];
}

+ (void)testCaseDidStart:(NSNotification *)aNotification
{
    SenTestRun * testRun = (SenTestRun *)[aNotification run];
    testName_ = [[[testRun test] name] stringByMatchingFirstOccurrenceOfRegEx:@"test([a-zA-Z0-9_]+)"
                                                                      capture:1];
    testFileManager_ = [[MSLogFileManager alloc]
                         initWithLogsDirectory:[[suiteFileManager_ logsDirectory]
                                                stringByAppendingPathComponent:testName_]];
    testFileManager_.maximumNumberOfLogFiles = 5;
    ((MSLogFormatter *)suiteFileLogger_.logFormatter).context = -1;
    if (testFileLogger_) [DDLog removeLogger:testFileLogger_];
    testFileLogger_ = [[MSFileLogger alloc] initWithLogFileManager:testFileManager_];
    testFileLogger_.rollingFrequency = 0;
    testFileLogger_.maximumFileSize  = 0;
    testFileLogger_.logFormatter = [MSLogFormatter taggingLogFormatterForContext:LOG_CONTEXT_FILE];
    [DDLog addLogger:testFileLogger_];

    [super testCaseDidStart:aNotification];
}

+ (void)testCaseDidStop:(NSNotification *)aNotification
{
    [DDLog removeLogger:testFileLogger_];
    testFileLogger_ = nil;
    ((MSLogFormatter *)suiteFileLogger_.logFormatter).context = LOG_CONTEXT_FILE;

    [super testCaseDidStop:aNotification];
}

+ (NSString *)baseLogDirectory
{
    static NSString const * baseLogDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError * error = nil;
        NSURL * libraryDirectory = [FileManager URLForDirectory:NSLibraryDirectory
                                                       inDomain:NSUserDomainMask
                                              appropriateForURL:nil
                                                         create:NO
                                                          error:&error];
        if (error) MSHandleErrors(error);

        baseLogDirectory = [[libraryDirectory path]
                            stringByAppendingPathComponent:@"Logs/com.moondeerstudios"];

    });
    return (NSString *)baseLogDirectory;
}

+ (void)attachLoggers
{
    ////////////////////////////////////////////////////////////////////////////////
    // Setup Console Logging
    ////////////////////////////////////////////////////////////////////////////////

    // Get the shared TTY instance and enable color output
    DDTTYLogger * ttyLogger = [DDTTYLogger sharedInstance];
    [ttyLogger setColorsEnabled:YES];

    // Establish the colors to be used
    UIColor * testColor          = [UIColor colorWithR:0    G:84  B:147 A:255];
    UIColor * testPassedColor    = [UIColor colorWithR:78   G:115 B:0   A:255];
    UIColor * testFailedColor    = [UIColor colorWithR:217  G:30  B:0   A:255];
    UIColor * testInfoColor      = [UIColor colorWithR:150  G:150 B:150 A:255];
    UIColor * magicalRecordColor = [UIColor colorWithR:105  G:47  B:156 A:255];

    // Set foreground for generic unit test output
    [ttyLogger setForegroundColor:testColor
                  backgroundColor:nil
                          forFlag:LOG_FLAG_UNITTEST
                          context:LOG_CONTEXT_UNITTEST];

    // Set the foreground for passing unit test output
    [ttyLogger setForegroundColor:testPassedColor
                  backgroundColor:nil
                          forFlag:LOG_FLAG_UNITTESTPASS
                          context:LOG_CONTEXT_UNITTEST];

    // Set the foreground for failing unit test output
    [ttyLogger setForegroundColor:testFailedColor
                  backgroundColor:nil
                          forFlag:LOG_FLAG_UNITTESTFAIL
                          context:LOG_CONTEXT_UNITTEST];

    [ttyLogger setForegroundColor:testFailedColor
                  backgroundColor:nil
                          forFlag:LOG_FLAG_ERROR
                          context:(LOG_CONTEXT_COREDATA|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE)];

    [ttyLogger setForegroundColor:testFailedColor
                  backgroundColor:nil
                          forFlag:LOG_FLAG_ERROR
                          context:LOG_CONTEXT_UNITTEST];

    [ttyLogger setForegroundColor:testInfoColor
                  backgroundColor:nil
                          forFlag:LOG_FLAG_INFO
                          context:LOG_CONTEXT_UNITTEST];

    [ttyLogger setForegroundColor:magicalRecordColor
                  backgroundColor:nil
                          forFlag:LOG_FLAG_MAGICALRECORD
                          context:LOG_CONTEXT_UNITTEST];

    // Create the log formatter
    MSLogFormatter * formatter =  [MSLogFormatter logFormatterForContext:LOG_CONTEXT_TTY];
    formatter.includeTimestamp        = NO;
    formatter.addReturnAfterPrefix    = NO;
    formatter.includeObjectName       = NO;
    formatter.includeSEL              = NO;
    formatter.addReturnAfterSEL       = NO;
    formatter.addReturnAfterObj       = NO;
    formatter.addReturnAfterMessage   = NO;
    formatter.collapseTrailingReturns = YES;
    formatter.includeLogLevel         = NO;
    formatter.indentMessageBody       = NO;
    formatter.includePrompt           = @">>>";

    // Set the formatter for the tty logger
    ttyLogger.logFormatter = formatter;

    // Add the logger
    [DDLog addLogger:ttyLogger];

    ////////////////////////////////////////////////////////////////////////////////
    // Setup File Logging
    ////////////////////////////////////////////////////////////////////////////////

    baseFileManager_ = [[MSLogFileManager alloc] initWithLogsDirectory:[self baseLogDirectory]];
    baseFileManager_.maximumNumberOfLogFiles = 5;
    baseFileLogger_ = [[MSFileLogger alloc] initWithLogFileManager:baseFileManager_];
    baseFileLogger_.rollingFrequency = 0;
    baseFileLogger_.maximumFileSize  = 0;
    baseFileLogger_.logFormatter = [MSLogFormatter taggingLogFormatterForContext:LOG_CONTEXT_FILE];
    [DDLog addLogger:baseFileLogger_];


    ////////////////////////////////////////////////////////////////////////////////
    // Setup Magical Record Logging Behavior
    ////////////////////////////////////////////////////////////////////////////////

    // Create the log handler
    LogHandlerBlock handler = ^(id _self, id object, NSString * format, va_list args)
    {
        if (format)
        {
            NSString * message = [[[NSString alloc] initWithFormat:format arguments:args]
                                  stringByReplacingOccurrencesOfString:@"\\\\"
                                                            withString:@"\\"];
            BOOL isErrorMessage = [message hasSubstring:@"Error"];
            int flag = (isErrorMessage ? LOG_FLAG_UNITTESTFAIL : LOG_FLAG_MAGICALRECORD);
            int logLevel = [MagicalRecord ddLogLevel];
            if (logLevel & flag)
                [DDLog log:YES
                     level:logLevel
                      flag:flag
                   context:LOG_CONTEXT_UNITTEST
                      file:__FILE__
                  function:sel_getName(_cmd)
                      line:__LINE__
                       tag:@{ MSLogClassNameKey  : CollectionSafeValue(ClassString([_self class])) }
                    format:@"%@", message];
        }
    };

    // Register the log handler
    [MagicalRecord setLogHandler:handler];

    // Set log level
    [MagicalRecord ddSetLogLevel:LOG_LEVEL_UNITTEST];
}

+ (void)testLogWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSMutableString * message = [[NSMutableString alloc] initWithFormat:format arguments:args];
    va_end(args);

    int flag = LOG_FLAG_UNITTEST;
    if ([message hasSubstring:@"failed"]||[message hasSubstring:@"error"])
        flag = LOG_FLAG_UNITTESTFAIL;
    else if ([message hasSubstring:@"' passed ("])
        flag = LOG_FLAG_UNITTESTPASS;

    [DDLog log:NO
         level:LOG_LEVEL_UNITTEST
          flag:flag
       context:LOG_CONTEXT_UNITTEST
          file:__FILE__
      function:sel_getName(_cmd)
          line:__LINE__
           tag:@{MSLogClassNameKey: ClassString([self class])}
        format:@"%@", message];
}

+ (void)testLogWithFormat:(NSString *)format arguments:(va_list)arguments
{
    [self testLogWithFormat:@"%@", [[NSString alloc] initWithFormat:format arguments:arguments]];
}

@end
