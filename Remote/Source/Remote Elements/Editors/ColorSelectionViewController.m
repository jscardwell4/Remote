#import "ColorSelectionViewController.h"

static int ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

@interface ColorSelectionViewController ()

@property (strong, nonatomic) IBOutlet UISlider     * redSlider;
@property (strong, nonatomic) IBOutlet UISlider     * greenSlider;
@property (strong, nonatomic) IBOutlet UISlider     * blueSlider;
@property (strong, nonatomic) IBOutlet UISlider     * alphaSlider;
@property (strong, nonatomic) IBOutlet UIView       * colorDisplayView;
@property (strong, nonatomic) IBOutlet UIPickerView * presetPickerView;
@property (strong, nonatomic) IBOutlet UIButton     * presetsButton;
@property (strong, nonatomic) IBOutlet MSView       * slidersContainerView;
@property (strong, nonatomic) IBOutlet UIView       * pickerContainer;
@property (strong, nonatomic)IBOutletCollection(UIButton) NSArray * buttonCollection;
@property (strong, nonatomic) IBOutlet UIView * buttonToolbar;
@property (strong, nonatomic) IBOutlet UIView * contentView;

- (IBAction)sliderValueChanged:(UISlider *)sender;
- (IBAction)reset:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)togglePresets:(id)sender;
- (IBAction)cancel:(id)sender;
- (void)setPresentationForColor:(UIColor *)color;
- (void)updateSliderColors;

@end

static NSArray const * systemColors;
static NSArray const * systemColorNames;

@implementation ColorSelectionViewController
@synthesize buttonCollection = _buttonCollection;
@synthesize buttonToolbar    = _buttonToolbar;
@synthesize contentView      = _contentView;
@synthesize
hidesToolbar         = _hidesToolbar,
pickerContainer      = _pickerContainer,
slidersContainerView = _slidersContainerView,
presetsButton        = _presetsButton,
presetPickerView     = _presetPickerView,
delegate             = _delegate,
colorDisplayView     = _colorDisplayView,
redSlider            = _redSlider,
greenSlider          = _greenSlider,
blueSlider           = _blueSlider,
alphaSlider          = _alphaSlider,
initialColor         = _initialColor;

+ (void)initialize {
    if (self == [ColorSelectionViewController class]) {
        systemColors     = @[[UIColor blackColor], [UIColor darkGrayColor], [UIColor lightGrayColor], [UIColor whiteColor], [UIColor grayColor], [UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], [UIColor yellowColor], [UIColor magentaColor], [UIColor orangeColor], [UIColor purpleColor], [UIColor brownColor], [UIColor clearColor], [UIColor lightTextColor], [UIColor darkTextColor]];
        systemColorNames = @[@"Black", @"Dark Gray", @"Light Gray", @"White", @"Gray", @"Red", @"Green", @"Blue", @"Cyan", @"Yellow", @"Magenta", @"Orange", @"Purple", @"Brown", @"Clear", @"Light Text Color", @"Dark Text Color"];
    }
}

- (void)viewDidLoad {
  [super viewDidLoad];
    if (!_presetPickerView.superview) {
        [_pickerContainer addSubview:_presetPickerView];

        CGPoint   pickerCenter;

        pickerCenter.x           = CGRectGetMidX(_pickerContainer.bounds);
        pickerCenter.y           = CGRectGetMidY(_pickerContainer.bounds);
        _presetPickerView.center = pickerCenter;
    }

    printfobj(stderr, @"pre-sort:%@", _buttonCollection);

    self.buttonCollection = [_buttonCollection sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]]];

    printfobj(stderr, @"post-sort:%@", _buttonCollection);

    if (_hidesToolbar) self.buttonToolbar.hidden = YES;

    self.contentView.frame = self.view.bounds;

    if (_initialColor) [self setPresentationForColor:_initialColor];

    _pickerContainer.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setRedSlider:nil];
    [self setGreenSlider:nil];
    [self setBlueSlider:nil];
    [self setAlphaSlider:nil];
    [self setColorDisplayView:nil];
    [self setPresetPickerView:nil];
    [self setPresetsButton:nil];
    [self setSlidersContainerView:nil];
    [self setPickerContainer:nil];
    [self setButtonCollection:nil];
    [self setButtonToolbar:nil];
    [self setContentView:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

- (void)hideButtonAtIndex:(NSUInteger)index {
    if (index < [_buttonCollection count]) [(UIButton *)_buttonCollection[index] setHidden : YES];
}

- (void)setPresentationForColor:(UIColor *)color {
    _colorDisplayView.backgroundColor = color;

    CGFloat   red, green, blue, alpha, white;

    if (CGColorGetNumberOfComponents([color CGColor]) == 2) {
        [color getWhite:&white alpha:&alpha];
        red = green = blue = white;
    } else
        [color getRed:&red green:&green blue:&blue alpha:&alpha];

    _redSlider.value   = red;
    _greenSlider.value = green;
    _blueSlider.value  = blue;
    _alphaSlider.value = alpha;

    [self updateSliderColors];
}

- (void)setHidesToolbar:(BOOL)hidesToolbar {
    if (hidesToolbar == _hidesToolbar) return;

    _hidesToolbar = hidesToolbar;

    _buttonToolbar.hidden = _hidesToolbar;

    CGSize   size = self.contentView.bounds.size;

    if (!_hidesToolbar) size.height = 272;
    else size.height = CGRectGetMaxY(self.slidersContainerView.frame) + 8;

    [self.contentView resizeBoundsToSize:size];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    [self updateSliderColors];
    _colorDisplayView.backgroundColor = [UIColor colorWithRed:_redSlider.value
                                                        green:_greenSlider.value
                                                         blue:_blueSlider.value
                                                        alpha:_alphaSlider.value];
}

- (IBAction)togglePresets:(id)sender {
    _pickerContainer.hidden = !_pickerContainer.hidden;
    _presetsButton.selected = !_pickerContainer.hidden;
}

- (IBAction)cancel:(id)sender {
    [_delegate colorSelectorDidCancel:self];
}

- (IBAction)reset:(id)sender {
    [self setPresentationForColor:_initialColor];
}

- (IBAction)save:(id)sender {
    [_delegate colorSelector:self didSelectColor:_colorDisplayView.backgroundColor];
}

- (void)updateSliderColors {
    _redSlider.minimumTrackTintColor =
        [UIColor colorWithRed:_redSlider.value green:0 blue:0 alpha:1];
    _redSlider.maximumTrackTintColor   = _redSlider.minimumTrackTintColor;
    _greenSlider.minimumTrackTintColor =
        [UIColor colorWithRed:0 green:_greenSlider.value blue:0 alpha:1];
    _greenSlider.maximumTrackTintColor = _greenSlider.minimumTrackTintColor;
    _blueSlider.minimumTrackTintColor  =
        [UIColor colorWithRed:0 green:0 blue:_blueSlider.value alpha:1];
    _blueSlider.maximumTrackTintColor  = _blueSlider.minimumTrackTintColor;
    _alphaSlider.minimumTrackTintColor =
        [UIColor colorWithRed:1 green:1 blue:1 alpha:_alphaSlider.value];
    _alphaSlider.maximumTrackTintColor = _alphaSlider.minimumTrackTintColor;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    [self setPresentationForColor:systemColors[row]];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 44.0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                        0,
                                                        _colorDisplayView.frame.size.width,
                                                        _colorDisplayView.frame.size.height)];
        view.backgroundColor = [UIColor clearColor];

        MSView * colorBox = [[MSView alloc] initWithFrame:CGRectMake(0, 5, 44, 34)];

        colorBox.style           = MSViewStyleBorderLine;
        colorBox.borderColor     = [UIColor blackColor];
        colorBox.borderThickness = 1.0;
        colorBox.tag             = 1;

        [view addSubview:colorBox];

        UILabel * colorName = [[UILabel alloc] initWithFrame:CGRectMake(54, 0, 200, 44)];

        colorName.baselineAdjustment        = UIBaselineAdjustmentAlignCenters;
        colorName.adjustsFontSizeToFitWidth = YES;
        colorName.backgroundColor           = [UIColor clearColor];
        colorName.tag                       = 2;

        [view addSubview:colorName];
    }

    MSView * colorBox = (MSView *)[view viewWithTag:1];

    colorBox.backgroundColor = systemColors[row];

    UILabel * colorName = (UILabel *)[view viewWithTag:2];

    colorName.text = systemColorNames[row];

    return view;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [systemColors count];
}

@end
