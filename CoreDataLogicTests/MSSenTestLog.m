//
//  MSSenTestLog.m
//  Remote
//
//  Created by Jason Cardwell on 4/16/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSSenTestLog.h"
#import <MagicalRecord/MagicalRecord.h>
#import "CoreDataManager.h"

//static const int ddLogLevel   = LOG_LEVEL_ERROR;
//static const int msLogContext = LOG_CONTEXT_UNITTEST;

static BOOL loggersAttached = NO;

@implementation MSSenTestLog

+ (void)testSuiteDidStart:(NSNotification *)aNotification
{
    if (!loggersAttached) { [self attachLoggers]; loggersAttached = YES; }
    [super testSuiteDidStart:aNotification];
}

+ (void)attachLoggers
{
    [MSLog addTaggingTTYLogger];
    DDTTYLogger * ttyLogger = [DDTTYLogger sharedInstance];
    assert(ttyLogger);
    assert([ttyLogger colorsEnabled]);
    UIColor * testColor          = [UIColor colorWithR:0    G:0   B:0   A:255];
    UIColor * testPassedColor    = [UIColor colorWithR:78   G:115 B:0   A:255];
    UIColor * testFailedColor    = [UIColor colorWithR:217  G:30  B:0   A:255];
    UIColor * testInfoColor      = [UIColor colorWithR:150  G:150 B:150 A:255];
    UIColor * magicalRecordColor = [UIColor colorWithR:105  G:47  B:156 A:255];

    [ttyLogger setForegroundColor:testColor
                  backgroundColor:nil
                          forFlag:LOG_FLAG_UNITTEST
                          context:LOG_CONTEXT_UNITTEST];

    [ttyLogger setForegroundColor:testPassedColor
                  backgroundColor:nil
                          forFlag:LOG_FLAG_UNITTESTPASS
                          context:LOG_CONTEXT_UNITTEST];

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

    NSString * logsDirectory = $(@"%@/CoreDataTests", [MSLog defaultLogDirectory]);
    [MSLog addDefaultFileLoggerForContext:LOG_CONTEXT_COREDATATESTS directory:logsDirectory];

    // register log handler
    LogHandlerBlock handler = ^(id _self, id object, NSString * format, va_list args)
    {
        if (format)
        {
            NSString * message = [[NSString alloc] initWithFormat:format arguments:args];
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
    [MagicalRecord setLogHandler:handler];
    [MagicalRecord ddSetLogLevel:LOG_LEVEL_UNITTEST];
}

+ (void)testLogWithFormat:(NSString *)format, ...
{
    va_list args;
    if (format)
    {
        va_start(args, format);
        [self testLogWithFormat:format arguments:args];
        va_end(args);
    }    
}

+ (void)testLogWithFormat:(NSString *)format arguments:(va_list)arguments
{
    NSString * message = [[NSString alloc] initWithFormat:format arguments:arguments];
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
        format:format
          args:arguments];
}

@end
