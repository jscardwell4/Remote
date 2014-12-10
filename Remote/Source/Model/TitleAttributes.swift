//
//  TitleAttributes.swift
//  Remote
//
//  Created by Jason Cardwell on 11/22/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

// TODO: This should probably be an option set, create workaround?
extension NSUnderlineStyle: JSONValueConvertible, EnumerableType {
  public var JSONValue: String {
    switch self {
      case .StyleNone:         return "none"
      case .StyleSingle:       return "single"
      case .StyleThick:        return "thick"
      case .StyleDouble:       return "double"
      case .PatternDot:        return "dot"
      case .PatternDash:       return "dash"
      case .PatternDashDot:    return "dash-dot"
      case .PatternDashDotDot: return "dash-dot-dot"
      case .ByWord:            return "by-word"
    }
  }
  public init?(JSONValue: String) {
    switch JSONValue {
      case "single":        self = .StyleSingle
      case "thick":         self = .StyleThick
      case "double":        self = .StyleDouble
      case "dot":           self = .PatternDot
      case "dash":          self = .PatternDash
      case "dash-dot":      self = .PatternDashDot
      case "dash-dot-dot":  self = .PatternDashDotDot
      case "by-word":       self = .ByWord
      case "none", "solid": self = .StyleNone
      default:              return nil
    }
  }

  public static var all: [NSUnderlineStyle] {
    return [.StyleNone, .StyleSingle, .StyleThick, .StyleDouble, .PatternDot, .PatternDash,
            .PatternDashDot, .PatternDashDotDot, .ByWord]
  }

  public static func enumerate(block: (NSUnderlineStyle) -> Void) { apply(all, block) }

}

extension NSLineBreakMode: JSONValueConvertible, EnumerableType {
  public var JSONValue: String {
    switch self {
      case .ByWordWrapping:      return "word-wrap"
      case .ByCharWrapping:      return "character-wrap"
      case .ByClipping:          return "clip"
      case .ByTruncatingHead:    return "truncate-head"
      case .ByTruncatingTail:    return "truncate-tail"
      case .ByTruncatingMiddle:  return "truncate-middle"
    }
  }
  public init?(JSONValue: String) {
    switch JSONValue {
      case "word-wrap":       self = .ByWordWrapping
      case "character-wrap":  self = .ByCharWrapping
      case "clip":            self = .ByClipping
      case "truncate-head":   self = .ByTruncatingHead
      case "truncate-tail":   self = .ByTruncatingTail
      case "truncate-middle": self = .ByTruncatingMiddle
      default:                return nil
    }
  }

  public static var all: [NSLineBreakMode] {
    return [.ByWordWrapping, .ByCharWrapping, .ByClipping, .ByTruncatingHead, .ByTruncatingTail, .ByTruncatingMiddle]
  }

  public static func enumerate(block: (NSLineBreakMode) -> Void) { apply(all, block) }
}

extension NSTextAlignment: JSONValueConvertible, EnumerableType {
  public var JSONValue: String {
    switch self {
      case .Left:      return "left"
      case .Right:     return "right"
      case .Center:    return "center"
      case .Justified: return "justified"
      case .Natural:   return "natural"
    }
  }
  public init?(JSONValue: String) {
    switch JSONValue {
      case "left":      self = .Left
      case "right":     self = .Right
      case "center":    self = .Center
      case "justified": self = .Justified
      case "natural":   self = .Natural
      default:          return nil
    }
  }

  public static var all: [NSTextAlignment] { return [.Left, .Right, .Center, .Justified, .Natural] }
  public static func enumerate(block: (NSTextAlignment) -> Void) { apply(all, block) }
}

extension NSShadow {
  public var JSONValue: [String:AnyObject] {
    var dict: [String:AnyObject] = ["offset": NSStringFromCGSize(shadowOffset), "radius": shadowBlurRadius]
    if shadowColor != nil { dict["color"] = (shadowColor as UIColor).JSONValue }
    return dict
  }

  public convenience init(JSONValue: [String:AnyObject]) {
    self.init()
    if let offset = JSONValue["offset"] as? String { shadowOffset = CGSizeFromString(offset) }
    if let radius = JSONValue["radius"] as? NSNumber { shadowBlurRadius = CGFloat(radius.floatValue) }
    if let color = JSONValue["color"] as? String { shadowColor = UIColor(JSONValue: color) }
  }
}

struct TitleAttributes: JSONValueConvertible {

  enum IconTextOrderSpecification: JSONValueConvertible, EnumerableType {
    case IconText, TextIcon
    var JSONValue: String {
      switch self {
        case .IconText: return "icon-text"
        case .TextIcon: return "text-icon"
      }
    }
    init(JSONValue: String) {
      switch JSONValue {
        case "text-icon": self = .TextIcon
        default:          self = .IconText
      }
    }

    static var all: [IconTextOrderSpecification] { return [.IconText, .TextIcon] }
    static func enumerate(block: (IconTextOrderSpecification) -> Void) { apply(all, block) }

  }

  var iconTextOrder: IconTextOrderSpecification {
    get {
      if let s = self[.IconTextOrder] as? String { return IconTextOrderSpecification(JSONValue: s) }
      else { return .IconText }
    }
    set { self[.IconTextOrder] = newValue.JSONValue }
  }

  var text: String? {
    get { return self[.Text] as? String }
    set { self[.Text] = newValue }
  }

  var iconName: String? {
    get { return self[.IconName] as? String }
    set { self[.IconName] = newValue }
  }

  var icon: String? {
    get { if let name = iconName { return UIFont.fontAwesomeIconForName(name) } else { return nil } }
    set { iconName = UIFont.fontAwesomeNameForIcon(newValue) }
  }

  var font: UIFont? {
    get { if let f = self[.Font] as? String { return Font(JSONValue: f)?.font } else { return nil } }
    set { self[.Font] = newValue == nil ? nil : Font(newValue!).JSONValue }
  }

  var foregroundColor: UIColor? {
    get { if let s =  self[.ForegroundColor] as? String { return UIColor(JSONValue: s)} else { return nil } }
    set { self[.ForegroundColor] = newValue?.JSONValue }
  }

  var backgroundColor: UIColor? {
    get { if let s =  self[.BackgroundColor] as? String { return UIColor(JSONValue: s)} else { return nil } }
    set { self[.BackgroundColor] = newValue?.JSONValue }
  }

  var ligature: Int? {
    get { return self[.Ligature] as? Int }
    set { self[.Ligature] = newValue }
  }

  var shadow: NSShadow? {
    get { if let d = self[.Shadow] as? [String:AnyObject] { return NSShadow(JSONValue: d) } else { return nil } }
    set { self[.Shadow] = newValue?.JSONValue }
  }

  var expansion: Float? {
    get { return self[.Expansion] as? Float }
    set { self[.Expansion] = newValue }
  }

  var obliqueness: Float? {
    get { return self[.Obliqueness] as? Float }
    set { self[.Obliqueness] = newValue }
  }

  var strikethroughColor: UIColor? {
    get { if let s =  self[.StrikethroughColor] as? String { return UIColor(JSONValue: s)} else { return nil } }
    set { self[.StrikethroughColor] = newValue?.JSONValue }
  }

  var underlineColor: UIColor? {
    get { if let s =  self[.UnderlineColor] as? String { return UIColor(JSONValue: s)} else { return nil } }
    set { self[.UnderlineColor] = newValue?.JSONValue }
  }

  var baselineOffset: Float? {
    get { return self[.BaselineOffset] as? Float }
    set { self[.BaselineOffset] = newValue }
  }

  var textEffect: String? {
    get { return self[.TextEffect] as? String }
    set { self[.TextEffect] = newValue }
  }

  var strokeWidth: Float? {
    get { return self[.StrokeWidth] as? Float }
    set { self[.StrokeWidth] = newValue }
  }

  var strokeFill: Bool? {
    get { return self[.StrokeFill] as? Bool }
    set { self[.StrokeFill] = newValue }
  }

  var strokeColor: UIColor? {
    get { if let s = self[.StrokeColor] as? String { return UIColor(JSONValue: s) } else { return nil } }
    set { self[.StrokeColor] = newValue?.JSONValue }
  }

  var underlineStyle: NSUnderlineStyle? {
    get { if let u = self[.UnderlineStyle] as? String { return NSUnderlineStyle(JSONValue: u) } else { return nil } }
    set { self[.UnderlineStyle] = newValue?.JSONValue }
  }

  var strikethroughStyle: NSUnderlineStyle? {
    get { if let s = self[.StrikethroughStyle] as? String { return NSUnderlineStyle(JSONValue: s) } else { return nil } }
    set { self[.StrikethroughStyle] = newValue?.JSONValue }
  }

  var kern: Float? {
    get { return self[.Kern] as? Float }
    set { self[.Kern] = newValue }
  }

  var paragraphStyle: NSParagraphStyle? {
    get {
      let style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle

      PropertyKey.enumerateParagraphPropertyKeys {
        (propertyKey: PropertyKey) -> Void in

        if self[propertyKey] != nil {
          switch propertyKey {
            case .HyphenationFactor:      style.hyphenationFactor      = self.hyphenationFactor!
            case .ParagraphSpacingBefore: style.paragraphSpacingBefore = self.paragraphSpacingBefore!
            case .LineHeightMultiple:     style.lineHeightMultiple     = self.lineHeightMultiple!
            case .MaximumLineHeight:      style.maximumLineHeight      = self.maximumLineHeight!
            case .MinimumLineHeight:      style.minimumLineHeight      = self.minimumLineHeight!
            case .LineBreakMode:          style.lineBreakMode          = self.lineBreakMode!
            case .TailIndent:             style.tailIndent             = self.tailIndent!
            case .HeadIndent:             style.headIndent             = self.headIndent!
            case .FirstLineHeadIndent:    style.firstLineHeadIndent    = self.firstLineHeadIndent!
            case .Alignment:              style.alignment              = self.alignment!
            case .ParagraphSpacing:       style.paragraphSpacing       = self.paragraphSpacing!
            case .LineSpacing:            style.lineSpacing            = self.lineSpacing!
            default:                      break
          }
        }
      }

      return style
    }
    set {
      PropertyKey.enumerateParagraphPropertyKeys {
        (propertyKey: PropertyKey) -> Void in

        switch propertyKey {
          case .HyphenationFactor:      self.hyphenationFactor      = newValue?.hyphenationFactor
          case .ParagraphSpacingBefore: self.paragraphSpacingBefore = newValue?.paragraphSpacingBefore
          case .LineHeightMultiple:     self.lineHeightMultiple     = newValue?.lineHeightMultiple
          case .MaximumLineHeight:      self.maximumLineHeight      = newValue?.maximumLineHeight
          case .MinimumLineHeight:      self.minimumLineHeight      = newValue?.minimumLineHeight
          case .LineBreakMode:          self.lineBreakMode          = newValue?.lineBreakMode
          case .TailIndent:             self.tailIndent             = newValue?.tailIndent
          case .HeadIndent:             self.headIndent             = newValue?.headIndent
          case .FirstLineHeadIndent:    self.firstLineHeadIndent    = newValue?.firstLineHeadIndent
          case .Alignment:              self.alignment              = newValue?.alignment
          case .ParagraphSpacing:       self.paragraphSpacing       = newValue?.paragraphSpacing
          case .LineSpacing:            self.lineSpacing            = newValue?.lineSpacing
          default:                      break
        }
      }
    }
  }

  var alignment: NSTextAlignment? {
    get { if let a = self[.Alignment] as? String { return NSTextAlignment(JSONValue: a) } else { return nil } }
    set { self[.Alignment] = newValue?.JSONValue }
  }

  var firstLineHeadIndent: CGFloat? {
    get { return self[.FirstLineHeadIndent] as? CGFloat }
    set { self[.FirstLineHeadIndent] = newValue }
  }

  var headIndent: CGFloat? {
    get { return self[.HeadIndent] as? CGFloat }
    set { self[.HeadIndent] = newValue }
  }

  var tailIndent: CGFloat? {
    get { return self[.TailIndent] as? CGFloat }
    set { self[.TailIndent] = newValue }
  }

  var lineHeightMultiple: CGFloat? {
    get { return self[.LineHeightMultiple] as? CGFloat }
    set { self[.LineHeightMultiple] = newValue }
  }

  var maximumLineHeight: CGFloat? {
    get { return self[.MaximumLineHeight] as? CGFloat }
    set { self[.MaximumLineHeight] = newValue }
  }

  var minimumLineHeight: CGFloat? {
    get { return self[.MinimumLineHeight] as? CGFloat }
    set { self[.MinimumLineHeight] = newValue }
  }

  var lineSpacing: CGFloat? {
    get { return self[.LineSpacing] as? CGFloat }
    set { self[.LineSpacing] = newValue }
  }

  var paragraphSpacing: CGFloat? {
    get { return self[.ParagraphSpacing] as? CGFloat }
    set { self[.ParagraphSpacing] = newValue }
  }

  var paragraphSpacingBefore: CGFloat? {
    get { return self[.ParagraphSpacingBefore] as? CGFloat }
    set { self[.ParagraphSpacingBefore] = newValue }
  }

  var hyphenationFactor: Float? {
    get { return self[.HyphenationFactor] as? Float }
    set { self[.HyphenationFactor] = newValue }
  }

  var lineBreakMode: NSLineBreakMode? {
    get { if let l = self[.LineBreakMode] as? String { return NSLineBreakMode(JSONValue: l) } else { return nil } }
    set { self[.LineBreakMode] = newValue?.JSONValue }
  }


  /**
  stringText

  :returns: String
  */
  var stringText: String {
    var s: String
    let i = icon ?? ""
    let t = text ?? ""
    switch iconTextOrder {
      case .IconText: s = i + t
      case .TextIcon: s = t + i
    }
    return s
  }

  var iconString: NSAttributedString {
    var attrs = attributes
    let pointSize: CGFloat = (attrs[PropertyKey.Font.attributeKey!] as? UIFont)?.pointSize ?? 18.0
    let font = UIFont(awesomeFontWithSize: pointSize)
    attrs[PropertyKey.Font.attributeKey!] = font
    return NSAttributedString(string: icon ?? "", attributes: attrs)
  }

  var textString: NSAttributedString { return NSAttributedString(string: text ?? "", attributes: attributes) }

  var string: NSAttributedString { return stringWithAttributes(attributes) }

  /**
  stringWithAttributes:

  :param: attrs MSDictionary

  :returns: NSAttributedString
  */
  private func stringWithAttributes(attrs: MSDictionary) -> NSAttributedString {
    let text = attrs[PropertyKey.Text.rawValue] as? String ?? ""
    return NSAttributedString(string: text, attributes: attrs)
  }

  /**
  stringWithFillers:

  :param: fillers MSDictionary?

  :returns: NSAttributedString
  */
  func stringWithFillers(fillers: MSDictionary?) -> NSAttributedString {
    if fillers != nil {
      var attrs = fillers!
      attrs.setValuesForKeysWithDictionary(attributes)
      return stringWithAttributes(attrs)
    } else { return string }
  }

  var attributes: MSDictionary {
    var attrs = MSDictionary()
    if let style = paragraphStyle { attrs[NSParagraphStyleAttributeName] = style }
    PropertyKey.enumerateAttributePropertyKeys {
      (propertyKey: PropertyKey) -> Void in
      if self[propertyKey] != nil {
        if let attributeName = propertyKey.attributeKey {
          switch propertyKey {
            case .Font:
              attrs[attributeName] = self.font!
            case .ForegroundColor:
              attrs[attributeName] = self.foregroundColor!
            case .BackgroundColor:
              attrs[attributeName] = self.backgroundColor!
            case .Ligature:
              attrs[attributeName] = self.ligature!
            case .Shadow:
              attrs[attributeName] = self.shadow!
            case .Expansion:
              attrs[attributeName] = self.expansion!
            case .Obliqueness:
              attrs[attributeName] = self.obliqueness!
            case .StrikethroughColor:
              attrs[attributeName] = self.strikethroughColor!
            case .UnderlineColor:
              attrs[attributeName] = self.underlineColor!
            case .BaselineOffset:
              attrs[attributeName] = self.baselineOffset!
            case .StrokeWidth:
              if let fill = self.strokeFill { attrs[attributeName] = fill ? -self.strokeWidth! : self.strokeWidth! }
              else { attrs[attributeName] = self.strokeWidth! }
            case .StrokeColor:
              attrs[attributeName] = self.strokeColor!
            case .Kern:
              attrs[attributeName] = self.kern!
            case .TextEffect:
              attrs[attributeName] = NSTextEffectLetterpressStyle
            case .UnderlineStyle:
              attrs[attributeName] = self.underlineStyle!.rawValue
            case .StrikethroughStyle:
              attrs[attributeName] = self.strikethroughStyle!.rawValue
            default:                  break
          }
        }
      }
    }
    let text = stringText
    if !text.isEmpty { attrs[PropertyKey.Text.rawValue] = text }
    return attrs
  }

  enum MergeKind { case CopyIfNilExisting, CopyAllNonNil, CopyAll }

  /**
  mergeWithTitleAttributes:mergeKind:

  :param: titleAttributes TitleAttributes
  :param: mergeKind MergeKind = .CopyIfNilExisting
  */
  mutating func mergeWithTitleAttributes(titleAttributes: TitleAttributes?, mergeKind: MergeKind = .CopyIfNilExisting) {
    if titleAttributes != nil {
      PropertyKey.enumerate {
        let existingValue: AnyObject? = self[$0]
        let sourceValue: AnyObject? = titleAttributes![$0]
        switch mergeKind {
          case .CopyIfNilExisting: if sourceValue != nil && existingValue == nil { self[$0] = sourceValue! }
          case .CopyAllNonNil:     if sourceValue != nil { self[$0] = sourceValue! }
          case .CopyAll:           self[$0] = sourceValue
        }
      }
    }
  }

  subscript(propertyKey: PropertyKey) -> AnyObject? {
    get { return storage[propertyKey.rawValue] }
    set { storage[propertyKey.rawValue] = newValue }
  }

  enum PropertyKey: String, JSONValueConvertible, EnumerableType {
    case Text                   = "text"
    case IconName               = "icon-name"
    case Font                   = "font"
    case ForegroundColor        = "foreground-color"
    case BackgroundColor        = "background-color"
    case Ligature               = "ligature"
    case Shadow                 = "shadow"
    case Expansion              = "expansion"
    case Obliqueness            = "obliqueness"
    case StrikethroughColor     = "strikethrough-color"
    case UnderlineColor         = "underline-color"
    case BaselineOffset         = "baseline-offset"
    case TextEffect             = "text-effect"
    case StrokeWidth            = "stroke-width"
    case StrokeFill             = "stroke-fill"
    case StrokeColor            = "stroke-color"
    case UnderlineStyle         = "underline-style"
    case StrikethroughStyle     = "strikethrough-style"
    case Kern                   = "kern"
    case Alignment              = "alignment"
    case FirstLineHeadIndent    = "first-line-head-indent"
    case HeadIndent             = "head-indent"
    case TailIndent             = "tail-indent"
    case LineHeightMultiple     = "line-height-multiple"
    case MaximumLineHeight      = "maximum-line-height"
    case MinimumLineHeight      = "minimum-line-height"
    case LineSpacing            = "line-spacing"
    case ParagraphSpacing       = "paragraph-spacing"
    case ParagraphSpacingBefore = "paragraph-spacing-before"
    case HyphenationFactor      = "hyphenation-factor"
    case LineBreakMode          = "line-break-mode"
    case IconTextOrder          = "icon-text-order"

    var JSONValue: String { return rawValue }
    init?(JSONValue: String) { self.init(rawValue: JSONValue) }

    var attributeKey: String? {
      switch self {
        case .Font:               return NSFontAttributeName
        case .ForegroundColor:    return NSForegroundColorAttributeName
        case .BackgroundColor:    return NSBackgroundColorAttributeName
        case .Ligature:           return NSLigatureAttributeName
        case .Shadow:             return NSShadowAttributeName
        case .Expansion:          return NSExpansionAttributeName
        case .Obliqueness:        return NSObliquenessAttributeName
        case .StrikethroughColor: return NSStrikethroughColorAttributeName
        case .UnderlineColor:     return NSUnderlineColorAttributeName
        case .BaselineOffset:     return NSBaselineOffsetAttributeName
        case .TextEffect:         return NSTextEffectAttributeName
        case .StrokeWidth:        return NSStrokeWidthAttributeName
        case .StrokeColor:        return NSStrokeColorAttributeName
        case .UnderlineStyle:     return NSUnderlineStyleAttributeName
        case .StrikethroughStyle: return NSStrikethroughStyleAttributeName
        case .Kern:               return NSKernAttributeName
        default:                  return nil
      }
    }

    static var all: [PropertyKey] {
      return [.Font,
              .ForegroundColor,
              .BackgroundColor,
              .Ligature,
              .IconName,
              .Text,
              .Shadow,
              .Expansion,
              .Obliqueness,
              .StrikethroughColor,
              .UnderlineColor,
              .BaselineOffset,
              .TextEffect,
              .StrokeWidth,
              .StrokeColor,
              .UnderlineStyle,
              .StrikethroughStyle,
              .Kern,
              .HyphenationFactor,
              .ParagraphSpacingBefore,
              .LineHeightMultiple,
              .MaximumLineHeight,
              .MinimumLineHeight,
              .LineBreakMode,
              .TailIndent,
              .HeadIndent,
              .FirstLineHeadIndent,
              .Alignment,
              .ParagraphSpacing,
              .LineSpacing,
              .IconTextOrder]
    }

    static var paragraphKeys: [PropertyKey] {
      return [.HyphenationFactor,
              .ParagraphSpacingBefore,
              .LineHeightMultiple,
              .MaximumLineHeight,
              .MinimumLineHeight,
              .LineBreakMode,
              .TailIndent,
              .HeadIndent,
              .FirstLineHeadIndent,
              .Alignment,
              .ParagraphSpacing,
              .LineSpacing]
    }

    static var attributeKeys: [PropertyKey] {
      return [.Font,
              .ForegroundColor,
              .BackgroundColor,
              .Ligature,
              .Shadow,
              .Expansion,
              .Obliqueness,
              .StrikethroughColor,
              .UnderlineColor,
              .BaselineOffset,
              .TextEffect,
              .StrokeWidth,
              .StrokeColor,
              .UnderlineStyle,
              .StrikethroughStyle,
              .Kern]
    }

    /**
    enumerate:

    :param: block (PropertyKey) -> Void
    */
    static func enumerate(block: (PropertyKey) -> Void) { apply(all, block) }

    /**
    enumerateParagraphPropertyKeys:

    :param: block (PropertyKey) -> Void
    */
    static func enumerateParagraphPropertyKeys(block: (PropertyKey) -> Void) { apply(paragraphKeys, block) }

    /**
    enumerateAttributePropertyKeys:

    :param: block (PropertyKey) -> Void
    */
    static func enumerateAttributePropertyKeys(block: (PropertyKey) -> Void) { apply(attributeKeys, block) }

  }

  private var storage: [String:AnyObject]
  var dictionaryValue: NSDictionary { return storage as NSDictionary }

  /** init */
  init() { storage = [:] }

  /**
  initWithStorage:

  :param: storage [String AnyObject]
  */
  init(storage: [String:AnyObject]) { self.storage = storage }

  /**
  initWithJSONValue:

  :param: JSONValue [String AnyObject]
  */
  init(JSONValue: [String:AnyObject]) {
    storage = [:]

    PropertyKey.enumerate {
      (propertyKey: PropertyKey) -> Void in

      var storedValue: AnyObject?

      if let value: AnyObject = JSONValue[propertyKey.JSONValue] {

        switch propertyKey {

          case .Font:
            if let f = value as? String { storedValue = Font(JSONValue: f)?.JSONValue }

          case .ForegroundColor, .BackgroundColor, .StrikethroughColor, .UnderlineColor, .StrokeColor:
            if let c = value as? String { storedValue = UIColor(JSONValue: c)?.JSONValue }

          case .Ligature:
            if let i = value as? Int { if i == 0 || i == 1 { storedValue = i } }

          case .IconName:
            if let s = value as? String { if (UIFont.fontAwesomeIconNames().allObjects as [String]) ∋ s { storedValue = s } }

          case .Text:
            if let s = value as? String { storedValue = s }
            else if value.respondsToSelector("stringValue") { storedValue = value.valueForKey("stringValue") }

          case .Shadow:
            if let d = value as? [String:AnyObject] { storedValue = d }

          case .Expansion, .Obliqueness, .BaselineOffset, .Kern, .HyphenationFactor, .ParagraphSpacingBefore,
               .LineHeightMultiple, .MaximumLineHeight, .MinimumLineHeight, .ParagraphSpacing, .LineSpacing, .TailIndent,
               .HeadIndent, .FirstLineHeadIndent:
            if let n = value as? NSNumber { storedValue = n }

          case .StrokeWidth:
            if let n = value as? NSNumber { self[.StrokeFill] = n.floatValue.isSignMinus; storedValue = abs(n.floatValue) }

          case .TextEffect:
            if let e = value as? String { if e == "letterpress" { storedValue = e } }

          case .UnderlineStyle, .StrikethroughStyle:
            if let n = value as? NSNumber { storedValue = NSUnderlineStyle(rawValue: n.integerValue)?.JSONValue }
            else if let s = value as? String { storedValue = NSUnderlineStyle(JSONValue: s)?.JSONValue }

          case .LineBreakMode:
            if let n = value as? NSNumber { storedValue = NSLineBreakMode(rawValue: n.integerValue)?.JSONValue }
            else if let s = value as? String { storedValue = NSLineBreakMode(JSONValue: s)?.JSONValue }

          case .Alignment:
            if let n = value as? NSNumber { storedValue = NSTextAlignment(rawValue: n.integerValue)?.JSONValue }
            else if let s = value as? String { storedValue = NSTextAlignment(JSONValue: s)?.JSONValue }

          case .IconTextOrder:
            if let s = value as? String { storedValue = IconTextOrderSpecification(JSONValue: s).JSONValue }

          default: break
        }

        if storedValue != nil { self[propertyKey] = storedValue }

      }

    }

  }

  var JSONValue: [String:AnyObject] {
    var dictionary: [String:AnyObject] = [:]
    PropertyKey.enumerate {
      if let value: AnyObject = self[$0] {
        switch $0 {
          case .StrokeWidth: dictionary[$0.JSONValue] = self.strokeFill != nil && self.strokeFill! ? -value.floatValue : value
          default: dictionary[$0.JSONValue] = value
        }
      }
    }
    return dictionary
  }

}
