//
//  ColorInputView.swift
//  Remote
//
//  Created by Jason Cardwell on 12/07/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit

public protocol ColorInput: class {
  var redValue:   Float { get set }
  var greenValue: Float { get set }
  var blueValue:  Float { get set }
  var alphaValue: Float { get set }
}

public final class ColorInputView: UIInputView {

  /**
  initWithFrame:colorInput:

  - parameter frame: CGRect
  - parameter colorInput: ColorInput
  */
  public init(frame: CGRect, colorInput: ColorInput) {
    super.init(frame: frame, inputViewStyle: .Keyboard)

    let r = Slider(style: .Gradient(.Red), autolayout: true)
    r.value = colorInput.redValue
    r.minimumTrackTintColor = UIColor.redColor()
    r.addActionBlock({ colorInput.redValue = r.value }, forControlEvents: .ValueChanged)
    addSubview(r)

    let g = Slider(style: .Gradient(.Green), autolayout: true)
    g.value = colorInput.greenValue
    g.minimumTrackTintColor = UIColor.greenColor()
    g.addActionBlock({ colorInput.greenValue = g.value }, forControlEvents: .ValueChanged)
    addSubview(g)

    let b = Slider(style: .Gradient(.Blue), autolayout: true)
    b.value = colorInput.blueValue
    b.minimumTrackTintColor = UIColor.blueColor()
    b.addActionBlock({ colorInput.blueValue = b.value }, forControlEvents: .ValueChanged)
    addSubview(b)

    let a = Slider(style: .Gradient(.Alpha), autolayout: true)
    a.value = colorInput.alphaValue
    a.minimumTrackTintColor = UIColor.whiteColor()
    a.addActionBlock({ colorInput.alphaValue = a.value }, forControlEvents: .ValueChanged)
    addSubview(a)

    let format = "\n".join(
      "|-20-[r]-20-|",
      "|-20-[g]-20-|",
      "|-20-[b]-20-|",
      "|-20-[a]-20-|",
      "V:|-(>=20)-[r]-[g]-[b]-[a]-(>=20)-|"
    )

    constrain(format, views: ["r": r, "g": g, "b": b, "a": a])

  }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}
