//
// BankPreset.m
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BankObject.h"
#import "RemoteElement.h"
#import "CoreDataManager.h"
#import "REView_Private.h"

@implementation BOPreset

@dynamic preview, element;

+ (instancetype)presetWithElement:(RemoteElement *)element
{
    assert(element);
    __block BOPreset * preset = nil;
    [element.managedObjectContext performBlockAndWait:
     ^{
         preset = [self bankObjectInContext:element.managedObjectContext];
         preset.element = element;
     }];
    return preset;
}

/*
- (void)setElement:(RemoteElement *)element
{
    [self willChangeValueForKey:@"element"];
    [self setPrimitiveValue:element forKey:@"element"];
    [self didChangeValueForKey:@"element"];
    [self generatePreviewWithObjectID:element.objectID];
}
*/

/*
- (void)generatePreviewWithObjectID:(NSManagedObjectID *)objectID
{
    assert(objectID);
    NSManagedObjectContext * context = [[CoreDataManager sharedManager] newContext];
    [context performBlock:
     ^{
         RemoteElement * element = (RemoteElement *)[context objectWithID:objectID];
         assert(element);
         REView * view = [REView viewWithModel:element];
         assert(view);

     }];
    
}
*/

@end

@implementation BORemotePreset @end

@implementation BOButtonGroupPreset @end

@implementation BOButtonPreset @end

