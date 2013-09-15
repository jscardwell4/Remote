//
//  Bank.m
//  Remote
//
//  Created by Jason Cardwell on 9/13/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "Bank.h"
#import "StoryboardProxy.h"
#import "MSRemoteAppController.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)

@interface Bank () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong, readwrite) UIViewController        * viewController;
@property (nonatomic, strong, readwrite) MSMutableDictionary     * rootDirectory;

- (void)importBankObject:(id)sender;
- (void)exportBankObject:(id)sender;
- (void)searchBankObjects:(id)sender;
- (void)dismiss:(id)sender;

@end

@implementation Bank

- (instancetype)init
{
    if (self = [super init])
    {
        self.rootDirectory = [MSMutableDictionary dictionary];
        _rootDirectory[@"BOIRCode"]          = @"IR Codes";
        _rootDirectory[@"BOImage"]           = @"Images";
        _rootDirectory[@"BOComponentDevice"] = @"Component Devices";
        _rootDirectory[@"BOPreset"]          = @"Presets";
        _rootDirectory[@"BOManufacturer"]    = @"Manufacturers";
    }
    return self;
}

- (UIViewController *)viewController
{
    if (!_viewController) self.viewController = [StoryboardProxy bankIndexViewController];
    return _viewController;
}

- (void)importBankObject:(id)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

- (void)exportBankObject:(id)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

- (void)searchBankObjects:(id)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

- (void)dismiss:(id)sender { [AppController dismissViewController:_viewController
                                                       completion:nil]; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableView Delegate and Data Source
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.rootDirectory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    assert(cell);
    cell.textLabel.text = self.rootDirectory[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSLogDebug(@"selection: (%@ : %@)",
               _rootDirectory[indexPath.row],
               [_rootDirectory allKeys][indexPath.row]);
}

@end

@interface BankDelegate : NSObject <UITableViewDataSource, UITableViewDelegate> @end

@implementation BankDelegate

- (IBAction)importBankObject:(UIBarButtonItem *)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

- (IBAction)exportBankObject:(UIBarButtonItem *)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

- (IBAction)searchBankObjects:(UIBarButtonItem *)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

- (IBAction)dismiss:(id)sender { [[Bank sharedInstance] dismiss:self]; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[Bank sharedInstance] tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[Bank sharedInstance] tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[Bank sharedInstance] tableView:tableView didSelectRowAtIndexPath:indexPath];
}


@end
