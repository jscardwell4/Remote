//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit
import XCPlayground

func ~=<T:Equatable>(lhs: T?, rhs: T?) -> Bool {
  if let l = lhs, r = rhs where l ~= r { return true }
  else if lhs == nil && rhs == nil { return true }
  else { return false }
}

let wtf1: Int? = 1

let wtf2: Int? = 1

let wtf3: Int? = nil

let wtf4: Int? = 2

let wtf5: Int = 1

switch wtf5 {
  case wtf1: println("huzzah")
  default: println("huh")
}
