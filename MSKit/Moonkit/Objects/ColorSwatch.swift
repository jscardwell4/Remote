//
//  ColorSwatch.swift
//  Remote
//
//  Created by Jason Cardwell on 12/07/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit

public class ColorSwatch: UIControl {

  public var color: UIColor = UIColor.whiteColor() { didSet { setNeedsDisplay() } }

  /**
  drawRect:

  :param: rect CGRect
  */
  public override func drawRect(rect: CGRect) {

   //// General Declarations
    let context = UIGraphicsGetCurrentContext()


    //// Shadow Declarations
    let dropShadow = NSShadow(color: UIColor.blackColor().colorWithAlphaComponent(0.15), offset: CGSizeMake(0.1, 3.1), blurRadius: 1)
    let swatchBaseInnerShadow = NSShadow(color: UIColor.whiteColor(), offset: CGSizeMake(0.1, -0.1), blurRadius: 5)
    let swatchBaseStrokeShadow = NSShadow(color: UIColor.blackColor().colorWithAlphaComponent(0.43), offset: CGSizeMake(0.1, -0.1), blurRadius: 1)
    let swatchInnerShadow = NSShadow(color: UIColor.blackColor().colorWithAlphaComponent(0.45), offset: CGSizeMake(0.1, -0.1), blurRadius: 1)


    //// Subframes
    let group2: CGRect = CGRectMake(rect.minX + 2, rect.minY + 2, rect.width - 4, rect.height - 7)
    let group: CGRect = CGRectMake(rect.minX + 2.5, rect.minY + 2.5, rect.width - 5, rect.height - 8)


    //// Group 2
    //// Rectangle Drawing
    let rectanglePath = UIBezierPath(rect: CGRectMake(group2.minX + floor(group2.width * 0.00000 + 0.5), group2.minY + floor(group2.height * 0.00000 + 0.5), floor(group2.width * 1.00000 + 0.5) - floor(group2.width * 0.00000 + 0.5), floor(group2.height * 1.00000 + 0.5) - floor(group2.height * 0.00000 + 0.5)))
    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, dropShadow.shadowOffset, dropShadow.shadowBlurRadius, (dropShadow.shadowColor as UIColor).CGColor)
    UIColor.whiteColor().setFill()
    rectanglePath.fill()

    ////// Rectangle Inner Shadow
    CGContextSaveGState(context)
    CGContextClipToRect(context, rectanglePath.bounds)
    CGContextSetShadow(context, CGSizeMake(0, 0), 0)
    CGContextSetAlpha(context, CGColorGetAlpha((swatchBaseInnerShadow.shadowColor as UIColor).CGColor))
    CGContextBeginTransparencyLayer(context, nil)
    let rectangleOpaqueShadow = (swatchBaseInnerShadow.shadowColor as UIColor).colorWithAlphaComponent(1)
    CGContextSetShadowWithColor(context, swatchBaseInnerShadow.shadowOffset, swatchBaseInnerShadow.shadowBlurRadius, (rectangleOpaqueShadow as UIColor).CGColor)
    CGContextSetBlendMode(context, kCGBlendModeSourceOut)
    CGContextBeginTransparencyLayer(context, nil)

    rectangleOpaqueShadow.setFill()
    rectanglePath.fill()

    CGContextEndTransparencyLayer(context)
    CGContextEndTransparencyLayer(context)
    CGContextRestoreGState(context)

    CGContextRestoreGState(context)

    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, swatchBaseStrokeShadow.shadowOffset, swatchBaseStrokeShadow.shadowBlurRadius, (swatchBaseStrokeShadow.shadowColor as UIColor).CGColor)
    UIColor.whiteColor().setStroke()
    rectanglePath.lineWidth = 0.5
    rectanglePath.stroke()
    CGContextRestoreGState(context)




    //// Group
    //// swatch Drawing
    let swatchPath = UIBezierPath(rect: CGRectMake(group.minX + floor(group.width * 0.00000 + 0.5), group.minY + floor(group.height * 0.00000 + 0.5), floor(group.width * 1.00000 + 0.5) - floor(group.width * 0.00000 + 0.5), floor(group.height * 1.00000 + 0.5) - floor(group.height * 0.00000 + 0.5)))
    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, swatchInnerShadow.shadowOffset, swatchInnerShadow.shadowBlurRadius, (swatchInnerShadow.shadowColor as UIColor).CGColor)
    color.setFill()
    swatchPath.fill()
    CGContextRestoreGState(context)

  }

  /**
  canBecomeFirstResponder

  :returns: Bool
  */
  public override func canBecomeFirstResponder() -> Bool { return true }

  public override var inputView: UIView? {
    return ColorInputView(frame: CGRect(size: CGSize(width: UIScreen.mainScreen().bounds.width, height: 200)), colorInput: self)
  }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  public override init(frame: CGRect) {
    super.init(frame: frame)
    opaque = false
    backgroundColor = UIColor.clearColor()
    addActionBlock({ self.toggleFirstResponder() }, forControlEvents: .TouchUpInside)
  }

  /** init */
  public override init() { super.init() }

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
  public override func intrinsicContentSize() -> CGSize { return CGSize(width: 50, height: 34) }

}

extension ColorSwatch: ColorInput {
  public var redValue:   Float { get { return Float(color.red   ?? 0) } set { color = color.colorWithRed(CGFloat(newValue))   } }
  public var greenValue: Float { get { return Float(color.green ?? 0) } set { color = color.colorWithGreen(CGFloat(newValue)) } }
  public var blueValue:  Float { get { return Float(color.blue  ?? 0) } set { color = color.colorWithBlue(CGFloat(newValue))  } }
  public var alphaValue: Float { get { return Float(color.alpha ?? 0) } set { color = color.colorWithAlpha(CGFloat(newValue)) } }
}
