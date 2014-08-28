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


@interface MSKVOReceptionist ()
@property (nonatomic, strong, readwrite) NSArray                  * keyPaths;
@property (nonatomic, strong, readwrite) NSOperationQueue         * queue;
@property (nonatomic, weak,   readwrite) id                         object;
@property (nonatomic, assign, readwrite) NSKeyValueObservingOptions options;
@property (nonatomic, assign, readwrite) void                     * context;
@property (nonatomic, copy,   readwrite) NSDictionary             * change;
@property (nonatomic, copy,   readwrite) void (^handler)(MSKVOReceptionist *);
@end

@implementation MSKVOReceptionist

+ (MSKVOReceptionist *)receptionistForObject:(id)object
                                     keyPath:(NSString *)keyPath
                                     options:(NSKeyValueObservingOptions)options
                                     context:(void *)context
                                       queue:(NSOperationQueue *)queue
                                     handler:(void(^)(MSKVOReceptionist * receptionist))handler
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
                                     handler:(void(^)(MSKVOReceptionist * receptionist))handler
{
  if (!object) ThrowInvalidNilArgument(object);
  if (![keyPaths count]) ThrowInvalidArgument(keyPaths, "keyPaths cannot be nil or empty");
  if (!handler) ThrowInvalidNilArgument(handler);
  if (!queue) ThrowInvalidNilArgument(queue);

  MSKVOReceptionist * receptionist = [MSKVOReceptionist new];
  receptionist.object   = object;
  receptionist.options  = options;
  receptionist.context  = context;
  receptionist.handler  = handler;
  receptionist.queue    = queue;
  receptionist.keyPaths = keyPaths; // Set last because setter adds the observer


  return receptionist;
}

- (void)setKeyPaths:(NSArray *)keyPaths {
  assert(self.object);
  _keyPaths = keyPaths;

  for (NSString * kp in keyPaths)
    [self.object addObserver:self forKeyPath:kp options:self.options context:self.context];
}

/// Receive the observed notification and execute's the registered handler.
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  assert([self.keyPaths containsObject:keyPath]);

  if (![self shouldIgnore]) {
    self.change = change;
    __weak MSKVOReceptionist * weakself = self;
    [self.queue addOperationWithBlock:^{ self.handler(weakself); }];
  }
}

- (void)dealloc { for (NSString * kp in self.keyPaths) [self.object removeObserver:self forKeyPath:kp]; }

@end
