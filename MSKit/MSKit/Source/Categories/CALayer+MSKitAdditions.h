//
//  CALayer+MSKitAdditions.h
//  Remote
//
//  Created by Jason Cardwell on 4/12/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CALayer (MSKitAdditions)

- (UIImage *)renderedImage;

- (void)setValue:(id)value 
      forKeyPath:(NSString *)keyPath 
        duration:(CFTimeInterval)duration 
           delay:(CFTimeInterval)delay;

@end
