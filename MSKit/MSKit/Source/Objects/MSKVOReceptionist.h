//
//  MSKVOReceptionist.h
//  MSKit
//
//  Created by Jason Cardwell on 10/15/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MSKitDefines.h"

@interface MSKVOReceptionist : NSObject

+ (MSKVOReceptionist *)receptionistForObject:(id)object
                                     keyPath:(NSString *)keyPath
                                     options:(NSKeyValueObservingOptions)options
                                     context:(void *)context
                                       queue:(NSOperationQueue *)queue
                                     handler:(void (^)(MSKVOReceptionist * receptionist))handler;

+ (MSKVOReceptionist *)receptionistForObject:(id)object
                                    keyPaths:(NSArray *)keyPaths
                                     options:(NSKeyValueObservingOptions)options
                                     context:(void *)context
                                       queue:(NSOperationQueue *)queue
                                     handler:(void (^)(MSKVOReceptionist * receptionist))handler;

@property (nonatomic, assign, getter = shouldIgnore) BOOL          ignore;
@property (nonatomic, strong, readonly) NSArray                  * keyPaths;
@property (nonatomic, strong, readonly) NSOperationQueue         * queue;
@property (nonatomic, weak,   readonly) id                         object;
@property (nonatomic, assign, readonly) void                     * context;
@property (nonatomic, copy,   readonly) NSDictionary             * change;
@property (nonatomic, assign, readonly) NSKeyValueObservingOptions options;
@property (nonatomic, copy,   readonly) void (^handler)(MSKVOReceptionist *);

@end
