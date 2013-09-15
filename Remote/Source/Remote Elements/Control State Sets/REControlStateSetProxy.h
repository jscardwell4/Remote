//
//  ControlStateSetProxy.h
//  Remote
//
//  Created by Jason Cardwell on 4/12/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

@class ControlStateSet, ControlStateTitleSet, ControlStateIconImageSet, ControlStateColorSet, ControlStateButtonImageSet, ControlStateSetProxy;

typedef id (^ControlStateSetProxyInstantiationBlock)(ControlStateSetProxy * proxy);

@protocol ControlStateSetProxyDelegate <NSObject>

@optional
- (void)didInstantiateProxyObject:(NSString *)uuid forProxy:(ControlStateSetProxy *)proxy;

@end

@interface ControlStateSetProxy : NSProxy

@property (nonatomic, weak, readonly)  id<ControlStateSetProxyDelegate> delegate;
@property (nonatomic, copy, readwrite) ControlStateSetProxyInstantiationBlock instanstiationBlock;

+ (instancetype)proxyWithDelegate:(id<ControlStateSetProxyDelegate>)delegate;
- (instancetype)initWithDelegate:(id<ControlStateSetProxyDelegate>)delegate;

+ (Class)proxyClass;
- (Class)proxyClass;

- (BOOL)updateProxyObject:(ControlStateSet *)object
                   sender:(id<ControlStateSetProxyDelegate>)sender;

@end

@interface ControlStateTitleSetProxy       : ControlStateSetProxy @end

@interface ControlStateColorSetProxy       : ControlStateSetProxy @end

