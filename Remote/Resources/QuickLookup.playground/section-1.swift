// Playground - noun: a place where people can play

import Foundation
import UIKit
import MoonKit
import XCPlayground

let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
view.backgroundColor = UIColor.lightGrayColor()
view

let view2 = UIView(frame: CGRect(x: 75, y: 75, width: 150, height: 150))
view2.backgroundColor = UIColor.whiteColor()
view.addSubview(view2)
//view2.layer.borderWidth = 3.0
view2.layer.cornerRadius = 5.0
view2.layer.shadowOpacity = 0.5
view
XCPShowView("testView", view)

let labelView = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
labelView.font = UIFont.boldSystemFontOfSize(72.0)
labelView.text = "WTF?"

let radii = (M_1_PI * 245.0) / 180.0

let cosTheta = CGFloat(cos(radii))
let sinTheta = CGFloat(sin(radii))
let matrix = CATransform3D(
  m11: cosTheta, m12: -sinTheta, m13: 0, m14: 0,
  m21: sinTheta, m22: cosTheta,  m23: 0, m24: 0,
  m31: 0,        m32: 0,         m33: 1, m34: 0,
  m41: 0,        m42: 0,         m43: 0, m44: 1)
labelView.layer.transform = matrix
XCPShowView("labelView2", labelView)
