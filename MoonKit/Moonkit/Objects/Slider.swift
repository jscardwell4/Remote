//
//  Slider.swift
//  MSKit
//
//  Created by Jason Cardwell on 12/6/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

public class Slider: UISlider {

  public enum SliderStyle {

    public enum ColorType { case Red, Green, Blue, Alpha }

    case Custom ((Slider) -> UIImage)
    case OneTone (ColorType)
    case TwoTone (ColorType)
    case Gradient (ColorType)

  }

  public var sliderStyle: SliderStyle = .Custom({
    (slider: Slider) -> UIImage in
      let color = UIColor.whiteColor()
      let shadow = DrawingKit.invisibleShadow
      return DrawingKit.imageOfOneToneCircle(color: color, opacity: 1.0)
    })
  {
    didSet { updateThumbImage() }
  }

  override public var value: Float { didSet { updateThumbImage() } }

  /** updateThumbImage */
  func updateThumbImage() {

    let value = CGFloat(self.value / minimumValue.distanceTo(maximumValue))
    var image: UIImage

    switch sliderStyle {

      case .Custom(let generateThumbImage):
        image = generateThumbImage(self)

      case .OneTone(let colorType):
        switch colorType {
          case .Red:
            image = DrawingKit.imageOfRedCircle(opacity: value)
          case .Green:
            image = DrawingKit.imageOfGreenCircle(opacity: value)
          case .Blue:
            image = DrawingKit.imageOfBlueCircle(opacity: value)
          case .Alpha:
            image = DrawingKit.imageOfAlphaCircle(opacity: value)
        }

      case .TwoTone(let colorType):
        switch colorType {
          case .Red:
            image = DrawingKit.imageOfRedValueCircle(value: value)
          case .Green:
            image = DrawingKit.imageOfGreenValueCircle(value: value)
          case .Blue:
            image = DrawingKit.imageOfBlueValueCircle(value: value)
          case .Alpha:
            image = DrawingKit.imageOfAlphaValueCircle(value: value)
        }

      case .Gradient(let colorType):
        switch colorType {
          case .Red:
            image = DrawingKit.imageOfRedGradientCircle(opacity: value)
          case .Green:
            image = DrawingKit.imageOfGreenGradientCircle(opacity: value)
          case .Blue:
            image = DrawingKit.imageOfBlueGradientCircle(opacity: value)
          case .Alpha:
            image = DrawingKit.imageOfAlphaGradientCircle(opacity: value)
        }

    }
    setThumbImage(image, forState: .Normal)
  }


  /**
  initWithFrame:

  :param: frame CGRect
  */
  public override init(frame: CGRect) {
    super.init(frame: frame)
    addTarget(self, action: "updateThumbImage", forControlEvents: .ValueChanged)
    updateThumbImage()
  }

  /**
  initWithAutolayout:

  :param: autolayout Bool
  */
  public convenience init(autolayout: Bool = false) {
    self.init(frame: CGRect.zeroRect)
    setTranslatesAutoresizingMaskIntoConstraints(!autolayout)
    updateThumbImage()
  }

  /**
  initWithType:autolayout:

  :param: style SliderStyle
  :param: autolayout Bool = false
  */
  public convenience init(style: SliderStyle, autolayout: Bool = false) {
    self.init(autolayout: autolayout)
    sliderStyle = style
    updateThumbImage()
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  public required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }


}
