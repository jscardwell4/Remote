//
// ManufacturerCodeSetsViewController.m
// Remote
//
// Created by Jason Cardwell on 3/19/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ManufacturerCodeSetsViewController.h"
#import "BankObjectGroup.h"
#import "CodeSetCodesViewController.h"
#import "CoreDataManager.h"

static int ddLogLevel = DefaultDDLogLevel;

@interface ManufacturerCodeSetsViewController ()

@property (nonatomic, strong) NSArray * fetchedCodeSets;

@end

@implementation ManufacturerCodeSetsViewController

@synthesize fetchedCodeSets, manufacturer;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (ValueIsNotNil(self.manufacturer)) self.navigationItem.title = self.manufacturer;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedCodeSets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell           = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...
    IRCodeset * codeset = self.fetchedCodeSets[indexPath.row];

    cell.textLabel.text = codeset.name;

    return cell;
}

- (NSArray *)fetchedCodeSets {
    if (ValueIsNotNil(fetchedCodeSets)) return fetchedCodeSets;

    [[NSManagedObjectContext MR_defaultContext] performBlockAndWait:^{
                                         NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IRCodeSet"];

                                         NSError * error = nil;
                                         NSPredicate * predicate =
                                         [NSPredicate predicateWithFormat:@"manufacturer == %@", self.manufacturer];
                                         [fetchRequest setPredicate:predicate];

                                         self.fetchedCodeSets = [[NSManagedObjectContext MR_defaultContext]                                  executeFetchRequest:fetchRequest
                                                                                                               error:&error];

                                         if (ValueIsNil(fetchedCodeSets)) {
                                         DDLogError(@"No codeset objects could be found");
                                         self.fetchedCodeSets = @[];
                                         } else
                                         self.fetchedCodeSets =
                                         [fetchedCodeSets sortedArrayUsingDescriptors:@[[NSSortDescriptor                          sortDescriptorWithKey:@"name"
                                                                                                                      ascending:YES]]];
    }

    ];

    return fetchedCodeSets;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (  [@"Push Codeset Codes" isEqualToString : segue.identifier]
       && [segue.destinationViewController isMemberOfClass:[CodeSetCodesViewController class]])
        [(CodeSetCodesViewController *)segue.destinationViewController
         setCodeset: self.fetchedCodeSets[[self.tableView indexPathForSelectedRow].row]];
}

@end