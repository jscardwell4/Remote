//: Playground - noun: a place where people can play

import UIKit
import MoonKit
import DataModel
import UI

let dpadRaw = RemoteElement.Role.DPad.rawValue
let topToolbarRaw = RemoteElement.Role.TopToolbar.rawValue
13 & 41
RemoteElement.Role.DPad & RemoteElement.Role.TopToolbar

let attrs: Painter.Attributes = [.Color: UIColor.redColor(), .Corners: UIRectCorner.AllCorners, .Radii: CGSize(width: 40, height: 20)]
attrs.description

let pa1 = ButtonGroup.PanelAssignment(rawValue: 0b10011)
pa1.stringValue

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
  draw: { Painter.drawBaseWithShape(.RoundedRectangle, attributes: Painter.Attributes(rect: $0)) }
)
testView
testView.draw = { Painter.drawBaseWithShape(.Rectangle, attributes: Painter.Attributes(rect: $0)) }
testView
//testView.frame = CGRect(size: CGSize(square: 200))
testView.draw = { Painter.drawBaseWithShape(.Triangle, attributes: Painter.Attributes(rect: $0)) }
testView
testView.draw = { Painter.drawBaseWithShape(.Diamond, attributes: Painter.Attributes(rect: $0)) }
testView
testView.draw = { Painter.drawBaseWithShape(.Oval, attributes: Painter.Attributes(rect: $0)) }
testView
testView.draw = {Painter.drawBatteryStatus(color: UIColor.darkGrayColor(), hasPower: true, chargeLevel: 1, frame: $0)}
testView
testView.draw = {Painter.drawBatteryStatus(color: UIColor.darkGrayColor(), hasPower: true, chargeLevel: 0.5, frame: $0)}
testView
testView.draw = {Painter.drawBatteryStatus(color: UIColor.darkGrayColor(), hasPower: false, chargeLevel: 0.25, frame: $0)}
testView
testView.draw = {Painter.drawWifiStatus(color: UIColor.darkGrayColor(), connected: true, frame: $0)}
testView
testView.draw = {Painter.drawWifiStatus(color: UIColor.darkGrayColor(), connected: false, frame: $0)}
testView
testView.frame = CGRect(size: CGSize(width: 300, height: 200))
testView.draw = {
  var attributes = Painter.Attributes(rect: $0)
  attributes.text = "Menu"
  attributes.accentColor = Painter.blueAccentColor
  Painter.drawButtonWithShape(.RoundedRectangle, attributes: attributes, gloss: true, highlighted: false)
}
testView
testView.draw = {
  var attributes = Painter.Attributes(rect: $0)
  attributes.text = "Menu"
  attributes.accentColor = Painter.blueAccentColor
  Painter.drawButtonWithShape(.RoundedRectangle, attributes: attributes, gloss: false, highlighted: false)
}
testView
testView.draw = {
  var attributes = Painter.Attributes(rect: $0)
  attributes.text = "Menu"
  attributes.accentColor = Painter.blueAccentColor
  Painter.drawButtonWithShape(.RoundedRectangle, attributes: attributes, gloss: true, highlighted: true)
}
testView
testView.draw = {
  var attributes = Painter.Attributes(rect: $0)
  attributes.text = "Menu"
  attributes.accentColor = Painter.blueAccentColor
  Painter.drawButtonWithShape(.RoundedRectangle, attributes: attributes, gloss: false, highlighted: true)
}
testView
testView.draw = {Painter.drawGlossWithShape(.RoundedRectangle, attributes: Painter.Attributes(rect: $0))}
testView

