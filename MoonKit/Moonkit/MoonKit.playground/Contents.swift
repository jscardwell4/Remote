//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit
import XCPlayground
import Glyphish

let unendingSequence = InfiniteSequenceOf(1)
let endingSequence = [1, 2, 3, 4, 5]
for (i, j) in zip(endingSequence, 1) {
  println("\(i), \(j)")
}

