//
//  MSScrollWheel.m
//  Remote
//
//  Created by Jason Cardwell on 5/4/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "MSKitMacros.h"
#import "MSScrollWheel.h"
#import "MSKitGeometryFunctions.h"

#pragma mark Math
// Return a point with respect to a given origin
CGPoint centeredPoint(CGPoint pt, CGPoint origin) {
	return CGPointMake(pt.x - origin.x, pt.y - origin.y);
}

// Return the angle of a point with respect to a given origin
float getangle (CGPoint p1, CGPoint c1) {
    
	// SOH CAH TOA 
	CGPoint p = centeredPoint(p1, c1);
	float h = ABS(sqrt(p.x * p.x + p.y * p.y));
	float a = p.x;
	float baseAngle = acos(a/h) * 180.0f / M_PI;
	
	// Above 180
	if (p1.y > c1.y) baseAngle = 360.0f - baseAngle;
	
	return baseAngle;
}

// Return whether a point falls within the radius from a given origin
BOOL pointInsideRadius(CGPoint p1, float r, CGPoint c1) {
    
	CGPoint pt = centeredPoint(p1, c1);
	float xsquared = pt.x * pt.x;
	float ysquared = pt.y * pt.y;
	float h = ABS(sqrt(xsquared + ysquared));
	if (((xsquared + ysquared) / h) < r) return YES;
	return NO;
}

@implementation MSScrollWheel

@synthesize value;
@synthesize theta;
@synthesize label;
@synthesize labelTextGenerator;

#pragma mark Object initialization
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
	if (self) {
		// This control uses a fixed 200x200 sized frame
		self.frame = CGRectMake(0.0f, 0.0f, 200.0f, 200.0f); 
		self.center = CGRectGetCenter(frame);
		
		// Add the touchwheel art
/*
		UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScrollWheel.png"]];
		[self addSubview:iv];
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(80, 80, 40, 40)];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:20];
    [self addSubview:label];
*/
	}
	
	return self;
    
}

- (id)init {

	return [self initWithFrame:CGRectZero];

}

+ (id)scrollWheel {
    
	return [[self alloc] init];

}

- (void)setValue:(float)aValue {
    value = aValue;
    
    if (labelTextGenerator)
        self.label.text = labelTextGenerator(value);
}

#pragma mark Touch tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
	CGPoint p = [touch locationInView:self];
	CGPoint cp = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
	// self.value = 0.0f; // Uncomment to set each touch to a separate value calculation
	
	// First touch must touch the gray part of the wheel
	if (!pointInsideRadius(p, cp.x, cp)) return NO;
	if (pointInsideRadius(p, 30.0f, cp)) return NO;
    
	// Set the initial angle
	self.theta = getangle([touch locationInView:self], cp);
    
	// Establish touch down
	[self sendActionsForControlEvents:UIControlEventTouchDown];
    
	return YES;
    
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	
	CGPoint p = [touch locationInView:self];
	CGPoint cp = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
	
	// Touch updates
	if (CGRectContainsPoint(self.frame, p))
        [self sendActionsForControlEvents:UIControlEventTouchDragInside];
    else 
        [self sendActionsForControlEvents:UIControlEventTouchDragOutside];		
    
	// falls outside too far, with boundary of 50 pixels. Inside strokes treated as touched
	if (!pointInsideRadius(p, cp.x + 50.0f, cp)) return NO;
	
	float newtheta = getangle([touch locationInView:self], cp);
	float dtheta = newtheta - self.theta;
    
	// correct for edge conditions
	int ntimes = 0;
	while ((ABS(dtheta) > 300.0f)  && (ntimes++ < 4))
		if (dtheta > 0.0f) dtheta -= 360.0f; else dtheta += 360.0f;
    
	// Update current values
	self.value -= dtheta / 360.0f;
	self.theta = newtheta;
    
	// Send value changed alert
	[self sendActionsForControlEvents:UIControlEventValueChanged];
    
	return YES;
    
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    // Test if touch ended inside or outside
    CGPoint touchPoint = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, touchPoint))
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    else 
        [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
    
}


- (void)cancelTrackingWithEvent:(UIEvent *)event {
    
	// Cancel
	[self sendActionsForControlEvents:UIControlEventTouchCancel];
    
}

@end

