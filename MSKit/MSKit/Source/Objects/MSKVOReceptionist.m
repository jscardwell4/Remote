//
//  MSKVOReceptionist.m
//  MSKit
//
//  Created by Jason Cardwell on 10/15/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "MSKVOReceptionist.h"
#import "MSKitLoggingFunctions.h"
#import "MSKitMacros.h"
#import "NSString+MSKitAdditions.h"
#import "NSArray+MSKitAdditions.h"

//static int ddLogLevel = LOG_LEVEL_ERROR;
//#pragma unused(ddLogLevel)

@implementation MSKVOReceptionist
{
    NSSet                      * _keyPaths;
    id                           _object;
    NSKeyValueObservingOptions   _options;
    void                       * _context;
    MSKVOHandler                 _handler;
    NSOperationQueue           * _queue;
}

+ (MSKVOReceptionist *)receptionistForObject:(id)object
                                     keyPath:(NSString *)keyPath
                                     options:(NSKeyValueObservingOptions)options
                                     context:(void *)context
                                       queue:(NSOperationQueue *)queue
                                     handler:(MSKVOHandler)handler
{
    return [self receptionistForObject:object
                              keyPaths:@[keyPath]
                               options:options
                               context:context
                                 queue:queue
                               handler:handler];
}

+ (MSKVOReceptionist *)receptionistForObject:(id)object
                                     keyPaths:(NSArray *)keyPaths
                                     options:(NSKeyValueObservingOptions)options
                                     context:(void *)context
                                       queue:(NSOperationQueue *)queue
                                     handler:(MSKVOHandler)handler
{
    if (!(object && [keyPaths count] && handler && queue)) return nil;
    MSKVOReceptionist * receptionist = [MSKVOReceptionist new];
    receptionist->_object = object;
    receptionist->_keyPaths = [keyPaths set];
    receptionist->_options = options;
    receptionist->_context = context;
    receptionist->_handler = [handler copy];
    receptionist->_queue = queue;

    for (NSString * keyPath in keyPaths)
        [object addObserver:receptionist forKeyPath:keyPath options:options context:context];

    return receptionist;
}

/**
 Receive the observed notification and execute's the registered handler.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (!_ignore && [_keyPaths containsObject:keyPath])
    {
        __weak MSKVOReceptionist * weakself = self;
        [_queue addOperationWithBlock:^{_handler(weakself,keyPath,object,change,context);}];
    }
}

- (void)dealloc
{
    for (NSString * keyPath in _keyPaths)
        [_object removeObserver:self forKeyPath:keyPath];
}

@end
