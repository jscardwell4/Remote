//: Playground - noun: a place where people can play

import UIKit
import MoonKit
import UI

class TestView1: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 300, height: 100)); opaque = false }
  override func drawRect(rect: CGRect) {
    UI.DrawingKit.drawRoundishButtonBase(frame: rect, color: UI.DrawingKit.buttonBaseColor, radius: 20.0)
  }
}
let testView1 = TestView1()
testView1
class TestView2: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200)); opaque = false }
  override func drawRect(rect: CGRect) {
    UI.DrawingKit.drawRectangularButtonBase(frame: rect, color: UI.DrawingKit.buttonBaseColor)
  }
}
let testView2 = TestView2()
testView2
class TestView3: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200)); opaque = false }
  override func drawRect(rect: CGRect) {
    UI.DrawingKit.drawTriangleButtonBase(frame: rect, color: UI.DrawingKit.buttonBaseColor)
  }
}
let testView3 = TestView3()
testView3
class TestView4: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200)); opaque = false }
  override func drawRect(rect: CGRect) {
    UI.DrawingKit.drawDiamondButtonBase(frame: rect, color: UI.DrawingKit.buttonBaseColor)
  }
}
let testView4 = TestView4()
testView4
class TestView5: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200)); opaque = false }
  override func drawRect(rect: CGRect) {
    UI.DrawingKit.drawOvalButtonBase(frame: rect, color: UI.DrawingKit.buttonBaseColor)
  }
}
let testView5 = TestView5()
testView5
class TestView6: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200)); opaque = false }
  override func drawRect(rect: CGRect) {
    UI.DrawingKit.drawBatteryStatus(batteryBaseColor: UI.DrawingKit.buttonBaseColor, hasPower: true, chargeLevel: 0.75, containingFrame: rect)
  }
}
let testView6 = TestView6()
testView6

class TestView7: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200)); opaque = false; clipsToBounds = false }
  override func drawRect(rect: CGRect) {
    UI.DrawingKit.drawWifiStatus(iconColor: UI.DrawingKit.buttonBaseColor, connected: false, containingFrame: rect)
  }
}
let testView7 = TestView7()
testView7
class TestView8: UIView {
  convenience init() { self.init(frame: CGRect(x: 0, y: 0, width: 600, height: 400)); opaque = false }
  override func drawRect(rect: CGRect) {
    UI.DrawingKit.drawRoundishButtonWithText(color: UI.DrawingKit.buttonBaseColor, buttonText: "Menu", addGloss: true, textFrame: rect, radius: 20)
  }
}
let testView8 = TestView8()
testView8
