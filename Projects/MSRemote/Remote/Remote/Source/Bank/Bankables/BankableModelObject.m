//
//  BankableModelObject.m
//  Remote
//
//  Created by Jason Cardwell on 9/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableModelObject.h"
#import "CoreDataManager.h"
#import "Remote-Swift.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;

#pragma unused(ddLogLevel,msLogContext)

@interface BankableModelObject () <BankDisplayItemModel>

@end

@implementation BankableModelObject
@dynamic user;

/// updateWithData:
/// @param data
- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

  self.name     = data[@"name"] ?: self.name;
  self.category = data[@"category"] ?: self.category;
  self.user     = data[@"user"] ?: self.user;

}

/// JSONDictionary
/// @return MSDictionary *
- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];

  SetValueForKeyIfNotDefault(self.name,              @"name",     dictionary);
  SetValueForKeyIfNotDefault(self.category,          @"category", dictionary);
  SetValueForKeyIfNotDefault(@(self.user.boolValue), @"user",     dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankDisplayItem
////////////////////////////////////////////////////////////////////////////////

+ (NSString *)label { return nil; }
+ (UIImage *)icon { return nil; }

/// isThumbnailable
/// @return BOOL
+ (BOOL)isThumbnailable { return NO;  }

/// isPreviewable
/// @return BOOL
+ (BOOL)isPreviewable { return NO;  }

/// isDetailable
/// @return BOOL
+ (BOOL)isDetailable { return YES; }

/// isEditable
/// @return BOOL
+ (BOOL)isEditable { return NO; }



////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankDisplayItemModel
////////////////////////////////////////////////////////////////////////////////


- (BankItemDetailController *)detailController { return nil; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark - BankableModel
////////////////////////////////////////////////////////////////////////////////

/// isPreviewable
/// @return BOOL
- (BOOL)isPreviewable { return [[self class] isPreviewable]; }

/// isCategorized
/// @return BOOL
+ (BOOL)isCategorized { return NO;  }

/// isThumbnailable
/// @return BOOL
- (BOOL)isThumbnailable { return [[self class] isThumbnailable]; }

/// isDetailable
/// @return BOOL
- (BOOL)isDetailable { return [[self class] isDetailable]; }

/// isEditable
/// @return BOOL
- (BOOL)isEditable { return [[self class] isEditable]; }

/// directoryLabel
/// @return NSString *
+ (NSString *)directoryLabel { return nil; }

/// directoryIcon
/// @return UIImage *
+ (UIImage *)directoryIcon { return nil; }

/// detailViewController
/// @return BankItemViewController *
- (BankItemDetailController *)detailViewController  { return nil; }

/// editingViewController
/// @return BankItemViewController *
- (BankItemDetailController *)editingViewController { return nil; }

/// updateItem
- (void)updateItem {
  if ([self hasChanges]) {
    NSManagedObjectContext * moc = self.managedObjectContext;

    [moc performBlockAndWait:^{
       NSError * error = nil;
       [moc save:&error];
       if (!MSHandleErrors(error)) [moc processPendingChanges];
     }];
  }
}

/// category
/// @return id<BankDisplayItemCategory>
- (id<BankDisplayItemCategory>)category { return nil; }

/// setCategory:
/// @param category
- (void)setCategory:(id<BankDisplayItemCategory>)category {}

/// resetItem
- (void)resetItem {
  if ([self hasChanges]) {
    NSManagedObjectContext * moc      = self.managedObjectContext;
    __weak NSManagedObject * weakself = self;
    [moc performBlockAndWait:^{ [moc refreshObject:weakself mergeChanges:NO]; }];
  }
}

/// thumbnail
/// @return UIImage *
- (UIImage *)thumbnail { return nil; }

/// preview
/// @return UIImage *
- (UIImage *)preview { return nil; }

/// allItems
/// @return NSFetchedResultsController *
+ (NSFetchedResultsController *)allItems {

  NSFetchedResultsController * controller = [self fetchAllGroupedBy:nil sortedBy:@"name"];

  NSError * error = nil;
  [controller performFetch:&error];
  MSHandleErrors(error);

  return controller;

}

/// rootCategories
/// @return NSArray *
+ (NSArray *)rootCategories { return nil; }

@end
