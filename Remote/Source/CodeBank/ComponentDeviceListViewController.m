//
// ComponentDeviceListViewController.m
// Remote
//
// Created by Jason Cardwell on 5/23/11.
// Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "ComponentDeviceListViewController.h"
#import "IRCodeDetailViewController.h"
#import "BankObject.h"
#import "BankObject.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@interface ComponentDeviceListViewController ()

// @property (nonatomic, assign) NSUInteger   deviceIndex;
@property (nonatomic, strong) NSArray * codes;

@end

@implementation ComponentDeviceListViewController
@synthesize codes, componentDevice;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (ValueIsNotNil(componentDevice)) self.navigationItem.title = componentDevice.name;
}

- (NSArray *)codes {
    if (ValueIsNotNil(codes)) return codes;

    if (ValueIsNotNil(componentDevice)) {
        NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                          ascending:YES];

        self.codes =
            [[componentDevice.codes allObjects]
             sortedArrayUsingDescriptors:@[sortDescriptor]];
    } else
        self.codes = [NSArray array];


    return codes;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.codes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell           = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (ValueIsNil(cell))
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];

    // Configure the cell...
    BOIRCode * code = self.codes[indexPath.row];

    cell.textLabel.text = code.name;

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([@"Push Code Detail" isEqualToString : segue.identifier]) {
        if (![segue.destinationViewController
              isMemberOfClass:[IRCodeDetailViewController class]]) return;

        NSUInteger                   codeIndex = [self.tableView indexPathForSelectedRow].row;
        BOIRCode                     * code      = self.codes[codeIndex];
        IRCodeDetailViewController * detailVC  =
            (IRCodeDetailViewController *)segue.destinationViewController;

        detailVC.code = code;
    }
}

@end
