//
//  FontAttributes.swift
//  Remote
//
//  Created by Jason Cardwell on 11/29/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

public struct FontAttributes {

  public enum Trait: UInt32 {
    case Italic       = UIFontDescriptorSymbolicTraits.TraitItalic
    case Bold         = UIFontDescriptorSymbolicTraits.TraitBold
    case Expanded     = UIFontDescriptorSymbolicTraits.TraitExpanded
    case Condensed    = UIFontDescriptorSymbolicTraits.TraitCondensed
    case MonoSpace    = UIFontDescriptorSymbolicTraits.TraitMonoSpace
    case Vertical     = UIFontDescriptorSymbolicTraits.TraitVertical
    case UIOptimized  = UIFontDescriptorSymbolicTraits.TraitUIOptimized
    case TightLeading = UIFontDescriptorSymbolicTraits.TraitTightLeading
    case LooseLeading = UIFontDescriptorSymbolicTraits.TraitLooseLeading
  }

  public enum Class: UInt32 {
    case Unknown            = UIFontDescriptorSymbolicTraits.ClassUnknown
    case OldStyleSerifs     = UIFontDescriptorSymbolicTraits.ClassOldStyleSerifs
    case TransitionalSerifs = UIFontDescriptorSymbolicTraits.ClassTransitionalSerifs
    case ModernSerifs       = UIFontDescriptorSymbolicTraits.ClassModernSerifs
    case ClarendonSerifs    = UIFontDescriptorSymbolicTraits.ClassClarendonSerifs
    case SlabSerifs         = UIFontDescriptorSymbolicTraits.ClassSlabSerifs
    case FreeformSerifs     = UIFontDescriptorSymbolicTraits.ClassFreeformSerifs
    case SansSerif          = UIFontDescriptorSymbolicTraits.ClassSansSerif
    case Ornamentals        = UIFontDescriptorSymbolicTraits.ClassOrnamentals
    case Scripts            = UIFontDescriptorSymbolicTraits.ClassScripts
    case Symbolic           = UIFontDescriptorSymbolicTraits.ClassSymbolic
  }

  private var symbolicTraits: UIFontDescriptorSymbolicTraits = UIFontDescriptorSymbolicTraits(0)

  public var family: String?
  public var name: String?
  public var face: String?
  public var size: CGFloat?
  public var italic: Bool {
    get { return isOptionSet(UIFontDescriptorSymbolicTraits.TraitItalic, symbolicTraits) }
    set { if newValue { setOption(UIFontDescriptorSymbolicTraits.TraitItalic, symbolicTraits) }
          else { unsetOption(UIFontDescriptorSymbolicTraits.TraitItalic, symbolicTraits) } }
  }
  public var bold: Bool {
    get { return isOptionSet(UIFontDescriptorSymbolicTraits.TraitBold, symbolicTraits) }
    set { if newValue { setOption(UIFontDescriptorSymbolicTraits.TraitBold, symbolicTraits) }
          else { unsetOption(UIFontDescriptorSymbolicTraits.TraitBold, symbolicTraits) } }
  }
  public var expanded: Bool {
    get { return isOptionSet(UIFontDescriptorSymbolicTraits.TraitExpanded, symbolicTraits) }
    set { if newValue { setOption(UIFontDescriptorSymbolicTraits.TraitExpanded, symbolicTraits) }
          else { unsetOption(UIFontDescriptorSymbolicTraits.TraitExpanded, symbolicTraits) } }
  }
  public var condensed: Bool {
    get { return isOptionSet(UIFontDescriptorSymbolicTraits.TraitCondensed, symbolicTraits) }
    set { if newValue { setOption(UIFontDescriptorSymbolicTraits.TraitCondensed, symbolicTraits) }
          else { unsetOption(UIFontDescriptorSymbolicTraits.TraitCondensed, symbolicTraits) } }
  }
  public var monoSpace: Bool {
    get { return isOptionSet(UIFontDescriptorSymbolicTraits.TraitMonoSpace, symbolicTraits) }
    set { if newValue { setOption(UIFontDescriptorSymbolicTraits.TraitMonoSpace, symbolicTraits) }
          else { unsetOption(UIFontDescriptorSymbolicTraits.TraitMonoSpace, symbolicTraits) } }
  }
  public var vertical: Bool {
    get { return isOptionSet(UIFontDescriptorSymbolicTraits.TraitVertical, symbolicTraits) }
    set { if newValue { setOption(UIFontDescriptorSymbolicTraits.TraitVertical, symbolicTraits) }
          else { unsetOption(UIFontDescriptorSymbolicTraits.TraitVertical, symbolicTraits) } }
  }
  public var uIOptimized: Bool {
    get { return isOptionSet(UIFontDescriptorSymbolicTraits.TraitUIOptimized, symbolicTraits) }
    set { if newValue { setOption(UIFontDescriptorSymbolicTraits.TraitUIOptimized, symbolicTraits) }
          else { unsetOption(UIFontDescriptorSymbolicTraits.TraitUIOptimized, symbolicTraits) } }
  }
  public var tightLeading: Bool {
    get { return isOptionSet(UIFontDescriptorSymbolicTraits.TraitTightLeading, symbolicTraits) }
    set { if newValue { setOption(UIFontDescriptorSymbolicTraits.TraitTightLeading, symbolicTraits) }
          else { unsetOption(UIFontDescriptorSymbolicTraits.TraitTightLeading, symbolicTraits) } }
  }
  public var looseLeading: Bool {
    get { return isOptionSet(UIFontDescriptorSymbolicTraits.TraitLooseLeading, symbolicTraits) }
    set { if newValue { setOption(UIFontDescriptorSymbolicTraits.TraitLooseLeading, symbolicTraits) }
          else { unsetOption(UIFontDescriptorSymbolicTraits.TraitLooseLeading, symbolicTraits) } }
  }
}
