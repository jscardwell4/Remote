//
//  MSResizingLayer.h
//  Remote
//
//  Created by Jason Cardwell on 4/17/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface MSResizingLayer : CAShapeLayer

- (id)initWithSuperlayer:(CALayer *)layer;

@end

@interface MSGLossLayer : MSResizingLayer

@end
