//
// UserCodesViewController.m
// Remote
//
// Created by Jason Cardwell on 5/23/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "UserCodesViewController.h"
#import "ComponentDeviceListViewController.h"
#import "BankObject.h"
#import "BankObjectGroup.h"
#import "MSRemoteAppController.h"
#import "CoreDataManager.h"

static int   ddLogLevel = DefaultDDLogLevel;

@interface UserCodesViewController ()

@property (nonatomic, strong) NSArray * fetchedDevices;

@end

@implementation UserCodesViewController

@synthesize fetchedDevices;

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedDevices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell           = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (ValueIsNil(cell))
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];

    // Configure the cell...
    BOComponentDevice * device = self.fetchedDevices[indexPath.row];

    cell.textLabel.text = device.name;

    return cell;
}

- (NSArray *)fetchedDevices {
    if (ValueIsNotNil(fetchedDevices)) return fetchedDevices;

    [[NSManagedObjectContext MR_defaultContext] performBlockAndWait:^{
                                         NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ComponentDevice"];

                                         NSSortDescriptor * sortDescriptor = [NSSortDescriptor                                  sortDescriptorWithKey:@"deviceName"
                                                                                                           ascending:YES];
                                         [fetchRequest setSortDescriptors:@[sortDescriptor]];

                                         NSError * error = nil;
                                         self.fetchedDevices = [[NSManagedObjectContext MR_defaultContext]                                  executeFetchRequest:fetchRequest
                                                                                                              error:&error];
                                         if (ValueIsNil(fetchedDevices)) {
                                         DDLogError(@"No component device objects could be found");
                                         self.fetchedDevices = [NSArray array];
                                         }
                                     }

    ];

    return fetchedDevices;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([@"Push Device Codes" isEqualToString : segue.identifier]) {
        if (![segue.destinationViewController
              isMemberOfClass:[ComponentDeviceListViewController class]]) return;

        NSUInteger                          deviceIndex = [self.tableView indexPathForSelectedRow].row;
        BOComponentDevice                   * device      = self.fetchedDevices[deviceIndex];
        ComponentDeviceListViewController * detailVC    = segue.destinationViewController;

        detailVC.componentDevice = device;
    }
}

@end
