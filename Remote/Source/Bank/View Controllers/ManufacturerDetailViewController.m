//
//  ManufacturerDetailViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController_Private.h"
#import "BankViewController.h"
#import "ManufacturerDetailViewController.h"
#import "Manufacturer.h"
#import "BankGroup.h"
#import "IRCode.h"
#import "CoreDataManager.h"

@interface ManufacturerDetailViewController ()

@property (weak, nonatomic, readonly) Manufacturer * manufacturer;
@property (nonatomic, strong)         NSArray      * devices;
@property (nonatomic, strong)         NSArray      * codesets;

@end

@implementation ManufacturerDetailViewController

- (Manufacturer *)manufacturer { return (Manufacturer *)self.item; }

+ (Class)itemClass { return [Manufacturer class]; }

- (void)updateDisplay
{
    [super updateDisplay];
    self.devices = [self.manufacturer.devices allObjects];
    self.codesets = [self.manufacturer.codesets allObjects];

    [self.tableView reloadData];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view data source
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 2; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section ? [_codesets count] : [_devices count]);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section ? @"Codesets" : @"Devices");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSSTATIC_STRING_CONST kCellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (!indexPath.section)
    {
        NSString * labelText = ([_devices count]
                                ? [_devices[indexPath.row] valueForKey:@"name"]
                                : @"No Devices");
        cell.textLabel.text = labelText;
    }
    else
    {
        NSString * labelText = ([_codesets count]
                                ? [_codesets[indexPath.row] valueForKey:@"name"]
                                : @"No Codesets");
        cell.textLabel.text = labelText;
    }

    return cell;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view delegate
////////////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section)
    {
        UIViewController * vc = [Bank detailControllerForItem:_devices[indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        IRCodeset * codeset = _codesets[indexPath.row];
        BankViewController * vc = UIStoryboardInstantiateSceneByClassName(BankViewController);
        vc.navigationItem.title = codeset.name;
        NSManagedObjectContext * context = codeset.managedObjectContext;
        NSFetchRequest * request = [IRCode MR_requestAllWhere:@"codeset"
                                                    isEqualTo:codeset
                                                    inContext:context];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        NSFetchedResultsController * controller = [[NSFetchedResultsController alloc]
                                                   initWithFetchRequest:request
                                                   managedObjectContext:context
                                                     sectionNameKeyPath:nil
                                                              cacheName:nil];
        NSError * error = nil;
        [controller performFetch:&error];
        if (error) [CoreDataManager handleErrors:error];
        else
        {
            vc.bankableItems = controller;
            vc.itemClass = [IRCode class];
            [self.navigationController pushViewController:vc animated:YES];
        }

    }
}

@end
