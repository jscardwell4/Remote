
//  BankViewController.m
//  Remote
//
//  Created by Jason Cardwell on 9/20/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "BankViewController.h"
#import "MSRemoteAppController.h"
#import "StoryboardProxy.h"
#import "BankTableViewController.h"
#import "BankableDetailTableViewController.h"
#import "BankCollectionViewController.h"
#import "CoreDataManager.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel, msLogContext)


@interface BankViewController ()

@property (nonatomic, weak)   IBOutlet UIView                       * containerView;
@property (nonatomic, strong) IBOutlet UIImageView                  * previewImageView;
@property (nonatomic, strong) IBOutlet BankCollectionViewController * thumbnailViewController;
@property (nonatomic, strong) IBOutlet BankTableViewController      * listViewController;

@end

@implementation BankViewController
{
    BankFlags _flags;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.listViewController = self.childViewControllers[0];
    assert(_listViewController);

    _thumbnailViewController = UIStoryboardInstantiateSceneByClassName(BankCollectionViewController);
    assert(_thumbnailViewController);

    self.previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if (![self isViewLoaded])
    {
        self.listViewController = nil;
        self.thumbnailViewController = nil;
        self.previewImageView = nil;
    }
}

- (void)setItemClass:(Class)itemClass
{
    if (itemClass && [itemClass conformsToProtocol:@protocol(Bankable)])
    {
        _itemClass = itemClass;
        _flags = [itemClass bankFlags];
    }

    else
    {
        _itemClass = NULL;
        _flags = BankDefault;
    }
}

- (NSFetchedResultsController *)bankableItems
{
    if (!_bankableItems && self.itemClass)
    {
        assert(_itemClass && [_itemClass isSubclassOfClass:[NSManagedObject class]]);
        NSManagedObjectContext * context = [NSManagedObjectContext MR_defaultContext];
        NSFetchRequest * request = [_itemClass MR_requestAllSortedBy:@"info.category"
                                                           ascending:YES
                                                           inContext:context];
        NSFetchedResultsController * controller = [[NSFetchedResultsController alloc]
                                                   initWithFetchRequest:request
                                                   managedObjectContext:context
                                                   sectionNameKeyPath:@"info.category"
                                                   cacheName:nil];
        NSError * error = nil;
        [controller performFetch:&error];

        if (error) [CoreDataManager handleErrors:error];
        else
        {
            self.bankableItems = controller;
            _bankableItems.delegate = _listViewController;
        }
    }

    return _bankableItems;
}


- (void)addChildViewController:(UIViewController *)childController
{
    if (  ([childController isKindOfClass:[BankTableViewController class]]
           && _listViewController
           && childController != _listViewController)
        || ([childController isKindOfClass:[BankCollectionViewController class]]
            && _thumbnailViewController
            && childController !=_thumbnailViewController))
        return;
    else
        [super addChildViewController:childController];

}

/*
- (void)addConstraintsToChildContent:(UIViewController *)childContentController
{
    if (!(   childContentController
          && [childContentController isViewLoaded]
          && childContentController.view.superview == _containerView)) return;

    UIView * childView = childContentController.view;
    if (childView.translatesAutoresizingMaskIntoConstraints)
    {
        childView.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray * constraints = [NSLayoutConstraint
                                 constraintsByParsingString:@"childView.left = containerView.left\n"
                                                             "childView.right = containerView.right\n"
                                                             "childView.top = containerView.top\n"
                                                             "childView.bottom = containerView.bottom"
                                                      views:@{ @"childView" : childView,
                                                               @"containerView" : _containerView }];
        [_containerView addConstraints:constraints];
    }
}
*/

- (void)updateViewConstraints
{
    MSSTATIC_NAMETAG(PreviewConstraint);

    [super updateViewConstraints];

    if (_previewImageView && _previewImageView.superview)
    {
        NSArray * constraints = [NSLayoutConstraint
                                 constraintsByParsingString:@"image.centerX = view.centerX\n"
                                                             "image.centerY = view.centerY\n"
                                                             "image.width = view.width\n"
                                                             "image.height = view.height"
                                                      views:@{ @"image" : _previewImageView,
                                                               @"view"  : self.navigationController.view }];
        [self.navigationController.view replaceConstraintsWithNametag:PreviewConstraintNametag
                                                      withConstraints:constraints];
    }
}

- (void)previewItem:(id<Bankable>)item
{
    MSLogDebug(@"item name: %@", item.name);
    assert(_previewImageView && !_previewImageView.superview);

    self.previewImageView.image = item.preview;
    [self.navigationController.view addSubview:_previewImageView];
    [self.view setNeedsUpdateConstraints];
    UIApp.statusBarHidden = YES;
}

- (void)editItem:(id<Bankable>)item
{
    MSLogDebug(@"item name: %@", item.name);
    assert(item && [item isEditable]);


    UIViewController<BankableDetailDelegate> * vc = [Bank detailViewControllerForItem:item];
    assert(vc);

    [self presentViewController:vc animated:YES completion:^{ [vc editItem]; }];
}

- (void)detailItem:(id<Bankable>)item
{
    MSLogDebug(@"item name: %@", item.name);

    UIViewController<BankableDetailDelegate> * vc = [Bank detailViewControllerForItem:item];
    assert(vc);
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showListView { [self cycleFromViewController:_thumbnailViewController
                                    toViewController:_listViewController]; }

- (void)showThumbnailView { [self cycleFromViewController:_listViewController
                                         toViewController:_thumbnailViewController]; }

- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action
                                      fromViewController:(UIViewController *)fromViewController
                                              withSender:(id)sender
{
    if (fromViewController == _thumbnailViewController) return _listViewController;
    else if (fromViewController == _listViewController) return _thumbnailViewController;
    else return nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////////////

- (IBAction)importBankObject:(UIBarButtonItem *)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

- (IBAction)exportBankObject:(UIBarButtonItem *)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

- (IBAction)searchBankObjects:(UIBarButtonItem *)sender { MSLogDebug(@"%@", ClassTagSelectorString); }

- (IBAction)dismiss:(id)sender
{
    [AppController dismissViewController:[Bank viewController] completion:nil];
}

- (IBAction)dismissPreview:(id)sender { UIApp.statusBarHidden = NO; [self.previewImageView removeFromSuperview]; }

- (IBAction)segmentedControlValueDidChange:(UISegmentedControl *)segmentedControl
{
    assert(_listViewController && _thumbnailViewController);

    switch (segmentedControl.selectedSegmentIndex)
    {
        case 0:  [self showListView];      break;
        case 1:  [self showThumbnailView]; break;
        default: assert(NO);               break;
    }

}

- (void)cycleFromViewController:(UIViewController<NSFetchedResultsControllerDelegate> *)oldController
               toViewController:(UIViewController<NSFetchedResultsControllerDelegate> *)newController
{

    [oldController willMoveToParentViewController:nil];
    [self addChildViewController:newController];

    [self transitionFromViewController:oldController
                      toViewController:newController
                              duration: 0.25
                               options:0
                            animations:^{
                                [_containerView addSubview:newController.view];
                                [oldController.view removeFromSuperview];
                                [_containerView addConstraints:
                                 [NSLayoutConstraint
                                  constraintsByParsingString:@"child.left = container.left\n"
                                                              "child.right = container.right\n"
                                                              "child.top = container.top\n"
                                                              "child.bottom = container.bottom"
                                                       views:@{ @"child"     : newController.view,
                                                                @"container" : _containerView }]];
                            }
                            completion:^(BOOL finished) {
                                [oldController removeFromParentViewController];
                                [newController didMoveToParentViewController:self];
                                _bankableItems.delegate = newController;
                            }];
}

@end

