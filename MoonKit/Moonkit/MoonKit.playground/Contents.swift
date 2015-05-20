//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit

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
