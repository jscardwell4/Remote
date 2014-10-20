//
//  REBackgroundEditingViewController.m
//  Remote
//
//  Created by Jason Cardwell on 4/2/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REBackgroundEditingViewController.h"
#import "REBackgroundCollectionViewController.h"
#import "ColorSelectionViewController.h"
//#import "BankObject.h"
#import "StoryboardProxy.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = (LOG_CONTEXT_EDITOR|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel, msLogContext)


@interface REBackgroundEditingViewController () <MSResettable, ColorSelectionDelegate>

- (IBAction)cancelAction:(id)sender;
- (IBAction)resetAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@property (nonatomic, weak)           REBackgroundCollectionViewController * collectionVC;
@property (nonatomic, strong)         ColorSelectionViewController         * colorSelectionVC;
@property (nonatomic, weak)  IBOutlet MSColorInputButton                   * colorInputButton;
@property (nonatomic, weak)  IBOutlet UIImageView                          * imagePreview;
@property (nonatomic, weak)  IBOutlet UIView                               * colorSelContainer;

@end

@implementation REBackgroundEditingViewController

- (void)resetToInitialState
{
    if (_subject)
    {
        _collectionVC.initialImage = _subject.backgroundImage;
        self.colorInputButton.backgroundColor = _subject.backgroundColor;
    }
}

- (IBAction)cancelAction:(id)sender { [self dismissViewControllerAnimated:YES completion:nil]; }

- (IBAction)resetAction:(id)sender { [self resetToInitialState]; }

- (IBAction)saveAction:(id)sender
{
    _subject.backgroundImage = [_collectionVC selectedImage];
    _subject.backgroundColor = self.colorInputButton.backgroundColor;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (ColorSelectionViewController *)colorSelectionVC
{
    if (_colorSelectionVC) return _colorSelectionVC;
    
    self.colorSelectionVC          = [StoryboardProxy colorSelectionViewController];
    _colorSelectionVC.hidesToolbar = YES;
    
    return _colorSelectionVC;
}

- (void)setCollectionVC:(REBackgroundCollectionViewController *)collectionVC
{
    _collectionVC = collectionVC;
    if (_subject)
    {
        _collectionVC.context = _subject.managedObjectContext;
        [self resetToInitialState];
    }
}

- (void)setSubject:(NSManagedObject<REEditableBackground> *)subject
{
    _subject = subject;
    if (_collectionVC)
    {
        _collectionVC.context = _subject.managedObjectContext;
        [self resetToInitialState];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Embed Background Collection"])
        self.collectionVC = segue.destinationViewController;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ColorSelectionDelegate
////////////////////////////////////////////////////////////////////////////////

- (void)colorSelector:(ColorSelectionViewController *)controller didSelectColor:(UIColor *)color {}

- (void)colorSelectorDidCancel:(ColorSelectionViewController *)controller {}

@end
