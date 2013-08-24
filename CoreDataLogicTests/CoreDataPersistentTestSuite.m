//
//  CoreDataPersistentTestSuite.m
//  Remote
//
//  Created by Jason Cardwell on 4/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "CoreDataPersistentTestSuite.h"

@implementation CoreDataPersistentTestSuite

+ (id)defaultTestSuite
{
    return [super defaultTestSuite];
}

+ (id)testSuiteForBundlePath:(NSString *)bundlePath
{
    return [super testSuiteForBundlePath:bundlePath];
}

+ (id)testSuiteForTestCaseWithName:(NSString *)aName
{
    return [super testSuiteForTestCaseWithName:aName];
}

+ (id)testSuiteForTestCaseClass:(Class)aClass
{
    return [super testSuiteForTestCaseClass:aClass];
}

+ (id)testSuiteWithName:(NSString *)aName
{
    return [super testSuiteWithName:aName];
}

- (id)initWithName:(NSString *)aName
{
    return [super initWithName:aName];
}

- (void)addTest:(SenTest *)aTest
{
    [super addTest:aTest];
}

- (void)addTestsEnumeratedBy:(NSEnumerator *)anEnumerator
{
    [super addTestsEnumeratedBy:anEnumerator];
}

@end
