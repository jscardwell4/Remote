//
// Preset.m
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "Preset.h"
#import "RemoteElement.h"
#import "CoreDataManager.h"
#import "RemoteElementView_Private.h"

@implementation Preset

@dynamic preview, element, name;

+ (BOOL)isEditable { return NO; }

+ (BOOL)isPreviewable { return NO;}

+ (NSString *)directoryLabel { return @"Preset"; }

+ (NSOrderedSet *)directoryItems { return nil; }

- (UIImage *)thumbnail { return nil; }

- (UIImage *)preview { return nil; }

- (NSString *)category { return nil; }

- (UIViewController *)editingViewController { return nil; }

- (NSOrderedSet *)subBankables { return nil; }

+ (instancetype)presetWithElement:(RemoteElement *)element
{
    assert(element);
    __block Preset * preset = nil;
    [element.managedObjectContext performBlockAndWait:
     ^{
         preset = [self MR_createInContext:element.managedObjectContext];
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
    NSManagedObjectContext * context = [CoreDataManager newContext];
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
