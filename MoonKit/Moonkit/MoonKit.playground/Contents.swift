//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit
import XCPlayground


let size = CGSize(width: 160, height: 160)

let targetSize = CGSize(width: 320, height: 567)

let ratio = size.ratioForFittingSize(targetSize)

// size.width * x = 320
let wtf1 = ["wtf1": 1, "wtf": 3]
let wtf2 = ["wtf2": 2, "wtf": 4]
var wtf3 = wtf1
extend(&wtf3, wtf2)