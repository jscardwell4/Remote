//
//  Moonkit_Tests.m
//  Moonkit Tests
//
//  Created by Jason Cardwell on 9/17/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
@import Moonkit;

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@interface Moonkit_Tests : XCTestCase

@end

@implementation Moonkit_Tests

+ (void)initialize {
  if (self == [Moonkit_Tests class])
    [MSLog addTaggingTTYLogger];
}

- (void)testJSONParser {

  NSString * filePath = [[NSBundle bundleWithPath:UserDefaults[@"XCTestedBundlePath"]] pathForResource:@"test"
                                                                                                ofType:@"json"];
  NSError * error = nil;
  NSString * json = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
  if (MSHandleErrors(error)) XCTFail("error encountered creating json string from testfile");
  JSONParser * parser = [[JSONParser alloc] initWithString:json];

  XCTAssert(parser.string != nil, @"Pass");

  [parser parse];

}

@end
