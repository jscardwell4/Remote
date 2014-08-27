//
//  MSJSON_Tests.m
//  MSJSON Tests
//
//  Created by Jason Cardwell on 8/27/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MSLog.h"
#import "MSJSONSerialization.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@interface MSJSON_Tests : XCTestCase

@end

@implementation MSJSON_Tests

+ (void)load
{
  // Register this class as the only XCTestObserver to be used with this target
  [[NSUserDefaults standardUserDefaults] setValue:@"MSTestLog,XCTestLog"
                                           forKey:XCTestObserverClassKey];
}
- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testObjectFromJSONString
{
  NSString * filePath = $(@"%@/MSJSON Tests.json",
                          [[NSUserDefaults standardUserDefaults] stringForKey:@"XCTestedBundlePath"]);

  NSError * error = nil;
  NSStringEncoding encoding;
  NSString * fileContent = [NSString stringWithContentsOfFile:filePath
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
  printf("importObjects:\n%s\n", [[importObjects description] UTF8String]);
}

@end
