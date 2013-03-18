//
// CommandContainer.h
// Remote
//
// Created by Jason Cardwell on 6/29/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CommandContainer : NSManagedObject {
    @private
}

+ (BOOL)isValidKey:(NSString *)key;
- (BOOL)isValidKey:(NSString *)key;

@end
