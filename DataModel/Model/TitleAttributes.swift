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
extension NSUnderlineStyle: JSONValueConvertible {
  public var jsonValue: JSONValue {
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
}

extension NSUnderlineStyle: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let string = String(jsonValue) {
      switch string {
        case "single":        self = .StyleSingle
        case "thick":         self = .StyleThick
        case "double":        self = .StyleDouble
        case "dot":           self = .PatternDot
        case "dash":          self = .PatternDash
        case "dash-dot":      self = .PatternDashDot
        case "dash-dot-dot":  self = .PatternDashDotDot
        case "by-word":       self = .ByWord
        default:              self = .StyleNone
      }
    } else { return nil }
  }
}

extension NSUnderlineStyle: EnumerableType {
  public static var all: [NSUnderlineStyle] {
    return [.StyleNone, .StyleSingle, .StyleThick, .StyleDouble, .PatternDot, .PatternDash,
            .PatternDashDot, .PatternDashDotDot, .ByWord]
  }

  public static func enumerate(block: (NSUnderlineStyle) -> Void) { apply(all, block) }

}

extension NSLineBreakMode: JSONValueConvertible {
  public var jsonValue: JSONValue {
    switch self {
      case .ByWordWrapping:      return "word-wrap"
      case .ByCharWrapping:      return "character-wrap"
      case .ByClipping:          return "clip"
      case .ByTruncatingHead:    return "truncate-head"
      case .ByTruncatingTail:    return "truncate-tail"
      case .ByTruncatingMiddle:  return "truncate-middle"
    }
  }
}

extension NSLineBreakMode: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let string = String(jsonValue) {
      switch string {
        case "character-wrap":  self = .ByCharWrapping
        case "clip":            self = .ByClipping
        case "truncate-head":   self = .ByTruncatingHead
        case "truncate-tail":   self = .ByTruncatingTail
        case "truncate-middle": self = .ByTruncatingMiddle
        default:                self = .ByWordWrapping
      }
    } else { return nil }
  }
}

extension NSLineBreakMode: EnumerableType {
  public static var all: [NSLineBreakMode] {
    return [.ByWordWrapping, .ByCharWrapping, .ByClipping, .ByTruncatingHead, .ByTruncatingTail, .ByTruncatingMiddle]
  }

  public static func enumerate(block: (NSLineBreakMode) -> Void) { apply(all, block) }
}

extension NSTextAlignment: JSONValueConvertible {
  public var jsonValue: JSONValue {
    switch self {
      case .Left:      return "left"
      case .Right:     return "right"
      case .Center:    return "center"
      case .Justified: return "justified"
      case .Natural:   return "natural"
    }
  }
}

extension NSTextAlignment: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let string = String(jsonValue) {
      switch string {
        case "left":      self = .Left
        case "right":     self = .Right
        case "center":    self = .Center
        case "justified": self = .Justified
        default:          self = .Natural
      }
    } else { return nil }
  }
}

extension NSTextAlignment: EnumerableType {
  public static var all: [NSTextAlignment] { return [.Left, .Right, .Center, .Justified, .Natural] }
  public static func enumerate(block: (NSTextAlignment) -> Void) { apply(all, block) }
}

extension NSShadow: JSONValueConvertible {
  public var jsonValue: JSONValue {
    var dict: JSONValue.ObjectValue = ["offset": shadowOffset.jsonValue, "radius": shadowBlurRadius.jsonValue]
    if shadowColor != nil { dict["color"] = (shadowColor as! UIColor).jsonValue }
    return .Object(dict)
  }
}

extension NSShadow /*: JSONValueInitializable */ {
  public convenience init?(_ jsonValue: JSONValue?) {
    self.init()
    if let object = ObjectJSONValue(jsonValue) {
      if let offset = CGSize(object["offset"]) { shadowOffset = offset }
      if let radius = CGFloat(object["radius"]) { shadowBlurRadius = radius }
      if let color = UIColor(object["color"]) { shadowColor = color }
    }
  }
}

extension TitleAttributes {
  public enum IconTextOrderSpecification: JSONValueConvertible {
    case IconText, TextIcon
    public var jsonValue: JSONValue {
      switch self {
      case .IconText: return "icon-text"
      case .TextIcon: return "text-icon"
      }
    }
  }
}
extension TitleAttributes.IconTextOrderSpecification: JSONValueInitializable {
  public init?(_ jsonValue: JSONValue?) {
    if let string = String(jsonValue) {
      switch string {
        case "text-icon": self = .TextIcon
        default:          self = .IconText
      }
    } else { return nil }
  }

}

extension TitleAttributes.IconTextOrderSpecification: EnumerableType {
  public static var all: [TitleAttributes.IconTextOrderSpecification] { return [.IconText, .TextIcon] }
  public static func enumerate(block: (TitleAttributes.IconTextOrderSpecification) -> Void) { apply(all, block) }

}

extension TitleAttributes {
  public enum PropertyKey: String {
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

    public var attributeKey: String? {
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
  }
}

extension TitleAttributes.PropertyKey: EnumerableType {

  public static var all: [TitleAttributes.PropertyKey] {
    return [.Font, .ForegroundColor, .BackgroundColor, .Ligature, .IconName, .Text, .Shadow, .Expansion, .Obliqueness,
            .StrikethroughColor, .UnderlineColor, .BaselineOffset, .TextEffect, .StrokeWidth, .StrokeColor,
            .UnderlineStyle, .StrikethroughStyle, .Kern, .HyphenationFactor, .ParagraphSpacingBefore, .LineHeightMultiple,
            .MaximumLineHeight, .MinimumLineHeight, .LineBreakMode, .TailIndent, .HeadIndent, .FirstLineHeadIndent,
            .Alignment, .ParagraphSpacing, .LineSpacing, .IconTextOrder]
  }

  static var paragraphKeys: [TitleAttributes.PropertyKey] {
    return [.HyphenationFactor, .ParagraphSpacingBefore, .LineHeightMultiple, .MaximumLineHeight, .MinimumLineHeight,
            .LineBreakMode, .TailIndent, .HeadIndent, .FirstLineHeadIndent, .Alignment, .ParagraphSpacing, .LineSpacing]
  }

  public static var attributeKeys: [TitleAttributes.PropertyKey] {
    return [.Font, .ForegroundColor, .BackgroundColor, .Ligature, .Shadow, .Expansion, .Obliqueness, .StrikethroughColor,
            .UnderlineColor, .BaselineOffset, .TextEffect, .StrokeWidth, .StrokeColor, .UnderlineStyle, .StrikethroughStyle,
            .Kern]
  }

  public static func enumerate(block: (TitleAttributes.PropertyKey) -> Void) { apply(all, block) }
  public static func enumerateParagraphPropertyKeys(block: (TitleAttributes.PropertyKey) -> Void) { paragraphKeys ➤ block }
  public static func enumerateAttributePropertyKeys(block: (TitleAttributes.PropertyKey) -> Void) { attributeKeys ➤ block }
}

public struct TitleAttributes: JSONValueConvertible, JSONValueInitializable {

  public var iconTextOrder: IconTextOrderSpecification {
    get { return self[.IconTextOrder] as? IconTextOrderSpecification ?? .IconText }
    set { self[.IconTextOrder] = newValue }
  }

  public var text: String {
    get { return self[.Text] as? String ?? "" }
    set { self[.Text] = newValue }
  }

  public var iconName: String? {
    get { return self[.IconName] as? String }
    set { self[.IconName] = newValue }
  }

  public var icon: String {
    get { if let name = iconName { return UIFont.fontAwesomeIconForName(name) } else { return "" } }
    set { iconName = UIFont.fontAwesomeNameForIcon(newValue) }
  }

  public var font: UIFont {
    get { return self[.Font] as? UIFont ?? UIFont(name: "HelveticaNeue", size: 12)! }
    set { self[.Font] = newValue.jsonValue }
  }

  public var foregroundColor: UIColor {
    get { return self[.ForegroundColor] as? UIColor ?? UIColor.blackColor() }
    set { self[.ForegroundColor] = newValue }
  }

  public var backgroundColor: UIColor? {
    get { return self[.BackgroundColor] as? UIColor }
    set { self[.BackgroundColor] = newValue }
  }

  public var ligature: Int {
    get { return self[.Ligature] as? Int ?? 1 }
    set { if 0...1 ~= newValue { self[.Ligature] = newValue } }
  }

  public var shadow: NSShadow? {
    get { return self[.Shadow] as? NSShadow }
    set { self[.Shadow] = newValue }
  }

  public var expansion: Float {
    get { return self[.Expansion] as? Float ?? 0.0 }
    set { self[.Expansion] = newValue }
  }

  public var obliqueness: Float {
    get { return self[.Obliqueness] as? Float ?? 0.0}
    set { self[.Obliqueness] = newValue }
  }

  public var strikethroughColor: UIColor {
    get { return self[.StrikethroughColor] as? UIColor ?? foregroundColor }
    set { self[.StrikethroughColor] = newValue }
  }

  public var underlineColor: UIColor {
    get { return self[.UnderlineColor] as? UIColor ?? foregroundColor }
    set { self[.UnderlineColor] = newValue }
  }

  public var baselineOffset: Float {
    get { return self[.BaselineOffset] as? Float ?? 0.0 }
    set { self[.BaselineOffset] = newValue }
  }

  public var textEffect: String? {
    get { return self[.TextEffect] as? String }
    set { if newValue == PropertyKey.TextEffect.attributeKey { self[.TextEffect] = "letterpress" } }
  }

  // TODO: Check whether we need to adjust values for `.StrokeFill` here
  public var strokeWidth: Float {
    get { return self[.StrokeWidth] as? Float ?? 0 }
    set { self[.StrokeWidth] = abs(newValue) }
  }

  public var strokeFill: Bool {
    get { return self[.StrokeFill] as? Bool ?? false }
    set { self[.StrokeFill] = newValue }
  }

  public var strokeColor: UIColor {
    get { return self[.StrokeColor] as? UIColor ?? foregroundColor }
    set { self[.StrokeColor] = newValue }
  }

  public var underlineStyle: NSUnderlineStyle {
    get { return  self[.UnderlineStyle] as? NSUnderlineStyle ?? .StyleNone }
    set { self[.UnderlineStyle] = newValue }
  }

  public var strikethroughStyle: NSUnderlineStyle {
    get { return self[.StrikethroughStyle] as? NSUnderlineStyle ?? .StyleNone }
    set { self[.StrikethroughStyle] = newValue }
  }

  public var kern: Float {
    get { return self[.Kern] as? Float ?? 0 }
    set { self[.Kern] = newValue }
  }

  public var paragraphStyle: NSParagraphStyle {
    get {
      return NSParagraphStyle.paragraphStyleWithAttributes(lineSpacing: lineSpacing,
                                                           paragraphSpacing: paragraphSpacing,
                                                           alignment: alignment,
                                                           headIndent: headIndent,
                                                           tailIndent: tailIndent,
                                                           firstLineHeadIndent: firstLineHeadIndent,
                                                           minimumLineHeight: minimumLineHeight,
                                                           maximumLineHeight: maximumLineHeight,
                                                           lineBreakMode: lineBreakMode,
                                                           lineHeightMultiple: lineHeightMultiple,
                                                           paragraphSpacingBefore: paragraphSpacingBefore,
                                                           hyphenationFactor: hyphenationFactor)
    }
    set {
      lineSpacing = newValue.lineSpacing
      paragraphSpacing = newValue.paragraphSpacing
      alignment = newValue.alignment
      headIndent = newValue.headIndent
      tailIndent = newValue.tailIndent
      firstLineHeadIndent = newValue.firstLineHeadIndent
      minimumLineHeight = newValue.minimumLineHeight
      maximumLineHeight = newValue.maximumLineHeight
      lineBreakMode = newValue.lineBreakMode
      lineHeightMultiple = newValue.lineHeightMultiple
      paragraphSpacingBefore = newValue.paragraphSpacingBefore
      hyphenationFactor = newValue.hyphenationFactor
    }
  }

  public var alignment: NSTextAlignment {
    get { return self[.Alignment] as? NSTextAlignment ?? .Natural }
    set { self[.Alignment] = newValue }
  }

  public var firstLineHeadIndent: CGFloat {
    get { return self[.FirstLineHeadIndent] as? CGFloat ?? 0 }
    set { self[.FirstLineHeadIndent] = newValue }
  }

  public var headIndent: CGFloat {
    get { return self[.HeadIndent] as? CGFloat ?? 0 }
    set { self[.HeadIndent] = newValue }
  }

  public var tailIndent: CGFloat {
    get { return self[.TailIndent] as? CGFloat ?? 0 }
    set { self[.TailIndent] = newValue }
  }

  public var lineHeightMultiple: CGFloat {
    get { return self[.LineHeightMultiple] as? CGFloat ?? 0 }
    set { self[.LineHeightMultiple] = newValue }
  }

  public var maximumLineHeight: CGFloat {
    get { return self[.MaximumLineHeight] as? CGFloat ?? 0 }
    set { self[.MaximumLineHeight] = newValue }
  }

  public var minimumLineHeight: CGFloat {
    get { return self[.MinimumLineHeight] as? CGFloat ?? 0 }
    set { self[.MinimumLineHeight] = newValue }
  }

  public var lineSpacing: CGFloat {
    get { return self[.LineSpacing] as? CGFloat ?? 0}
    set { self[.LineSpacing] = newValue }
  }

  public var paragraphSpacing: CGFloat {
    get { return self[.ParagraphSpacing] as? CGFloat ?? 0 }
    set { self[.ParagraphSpacing] = newValue }
  }

  public var paragraphSpacingBefore: CGFloat {
    get { return self[.ParagraphSpacingBefore] as? CGFloat ?? 0}
    set { self[.ParagraphSpacingBefore] = newValue }
  }

  public var hyphenationFactor: Float {
    get { return self[.HyphenationFactor] as? Float ?? 0 }
    set { self[.HyphenationFactor] = newValue }
  }

  public var lineBreakMode: NSLineBreakMode {
    get { return self[.LineBreakMode] as? NSLineBreakMode ?? .ByWordWrapping }
    set { self[.LineBreakMode] = newValue }
  }

  public var stringText: String {
    switch iconTextOrder { case .IconText: return icon + text; case .TextIcon: return text + icon }
  }

  public var iconString: NSAttributedString {
    var attrs = attributes
    let pointSize: CGFloat = (attrs[PropertyKey.Font.attributeKey!] as? UIFont)?.pointSize ?? 18.0
    let font = UIFont(awesomeFontWithSize: pointSize)
    attrs[PropertyKey.Font.attributeKey!] = font
    return NSAttributedString(string: icon, attributes: attrs)
  }

  public var textString: NSAttributedString {
    return NSAttributedString(string: text, attributes: attributes)
  }

  public var string: NSAttributedString { return stringWithAttributes(attributes) }

  /**
  stringWithAttributes:

  :param: attrs MSDictionary

  :returns: NSAttributedString
  */
  private func stringWithAttributes(attrs: MSDictionary) -> NSAttributedString {
    return NSAttributedString(string: attrs[PropertyKey.Text.rawValue] as? String ?? "", attributes: attrs)
  }

  /**
  stringWithFillers:

  :param: fillers MSDictionary?

  :returns: NSAttributedString
  */
  public func stringWithFillers(fillers: MSDictionary?) -> NSAttributedString {
    if fillers != nil {
      var attrs = fillers!
      attrs.setValuesForKeysWithDictionary(attributes as [NSObject:AnyObject])
      return stringWithAttributes(attrs)
    } else { return string }
  }

  public var attributes: MSDictionary {
    let attrs: MSDictionary = [
      NSFontAttributeName                : font,
      NSForegroundColorAttributeName     : foregroundColor,
      NSBackgroundColorAttributeName     : backgroundColor ?? NSNull(),
      NSLigatureAttributeName            : ligature,
      NSShadowAttributeName              : shadow ?? NSNull(),
      NSExpansionAttributeName           : expansion,
      NSObliquenessAttributeName         : obliqueness,
      NSStrikethroughColorAttributeName  : strikethroughColor,
      NSUnderlineColorAttributeName      : underlineColor,
      NSBaselineOffsetAttributeName      : baselineOffset,
      NSTextEffectAttributeName          : textEffect ?? NSNull(),
      NSStrokeWidthAttributeName         : strokeFill ? -strokeWidth : strokeWidth,
      NSStrokeColorAttributeName         : strokeColor,
      NSUnderlineStyleAttributeName      : underlineStyle.rawValue,
      NSStrikethroughStyleAttributeName  : strikethroughStyle.rawValue,
      NSKernAttributeName                : kern,
      NSParagraphStyleAttributeName      : paragraphStyle,
      "text"                             : stringText
    ]
    attrs.compact()
    return attrs
  }

  public enum MergeKind { case CopyIfNilExisting, CopyAllNonNil, CopyAll }

  /**
  mergeWithTitleAttributes:mergeKind:

  :param: titleAttributes TitleAttributes
  :param: mergeKind MergeKind = .CopyIfNilExisting
  */
  public mutating func mergeWithTitleAttributes(titleAttributes: TitleAttributes?, mergeKind: MergeKind = .CopyIfNilExisting) {
    if titleAttributes != nil {
      PropertyKey.enumerate {
        let existingValue: Any? = self[$0]
        let sourceValue: Any? = titleAttributes![$0]
        switch mergeKind {
          case .CopyIfNilExisting: if sourceValue != nil && existingValue == nil { self[$0] = sourceValue! }
          case .CopyAllNonNil:     if sourceValue != nil { self[$0] = sourceValue! }
          case .CopyAll:           self[$0] = sourceValue
        }
      }
    }
  }

  /**
  mergedWithTitleAttributes:mergeKind:

  :param: titleAttributes TitleAttributes?
  :param: mergeKind MergeKind = .CopyIfNilExisting

  :returns: TitleAttributes
  */
  public func mergedWithTitleAttributes(titleAttributes: TitleAttributes?,
                              mergeKind: MergeKind = .CopyIfNilExisting) -> TitleAttributes {
    var mergedAttributes = self
    mergedAttributes.mergeWithTitleAttributes(titleAttributes, mergeKind: mergeKind)
    return mergedAttributes
  }

  /**
  Gets or sets a value for the specified property after first converting to/from a `JSONValue`

  :param: propertyKey PropertyKey

  :returns: Any?
  */
  public subscript(propertyKey: PropertyKey) -> Any? {
    get {
      let jsonValue = storage[propertyKey.rawValue]
      switch propertyKey {

        case .Font:
          return UIFont(jsonValue)

        case .ForegroundColor, .BackgroundColor, .StrikethroughColor, .UnderlineColor, .StrokeColor:
          return UIColor(jsonValue)

        case .IconName, .Text:
          return String(jsonValue)

        case .TextEffect:
          return String(jsonValue) == "letterpress" ? PropertyKey.TextEffect.attributeKey : nil

        case .Shadow:
          return NSShadow(jsonValue)

        case .Ligature:
          return Int(jsonValue)

        case .Expansion, .Obliqueness, .BaselineOffset, .Kern, .HyphenationFactor, .StrokeWidth:
          return Float(jsonValue)

         case .ParagraphSpacingBefore, .LineHeightMultiple, .MaximumLineHeight, .MinimumLineHeight, .ParagraphSpacing,
              .LineSpacing, .TailIndent, .HeadIndent, .FirstLineHeadIndent:
          return CGFloat(jsonValue)

        case .UnderlineStyle, .StrikethroughStyle:
          return NSUnderlineStyle(jsonValue)

        case .LineBreakMode:
          return NSLineBreakMode(jsonValue)

        case .Alignment:
          return NSTextAlignment(jsonValue)

        case .IconTextOrder:
          return IconTextOrderSpecification(jsonValue)

        case .StrokeWidth:
          if let w = Float(jsonValue) {
            let absW = abs(w)
            if let shouldFill = self[.StrokeFill] as? Bool {
              return shouldFill ? -absW : absW
            } else { return absW }
          } else { return nil }

        case .StrokeFill:
          return Bool(jsonValue)
      }

    }
    set {
      if let convertibleValue = newValue as? JSONValueConvertible {
        storage[propertyKey.rawValue] = convertibleValue.jsonValue
      }
    }
  }

  private(set) internal var storage: JSONValue.ObjectValue

  /** init */
  public init() { storage = [:] }

  /**
  initWithStorage:

  :param: storage [String AnyObject]
  */
  public init(storage: JSONValue.ObjectValue) { self.storage = storage.filter({(k, _) in PropertyKey(rawValue: k) != nil}) }

  /**
  initWithJSONValue:

  :param: JSONValue [String AnyObject]
  */
  public init?(_ jsonValue: JSONValue?) {
    if let object = ObjectJSONValue(jsonValue) {
      self.init(storage: object.value)
    } else { return nil }
  }

  public var jsonValue: JSONValue { return .Object(storage) }

}
