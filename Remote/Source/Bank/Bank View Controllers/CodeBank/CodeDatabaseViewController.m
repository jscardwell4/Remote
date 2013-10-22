#import "CodeDatabaseViewController.h"
#import "BankObjectGroup.h"
#import "ManufacturerCodeSetsViewController.h"
#import "CoreDataManager.h"

static int ddLogLevel = DefaultDDLogLevel;

@interface CodeDatabaseViewController ()

@property (nonatomic, strong) NSMutableArray * fetchedManufacturers;

@end

@implementation CodeDatabaseViewController

@synthesize  fetchedManufacturers;

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedManufacturers count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedManufacturers[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell           = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (ValueIsNil(cell))
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];

    cell.textLabel.text =
        (self.fetchedManufacturers[indexPath.section])[indexPath.row];

    return cell;
}

- (NSMutableArray *)fetchedManufacturers {
    if (ValueIsNotNil(fetchedManufacturers)) return fetchedManufacturers;

    self.fetchedManufacturers = [NSMutableArray arrayWithCapacity:26];
    for (int i = 0; i < 26; i++) {
        [fetchedManufacturers addObject:[NSMutableArray array]];
    }

    [[NSManagedObjectContext MR_defaultContext] performBlockAndWait:^{
                                         NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IRCodeSet"];

                                         NSError * error = nil;
                                         NSArray * fetchedCodesets =
                                         [[NSManagedObjectContext MR_defaultContext]                              executeFetchRequest:fetchRequest
                                                                                        error:&error];

                                         if (ValueIsNil(fetchedCodesets))
                                         DDLogError(@"No codeset objects could be found");
        else {
                                         NSArray * sortedManufacturers =
                                         [[fetchedCodesets valueForKeyPath:@"@distinctUnionOfObjects.manufacturer"]
                                          sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self"
                                                                                                      ascending:YES]]];

                                         for (NSString * manufacturer in sortedManufacturers) {
                                         unichar firstLetter = [manufacturer characterAtIndex:0];
                                         if ((firstLetter - 65) > 25) firstLetter -= 32;

                                         [self.fetchedManufacturers[firstLetter - 65]
                                          addObject:manufacturer];
                                         }
                                         }
                                     }

    ];

    return fetchedManufacturers;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([@"Push Codesets" isEqualToString : segue.identifier]) {
        if (![segue.destinationViewController
              isMemberOfClass:[ManufacturerCodeSetsViewController class]]) return;

        NSIndexPath * selectedRow  = [self.tableView indexPathForSelectedRow];
        NSString    * manufacturer =
            (self.fetchedManufacturers[selectedRow.section])[selectedRow.row];
        ManufacturerCodeSetsViewController * detailVC = segue.destinationViewController;

        detailVC.manufacturer = manufacturer;
    }
}

@end
