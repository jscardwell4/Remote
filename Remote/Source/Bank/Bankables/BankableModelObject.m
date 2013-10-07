//
//  BankableModelObject.m
//  Remote
//
//  Created by Jason Cardwell on 9/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableModelObject.h"
#import "CoreDataManager.h"

@interface BankableModelObject ()

@property (nonatomic, strong, readwrite) BankInfo * info;

@end

@implementation BankableModelObject

@dynamic info;

- (void)awakeFromInsert
{
    [super awakeFromInsert];

    if (ModelObjectShouldInitialize)
    {
        NSManagedObjectContext * context = self.managedObjectContext;
        [context performBlockAndWait:
         ^{
             assert(!self.info);
             self.info = [BankInfo MR_createInContext:context];
         }];
    }
}

+ (BankFlags)bankFlags { return BankDefault; }
+ (NSString *)directoryLabel { return nil; }
+ (UIImage *)directoryIcon { return nil; }
+ (Class)detailViewControllerClass { return NSClassFromString($(@"%@DetailViewController",
                                                                ClassString(self))); }
+ (Class)editingViewControllerClass { return [self detailViewControllerClass]; }

- (void)updateItem
{
    if ([self hasChanges])
    {
        NSManagedObjectContext * moc = self.managedObjectContext;
        [moc performBlockAndWait:
         ^{
             NSError * error = nil;
             [moc save:&error];
             if (error) [CoreDataManager handleErrors:error];
             else [moc processPendingChanges];
         }];
    }
}

- (void)resetItem
{
    if ([self hasChanges])
    {
        NSManagedObjectContext * moc = self.managedObjectContext;
        __weak NSManagedObject * weakself = self;
        [moc performBlockAndWait:^{[moc refreshObject:weakself mergeChanges:NO];}];
    }
}

- (NSString *)name { return self.info.name; }
- (void)setName:(NSString *)name { self.info.name = name; }

- (BOOL)isEditable { return ([[self class] bankFlags] & BankEditable); }

- (NSString *)category { return self.info.category; }
- (void)setCategory:(NSString *)category { self.info.category = category; }

- (BOOL)user { return [self.info.user boolValue]; }
- (void)setUser:(BOOL)user { self.info.user = @(user); }

- (UIImage *)thumbnail { return nil; }
- (UIImage *)preview { return nil; }
- (MSDictionary *)subBankables { return nil; }

@end
