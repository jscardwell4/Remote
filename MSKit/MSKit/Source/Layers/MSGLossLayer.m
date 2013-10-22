//
//  MSGLossLayer.m
//  Remote
//
//  Created by Jason Cardwell on 4/19/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "MSResizingLayer.h"



/*
static UIColor * glossColor;

typedef struct {
    CGFloat color [4];
    CGFloat caustic [4];
    CGFloat expCoefficient;
    CGFloat expScale;
    CGFloat expOffset;
    CGFloat initialWhite;
    CGFloat finalWhite;
} GlossParameters;

CGFloat perceptualGlossFraction(CGFloat * inputComponents);

void perceptualCausticColor(CGFloat * inputComponents, CGFloat * outputComponents);

static void glossInterpolationCallback(void * info, const CGFloat * input, CGFloat * output);

static void drawGlossGradient(UIColor * color, CGRect rect, CGContextRef context);

CGFloat perceptualGlossFraction(CGFloat * inputComponents) {
    const CGFloat REFLECTION_SCALE_NUMBER = 0.2;
    const CGFloat NTSC_RED_FRACTION = 0.299;
    const CGFloat NTSC_GREEN_FRACTION = 0.587;
    const CGFloat NTSC_BLUE_FRACTION = 0.114;
    
    CGFloat glossScale = NTSC_RED_FRACTION * inputComponents [0] + NTSC_GREEN_FRACTION * inputComponents [1] + NTSC_BLUE_FRACTION * inputComponents [2];
    
    glossScale = pow(glossScale, REFLECTION_SCALE_NUMBER);
    return glossScale;
}

void perceptualCausticColor(CGFloat * inputComponents, CGFloat * outputComponents) {
    const CGFloat CAUSTIC_FRACTION = 0.60;
    const CGFloat COSINE_ANGLE_SCALE = 1.4;
    const CGFloat MIN_RED_THRESHOLD = 0.95;
    const CGFloat MAX_BLUE_THRESHOLD = 0.7;
    const CGFloat GRAYSCALE_CAUSTIC_SATURATION = 0.2;
    
    UIColor * source = [UIColor colorWithRed:inputComponents [0] green:inputComponents [1] blue:inputComponents [2] alpha:inputComponents [3]];
    
    CGFloat hue, saturation, brightness, alpha;
    
    [source getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    CGFloat targetHue, targetSaturation, targetBrightness;
    [[UIColor yellowColor] getHue:&targetHue saturation:&targetSaturation brightness:&targetBrightness alpha:&alpha];
    
    if (saturation < 1e-3) {
        hue = targetHue;
        saturation = GRAYSCALE_CAUSTIC_SATURATION;
    }
    
    if (hue > MIN_RED_THRESHOLD)
        hue -= 1.0;
    else if (hue > MAX_BLUE_THRESHOLD)
        [[UIColor magentaColor] getHue:&targetHue saturation:&targetSaturation brightness:&targetBrightness alpha:&alpha];
    
    CGFloat scaledCaustic = CAUSTIC_FRACTION * 0.5 * (1.0 + cos(COSINE_ANGLE_SCALE * M_PI * (hue - targetHue) ) );
    
    UIColor * targetColor = [UIColor colorWithHue:hue * (1.0 - scaledCaustic) + targetHue * scaledCaustic
                                       saturation:saturation
                                       brightness:brightness * (1.0 - scaledCaustic) + targetBrightness * scaledCaustic
                                            alpha:inputComponents [3]];
    [targetColor getRed:&outputComponents [0] green:&outputComponents [1] blue:&outputComponents [2] alpha:&outputComponents [3]];
}

static void glossInterpolationCallback(void * info, const CGFloat * input, CGFloat * output) {
    GlossParameters * params = (GlossParameters *) info;
    
    CGFloat progress = *input;
    
    if (progress < 0.5) {
        progress = progress * 2.0;
        
        progress =
        1.0 - params->expScale * (expf(progress * -params->expCoefficient) - params->expOffset);
        
        CGFloat currentWhite = progress * (params->finalWhite - params->initialWhite) + params->initialWhite;
        
        output [0] = params->color [0] * (1.0 - currentWhite) + currentWhite;
        output [1] = params->color [1] * (1.0 - currentWhite) + currentWhite;
        output [2] = params->color [2] * (1.0 - currentWhite) + currentWhite;
        output [3] = params->color [3] * (1.0 - currentWhite) + currentWhite;
    } else {
        progress = (progress - 0.5) * 2.0;
        
        progress = params->expScale *
        (expf( (1.0 - progress) * -params->expCoefficient) - params->expOffset);
        
        output [0] = params->color [0] * (1.0 - progress) + params->caustic [0] * progress;
        output [1] = params->color [1] * (1.0 - progress) + params->caustic [1] * progress;
        output [2] = params->color [2] * (1.0 - progress) + params->caustic [2] * progress;
        output [3] = params->color [3] * (1.0 - progress) + params->caustic [3] * progress;
    }
}

static void drawGlossGradient(UIColor * color, CGRect rect, CGContextRef context) {
    
    const CGFloat EXP_COEFFICIENT = 1.2;
    const CGFloat REFLECTION_MAX = 0.60;
    const CGFloat REFLECTION_MIN = 0.20;
    
    GlossParameters params;
    
    params.expCoefficient = EXP_COEFFICIENT;
    params.expOffset = expf(-params.expCoefficient);
    params.expScale = 1.0 / (1.0 - params.expOffset);
    
    [color getRed:&params.color[0]
            green:&params.color[1] 
             blue:&params.color[2] 
            alpha:&params.color[3]];
    
    perceptualCausticColor(params.color, params.caustic);
    
    CGFloat glossScale = perceptualGlossFraction(params.color);
    
    params.initialWhite = glossScale * REFLECTION_MAX;
    params.finalWhite = glossScale * REFLECTION_MIN;
    
    static const CGFloat input_value_range [2] = {0, 1};
    static const CGFloat output_value_ranges [8] = {0, 1, 0, 1, 0, 1, 0, 1};
    CGFunctionCallbacks callbacks = {0, glossInterpolationCallback, NULL};
    
    CGFunctionRef gradientFunction = CGFunctionCreate((void *) &params,
                                                      1,
                                                      input_value_range,
                                                      4,
                                                      output_value_ranges,
                                                      &callbacks);
    
    CGPoint endPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) );
    CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect) );
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGShadingRef shading = CGShadingCreateAxial(colorspace, startPoint,
                                                endPoint, gradientFunction, FALSE, FALSE);
    
    CGContextSaveGState(context);
    CGContextClipToRect(context, rect);
    CGContextDrawShading(context, shading);
    CGContextRestoreGState(context);
    
    CGShadingRelease(shading);
    CGColorSpaceRelease(colorspace);
    CGFunctionRelease(gradientFunction);
}


*/@implementation MSGLossLayer

/*
+ (void)initialize {
    if (self == [MSGLossLayer class]) {
        glossColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.02];
    }
}

*/
/*
- (void)drawInContext:(CGContextRef)ctx {
    CGRect boundingBox = CGContextGetClipBoundingBox(ctx);
    drawGlossGradient(glossColor, boundingBox, ctx);
}

*/
/*
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // NSLog(@"%@\n"
               "\tkeyPath:%@\n"
               "\tobject:%@\n"
               "\tsuperlayer:%@\n"
               "\tself:%@",
               ClassTagSelectorString,
               keyPath,
               [object debugDescription],
               [self.superlayer debugDescription],
               [self debugDescription]);
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
*/

@end
