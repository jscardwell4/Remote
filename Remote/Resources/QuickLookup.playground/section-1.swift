// Playground - noun: a place where people can play

import Foundation
import UIKit
import MoonKit

var textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
textField.text = "what the fuck"
textField.backgroundColor = UIColor.lightGrayColor()
textField

class TextField: UITextField {
  var gutter: CGFloat = 4.0

  /**
  drawRect:

  :param: rect CGRect
  */
  override func drawTextInRect(rect: CGRect) {
    var newRect = rect
    newRect.origin.x = rect.origin.x + gutter
    newRect.origin.y = rect.origin.y + gutter
    newRect.size.width = rect.size.width - CGFloat(2) * gutter
    newRect.size.height = rect.size.height - CGFloat(2) * gutter
    attributedText?.drawInRect(newRect)
  }

  /**
  alignmentRectInsets

  :returns: UIEdgeInsets
  */
  override func alignmentRectInsets() -> UIEdgeInsets {
    return UIEdgeInsets(top: gutter, left: gutter, bottom: gutter, right: gutter);
  }

  /**
  intrinsicContentSize

  :returns: CGSize
  */
  override func intrinsicContentSize() -> CGSize {
    var size = super.intrinsicContentSize()
    size.width += CGFloat(2) * gutter
    size.height += CGFloat(2) * gutter
    return size;
  }

}

var textField2 = TextField(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
textField2.text = "what the fuck"
textField2.backgroundColor = UIColor.lightGrayColor()
textField2.subviews
textField2
