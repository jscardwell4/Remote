//
//  Font.swift
//  Remote
//
//  Created by Jason Cardwell on 11/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class Font: JSONValueConvertible {

  var name: String = UIFont.systemFontOfSize(UIFont.systemFontSize()).fontName
  var size: CGFloat = UIFont.systemFontSize()
  var font: UIFont? { return UIFont(name: name, size: size) }

  init?(name: String) { if (UIFont.familyNames() as [String]) ∋ name { self.name = name } else { return nil } }
  init(_ font: UIFont) { name = font.fontName; size = font.pointSize }
  init(size: CGFloat) { self.size = size }
  convenience init?(name: String, size: CGFloat) { self.init(name: name); self.size = size }

  var JSONValue: String { return "\(name)@\(size)" }
  required init?(JSONValue: String) {
    let components: [String?] = JSONValue.matchFirst("^([^@]*)@?([0-9]*\\.?[0-9]*)")
    if let nameComponent = components.first {
      if nameComponent != nil {
        if (UIFont.familyNames() as [String]) ∋ nameComponent! { self.name = nameComponent! } else { return nil }
        if let sizeComponent = components.last {
          if sizeComponent != nil {
            let scanner = NSScanner(string: sizeComponent!)
            var s: Float = 0
            if scanner.scanFloat(&s) { size = CGFloat(s) }
          }
        }
      } else { return nil }
    } else { return nil }
  }
}
