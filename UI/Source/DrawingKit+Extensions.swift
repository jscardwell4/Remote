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

  public class func roundishBasePath(#frame: CGRect, radius: CGFloat) -> UIBezierPath {
    return UIBezierPath(roundedRect: frame.rectByInsetting(dx: 2, dy: 2), cornerRadius: radius)
  }

  public class func rectangularBasePath(#frame: CGRect) -> UIBezierPath {
    return UIBezierPath(rect: frame.rectByInsetting(dx: 2, dy: 2))
  }

  public class func ovalBasePath(#frame: CGRect) -> UIBezierPath {
    return UIBezierPath(ovalInRect: frame.rectByInsetting(dx: 2, dy: 2))
  }

  public class func diamondBasePath(#frame: CGRect) -> UIBezierPath {
    var path = UIBezierPath()
    path.moveToPoint(CGPoint(x: frame.minX + 2, y: frame.minY + 0.5 * frame.height))
    path.addLineToPoint(CGPoint(x: frame.minX + 0.5 * frame.width, y: frame.minY + 2))
    path.addLineToPoint(CGPoint(x: frame.maxX - 2, y: frame.minY + 0.5 * frame.height))
    path.addLineToPoint(CGPoint(x: frame.minX + 0.5 * frame.width, y: frame.maxY - 2))
    path.addLineToPoint(CGPoint(x: frame.minX + 2, y: frame.minY + 0.5 * frame.height))
    path.closePath()
    return path
  }

  public class func triangleBasePath(#frame: CGRect) -> UIBezierPath {
    let r = CGRect(x: frame.minX + 7.2, y: frame.minY + 9.5, width: frame.width - 13.4, height: frame.height - 25)
    var path = UIBezierPath()
    path.moveToPoint(CGPoint(x: r.minX + 0.5 * r.width, y: r.minY))
    path.addLineToPoint(CGPoint(x: r.minX + 0.75 * r.width, y: r.minY + 0.5 * r.height))
    path.addLineToPoint(CGPoint(x: r.minX + r.width, y: r.minY + r.height))
    path.addLineToPoint(CGPoint(x: r.minX + 0.5 * r.width, y: r.minY + r.height))
    path.addLineToPoint(CGPoint(x: r.minX, y: r.minY + r.height))
    path.addLineToPoint(CGPoint(x: r.minX + 0.25 * r.width, y: r.minY + 0.5 * r.height))
    path.addLineToPoint(CGPoint(x: r.minX + 0.5 * r.width, y: r.minY ))
    path.closePath()
    return path
  }


  public class func drawSelectedButtonBase(#frame: CGRect, color: UIColor, contentColor: UIColor, radius: CGFloat, shape: Shape) {
    //// General Declarations
    let context = UIGraphicsGetCurrentContext()

    CGContextSaveGState(context)
    UIRectClip(frame)
    CGContextTranslateCTM(context, frame.origin.x, frame.origin.y)

    CGContextScaleCTM(context, frame.size.width / 200, frame.size.height / 200)
    let rect = CGRect(size: CGSize(square: 200))


    switch shape {
      case .Diamond:          DrawingKit.drawDiamondButtonBase(color: color, contentColor: contentColor, rect: rect)
      case .Oval:             DrawingKit.drawOvalButtonBase(color: color, contentColor: contentColor, rect: rect)
      case .Triangle:         DrawingKit.drawTriangleButtonBase(color: color, contentColor: contentColor, rect: rect)
      case .Rectangle:        DrawingKit.drawRectangularButtonBase(color: color, contentColor: contentColor, rect: rect)
      case .RoundedRectangle: DrawingKit.drawRoundedButtonBase(color: color, contentColor: contentColor, radius: radius, rect: rect)
      default:                break
    }

    CGContextRestoreGState(context)
  }

  public class func drawButton(#rect: CGRect,
                               color: UIColor = defaultButtonColor,
                               contentColor: UIColor = defaultContentColor,
                               image: UIImage? = nil,
                               radius: CGFloat = 10.0,
                               text: String? = nil,
                               fontAttributes: [String:AnyObject]? = nil,
                               applyGloss: Bool = true,
                               shape: Shape,
                               highlighted: Bool = false)
  {
    let context = UIGraphicsGetCurrentContext()

    // TODO: Check points against path for the sides of min/max font height, i.e. shrink more for diamond/triangle shapes
    let contentAndBaseRect = rect.rectByInsetting(dx: 4, dy: 4)
    let bleedGroupRect = contentAndBaseRect.rectByInsetting(dx: 4, dy: 4)

    let contentOuterShadow: NSShadow? = highlighted ? NSShadow(color: contentColor, offset: CGSize.zeroSize, blurRadius: 5) : nil



    //// Bleed
    //// Bleed Base Drawing
    CGContextSaveGState(context)
    UIRectClip(bleedGroupRect)
    CGContextTranslateCTM(context, bleedGroupRect.origin.x, bleedGroupRect.origin.y)

    DrawingKit.drawSelectedButtonShape(frame: CGRect(size: bleedGroupRect.size), contentColor: contentColor, radius: radius, shape: shape)
    CGContextRestoreGState(context)




    //// Content And Base Group
    CGContextSaveGState(context)
    CGContextBeginTransparencyLayer(context, nil)


    //// Base Group
    CGContextSaveGState(context)
    contentOuterShadow?.setShadow()
    CGContextBeginTransparencyLayer(context, nil)


    //// Button Base Drawing
    CGContextSaveGState(context)
    UIRectClip(contentAndBaseRect)
    CGContextTranslateCTM(context, contentAndBaseRect.origin.x, contentAndBaseRect.origin.y)

    DrawingKit.drawSelectedButtonBase(frame: CGRect(size: contentAndBaseRect.size), color: color, contentColor: contentColor, radius: radius, shape: shape)
    CGContextRestoreGState(context)


    CGContextEndTransparencyLayer(context)
    CGContextRestoreGState(context)


    //// Cutout Group
    CGContextSaveGState(context)
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut)
    CGContextBeginTransparencyLayer(context, nil)


    if let img = image {

      let imgSize = img.size

      //// Icon Group
      CGContextSaveGState(context)
      CGContextTranslateCTM(context, (rect.size.width - imgSize.width) / 2.0, (rect.size.height - imgSize.height) / 2.0)

      innerShadow.setShadow()
      CGContextSetAlpha(context, 0.9)
      CGContextBeginTransparencyLayer(context, nil)


      //// Icon Path Drawing
      CGContextSaveGState(context)
      contentOuterShadow?.setShadow()
      CGContextBeginTransparencyLayer(context, nil)
      CGContextSaveGState(context)
      UIBezierPath(rect: CGRect(size: CGSize(square: 100))).addClip()
      img.drawInRect(CGRect(size: imgSize))
      CGContextRestoreGState(context)
      CGContextEndTransparencyLayer(context)
      CGContextRestoreGState(context)



      CGContextEndTransparencyLayer(context)

      CGContextRestoreGState(context)
    }


    if let txt: NSString = text {
      let appliedFontSize: CGFloat = min(rect.size.width / CGFloat(txt.length), rect.size.height)

      CGContextSaveGState(context)
      contentOuterShadow?.setShadow()

      let attributes: [String:AnyObject]
      if fontAttributes != nil {
        var attrs = fontAttributes!
        if let f = attrs[NSFontAttributeName] as? UIFont {
          attrs[NSFontAttributeName] = f.fontWithSize(appliedFontSize)
        }
        attributes = attrs
      }
      else {
        let paragraphStyle = NSParagraphStyle.paragraphStyleWithAttributes(alignment: .Center)
        let font = UIFont(name: "HelveticaNeue-Bold", size: appliedFontSize)!
        let fg = UIColor.blackColor()
        attributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: fg, NSParagraphStyleAttributeName: paragraphStyle]
      }

      let textHeight: CGFloat = txt.boundingRectWithSize(CGSize(width: bleedGroupRect.width, height: CGFloat.infinity),
                                                 options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                                              attributes: attributes,
                                                 context: nil).size.height
      CGContextSaveGState(context)
      CGContextClipToRect(context, bleedGroupRect);
      let textRect = CGRect(x: bleedGroupRect.minX,
                            y: bleedGroupRect.minY + (bleedGroupRect.height - textHeight) / 2,
                            width: bleedGroupRect.width,
                            height: textHeight)
      txt.drawInRect(textRect, withAttributes: attributes)
      CGContextRestoreGState(context)
      CGContextRestoreGState(context)



    }


    CGContextEndTransparencyLayer(context)
    CGContextRestoreGState(context)


    CGContextEndTransparencyLayer(context)
    CGContextRestoreGState(context)


    if (applyGloss) {
      //// Gloss Overlay Group
      CGContextSaveGState(context)
      CGContextSetAlpha(context, 0.1)
      CGContextSetBlendMode(context, kCGBlendModeSourceAtop)
      CGContextBeginTransparencyLayer(context, nil)


      //// Gloss Overlay Drawing
      let glossOverlayRect = CGRect(x: rect.minX, y: rect.minY, width: floor(rect.width + 0.5), height: floor(rect.height + 0.5))
      CGContextSaveGState(context)
      UIRectClip(glossOverlayRect)
      CGContextTranslateCTM(context, glossOverlayRect.origin.x, glossOverlayRect.origin.y)

      DrawingKit.drawSelectedGloss(frame: CGRect(size: glossOverlayRect.size), radius: radius, shape: shape)
      CGContextRestoreGState(context)


      CGContextEndTransparencyLayer(context)
      CGContextRestoreGState(context)
    }
  }

  public class func drawSelectedButtonShape(#frame: CGRect, contentColor: UIColor, radius: CGFloat, shape: Shape) {


    let context = UIGraphicsGetCurrentContext()

    CGContextSaveGState(context)
    UIRectClip(frame)
    CGContextTranslateCTM(context, frame.origin.x, frame.origin.y)
    let rect = CGRect(size: frame.size)


    switch shape {
    case .Diamond:          DrawingKit.drawDiamondPath(frame: rect, contentColor: contentColor)
    case .Oval:             DrawingKit.drawOvalPath(frame: rect, contentColor: contentColor)
    case .Triangle:         DrawingKit.drawTrianglePath(frame: rect, contentColor: contentColor)
    case .Rectangle:        DrawingKit.drawRectangularPath(frame: rect, contentColor: contentColor)
    case .RoundedRectangle: DrawingKit.drawRoundedRectanglePath(frame: rect, contentColor: contentColor, radius: radius)
    default:                break
    }

    CGContextRestoreGState(context)

  }

  public class func drawSelectedGloss(#frame: CGRect, radius: CGFloat, shape: Shape) {

    let context = UIGraphicsGetCurrentContext()

    CGContextSaveGState(context)
    UIRectClip(frame)
    CGContextTranslateCTM(context, frame.origin.x, frame.origin.y)
    let rect = CGRect(size: frame.size)

    switch shape {
      case .Diamond:          DrawingKit.drawDiamondGloss(frame: rect)
      case .Oval:             DrawingKit.drawOvalGloss(frame: rect)
      case .Triangle:         DrawingKit.drawTriangleGloss(frame: rect)
      case .Rectangle:        DrawingKit.drawRectangleGloss(frame: rect)
      case .RoundedRectangle: DrawingKit.drawRoundedGloss(frame: rect, radius: radius)
      default:                break
    }

    CGContextRestoreGState(context)
  }

}
