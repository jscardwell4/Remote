//: Playground - noun: a place where people can play

import UIKit
import MoonKit
import DataModel
import UI
import XCPlayground

@objc class LayerProxy {
  let callback: (CGContext) -> Void
  init(callback: (CGContext) -> Void) { self.callback = callback }
  func drawLayer(layer: CALayer!, inContext ctx: CGContext!) { callback(ctx) }
}

class TestRemoteElementView: UIView {
  var shape: RemoteElement.Shape = .Undefined
  var useGloss = true
  var backgroundImage: UIImage?
  var drawBorder = false

  var backdropProxy: LayerProxy!
  var contentProxy: LayerProxy!
  var overlayProxy: LayerProxy!

  var backdropLayer: CALayer!
  var contentLayer: CALayer!
  var overlayLayer: CALayer!

  func drawBackdropInContext(ctx: CGContext) {
    UIGraphicsPushContext(ctx)
    let rect = CGContextGetClipBoundingBox(ctx)
    if let image = backgroundImage {
      image.drawInRect(rect)
    }
    let color = backgroundColor ?? UI.DrawingKit.buttonBaseColor
    var path: UIBezierPath?
    switch shape {
      case RemoteElement.Shape.RoundedRectangle:
        UI.DrawingKit.drawRoundishButtonBase(frame: rect, color: color, radius: 20)
        path = UI.DrawingKit.roundishBasePath(frame: rect, radius: 20)
      case RemoteElement.Shape.Rectangle:
        UI.DrawingKit.drawRectangularButtonBase(frame: rect, color: color)
        path = UI.DrawingKit.rectangularBasePath(frame: rect)
      case RemoteElement.Shape.Triangle:
        UI.DrawingKit.drawTriangleButtonBase(frame: rect, color: color)
        path = UI.DrawingKit.triangleBasePath(frame: rect)
      case RemoteElement.Shape.Diamond:
        UI.DrawingKit.drawDiamondButtonBase(frame: rect, color: color)
        path = UI.DrawingKit.diamondBasePath(frame: rect)
      default: break
    }
    UIGraphicsPopContext()
  }

  func drawContentInContext(ctx: CGContext) {

  }

  func drawOverlayInContext(ctx: CGContext) {
    if useGloss {
      UIGraphicsPushContext(ctx)
      let rect = CGContextGetClipBoundingBox(ctx)
      var path: UIBezierPath?
      switch shape {
        case RemoteElement.Shape.RoundedRectangle:
          path = UI.DrawingKit.roundishBasePath(frame: rect, radius: 20)
        case RemoteElement.Shape.Rectangle:
          path = UI.DrawingKit.rectangularBasePath(frame: rect)
        case RemoteElement.Shape.Triangle:
          path = UI.DrawingKit.triangleBasePath(frame: rect)
        case RemoteElement.Shape.Diamond:
          path = UI.DrawingKit.diamondBasePath(frame: rect)
        default: break
      }
      path?.addClip()
      UI.DrawingKit.drawGloss(frame: rect)
      UIGraphicsPopContext()
    }
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
    backdropProxy = LayerProxy(callback: drawBackdropInContext)
    backdropLayer = CALayer()
    backdropLayer.frame = bounds
    backdropLayer.delegate = backdropProxy
    layer.addSublayer(backdropLayer)
    contentProxy = LayerProxy(callback: drawContentInContext)
    contentLayer = CALayer()
    contentLayer.frame = bounds
    contentLayer.delegate = contentProxy
    layer.addSublayer(contentLayer)
    overlayProxy = LayerProxy(callback: drawOverlayInContext)
    overlayLayer = CALayer()
    overlayLayer.frame = bounds
    overlayLayer.delegate = overlayProxy
    layer.addSublayer(overlayLayer)
  }

}

class TestButtonView: TestRemoteElementView {
  var text = ""

  override func drawContentInContext(ctx: CGContext) {
    super.drawContentInContext(ctx)
    if !text.isEmpty {
      UIGraphicsPushContext(ctx)
      var p = bounds.center
      let attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 32)!]
      let b = (text as NSString).boundingRectWithSize(bounds.size, options: nil, attributes: attributes, context: nil)
      p.x = p.x - b.origin.x / 2 - b.width / 2
      p.y = p.y + b.origin.y / 2 - b.height / 2
      (text as NSString).drawAtPoint(p, withAttributes: attributes)
      UIGraphicsPopContext()
    }
  }


}

let testRemoteView = TestRemoteElementView(frame: CGRect(size: UIScreen.mainScreen().bounds.size),
                                           shape: .Undefined,
                                           useGloss: false,
                                           backgroundImage: UIImage(named: "ProDots"))

let testButtonView = TestButtonView(frame: CGRect(x: 50, y: 150, width: 165, height: 80),
                                           shape: RemoteElement.Shape.RoundedRectangle)
testButtonView.text = "Menu"
testRemoteView.backdropLayer.setNeedsDisplay()
testRemoteView.addSubview(testButtonView)
testButtonView.backdropLayer.setNeedsDisplay()
testButtonView.overlayLayer.setNeedsDisplay()
testButtonView.contentLayer.setNeedsDisplay()
testButtonView.setNeedsDisplay()
XCPCaptureValue("testRemoteView", testRemoteView)
