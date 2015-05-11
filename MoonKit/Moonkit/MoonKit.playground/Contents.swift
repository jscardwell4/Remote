//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit

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