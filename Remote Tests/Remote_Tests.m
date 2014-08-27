//
//  Remote_Tests.m
//  Remote Tests
//
//  Created by Jason Cardwell on 10/13/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MSKit/MSKit.h"


static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

static MSFileLogger * fileLogger_ = nil;
@interface Remote_Tests : XCTestCase
@end

@implementation Remote_Tests

+ (NSString *)baseLogDirectory {
  static NSString const * baseLogDirectory = nil;
  static dispatch_once_t  onceToken;
  dispatch_once(&onceToken, ^{
    NSError * error = nil;
    NSURL * libraryDirectory = [FileManager URLForDirectory:NSLibraryDirectory
                                                   inDomain:NSUserDomainMask
                                          appropriateForURL:nil
                                                     create:NO
                                                      error:&error];
    MSHandleErrors(error);

    baseLogDirectory = [[libraryDirectory path]
                        stringByAppendingPathComponent:@"Logs/com.moondeerstudios"];

  });
  printf("baseLogDirectory: %s\n", [baseLogDirectory UTF8String]);
  return (NSString *)baseLogDirectory;
}

+ (void)attachLoggers {

  DDTTYLogger * logger = [DDTTYLogger sharedInstance];

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

  logger.logFormatter = formatter;
//  [DDLog addLogger:logger];


  MSLogFileManager * fileManager = [[MSLogFileManager alloc] initWithLogsDirectory:[Remote_Tests baseLogDirectory]];
  fileManager.maximumNumberOfLogFiles = 5;
  fileLogger_                         = [[MSFileLogger alloc] initWithLogFileManager:fileManager];
  fileLogger_.rollingFrequency        = 0;
  fileLogger_.maximumFileSize         = 0;
  fileLogger_.logFormatter            = [MSLogFormatter taggingLogFormatterForContext:LOG_CONTEXT_FILE];
  [DDLog addLogger:fileLogger_];

}

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
  if (!fileLogger_) [Remote_Tests attachLoggers];
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testObjectFromJSONString {
  NSString * filePath = [MainBundle pathForResource:@"Remote_Tests" ofType:@"json"];
  nsprintf(@"filePath: %@\n", filePath);

  NSError        * error = nil;
  NSStringEncoding encoding;
  NSString       * fileContent = [NSString stringWithContentsOfFile:filePath
                                                       usedEncoding:&encoding
                                                              error:&error];
  MSLogDebugInContext(LOG_CONTEXT_UNITTEST, @"fileContent:\n%@", fileContent);
  BOOL wasError = MSHandleErrors(error);
  XCTAssertFalse(wasError, @"failed to load file content");

  if (!fileContent) {
    XCTFail("cannot proceed without file content to parse");
    return;
  }

  error = nil;
  NSArray * importObjects = [MSJSONSerialization objectByParsingString:fileContent error:&error];
  MSLogDebugInContext(LOG_CONTEXT_UNITTEST, @"importObjects:\n%@", importObjects);
  wasError = MSHandleErrors(error);
  XCTAssertFalse(wasError, @"failed to parse file content");
  sleep(5);
}

@end
