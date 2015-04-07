// Playground - noun: a place where people can play
import Foundation
import UIKit


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
