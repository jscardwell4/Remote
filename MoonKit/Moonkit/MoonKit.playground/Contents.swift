//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit

dispatch_time(DISPATCH_TIME_NOW, Int64(round(5.0 * Double(NSEC_PER_MSEC))))

func wtf(x: Int)(y: Int)(z: Float) -> String { return "whatup" }

func ftw(x: Int)(y: Int)(z: Int) -> String { return "bitches" }


let party = wtf(0)(y: 1)


let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
let popOverView = PopOverView(autolayout: true)
popOverView.addLabel(label: "Label 1", withAction: {println("\($1)")})
popOverView.addLabel(label: "Label 2", withAction: {println("\($1)")})
popOverView.addLabel(label: "Label 3", withAction: {println("\($1)")})
popOverView.backgroundColor = UIColor.blueColor()
popOverView.location = .Top
popOverView.setNeedsLayout()
popOverView.layoutIfNeeded()
popOverView.setNeedsDisplay()
view.addSubview(popOverView)
view.constrain(popOverView.centerX => view.centerX, popOverView.centerY => view.centerY)
view.setNeedsLayout()
view.layoutIfNeeded()
view.setNeedsDisplay()
view

popOverView.frame
(popOverView.subviews as! [UIView])[0].userInteractionEnabled
flattened(popOverView.subviews) as [UILabel]
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

