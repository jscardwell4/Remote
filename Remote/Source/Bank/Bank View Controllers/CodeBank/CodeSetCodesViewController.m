//
// CodeSetCodesViewController.m
// Remote
//
// Created by Jason Cardwell on 3/22/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "CodeSetCodesViewController.h"
#import "BankObjectGroup.h"
#import "IRCode.h"
#import "IRCodeDetailViewController.h"

static int ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@interface CodeSetCodesViewController ()

@property (nonatomic, strong) NSArray * fetchedCodes;

@end

@implementation CodeSetCodesViewController

@synthesize codeset, fetchedCodes;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (ValueIsNotNil(self.codeset)) self.navigationItem.title = self.codeset.name;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedCodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell           = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...
    IRCode * code = self.fetchedCodes[indexPath.row];

    cell.textLabel.text = code.name;

    return cell;
}

- (void)setCodeSet:(IRCodeset *)newCodeSet {
    codeset           = newCodeSet;
    self.fetchedCodes =
        [[codeset.codes allObjects]
         sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                     ascending:YES]]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (  [@"Push Code Detail" isEqualToString : segue.identifier]
       && [segue.destinationViewController isMemberOfClass:[IRCodeDetailViewController class]])
        [(IRCodeDetailViewController *)segue.destinationViewController
         setCode : self.fetchedCodes[
                                     [self.tableView indexPathForSelectedRow].row]];
}

@end
