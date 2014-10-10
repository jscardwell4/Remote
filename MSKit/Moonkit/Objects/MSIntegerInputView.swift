//
//  MSIntegerInputView.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/10/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public class MSIntegerInputView: UIInputView {

  /**
  initWithFrame:target:

  :param: frame CGRect
  :param: target UIResponder
  */
  public init?(frame: CGRect, target: UIResponder) {
    super.init(frame: frame, inputViewStyle: .Keyboard)
    let index = [0: "1",      1: "2",  2: "3",
                 3: "4",      4: "5",  5: "6",
                 6: "7",      7: "8",  8: "9",
                 9: "Erase", 10: "0", 11: "Done"]

    for i in 0...11 {
      let b = MSButton.newForAutolayout()
      if i == 11 {
//        b.setBackgroundColor(UIColor(r: 0, g: 122, b: 255, a: 255), forState: .Normal)
        b.setBackgroundColor(UIColor.clearColor(), forState: .Normal)
        b.setBackgroundColor(UIColor(r: 135, g: 135, b: 135, a: 255), forState: .Highlighted)
        b.setTitle("Done", forState: .Normal)
      } else if i == 9 {
        b.setBackgroundColor(UIColor.clearColor(), forState: .Normal)
        b.setBackgroundColor(UIColor(r: 135, g: 135, b: 135, a: 255), forState: .Highlighted)
        let image = eraseButtonImage()
        b.setImage(image, forState: .Normal)
        b.setImage(image, forState: .Highlighted)
      } else {
        b.setBackgroundColor(UIColor(r: 135, g: 135, b: 135, a: 255), forState: .Normal)
        b.setBackgroundColor(UIColor.clearColor(), forState: .Highlighted)
        b.setTitle(index[i], forState: .Normal)
        b.titleLabel?.font = UIFont.systemFontOfSize(36.0)
      }

      var actionBlock: (Void) -> Void
      switch i {
        case  9: actionBlock = {_ = (target as? UIKeyInput)?.deleteBackward()}
        case 11: actionBlock = {_ = target.resignFirstResponder()}
        default: actionBlock = {_ = (target as? UIKeyInput)?.insertText(index[i]!)}
      }
      b.addActionBlock(actionBlock, forControlEvents: .TouchUpInside)
      b.constrainWithFormat("self.height = \((frame.size.height - 1.5) * 0.25) :: self.width = \((frame.size.width - 1.0) / 3.0)")
      addSubview(b)

      if i < 3                 { constrainWithFormat("b.top = self.top", views: ["b": b]) }
      else if i > 8            { constrainWithFormat("b.bottom = self.bottom", views: ["b": b]) }

      if i % 3 == 0            { constrainWithFormat("b.left = self.left", views: ["b": b]) }
      else if (i + 1) % 3 == 0 { constrainWithFormat("b.right = self.right", views: ["b": b]) }
      else                     { constrainWithFormat("b.centerX = self.centerX", views: ["b": b]) }

      if 3...5 ∋ i      { constrainWithFormat("b.bottom = self.centerY - 0.25", views: ["b": b]) }
      else if 6...8 ∋ i { constrainWithFormat("b.top = self.centerY + 0.25", views: ["b": b]) }
    }

  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required public init(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
  }

  /**
  eraseButtonImage

  :returns: UIImage
  */
  private func eraseButtonImage() -> UIImage {
    UIGraphicsBeginImageContextWithOptions(CGSize(width: 27.5, height: 20.5), false, 0.0)
    let bezier = UIBezierPath()
    bezier.moveToPoint(CGPoint(x: 11.01, y: 4.21))
    bezier.addCurveToPoint(CGPoint(x: 10.595, y: 5.375),
      controlPoint1: CGPoint(x: 10.2, y: 4.94),
      controlPoint2: CGPoint(x: 10.595, y: 5.375))
    bezier.addLineToPoint(CGPoint(x: 13.885, y: 8.875))
    bezier.addLineToPoint(CGPoint(x: 10.595, y: 12.375))
    bezier.addCurveToPoint(CGPoint(x: 11.01, y: 13.54),
      controlPoint1: CGPoint(x: 10.595, y: 12.375),
      controlPoint2: CGPoint(x: 10.2, y: 12.81))
    bezier.addCurveToPoint(CGPoint(x: 12.225, y: 13.56),
      controlPoint1: CGPoint(x: 11.75, y: 14.21),
      controlPoint2: CGPoint(x: 12.09, y: 13.685))
    bezier.addLineToPoint(CGPoint(x: 15.5, y: 10.07))
    bezier.addLineToPoint(CGPoint(x: 18.775, y: 13.56))
    bezier.addCurveToPoint(CGPoint(x: 19.99, y: 13.54),
      controlPoint1: CGPoint(x: 18.91, y: 13.685),
      controlPoint2: CGPoint(x: 19.25, y: 14.21))
    bezier.addCurveToPoint(CGPoint(x: 20.405, y: 12.375),
      controlPoint1: CGPoint(x: 20.8, y: 12.81),
      controlPoint2: CGPoint(x: 20.405, y: 12.375))
    bezier.addLineToPoint(CGPoint(x: 17.115, y: 8.875))
    bezier.addLineToPoint(CGPoint(x: 20.405, y: 5.375))
    bezier.addCurveToPoint(CGPoint(x: 19.99, y: 4.21),
      controlPoint1: CGPoint(x: 20.405, y: 5.375),
      controlPoint2: CGPoint(x: 20.8, y: 4.94))
    bezier.addCurveToPoint(CGPoint(x: 19.275, y: 3.875),
      controlPoint1: CGPoint(x: 19.695, y: 3.945),
      controlPoint2: CGPoint(x: 19.465, y: 3.865))
    bezier.addCurveToPoint(CGPoint(x: 18.775, y: 4.19),
      controlPoint1: CGPoint(x: 19.01, y: 3.9),
      controlPoint2: CGPoint(x: 18.855, y: 4.115))
    bezier.addLineToPoint(CGPoint(x: 15.5, y: 7.68))
    bezier.addLineToPoint(CGPoint(x: 12.18, y: 4.15))
    bezier.addCurveToPoint(CGPoint(x: 11.01, y: 4.21),
      controlPoint1: CGPoint(x: 12.025, y: 3.975),
      controlPoint2: CGPoint(x: 11.685, y: 3.6))
    bezier.closePath()
    bezier.moveToPoint(CGPoint(x: 25.5, y: 2.7))
    bezier.addLineToPoint(CGPoint(x: 25.5, y: 15.3))
    bezier.addCurveToPoint(CGPoint(x: 22.72, y: 18.0),
      controlPoint1: CGPoint(x: 25.5, y: 16.79),
      controlPoint2: CGPoint(x: 24.255, y: 18.0))
    bezier.addLineToPoint(CGPoint(x: 9.735, y: 18.0))
    bezier.addCurveToPoint(CGPoint(x: 7.66, y: 17.095),
      controlPoint1: CGPoint(x: 8.91, y: 18.0),
      controlPoint2: CGPoint(x: 8.17, y: 17.65))
    bezier.addLineToPoint(CGPoint(x: 2.085, y: 11.7))
    bezier.addCurveToPoint(CGPoint(x: 0.0, y: 9.0),
      controlPoint1: CGPoint(x: 0.92, y: 10.68),
      controlPoint2: CGPoint(x: 0.0, y: 9.665))
    bezier.addCurveToPoint(CGPoint(x: 2.085, y: 6.3),
      controlPoint1: CGPoint(x: 0.0, y: 8.335),
      controlPoint2: CGPoint(x: 0.92, y: 7.32))
    bezier.addLineToPoint(CGPoint(x: 7.65, y: 0.9))
    bezier.addCurveToPoint(CGPoint(x: 9.735, y: 0.0),
      controlPoint1: CGPoint(x: 8.16, y: 0.355),
      controlPoint2: CGPoint(x: 8.905, y: 0.0))
    bezier.addLineToPoint(CGPoint(x: 22.72, y: 0.0))
    bezier.addCurveToPoint(CGPoint(x: 25.5, y: 2.7),
      controlPoint1: CGPoint(x: 24.255, y: 0.0),
      controlPoint2: CGPoint(x: 25.5, y: 1.21))
    bezier.closePath()
    UIColor.whiteColor().setFill()
    bezier.fill()
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
  }

}
