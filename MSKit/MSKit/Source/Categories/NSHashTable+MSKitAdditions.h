//
//  NSHashTable+MSKitAdditions.h
//  MSKit
//
//  Created by Jason Cardwell on 1/28/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

@interface NSHashTable (MSKitAdditions)

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block;
- (NSString *)componentsJoinedByString:(NSString *)string;

@end
