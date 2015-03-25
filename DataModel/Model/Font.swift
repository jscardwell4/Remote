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

public class Font: JSONValueConvertible {

  public var name: String = UIFont.systemFontOfSize(UIFont.systemFontSize()).fontName
  public var size: CGFloat = UIFont.systemFontSize()
  public var font: UIFont? { return UIFont(name: name, size: size) }

  public init?(name: String) { if (UIFont.familyNames() as! [String]) ∋ name { self.name = name } else { return nil } }
  public init(_ font: UIFont) { name = font.fontName; size = font.pointSize }
  public init(size: CGFloat) { self.size = size }
  public convenience init?(name: String, size: CGFloat) { self.init(name: name); self.size = size }

  public var JSONValue: String { return "\(name)@\(size)" }
  required public init?(JSONValue: String) {
    let components: [String?] = JSONValue.matchFirst("^([^@]*)@?([0-9]*\\.?[0-9]*)")
    if let nameComponent = components.first {
      if nameComponent != nil {
        if (UIFont.familyNames() as! [String]) ∋ nameComponent! { self.name = nameComponent! } else { return nil }
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

/*
public struct UIFontDescriptorSymbolicTraits : RawOptionSetType {
  init(_ rawValue: UInt32)
  init(rawValue: UInt32)

  /* Symbolic Font Traits (Typeface info - lower 16 bits of UIFontDescriptorSymbolicTraits) */
  /*
  UIFontDescriptorSymbolicTraits symbolically describes stylistic aspects of a font. The upper 16 bits is used to describe appearance of the font whereas the lower 16 bits for typeface. The font appearance information represented by the upper 16 bits can be used for stylistic font matching.
  */
  static var TraitItalic: UIFontDescriptorSymbolicTraits { get }
  static var TraitBold: UIFontDescriptorSymbolicTraits { get }
  static var TraitExpanded: UIFontDescriptorSymbolicTraits { get } // expanded and condensed traits are mutually exclusive
  static var TraitCondensed: UIFontDescriptorSymbolicTraits { get }
  static var TraitMonoSpace: UIFontDescriptorSymbolicTraits { get } // Use fixed-pitch glyphs if available. May have multiple glyph advances (most CJK glyphs may contain two spaces)
  static var TraitVertical: UIFontDescriptorSymbolicTraits { get } // Use vertical glyph variants and metrics
  static var TraitUIOptimized: UIFontDescriptorSymbolicTraits { get } // Synthesize appropriate attributes for UI rendering such as control titles if necessary
  static var TraitTightLeading: UIFontDescriptorSymbolicTraits { get } // Use tighter leading values
  static var TraitLooseLeading: UIFontDescriptorSymbolicTraits { get } // Use looser leading values

  /* Font appearance info (upper 16 bits of NSFontSymbolicTraits */
  /* UIFontDescriptorClassFamily classifies certain stylistic qualities of the font. These values correspond closely to the font class values in the OpenType 'OS/2' table. The class values are bundled in the upper four bits of the UIFontDescriptorSymbolicTraits and can be accessed via UIFontDescriptorClassMask. For specific meaning of each identifier, refer to the OpenType specification.
  */
  static var ClassMask: UIFontDescriptorSymbolicTraits { get }

  static var ClassUnknown: UIFontDescriptorSymbolicTraits { get }
  static var ClassOldStyleSerifs: UIFontDescriptorSymbolicTraits { get }
  static var ClassTransitionalSerifs: UIFontDescriptorSymbolicTraits { get }
  static var ClassModernSerifs: UIFontDescriptorSymbolicTraits { get }
  static var ClassClarendonSerifs: UIFontDescriptorSymbolicTraits { get }
  static var ClassSlabSerifs: UIFontDescriptorSymbolicTraits { get }
  static var ClassFreeformSerifs: UIFontDescriptorSymbolicTraits { get }
  static var ClassSansSerif: UIFontDescriptorSymbolicTraits { get }
  static var ClassOrnamentals: UIFontDescriptorSymbolicTraits { get }
  static var ClassScripts: UIFontDescriptorSymbolicTraits { get }
  static var ClassSymbolic: UIFontDescriptorSymbolicTraits { get }
}

*/