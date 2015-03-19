// Playground - noun: a place where people can play

import Foundation

func afunc(type: NSArray.Type) {
  println(NSStringFromClass(type))
}

afunc(NSArray.self)
afunc(NSMutableArray.self)

func bfunc(typeName: String) {
  if let type = NSClassFromString(typeName) as? NSArray.Type {
    afunc(type)
  }
}

bfunc("NSArray")
bfunc("NSMutableArray")
