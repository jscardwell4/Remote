//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit

let wtf = UIView()
let identifier = _stdlib_getDemangledTypeName(wtf)
identifier

extension Any {
  var typeName: String { return _stdlib_getDemangledTypeName(self) }
}

let wtfName = wtf.typeName
wtfName

