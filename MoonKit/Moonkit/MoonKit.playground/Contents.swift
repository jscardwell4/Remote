//: Playground - noun: a place where people can play

import UIKit
import MoonKit

func takesAnInt(i: Int) {
  println("takesAnInt(i = \(i))")
}

func takesAndReturnsAnInt(i: Int) -> Int? {
  println("takesAndReturnsAnInt(i = \(i))")
  return i
}

infix operator <?> {}
func <?><T, U>(lhs: T?, rhs: T -> U?) -> U? {
  return flatMap(lhs, rhs)
}

infix operator ?> {}
func ?><T>(lhs: T?, rhs: T -> Void) {
  if let x = lhs { rhs(x) }
}

var anI: Int? = 4

flatMap(anI, takesAndReturnsAnInt)
anI <?> takesAndReturnsAnInt
anI ?> takesAnInt
anI = nil

flatMap(anI, takesAndReturnsAnInt)
anI <?> takesAndReturnsAnInt
anI ?> takesAnInt

typealias T = Int
typealias U = Int
anI = 6
let curriedFlatMap: T? -> (T -> U?) -> U? = curry(flatMap)
curriedFlatMap(anI)(takesAndReturnsAnInt)

