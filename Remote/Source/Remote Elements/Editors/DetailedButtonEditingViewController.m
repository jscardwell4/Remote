//
// DetailedButtonEditingViewController.m
// Remote
//
//
// Created by Jason Cardwell on 4/20/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "RemoteElementEditingViewController_Private.h"
#import "Button.h"

#define kChildContainerFrame     CGRectMake(0, 129, 320, 332)
#define USE_CURL_DOWN_TRANSITION NO
#define USE_CURL_DOWN_FOR_PUSH   NO

static int ddLogLevel = LOG_LEVEL_WARN;
static const int msLogContext = 0;
#pragma unused(ddLogLevel, msLogContext)

MSSTRING_CONST   REDetailedButtonEditingButtonKey       = @"REDetailedButtonEditingButtonKey";
MSSTRING_CONST   REDetailedButtonEditingControlStateKey = @"REDetailedButtonEditingControlStateKey";

enum {
    CommandEditingChildController,
    LabelEditingChildController,
    IconEditingChildController

};

@interface DetailedButtonEditingViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, weak) Button                      * buttonModel;
@property (nonatomic, strong) ButtonView                * buttonView;
@property (strong, nonatomic) IBOutlet UIToolbar        * topToolbar;
@property (strong, nonatomic) IBOutlet UIScrollView     * childContentContainer;
@property (strong, nonatomic) IBOutlet UIImageView      * backgroundImageView;
@property (weak, nonatomic) ButtonEditingViewController * buttonEditor;
@property (strong, nonatomic) IBOutlet UIPageControl    * pageControl;
@property (weak, nonatomic) UIView                      * childRootView;
@property (nonatomic, assign) NSInteger                   previousPageNumber;
@property (nonatomic, weak) UIViewController            * currentChildController;
@property (nonatomic, assign) NSInteger                   currentChildIndex;
@property (nonatomic, assign) NSInteger                   previousChildIndex;

@property struct {
    UIControlState   presentedState;
}
editorState;

- (void)setButtonViewStateFromPresentedState;
- (void)keyboardWillShow:(NSNotification *)note;
- (void)keyboardWillHide:(NSNotification *)note;
- (void)updateChildContainerForNewController:(UIViewController *)controller;
- (IBAction)pageChangeAction:(UIPageControl *)sender;
- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)sender;
- (void)transitionToAuxControllerForPage:(NSUInteger)pageNumber;
- (void)    animatePageControl;
- (void)animatePageControl:(BOOL)fadeOut;

- (UIViewController *)childControllerForPage:(NSUInteger)pageNumber;

@end

@implementation DetailedButtonEditingViewController

- (void)initializeEditorWithValues:(NSDictionary *)values {
    if (ValueIsNil(values)) return;

    _editorState.presentedState =
        [values[REDetailedButtonEditingControlStateKey] unsignedIntegerValue];

    Button * buttonModel = NilSafe(values[REDetailedButtonEditingButtonKey]);

    if (ValueIsNotNil(buttonModel)) self.remoteElement = buttonModel;
}

- (void)setButtonViewStateFromPresentedState {
    _buttonView.highlighted = _editorState.presentedState & UIControlStateHighlighted;
    _buttonView.selected    = _editorState.presentedState & UIControlStateSelected;
    _buttonView.enabled     = !(_editorState.presentedState & UIControlStateDisabled);
}

- (IBAction)cancelAction:(id)sender {
    [super cancelAction:sender];
    [_buttonEditor removeAuxController:self animated:YES];
}

- (IBAction)saveAction:(id)sender {
    [super saveAction:sender];
    [_buttonEditor removeAuxController:self animated:YES];
}

- (IBAction)resetAction:(id)sender {
    [super resetAction:sender];

    for (UIViewController * childController in self.childViewControllers) {
        if ([childController conformsToProtocol:@protocol(MSResettable)]) [(UIViewController < MSResettable > *) childController resetToInitialState];
    }
}

#pragma mark - Managing auxiliary view controllers

- (void)updateChildContainerForNewController:(UIViewController *)controller {
    self.childRootView = controller.view;

    if ([_childRootView isKindOfClass:[UIScrollView class]])
    {} else {
        CGSize   childContentSize = _childContentContainer.bounds.size;

        childContentSize.width             = MAX(childContentSize.width, controller.view.bounds.size.width);
        childContentSize.height            = MAX(childContentSize.height, controller.view.bounds.size.height);
        _childContentContainer.contentSize = childContentSize;
    }
}

- (IBAction)pageChangeAction:(UIPageControl *)sender {
    [self transitionToAuxControllerForPage:sender.currentPage];
}

- (void)animatePageControl {
    [self animatePageControl:NO];
}

- (void)animatePageControl:(BOOL)fadeOut {
    if (_pageControl.alpha == 0) {
        [UIView animateWithDuration:1.0
                         animations:^{_pageControl.alpha = 1.0; }

                         completion:^(BOOL finished) {
                             if (fadeOut) {
                             [UIView animateWithDuration:1.0
                                      delay:5.0
                                    options:0
                                 animations:^{_pageControl.alpha = 0.0; }

                                 completion:nil];
                             }
                         }

        ];
    } else {
        [UIView animateWithDuration:1.0
                         animations:^{_pageControl.alpha = 0.0; }

                         completion:^(BOOL finished) {}

        ];
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    static NSArray * blacklistClasses;

    if (ValueIsNil(blacklistClasses)) blacklistClasses = @[[UISlider class], [UIButton class]];

    if ([blacklistClasses containsObject:[touch.view class]]) return NO;
    else return YES;
}

- (BOOL)                             gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)sender {
    if (  [_currentChildController isKindOfClass:[SelectionViewController class]]
       || [_currentChildController isKindOfClass:[SelectionTableViewController class]])
    {
                    MSLogDebug(@"%@\n\tshowing selection controller, ignoring swipe", ClassTagString);

        return;
    }

    if (sender.state == UIGestureRecognizerStateEnded) {
        UISwipeGestureRecognizerDirection   direction   = sender.direction;
        NSUInteger                          currentPage = _pageControl.currentPage;

        switch (direction) {
            case UISwipeGestureRecognizerDirectionLeft :
                    MSLogDebug(@"%@\n\tleft swipe received...", ClassTagString);
                if (_pageControl.currentPage < _pageControl.numberOfPages - 1) {
                    MSLogDebug(@"%@\n\tcurrent page = %lu, transitioning to next page...",
                               ClassTagString, (unsigned long)currentPage);
                    [_pageControl setCurrentPage:_pageControl.currentPage + 1];
                    [self pageChangeAction:_pageControl];
                }

                break;

            case UISwipeGestureRecognizerDirectionRight :
                    MSLogDebug(@"%@\n\tright swipe received...", ClassTagString);
                if (_pageControl.currentPage > 0) {
                    MSLogDebug(@"%@\n\tcurrent page = %lu, transitioning to previous page...",
                               ClassTagString, (unsigned long)currentPage);
                    [_pageControl setCurrentPage:_pageControl.currentPage - 1];
                    [self pageChangeAction:_pageControl];
                }

                break;

            default :
                break;
        }  /* switch */
    }
}

- (UIViewController *)childControllerForPage:(NSUInteger)pageNumber {
    UIViewController * childController = nil;
    Class              controllerClass;

                    MSLogDebug(@"%@\n\tlocating child controller for page number:%lu", ClassTagString, (unsigned long)pageNumber);
    switch (pageNumber) {
        case LabelEditingChildController :
            controllerClass = [LabelEditingViewController class];
            break;

        case IconEditingChildController :
            controllerClass = [IconEditingViewController class];
            break;

        case CommandEditingChildController :
            controllerClass = [CommandEditingViewController class];
            break;

        default :
            DDLogWarn(@"%@\n\treceived child controller for page request with invalid number",
                      ClassTagString);
            break;
    }  /* switch */

    if (ValueIsNil(controllerClass)) return nil;

        MSLogDebug(@"%@\n\tchecking child controllers array for controller of class:%@",
               ClassTagString, ClassString(controllerClass));

    NSUInteger   controllerIndex =
        [self.childViewControllers
         indexOfObjectPassingTest:
         ^BOOL (id obj, NSUInteger idx, BOOL * stop) {
        if ([obj isMemberOfClass:controllerClass]) {
            *stop = YES;

            return YES;
        } else
            return NO;
    }

        ];

    if (controllerIndex != NSNotFound) {
        MSLogDebug(@"%@\n\tcontroller located at index:%lu", ClassTagString, (unsigned long)controllerIndex);

        return self.childViewControllers[controllerIndex];
    }

        MSLogDebug(@"%@\n\tno existing controller could be located, creating a new controller...",
               ClassTagString);
    switch (pageNumber) {
        case LabelEditingChildController : {
/*
            NSString * titleText = _buttonModel.titles[_editorState.presentedState][RETitleTextAttributeKey];
// NSNumber * fontSize = @(_buttonModel.fontSize);
// NSString * fontName = _buttonModel.fontName;
            NSValue * edgeInsets = [NSValue valueWithUIEdgeInsets:_buttonModel.titleEdgeInsets];
// UIColor * titleColor = [_buttonModel titleBaseColorForState:_editorState.presentedState];
            NSValue      * bounds        = [NSValue valueWithCGRect:_buttonView.bounds];
            NSDictionary * initialValues = @{kAttributeEditingTitleTextKey : CollectionSafe(titleText),
// kAttributeEditingFontSizeKey : CollectionSafe(fontSize),
// kAttributeEditingFontNameKey : CollectionSafe(fontName),
                                             kAttributeEditingEdgeInsetsKey : CollectionSafe(edgeInsets),
// kAttributeEditingTitleColorKey : CollectionSafe(titleColor),
                                             kAttributeEditingBoundsKey : CollectionSafe(bounds),
                                             kAttributeEditingButtonKey : _buttonModel,
                                             kAttributeEditingControlStateKey : @(_editorState.presentedState)};
            LabelEditingViewController * labelEditor = [StoryboardProxy labelEditingViewController];

            [labelEditor setInitialValuesFromDictionary:initialValues];
            childController = labelEditor;
*/
            break;
        }

        case IconEditingChildController : {
            Image * iconImage = (Image *)_buttonModel.icons[_editorState.presentedState];
            UIColor * iconColor = _buttonModel.icons.colors[_editorState.presentedState];
            NSValue                   * edgeInsets    = [NSValue valueWithUIEdgeInsets:_buttonModel.imageEdgeInsets];
            NSDictionary              * initialValues = @{kAttributeEditingImageKey : CollectionSafe(iconImage), kAttributeEditingColorKey : CollectionSafe(iconColor), kAttributeEditingEdgeInsetsKey : CollectionSafe(edgeInsets), kAttributeEditingButtonKey : _buttonModel, kAttributeEditingControlStateKey : @(_editorState.presentedState)};
            IconEditingViewController * iconEditor    = [StoryboardProxy iconEditingViewController];

            [iconEditor setInitialValuesFromDictionary:initialValues];
            childController = iconEditor;
            break;
        }

        case CommandEditingChildController : {
            NSDictionary                 * initialValues = @{kAttributeEditingButtonKey : _buttonModel};
            CommandEditingViewController * commandEditor = [StoryboardProxy commandEditingViewController];

            [commandEditor setInitialValuesFromDictionary:initialValues];
            childController = commandEditor;
            break;
        }

        default :
            break;
    } /* switch */

        MSLogDebug(@"%@\n\treturning new controller %@", ClassTagString, childController);

    return childController;
}     /* childControllerForPage */

- (void)transitionToAuxControllerForPage:(NSUInteger)pageNumber {
    UIViewController * childController = [self childControllerForPage:pageNumber];

        MSLogDebug(@"%@\n\tcontroller returned for page %lu:%@",
               ClassTagString, (unsigned long)pageNumber, childController);

    if (ValueIsNil(childController) || [self.childViewControllers count] < 1) return;

    UIViewController * currentChild = self.childViewControllers[_currentChildIndex];

        MSLogDebug(@"%@\n\tcurrent child controller %@", ClassTagString, currentChild);

    [self updateChildContainerForNewController:childController];

    if (![self.childViewControllers containsObject:childController]) {
        MSLogDebug(@"%@\n\tchild controller is new, adding to array...", ClassTagString);
        [self addChildViewController:childController];
        [childController didMoveToParentViewController:self];
    }

        MSLogDebug(@"%@\n\ttransitioning from controller:%@ to controller:%@",
               ClassTagString, currentChild, childController);

    if (USE_CURL_DOWN_TRANSITION) {
        [self transitionFromViewController:currentChild
                          toViewController:childController
                                  duration:0.5
                                   options:UIViewAnimationOptionTransitionFlipFromLeft
                                animations:^{}

                                completion:^(BOOL finished) {
                                    self.previousChildIndex = _currentChildIndex;
                                    self.currentChildIndex =
                                    [self.childViewControllers
                                     indexOfObject:childController];
                                    self.currentChildController = childController;
                                    self.previousPageNumber = pageNumber;
                                }

        ];
    } else {
        if (_pageControl.currentPage > _previousPageNumber) {
            CGRect   currentChildEndFrame = currentChild.view.frame;

            currentChildEndFrame.origin.x = 0 - currentChildEndFrame.size.width;

            CGRect   newChildBeginFrame = childController.view.frame;

            newChildBeginFrame.origin.x = newChildBeginFrame.size.width;

            CGRect   newChildEndFrame = childController.view.frame;

            newChildEndFrame.origin.x = 0;

            childController.view.frame = newChildBeginFrame;
            [_childContentContainer addSubview:childController.view];

            [UIView animateWithDuration:0.5
                             animations:^{
                                 currentChild.view.frame = currentChildEndFrame;
                                 childController.view.frame = newChildEndFrame;
                             }

                             completion:^(BOOL finished) {
                                 [currentChild.view removeFromSuperview];
                                 self.previousChildIndex = _currentChildIndex;
                                 self.currentChildIndex =
                                 [self.childViewControllers
                                  indexOfObject:childController];
                                 self.currentChildController = childController;
                                 self.previousPageNumber = pageNumber;
                             }

            ];
        } else {
            CGRect   currentChildEndFrame = currentChild.view.frame;

            currentChildEndFrame.origin.x = currentChildEndFrame.size.width;

            CGRect   newChildBeginFrame = childController.view.frame;

            newChildBeginFrame.origin.x = 0 - newChildBeginFrame.size.width;

            CGRect   newChildEndFrame = childController.view.frame;

            newChildEndFrame.origin.x = 0;

            childController.view.frame = newChildBeginFrame;
            [_childContentContainer addSubview:childController.view];

            [UIView animateWithDuration:0.5
                             animations:^{
                                 currentChild.view.frame = currentChildEndFrame;
                                 childController.view.frame = newChildEndFrame;
                             }

                             completion:^(BOOL finished) {
                                 [currentChild.view removeFromSuperview];
                                 self.previousChildIndex = _currentChildIndex;
                                 self.currentChildIndex =
                                 [self.childViewControllers
                                  indexOfObject:childController];
                                 self.currentChildController = childController;
                                 self.previousPageNumber = pageNumber;
                             }

            ];
        }
    }
}  /* transitionToAuxControllerForPage */

- (void)addAuxController:(UIViewController *)controller animated:(BOOL)animated {
    BOOL   animatePageControl = NO;

    if (  [controller isKindOfClass:[SelectionViewController class]]
       || [controller isKindOfClass:[SelectionTableViewController class]]) animatePageControl = YES;

    if ([self.childViewControllers count] > 0) {
        UIViewController * currentChild;  // = self.childViewControllers[_currentChildIndex];

        [self addChildViewController:controller];
        [controller didMoveToParentViewController:self];

        [self updateChildContainerForNewController:controller];

        if (USE_CURL_DOWN_FOR_PUSH) {
            [self transitionFromViewController:currentChild
                              toViewController:controller
                                      duration:(animated ? 0.5 : 0.0)
                                       options:UIViewAnimationOptionTransitionCurlDown
                                    animations:^(void) {}

                                    completion:^(BOOL finished) {
                                        self.previousChildIndex = _currentChildIndex;
                                        self.currentChildIndex =
                                        [self.childViewControllers
                                         indexOfObject:controller];
                                        self.currentChildController = controller;
                                        if (animatePageControl) [self animatePageControl];
                                    }

            ];
        } else {
            [_childContentContainer addSubview:controller.view];

            CGRect   newChildBeginFrame = controller.view.frame;
            CGRect   newChildEndFrame   = newChildBeginFrame;

            newChildBeginFrame.origin.y = self.view.frame.size.height;
            controller.view.frame       = newChildBeginFrame;

            [UIView animateWithDuration:0.5
                             animations:^{
                                 controller.view.frame = newChildEndFrame;
                             }

                             completion:^(BOOL finished) {
                                 self.previousChildIndex = _currentChildIndex;
                                 self.currentChildIndex =
                                 [self.childViewControllers
                                  indexOfObject:controller];
                                 self.currentChildController = controller;
                                 if (animatePageControl) [self animatePageControl];
                             }

            ];
        }
    } else {
        [self addChildViewController:controller];
        [controller didMoveToParentViewController:self];

        [self updateChildContainerForNewController:controller];

        [_childContentContainer insertSubview:controller.view belowSubview:_pageControl];
        self.currentChildIndex      = [self.childViewControllers indexOfObject:controller];
        self.previousChildIndex     = 0;
        self.previousPageNumber     = 0;
        self.currentChildController = controller;
    }
}  /* addAuxController */

- (void)removeAuxController:(UIViewController *)controller animated:(BOOL)animated {
    if (controller.parentViewController == self) {
        BOOL   animatePageControl = NO;

        if (  [controller isKindOfClass:[SelectionViewController class]]
           || [controller isKindOfClass:[SelectionTableViewController class]]) animatePageControl = YES;

        if ([self.childViewControllers count] > 0) {
// NSUInteger controllerIndex = [self.childViewControllers indexOfObject:controller];

            if (USE_CURL_DOWN_FOR_PUSH) {
                UIViewController * destinationController = (UIViewController *)self.childViewControllers[_previousChildIndex];

                [self transitionFromViewController:controller
                                  toViewController:destinationController
                                          duration:(animated ? 0.5 : 0.0)
                                           options:UIViewAnimationOptionTransitionCurlUp
                                        animations:^(void) {}

                                        completion:^(BOOL finished) {
                                            [controller willMoveToParentViewController:nil];
                                            [controller removeFromParentViewController];
                                            self.currentChildIndex = _previousChildIndex;
                                            self.previousChildIndex = -1;
                                            [self updateChildContainerForNewController:destinationController];
                                            self.currentChildController = destinationController;
                                            if (animatePageControl) [self animatePageControl];
                                        }

                ];
            } else {
                CGRect   newChildEndFrame = controller.view.frame;

                newChildEndFrame.origin.y = self.view.frame.size.height;

                [UIView animateWithDuration:0.5
                                 animations:^{
                                     controller.view.frame = newChildEndFrame;
                                 }

                                 completion:^(BOOL finished) {
                                     self.currentChildIndex = _previousChildIndex;
                                     self.previousChildIndex = -1;
                                     [controller.view removeFromSuperview];
                                     [controller willMoveToParentViewController:nil];
                                     [controller removeFromParentViewController];
                                     self.currentChildController = self.childViewControllers[_currentChildIndex];
                                     if (animatePageControl) [self animatePageControl];
                                 }

                ];
            }
        } else {
            [UIView transitionWithView:_childContentContainer
                              duration:(animated ? 0.5 : 0.0)
                               options:UIViewAnimationOptionTransitionCurlUp
                            animations:^{
                                [controller.view removeFromSuperview];
                            }

                            completion:^(BOOL finished) {
                                [controller willMoveToParentViewController:nil];
                                [controller removeFromParentViewController];
                                self.childRootView = nil;
                                [self.view.subviews
                                 enumerateObjectsUsingBlock:
                                ^(id obj, NSUInteger idx, BOOL * stop) {
                        [(UIView *)obj setUserInteractionEnabled : YES];
                                }

                                ];
                                self.currentChildIndex = -1;
                                self.previousChildIndex = -1;
                                self.currentChildController = nil;
                                if (animatePageControl) [self animatePageControl];
                            }

            ];
        }
    }
}  /* removeAuxController */

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if ([parent isMemberOfClass:[ButtonEditingViewController class]]) self.buttonEditor = (ButtonEditingViewController *)parent;
    else self.buttonEditor = nil;
}

#pragma mark - Managing the keyboard

- (void)keyboardWillShow:(NSNotification *)note {
    UIView * firstResponder = [UIView firstResponderInView:_childContentContainer];

    if ([firstResponder isMemberOfClass:[MSPickerInputButton class]]) return;

    CGFloat   keyboardTop =
        [[note userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;

    if (ValueIsNotNil(firstResponder)) {
        CGRect   rectInWindow = [firstResponder convertRect:firstResponder.frame toView:nil];

// CGFloat rectBottom = rectInWindow.origin.y + rectInWindow.size.height;
        MSLogDebug(@"%@\n\tfirst responder rect as report by window:%@",
                   ClassTagString, CGRectString(rectInWindow));
    }

    CGFloat   duration =
        [(NSNumber *)[note userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect   frame = self.view.frame;

    frame.origin.y -= (frame.size.height - keyboardTop);

    [UIView animateWithDuration:duration
                     animations:^{
                         self.view.frame = frame;
                     }

    ];
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGRect   frame = self.view.frame;

    if (frame.origin.y == 0) return;

    frame.origin.y = 0;

    CGFloat   duration =
        [(NSNumber *)[note userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];

    [UIView animateWithDuration:duration
                     animations:^{
                         self.view.frame = frame;
                     }

    ];
}

#pragma mark - View loading and unloading

- (void)viewDidLoad {
    [super viewDidLoad];
    [NotificationCenter addObserver:self
                           selector:@selector(keyboardWillShow:)
                               name:UIKeyboardWillShowNotification
                             object:self.view.window];
    [NotificationCenter addObserver:self
                           selector:@selector(keyboardWillHide:)
                               name:UIKeyboardWillHideNotification
                             object:self.view.window];
    self.currentChildIndex  = -1;
    self.previousChildIndex = -1;
    self.previousPageNumber = -1;

    if (_buttonModel) {
        self.buttonView         = (ButtonView *)[ButtonView viewWithModel:_buttonModel];
        _buttonView.editingMode = REButtonEditingMode;
        [self setButtonViewStateFromPresentedState];
        [self.view addSubview:_buttonView];

        CGPoint             buttonLocation  = CGPointMake(160, 124);
        CGFloat             xDiff           = buttonLocation.x - _buttonView.center.x;
        CGFloat             yDiff           = buttonLocation.y - _buttonView.center.y;
        CGAffineTransform   transform       = CGAffineTransformMakeTranslation(xDiff, yDiff);
        CGFloat             buttonMaxHeight = 130;

        if (_buttonView.bounds.size.height > buttonMaxHeight) {
            CGFloat   scale = buttonMaxHeight / _buttonView.bounds.size.height;

            transform = CGAffineTransformScale(transform, scale, scale);
        }

        _buttonView.transform = transform;
        [self addAuxController:[self childControllerForPage:0] animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setButtonView:nil];
    [self setTopToolbar:nil];
    [self setChildContentContainer:nil];
    [self setBackgroundImageView:nil];
    [self setPageControl:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

- (void)setRemoteElement:(Button *)remoteElement {
    if ([remoteElement isKindOfClass:[Button class]]) {
        [super setRemoteElement:remoteElement];
        self.buttonModel = (Button *)self.remoteElement;
    }
}

@end
