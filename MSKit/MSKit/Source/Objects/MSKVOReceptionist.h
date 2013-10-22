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

MSEXTERN_STRING MSKVOObjectKeyName;
MSEXTERN_STRING MSKVOKeyPathKeyName;
MSEXTERN_STRING MSKVOOptionsKeyName;
MSEXTERN_STRING MSKVOContextKeyName;
MSEXTERN_STRING MSKVOHandlerKeyName;
MSEXTERN_STRING MSKVOHandlerRequiresMainKeyName;

@class MSKVOReceptionist;
typedef void(^MSKVOHandler)(MSKVOReceptionist * receptionist,
                            NSString * keyPath,
                            id object,
                            NSDictionary * change,
                            void * context);

@interface MSKVOReceptionist : NSObject

+ (MSKVOReceptionist *)receptionistForObject:(id)object
                                     keyPath:(NSString *)keyPath
                                     options:(NSKeyValueObservingOptions)options
                                     context:(void *)context
                                       queue:(NSOperationQueue *)queue
                                     handler:(MSKVOHandler)handler;

+ (MSKVOReceptionist *)receptionistForObject:(id)object
                                    keyPaths:(NSArray *)keyPaths
                                     options:(NSKeyValueObservingOptions)options
                                     context:(void *)context
                                       queue:(NSOperationQueue *)queue
                                     handler:(MSKVOHandler)handler;

@property (nonatomic, assign, getter = shouldIgnore) BOOL ignore;

@end

#define MSMakeKVOHandler(block)         \
    ^(MSKVOReceptionist * receptionist, \
      NSString          * keyPath,      \
      id object,                        \
      NSDictionary      * change,       \
      void              * context)      \
    block

#define MSKVOHandlerMake(block)         \
    ^(MSKVOReceptionist * receptionist, \
      NSString          * keyPath,      \
      id object,                        \
      NSDictionary      * change,       \
      void              * context)      \
    {                                   \
        block                           \
    }
