// Playground - noun: a place where people can play
import Foundation
import UIKit
let excluded = ["device", "code.uuid", "some.other.key", "yetAnotherKey"]
let expandedKeys = excluded.map({split($0, isSeparator: {$0 == "."})})
expandedKeys
let depth = reduce(expandedKeys.map({$0.count}), 0, max)
depth
let zippedExpandedKeys = reduce(enumerate(expandedKeys), Array<[String]>(count: depth, repeatedValue: []), {
  (var result: [[String]], element: (Int, [String])) -> [[String]] in
  toString(result)
  toString(element)
  for (i, s) in enumerate(element.1) {
    toString((i , s))
    result[i].append(s)
  }
  return result
})
toString(zippedExpandedKeys)
func hexToRGBA(var hex: UInt) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
  let a = CGFloat(hex & 0xFF)
  hex >>= 8
  let b = CGFloat(hex & 0xFF)
  hex >>= 8
  let g = CGFloat(hex & 0xFF)
  hex >>= 8
  let r = CGFloat(hex & 0xFF)
  return (r/255.0, g/255.0, b/255.0, a/255.0)
}

let hex: [UInt] = [
  0x919191FF, // Invisibles
  0x383838FF, // Background
  0xB4D5FE12, // Line highlight
  0xE0A4FFFF, // Caret
  0xD7D7D7FF, // Foreground
  0xB4D5FE40, // Selection
  0xFF00FF04  // Foreground
]
for h in hex {
  let rgba = hexToRGBA(h)
  let color = UIColor(red: rgba.0, green: rgba.1, blue: rgba.2, alpha: rgba.3)
}

class BumFuck: NSObject, Printable {
  override var description: String { return "I'm a bum fuck" }
}

let fakeBumFuck: BumFuck? = nil
let realBumFuck: BumFuck? = BumFuck()
println("fakeBumFuck = \(fakeBumFuck ?? nil)")
println("realBumFuck = \(toString(realBumFuck!))")

postfix operator -?? {}
postfix func -??(lhs: AnyObject?) -> String {
  return toString(lhs != nil ? lhs! : "nil")
}
func toString<T>(x: T?) -> String {
  if let xx = x {
    return toString(xx)
  } else {
    return "nil"
  }
}
realBumFuck-??
println("realBumFuck = \(toString(realBumFuck))")
