//
//  ManufacturerDetailViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/22/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankableDetailTableViewController_Private.h"
#import "BankCollectionViewController.h"
#import "ManufacturerDetailViewController.h"
#import "Manufacturer.h"
#import "BankGroup.h"
#import "IRCode.h"
#import "CoreDataManager.h"
static int ddLogLevel   = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)
MSSTATIC_STRING_CONST kDeviceCodesetText = @"Device Codes";

@interface ManufacturerDetailViewController ()

@property (nonatomic, weak, readonly) Manufacturer * manufacturer;
@property (nonatomic, strong)         NSArray      * devices;
@property (nonatomic, strong)         NSArray      * codesets;

@end

@implementation ManufacturerDetailViewController
{
    __weak Manufacturer * _manufacturer;
}

//- (Manufacturer *)manufacturer { return (Manufacturer *)self.item; }

- (Class<Bankable>)itemClass { return [Manufacturer class]; }

- (void)setItem:(NSManagedObject<Bankable> *)item
{
    [super setItem:item];
    _manufacturer = (Manufacturer *)self.item;

    if (_manufacturer)
    {
        self.devices  = [self.manufacturer.devices allObjects];
        NSSet * codesets = (self.manufacturer.codesets ?: [NSSet set]);
        self.codesets = ([_devices count]
                         ? [@[kDeviceCodesetText] arrayByAddingObjects:codesets]
                         : [codesets allObjects]);
    }

}

/*
- (void)updateDisplay
{
    [super updateDisplay];
    if ([self isViewLoaded]) [self.tableView reloadData];
}
*/

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
    BankableDetailTableViewCell * cell = [self dequeueReusableCellWithIdentifier:LabelListCellIdentifier
                                                           forIndexPath:indexPath];
    
    if (!indexPath.section)
    {
        NSString * labelText = ([_devices count]
                                ? [_devices[indexPath.row] valueForKey:@"name"]
                                : @"No Devices");
        cell.infoLabel.text = labelText;
    }
    else
    {
        NSString * labelText = ([_codesets count] ? _codesets[indexPath.row] : @"No Codesets");
        cell.infoLabel.text = labelText;
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
        NSString * codeset = _codesets[indexPath.row];

        BOOL isUserCodeset = [codeset isEqualToString:kDeviceCodesetText];
        if (isUserCodeset) codeset = nil;
        
        BankCollectionViewController * vc =
            UIStoryboardInstantiateSceneByClassName(BankCollectionViewController);

        vc.navigationItem.title = $(@"(%@) %@",
                                    self.manufacturer.name,
                                    (isUserCodeset ? @"Devices" : codeset));

        NSPredicate * predicate =
            NSPredicateMake(@"(manufacturer = %@) && (codeset = %@)", self.manufacturer, codeset);

        NSString * groupBy = (isUserCodeset ? @"device.info.name" : nil);

        NSString * sortedBy = (isUserCodeset ? @"device.info.name,info.name" : @"info.name");

        NSManagedObjectContext * moc = self.manufacturer.managedObjectContext;

        NSFetchedResultsController * controller = [IRCode fetchAllGroupedBy:groupBy
                                                              withPredicate:predicate
                                                                   sortedBy:sortedBy
                                                                  ascending:YES
                                                                  context:moc];
        NSError * error = nil;
        [controller performFetch:&error];

        if (!MSHandleErrors(error)) {
            vc.bankableItems = controller;
            vc.itemClass = [IRCode class];

            if (!isUserCodeset)
            {
                BankFlags bf = vc.bankFlags;
                vc.bankFlags = bf|BankNoSections;
            }

            [self.navigationController pushViewController:vc animated:YES];
        }

    }
}

@end
