//
//  NSOrderedSet+MSKitAdditions.h
//  MSKit
//
//  Created by Jason Cardwell on 10/20/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSKitProtocols.h"

@interface NSOrderedSet (MSKitAdditions) <MSJSONExport, MSKeySearchable>

@property (nonatomic, readonly) BOOL isEmpty;

- (NSOrderedSet *)setByMappingToBlock:(id (^)(id obj))block;

- (id)objectPassingTest:(BOOL (^)(id obj, NSUInteger idx))predicate;

- (NSString *)componentsJoinedByString:(NSString *)string;

@end
