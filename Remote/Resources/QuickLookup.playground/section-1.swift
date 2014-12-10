// Playground - noun: a place where people can play

import Foundation
import UIKit
import MoonKit

let wtf = (1, 2, 3, 4)

func sequence<T>(v: (T,T)) -> [T] { return [v.0, v.1] }
func sequence<T>(v: (T,T,T)) -> [T] { return [v.0, v.1, v.2] }
func sequence<T>(v: (T,T,T,T)) -> [T] { return [v.0, v.1, v.2, v.3] }



let wtfArray = sequence(wtf)

wtfArray
wtfArray.count

func iterate<C,R>(t:C, block:(String,Any)->R) {
  let mirror = reflect(t)
  for i in 0..<mirror.count {
    block(mirror[i].0, mirror[i].1.value)
  }
}

iterate(wtf) { println("\($0) => \($1)") }

let mirror = reflect(wtf)

mirror.count

mirror[0].1.value is Int


