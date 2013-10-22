//
//  MagicalRecord.m
//
//  Created by Saul Mora on 3/11/10.
//  Copyright 2010 Magical Panda Software, LLC All rights reserved.
//


#import "MagicalRecord.h"
#import "MagicalRecordStack.h"
#import "NSPersistentStore+MagicalRecord.h"


@implementation MagicalRecord

+ (void) cleanUp
{
    [MagicalRecordStack setDefaultStack:nil];
}

+ (NSString *) defaultStoreName;
{
    NSString *defaultName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(id)kCFBundleNameKey];
    if (defaultName == nil)
    {
        defaultName = kMagicalRecordDefaultStoreFileName;
    }
    if (![defaultName hasSuffix:@"sqlite"]) 
    {
        defaultName = [defaultName stringByAppendingPathExtension:@"sqlite"];
    }

    return defaultName;
}

+ (void) initialize;
{
    if (self == [MagicalRecord class]) 
    {
#ifdef MR_SHORTHAND
        [self swizzleShorthandMethods];
#endif
    }
}

- (NSString *) version;
{
    return [[self class] version];
}

+ (NSString *) version;
{
    return @"3.0";
}

@end


