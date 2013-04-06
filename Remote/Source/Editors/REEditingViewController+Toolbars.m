//
//  RemoteElementEditingViewController+Toolbars.m
//  Remote
//
//  Created by Jason Cardwell on 2/15/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REEditingViewController_Private.h"
#import "ViewDecorator.h"

NSUInteger const   kTopToolbarIndex               = 0;
NSUInteger const   kEmptySelectionToolbarIndex    = 1;
NSUInteger const   kNonEmptySelectionToolbarIndex = 2;
NSUInteger const   kFocusSelectionToolbarIndex    = 3;

@implementation REEditingViewController (Toolbars)

- (UIBarButtonItem *)barButtonItemWithImage:(NSString *)imageName selector:(SEL)selector
{
    UIImage         * image         = [UIImage imageNamed:imageName];
    UIBarButtonItem * barButtonItem = ImageBarButton(image, selector);
    barButtonItem.width = 44.0f;

    return barButtonItem;
}

- (void)initializeToolbars
{

    self.topToolbar      = [[UIToolbar alloc] initForAutoLayoutWithFrame:(CGRect){0, 0, 320, 44 }];
    _topToolbar.barStyle = UIBarStyleBlack;
    [self.view addSubview:_topToolbar];

    self.emptySelectionToolbar      = [[UIToolbar alloc] initForAutoLayoutWithFrame:TOOLBAR_FRAME];
    _emptySelectionToolbar.barStyle = UIBarStyleBlack;
    [self.view addSubview:_emptySelectionToolbar];

    self.nonEmptySelectionToolbar      = [[UIToolbar alloc] initForAutoLayoutWithFrame:TOOLBAR_FRAME];
    _nonEmptySelectionToolbar.barStyle = UIBarStyleBlack;
    _nonEmptySelectionToolbar.hidden   = YES;
    [self.view addSubview:_nonEmptySelectionToolbar];

    self.focusSelectionToolbar      = [[UIToolbar alloc] initForAutoLayoutWithFrame:TOOLBAR_FRAME];
    _focusSelectionToolbar.barStyle = UIBarStyleBlack;
    _focusSelectionToolbar.hidden   = YES;
    [self.view addSubview:_focusSelectionToolbar];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_topToolbar,
                                                             _emptySelectionToolbar,
                                                             _nonEmptySelectionToolbar,
                                                             _focusSelectionToolbar);
    NSString * constraints = @"H:|[_topToolbar]|\n"
                             "V:|[_topToolbar]\n"
                             "H:|[_emptySelectionToolbar]|\n"
                             "V:[_emptySelectionToolbar]|\n"
                             "H:|[_nonEmptySelectionToolbar]|\n"
                             "V:[_nonEmptySelectionToolbar]|\n"
                             "H:|[_focusSelectionToolbar]|\n"
                             "V:[_focusSelectionToolbar]|";
    
    [self.view addConstraints:[NSLayoutConstraint constraintsByParsingString:constraints
                                                                       views:bindings]];

    self.toolbars = @[_topToolbar,
                      _emptySelectionToolbar,
                      _nonEmptySelectionToolbar,
                      _focusSelectionToolbar];

    self.singleSelButtons = [@[] mutableCopy];
    self.anySelButtons    = [@[] mutableCopy];
    self.noSelButtons     = [@[] mutableCopy];
    self.multiSelButtons  = [@[] mutableCopy];

    [self populateTopToolbar];
    [self populateEmptySelectionToolbar];
    [self populateNonEmptySelectionToolbar];
    [self populateFocusSelectionToolbar];

    self.currentToolbar = _emptySelectionToolbar;
}

/*
 * topToolbar: Cancel ↔ Undo ↔ Save
 */
- (void)populateTopToolbar
{
    self.undoButton =[ViewDecorator fontAwesomeBarButtonItemWithName:@"undo"
                                                              target:self
                                                            selector:@selector(undo:)];

    _topToolbar.items =
        @[[ViewDecorator fontAwesomeBarButtonItemWithName:@"remove"
                                                   target:self
                                                 selector:@selector(cancelAction:)],
          FlexibleSpaceBarButton,
          _undoButton,
          FlexibleSpaceBarButton,
          [ViewDecorator fontAwesomeBarButtonItemWithName:@"save"
                                                   target:self
                                                 selector:@selector(saveAction:)]];
    NSMutableIndexSet * indices = [NSMutableIndexSet indexSetWithIndex:0];
    [indices addIndex:2];
    [indices addIndex:4];
    [_anySelButtons addObjectsFromArray:[_topToolbar.items objectsAtIndexes:indices]];
}

/*
 * emptySelectionToolbar: Add ↔ Background ↔ Toggle Bounds ↔ Presets
 */
- (void)populateEmptySelectionToolbar
{
    _emptySelectionToolbar.items =
        @[[ViewDecorator fontAwesomeBarButtonItemWithName:@"plus"
                                                   target:self
                                                 selector:@selector(addSubelement:)],
          FlexibleSpaceBarButton,
          [ViewDecorator fontAwesomeBarButtonItemWithName:@"picture"
                                                   target:self
                                                 selector:@selector(editBackground:)],
          FlexibleSpaceBarButton,
          [ViewDecorator fontAwesomeBarButtonItemWithName:@"bounds"
                                                   target:self
                                                 selector:@selector(toggleBoundsVisibility:)],
          FlexibleSpaceBarButton,
          [ViewDecorator fontAwesomeBarButtonItemWithName:@"hdd"
                                                   target:self
                                                 selector:@selector(presets:)]];

    NSMutableIndexSet * indices = [NSMutableIndexSet indexSetWithIndex:0];
    [indices addIndex:2];
    [indices addIndex:4];
    [indices addIndex:6];
    [_anySelButtons addObjectsFromArray:[_emptySelectionToolbar.items objectsAtIndexes:indices]];
}

/*
 * nonEmptySelectionToolbar: Edit ↔ Trash ↔ Duplicate ↔ Copy Style ↔ Paste Style
 */
- (void)populateNonEmptySelectionToolbar
{
    _nonEmptySelectionToolbar.items =
        @[[ViewDecorator fontAwesomeBarButtonItemWithName:@"edit"
                                                   target:self
                                                 selector:@selector(editSubelement:)],
          FlexibleSpaceBarButton,
          [ViewDecorator fontAwesomeBarButtonItemWithName:@"trash"
                                                   target:self
                                                 selector:@selector(delete:)],
          FlexibleSpaceBarButton,
          [ViewDecorator fontAwesomeBarButtonItemWithName:@"th-large"
                                                   target:self
                                                 selector:@selector(duplicateSubelements:)],
          FlexibleSpaceBarButton,
          [ViewDecorator fontAwesomeBarButtonItemWithName:@"copy"
                                                   target:self
                                                 selector:@selector(copyStyle:)],
          FlexibleSpaceBarButton,
          [ViewDecorator fontAwesomeBarButtonItemWithName:@"paste"
                                                   target:self
                                                 selector:@selector(pasteStyle:)]];

    NSMutableIndexSet * indices = [NSMutableIndexSet indexSetWithIndex:2];
    [indices addIndex:4];
    [indices addIndex:8];
    [_anySelButtons addObjectsFromArray:[_nonEmptySelectionToolbar.items objectsAtIndexes:indices]];

    [indices removeAllIndexes];
    [indices addIndex:0];
    [indices addIndex:6];
    [_singleSelButtons addObjectsFromArray:[_nonEmptySelectionToolbar.items objectsAtIndexes:indices]];
}

/*
 * focusSelectionToolbar: Alignment ↔ Size
 */
- (void)populateFocusSelectionToolbar
{

    NSArray * titles = @[[ViewDecorator fontAwesomeTitleWithName:@"align-bottom-edges" size:48.0f],
                         [ViewDecorator fontAwesomeTitleWithName:@"align-top-edges"    size:48.0f],
                         [ViewDecorator fontAwesomeTitleWithName:@"align-left-edges"   size:48.0f],
                         [ViewDecorator fontAwesomeTitleWithName:@"align-right-edges"  size:48.0f],
                         [ViewDecorator fontAwesomeTitleWithName:@"align-center-y"     size:48.0f],
                         [ViewDecorator fontAwesomeTitleWithName:@"align-center-x"     size:48.0f]];

    NSArray * selectorNames = @[SelectorString(@selector(alignBottomEdges:)),
                                SelectorString(@selector(alignTopEdges:)),
                                SelectorString(@selector(alignLeftEdges:)),
                                SelectorString(@selector(alignRightEdges:)),
                                SelectorString(@selector(alignVerticalCenters:)),
                                SelectorString(@selector(alignHorizontalCenters:))];

    MSPopupBarButton * align = [[MSPopupBarButton alloc]
                                initWithTitle:[UIFont fontAwesomeIconForName:@"align-edges"]
                                        style:UIBarButtonItemStylePlain
                                       target:nil
                                       action:NULL];

    [align setTitleTextAttributes:@{UITextAttributeFont : [UIFont fontAwesomeFontWithSize:32.0f]}
                         forState:UIControlStateNormal];

    [align setTitleTextAttributes:@{UITextAttributeFont : [UIFont fontAwesomeFontWithSize:32.0f]}
                         forState:UIControlStateHighlighted];

    align.delegate = self;

    for (int i = 0; i < titles.count; i++)
        [align addItemWithAttributedTitle:titles[i]
                                   target:self
                                   action:NSSelectorFromString(selectorNames[i])];

    titles = @[[ViewDecorator fontAwesomeTitleWithName:@"align-horizontal-size" size:48.0f],
               [ViewDecorator fontAwesomeTitleWithName:@"align-vertical-size" size:48.0f],
               [ViewDecorator fontAwesomeTitleWithName:@"align-size-exact" size:48.0f]];

    selectorNames = @[SelectorString(@selector(resizeHorizontallyFromFocusView:)),
                                SelectorString(@selector(resizeVerticallyFromFocusView:)),
                                SelectorString(@selector(resizeFromFocusView:))];

    MSPopupBarButton * resize = [[MSPopupBarButton alloc]
                                 initWithTitle:[UIFont fontAwesomeIconForName:@"align-size"]
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:NULL];

    [resize setTitleTextAttributes:@{UITextAttributeFont:[UIFont fontAwesomeFontWithSize:32.0f]}
                          forState:UIControlStateNormal];

    [resize setTitleTextAttributes:@{UITextAttributeFont:[UIFont fontAwesomeFontWithSize:32.0f]}
                          forState:UIControlStateHighlighted];

    resize.delegate = self;

    for (int i = 0; i < titles.count; i++)
        [resize addItemWithAttributedTitle:titles[i]
                                    target:self
                                    action:NSSelectorFromString(selectorNames[i])];

    _focusSelectionToolbar.items = @[FlexibleSpaceBarButton,
                                     align,
                                     FlexibleSpaceBarButton,
                                     resize,
                                     FlexibleSpaceBarButton];

    [_multiSelButtons addObjectsFromArray:@[align, resize]];
}

- (void)setCurrentToolbar:(UIToolbar *)currentToolbar
{
    if (currentToolbar && _currentToolbar && _currentToolbar != currentToolbar) {
        currentToolbar.frame = _currentToolbar.frame;
        [UIView animateWithDuration:0.25
                         animations:^{
                             _currentToolbar.hidden = YES;
                             currentToolbar.hidden  = NO;
                         }

                         completion:^(BOOL finished) {
                             if (finished) _currentToolbar = currentToolbar;
                         }];
    }

    else
        _currentToolbar = currentToolbar;
}

- (UIToolbar *)currentToolbar { return _currentToolbar; }

/*
 * Updates the toolbar to display based on the current selection and whether `focusView` has been
 * set.
 */
- (void)updateToolbarDisplayed
{
    if (self.selectionCount > 0) {
        BOOL        focusBarAvailable = ValueIsNotNil(_focusSelectionToolbar);
        UIToolbar * toolbar           = ((ValueIsNotNil(_focusView) && focusBarAvailable)
                                         ? _focusSelectionToolbar
                                         : _nonEmptySelectionToolbar);

        if (_currentToolbar != toolbar && ValueIsNotNil(toolbar)) self.currentToolbar = toolbar;
    } else self.currentToolbar = _emptySelectionToolbar;
}

- (void)updateBarButtonItems
{
    if (_flags.movingSelectedViews)
    {
        [_singleSelButtons setValue:@NO forKeyPath:@"enabled"];
        [_anySelButtons setValue:@NO forKeyPath:@"enabled"];
        [_multiSelButtons setValue:@NO forKeyPath:@"enabled"];
    }

    else
    {
        [_anySelButtons setValue:@YES forKeyPath:@"enabled"];

        BOOL   multipleButtonsSelected = self.selectionCount > 1;
        [_singleSelButtons setValue:@(!multipleButtonsSelected) forKeyPath:@"enabled"];
        [_multiSelButtons setValue:@(multipleButtonsSelected) forKeyPath:@"enabled"];
    }
}

/*
 * Delegate method for being notified when an `MSPopupBarButton` has displayed its popover. Toggles
 * `flags.popoverActive`.
 * @param popupBarButton The newly active `MSPopupBarButton`
 */
- (void)popupBarButtonDidShowPopover:(MSPopupBarButton *)popupBarButton {_flags.popoverActive = YES;}

/*
 * Delegate method for being notified when an `MSPopupBarButton` has hidden its popover. Toggles
 * `flags.popoverActive`.
 * @param popupBarButton The newly inactive `MSPopupBarButton`
 */
- (void)popupBarButtonDidHidePopover:(MSPopupBarButton *)popupBarButton { _flags.popoverActive = NO; }

@end
