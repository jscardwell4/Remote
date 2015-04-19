//: Playground - noun: a place where people can play

import Foundation
import UIKit
import MoonKit


func nearestAncestor<V1: UIView, V2: UIView>(view1: V1, view2: V2) -> UIView? {
  var ancestor: UIView? = nil
  var view1Ancestors = Set<UIView>()
  var v: UIView? = view1
  while v != nil { view1Ancestors.insert(v!); v = v!.superview }
  v = view2
  while v != nil { if view1Ancestors.contains(v!) { ancestor = v; break } else { v = v!.superview } }
  return ancestor
}

typealias ViewAttribute = (UIView, PseudoConstraint.Attribute)
extension UIView {
  var right: (UIView, PseudoConstraint.Attribute) { return (self, .Right) }
  var left: (UIView, PseudoConstraint.Attribute) { return (self, .Left) }
  var top: (UIView, PseudoConstraint.Attribute) { return (self, .Top) }
  var bottom: (UIView, PseudoConstraint.Attribute) { return (self, .Bottom) }
  var centerX: (UIView, PseudoConstraint.Attribute) { return (self, .CenterX) }
  var centerY: (UIView, PseudoConstraint.Attribute) { return (self, .CenterY) }
  var width: (UIView, PseudoConstraint.Attribute) { return (self, .Width) }
  var height: (UIView, PseudoConstraint.Attribute) { return (self, .Height) }
  var baseline: (UIView, PseudoConstraint.Attribute) { return (self, .Baseline) }
  var leading: (UIView, PseudoConstraint.Attribute) { return (self, .Leading) }
  var trailing: (UIView, PseudoConstraint.Attribute) { return (self, .Trailing) }
}

infix operator == {associativity left}
infix operator * {associativity left}
infix operator + {associativity left}
infix operator - {associativity left}

func ==(lhs: ViewAttribute, rhs: ViewAttribute) -> PseudoConstraint {
  var pseudo = PseudoConstraint()
  pseudo.firstObject = lhs.0
  pseudo.firstAttribute = lhs.1
  pseudo.secondObject = rhs.0
  pseudo.secondAttribute = rhs.1
  return pseudo
}

func *(var lhs: PseudoConstraint, rhs: Float) -> PseudoConstraint {
  lhs.multiplier = rhs
  return lhs
}

func +(var lhs: PseudoConstraint, rhs: Float) -> PseudoConstraint {
  lhs.constant = rhs
  return lhs
}

func -(var lhs: PseudoConstraint, rhs: Float) -> PseudoConstraint {
  lhs.constant = -rhs
  return lhs
}

let indicator = UIImageView.newForAutolayout()
indicator.nametag = "indicator"
//indicator.constrain("self.width ≤ self.height :: self.height = 22")

let deleteButton = UIButton()
deleteButton.setTranslatesAutoresizingMaskIntoConstraints(false)
deleteButton.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.75)
deleteButton.setTitle("Delete", forState: .Normal)
deleteButton.constrain("self.width = 100")

var indicatorImage = UIImage(named: "1040-checkmark-toolbar")
indicator.image = indicatorImage

let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 34))
label.setTranslatesAutoresizingMaskIntoConstraints(false)
label.text = "Label Muthafucka!"
label.font = UIFont.systemFontOfSize(20)

let contentView = UIView()
contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
contentView.backgroundColor = UIColor.lightGrayColor().colorWithAlpha(0.5)
contentView.addSubview(indicator)
contentView.addSubview(label)
contentView.addSubview(deleteButton)

let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 38))
view.backgroundColor = UIColor.whiteColor()
view.addSubview(contentView)
view.setNeedsLayout()
view.layoutIfNeeded()
view

let ancestor = nearestAncestor(label, view)
toDebugString(ancestor)
toDebugString(view)
let identifier = createIdentifier(view, "Internal")

// Refresh our constraints
let format = "\n".join(
  "H:|[content]|", "V:|[content]|",
  "delete.right = self.right",
  "delete.top = self.top",
  "delete.bottom = self.bottom",
  "H:|-[indicator]-[label]",
  "label.centerY = content.centerY",
  "indicator.centerY = content.centerY")
let views = ["delete": deleteButton, "content": contentView, "indicator": indicator, "label": label]
view.constrain(format, views: views, identifier: identifier)
view.setNeedsLayout()
view.layoutIfNeeded()


view






view.removeAllConstraints()
view.setNeedsLayout()
view.layoutIfNeeded()




view.constrain(
  contentView.left == view.left,
  contentView.right == view.right,
  contentView.top == view.top,
  contentView.bottom == view.bottom,
  deleteButton.right == view.right,
  deleteButton.top == view.top,
  deleteButton.bottom == view.bottom,
  indicator.left == view.left + 8,
  indicator.centerY == view.centerY,
  label.centerY == view.centerY,
  label.left == indicator.right + 8
)

view.setNeedsLayout()
view.layoutIfNeeded()

view



