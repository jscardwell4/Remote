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
#import <Lumberjack/DDLog.h>

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

//static id  errorHandlerTarget = nil;
//static SEL errorHandlerAction = nil;


@implementation MagicalRecord (MSKitAdditions)

+ (void)load
{
    SEL selector = @selector(log:level:flag:context:file:function:line:tag:format:);
    Method method = class_getClassMethod([DDLog class], selector);
    IMP imp = imp_implementationWithBlock(^(id _self,
                                            BOOL synchronous,
                                            int level,
                                            int flag,
                                            int context,
                                            const char * file,
                                            const char * function,
                                            int line,
                                            id tag,
                                            NSString * format, ...) {
        va_list args;
        va_start(args, format);
        [DDLog log:synchronous
             level:level
              flag:flag
           context:context
              file:file
          function:function
              line:line
               tag:tag
            format:format
              args:args];
        va_end(args);
    });
    if (method)
        class_replaceMethod(objc_getMetaClass("MagicalRecord"),
                            selector,
                            imp,
                            method_getTypeEncoding(method));
}

+ (MagicalRecordStack *)
    setupAutoMigratingCoreDataStackWithSqliteStoreNamed:(NSString *)storeName
                                                  model:(NSManagedObjectModel *)model
{
    MagicalRecordStack *stack = [[AutoMigratingMagicalRecordStack alloc] initWithStoreNamed:storeName
                                                                                      model:model];
    [MagicalRecordStack setDefaultStack:stack];
    return stack;
}

/*
+ (BOOL)setLogHandler:(LogHandlerBlock)handler
{
    if (handler)
    {

        SEL selector = @selector(log:level:flag:context:file:function:line:tag:format:);
        Method method = class_getClassMethod([DDLog class], selector);
        if (method)
            class_replaceMethod(objc_getMetaClass("MagicalRecord"),
                                selector,
                                method_getImplementation(method),
                                method_getTypeEncoding(method));
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
    errorHandlerTarget = target;     Deliberately don't retain to avoid potential retain cycles 
    errorHandlerAction = action;
}

- (void)handleErrors:(NSError *)error
{
    [[self class] handleErrors:error];
}
*/

@end
