//
//  REControlStateSetProxy.h
//  Remote
//
//  Created by Jason Cardwell on 4/12/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

@class REControlStateSet, REControlStateTitleSet, REControlStateIconImageSet, REControlStateColorSet, REControlStateButtonImageSet, REControlStateSetProxy;

typedef id (^REControlStateSetProxyInstantiationBlock)(REControlStateSetProxy * proxy);

@protocol REControlStateSetProxyDelegate <NSObject>

@optional
- (void)didInstantiateProxyObject:(NSString *)uuid forProxy:(REControlStateSetProxy *)proxy;

@end

@interface REControlStateSetProxy : NSProxy

@property (nonatomic, weak, readonly)  id<REControlStateSetProxyDelegate> delegate;
@property (nonatomic, copy, readwrite) REControlStateSetProxyInstantiationBlock instanstiationBlock;

+ (instancetype)proxyWithDelegate:(id<REControlStateSetProxyDelegate>)delegate;
- (instancetype)initWithDelegate:(id<REControlStateSetProxyDelegate>)delegate;

+ (Class)proxyClass;
- (Class)proxyClass;

- (BOOL)updateProxyObject:(REControlStateSet *)object
                   sender:(id<REControlStateSetProxyDelegate>)sender;

@end

@interface REControlStateTitleSetProxy       : REControlStateSetProxy @end

@interface REControlStateColorSetProxy       : REControlStateSetProxy @end

