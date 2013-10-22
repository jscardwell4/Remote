//
//  MagicalRecord+MSKitAdditions.m
//  MSKit
//
//  Created by Jason Cardwell on 10/8/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "MagicalRecord+MSKitAdditions.h"
#import <objc/runtime.h>
#import <MagicalRecord/AutoMigratingMagicalRecordStack.h>

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

static id  errorHandlerTarget = nil;
static SEL errorHandlerAction = nil;


@implementation MagicalRecord (MSKitAdditions)

+ (MagicalRecordStack *)
    setupAutoMigratingCoreDataStackWithSqliteStoreNamed:(NSString *)storeName
                                                  model:(NSManagedObjectModel *)model
{
    MagicalRecordStack *stack = [[AutoMigratingMagicalRecordStack alloc] initWithStoreNamed:storeName
                                                                                      model:model];
    [MagicalRecordStack setDefaultStack:stack];
    return stack;
}

+ (BOOL)setLogHandler:(LogHandlerBlock)handler
{
    if (handler)
    {
        IMP handlerIMP = imp_implementationWithBlock(handler);
        if (!handlerIMP) return NO;

        Method m = class_getClassMethod(self, @selector(performLogForObject:message:args:));
        if (!m) return NO;

        class_replaceMethod(objc_getMetaClass("MagicalRecord"),
                            @selector(performLogForObject:message:args:),
                            handlerIMP,
                            method_getTypeEncoding(m));
        return YES;
    }

    else
    return NO;
}

+ (void)performLogForObject:(id)object message:(NSString *)format args:(va_list)args
{
    if (format)
    NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, object, [[NSString alloc] initWithFormat:format
                                                                            arguments:args]);
}

+ (void)performLogForObject:(id)object message:(NSString *)format, ...
{
    va_list args;
	if (format)
	{
        va_start(args, format);
        [self performLogForObject:object message:format args:args];
        va_end(args);
    }
}

+ (void)defaultErrorHandler:(NSError *)error
{
    MSHandleErrors(error);
}

+ (void)handleErrors:(NSError *)error
{
    if (error)
    {
        // If a custom error handler is set, call that
        if (errorHandlerTarget != nil && errorHandlerAction != nil)
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [errorHandlerTarget performSelector:errorHandlerAction withObject:error];
#pragma clang diagnostic pop
        }
        else
        {
            // Otherwise, fall back to the default error handling
            [self defaultErrorHandler:error];
        }
    }
}

+ (id)errorHandlerTarget
{
    return errorHandlerTarget;
}

+ (SEL)errorHandlerAction
{
    return errorHandlerAction;
}

+ (void)setErrorHandlerTarget:(id)target action:(SEL)action
{
    errorHandlerTarget = target;    /* Deliberately don't retain to avoid potential retain cycles */
    errorHandlerAction = action;
}

- (void)handleErrors:(NSError *)error
{
    [[self class] handleErrors:error];
}

@end
