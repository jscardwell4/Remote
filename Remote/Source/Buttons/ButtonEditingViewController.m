#import "ButtonEditingViewController.h"
#import "RemoteElementEditingViewController_Private.h"
#import "ControlStateSet.h"
#import "DetailedButtonEditingViewController.h"
#import "Button.h"
#import "ButtonView.h"
#import "Command.h"
#import "IRCode.h"
#import "ComponentDevice.h"
#import <QuartzCore/QuartzCore.h>
#import "StoryboardProxy.h"

#define AUTO_LAUNCH_DETAIL_EDITOR NO
#define REPLACE_BUTTON_COMMAND    NO
#define MIN_BUTTON_BOUNDS         CGRectMake(0, 0, 14, 14)

static int             ddLogLevel = LOG_LEVEL_DEBUG | LOG_FLAG_SELECTOR;
static NSArray const * styleNames;

typedef NS_OPTIONS (NSUInteger, ResizeTouchDirection) {
    ResizeTouchDirectionUndefined = 0 << 0,
        ResizeTouchDirectionUp    = 1 << 0,
        ResizeTouchDirectionDown  = 1 << 1,
        ResizeTouchDirectionLeft  = 1 << 2,
        ResizeTouchDirectionRight = 1 << 3
};

static CGRect   childFrame = {.origin.x = 0, .origin.y = 0, .size.width = 320, .size.height = 480};

@interface ButtonEditingViewController () <MSCheckboxViewDelegate, MSTouchReporterViewDelegate, UIPickerViewDelegate>

@property (nonatomic, strong) ButtonView                   * buttonView;
@property (nonatomic, strong) CALayer                      * darknessFilterLayer;
@property (nonatomic, strong) IBOutlet UIToolbar           * topToolbar;
@property (nonatomic, strong) IBOutlet UIToolbar           * buttonActionsToolbar;
@property (strong, nonatomic) IBOutlet UIImageView         * backgroundImageView;
@property (nonatomic, strong) IBOutlet MSView              * buttonStateSelectionContainer;
@property (strong, nonatomic) IBOutlet MSTouchReporterView * touchReporter;
@property (nonatomic, strong) IBOutlet MSCheckboxView      * selectedStateCheckbox;
@property (nonatomic, strong) IBOutlet MSCheckboxView      * highlightedStateCheckbox;
@property (nonatomic, strong) IBOutlet MSCheckboxView      * disabledStateCheckbox;
@property (strong, nonatomic) IBOutlet UIPickerView        * stylePicker;
@property (strong, nonatomic) IBOutlet UIButton            * styleButton;
@property (strong, nonatomic) IBOutlet MSCheckboxView      * applyGlossCheckbox;
@property (strong, nonatomic) IBOutlet MSCheckboxView      * drawBorderCheckbox;
@property (strong, nonatomic) CALayer                      * resizeLayer;
@property (strong, nonatomic) UITouch                      * resizeTouch;
@property (weak, nonatomic) Button                         * buttonModel;

- (IBAction)editButtonDetails:(id)sender;
- (IBAction)editButtonStyle:(id)sender;
- (IBAction)resizeButton:(UIButton *)sender;

- (CGRect)rectWithEdgeOnPoint:(CGPoint)point;

@property (nonatomic, readonly)
struct {
    BOOL                   resizingButton;
    CGPoint                initialTouchLocation;
    ResizeTouchDirection   resizeTouchDirection;
}
flags;

@end

@implementation ButtonEditingViewController
@synthesize
flags,
resizeTouch   = _resizeTouch,
touchReporter = _touchReporter,
applyGlossCheckbox,
drawBorderCheckbox,
resizeLayer = _resizeLayer,
styleButton = _styleButton,
stylePicker = _stylePicker,
buttonModel = _buttonModel,
backgroundImageView,
buttonView = _buttonView,
topToolbar,
buttonActionsToolbar,
darknessFilterLayer,
buttonStateSelectionContainer,
selectedStateCheckbox,
highlightedStateCheckbox,
disabledStateCheckbox,
presentedControlState = _presentedControlState;

- (void)viewDidAppear:(BOOL)animated {
    static BOOL   buttonEditorHasAutoLaunched = NO;

    if (AUTO_LAUNCH_DETAIL_EDITOR && !buttonEditorHasAutoLaunched) {
        if (REPLACE_BUTTON_COMMAND) {
            ComponentDevice * tv =
                [ComponentDevice fetchComponentDeviceWithName:@"Samsung TV"
                                                    inContext:_buttonModel.managedObjectContext];
            SendIRCommand * command = (SendIRCommand *)tv.onCommand;

            _buttonModel.command = command;
        }

        [self editButtonDetails:nil];
        buttonEditorHasAutoLaunched = YES;
    }
}

+ (void)initialize {
    if (self == [ButtonEditingViewController class]) styleNames = @[@"Custom", @"Rounded Rectangle", @"Oval", @"Rectangle", @"Triangle", @"Diamond"];
}

- (id)initWithButton:(Button *)button
            delegate:(UIViewController <RemoteElementEditingViewControllerDelegate> *)delegate {

// self = [super initWithModel:button delegate:delegate];
    return self;
}

- (void)viewDidLoad {
    if (ValueIsNotNil(_buttonModel)) {
        self.buttonView                    = (ButtonView *)[ButtonView remoteElementViewWithElement:_buttonModel];
        _buttonView.editingMode            = EditingModeEditingButton;
        _buttonView.userInteractionEnabled = NO;
        [_touchReporter addSubview:_buttonView];

        CGPoint             buttonCenter = _buttonView.center;
        CGPoint             viewCenter   = CGRectGetCenter(_touchReporter.bounds);
        CGFloat             xDiff        = viewCenter.x - buttonCenter.x;
        CGFloat             yDiff        = viewCenter.y - buttonCenter.y;
        CGAffineTransform   translate    = CGAffineTransformMakeTranslation(xDiff, yDiff);

        _buttonView.transform = translate;

        disabledStateCheckbox.checked = !_buttonModel.enabled;

        selectedStateCheckbox.checked = _buttonModel.selected;

        applyGlossCheckbox.checked = _buttonModel.style & ButtonStyleApplyGloss;
        drawBorderCheckbox.checked = _buttonModel.style & ButtonStyleDrawBorder;

        self.resizeLayer             = [CALayer layer];
        _resizeLayer.bounds          = _buttonView.bounds;
        _resizeLayer.position        = viewCenter;
        _resizeLayer.backgroundColor = [[[UIColor purpleColor] colorWithAlphaComponent:0.5] CGColor];
        _resizeLayer.hidden          = YES;
        [_touchReporter.layer addSublayer:_resizeLayer];
    }
}

- (void)setRemoteElement:(RemoteElement *)remoteElement {
    [super setRemoteElement:remoteElement];
    self.buttonModel = (Button *)self.remoteElement;
}

- (void)checkboxValueDidChange:(MSCheckboxView *)checkbox checked:(BOOL)checked {
    UIControlState   toggledState;

    if (checkbox == self.selectedStateCheckbox) {
        self.buttonView.selected = checked;
        toggledState             = UIControlStateSelected;
        if (checked) _presentedControlState |= toggledState;
        else _presentedControlState &= ~toggledState;
    } else if (checkbox == self.highlightedStateCheckbox) {
        self.buttonView.highlighted = checked;
        toggledState                = UIControlStateHighlighted;
        if (checked) _presentedControlState |= toggledState;
        else _presentedControlState &= ~toggledState;
    } else if (checkbox == self.disabledStateCheckbox) {
        self.buttonView.enabled = !checked;
        toggledState            = UIControlStateDisabled;
        if (checked) _presentedControlState |= toggledState;
        else _presentedControlState &= ~toggledState;
    } else if (checkbox == self.applyGlossCheckbox) {
        if (checked) _buttonModel.style |= ButtonStyleApplyGloss;
        else _buttonModel.style &= ~ButtonStyleApplyGloss;

        [_buttonView setNeedsDisplay];
    } else if (checkbox == self.drawBorderCheckbox) {
        if (checked) _buttonModel.style |= ButtonStyleDrawBorder;
        else _buttonModel.style &= ~ButtonStyleDrawBorder;

        [_buttonView setNeedsDisplay];
    }
}

#pragma mark - Managing auxiliary view controllers

- (void)addAuxController:(UIViewController *)controller animated:(BOOL)animated {
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    controller.view.frame = childFrame;

    if ([self.childViewControllers count] > 1) {
        NSUInteger         currentChildIndex      = [self.childViewControllers count] - 2;
        UIViewController * currentChildController =
            (UIViewController *)self.childViewControllers[currentChildIndex];

        [self transitionFromViewController:currentChildController
                          toViewController:controller
                                  duration:(animated ? 0.5 : 0.0)
                                   options:UIViewAnimationOptionTransitionCurlDown
                                animations:nil
                                completion:nil];
    } else {
        [self.view.subviews
         enumerateObjectsUsingBlock:
         ^(id obj, NSUInteger idx, BOOL * stop) {
            [(UIView *)obj setUserInteractionEnabled : NO];
        }

        ];
        [UIView transitionWithView:self.view
                          duration:(animated ? 0.5 : 0.0)
                           options:UIViewAnimationOptionTransitionCurlDown
                        animations:^{[self.view
                            addSubview:controller.view]; }

                        completion:nil];
    }
}

- (void)removeAuxController:(UIViewController *)controller animated:(BOOL)animated {
    if (controller.parentViewController == self) {
        if ([self.childViewControllers count] > 1) {
            NSUInteger         controllerIndex       = [self.childViewControllers indexOfObject:controller];
            UIViewController * destinationController =
                (UIViewController *)self.childViewControllers[controllerIndex - 1];

            [self transitionFromViewController:controller
                              toViewController:destinationController
                                      duration:(animated ? 0.5 : 0.0)
                                       options:UIViewAnimationOptionTransitionCurlUp
                                    animations:nil
                                    completion:^(BOOL finished) {
                                        [controller willMoveToParentViewController:nil];
                                        [controller removeFromParentViewController];
                                    }

            ];
        } else {
            [UIView transitionWithView:self.view
                              duration:(animated ? 0.5 : 0.0)
                               options:UIViewAnimationOptionTransitionCurlUp
                            animations:^{
                                [controller.view removeFromSuperview];
                            }

                            completion:^(BOOL finished) {
                                [controller willMoveToParentViewController:nil];
                                [controller removeFromParentViewController];
                                [self.view.subviews
                                 enumerateObjectsUsingBlock:
                                ^(id obj, NSUInteger idx, BOOL * stop) {
                        [(UIView *)obj setUserInteractionEnabled : YES];
                                }

                                ];
                                [self.buttonView setNeedsDisplay];
                            }

            ];
        }
    }
}

#pragma mark - Actions
- (UIControlState)presentedControlState {
    UIControlState   controlState = UIControlStateNormal;

    if (self.selectedStateCheckbox.checked) controlState |= UIControlStateSelected;

    if (self.highlightedStateCheckbox.checked) controlState |= UIControlStateHighlighted;

    if (self.disabledStateCheckbox.checked) controlState |= UIControlStateDisabled;

    return controlState;
}

- (void)setPresentedControlState:(UIControlState)presentedControlState {
    if (presentedControlState & UIControlStateSelected) self.selectedStateCheckbox.checked = YES;

    if (presentedControlState & UIControlStateHighlighted) self.highlightedStateCheckbox.checked = YES;

    if (presentedControlState & UIControlStateDisabled) self.disabledStateCheckbox.checked = YES;

    _presentedControlState = presentedControlState;
}

- (IBAction)editButtonDetails:(id)sender {
    NSDictionary                        * initialValues  = @{kDetailedButtonEditingButtonKey : CollectionSafeValue(self.remoteElement), kDetailedButtonEditingControlStateKey : CollectionSafeValue(@(_presentedControlState))};
    DetailedButtonEditingViewController * detailedEditor =
        [StoryboardProxy detailedButtonEditingViewController];

    [detailedEditor initializeEditorWithValues:initialValues];
    [self addAuxController:detailedEditor animated:YES];
}

- (IBAction)editButtonStyle:(id)sender {
    if (_styleButton.selected) {
        _styleButton.selected = NO;

        CGRect   frame = _stylePicker.frame;

        frame.origin.y = self.view.frame.size.height;
        [UIView animateWithDuration:0.5
                         animations:^{_stylePicker.frame = frame; }

        ];
    } else {
        _styleButton.selected = YES;

        NSUInteger   currentSelection = _buttonModel.style & ButtonShapeMask;

        [_stylePicker selectRow:currentSelection inComponent:0 animated:NO];

        CGRect   frame = _stylePicker.frame;

        frame.origin.y -= frame.size.height + 44.0;
        [UIView animateWithDuration:0.5
                         animations:^{_stylePicker.frame = frame; }

        ];
    }
}

- (IBAction)resizeButton:(UIButton *)sender {
    sender.selected                       = !sender.selected;
    flags.resizingButton                  = sender.selected;
    _resizeLayer.hidden                   = !flags.resizingButton;
    _touchReporter.userInteractionEnabled = flags.resizingButton;
    if (flags.resizingButton) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _resizeLayer.bounds   = _buttonView.bounds;
        _resizeLayer.position = CGRectGetCenter(_touchReporter.bounds);
        [CATransaction commit];
    } else {
        [_buttonView resizeBoundsToSize:_resizeLayer.bounds.size];

        CGAffineTransform   inversion    = CGAffineTransformInvert(_buttonView.transform);
        CGPoint             buttonCenter = CGPointApplyAffineTransform(CGRectGetCenter(_touchReporter.bounds),
                                                                       inversion);

        _buttonView.center = buttonCenter;
    }
}

- (CGRect)rectWithEdgeOnPoint:(CGPoint)point {
    CGRect   currentFrame = _resizeLayer.frame;
// CGRect minRect = MIN_BUTTON_BOUNDS;
    BOOL      setVerticalEdge = NO, setHorizontalEdge = NO;
    CGFloat   curMinX         = CGRectGetMinX(currentFrame);
    CGFloat   curMinY         = CGRectGetMinY(currentFrame);
    CGFloat   curMaxX         = CGRectGetMaxX(currentFrame);
    CGFloat   curMaxY         = CGRectGetMaxY(currentFrame);
    CGFloat   newMinX         = CGFLOAT_MAX, newMinY = CGFLOAT_MAX, newMaxX = CGFLOAT_MIN, newMaxY = CGFLOAT_MIN;

// CGFloat touchX = point.x;
// CGFloat touchY = point.y;
    CGRect   upperLeftQuad, upperRightQuad, lowerLeftQuad, lowerRightQuad, leftHalf, rightHalf;

    CGRectDivide(_touchReporter.bounds,
                 &leftHalf,
                 &rightHalf,
                 CGRectGetMidX(_touchReporter.bounds),
                 CGRectMinXEdge);
    CGRectDivide(leftHalf,
                 &upperLeftQuad,
                 &lowerLeftQuad,
                 leftHalf.size.height / 2.0,
                 CGRectMinYEdge);
    CGRectDivide(rightHalf,
                 &upperRightQuad,
                 &lowerRightQuad,
                 rightHalf.size.height / 2.0,
                 CGRectMinYEdge);
    if (CGRectContainsPoint(currentFrame, point)) {
        if (CGRectContainsPoint(leftHalf, point)) {
            setVerticalEdge =
                (  (flags.resizeTouchDirection & ResizeTouchDirectionRight)
                || (flags.resizeTouchDirection & ResizeTouchDirectionLeft)) ? YES : NO;

            newMinX = setVerticalEdge ? point.x : curMinX;
            newMaxX = curMaxX;
            if (CGRectContainsPoint(upperLeftQuad, point)) {
                setHorizontalEdge =
                    (  (flags.resizeTouchDirection & ResizeTouchDirectionDown)
                    || (flags.resizeTouchDirection & ResizeTouchDirectionLeft)) ? YES : NO;

                newMinY = setHorizontalEdge ? point.y : curMinY;
                newMaxY = curMaxY;
            } else if (CGRectContainsPoint(lowerLeftQuad, point)) {
                setHorizontalEdge =
                    (  (flags.resizeTouchDirection & ResizeTouchDirectionUp)
                    || (flags.resizeTouchDirection & ResizeTouchDirectionLeft)) ? YES : NO;

                newMaxY = setHorizontalEdge ? point.y : curMaxY;
                newMinY = curMinY;
            } else
                DDLogWarn(@"%@\n\tsomething went wrong, neither upper left nor lower left "
                          "contains point %@", ClassTagSelectorString, CGPointString(point));
        } else if (CGRectContainsPoint(rightHalf, point)) {
            setVerticalEdge =
                (  (flags.resizeTouchDirection & ResizeTouchDirectionRight)
                || (flags.resizeTouchDirection & ResizeTouchDirectionLeft)) ? YES : NO;

            newMaxX = setVerticalEdge ? point.x : curMaxX;
            newMinX = curMinX;
            if (CGRectContainsPoint(upperRightQuad, point)) {
                setHorizontalEdge =
                    (  (flags.resizeTouchDirection & ResizeTouchDirectionDown)
                    || (flags.resizeTouchDirection & ResizeTouchDirectionLeft)) ? YES : NO;

                newMinY = setHorizontalEdge ? point.y : curMinY;
                newMaxY = curMaxY;
            } else if (CGRectContainsPoint(lowerRightQuad, point)) {
                setHorizontalEdge =
                    (  (flags.resizeTouchDirection & ResizeTouchDirectionUp)
                    || (flags.resizeTouchDirection & ResizeTouchDirectionLeft)) ? YES : NO;

                newMaxY = setHorizontalEdge ? point.y : curMaxY;
                newMinY = curMinY;
            } else
                DDLogWarn(@"%@\n\tsomething went wrong, neither upper right nor lower right contains"
                          "point %@", ClassTagSelectorString, CGPointString(point));
        } else
                DDLogWarn(@"%@\n\tsomething went wrong, neither left nor right half contains point %@",
                      ClassTagSelectorString, CGPointString(point));
    } else {
// setVerticalEdge = YES;
// setHorizontalEdge = YES;

        newMinX = MIN(point.x, curMinX);
        newMinY = MIN(point.y, curMinY);
        newMaxX = MAX(point.x, curMaxX);
        newMaxY = MAX(point.y, curMaxY);
    }

    CGRect   newFrame = CGRectMake(newMinX, newMinY, newMaxX - newMinX, newMaxY - newMinY);

    return newFrame;
}  /* rectWithEdgeOnPoint */

#pragma mark - MSTouchReporterViewDelegate
- (void)touchReporter:(MSTouchReporterView *)reporter
         touchesEnded:(NSSet *)touches
            withEvent:(UIEvent *)event {
    if (flags.resizingButton) {
        self.resizeTouch           = nil;
        flags.resizeTouchDirection = ResizeTouchDirectionUndefined;
        flags.initialTouchLocation = CGPointMake(-1, -1);
    }
}

- (void)touchReporter:(MSTouchReporterView *)reporter
     touchesCancelled:(NSSet *)touches
            withEvent:(UIEvent *)event {
    if (flags.resizingButton) {
        self.resizeTouch           = nil;
        flags.resizeTouchDirection = ResizeTouchDirectionUndefined;
        flags.initialTouchLocation = CGPointMake(-1, -1);
    }
}

- (void)touchReporter:(MSTouchReporterView *)reporter
         touchesBegan:(NSSet *)touches
            withEvent:(UIEvent *)event {
    if (flags.resizingButton) {
        UITouch * t = [touches anyObject];
        CGPoint   p = [t locationInView:reporter];

        if (CGRectContainsPoint(_touchReporter.bounds, p)) {
            self.resizeTouch           = t;
            flags.initialTouchLocation = p;
            flags.resizeTouchDirection = ResizeTouchDirectionUndefined;
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            _resizeLayer.frame = [self rectWithEdgeOnPoint:p];
            [CATransaction commit];
        }
    }
}

- (void)touchReporter:(MSTouchReporterView *)reporter
         touchesMoved:(NSSet *)touches
            withEvent:(UIEvent *)event {
    if (flags.resizingButton) {
        UITouch * t = [touches member:_resizeTouch];

        if (ValueIsNil(t)) return;

        CGPoint                p                  = [t locationInView:reporter];
        ResizeTouchDirection   horizontalMovement = ResizeTouchDirectionUndefined;
        ResizeTouchDirection   verticalMovement   = ResizeTouchDirectionUndefined;
        CGFloat                deltaX             = 0, deltaY = 0;

        if (p.x < flags.initialTouchLocation.x) {
            deltaX             = flags.initialTouchLocation.x - p.x;
            horizontalMovement = ResizeTouchDirectionLeft;
        } else if (p.x > flags.initialTouchLocation.x) {
            deltaX             = p.x - flags.initialTouchLocation.x;
            horizontalMovement = ResizeTouchDirectionRight;
        }

        if (p.y < flags.initialTouchLocation.y) {
            deltaY           = flags.initialTouchLocation.y - p.y;
            verticalMovement = ResizeTouchDirectionUp;
        } else if (p.y > flags.initialTouchLocation.y) {
            deltaY           = p.y - flags.initialTouchLocation.y;
            verticalMovement = ResizeTouchDirectionDown;
        }

        if (roundf(deltaX) == roundf(deltaY)) flags.resizeTouchDirection = horizontalMovement | verticalMovement;
        else if (deltaX > deltaY) flags.resizeTouchDirection = horizontalMovement;
        else flags.resizeTouchDirection = verticalMovement;

        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _resizeLayer.frame = [self rectWithEdgeOnPoint:p];
        [CATransaction commit];
    }
}

#pragma mark - UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [styleNames count];
}

#pragma mark - UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    ButtonStyle   style = (ButtonStyle)_buttonModel.style;

    style             &= ButtonStyleMask;
    style             |= row;
    _buttonModel.style = style;
    [_buttonView setNeedsDisplay];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    return styleNames[row];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setButtonView:nil];
    [self setBackgroundImageView:nil];
    [self setDarknessFilterLayer:nil];
    [self setTopToolbar:nil];
    [self setButtonActionsToolbar:nil];
    [self setBackgroundImageView:nil];
    [self setButtonStateSelectionContainer:nil];
    [self setSelectedStateCheckbox:nil];
    [self setHighlightedStateCheckbox:nil];
    [self setDisabledStateCheckbox:nil];
    [self setStylePicker:nil];
    [self setStyleButton:nil];
    [self setApplyGlossCheckbox:nil];
    [self setDrawBorderCheckbox:nil];
    [self setTouchReporter:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

@end
