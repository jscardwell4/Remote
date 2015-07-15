//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit

let containingView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
containingView.backgroundColor = UIColor.yellowColor()
let subview1 = UILabel(frame: CGRect(x: 139.5, y: 7, width: 39, height: 30))
subview1.text = "Sony"
subview1.backgroundColor = UIColor.redColor()
containingView.addSubview(subview1)
let subview2 = UILabel(frame: CGRect(x:60, y: 7, width: 74, height: 30))
subview2.backgroundColor = UIColor.greenColor()
subview2.text = "Samsung"
containingView.addSubview(subview2)
let subview3 = UILabel(frame: CGRect(x:20, y: 7, width: 39, height: 30))
subview3.backgroundColor = UIColor.blueColor()
subview3.text = "Dish"
containingView.addSubview(subview3)
var transform = CATransform3DIdentity
transform.m34 = -1 / 1000
containingView.layer.sublayerTransform = transform

let midX: CGFloat = 160
let distance = subview2.frame.midX - midX
let r: CGFloat = 160

var subview2Transform = CATransform3DIdentity
subview2Transform = CATransform3DTranslate(subview2Transform, -distance, 0, -r)
subview2Transform = CATransform3DRotate(subview2Transform, distance / r, 0, 1, 0)
subview2Transform = CATransform3DTranslate(subview2Transform, 0, 0, r)

var subview3Transform = CATransform3DIdentity
subview3Transform = CATransform3DTranslate(subview3Transform, -distance, 0, -r)
subview3Transform = CATransform3DRotate(subview3Transform, CGFloat(M_PI_2), 1, 1, 1)
subview3Transform = CATransform3DTranslate(subview3Transform, 0, 0, r)
subview3.layer.transform = subview3Transform
subview3.layer.setNeedsDisplay()
subview3.layer.displayIfNeeded()
subview3


containingView