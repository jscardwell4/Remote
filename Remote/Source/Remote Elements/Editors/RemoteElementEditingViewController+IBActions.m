//
//  REEditingViewController+IBActions.m
//  Remote
//
//  Created by Jason Cardwell on 2/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteElementEditingViewController_Private.h"
#import "REPresetCollectionViewController.h"
#import "MSRemoteAppController.h"

static const int   ddLogLevel   = LOG_LEVEL_DEBUG;
static const int   msLogContext = (LOG_CONTEXT_EDITOR|LOG_CONTEXT_FILE|LOG_CONTEXT_CONSOLE);
#pragma unused(ddLogLevel)

@implementation RemoteElementEditingViewController (IBActions)

- (IBAction)addSubelement:(id)sender
{
    MSLogDebugTag(@"");
    REPresetCollectionViewController * presetVC =
    [REPresetCollectionViewController presetControllerWithLayout:
     [UICollectionViewFlowLayout layoutWithScrollDirection:UICollectionViewScrollDirectionHorizontal]];
    presetVC.context = _context;
    [self addChildViewController:presetVC];
    [presetVC didMoveToParentViewController:self];
    UICollectionView * presetView = presetVC.collectionView;
    NSLayoutConstraint * heightConstraint = [NSLayoutConstraint
                                             constraintWithItem:presetView
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                     multiplier:1.0f
                                                       constant:0];
    [presetView addConstraint:heightConstraint];
    [self.view addSubview:presetView];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsByParsingString:@"H:|[presetView]|\nV:[presetView]|"
                                              views:@{ @"presetView": presetView }]];
    [self.view layoutIfNeeded];

    [UIView transitionWithView:self.view
                      duration:0.25f
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{ heightConstraint.constant = 200.0f; [presetView layoutIfNeeded]; }
                    completion:^(BOOL finished) { _flags.presetsActive = YES; }];
}

- (IBAction)presets:(id)sender
{ //TODO: needs implementing
    MSLogDebugTag(@"");
}

- (IBAction)editBackground:(id)sender
{ //TODO: needs implementing
    MSLogDebugTag(@"");
    REBackgroundEditingViewController * bgEditor = [StoryboardProxy backgroundEditingViewController];
    bgEditor.subject = self.remoteElement;
    [self presentViewController:bgEditor animated:YES completion:nil];
}

- (IBAction)editSubelement:(id)sender
{ //TODO: needs to be overridden by REButtonGroupEditingViewController
    MSLogDebugTag(@"");
    assert(self.selectionCount == 1);
    [self openSubelementInEditor:((RemoteElementView *)[self.selectedViews anyObject]).model];
}

- (IBAction)duplicateSubelements:(id)sender
{ //TODO: needs implementing
    MSLogDebugTag(@"");
}

- (IBAction)copyStyle:(id)sender
{ //TODO: needs implementing
    MSLogDebugTag(@"");
}

- (IBAction)pasteStyle:(id)sender
{ //TODO: needs implementing
    MSLogDebugTag(@"");
}

- (IBAction)toggleBoundsVisibility:(id)sender
{
    MSLogDebugTag(@"");
    _flags.showSourceBoundary = !_flags.showSourceBoundary;
    _sourceViewBoundsLayer.hidden = !_flags.showSourceBoundary;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Resizing, alignment actions
///@name Resizing, alignment actions
////////////////////////////////////////////////////////////////////////////////

- (IBAction)alignVerticalCenters:(id)sender
{
    MSLogDebugTag(@"");
    [self willAlignSelectedViews];
    [self alignSelectedViews:NSLayoutAttributeCenterY];
    [self didAlignSelectedViews];
}

- (IBAction)alignHorizontalCenters:(id)sender
{
    MSLogDebugTag(@"");
    [self willAlignSelectedViews];
    [self alignSelectedViews:NSLayoutAttributeCenterX];
    [self didAlignSelectedViews];
}

- (IBAction)alignTopEdges:(id)sender
{
    MSLogDebugTag(@"");
    [self willAlignSelectedViews];
    [self alignSelectedViews:NSLayoutAttributeTop];
    [self didAlignSelectedViews];
}

- (IBAction)alignBottomEdges:(id)sender
{
    MSLogDebugTag(@"");
    [self willAlignSelectedViews];
    [self alignSelectedViews:NSLayoutAttributeBottom];
    [self didAlignSelectedViews];
}

- (IBAction)alignLeftEdges:(id)sender
{
    MSLogDebugTag(@"");
    [self willAlignSelectedViews];
    [self alignSelectedViews:NSLayoutAttributeLeft];
    [self didAlignSelectedViews];
}

- (IBAction)alignRightEdges:(id)sender
{
    MSLogDebugTag(@"");
    [self willAlignSelectedViews];
    [self alignSelectedViews:NSLayoutAttributeRight];
    [self didAlignSelectedViews];
}

- (IBAction)resizeFromFocusView:(id)sender
{
    MSLogDebugTag(@"");
    [self willResizeSelectedViews];
    [self resizeSelectedViews:NSLayoutAttributeWidth];
    [self resizeSelectedViews:NSLayoutAttributeHeight];
    [self didResizeSelectedViews];
}

- (IBAction)resizeHorizontallyFromFocusView:(id)sender
{
    MSLogDebugTag(@"");
    [self willResizeSelectedViews];
    [self resizeSelectedViews:NSLayoutAttributeWidth];
    [self didResizeSelectedViews];
}

- (IBAction)resizeVerticallyFromFocusView:(id)sender
{
    MSLogDebugTag(@"");
    [self willResizeSelectedViews];
    [self resizeSelectedViews:NSLayoutAttributeHeight];
    [self didResizeSelectedViews];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Saving and reverting the managed object context
///@name Saving and reverting the managed object context
////////////////////////////////////////////////////////////////////////////////

- (IBAction)saveAction:(id)sender
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:nil
                                               completion:^(BOOL success, NSError *error) {
                                                   if (error) [MagicalRecord handleErrors:error];
                                                   else if (success)
                                                   {
                                                       if (_delegate) [_delegate remoteElementEditorDidSave:self];

                                                       else
                                                           [AppController dismissViewController:self completion:nil];

//                                                       else if (self.presentingViewController)
//                                                           [self dismissViewControllerAnimated:YES completion:nil];
                                                   }
                                               }];
/*
    BOOL savedOK = [CoreDataManager saveContext:_context asynchronous:NO completion:nil];
    if (savedOK)
    {
        if (_delegate) [_delegate remoteElementEditorDidSave:self];

        else if (self.presentingViewController)
            [self dismissViewControllerAnimated:YES completion:nil];
    }
*/
}

- (IBAction)resetAction:(id)sender
{
    MSLogDebugTag(@"");
    [_context performBlockAndWait:^{[_context rollback];}];
}

- (IBAction)cancelAction:(id)sender
{
    [_context performBlockAndWait:^{[_context rollback];}];

    if (_delegate)
        [_delegate remoteElementEditorDidCancel:self];

    else
        [AppController dismissViewController:self completion:nil];

//    else if (self.presentingViewController)
//        [self dismissViewControllerAnimated:YES completion:nil];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark UIResponderStandardEditActions Protocol Methods
///@name UIResponderStandardEditActions Protocol Methods
////////////////////////////////////////////////////////////////////////////////

- (void)undo:(id)sender
{
    MSLogDebugTag(@"");
    [_context performBlockAndWait:^{[_context undo];}];
}

- (void)redo:(id)sender
{
    MSLogDebugTag(@"");
    [_context performBlockAndWait:^{[_context redo];}];
}

- (void)copy:(id)sender
{ //TODO: needs implementing
    MSLogDebugTag(@"");
}

- (void)cut:(id)sender
{ //TODO: needs implementing
    MSLogDebugTag(@"");
}

- (void)delete:(id)sender
{ //TODO: needs to handle sibling dependencies
    MSLogDebugTag(@"");
    NSSet * elementsToDelete = [_selectedViews valueForKeyPath:@"model"];
    [_selectedViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_selectedViews removeAllObjects];
    _focusView = nil;
    [_context performBlockAndWait:
     ^{
         [_context deleteObjects:elementsToDelete];
         [_context processPendingChanges];
     }];
    [_sourceView setNeedsUpdateConstraints];
    [_sourceView updateConstraintsIfNeeded];
}

- (void)paste:(id)sender
{ //TODO: needs implementing
    MSLogDebugTag(@"");
}

- (void)select:(id)sender
{ //TODO: needs implementing
    MSLogDebugTag(@"");
}

- (void)selectAll:(id)sender
{ //TODO: needs implementing
    MSLogDebugTag(@"");
}

- (void)toggleBoldface:(id)sender
{ //TODO: needs implementing
    MSLogDebugTag(@"");
}

- (void)toggleItalics:(id)sender
{ //TODO: needs implementing
    MSLogDebugTag(@"");
}

- (void)toggleUnderline:(id)sender
{ //TODO: needs implementing
    MSLogDebugTag(@"");
}

@end
