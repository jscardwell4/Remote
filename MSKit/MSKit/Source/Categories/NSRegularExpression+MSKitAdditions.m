//
//  NSRegularExpression+MSKitAdditions.m
//  MSKit
//
//  Created by Jason Cardwell on 10/2/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "NSRegularExpression+MSKitAdditions.h"

@implementation NSRegularExpression (MSKitAdditions)

- (NSDictionary *)captureGroupsFromFirstMatchInString:(NSString *)string
											  options:(NSMatchingOptions)options
												range:(NSRange)range
												 keys:(NSArray *)keys
{
	if (!keys || keys.count != self.numberOfCaptureGroups) return nil;

	NSMutableDictionary * captureGroups = [@{} mutableCopy];
	NSTextCheckingResult * firstMatch = [self firstMatchInString:string options:options range:range];

	if (!firstMatch) return nil;

	assert(firstMatch.numberOfRanges == self.numberOfCaptureGroups + 1);
	
	for (int i = 0; i < self.numberOfCaptureGroups; i++) {
		NSRange captureRange = [firstMatch rangeAtIndex:i + 1];
		captureGroups[keys[i]] = (captureRange.location == NSNotFound
								  ? [NSNull null] :
								  [string substringWithRange:captureRange]);
	}
	
	return captureGroups;
}

@end
