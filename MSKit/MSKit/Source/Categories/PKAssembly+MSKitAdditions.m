//
//  PKAssembly+MSKitAdditions.m
//  MSKit
//
//  Created by Jason Cardwell on 10/21/13.
//  Copyright (c) 2013 Jason Cardwell. All rights reserved.
//

#import "PKAssembly+MSKitAdditions.h"

@implementation PKAssembly (MSKitAdditions)

- (id)MS_peek { return ([self isStackEmpty] ? nil : [self.stack lastObject]); }

@end
