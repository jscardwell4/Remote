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
  public init(jsonValue: JSONValue) {
    switch String(jsonValue) ?? "" {
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
  }

  public static var all: [NSUnderlineStyle] {
    return [.StyleNone, .StyleSingle, .StyleThick, .StyleDouble, .PatternDot, .PatternDash,
            .PatternDashDot, .PatternDashDotDot, .ByWord]
  }

  public static func enumerate(block: (NSUnderlineStyle) -> Void) { apply(all, block) }

}

extension NSLineBreakMode: JSONValueConvertible, EnumerableType {
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
  public init(jsonValue: JSONValue) {
    switch String(jsonValue) ?? "" {
      case "character-wrap":  self = .ByCharWrapping
      case "clip":            self = .ByClipping
      case "truncate-head":   self = .ByTruncatingHead
      case "truncate-tail":   self = .ByTruncatingTail
      case "truncate-middle": self = .ByTruncatingMiddle
      default:                self = .ByWordWrapping
    }
  }

  public static var all: [NSLineBreakMode] {
    return [.ByWordWrapping, .ByCharWrapping, .ByClipping, .ByTruncatingHead, .ByTruncatingTail, .ByTruncatingMiddle]
  }

  public static func enumerate(block: (NSLineBreakMode) -> Void) { apply(all, block) }
}

extension NSTextAlignment: JSONValueConvertible, EnumerableType {
  public var jsonValue: JSONValue {
    switch self {
      case .Left:      return "left"
      case .Right:     return "right"
      case .Center:    return "center"
      case .Justified: return "justified"
      case .Natural:   return "natural"
    }
  }
  public init(jsonValue: JSONValue) {
    switch String(jsonValue) ?? "" {
      case "left":      self = .Left
      case "right":     self = .Right
      case "center":    self = .Center
      case "justified": self = .Justified
      default:          self = .Natural
    }
  }

  public static var all: [NSTextAlignment] { return [.Left, .Right, .Center, .Justified, .Natural] }
  public static func enumerate(block: (NSTextAlignment) -> Void) { apply(all, block) }
}

extension NSShadow: JSONValueConvertible {
  public var jsonValue: JSONValue {
    var dict: JSONValue.ObjectValue = ["offset": .String(NSStringFromCGSize(shadowOffset)), "radius": .Number(shadowBlurRadius)]
    if shadowColor != nil { dict["color"] = (shadowColor as! UIColor).jsonValue }
    return .Object(dict)
  }

  public convenience init(jsonValue: JSONValue) {
    self.init()
    if let dict = jsonValue.value as? JSONValue.ObjectValue {
      if let offset = dict["offset"]?.value as? String { shadowOffset = CGSizeFromString(offset) }
      if let radius = dict["radius"]?.value as? NSNumber { shadowBlurRadius = CGFloat(radius.floatValue) }
      if let color = dict["color"]?.value as? String { shadowColor = UIColor(string: color) }
    }
  }
}

public struct TitleAttributes: JSONValueConvertible {

  public enum IconTextOrderSpecification: JSONValueConvertible, EnumerableType {
    case IconText, TextIcon
    public var jsonValue: JSONValue {
      switch self {
        case .IconText: return "icon-text"
        case .TextIcon: return "text-icon"
      }
    }
    public init(jsonValue: JSONValue) {
      switch String(jsonValue) ?? "" {
        case "text-icon": self = .TextIcon
        default:          self = .IconText
      }
    }

    public static var all: [IconTextOrderSpecification] { return [.IconText, .TextIcon] }
    public static func enumerate(block: (IconTextOrderSpecification) -> Void) { apply(all, block) }

  }

  public var iconTextOrder: IconTextOrderSpecification {
    get {
      if let s = self[.IconTextOrder] as? String { return IconTextOrderSpecification(jsonValue: .String(s)) }
      else { return .IconText }
    }
    set { self[.IconTextOrder] = newValue.jsonValue.value as! String }
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
    get {
      var font: UIFont?
      if let fontJSON = self[.Font] as? String {
        font = Font(jsonValue: fontJSON.jsonValue)?.font
      }
      return font ?? UIFont(name: "HelveticaNeue", size: 12)!
    }
    set { self[.Font] = Font(newValue).jsonValue.objectValue }
  }

  public var foregroundColor: UIColor {
    get {
      if let s =  self[.ForegroundColor] as? String {
        return UIColor(string: s)
      } else {
        return UIColor.blackColor()
      }
    }
    set { self[.ForegroundColor] = newValue.string }
  }

  public var backgroundColor: UIColor? {
    get { if let s =  self[.BackgroundColor] as? String { return UIColor(string: s)} else { return nil } }
    set { self[.BackgroundColor] = newValue?.string }
  }

  public var ligature: Int {
    get { return self[.Ligature] as? Int ?? 1 }
    set { if 0...1 ~= newValue { self[.Ligature] = newValue } }
  }

  public var shadow: NSShadow? {
    get { if let d = self[.Shadow] as? [String:AnyObject], json = JSONValue(d) { return NSShadow(jsonValue: json) } else { return nil } }
    set { self[.Shadow] = newValue?.jsonValue.objectValue }
  }

  public var expansion: Float {
    get { return self[.Expansion] as? Float ?? 0 }
    set { self[.Expansion] = newValue }
  }

  public var obliqueness: Float {
    get { return self[.Obliqueness] as? Float ?? 0}
    set { self[.Obliqueness] = newValue }
  }

  public var strikethroughColor: UIColor {
    get { if let s =  self[.StrikethroughColor] as? String { return UIColor(string: s)} else { return foregroundColor } }
    set { self[.StrikethroughColor] = newValue.string }
  }

  public var underlineColor: UIColor {
    get { if let s =  self[.UnderlineColor] as? String { return UIColor(string: s)} else { return foregroundColor } }
    set { self[.UnderlineColor] = newValue.string }
  }

  public var baselineOffset: Float {
    get { return self[.BaselineOffset] as? Float ?? 0 }
    set { self[.BaselineOffset] = newValue }
  }

  public var textEffect: String? {
    get { return self[.TextEffect] as? String }
    set { self[.TextEffect] = newValue }
  }

  public var strokeWidth: Float {
    get { return self[.StrokeWidth] as? Float ?? 0 }
    set { self[.StrokeWidth] = newValue }
  }

  public var strokeFill: Bool {
    get { return self[.StrokeFill] as? Bool ?? false }
    set { self[.StrokeFill] = newValue }
  }

  public var strokeColor: UIColor {
    get { if let s = self[.StrokeColor] as? String { return UIColor(string: s) } else { return foregroundColor } }
    set { self[.StrokeColor] = newValue.string }
  }

  public var underlineStyle: NSUnderlineStyle {
    get { return  NSUnderlineStyle(jsonValue: .String(self[.UnderlineStyle] as? String ?? "none")) }
    set { self[.UnderlineStyle] = newValue.jsonValue.value as! String }
  }

  public var strikethroughStyle: NSUnderlineStyle {
    get { return NSUnderlineStyle(jsonValue: .String(self[.StrikethroughStyle] as? String ?? "none")) }
    set { self[.StrikethroughStyle] = newValue.jsonValue.value as! String }
  }

  public var kern: Float {
    get { return self[.Kern] as? Float ?? 0 }
    set { self[.Kern] = newValue }
  }

  public var paragraphStyle: NSParagraphStyle {
    get {
      return NSParagraphStyle.paragraphStyleWithAttributes(
          lineSpacing: lineSpacing,
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
          hyphenationFactor: hyphenationFactor
        )
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
    get { return NSTextAlignment(jsonValue: .String(self[.Alignment] as? String ?? "natural")) }
    set { self[.Alignment] = newValue.jsonValue.value as! String }
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
    get { return NSLineBreakMode(jsonValue: .String(self[.LineBreakMode] as? String ?? "by-word-wrapping")) }
    set { self[.LineBreakMode] = newValue.jsonValue.value as! String }
  }


  /**
  stringText

  :returns: String
  */
  public var stringText: String {
    switch iconTextOrder {
      case .IconText: return icon + text
      case .TextIcon: return text + icon
    }
  }

  public var iconString: NSAttributedString {
    var attrs = attributes
    let pointSize: CGFloat = (attrs[PropertyKey.Font.attributeKey!] as? UIFont)?.pointSize ?? 18.0
    let font = UIFont(awesomeFontWithSize: pointSize)
    attrs[PropertyKey.Font.attributeKey!] = font
    return NSAttributedString(string: icon, attributes: attrs as [NSObject:AnyObject])
  }

  public var textString: NSAttributedString { return NSAttributedString(string: text, attributes: attributes as [NSObject:AnyObject]) }

  public var string: NSAttributedString { return stringWithAttributes(attributes) }

  /**
  stringWithAttributes:

  :param: attrs MSDictionary

  :returns: NSAttributedString
  */
  private func stringWithAttributes(attrs: MSDictionary) -> NSAttributedString {
    let text = attrs[PropertyKey.Text.rawValue] as? String ?? ""
    return NSAttributedString(string: text, attributes: attrs as [NSObject:AnyObject])
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

  /**
  mergedWithTitleAttributes:mergeKind:

  :param: titleAttributes TitleAttributes?
  :param: mergeKind MergeKind = .CopyIfNilExisting

  :returns: TitleAttributes
  */
  public func mergedWithTitleAttributes(titleAttributes: TitleAttributes?, mergeKind: MergeKind = .CopyIfNilExisting) -> TitleAttributes {
    var mergedAttributes = self
    mergedAttributes.mergeWithTitleAttributes(titleAttributes, mergeKind: mergeKind)
    return mergedAttributes
  }

  public subscript(propertyKey: PropertyKey) -> AnyObject? {
    get { return storage[propertyKey.rawValue] }
    set { storage[propertyKey.rawValue] = newValue }
  }

  public enum PropertyKey: String, JSONValueConvertible, EnumerableType {
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

    public var jsonValue: JSONValue { return .String(rawValue) }
    public init?(jsonValue: JSONValue) { if let s = String(jsonValue) { self.init(rawValue: s) } else { return nil } }

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

    public static var all: [PropertyKey] {
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

    public static var attributeKeys: [PropertyKey] {
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
    public static func enumerate(block: (PropertyKey) -> Void) { apply(all, block) }

    /**
    enumerateParagraphPropertyKeys:

    :param: block (PropertyKey) -> Void
    */
    public static func enumerateParagraphPropertyKeys(block: (PropertyKey) -> Void) { apply(paragraphKeys, block) }

    /**
    enumerateAttributePropertyKeys:

    :param: block (PropertyKey) -> Void
    */
    public static func enumerateAttributePropertyKeys(block: (PropertyKey) -> Void) { apply(attributeKeys, block) }

  }

  private var storage: [String:AnyObject]
  public var dictionaryValue: NSDictionary { return storage as NSDictionary }

  /** init */
  public init() { storage = [:] }

  /**
  initWithStorage:

  :param: storage [String AnyObject]
  */
  public init(storage: [String:AnyObject]) { self.storage = storage }

  /**
  initWithJSONValue:

  :param: JSONValue [String AnyObject]
  */
  public init(jsonValue: JSONValue) {
    storage = [:]

    let dict: JSONValue.ObjectValue = jsonValue.value as? JSONValue.ObjectValue ?? [:]

    PropertyKey.enumerate {
      (propertyKey: PropertyKey) -> Void in

//      var storedValue: AnyObject?

      if let value: JSONValue = dict[String(propertyKey.jsonValue)!] {
//        switch value {
//        case .String(_):
//          switch propertyKey {
//          case .Font:
//            break
//          case .ForegroundColor, .BackgroundColor, .StrikethroughColor, .UnderlineColor, .StrokeColor:
//            break
//          case .IconName:
//            break
//          case .Text:
//            break
//          case .TextEffect:
//            break
//          case .UnderlineStyle, .StrikethroughStyle:
//            break
//          case .LineBreakMode:
//            break
//          case .Alignment:
//            break
//          case .IconTextOrder:
//            break
//          default:
//            break
//          }
//          break
//        case .Number(_):
//          switch propertyKey {
//          case .Ligature:
//            break
//          case .Expansion, .Obliqueness, .BaselineOffset, .Kern, .HyphenationFactor, .ParagraphSpacingBefore,
//               .LineHeightMultiple, .MaximumLineHeight, .MinimumLineHeight, .ParagraphSpacing, .LineSpacing, .TailIndent,
//               .HeadIndent, .FirstLineHeadIndent:
//            break
//          case .StrokeWidth:
//            break
//          default:
//            break
//          }
//          break
//        case .Boolean(_):
//          break
//        case .Array(_):
//          break
//        case .Object(_):
//          switch propertyKey {
//          case .Shadow:
//            break
//          default:
//            break
//          }
//          break
//        }
//        switch propertyKey {
//
//          case .Font:
//            if let f = value.value as? String { storedValue = Font(jsonValue: f.jsonValue)?.jsonValue.objectValue }
//
//          case .ForegroundColor, .BackgroundColor, .StrikethroughColor, .UnderlineColor, .StrokeColor:
//            if let c = value.value as? String { storedValue = UIColor(string: c)?.string }
//
//          case .Ligature:
//            if let i = value.value as? Int { if i == 0 || i == 1 { storedValue = i } }
//
//          case .IconName:
//            if let s = value.value as? String { if ((UIFont.fontAwesomeIconNames() as NSSet).allObjects as! [String]) ∋ s { storedValue = s } }
//
//          case .Text:
//            if let s = value.value as? String { storedValue = s }
//          //FIXME: need to resolve this for JSONValueConvertible changes
////            else if value.respondsToSelector("stringValue") { storedValue = value.valueForKey("stringValue") }
//
//          case .Shadow:
//            if let d = value.objectValue as? MSDictionary { storedValue = d }
//
//          case .Expansion, .Obliqueness, .BaselineOffset, .Kern, .HyphenationFactor, .ParagraphSpacingBefore,
//               .LineHeightMultiple, .MaximumLineHeight, .MinimumLineHeight, .ParagraphSpacing, .LineSpacing, .TailIndent,
//               .HeadIndent, .FirstLineHeadIndent:
//            if let n = value.value as? NSNumber { storedValue = n }
//
//          case .StrokeWidth:
//            if let n = value.value as? NSNumber { self[.StrokeFill] = n.floatValue.isSignMinus; storedValue = abs(n.floatValue) }
//
//          case .TextEffect:
//            if let e = value.value as? String { if e == "letterpress" { storedValue = e } }
//
//          case .UnderlineStyle, .StrikethroughStyle:
//            if let n = value.value as? NSNumber { storedValue = NSUnderlineStyle(rawValue: n.integerValue)?.jsonValue.value as? String }
//            else if let s = value.value as? String { storedValue = NSUnderlineStyle(jsonValue: value).jsonValue.value as! String }
//
//          case .LineBreakMode:
//            if let n = value.value as? NSNumber { storedValue = NSLineBreakMode(rawValue: n.integerValue)?.jsonValue.value as? String }
//            else if let s = value.value as? String { storedValue = NSLineBreakMode(jsonValue: value).jsonValue.value as! String }
//
//          case .Alignment:
//            if let n = value.value as? NSNumber { storedValue = NSTextAlignment(rawValue: n.integerValue)?.jsonValue.value as? String }
//            else if let s = value.value as? String { storedValue = NSTextAlignment(jsonValue: value).jsonValue.value as! String }
//
//          case .IconTextOrder:
//            if let s = value.value as? String { storedValue = IconTextOrderSpecification(jsonValue: value).jsonValue.value as! String }
//
//          default: break
//        }

//        if storedValue != nil { self[propertyKey] = storedValue }
        self[propertyKey] = value.rawValue

      }

    }

  }

  public var jsonValue: JSONValue {
    var dict: JSONValue.ObjectValue = [:]
    PropertyKey.enumerate {
      if let value: AnyObject = self[$0] {
        switch $0 {
          case .StrokeWidth: dict[$0.jsonValue.value as! String] = .Number(self.strokeFill ? -(value as! NSNumber).floatValue : (value as! NSNumber))
          default: dict[$0.jsonValue.value as! String] = JSONValue(value)
        }
      }
    }
    return .Object(dict)
  }

}
