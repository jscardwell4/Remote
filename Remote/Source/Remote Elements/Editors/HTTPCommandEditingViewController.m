//
// HTTPCommandEditingViewController.m
// Remote
//
// Created by Jason Cardwell on 4/5/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "HTTPCommandEditingViewController.h"

@interface HTTPCommandEditingViewController ()
@property (strong, nonatomic) IBOutlet UITextView * textView;

@end

@implementation HTTPCommandEditingViewController
@synthesize textView = _textView, command = _command;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textView.text = [self.command.url absoluteString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self setTextView:nil];
    if ([self isViewLoaded] && self.view.window == nil) self.view = nil;
}

- (BOOL)           textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
    if ('\n' == [text characterAtIndex:[text length] - 1]) {
        textView.text = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [textView resignFirstResponder];

        return NO;
    } else
        return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
// _doneEditingTitleButton.hidden = NO;
//
// CGRect frame = _titleTextView.frame;
// frame.size.width -= _doneEditingTitleButton.frame.size.width;
// [UIView animateWithDuration:0.5 animations:^{_titleTextView.frame = frame;}];
}

// - (BOOL)textViewShouldEndEditing:(UITextView *)textView {
// return _doneEditingTitleButton.hidden;
// }

@end
