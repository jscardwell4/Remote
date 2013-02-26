//
// ButtonViewLayer.h
// iPhonto
//
// Created by Jason Cardwell on 4/19/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class   ButtonView;

@interface ButtonViewLayer : CALayer

@property (nonatomic, weak) ButtonView * buttonView;

@property (nonatomic, assign) CGSize   cornerRadii;

- (void)updateContent;

@end
