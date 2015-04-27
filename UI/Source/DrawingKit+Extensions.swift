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

  public class func drawButton(#rect: CGRect,
                               color: UIColor,
                               contentColor: UIColor,
                               image: UIImage? = nil,
                               imageOffset: CGPoint = CGPoint.zeroPoint,
                               radius: CGFloat = 5.0,
                               text: String? = nil,
                               applyGloss: Bool = true,
                               shape: RemoteElement.Shape = RemoteElement.Shape.Rectangle,
                               iconSize: CGSize,
                               highlighted: Bool = false)
  {
    //// General Declarations
    let context = UIGraphicsGetCurrentContext()


    //// Variable Declarations
    let useOvalBase = shape == RemoteElement.Shape.Oval
    let useDiamondBase = shape == RemoteElement.Shape.Diamond
    let useTriangleBase = shape == RemoteElement.Shape.Triangle
    let useRoundishBase = shape == RemoteElement.Shape.RoundedRectangle
    let useRectangularBase = shape == RemoteElement.Shape.Rectangle

    let widthBasedFontSize: CGFloat = text != nil ? rect.size.width / CGFloat(count(text!.utf16)) : 0
    let heightBasedFontSize: CGFloat = rect.size.height
    let appliedFontSize: CGFloat = min(widthBasedFontSize, heightBasedFontSize)

    let offsetIcon = CGPointMake((rect.size.width - iconSize.width) / 2.0, (rect.size.height - iconSize.height) / 2.0)
    let iconXScale: CGFloat = iconSize.width / rect.size.width
    let iconYScale: CGFloat = iconSize.height / rect.size.height

    let contentAndBaseRect = CGRectMake(4, 4, rect.size.width - 8, rect.size.height - 8)
    let bleedGroupRect = CGRectMake(contentAndBaseRect.origin.x + 4, contentAndBaseRect.origin.y + 4, contentAndBaseRect.size.width - 8, contentAndBaseRect.size.height - 8)

    let contentOuterShadow = highlighted ? NSShadow(color: contentColor, offset: CGSizeMake(0, -0), blurRadius: 5) : NSShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0), offset: CGSizeMake(0, -0), blurRadius: 0)


    //// Subrects
    let glossOverlayGroup: CGRect = CGRectMake(rect.minX + floor(rect.width * 0 + 0.5), rect.minY + floor(rect.height * 0 + 0.5), floor(rect.width * 1 + 0.5) - floor(rect.width * 0 + 0.5), floor(rect.height * 1 + 0.5) - floor(rect.height * 0 + 0.5))


    //// Bleed
    if (useDiamondBase) {
      //// Diamond Bleed Drawing
      let diamondBleedRect = CGRectMake(bleedGroupRect.origin.x, bleedGroupRect.origin.y, bleedGroupRect.size.width, bleedGroupRect.size.height)
      UIGraphicsPushContext(context)
      UIRectClip(diamondBleedRect)
      CGContextTranslateCTM(context, diamondBleedRect.origin.x, diamondBleedRect.origin.y)

      DrawingKit.drawDiamondPath(frame: CGRectMake(0, 0, diamondBleedRect.size.width, diamondBleedRect.size.height), contentColor: contentColor)
      UIGraphicsPopContext()
    }


    if (useOvalBase) {
      //// Oval Bleed Drawing
      let ovalBleedRect = CGRectMake(bleedGroupRect.origin.x, bleedGroupRect.origin.y, bleedGroupRect.size.width, bleedGroupRect.size.height)
      UIGraphicsPushContext(context)
      UIRectClip(ovalBleedRect)
      CGContextTranslateCTM(context, ovalBleedRect.origin.x, ovalBleedRect.origin.y)

      DrawingKit.drawOvalPath(frame: CGRectMake(0, 0, ovalBleedRect.size.width, ovalBleedRect.size.height), contentColor: contentColor)
      UIGraphicsPopContext()
    }


    if (useTriangleBase) {
      //// Triangular Bleed Drawing
      let triangularBleedRect = CGRectMake(bleedGroupRect.origin.x, bleedGroupRect.origin.y, bleedGroupRect.size.width, bleedGroupRect.size.height)
      UIGraphicsPushContext(context)
      UIRectClip(triangularBleedRect)
      CGContextTranslateCTM(context, triangularBleedRect.origin.x, triangularBleedRect.origin.y)

      DrawingKit.drawTrianglePath(frame: CGRectMake(0, 0, triangularBleedRect.size.width, triangularBleedRect.size.height), contentColor: contentColor)
      UIGraphicsPopContext()
    }


    if (useRectangularBase) {
      //// Rectangular Bleed Drawing
      let rectangularBleedRect = CGRectMake(bleedGroupRect.origin.x, bleedGroupRect.origin.y, bleedGroupRect.size.width, bleedGroupRect.size.height)
      UIGraphicsPushContext(context)
      UIRectClip(rectangularBleedRect)
      CGContextTranslateCTM(context, rectangularBleedRect.origin.x, rectangularBleedRect.origin.y)

      DrawingKit.drawRectangularPath(frame: CGRectMake(0, 0, rectangularBleedRect.size.width, rectangularBleedRect.size.height), contentColor: contentColor)
      UIGraphicsPopContext()
    }


    if (useRoundishBase) {
      //// Roundish Bleed Drawing
      let roundishBleedRect = CGRectMake(bleedGroupRect.origin.x, bleedGroupRect.origin.y, bleedGroupRect.size.width, bleedGroupRect.size.height)
      UIGraphicsPushContext(context)
      UIRectClip(roundishBleedRect)
      CGContextTranslateCTM(context, roundishBleedRect.origin.x, roundishBleedRect.origin.y)

      DrawingKit.drawRoundishPath(frame: CGRectMake(0, 0, roundishBleedRect.size.width, roundishBleedRect.size.height), contentColor: contentColor, radius: radius)
      UIGraphicsPopContext()
    }




    //// Content And Base Group
    UIGraphicsPushContext(context)
    CGContextBeginTransparencyLayer(context, nil)


    //// Base Group
    UIGraphicsPushContext(context)
    CGContextSetShadowWithColor(context, contentOuterShadow.shadowOffset, contentOuterShadow.shadowBlurRadius, (contentOuterShadow.shadowColor as! UIColor).CGColor)
    CGContextBeginTransparencyLayer(context, nil)


    if (useRectangularBase) {
      //// Rectangular Base Drawing
      let rectangularBaseRect = CGRectMake(0, 0, 200, 200)
      UIGraphicsPushContext(context)
      UIRectClip(rectangularBaseRect)
      CGContextTranslateCTM(context, rectangularBaseRect.origin.x, rectangularBaseRect.origin.y)

      DrawingKit.drawRectangularButtonBase(frame: CGRectMake(0, 0, rectangularBaseRect.size.width, rectangularBaseRect.size.height), color: color, contentColor: contentColor)
      UIGraphicsPopContext()
    }


    if (useRoundishBase) {
      //// Roundish Base Drawing
      let roundishBaseRect = CGRectMake(0, 0, 200, 200)
      UIGraphicsPushContext(context)
      UIRectClip(roundishBaseRect)
      CGContextTranslateCTM(context, roundishBaseRect.origin.x, roundishBaseRect.origin.y)

      DrawingKit.drawRoundishButtonBase(frame: CGRectMake(0, 0, roundishBaseRect.size.width, roundishBaseRect.size.height), color: color, contentColor: contentColor, radius: 5)
      UIGraphicsPopContext()
    }


    if (useOvalBase) {
      //// Oval Base Drawing
      let ovalBaseRect = CGRectMake(0, 0, 200, 200)
      UIGraphicsPushContext(context)
      UIRectClip(ovalBaseRect)
      CGContextTranslateCTM(context, ovalBaseRect.origin.x, ovalBaseRect.origin.y)

      DrawingKit.drawOvalButtonBase(frame: CGRectMake(0, 0, ovalBaseRect.size.width, ovalBaseRect.size.height), color: color, contentColor: contentColor)
      UIGraphicsPopContext()
    }


    if (useDiamondBase) {
      //// Diamond Base Drawing
      let diamondBaseRect = CGRectMake(0, 0, 200, 200)
      UIGraphicsPushContext(context)
      UIRectClip(diamondBaseRect)
      CGContextTranslateCTM(context, diamondBaseRect.origin.x, diamondBaseRect.origin.y)

      DrawingKit.drawDiamondButtonBase(frame: CGRectMake(0, 0, diamondBaseRect.size.width, diamondBaseRect.size.height), color: color, contentColor: contentColor)
      UIGraphicsPopContext()
    }


    if (useTriangleBase) {
      //// Triangle Base Drawing
      let triangleBaseRect = CGRectMake(0, 0, 200, 200)
      UIGraphicsPushContext(context)
      UIRectClip(triangleBaseRect)
      CGContextTranslateCTM(context, triangleBaseRect.origin.x, triangleBaseRect.origin.y)

      DrawingKit.drawTriangleButtonBase(frame: CGRectMake(0, 0, triangleBaseRect.size.width, triangleBaseRect.size.height), color: color, contentColor: contentColor)
      UIGraphicsPopContext()
    }


    CGContextEndTransparencyLayer(context)
    UIGraphicsPopContext()


    //// Cutout Group
    UIGraphicsPushContext(context)
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut)
    CGContextBeginTransparencyLayer(context, nil)


    if let icon = image {
      //// Icon Group
      UIGraphicsPushContext(context)
      CGContextSetShadowWithColor(context, DrawingKit.innerShadow.shadowOffset, DrawingKit.innerShadow.shadowBlurRadius, (DrawingKit.innerShadow.shadowColor as! UIColor).CGColor)
      CGContextSetAlpha(context, 0.9)
      CGContextBeginTransparencyLayer(context, nil)


      //// Icon Path Drawing
      UIGraphicsPushContext(context)
      CGContextTranslateCTM(context, (offsetIcon.x - 50), (offsetIcon.y - 50))
      CGContextScaleCTM(context, iconXScale, iconYScale)

      let iconPathRect = CGRectMake(imageOffset.x, imageOffset.y, 200, 200)
      let iconPathPath = UIBezierPath(rect: iconPathRect)
      UIGraphicsPushContext(context)
      CGContextSetShadowWithColor(context, contentOuterShadow.shadowOffset, contentOuterShadow.shadowBlurRadius, (contentOuterShadow.shadowColor as! UIColor).CGColor)
      CGContextBeginTransparencyLayer(context, nil)
      UIGraphicsPushContext(context)
      iconPathPath.addClip()
      icon.drawInRect(CGRectMake(floor(iconPathRect.minX + 0.5), floor(iconPathRect.minY + 0.5), icon.size.width, icon.size.height))
      UIGraphicsPopContext()
      CGContextEndTransparencyLayer(context)
      UIGraphicsPopContext()


      UIGraphicsPopContext()


      CGContextEndTransparencyLayer(context)
      UIGraphicsPopContext()
    }


    if let text = text {
      //// Label Group
      //// label Drawing
      let labelRect = CGRectMake(0, 0, 200, 200)
      UIGraphicsPushContext(context)
      CGContextSetShadowWithColor(context, contentOuterShadow.shadowOffset, contentOuterShadow.shadowBlurRadius, (contentOuterShadow.shadowColor as! UIColor).CGColor)
      let labelStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
      labelStyle.alignment = NSTextAlignment.Center

      let labelFontAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: appliedFontSize)!, NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: labelStyle]

      let labelTextHeight: CGFloat = NSString(string: text).boundingRectWithSize(CGSizeMake(labelRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: labelFontAttributes, context: nil).size.height
      UIGraphicsPushContext(context)
      CGContextClipToRect(context, labelRect);
      NSString(string: text).drawInRect(CGRectMake(labelRect.minX, labelRect.minY + (labelRect.height - labelTextHeight) / 2, labelRect.width, labelTextHeight), withAttributes: labelFontAttributes)
      UIGraphicsPopContext()
      UIGraphicsPopContext()



    }


    CGContextEndTransparencyLayer(context)
    UIGraphicsPopContext()


    CGContextEndTransparencyLayer(context)
    UIGraphicsPopContext()


    if (applyGloss) {
      //// Gloss Overlay Group
      UIGraphicsPushContext(context)
      CGContextSetAlpha(context, 0.5)
      CGContextSetBlendMode(context, kCGBlendModeOverlay)
      CGContextBeginTransparencyLayer(context, nil)


      //// Gloss Overlay Drawing
      let glossOverlayRect = CGRectMake(glossOverlayGroup.minX + floor(glossOverlayGroup.width * 0 + 0.5), glossOverlayGroup.minY + floor(glossOverlayGroup.height * 0 + 0.5), floor(glossOverlayGroup.width * 1 + 0.5) - floor(glossOverlayGroup.width * 0 + 0.5), floor(glossOverlayGroup.height * 1 + 0.5) - floor(glossOverlayGroup.height * 0 + 0.5))
      UIGraphicsPushContext(context)
      UIRectClip(glossOverlayRect)
      CGContextTranslateCTM(context, glossOverlayRect.origin.x, glossOverlayRect.origin.y)

      DrawingKit.drawGloss(frame: CGRectMake(0, 0, glossOverlayRect.size.width, glossOverlayRect.size.height))
      UIGraphicsPopContext()


      CGContextEndTransparencyLayer(context)
      UIGraphicsPopContext()
    }
  }
}
