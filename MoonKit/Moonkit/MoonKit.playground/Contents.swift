//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit
import XCPlayground

dispatch_time(DISPATCH_TIME_NOW, Int64(round(5.0 * Double(NSEC_PER_MSEC))))

func wtf(x: Int)(y: Int)(z: Float) -> String { return "whatup" }

func ftw(x: Int)(y: Int)(z: Int) -> String { return "bitches" }


let party = wtf(0)(y: 1)

func updateView(view: UIView) {
  view.setNeedsLayout()
  view.layoutIfNeeded()
  view.setNeedsDisplay()
  for subview in view.subviews {
    updateView(subview as! UIView)
  }
}

let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
window.makeKeyAndVisible()

let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
view.backgroundColor = UIColor.whiteColor()
let popOverView = PopOverView(autolayout: true)
popOverView.preservesSuperviewLayoutMargins = true
popOverView.addLabel(label: "Label 1", withAction: {println("\($1)")})
popOverView.addLabel(label: "Label 2", withAction: {println("\($1)")})
popOverView.addLabel(label: "Label 3", withAction: {println("\($1)")})
//popOverView.backgroundColor = UIColor.lightGrayColor()

//(popOverView.layer as! CAShapeLayer).masksToBounds = true
//popOverView.backgroundColor = UIColor.blueColor()
popOverView.location = .Top
view.addSubview(popOverView)
view.constrain(popOverView.centerX => view.centerX, popOverView.centerY => view.centerY)
updateView(view)
view.backgroundColor = UIColor.blueColor()
//let layer = popOverView.layer as! CAShapeLayer
//let path = layer.path
//let maskingLayer = CAShapeLayer()
//maskingLayer.frame = CGRect(origin: CGPoint.zeroPoint, size: layer.frame.size)
//maskingLayer.path = path
//maskingLayer.path
//maskingLayer.fillColor
//layer.mask = maskingLayer
view

let maskingLayer = popOverView.layer.mask as! CAShapeLayer
maskingLayer.frame
maskingLayer.path
//maskingLayer.fillColor = nil
popOverView.backgroundColor = UIColor.lightGrayColor()
view

window.addSubview(view)
//(((popOverView.subviews[0] as! UIVisualEffectView).contentView.subviews[0] as! UIVisualEffectView).contentView.subviews[0] as! LabelButton).tintColor = UIColor.orangeColor()
//(((popOverView.subviews[0] as! UIVisualEffectView).contentView.subviews[0] as! UIVisualEffectView).contentView.subviews[1] as! LabelButton).backgroundColor = UIColor.redColor()
(((popOverView.subviews[0] as! UIVisualEffectView).contentView.subviews[0] as! UIVisualEffectView).contentView.subviews[1] as! LabelButton).textColor = UIColor.whiteColor()
updateView(window)
window

let s = "ComponentDevice"
s.isDashcase
s.isCamelcase
s.isTitlecase
s.dashcaseString.subbed("-", " ")

let floatingPointString = "12345.6789"
if let decimal = find(floatingPointString, ".") {
  let integerPart = floatingPointString[..<decimal]
  integerPart
  let fractionalPart = floatingPointString[advance(decimal, 1)..<]
  let wtf = prefix(fractionalPart, 2)
}

let floatingPoint = 12345.6789
toString(floatingPoint)
String(floatingPoint, precision: -1)

class WTF {}
let wtf = WTF()
let firstIdentfier = ObjectIdentifier(wtf)
let secondIdentifier = ObjectIdentifier(wtf)

firstIdentfier == secondIdentifier
toString(firstIdentfier.uintValue)

var q = Queue<Int>()
q
q.enqueue(1)
q.enqueue(2)
q.enqueue(3)
q.dequeue()
q.dequeue()
q.dequeue()


let target = "<tag>"
let replacement = "12"
var message = "It is a muthafunkin <tag> yo!"
message.sub(target, replacement)

UIViewNoIntrinsicMetric


let float = Float(43)

let floatBitPattern = float._toBitPattern()
Float._fromBitPattern(floatBitPattern)
String(floatBitPattern, radix: 16, uppercase: true)
let upsizedFloatBitPattern = Double._BitsType(floatBitPattern)
String(upsizedFloatBitPattern, radix: 16, uppercase: true)


let double = Double(43)

let doubleBitPattern = double._toBitPattern()
Double._fromBitPattern(doubleBitPattern)
String(doubleBitPattern >> 33, radix: 16, uppercase: true)




let cgfloat = CGFloat(43)

let cgfloatBitPattern = cgfloat._toBitPattern()
CGFloat._fromBitPattern(cgfloatBitPattern)
CGFloat._fromBitPattern(CGFloat._BitsType(doubleBitPattern))
Double._BitsType.self
CGFloat._BitsType.self
Float._BitsType.self

