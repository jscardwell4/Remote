//
//  Checkbox.swift
//  Remote
//
//  Created by Jason Cardwell on 12/06/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit

public class Checkbox: UIControl {

  public var checked: Bool = false { didSet { setNeedsDisplay() } }

  /** toggleChecked */
  public func toggleChecked() { checked = !checked }

  /** init */
  public override init() { super.init(); addTarget(self, action: "toggleChecked", forControlEvents: .TouchUpInside) }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  public override init(frame: CGRect) {
    super.init(frame: frame)
    addTarget(self, action: "toggleChecked", forControlEvents: .TouchUpInside)
  }

  /**
  initWithAutolayout:

  :param: autolayout Bool
  */
  public convenience init(autolayout: Bool) { self.init(); setTranslatesAutoresizingMaskIntoConstraints(!autolayout) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  public required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /**
  intrinsicContentSize

  :returns: CGSize
  */
  public override func intrinsicContentSize() -> CGSize { return CGSize(square: 44.0) }

  /**
  alignmentRectInsets

  :returns: UIEdgeInsets
  */
  public override func alignmentRectInsets() -> UIEdgeInsets { return UIEdgeInsets(inset: 7.0) }

  /**
  drawRect:

  :param: rect CGRect
  */
  public override func drawRect(rect: CGRect) {
    //// General Declarations
    let context = UIGraphicsGetCurrentContext()

    //// Color Declarations
    let affirmativeGreenColor = UIColor(red: 0.294, green: 0.847, blue: 0.384, alpha: 1.000)

    //// Shadow Declarations
    let semiDarkShadow = UIColor.blackColor().colorWithAlphaComponent(0.44)
    let semiDarkShadowOffset = CGSizeMake(0.1, 2.1)
    let semiDarkShadowBlurRadius: CGFloat = 2
    let lightShadow = UIColor.whiteColor().colorWithAlphaComponent(0.44)
    let lightShadowOffset = CGSizeMake(0.1, 2.1)
    let lightShadowBlurRadius: CGFloat = 2

    //// Rectangle Drawing
    let rectanglePath = UIBezierPath(rect: CGRectMake(rect.minX, rect.minY, 44, 44))
    UIColor.whiteColor().setFill()
    rectanglePath.fill()


    //// box Drawing
    let boxPath = UIBezierPath(roundedRect: CGRectMake(rect.minX + 7, rect.minY + 5, rect.width - 13, rect.height - 13), cornerRadius: 5)
    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, semiDarkShadowOffset, semiDarkShadowBlurRadius, (semiDarkShadow as UIColor).CGColor)
    UIColor.whiteColor().setFill()
    boxPath.fill()

    ////// box Inner Shadow
    CGContextSaveGState(context)
    CGContextClipToRect(context, boxPath.bounds)
    CGContextSetShadow(context, CGSizeMake(0, 0), 0)
    CGContextSetAlpha(context, CGColorGetAlpha((semiDarkShadow as UIColor).CGColor))
    CGContextBeginTransparencyLayer(context, nil)
    let boxOpaqueShadow = (semiDarkShadow as UIColor).colorWithAlphaComponent(1)
    CGContextSetShadowWithColor(context, semiDarkShadowOffset, semiDarkShadowBlurRadius, (boxOpaqueShadow as UIColor).CGColor)
    CGContextSetBlendMode(context, kCGBlendModeSourceOut)
    CGContextBeginTransparencyLayer(context, nil)

    boxOpaqueShadow.setFill()
    boxPath.fill()

    CGContextEndTransparencyLayer(context)
    CGContextEndTransparencyLayer(context)
    CGContextRestoreGState(context)

    CGContextRestoreGState(context)



    if (checked) {
        //// checkmark Drawing
        var checkmarkPath = UIBezierPath()
        checkmarkPath.moveToPoint(CGPointMake(rect.minX + 44, rect.minY + 2.98))
        checkmarkPath.addCurveToPoint(CGPointMake(rect.minX + 40.96, rect.minY), controlPoint1: CGPointMake(rect.minX + 44, rect.minY + 1.33), controlPoint2: CGPointMake(rect.minX + 42.64, rect.minY))
        checkmarkPath.addCurveToPoint(CGPointMake(rect.minX + 38.75, rect.minY + 0.99), controlPoint1: CGPointMake(rect.minX + 40.08, rect.minY), controlPoint2: CGPointMake(rect.minX + 39.3, rect.minY + 0.39))
        checkmarkPath.addLineToPoint(CGPointMake(rect.minX + 38.73, rect.minY + 0.97))
        checkmarkPath.addLineToPoint(CGPointMake(rect.minX + 21.12, rect.minY + 19.82))
        checkmarkPath.addLineToPoint(CGPointMake(rect.minX + 15.18, rect.minY + 13.99))
        checkmarkPath.addLineToPoint(CGPointMake(rect.minX + 15.18, rect.minY + 14))
        checkmarkPath.addCurveToPoint(CGPointMake(rect.minX + 13.04, rect.minY + 13.12), controlPoint1: CGPointMake(rect.minX + 14.63, rect.minY + 13.45), controlPoint2: CGPointMake(rect.minX + 13.87, rect.minY + 13.12))
        checkmarkPath.addCurveToPoint(CGPointMake(rect.minX + 10, rect.minY + 16.1), controlPoint1: CGPointMake(rect.minX + 11.36, rect.minY + 13.12), controlPoint2: CGPointMake(rect.minX + 10, rect.minY + 14.45))
        checkmarkPath.addCurveToPoint(CGPointMake(rect.minX + 10.55, rect.minY + 17.8), controlPoint1: CGPointMake(rect.minX + 10, rect.minY + 16.73), controlPoint2: CGPointMake(rect.minX + 10.21, rect.minY + 17.32))
        checkmarkPath.addLineToPoint(CGPointMake(rect.minX + 10.55, rect.minY + 17.81))
        checkmarkPath.addLineToPoint(CGPointMake(rect.minX + 19.05, rect.minY + 29.73))
        checkmarkPath.addLineToPoint(CGPointMake(rect.minX + 19.05, rect.minY + 29.73))
        checkmarkPath.addCurveToPoint(CGPointMake(rect.minX + 21.54, rect.minY + 31), controlPoint1: CGPointMake(rect.minX + 19.6, rect.minY + 30.49), controlPoint2: CGPointMake(rect.minX + 20.51, rect.minY + 31))
        checkmarkPath.addCurveToPoint(CGPointMake(rect.minX + 23.94, rect.minY + 29.82), controlPoint1: CGPointMake(rect.minX + 22.52, rect.minY + 31), controlPoint2: CGPointMake(rect.minX + 23.39, rect.minY + 30.53))
        checkmarkPath.addLineToPoint(CGPointMake(rect.minX + 23.95, rect.minY + 29.83))
        checkmarkPath.addLineToPoint(CGPointMake(rect.minX + 43.38, rect.minY + 4.79))
        checkmarkPath.addLineToPoint(CGPointMake(rect.minX + 43.37, rect.minY + 4.78))
        checkmarkPath.addCurveToPoint(CGPointMake(rect.minX + 44, rect.minY + 2.98), controlPoint1: CGPointMake(rect.minX + 43.76, rect.minY + 4.28), controlPoint2: CGPointMake(rect.minX + 44, rect.minY + 3.66))
        checkmarkPath.closePath()
        checkmarkPath.miterLimit = 4;

        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, semiDarkShadowOffset, semiDarkShadowBlurRadius, (semiDarkShadow as UIColor).CGColor)
        affirmativeGreenColor.setFill()
        checkmarkPath.fill()

        ////// checkmark Inner Shadow
        CGContextSaveGState(context)
        CGContextClipToRect(context, checkmarkPath.bounds)
        CGContextSetShadow(context, CGSizeMake(0, 0), 0)
        CGContextSetAlpha(context, CGColorGetAlpha((lightShadow as UIColor).CGColor))
        CGContextBeginTransparencyLayer(context, nil)
        let checkmarkOpaqueShadow = (lightShadow as UIColor).colorWithAlphaComponent(1)
        CGContextSetShadowWithColor(context, lightShadowOffset, lightShadowBlurRadius, (checkmarkOpaqueShadow as UIColor).CGColor)
        CGContextSetBlendMode(context, kCGBlendModeSourceOut)
        CGContextBeginTransparencyLayer(context, nil)

        checkmarkOpaqueShadow.setFill()
        checkmarkPath.fill()

        CGContextEndTransparencyLayer(context)
        CGContextEndTransparencyLayer(context)
        CGContextRestoreGState(context)

        CGContextRestoreGState(context)

    }
  }
}
