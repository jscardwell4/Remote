//
// Painter.m
// Remote
//
// Created by Jason Cardwell on 2/29/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "Painter.h"
#import <malloc/malloc.h>
#import <Accelerate/Accelerate.h>
#import <stdint.h>
#import <ImageIO/ImageIO.h>
#import "MSRemoteLogFormatter.h"

static int         ddLogLevel   = LOG_LEVEL_DEBUG;
static const int   msLogContext = PAINTER_F;

#pragma mark - Typedefs

typedef struct {
    CGFloat   color[4];
    CGFloat   caustic[4];
    CGFloat   expCoefficient;
    CGFloat   expScale;
    CGFloat   expOffset;
    CGFloat   initialWhite;
    CGFloat   finalWhite;
} GlossParameters;

NSUInteger   (^ bitmapLocation)(NSUInteger, NSUInteger, NSUInteger) =
    ^(NSUInteger x, NSUInteger y, NSUInteger w) {
    return (NSUInteger)(y * w * 4 + x * 4);
};

NSUInteger   (^ bitmapLocationSingleChannel)(NSUInteger, NSUInteger, NSUInteger) =
    ^(NSUInteger x, NSUInteger y, NSUInteger w) {
    return (NSUInteger)(y * w + x);
};

CGPoint   (^ imageLocation)(NSUInteger, NSUInteger) =
    ^(NSUInteger i, NSUInteger w) {
    CGPoint   p = CGPointZero;

    p.y = i / (w * 4);
    p.x = (i - 4 * w * p.y) / 4;

    return p;
};

#pragma mark - Kernels

static const int16_t   kEmbossKernel[] = {
    -2, -2, 0,
    -2, 6,  0,
    0,  0,  0
};
static const int16_t   kGaussianBlurKernel[] = {
    1, 2, 1,
    2, 4, 2,
    1, 2, 1
};
static const int16_t   kBoxKernel[] = {
    -1, -1, -1, 3,  -1, -1,  -1,
    -1, -1, 0,  2,  0,  -1,  -1,
    -1, 0,  1,  1,  1,  0,   -1,
    3,  2,  1,  0,  1,  2,   3,
    -1, 0,  1,  1,  1,  0,   -1 - 1, 0,0, 2, 0, -1, -1,
    -1, -1, -1, 3,  -1, -1,  -1
};
static const int16_t   kTentKernel[] = {
    1, 1, 1,
    1, 1, 1,
    1, 1, 1
};
static const int16_t   kEdgeDetectionKernel[] = {
    -1, -1, -1,
    0,  0,  0,
    1,  1,  1
};

#pragma mark - Function declarations

CGFloat perceptualGlossFractionForColor(CGFloat * inputComponents);

void perceptualCausticColorForColor(CGFloat * inputComponents, CGFloat * outputComponents);

static void glossInterpolation(void * info, const CGFloat * input, CGFloat * output);
NSData    * getBitmapFromImage(UIImage * image);
NSData    * vImageConformantDataForImage(UIImage * image);

CGImageRef createImageFromFileName(NSString * fileName);

NSDictionary * imageSourceFromURL(NSURL * url);

UInt8 reversePremultipliedAlpha(UInt8 channel, UInt8 alpha);

vImage_Error gaussianBlur(uint8_t * inData, uint8_t * outData, NSUInteger height, NSUInteger width, NSUInteger bytesPerRow);

vImage_Error convolve(uint8_t * inData, uint8_t * outData, NSUInteger height, NSUInteger width, NSUInteger bytesPerRow, int16_t * kernel, uint32_t kernelHeight, uint32_t kernelWidth, int32_t divisor);

NSData * scaledImageDataFromImageData(NSData * imageData, NSUInteger bytesPerRow, CGFloat scale);

#pragma mark - Function definitions

UInt8 reversePremultipliedAlpha(UInt8 channel, UInt8 alpha) {
    return channel - (channel - alpha);
}

CGImageRef createImageFromFileName(NSString * fileName) {
    NSURL * url = [NSURL fileURLWithPath:fileName];

    // Create the image source with the options left null for now
    // Keep in mind since we created it, we're responsible for getting rid of it
    CGImageSourceRef   image_source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);

    if (image_source == NULL) {
        // Something went wrong
        MSLogCError(@"VImage error: Couldn't create image source from URL\n");

        return NULL;
    }

    // Now that we got the source, let's create an image from the first image in the CGImageSource
    CGImageRef   image = CGImageSourceCreateImageAtIndex(image_source, 0, NULL);

    // We created our image, and that's all we needed the source for, so let's release it
    CFRelease(image_source);

    if (image == NULL) {
        // something went wrong
        MSLogCError(@"VImage error: Couldn't create image source from URL\n");

        return NULL;
    }

    return image;
}

NSDictionary * imageSourceFromURL(NSURL * url) {
    NSMutableDictionary * returnDict = [NSMutableDictionary dictionary];
    CGImageSourceRef      source     = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);

    if (source) {
        returnDict[@"imageSource"] = (__bridge_transfer id)source;

        NSDictionary * props =
            (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);

        returnDict[@"props"] = props;

        NSDictionary * thumbOpts = @{(id)kCGImageSourceCreateThumbnailWithTransform : (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageIfAbsent : (id)kCFBooleanTrue, (id)kCGImageSourceThumbnailMaxPixelSize : @128};
        CGImageRef     image     = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)thumbOpts);

        returnDict[@"thumb"] = [UIImage imageWithCGImage:image];

        CGImageRelease(image);

        NSString * uti = (__bridge_transfer NSString *)CGImageSourceGetType(source);

        returnDict[@"uti"] = uti;

        NSDictionary * fileProps = (__bridge_transfer NSDictionary *)CGImageSourceCopyProperties(source, nil);

        returnDict[@"fileProps"] = fileProps;
    }

    return returnDict;
}

CGFloat perceptualGlossFractionForColor(CGFloat * inputComponents) {
    const CGFloat   REFLECTION_SCALE_NUMBER = 0.2;
    const CGFloat   NTSC_RED_FRACTION       = 0.299;
    const CGFloat   NTSC_GREEN_FRACTION     = 0.587;
    const CGFloat   NTSC_BLUE_FRACTION      = 0.114;
    CGFloat         glossScale              = NTSC_RED_FRACTION * inputComponents[0] + NTSC_GREEN_FRACTION * inputComponents[1] + NTSC_BLUE_FRACTION * inputComponents[2];

    glossScale = pow(glossScale, REFLECTION_SCALE_NUMBER);

    return glossScale;
}

void perceptualCausticColorForColor(CGFloat * inputComponents, CGFloat * outputComponents) {
    const CGFloat   CAUSTIC_FRACTION             = 0.60;
    const CGFloat   COSINE_ANGLE_SCALE           = 1.4;
    const CGFloat   MIN_RED_THRESHOLD            = 0.95;
    const CGFloat   MAX_BLUE_THRESHOLD           = 0.7;
    const CGFloat   GRAYSCALE_CAUSTIC_SATURATION = 0.2;
    UIColor       * source                       = [UIColor colorWithRed:inputComponents[0] green:inputComponents[1] blue:inputComponents[2] alpha:inputComponents[3]];
    CGFloat         hue, saturation, brightness, alpha;

    [source getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];

    CGFloat   targetHue, targetSaturation, targetBrightness;

    [[UIColor yellowColor] getHue:&targetHue saturation:&targetSaturation brightness:&targetBrightness alpha:&alpha];

    if (saturation < 1e-3) {
        hue        = targetHue;
        saturation = GRAYSCALE_CAUSTIC_SATURATION;
    }

    if (hue > MIN_RED_THRESHOLD) hue -= 1.0;
    else if (hue > MAX_BLUE_THRESHOLD) [[UIColor magentaColor] getHue:&targetHue saturation:&targetSaturation brightness:&targetBrightness alpha:&alpha];

    CGFloat   scaledCaustic = CAUSTIC_FRACTION * 0.5 * (1.0 + cos(COSINE_ANGLE_SCALE * M_PI * (hue - targetHue)));
    UIColor * targetColor   = [UIColor colorWithHue:hue * (1.0 - scaledCaustic) + targetHue * scaledCaustic
                                         saturation:saturation
                                         brightness:brightness * (1.0 - scaledCaustic) + targetBrightness * scaledCaustic
                                              alpha:inputComponents[3]];

    [targetColor getRed:&outputComponents[0] green:&outputComponents[1] blue:&outputComponents[2] alpha:&outputComponents[3]];
}

static void glossInterpolation(void * info, const CGFloat * input, CGFloat * output) {
    GlossParameters * params   = (GlossParameters *)info;
    CGFloat           progress = *input;

    if (progress < 0.5) {
        progress = progress * 2.0;

        progress =
            1.0 - params->expScale * (expf(progress * -params->expCoefficient) - params->expOffset);

        CGFloat   currentWhite = progress * (params->finalWhite - params->initialWhite) + params->initialWhite;

        output[0] = params->color[0] * (1.0 - currentWhite) + currentWhite;
        output[1] = params->color[1] * (1.0 - currentWhite) + currentWhite;
        output[2] = params->color[2] * (1.0 - currentWhite) + currentWhite;
        output[3] = params->color[3] * (1.0 - currentWhite) + currentWhite;
    } else {
        progress = (progress - 0.5) * 2.0;

        progress = params->expScale * (expf((1.0 - progress) * -params->expCoefficient) - params->expOffset);

        output[0] = params->color[0] * (1.0 - progress) + params->caustic[0] * progress;
        output[1] = params->color[1] * (1.0 - progress) + params->caustic[1] * progress;
        output[2] = params->color[2] * (1.0 - progress) + params->caustic[2] * progress;
        output[3] = params->color[3] * (1.0 - progress) + params->caustic[3] * progress;
    }
}

NSData * getBitmapFromImage(UIImage * image) {
    NSData * bitmapData =
        (__bridge_transfer NSData *)CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));

    return bitmapData;
}

NSData * vImageConformantDataForImage(UIImage * image) {
    ImageInfo   imageInfo = [image imageInfo];

    MSLogCDebug(@"%@", ImageInfoString(imageInfo));

    CGColorSpaceRef   colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef      context    = CGBitmapContextCreate(NULL,
                                                         imageInfo.width,
                                                         imageInfo.height,
                                                         imageInfo.bitsPerComponent,
                                                         imageInfo.bytesPerRow,
                                                         colorSpace,
                                                         kCGImageAlphaPremultipliedFirst);

    CGContextDrawImage(context,
                       CGRectMake(0.0f, 0.0f, imageInfo.width, imageInfo.height),
                       image.CGImage);

    CGImageRef   imageRef  = CGBitmapContextCreateImage(context);
    NSData     * imageData = (__bridge_transfer NSData *)CGDataProviderCopyData(CGImageGetDataProvider(imageRef));

    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    return imageData;
}

vImage_Error gaussianBlur(uint8_t  * inData,
                          uint8_t  * outData,
                          NSUInteger height,
                          NSUInteger width,
                          NSUInteger bytesPerRow) {
    vImage_Buffer   src = {
        inData,
        height,
        width,
        bytesPerRow
    };
    vImage_Buffer   dest = {
        outData,
        height,
        width,
        bytesPerRow
    };
    vImage_Error    err = vImageConvolve_ARGB8888(&src,
                                                  &dest,
                                                  NULL,
                                                  0,
                                                  0,
                                                  kGaussianBlurKernel,
                                                  3,
                                                  3,
                                                  1,
                                                  NULL,             // (Pixel_8888){0,0,0,0},
                                                  kvImageEdgeExtend // kvImageBackgroundColorFill
                                                  );

    return err;
}

vImage_Error convolve(uint8_t  * inData,
                      uint8_t  * outData,
                      NSUInteger height,
                      NSUInteger width,
                      NSUInteger bytesPerRow,
                      int16_t  * kernel,
                      uint32_t   kernelHeight,
                      uint32_t   kernelWidth,
                      int32_t    divisor) {
    assert(NO);

    vImage_Buffer   src = {
        inData,
        height,
        width,
        bytesPerRow
    };
    vImage_Buffer   dest = {
        outData,
        height,
        width,
        bytesPerRow
    };
    vImage_Error    err = vImageConvolve_ARGB8888(&src,
                                                  &dest,
                                                  NULL,
                                                  0,
                                                  0,
                                                  kernel,
                                                  kernelHeight,
                                                  kernelWidth,
                                                  divisor,
                                                  (Pixel_8888) {0, 0, 0, 0},
                                                  kvImageBackgroundColorFill
                                                  );

    return err;
}

NSData * scaledImageDataFromImageData(NSData * imageData, NSUInteger bytesPerRow, CGFloat scale) {
    assert(NO);

    vImage_Buffer   src = {
        (void *)imageData.bytes,
        imageData.length / bytesPerRow,
        bytesPerRow / 4,
        bytesPerRow
    };
    vImage_Buffer   dest = {
        malloc([imageData length] * scale),
        (imageData.length / bytesPerRow) * scale,
        (bytesPerRow / 4) * scale,
        bytesPerRow * scale
    };

    vImageScale_ARGB8888(&src, &dest, NULL, kvImageNoFlags);

    NSData * scaledImageData = [NSData dataWithBytes:dest.data length:imageData.length * scale];

    free(dest.data);

    return scaledImageData;
}

#pragma mark - Painter implementation

@implementation Painter

+ (id)sharedSharedPainter {
    static dispatch_once_t   pred          = 0;
    __strong static id       _sharedObject = nil;

    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    }

                  );

    return _sharedObject;
}

+ (UIImage *)circledText:(NSString *)text
                    font:(UIFont *)font
         backgroundColor:(UIColor *)color
               textColor:(UIColor *)textColor
                    size:(CGSize)size {
    /* Called by MacroCommandEditingViewController */

    BOOL   shouldClearText = ValueIsNil(textColor);

    // Create context
    UIGraphicsBeginImageContextWithOptions(size, NO, MainScreenScale);

    CGContextRef   context = UIGraphicsGetCurrentContext();

    CGContextSetShouldAntialias(context, YES);

    // Draw circle
    CGRect   rect = (CGRect) {.origin = CGPointZero, .size = size};

    [color setFill];

    UIBezierPath * circle = [UIBezierPath bezierPathWithOvalInRect:rect];

    [circle fill];

    // Flip context
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    // Ensure font height is not too large
    CGFloat   pointSize = font.pointSize;

    if (pointSize > size.height) font = [font fontWithSize:size.height];

    // Measure width of text
    CGContextSelectFont(context, [font.fontName UTF8String], font.pointSize, kCGEncodingMacRoman);
    CGContextSaveGState(context);
    CGContextSetTextDrawingMode(context, kCGTextInvisible);
    CGContextShowTextAtPoint(context, 0.0f, 0.0f, [text UTF8String], text.length);

    CGPoint   endPoint = CGContextGetTextPosition(context);

    CGContextRestoreGState(context);

    // Measure height and calculate center point
    CGSize    stringSize   = [text sizeWithFont:font];
    CGPoint   textCenter   = CGRectGetCenter(rect);
    CGPoint   textLocation = CGPointMake(textCenter.x - endPoint.x / 2.0f,
                                         fabsf(textCenter.y - stringSize.height / 2.0f));

    // Draw text
    [textColor setFill];
    CGContextSetTextDrawingMode(context, kCGTextFillClip);
    CGContextShowTextAtPoint(context,
                             textLocation.x,
                             textLocation.y,
                             [text UTF8String],
                             text.length);

    // Clear rect with path clipped to text if text color is nil
    if (shouldClearText) CGContextClearRect(context, rect);

    // Grab the image and end the context
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}  /* circledText */

+ (void)drawGlossGradientWithColor:(UIColor *)color
                            inRect:(CGRect)rect
                         inContext:(CGContextRef)context {
    /* Called by ButtonGroupView and ButtonView overlays */
    const CGFloat     EXP_COEFFICIENT = 1.2;
    const CGFloat     REFLECTION_MAX  = 0.60;
    const CGFloat     REFLECTION_MIN  = 0.20;
    GlossParameters   params;

    params.expCoefficient = EXP_COEFFICIENT;
    params.expOffset      = expf(-params.expCoefficient);
    params.expScale       = 1.0 / (1.0 - params.expOffset);

    [color getRed:&params.color[0] green:&params.color[1] blue:&params.color[2] alpha:&params.color[3]];

    perceptualCausticColorForColor(params.color, params.caustic);

    CGFloat   glossScale = perceptualGlossFractionForColor(params.color);

    params.initialWhite = glossScale * REFLECTION_MAX;
    params.finalWhite   = glossScale * REFLECTION_MIN;

    static const CGFloat   input_value_range[2]   = {0, 1};
    static const CGFloat   output_value_ranges[8] = {0, 1, 0, 1, 0, 1, 0, 1};
    CGFunctionCallbacks    callbacks              = {0, glossInterpolation, NULL};
    CGFunctionRef          gradientFunction       = CGFunctionCreate((void *)&params,
                                                                     1, // number of input values to
                                                                        // the callback
                                                                     input_value_range,
                                                                     4, // number of components (r,
                                                                        // g, b, a)
                                                                     output_value_ranges,
                                                                     &callbacks);
    CGPoint           endPoint   = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGPoint           startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGColorSpaceRef   colorspace = CGColorSpaceCreateDeviceRGB();
    CGShadingRef      shading    = CGShadingCreateAxial(colorspace, startPoint,
                                                        endPoint, gradientFunction, FALSE, FALSE);

    CGContextSaveGState(context);
    CGContextClipToRect(context, rect);
    CGContextDrawShading(context, shading);
    CGContextRestoreGState(context);

    CGShadingRelease(shading);
    CGColorSpaceRelease(colorspace);
    CGFunctionRelease(gradientFunction);
}

+ (void)drawLinearGradientInRect:(CGRect)rect
                  withStartColor:(CGColorRef)startColor
                        endColor:(CGColorRef)endColor
                       inContext:(CGContextRef)context {
    assert(NO);

    CGColorSpaceRef   colorSpace  = CGColorSpaceCreateDeviceRGB();
    CGFloat           locations[] = {0.0, 1.0};
    NSArray         * colors      = @[(__bridge id)startColor, (__bridge id)endColor];
    CGGradientRef     gradient    = CGGradientCreateWithColors(colorSpace,
                                                               (__bridge CFArrayRef)colors,
                                                               locations);
    CGPoint   startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint   endPoint   = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));

    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);

    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

+ (void)drawBackdropForShape:(PainterShape)shape
                      inRect:(CGRect)rect
               backdropColor:(UIColor *)color
                 cornerRadii:(CGSize)cornerRadii
                   inContext:(CGContextRef)context {
    assert(NO);

    UIBezierPath * backdropBP = nil;

    switch (shape) {
        case PainterShapeRoundedRectangle :
            backdropBP = [UIBezierPath bezierPathWithRoundedRect:rect
                                               byRoundingCorners:UIRectCornerAllCorners
                                                     cornerRadii:cornerRadii];
            break;

        case PainterShapeOval :
            backdropBP = [UIBezierPath bezierPathWithOvalInRect:rect];
            break;

        case PainterShapeRectangle :
            backdropBP = [UIBezierPath bezierPathWithRoundedRect:rect
                                               byRoundingCorners:UIRectCornerAllCorners
                                                     cornerRadii:cornerRadii];
            break;

        default :
            break;
    }  /* switch */

    [backdropBP addClip];
    CGContextSaveGState(context);
    [color setFill];
    [backdropBP fill];
    CGContextRestoreGState(context);
}

+ (void)drawBorderForShape:(PainterShape)shape
                     color:(UIColor *)color
                     width:(CGFloat)width
                      join:(CGLineJoin)join
                      rect:(CGRect)rect
               cornerRadii:(CGSize)cornerRadii
                   context:(CGContextRef)context {
    assert(NO);

    UIBezierPath * borderBP = nil;

    switch (shape) {
        case PainterShapeUndefined :

            return;

        case PainterShapeRoundedRectangle :
            borderBP = [UIBezierPath bezierPathWithRoundedRect:rect
                                             byRoundingCorners:UIRectCornerAllCorners
                                                   cornerRadii:cornerRadii];
            break;

        case PainterShapeOval :
            borderBP = [UIBezierPath bezierPathWithOvalInRect:rect];
            break;

        case PainterShapeRectangle :
            borderBP = [UIBezierPath bezierPathWithRect:rect];
            break;

        case PainterShapeTriangle :
            break;

        case PainterShapeDiamond :
            break;

        default :
            break;
    }  /* switch */

    CGContextSaveGState(context);
    [color setStroke];
    borderBP.lineJoinStyle = join;
    borderBP.lineWidth     = width;
    [borderBP stroke];
    CGContextRestoreGState(context);
}

+ (UIBezierPath *)stretchedOvalFromRect:(CGRect)rect {
    /* Called by ButtonView for backdrop and overlay oval shapes */
    CGFloat   width  = rect.size.width, height = rect.size.height;
    CGPoint   a      = rect.origin, b = rect.origin, c1 = CGPointZero, c2 = CGPointZero;
    CGFloat   radius = 0.0, start1 = 0, end1 = 0, start2 = 0, end2 = 0;
    CGFloat   delta  = fabs(Delta(height, width));

    if (delta == 0)
        return [UIBezierPath bezierPathWithOvalInRect:rect];
    else if (width > height) {
        radius = height / 2.0;
        a.x   += radius;
        a.y   += height;
        b.x   += radius + delta;
        c1.x   = a.x;
        c1.y   = a.y - radius;
        c2.x   = b.x;
        c2.y   = c1.y;
        start1 = M_PI_2;
        end1   = M_PI_2 * 3.0;
    } else {
        radius = width / 2.0;
        a.y   += radius;
        b.x   += width;
        b.y   += radius + delta;
        c1.x   = a.x + radius;
        c1.y   = a.y;
        c2.x   = c1.x;
        c2.y   = b.y;
        start1 = M_PI;
        end1   = 0;
    }

    start2 = end1;
    end2   = start1;

    UIBezierPath * path = [UIBezierPath bezierPath];

    [path moveToPoint:a];
    [path addArcWithCenter:c1 radius:radius startAngle:start1 endAngle:end1 clockwise:YES];
    [path addLineToPoint:b];
    [path addArcWithCenter:c2 radius:radius startAngle:start2 endAngle:end2 clockwise:YES];
    [path closePath];

    return path;
}  /* stretchedOvalFromRect */

+ (NSArray *)borderPointsForImage:(UIImage *)image {
    NSData         * imageData      = [image bitmapData];
    Pixel_8        * pixels         = (Pixel_8 *)[imageData bytes];
    ImageInfo        imageInfo      = image.imageInfo;
    NSMutableArray * border         = [NSMutableArray arrayWithCapacity:imageInfo.width * 2 + imageInfo.height * 2];
    Pixel_8          alphaThreshold = 225; // cutoff for distinguishing between solid and
                                           // transparent
    CGRect   bounds = CGRectMake(0, 0, imageInfo.width, imageInfo.height);

    /*******************************************************************************
    *  helper function blocks
    *******************************************************************************/

    /* block for converting the index of a pixel into its corresponding point */
    CGPoint   (^ imageLocation)(NSUInteger) = ^(NSUInteger i) {
        CGPoint   p = CGPointZero;

        p.y = floor(i / (imageInfo.width * 4));
        p.x = (i - 4 * imageInfo.width * p.y) / 4;

        return p;
    };

    /* block for converting a point into its corresponding pixel array index */
    NSUInteger   (^ bitmapLocation)(CGPoint) = ^(CGPoint p) {return (NSUInteger)(p.y * imageInfo.width * 4 + p.x * 4); };

    /* Returns the alpha value for a given pixel location */
    Pixel_8   (^ pixelAlpha)(NSUInteger) = ^(NSUInteger bitmapLocation) {return pixels[bitmapLocation + 3]; };

    /* Returns the search direction given the previous direction */
    uint   (^ nextDirection)(uint) = ^(uint d) {return (d % 2 ? (d + 6) % 8 : (d + 7) % 8); };

    /* Returns the neighbor point around point p in the direction d */
    CGPoint   (^ pointForNeighborInDirection)(uint, CGPoint) = ^(uint d, CGPoint p) {
        switch (d) {
            case 0 :

                return CGPointMake(p.x + 1, p.y);

            case 1 :

                return CGPointMake(p.x + 1, p.y - 1);

            case 2 :

                return CGPointMake(p.x, p.y - 1);

            case 3 :

                return CGPointMake(p.x - 1, p.y - 1);

            case 4 :

                return CGPointMake(p.x - 1, p.y);

            case 5 :

                return CGPointMake(p.x - 1, p.y + 1);

            case 6 :

                return CGPointMake(p.x, p.y + 1);

            case 7 :

                return CGPointMake(p.x + 1, p.y + 1);

            default :

                return CGPointMake(-1, -1);
        }  /* switch */
    };

    /* Returns the pixel location for the neighbor of point p in direction d, or -1 if not in bounds
    **/
    NSInteger   (^ indexForNeighborInDirection)(uint, CGPoint p) = ^(uint d, CGPoint p) {
        CGPoint   n = pointForNeighborInDirection(d, p);

        return (NSInteger)(CGRectContainsPoint(bounds, n) ? bitmapLocation(n) : -1);
    };

    /* Returns the pixel index for the next counter clockwise pixel around point p from direction d
    **/
    NSInteger   (^ nextCounterClockwiseNeighbor)(uint *, CGPoint) = ^(uint * d, CGPoint p) {
        NSInteger   n = indexForNeighborInDirection(*d, p);

        while (n < 0) {
            *d = (*d + 1) % 8;
            n  = indexForNeighborInDirection(*d, p);
        }

        assert(n > -1);

        return n;
    };

    /*******************************************************************************
    *  border point search
    *******************************************************************************/

    // find p0
    NSUInteger   p0 = 0;

    while (border.count == 0 && p0 < imageData.length - 4) {
        if (pixelAlpha(p0) > alphaThreshold) [border addObject:NSValueWithCGPoint(imageLocation(p0))];
        else p0 += 4;
    }

    // return if p0 was not found
    if (border.count == 0) return border;

    // start neighborhood search
    uint        dir  = nextDirection(7);
    NSInteger   pn   = p0;
    BOOL        stop = NO;

    do {
        NSInteger   n = nextCounterClockwiseNeighbor(&dir, imageLocation(pn));

        if (n == p0)
            stop = YES;
        else if (pixelAlpha(n) > alphaThreshold) {
            [border addObject:NSValueWithCGPoint(imageLocation(n))];
            pn  = n;
            dir = nextDirection(dir);
        } else
            dir = (dir + 1) % 8;
    } while (!stop);

/*
 *  // block for determining next clockwise point in Moore neighborhood
 *  CGPoint (^__block nextClockwisePoint)(CGPoint,CGPoint) = ^(CGPoint b, CGPoint p) {
 *      CGPoint next;
 *      if (CGPointEqualToPoint(b, p))
 *          next = CGPointMake(p.x+1, p.y);
 *
 *      else if (b.x >= p.x)
 *          // b in {N,NE,E,SE,S}
 *          next = (  b.y > p.y
 *                  ? CGPointMake(b.x-1, b.y)
 *                  : (  b.y <= p.y && b.x > p.x
 *                     ? CGPointMake(b.x, b.y+1)
 *                     : CGPointMake(b.x+1, b.y)));
 *      else
 *          // b in {SW,W,NW}
 *          next = (  b.y >= p.y
 *                  ? CGPointMake(b.x, b.y-1)
 *                  : CGPointMake(b.x+1, b.y));
 *
 *      if (next.x < 0 || next.y < 0 || next.x >= imageInfo.width || next.y >= imageInfo.height)
 *          next = nextClockwisePoint(next,p);
 *
 *      return next;
 *  };
 *
 *
 *  CGPoint borderStart = CGPointZero, // first border point discovered
 *  borderPoint = CGPointZero, // center of current Moore neighborhood
 *  backtrack   = CGPointZero, // point from which borderPoint was entered
 *  current     = CGPointZero; // point under current consideration
 *
 *  NSUInteger c = 0, b = 0; // indices used while finding starting point
 *                                // find the first point from the edge that has a positive alpha
 * value
 *  while (border.count == 0) {
 *      if (pixels[c+3] > alphaThreshold) {
 *          // add point to array and setup variables
 *          borderStart = imageLocation(c);
 *          [border addObject:NSValueWithCGPoint(borderStart)];
 *          borderPoint = borderStart;
 *          backtrack = imageLocation(b);
 *      } else {
 *          // check the next pixel over
 *          b = c;
 *          c += 4;
 *      }
 *  }
 *
 *  // check the next clockwise point according to Moore's neighborhood algorithm
 *  current = nextClockwisePoint(backtrack, borderPoint);
 *
 *  // continue until travel has come back to original border point
 *  while (!CGPointEqualToPoint(current, borderStart)) {
 *      NSUInteger idx = bitmapLocation(current);
 *      Pixel_8 alpha = pixels[idx+3];
 *      if (alpha > alphaThreshold) {
 *          [border addObject:NSValueWithCGPoint(current)];
 *          backtrack = borderPoint;
 *          borderPoint = current;
 *      } else
 *          backtrack = current;
 *      current = nextClockwisePoint(backtrack,borderPoint);
 *  }
 */

    #define DUMP_PIXEL_LOCATIONS
#ifdef DUMP_PIXEL_LOCATIONS
    NSOperationQueue * queue = [NSOperationQueue new];

    [queue addOperationWithBlock:^{
               NSMutableString * string = [NSMutableString
                                    stringWithFormat:@"%@ detected border points in %zu x %zu context:\n",
                                    ClassTagSelectorString, imageInfo.width, imageInfo.height];
               for (NSValue * pv in border) {
               [string appendFormat:@"%@  ", CGPointString(CGPointValue(pv))];
               }

               MSLogDebug(@"%@", string);
           }

    ];
#endif /* ifdef DUMP_PIXEL_LOCATIONS */
    return border;
}  /* borderPointsForImage */

+ (UIBezierPath *)borderPathForImage:(UIImage *)image {
    assert(NO);

    NSArray * allEdges = [self borderPointsForImage:image];
// ImageInfo info = image.imageInfo;
    UIBezierPath * path = [UIBezierPath bezierPath];

    [path moveToPoint:[allEdges[0] CGPointValue]];

    for (int i = 1; i < [allEdges count]; i++) {
        [path addLineToPoint:[allEdges[i] CGPointValue]];
    }

    [path closePath];

    return path;
}

+ (UIImage *)borderPathImage:(UIImage *)image color:(UIColor *)color width:(NSUInteger)width {
    assert(NO);

    UIBezierPath * path = [self borderPathForImage:image];

    path.lineWidth     = width;
    path.lineJoinStyle = kCGLineJoinRound;
    [path applyTransform:CGAffineTransformMakeScale(1 / image.scale, 1 / image.scale)];

    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [color setStroke];
    [path stroke];
    [color setFill];
    [path fill];

    UIImage * pathImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return pathImage;
}

+ (UIImage *)embossImage:(UIImage *)image {
    assert(NO);

    ImageInfo       imageInfo  = image.imageInfo;
    NSData        * bitmapData = vImageConformantDataForImage(image);
    UInt8         * pixels     = (UInt8 *)[bitmapData bytes];
    vImage_Buffer   src        = {
        (void *)pixels,
        imageInfo.height,
        imageInfo.width,
        imageInfo.bytesPerRow
    };
    void          * outData = malloc([bitmapData length]);
    vImage_Buffer   dest    = {
        outData,
        imageInfo.height,
        imageInfo.width,
        imageInfo.bytesPerRow
    };
    short           kernel[9]    = {-2, -2, 0, -2, 6, 0, 0, 0, 0}; // 1
    int             kernelHeight = 3;
    int             kernelWidth  = 3;
    int             divisor      = 1;
    unsigned char   bgColor[4]   = {0, 0, 0, 0};
    vImage_Error    err;

    err = vImageConvolve_ARGB8888(&src,
                                  &dest,
                                  NULL,
                                  0,
                                  0,
                                  kernel,
                                  kernelHeight,
                                  kernelWidth,
                                  divisor,
                                  bgColor,
                                  kvImageBackgroundColorFill
                                  );

    if (err != kvImageNoError) {
        MSLogError(@"%@ error with image convolusion:%li", ClassTagSelectorString, err);
        free(outData);

        return nil;
    }

    CGColorSpaceRef     colorspace   = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef   dataProvider =
        CGDataProviderCreateWithData(NULL, dest.data, [bitmapData length], NULL);
    CGImageRef   imageRef = CGImageCreate(imageInfo.width,
                                          imageInfo.height,
                                          imageInfo.bitsPerComponent,
                                          imageInfo.bitsPerPixel,
                                          imageInfo.bytesPerRow,
                                          colorspace,
                                          kCGImageAlphaPremultipliedFirst,
                                          dataProvider,
                                          NULL,
                                          false,
                                          imageInfo.renderingIntent);
    UIImage * embossedImage = [UIImage imageWithCGImage:imageRef
                                                  scale:image.scale
                                            orientation:UIImageOrientationUp];

    CGDataProviderRelease(dataProvider);
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorspace);

    return embossedImage;
}  /* embossImage */

+ (UIImage *)blurImage:(UIImage *)image {
    assert(NO);

    ImageInfo   imageInfo  = image.imageInfo;
    NSData    * bitmapData = vImageConformantDataForImage(image);
    UInt8     * pixels     = (UInt8 *)[bitmapData bytes];

// vImage_Buffer src = {
// (void *)pixels,
// imageInfo.height,
// imageInfo.width,
// imageInfo.bytesPerRow
// };
    void * outData = malloc([bitmapData length]);
// vImage_Buffer dest = {
// outData,
// imageInfo.height,
// imageInfo.width,
// imageInfo.bytesPerRow
// };

// short kernel[9] = {-2, -2, 0, -2, 6, 0, 0, 0, 0}; // 1
// int kernelHeight = 3;
// int kernelWidth = 3;
// int divisor = 1;
// unsigned char bgColor[4] = { 0, 0, 0, 0 };
    vImage_Error   err;

    err = gaussianBlur(pixels, outData, imageInfo.height, imageInfo.width, imageInfo.bytesPerRow);

// err = vImageConvolve_ARGB8888(&src,
// &dest,
// NULL,
// 0,
// 0,
// kGaussianBlurKernel,
// kernelHeight,
// kernelWidth,
// divisor,
// bgColor,
// kvImageBackgroundColorFill
// );

    if (err != kvImageNoError) {
        MSLogError(@"%@ error with image convolusion:%li", ClassTagSelectorString, err);
        free(outData);

        return nil;
    }

    CGColorSpaceRef     colorspace   = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef   dataProvider =
        CGDataProviderCreateWithData(NULL, outData, [bitmapData length], NULL);
    CGImageRef   imageRef = CGImageCreate(imageInfo.width,
                                          imageInfo.height,
                                          imageInfo.bitsPerComponent,
                                          imageInfo.bitsPerPixel,
                                          imageInfo.bytesPerRow,
                                          colorspace,
                                          kCGImageAlphaPremultipliedFirst,
                                          dataProvider,
                                          NULL,
                                          false,
                                          imageInfo.renderingIntent);
    UIImage * blurredImage = [UIImage imageWithCGImage:imageRef
                                                 scale:image.scale
                                           orientation:UIImageOrientationUp];

    CGDataProviderRelease(dataProvider);
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorspace);

    return blurredImage;
}  /* blurImage */

@end
