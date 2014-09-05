//
//  MSKitXML_Tests.m
//  MSKitXML Tests
//
//  Created by Jason Cardwell on 9/3/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MSDictionary.h"
#import "MSLog.h"
#import "MSKitMacros.h"

@interface MSKitXML_Tests : XCTestCase

@end

@implementation MSKitXML_Tests

- (void)testDictionaryFromXML
{
  NSString * filePath = $(@"%@/Test.xml",
                          [[NSUserDefaults standardUserDefaults] stringForKey:@"XCTestedBundlePath"]);

  NSData * xmlData = [NSData dataWithContentsOfFile:filePath];
  printf("%s\n\n", [[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding] UTF8String]);
  MSDictionary * dictionary = [MSDictionary dictionaryByParsingXML:xmlData];
  printf("%s\n", [[dictionary description] UTF8String]);
  [dictionary compress];
  printf("%s\n", [[dictionary description] UTF8String]);
}

@end
