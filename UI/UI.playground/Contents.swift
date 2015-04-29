//: Playground - noun: a place where people can play

import UIKit
import MoonKit
import DataModel
import UI

class TestView1: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 300, height: 100)); opaque = false }
  override func drawRect(rect: CGRect) {
    var attrs = UI.DrawingKit.Attributes(rect: rect)
    attrs.color = UI.DrawingKit.defaultButtonColor
    UI.DrawingKit.drawButtonBaseWithShape(.RoundedRectangle, withAttributes: attrs)
  }
}
let testView1 = TestView1()
testView1
class TestView2: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200)); opaque = false }
  override func drawRect(rect: CGRect) {
    var attrs = UI.DrawingKit.Attributes(rect: rect)
    attrs.color = UI.DrawingKit.defaultButtonColor
    UI.DrawingKit.drawButtonBaseWithShape(.Rectangle, withAttributes: attrs)
  }
}
let testView2 = TestView2()
testView2
class TestView3: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200)); opaque = false }
  override func drawRect(rect: CGRect) {
    var attrs = UI.DrawingKit.Attributes(rect: rect)
    attrs.color = UI.DrawingKit.defaultButtonColor
    UI.DrawingKit.drawButtonBaseWithShape(.Triangle, withAttributes: attrs)
  }
}
let testView3 = TestView3()
testView3
class TestView4: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200)); opaque = false }
  override func drawRect(rect: CGRect) {
    var attrs = UI.DrawingKit.Attributes(rect: rect)
    attrs.color = UI.DrawingKit.defaultButtonColor
    UI.DrawingKit.drawButtonBaseWithShape(.Diamond, withAttributes: attrs)
  }
}
let testView4 = TestView4()
testView4
class TestView5: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200)); opaque = false }
  override func drawRect(rect: CGRect) {
    var attrs = UI.DrawingKit.Attributes(rect: rect)
    attrs.color = UI.DrawingKit.defaultButtonColor
    UI.DrawingKit.drawButtonBaseWithShape(.Oval, withAttributes: attrs)
  }
}
let testView5 = TestView5()
testView5
class TestView6: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200)); opaque = false }
  override func drawRect(rect: CGRect) {
    UI.DrawingKit.drawBatteryStatus(color: UIColor.darkGrayColor(), hasPower: true, chargeLevel: 1, frame: rect)
  }
}
let testView6 = TestView6()
testView6

class TestView7: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200)); opaque = false; clipsToBounds = false }
  override func drawRect(rect: CGRect) {
    UI.DrawingKit.drawWifiStatus(color: UIColor.darkGrayColor(), connected: true, frame: rect)
  }
}
let testView7 = TestView7()
testView7
class TestView8: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 300, height: 200)); opaque = false }
  override func drawRect(rect: CGRect) {
//    UI.DrawingKit.PCdrawButton(color: UI.DrawingKit.defaultButtonColor, contentColor: UI.DrawingKit.defaultContentColor, iconImage: UIImage(), radius: 10.0, text: "Menu", applyGloss: true, baseShape: "diamond", rect: rect, highlighted: true, shouldDrawIcon: false, shouldDrawText: true)
    UI.DrawingKit.drawButtonWithShape(.RoundedRectangle, inRect: rect, text: "Menu", applyGloss: true, highlighted: false)
  }
}
let testView8 = TestView8()
testView8
class TestView9: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200)); opaque = false }
  override func drawRect(rect: CGRect) {
    UI.DrawingKit.drawGlossWithShape(.Oval, withAttributes: UI.DrawingKit.Attributes(rect: rect))
  }
}
let testView9 = TestView9()
testView9
