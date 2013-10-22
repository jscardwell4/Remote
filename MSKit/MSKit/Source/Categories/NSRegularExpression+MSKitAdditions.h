//
//  NSRegularExpression+MSKitAdditions.h
//  MSKit
//
//  Created by Jason Cardwell on 10/2/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

@interface NSRegularExpression (MSKitAdditions)

- (NSDictionary *)captureGroupsFromFirstMatchInString:(NSString *)string
											  options:(NSMatchingOptions)options
												range:(NSRange)range
												 keys:(NSArray *)keys;

@end
