//: Playground - noun: a place where people can play

import UIKit
import MoonKit
import DataModel
import UI
import XCPlayground

class TestRemoteElementView: UIView {
  var shape: RemoteElement.Shape = .Undefined
  var useGloss = true
  var backgroundImage: UIImage?
  var drawBorder = false
  var text = ""

  override func drawRect(rect: CGRect) {
    UIGraphicsPushContext(UIGraphicsGetCurrentContext())
    backgroundImage?.drawInRect(rect)
    UIGraphicsPopContext()
  }

  convenience init(frame: CGRect,
                   shape: RemoteElement.Shape,
                   useGloss: Bool = true,
                   backgroundImage: UIImage? = nil,
                   drawBorder: Bool = false)
  {
    self.init(frame: frame)
    self.shape = shape
    self.useGloss = useGloss
    self.backgroundImage = backgroundImage
    self.drawBorder = drawBorder
    opaque = false
  }

}

class TestButtonView: TestRemoteElementView {

  override func drawRect(rect: CGRect) {
    UIGraphicsPushContext(UIGraphicsGetCurrentContext())
    let color = UIColor.blackColor()
    let contentColor = UIColor.whiteColor()
    let text = self.text
    UI.DrawingKit.drawButton(rect: rect, color: color, contentColor: contentColor, image: nil, radius: 10.0, text: text, fontAttributes: nil, applyGloss: true, shape: shape, highlighted: false)

    UIGraphicsPopContext()
  }

}

let testRemoteView = TestRemoteElementView(frame: CGRect(size: UIScreen.mainScreen().bounds.size),
                                           shape: .Undefined,
                                           useGloss: false,
                                           backgroundImage: UIImage(named: "ProDots"))

let testButtonView = TestButtonView(frame: CGRect(x: 50, y: 150, width: 100, height: 44),
                                           shape: RemoteElement.Shape.RoundedRectangle)
testButtonView.text = "Menu"
testRemoteView.addSubview(testButtonView)
testRemoteView.setNeedsDisplay()
testButtonView.setNeedsDisplay()
XCPCaptureValue("testRemoteView", testRemoteView)
