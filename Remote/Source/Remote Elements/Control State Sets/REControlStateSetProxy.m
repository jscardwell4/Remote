//
//  ControlStateSetProxy.m
//  Remote
//
//  Created by Jason Cardwell on 4/12/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "ControlStateSetProxy_Private.h"

@implementation ControlStateSetProxy

+ (instancetype)proxyWithDelegate:(id<ControlStateSetProxyDelegate>)delegate
{
    return [[self alloc] initWithDelegate:delegate];
}

- (instancetype)initWithDelegate:(id<ControlStateSetProxyDelegate>)delegate
{
    self->_delegate = delegate;
    return self;
}

- (NSString *)uuid
{
    return (self.proxiedObject
            ? ((ControlStateSet *)self.proxiedObject).uuid
            : ClassString([self class]));
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if (self.proxiedObject)
        [invocation invokeWithTarget:self.proxiedObject];

    else if (@selector(objectAtIndexedSubscript:) != invocation.selector)
    {
        [self instantiateProxyObject];
        if (self.proxiedObject)
            [invocation invokeWithTarget:self.proxiedObject];
    }
}

+ (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL responds = [[self proxyClass] respondsToSelector:aSelector];
    if (!responds) responds = [[[self proxyClass] superclass] respondsToSelector:aSelector];
    return responds;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL responds = [[self proxyClass] instancesRespondToSelector:aSelector];
    if (!responds) responds = [[[self proxyClass] superclass] instancesRespondToSelector:aSelector];
    return responds;
}


- (void)instantiateProxyObject { assert(!self.proxiedObject); }

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [[self proxyClass] instanceMethodSignatureForSelector:sel];
}

+ (Class)proxyClass { return NULL; }
- (Class)proxyClass { return [[self class] proxyClass]; }

//- (BOOL)isKindOfClass:(Class)aClass { return (aClass == [self proxyClass]); }

- (BOOL)updateProxyObject:(ControlStateSet *)object sender:(id<ControlStateSetProxyDelegate>)sender
{
    if (self.delegate == sender)
    {
        self.proxiedObject = object;
        return YES;
    }

    else
        return NO;
}

@end


@implementation ControlStateTitleSetProxy

//- (BOOL)isKindOfClass:(Class)aClass { return (aClass == [ControlStateTitleSet class]); }
+ (Class)proxyClass { return [ControlStateTitleSet class]; }
- (Class)proxyClass { return [[self class] proxyClass]; }

- (ControlStateTitleSet *)proxiedObject { return (ControlStateTitleSet *)[super proxiedObject]; }

- (void)instantiateProxyObject
{
    [super instantiateProxyObject];

    if (self.instanstiationBlock)
        self.proxiedObject = self.instanstiationBlock(self);

    else
        self.proxiedObject = [ControlStateTitleSet controlStateSet];

    if ([self.delegate respondsToSelector:@selector(didInstantiateProxyObject:forProxy:)])
        [self.delegate didInstantiateProxyObject:[self proxiedObject].uuid forProxy:self];
}

@end


@implementation ControlStateColorSetProxy

//- (BOOL)isKindOfClass:(Class)aClass { return (aClass == [ControlStateColorSet class]); }
+ (Class)proxyClass { return [ControlStateColorSet class]; }
- (Class)proxyClass { return [[self class] proxyClass]; }

- (ControlStateColorSet *)proxiedObject { return (ControlStateColorSet *)[super proxiedObject]; }

- (void)instantiateProxyObject
{
    [super instantiateProxyObject];
    if (self.instanstiationBlock)
        self.proxiedObject = self.instanstiationBlock(self);

    else
        self.proxiedObject = [ControlStateColorSet controlStateSet];

    if ([self.delegate respondsToSelector:@selector(didInstantiateProxyObject:forProxy:)])
        [self.delegate didInstantiateProxyObject:[self proxiedObject].uuid forProxy:self];
}

@end


