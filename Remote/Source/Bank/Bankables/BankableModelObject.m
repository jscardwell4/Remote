//
//  BankableModelObject.m
//  Remote
//
//  Created by Jason Cardwell on 9/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableModelObject.h"
#import "CoreDataManager.h"

static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;

#pragma unused(ddLogLevel,msLogContext)

@implementation BankableModelObject

@dynamic category, user;


+ (BankFlags)bankFlags { return BankDefault; }
+ (NSString *)directoryLabel { return nil; }
+ (UIImage *)directoryIcon { return nil; }
+ (Class)detailViewControllerClass {
  return NSClassFromString($(@"%@DetailViewController", ClassString(self)));
}

+ (Class)editingViewControllerClass { return [self detailViewControllerClass]; }

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

- (void)resetItem {
  if ([self hasChanges]) {
    NSManagedObjectContext * moc      = self.managedObjectContext;
    __weak NSManagedObject * weakself = self;

    [moc performBlockAndWait:^{ [moc refreshObject:weakself mergeChanges:NO]; }];
  }
}


- (void)updateWithData:(NSDictionary *)data {

  [super updateWithData:data];

  self.name     = data[@"name"] ?: self.name;
  self.category = data[@"category"] ?: self.category;
  self.user     = data[@"user"] ?: self.user;

}

- (MSDictionary *)JSONDictionary {
  MSDictionary * dictionary = [super JSONDictionary];

  SetValueForKeyIfNotDefault(self.name, @"name", dictionary);
  SetValueForKeyIfNotDefault(self.category, @"category", dictionary);
  SetValueForKeyIfNotDefault(@(self.user.boolValue), @"user", dictionary);

  [dictionary compact];
  [dictionary compress];

  return dictionary;
}

- (BOOL)isEditable { return ([[self class] bankFlags] & BankEditable); }

- (UIImage *)thumbnail { return nil; }
- (UIImage *)preview { return nil; }
- (MSDictionary *)subBankables { return nil; }

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
