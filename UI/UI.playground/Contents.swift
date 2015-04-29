//: Playground - noun: a place where people can play

import UIKit
import MoonKit
import DataModel
import UI

var r = CGRect(size: CGSize(width: 300, height: 100))
var rr = r
r.inset(dx: 4, dy: 4)
rr.proportionallyInsetX(4)
rr.integerize()

class TestView: UIView {
  var draw: (CGRect) -> Void = { _ in } { didSet { setNeedsDisplay() } }
  convenience init(frame: CGRect, draw d: (CGRect) -> Void) { self.init(frame: frame); draw = d; opaque = false }
  override func drawRect(rect: CGRect) { draw(rect) }
}

let testView = TestView(
  frame: CGRect(size: CGSize(width: 300, height: 100)),
  draw: { UI.DrawingKit.drawBaseWithShape(.RoundedRectangle, attributes: UI.DrawingKit.Attributes(rect: $0)) }
)
testView
testView.draw = { UI.DrawingKit.drawBaseWithShape(.Rectangle, attributes: UI.DrawingKit.Attributes(rect: $0)) }
testView
//testView.frame = CGRect(size: CGSize(square: 200))
testView.draw = { UI.DrawingKit.drawBaseWithShape(.Triangle, attributes: UI.DrawingKit.Attributes(rect: $0)) }
testView
testView.draw = { UI.DrawingKit.drawBaseWithShape(.Diamond, attributes: UI.DrawingKit.Attributes(rect: $0)) }
testView
testView.draw = { UI.DrawingKit.drawBaseWithShape(.Oval, attributes: UI.DrawingKit.Attributes(rect: $0)) }
testView
testView.draw = {UI.DrawingKit.drawBatteryStatus(color: UIColor.darkGrayColor(), hasPower: true, chargeLevel: 1, frame: $0)}
testView
testView.draw = {UI.DrawingKit.drawBatteryStatus(color: UIColor.darkGrayColor(), hasPower: true, chargeLevel: 0.5, frame: $0)}
testView
testView.draw = {UI.DrawingKit.drawBatteryStatus(color: UIColor.darkGrayColor(), hasPower: false, chargeLevel: 0.25, frame: $0)}
testView
testView.draw = {UI.DrawingKit.drawWifiStatus(color: UIColor.darkGrayColor(), connected: true, frame: $0)}
testView
testView.draw = {UI.DrawingKit.drawWifiStatus(color: UIColor.darkGrayColor(), connected: false, frame: $0)}
testView
testView.frame = CGRect(size: CGSize(width: 300, height: 200))
testView.draw = {
  var attributes = UI.DrawingKit.Attributes(rect: $0)
  attributes.text = "Menu"
  attributes.accentColor = UI.DrawingKit.defaultAccentColor
  UI.DrawingKit.drawButtonWithShape(.RoundedRectangle, attributes: attributes, gloss: true, highlighted: false)
}
testView
testView.draw = {
  var attributes = UI.DrawingKit.Attributes(rect: $0)
  attributes.text = "Menu"
  attributes.accentColor = UI.DrawingKit.defaultAccentColor
  UI.DrawingKit.drawButtonWithShape(.RoundedRectangle, attributes: attributes, gloss: false, highlighted: false)
}
testView
testView.draw = {
  var attributes = UI.DrawingKit.Attributes(rect: $0)
  attributes.text = "Menu"
  attributes.accentColor = UI.DrawingKit.defaultAccentColor
  UI.DrawingKit.drawButtonWithShape(.RoundedRectangle, attributes: attributes, gloss: true, highlighted: true)
}
testView
testView.draw = {
  var attributes = UI.DrawingKit.Attributes(rect: $0)
  attributes.text = "Menu"
  attributes.accentColor = UI.DrawingKit.defaultAccentColor
  UI.DrawingKit.drawButtonWithShape(.RoundedRectangle, attributes: attributes, gloss: false, highlighted: true)
}
testView
testView.draw = {UI.DrawingKit.drawGlossWithShape(.RoundedRectangle, attributes: UI.DrawingKit.Attributes(rect: $0))}
testView

