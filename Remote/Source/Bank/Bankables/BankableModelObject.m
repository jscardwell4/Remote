//
//  BankableModelObject.m
//  Remote
//
//  Created by Jason Cardwell on 9/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableModelObject.h"
#import "CoreDataManager.h"
#import "BankableDetailTableViewController.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;

#pragma unused(ddLogLevel,msLogContext)

@implementation BankableModelObject
@dynamic category, user;



/// updateWithData:
/// @param data description
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
#pragma mark - BankableModel
////////////////////////////////////////////////////////////////////////////////

/// isPreviewable
/// @return BOOL
+ (BOOL)isPreviewable { return NO;  }

/// isSectionable
/// @return BOOL
+ (BOOL)isSectionable { return YES;  }

/// isThumbnailable
/// @return BOOL
+ (BOOL)isThumbnailable { return NO;  }

/// isDetailable
/// @return BOOL
+ (BOOL)isDetailable { return YES; }

/// isEditable
/// @return BOOL
+ (BOOL)isEditable { return YES; }

/// directoryLabel
/// @return NSString *
+ (NSString *)directoryLabel { return nil; }

/// directoryIcon
/// @return UIImage *
+ (UIImage *)directoryIcon { return nil; }

/// detailViewController
/// @return BankableDetailTableViewController *
- (BankableDetailTableViewController *)detailViewController  { return nil; }

/// editingViewController
/// @return BankableDetailTableViewController *
- (BankableDetailTableViewController *)editingViewController { return nil; }

/// updateItem
- (void)updateItem {
  if ([self hasChanges]) {
    NSManagedObjectContext * moc = self.managedObjectContext;

    [moc performBlockAndWait:
     ^{
       NSError * error = nil;
       [moc save:&error];

       if (!MSHandleErrors(error)) [moc processPendingChanges];
     }];
  }
}

/// resetItem
- (void)resetItem {
  if ([self hasChanges]) {
    NSManagedObjectContext * moc      = self.managedObjectContext;
    __weak NSManagedObject * weakself = self;

    [moc performBlockAndWait:^{ [moc refreshObject:weakself mergeChanges:NO]; }];
  }
}

/// isEditable
/// @return BOOL
- (BOOL)isEditable { return [[self class] isEditable]; }

/// thumbnail
/// @return UIImage *
- (UIImage *)thumbnail { return nil; }

/// preview
/// @return UIImage *
- (UIImage *)preview { return nil; }

/// subitems
/// @return MSDictionary *
- (MSDictionary *)subitems { return nil; }

/// bankableItems
/// @return NSFetchedResultsController *
+ (NSFetchedResultsController *)bankableItems {

  NSFetchedResultsController * controller = [self fetchAllGroupedBy:@"category"
                                                      withPredicate:nil
                                                           sortedBy:@"category,name"
                                                          ascending:YES];
  NSError * error = nil;

  [controller performFetch:&error];

  MSHandleErrors(error);

  return controller;

}

@end
