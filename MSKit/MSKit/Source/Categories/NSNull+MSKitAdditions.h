//
//  NSNull+MSKitAdditions.h
//  Remote
//
//  Created by Jason Cardwell on 4/12/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NullObject            [NSNull null]

#define ValueIsNil(v)             [NSNull valueIsNil:v]
#define ValueIsNotNil(v)          [NSNull valueIsNotNil:v]
#define CollectionSafeValue(v)    [NSNull collectionSafeValue:v]
#define NilSafeValue(v)           [NSNull nilSafeValue:v]

@interface NSNull (MSKitAdditions)

+ (id)collectionSafeValue:(id)value;
+ (id)nilSafeValue:(id)value;
+ (BOOL)valueIsNil:(id)value;
+ (BOOL)valueIsNotNil:(id)value;

@end