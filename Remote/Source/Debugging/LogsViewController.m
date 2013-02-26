//
// LogsViewController.m
// iPhonto
//
// Created by Jason Cardwell on 10/13/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "LogsViewController.h"
#import <QuickLook/QuickLook.h>
#import "StoryboardProxy.h"

@interface LogsViewController () <UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) NSArray                         * logPaths;
@property (nonatomic, strong) NSString                        * logDirectory;
@property (nonatomic, strong) NSArray                         * logFiles;
@property (nonatomic, strong) UIDocumentInteractionController * docController;
@end

@implementation LogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UIToolbar appearance] setBarStyle:UIBarStyleBlackOpaque];
    self.clearsSelectionOnViewWillAppear                        = YES;
    self.definesPresentationContext                             = YES;
    self.navigationController.toolbar.barStyle                  = UIBarStyleBlackOpaque;
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont : [UIFont boldSystemFontOfSize:16]};
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:2.0 forBarMetrics:UIBarMetricsDefault];
    if (!_logDirectory) self.logDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Logs"];
}

- (void)viewWillAppear:(BOOL)animated {
    NSError * error = nil;

    self.logPaths = [[[NSFileManager defaultManager]
                      contentsOfDirectoryAtPath:_logDirectory
                                          error:&error] filteredArrayUsingPredicateWithFormat:@"NOT SELF BEGINSWITH %@", @"."];
    self.logFiles = [_logPaths filteredArrayUsingPredicateWithFormat:@"SELF ENDSWITH %@", @".txt"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _logPaths.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell           = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Configure the cell...
    cell.textLabel.text                 = _logPaths[indexPath.row];
    cell.imageView.image                = ([cell.textLabel.text hasSuffix:@"txt"] ? nil :[UIImage imageNamed:@"icons/[477]bankers-box"]);
    cell.contentView.gestureRecognizers = self.docController.gestureRecognizers;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * fileName = _logPaths[indexPath.row];

    if ([fileName hasSuffix:@"txt"]) {
        UIDocumentInteractionController * docController =
            [UIDocumentInteractionController interactionControllerWithURL:
             [NSURL fileURLWithPath:
              [_logDirectory stringByAppendingPathComponent:_logFiles[indexPath.row]]]];

        docController.delegate = self;
        [docController presentPreviewAnimated:YES];
    } else {
        LogsViewController * logsViewController = [StoryboardProxy logsViewController];

        logsViewController.logDirectory = [_logDirectory stringByAppendingPathComponent:fileName];
        [self.navigationController pushViewController:logsViewController animated:YES];
    }
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

@end
