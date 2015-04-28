 //
//  DrawingKit+Extensions.swift
//  Remote
//
//  Created by Jason Cardwell on 4/26/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import DataModel

extension DrawingKit {

  public typealias Shape = RemoteElement.Shape
  public static var defaultButtonColor: UIColor { return UIColor(r: 41, g: 40, b: 39, a: 255)! }
  public static var defaultContentColor: UIColor { return UIColor(r: 50, g: 143, b: 239, a: 255)! }
  public static var defaultRadii: CGSize { return CGSize(width: 10, height: 20) }
  public static var defaultCorners: UIRectCorner { return .AllCorners }

  /**
  roundedRectanglePathInRect:radius:

  :param: rect CGRect
  :param: radius CGFloat

  :returns: UIBezierPath
  */
  public class func roundedRectanglePathInRect(rect: CGRect, radius: CGFloat) -> UIBezierPath {
    return UIBezierPath(roundedRect: rect, cornerRadius: radius)
  }

  /**
  roundedRectanglePathInRect:corners:radii:

  :param: rect CGRect
  :param: radius CGFloat

  :returns: UIBezierPath
  */
  public class func roundedRectanglePathInRect(rect: CGRect,
                             byRoundingCorners corners: UIRectCorner,
                                     withRadii radii: CGSize) -> UIBezierPath
  {
    return UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: radii)
  }

  /**
  rectanglePathInRect:

  :param: rect CGRect

  :returns: UIBezierPath
  */
  public class func rectanglePathInRect(rect: CGRect) -> UIBezierPath { return UIBezierPath(rect: rect) }

  /**
  ovalPathInRect:

  :param: rect CGRect

  :returns: UIBezierPath
  */
  public class func ovalPathInRect(rect: CGRect) -> UIBezierPath { return UIBezierPath(ovalInRect: rect) }

  /**
  diamondBasePathInRect:

  :param: rect CGRect

  :returns: UIBezierPath
  */
  public class func diamondPathInRect(rect: CGRect) -> UIBezierPath {
    var path = UIBezierPath()
    path.moveToPoint(CGPoint(x: rect.minX, y: rect.minY + 0.5 * rect.height))
    path.addLineToPoint(CGPoint(x: rect.minX + 0.5 * rect.width, y: rect.minY))
    path.addLineToPoint(CGPoint(x: rect.minX + rect.width, y: rect.minY + 0.5 * rect.height))
    path.addLineToPoint(CGPoint(x: rect.minX + 0.5 * rect.width, y: rect.minY + rect.height))
    path.addLineToPoint(CGPoint(x: rect.minX, y: rect.minY + 0.5 * rect.height))
    path.closePath()
    return path
  }

  /**
  triangleBasePathInRect:

  :param: rect CGRect

  :returns: UIBezierPath
  */
  public class func trianglePathInRect(rect: CGRect) -> UIBezierPath {
    var path = UIBezierPath()
    path.moveToPoint(CGPoint(x: rect.minX + 0.50 * rect.width, y: rect.minY))
    path.addLineToPoint(CGPoint(x: rect.minX + 0.75 * rect.width, y: rect.minY + 0.5 * rect.height))
    path.addLineToPoint(CGPoint(x: rect.minX + rect.width, y: rect.minY + rect.height))
    path.addLineToPoint(CGPoint(x: rect.minX + 0.50 * rect.width, y: rect.minY + rect.height))
    path.addLineToPoint(CGPoint(x: rect.minX, y: rect.minY + rect.height))
    path.addLineToPoint(CGPoint(x: rect.minX + 0.25 * rect.width, y: rect.minY + 0.5 * rect.height))
    path.addLineToPoint(CGPoint(x: rect.minX + 0.5 * rect.width, y: rect.minY))
    path.closePath()
    return path
  }

  /**
  pathForShape:inRect:byRoundingCorners:withRadii:

  :param: shape Shape
  :param: rect CGRect
  :param: corners UIRectCorner = defaultCorners
  :param: radii CGSize = defaultRadii

  :returns: UIBezierPath
  */
  public class func pathForShape(shape: Shape,
                          inRect rect: CGRect,
               byRoundingCorners corners: UIRectCorner = defaultCorners,
                       withRadii radii: CGSize = defaultRadii) -> UIBezierPath
  {
    switch shape {
      case .Diamond:          return diamondPathInRect(rect)
      case .Oval:             return ovalPathInRect(rect)
      case .Triangle:         return trianglePathInRect(rect)
      case .Rectangle:        return rectanglePathInRect(rect)
      case .RoundedRectangle: return roundedRectanglePathInRect(rect, byRoundingCorners: corners, withRadii: radii)
      case .Undefined:        return UIBezierPath()
    }
  }

  /**
  drawButtonBaseWithShape:inRect:withColor:byRoundingCorners:withRadii:

  :param: shape Shape
  :param: rect CGRect
  :param: color UIColor = defaultButtonColor
  :param: corners UIRectCorner = defaultCorners
  :param: radii CGSize = defaultRadii
  */
  public class func drawButtonBaseWithShape(shape: Shape,
                                     inRect rect: CGRect,
                                  withColor color: UIColor = defaultButtonColor,
                            byRoundingCorners corners: UIRectCorner = defaultCorners,
                                  withRadii radii: CGSize = defaultRadii)
  {

    let context      = UIGraphicsGetCurrentContext()
    let clippingPath = pathForShape(shape, inRect: rect, byRoundingCorners: corners, withRadii: radii)
    let drawingPath  = pathForShape(shape,
                             inRect: rect.rectByInsetting(dx: 2, dy: 2),
                  byRoundingCorners: corners,
                          withRadii: radii)
    let overlayPath = pathForShape(shape,
                            inRect: rect.rectByInsetting(dx: 6, dy: 6),
                 byRoundingCorners: corners,
                         withRadii: radii)

    CGContextSaveGState(context)                                                            // context: •

    clippingPath.addClip()

    // Draw base using color
    outerShadow.setShadow()
    color.setFill()
    drawingPath.fill()

    CGContextSaveGState(context)                                                            // context: ••

    // Clip, remove shadow and update alpha
    CGContextClipToRect(context, clippingPath.bounds)
    CGContextSetShadow(context, CGSize.zeroSize, 0)
    CGContextSetAlpha(context, innerShadow.color.alpha!)

    CGContextBeginTransparencyLayer(context, nil)                                           // transparency: •

    let opaqueInnerShadow = innerShadow.shadowWithAlpha(1.0)
    opaqueInnerShadow.setShadow()
    CGContextSetBlendMode(context, kCGBlendModeSourceOut)

    CGContextBeginTransparencyLayer(context, nil)                                           // transparency: ••
    opaqueInnerShadow.color.setFill()

    drawingPath.fill()

    CGContextEndTransparencyLayer(context)                                                  // transparency: •
    CGContextEndTransparencyLayer(context)                                                  // transparency:
    CGContextRestoreGState(context)                                                         // context: •
    CGContextRestoreGState(context)                                                         // context:

    overlayPath.addClip() // helps to cut down on edge artifacts

    // Draw stroke shadow
    CGContextSaveGState(context)                                                            // context: •
    strokeShadow.setShadow()
    drawingPath.lineWidth = 1
    drawingPath.stroke()
    CGContextRestoreGState(context)                                                         // context:

    // Draw overlay
    CGContextSaveGState(context)                                                            // context: ••
    // drawingPath.addClip()

    CGContextSaveGState(context)
    CGContextSetBlendMode(context, kCGBlendModeSoftLight)

    let bounds = overlayPath.bounds
    let p1 = CGPoint(x: bounds.midX, y: bounds.midY + 0.5 * bounds.height)
    let p2 = CGPoint(x: bounds.midX, y: bounds.midY)
    let options = UInt32(kCGGradientDrawsBeforeStartLocation) | UInt32(kCGGradientDrawsAfterEndLocation)
    CGContextDrawLinearGradient(context, verticalGloss, p1, p2, options)

    CGContextRestoreGState(context)                                                         // context: •

    CGContextRestoreGState(context)                                                         // context:

  }

  /**
  drawButton:color:contentColor:image:corners:radii:text:fontAttributes:applyGloss:shape:highlighted:

  :param: #rect CGRect
  :param: color UIColor = defaultButtonColor
  :param: contentColor UIColor = defaultContentColor
  :param: image UIImage? = nil
  :param: corners UIRectCorner = defaultCorners
  :param: radii CGSize = defaultRadii
  :param: text String? = nil
  :param: fontAttributes [String AnyObject]? = nil
  :param: applyGloss Bool = true
  :param: shape Shape
  :param: highlighted Bool = false
  */
  public class func drawButtonWithShape(shape: Shape,
                                 inRect rect: CGRect,
                              withColor color: UIColor = defaultButtonColor,
                       withContentColor ccolor: UIColor = defaultContentColor,
                      byRoundingCorners corners: UIRectCorner = defaultCorners,
                              withRadii radii: CGSize = defaultRadii,
                                  image: UIImage? = nil,
                                   text: String? = nil,
                    usingFontAttributes fontAttributes: [String:AnyObject]? = nil,
                             applyGloss: Bool = true,
                               highlighted: Bool = false)
  {
    let context = UIGraphicsGetCurrentContext()

    // TODO: Check points against path for the sides of min/max font height, i.e. shrink more for diamond/triangle shapes
    let baseRect = rect.rectByInsetting(dx: 4, dy: 4).integerRect
    let bleedRect = baseRect.rectByInsetting(dx: 4, dy: 4)

    let contentOuterShadow: NSShadow? = highlighted ? NSShadow(color: ccolor, offset: CGSize.zeroSize, blurRadius: 5) : nil


    CGContextSaveGState(context)                                                            // context stack: •
    UIRectClip(bleedRect)
    CGContextTranslateCTM(context, bleedRect.origin.x, bleedRect.origin.y)
    drawShape(shape, inRect: CGRect(size: bleedRect.size), withColor: ccolor, byRoundingCorners: corners, withRadii: radii)
    CGContextRestoreGState(context)                                                         // context:

    CGContextSaveGState(context)                                                            // context: •
    CGContextBeginTransparencyLayer(context, nil)                                           // transparency: •
    CGContextSaveGState(context)                                                            // context: ••
    contentOuterShadow?.setShadow()
    CGContextBeginTransparencyLayer(context, nil)                                           // transparency: ••

    CGContextSaveGState(context)                                                            // context: •••
    UIRectClip(baseRect)
    CGContextTranslateCTM(context, baseRect.origin.x, baseRect.origin.y)

    drawButtonBaseWithShape(shape,
                     inRect: CGRect(size: baseRect.size),
                  withColor: color,
            byRoundingCorners: corners,
                  withRadii: radii)
    CGContextRestoreGState(context)                                                         // context: ••


    CGContextEndTransparencyLayer(context)                                                  // transparency: •
    CGContextRestoreGState(context)                                                         // context: •

    CGContextSaveGState(context)                                                            // context: ••
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut)
    CGContextBeginTransparencyLayer(context, nil)                                           // transparency: ••


    if let image = image {

      let actualImageSize = image.size
      let boundingSize = baseRect.size
      let imageSize = boundingSize.contains(actualImageSize)
                        ? actualImageSize
                        : actualImageSize.aspectMappedToSize(boundingSize, binding: true)
      let imageOffset = CGPoint(x: baseRect.midX - imageSize.width * 0.5, y: baseRect.midY - imageSize.height * 0.5)

      //// Icon Group
      CGContextSaveGState(context)                                                          // context: •••
      CGContextTranslateCTM(context, imageOffset.x, imageOffset.y)

      innerShadow.setShadow()
      CGContextSetAlpha(context, 0.9)
      CGContextBeginTransparencyLayer(context, nil)                                         // transparency: •••


      //// Icon Path Drawing
      CGContextSaveGState(context)                                                          // context: ••••
      contentOuterShadow?.setShadow()
      CGContextBeginTransparencyLayer(context, nil)                                         // transparency: ••••
      CGContextSaveGState(context)                                                          // context: •••••
      let imageRect = CGRect(size: imageSize)
      CGContextClipToRect(context, imageRect)
      image.drawInRect(imageRect)
      CGContextRestoreGState(context)                                                       // context: ••••
      CGContextEndTransparencyLayer(context)                                                // transparency: •••
      CGContextRestoreGState(context)                                                       // context: •••



      CGContextEndTransparencyLayer(context)                                                // transparency: ••

      CGContextRestoreGState(context)                                                       // context: ••
    }


    if let text: NSString = text {
      let appliedFontSize: CGFloat = min(baseRect.size.width / CGFloat(text.length), baseRect.size.height)

      CGContextSaveGState(context)                                                          // context: •••
      contentOuterShadow?.setShadow()

      let attributes: [String:AnyObject]

      if fontAttributes != nil {

        var attrs = fontAttributes!
        if let f = attrs[NSFontAttributeName] as? UIFont { attrs[NSFontAttributeName] = f.fontWithSize(appliedFontSize) }
        attributes = attrs

      } else {

        let paragraphStyle = NSParagraphStyle.paragraphStyleWithAttributes(alignment: .Center)
        let font = UIFont(name: "HelveticaNeue-Bold", size: appliedFontSize)!
        let fg = UIColor.blackColor()
        attributes = [ NSFontAttributeName           : font,
                       NSForegroundColorAttributeName: fg,
                       NSParagraphStyleAttributeName : paragraphStyle ]

      }

      let textHeight: CGFloat = text.boundingRectWithSize(CGSize(width: bleedRect.width, height: CGFloat.infinity),
                                                 options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                                              attributes: attributes,
                                                 context: nil).size.height
      CGContextSaveGState(context)                                                          // context: ••••
      CGContextClipToRect(context, bleedRect);
      let textRect = CGRect(x: bleedRect.minX,
                            y: bleedRect.minY + (bleedRect.height - textHeight) * 0.5,
                            width: bleedRect.width,
                            height: textHeight)
      text.drawInRect(textRect, withAttributes: attributes)
      CGContextRestoreGState(context)                                                       // context: •••
      CGContextRestoreGState(context)                                                       // context: ••

    }


    CGContextEndTransparencyLayer(context)                                                  // transparency: •
    CGContextRestoreGState(context)                                                         // context: •


    CGContextEndTransparencyLayer(context)                                                  // transparency:
    CGContextRestoreGState(context)                                                         // context:


    if (applyGloss) {

      CGContextSaveGState(context)                                                          // context: •
      CGContextSetBlendMode(context, kCGBlendModeSourceAtop)
      CGContextBeginTransparencyLayer(context, nil)                                         // transparency: •


      CGContextSaveGState(context)                                                          // context: ••
      CGContextClipToRect(context, baseRect)
      CGContextTranslateCTM(context, baseRect.origin.x, baseRect.origin.y)
      drawGlossWithShape(shape, inRect: CGRect(size: baseRect.size), byRoundingCorners: corners, withRadii: radii)
      CGContextRestoreGState(context)                                                       // context: •


      CGContextEndTransparencyLayer(context)                                                // transparency:
      CGContextRestoreGState(context)                                                       // context:
    }

  }

  /**
  drawShape:inRect:withColor:byRoundingCorners:withRadii:

  :param: shape Shape
  :param: rect CGRect
  :param: color UIColor = defaultContentColor
  :param: corners UIRectCorner = defaultCorners
  :param: radii CGSize = defaultRadii
  */
  public class func drawShape(shape: Shape,
                       inRect rect: CGRect,
                    withColor color: UIColor = defaultContentColor,
            byRoundingCorners corners: UIRectCorner = defaultCorners,
                    withRadii radii: CGSize = defaultRadii)
  {


    let context = UIGraphicsGetCurrentContext()

    CGContextSaveGState(context)
    UIRectClip(rect)
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y)
    color.setFill()
    let insetRect = CGRect(size: rect.size).rectByInsetting(dx: 2, dy: 2)
    let drawingPath = pathForShape(shape, inRect: insetRect, byRoundingCorners: corners, withRadii: radii)
    drawingPath.fill()
    CGContextRestoreGState(context)

  }

  /**
  drawGlossWithShape:inRect:byRoundingCorners:withRadii:

  :param: shape Shape
  :param: rect CGRect
  :param: corners UIRectCorner = defaultCorners
  :param: radii CGSize = defaultRadii
  */
  public class func drawGlossWithShape(shape: Shape,
                                inRect rect: CGRect,
                     byRoundingCorners corners: UIRectCorner = defaultCorners,
                             withRadii radii: CGSize = defaultRadii)
  {

    let context = UIGraphicsGetCurrentContext()
    let insetRect = rect.rectByInsetting(dx: 0, dy: 0)

    CGContextSaveGState(context)
    UIRectClip(insetRect)
    CGContextTranslateCTM(context, insetRect.origin.x, insetRect.origin.y)
    let path = pathForShape(shape, inRect: CGRect(size: insetRect.size), byRoundingCorners: corners, withRadii: radii)

    CGContextSetAlpha(context, 0.1)

    path.addClip()
    let bounds = path.bounds
    let p1 = CGPoint(x: bounds.midX, y: bounds.midY + 0.5 * bounds.height)
    let p2 = CGPoint(x: bounds.midX, y: bounds.midY)
    let options = UInt32(kCGGradientDrawsBeforeStartLocation) | UInt32(kCGGradientDrawsAfterEndLocation)
    CGContextDrawLinearGradient(context, verticalGloss, p1, p2, options)

    CGContextRestoreGState(context)
  }

}
