//
//  REControlStateSetProxy.m
//  Remote
//
//  Created by Jason Cardwell on 4/12/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "REControlStateSetProxy_Private.h"

@implementation REControlStateSetProxy

+ (instancetype)proxyWithDelegate:(id<REControlStateSetProxyDelegate>)delegate
{
    return [[self alloc] initWithDelegate:delegate];
}

- (instancetype)initWithDelegate:(id<REControlStateSetProxyDelegate>)delegate
{
    self->_delegate = delegate;
    return self;
}

- (NSString *)uuid { return (self.proxiedObject ? self.proxiedObject.uuid : ClassString([self class])); }

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

- (BOOL)updateProxyObject:(REControlStateSet *)object sender:(id<REControlStateSetProxyDelegate>)sender
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


@implementation REControlStateTitleSetProxy

//- (BOOL)isKindOfClass:(Class)aClass { return (aClass == [REControlStateTitleSet class]); }
+ (Class)proxyClass { return [REControlStateTitleSet class]; }
- (Class)proxyClass { return [[self class] proxyClass]; }

- (void)instantiateProxyObject
{
    [super instantiateProxyObject];

    if (self.instanstiationBlock)
        self.proxiedObject = self.instanstiationBlock(self);

    else
        self.proxiedObject = [REControlStateTitleSet controlStateSet];

    if ([self.delegate respondsToSelector:@selector(didInstantiateProxyObject:forProxy:)])
        [self.delegate didInstantiateProxyObject:_proxiedObject.uuid forProxy:self];
}

@end

@implementation REControlStateIconImageSetProxy

//- (BOOL)isKindOfClass:(Class)aClass { return (aClass == [REControlStateIconImageSet class]); }
+ (Class)proxyClass { return [REControlStateIconImageSet class]; }
- (Class)proxyClass { return [[self class] proxyClass]; }
+ (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL responds = [[self proxyClass] respondsToSelector:aSelector];
    return responds;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL responds = [[self proxyClass] instancesRespondToSelector:aSelector];
    return responds;
}

- (REControlStateColorSet *)iconColors
{
    if (!self.proxiedObject)
    {
        [self instantiateProxyObject];
        assert(self.proxiedObject);
    }
    return self.proxiedObject.iconColors;
}

- (void)instantiateProxyObject
{
    [super instantiateProxyObject];
    if (self.instanstiationBlock)
        self.proxiedObject = self.instanstiationBlock(self);

    else
        self.proxiedObject = [REControlStateIconImageSet controlStateSet];

    if ([self.delegate respondsToSelector:@selector(didInstantiateProxyObject:forProxy:)])
        [self.delegate didInstantiateProxyObject:_proxiedObject.uuid forProxy:self];
}

@end

@implementation REControlStateColorSetProxy

//- (BOOL)isKindOfClass:(Class)aClass { return (aClass == [REControlStateColorSet class]); }
+ (Class)proxyClass { return [REControlStateColorSet class]; }
- (Class)proxyClass { return [[self class] proxyClass]; }
- (void)instantiateProxyObject
{
    [super instantiateProxyObject];
    if (self.instanstiationBlock)
        self.proxiedObject = self.instanstiationBlock(self);

    else
        self.proxiedObject = [REControlStateColorSet controlStateSet];

    if ([self.delegate respondsToSelector:@selector(didInstantiateProxyObject:forProxy:)])
        [self.delegate didInstantiateProxyObject:_proxiedObject.uuid forProxy:self];
}

@end

@implementation REControlStateButtonImageSetProxy

//- (BOOL)isKindOfClass:(Class)aClass { return (aClass == [REControlStateButtonImageSet class]); }
+ (Class)proxyClass { return [REControlStateButtonImageSet class]; }
- (Class)proxyClass { return [[self class] proxyClass]; }
- (void)instantiateProxyObject
{
    [super instantiateProxyObject];
    if (self.instanstiationBlock)
        self.proxiedObject = self.instanstiationBlock(self);

    else
        self.proxiedObject = [REControlStateButtonImageSet controlStateSet];

    if ([self.delegate respondsToSelector:@selector(didInstantiateProxyObject:forProxy:)])
        [self.delegate didInstantiateProxyObject:_proxiedObject.uuid forProxy:self];
}

@end


