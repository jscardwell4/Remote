//
//  String+MoonKitAdditions.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/15/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

// even though infix ..< already exists, we need to declare it
// two more times for the prefix and postfix form
postfix operator ..< { }
prefix operator ..< { }

// then, declare a couple of simple custom types that indicate one-sided ranges:
public struct RangeStart<I: ForwardIndexType> { let start: I }
public struct RangeEnd<I: ForwardIndexType> { let end: I }

// and define ..< to return them
public postfix func ..<<I: ForwardIndexType>(lhs: I) -> RangeStart<I>
{ return RangeStart(start: lhs) }

public prefix func ..<<I: ForwardIndexType>(rhs: I) -> RangeEnd<I>
{ return RangeEnd(end: rhs) }

// finally, extend String to have a slicing subscript for these types:
extension String {
  public subscript(r: RangeStart<String.Index>) -> String {
    return self[r.start..<self.endIndex]
  }
  public subscript(r: RangeEnd<String.Index>) -> String {
    return self[self.startIndex..<r.end]
  }
}
public extension String {

  public static let Space:       String = " "
  public static let Newline:     String = "\n"
  public static let Tab:         String = "\t"
  public static let CommaSpace:  String = ", "
  public static let Quote:       String = "'"
  public static let DoubleQuote: String = "\""

  public var length: Int { return characters.count }
  public var count: Int { return characters.count }

  /** Returns the string converted to 'dash-case' */
  public var dashCaseString: String {
    guard !isDashCase else { return self }
    if isCamelCase { return "-".join(split(~/"(?<=\\p{Ll})(?=\\p{Lu})").map {$0.lowercaseString}) }
    else { return camelCaseString.dashCaseString }
  }

  /** Returns the string with the first character converted to lowercase */
  public var lowercaseFirst: String {
    guard count > 1 else { return lowercaseString }
    return self[startIndex ..< advance(startIndex, 1)].lowercaseString + self[advance(startIndex, 1) ..< endIndex]
  }

  /** Returns the string with the first character converted to uppercase */
  public var uppercaseFirst: String {
    guard count > 1 else { return uppercaseString }
    return self[startIndex ..< advance(startIndex, 1)].uppercaseString + self[advance(startIndex, 1) ..< endIndex]
  }

  /** Returns the string converted to 'camelCase' */
  public var camelCaseString: String {

    guard !isCamelCase else { return self }

    var components = split(~/"(?<=\\p{Ll})(?=\\p{Lu})|(?<=\\p{Lu})(?=\\p{Lu})|(\\p{Z}|\\p{P})")

    guard components.count > 0 else { return self }

    var i = 0
    while i < components.count && components[i] ~= ~/"^\\p{Lu}$" { components[i] = components[i++].lowercaseString }

    if i++ == 0 { components[0] = components[0].lowercaseFirst }

    for j in i ..< components.count where components[j] ~= ~/"^\\p{Ll}" { components[j] = components[j].uppercaseFirst }

    return "".join(components)
  }

  /** Returns the string converted to 'PascalCase' */
  public var pascalCaseString: String {
    guard !isPascalCase else { return self }
    return camelCaseString.sub(~/"^(\\p{Ll}+)", {$0.string.uppercaseString})
  }

  public var isQuoted: Bool { return hasPrefix("\"") && hasSuffix("\"") }
  public var quoted: String { return isQuoted ? self : "\"\(self)\"" }
  public var unquoted: String { return isQuoted ? self[1..<length - 1] : self }

  public var isCamelCase: Bool { return ~/"^\\p{Ll}+((?:\\p{Lu}|\\p{N})+\\p{Ll}*)*$" ~= self }
  public var isPascalCase: Bool { return ~/"^\\p{Lu}+((?:\\p{Ll}|\\p{N})+\\p{Lu}*)*$" ~= self }
  public var isDashCase: Bool { return ~/"^\\p{Ll}+(-\\p{Ll}*)*$" ~= self }

  public var pathEncoded: String { return self.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) ?? self }
  public var urlFragmentEncoded: String {
    return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())
      ?? self
  }
  public var urlPathEncoded: String {
    return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())
      ?? self
  }
  public var urlQueryEncoded: String {
    return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
      ?? self
  }

  public var urlUserEncoded: String {
    return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLUserAllowedCharacterSet())
      ?? self
  }

  public var pathDecoded: String { return self.stringByRemovingPercentEncoding ?? self }

  public var forwardSlashEncoded: String { return sub("/", "%2F") }
  public var forwardSlashDecoded: String { return sub("%2F", "/").sub("%2f", "/") }

  /**
  Returns the string with the specified amount of leading space in the form of space characters

  - parameter indent: Int
  - parameter preserveFirst: Bool = false

  - returns: String
  */
  public func indentedBy(indent: Int, preserveFirstLineIndent preserveFirst: Bool = false) -> String {
    let spacer = " " * indent
    let result = "\n\(spacer)".join("\n".split(self))
    return preserveFirst ? result : spacer + result
  }

  /**
  Convenience for using variadic parameter to pass strings

  - parameter strings: String...

  - returns: String
  */
  public func join(strings: String...) -> String { return join(strings) }

  /**
  Convenience for joining string representations of `elements`

  - parameter elements: [T]

  - returns: String
  */
  public func join<T>(elements: [T]) -> String { return join(elements.map { String($0) }) }

  /**
  Returns a string wrapped by `self`

  - parameter string: String

  - returns: String
  */
  public func sandwhich(string: String) -> String { return self + string + self }

  /**
  split:

  - parameter string: String

  - returns: [String]
  */
  public func split(string: String) -> [String] { return string.componentsSeparatedByString(self) }

  /**
  split:

  - parameter regex: RegularExpression

  - returns: [String]
  */
  public func split(regex: RegularExpression) -> [String] {
    let ranges = regex.matchRanges(self)
    guard ranges.count > 0 else { return [self] }
    return utf16.indices.split(ranges, noImplicitJoin: true).flatMap{String(utf16[$0])}
  }

  public var pathStack: Stack<String> { return Stack(Array(pathComponents.reverse())) }
  public var keypathStack: Stack<String> { return Stack(Array(".".split(self).reverse())) }

  // MARK: - Initializers

  public init(_ f: Float, precision: Int = -1) { self = String(Double(f)) }

  public init(_ d: Double, precision: Int = -1) {

    switch precision {
    case Int.min ... -1:
      self = String(prettyNil: d)
    case 0:
      self = String(prettyNil: Int(d))
    default:
      let string = String(prettyNil: d)
      if let decimal = string.characters.indexOf(".") {
        self = ".".join(string[..<decimal], String(prefix(string[advance(decimal, 1)..<].characters, precision)))
      } else { self = string }
    }
  }

  public init<T>(prettyNil x: T?) {
    if let x = x { self = String(x) } else { self = "nil" }
  }

  /**
  initWithContentsOfFile:error:

  - parameter contentsOfFile: String
  - parameter error: NSErrorPointer = nil
  */
  public init(contentsOfFile: String) throws {
    let string = try NSString(contentsOfFile: contentsOfFile, encoding: NSUTF8StringEncoding)
    self = string as String
  }

  /**
  init:ofType:error:

  - parameter resource: String
  - parameter type: String?
  - parameter error: NSErrorPointer = nil
  */
  public init(contentsOfBundleResource resource: String, ofType type: String?) throws {
    let error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
    if let filePath = NSBundle.mainBundle().pathForResource(resource, ofType: type) {
      let string = try NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
      self = string as String
    } else { throw error }
  }

  /**
  initWithData:encoding:

  - parameter data: NSData
  - parameter encoding: UInt = NSUTF8StringEncoding
  */
  public init?(data: NSData, encoding: UInt = NSUTF8StringEncoding) { 
    if let s = NSString(data: data, encoding: encoding) as? String { self = s } else { return nil }
  }

  /**
  subscript:

  - parameter i: Int

  - returns: Character
  */
  public subscript (i: Int) -> Character {
    get { return self[advance(i < 0 ? self.endIndex : self.startIndex, i)] }
    mutating set { replaceRange(i...i, with: [newValue]) }
  }

  /**
  replaceRange:with:

  - parameter subRange: Range<Int>
  - parameter newElements: C
  */
  public mutating func replaceRange<C : CollectionType where C.Generator.Element == Character>(subRange: Range<Int>, with newElements: C) {
    let range = indexRangeFromIntRange(subRange)
    replaceRange(range, with: newElements)
  }

  /**
  substringFromRange:

  - parameter range: Range<Int>

  - returns: String
  */
  public func substringFromRange(range: Range<Int>) -> String { return self[range] }
  

  /**
  subscript:

  - parameter r: Range<Int>

  - returns: String
  */
  public subscript (r: Range<Int>) -> String {
    get { return self[indexRangeFromIntRange(r)] }
    mutating set { replaceRange(r, with: newValue.characters) }
  }

  /**
  subscript:

  - parameter r: Range<UInt>

  - returns: String
  */
  public subscript (r: Range<UInt>) -> String {
    let rangeStart: String.Index = advance(startIndex, Int(r.startIndex))
    let rangeEnd:   String.Index = advance(startIndex, Int(distance(r.startIndex, r.endIndex)))
    let range: Range<String.Index> = Range<String.Index>(start: rangeStart, end: rangeEnd)
    return self[range]
  }

  /**
  subscript:

  - parameter r: NSRange

  - returns: String
  */
  public subscript (r: NSRange) -> String {
    let rangeStart: String.Index = advance(startIndex, r.location)
    let rangeEnd:   String.Index = advance(startIndex, r.location + r.length)
    let range: Range<String.Index> = Range<String.Index>(start: rangeStart, end: rangeEnd)
    return self[range]
  }

  public var indices: Range<String.Index> { return characters.indices }
  public var range: NSRange { return NSRange(location: 0, length: utf16.count) }

  /**
  Convert a `Range` to an `NSRange` over the string

  - parameter r: Range<String.Index>

  - returns: NSRange
  */
  public func convertRange(r: Range<String.Index>) -> NSRange {
    let location = r.startIndex == startIndex ? 0 : self[startIndex ..< r.startIndex].utf16.count
    let length = self[r].count
    return NSRange(location: location, length: length)
  }

  /**
  Convert an `NSRange` to a `Range` over the string

  - parameter r: NSRange

  - returns: Range<String.Index>?
  */
  public func convertRange(r: NSRange) -> Range<String.Index>? {
    let range = Range(start: UTF16Index(r.location), end: advance(UTF16Index(r.location), r.length))
    guard let lhs = String(utf16[utf16.startIndex ..< range.startIndex]), rhs = String(utf16[range]) else { return nil }
    let start = advance(startIndex, distance(lhs.startIndex, lhs.endIndex))
    let end = advance(start, distance(rhs.startIndex, rhs.endIndex))
    return start ..< end
  }

  /**
  indexRangeFromIntRange:

  - parameter range: Range<Int>

  - returns: Range<String
  */
  public func indexRangeFromIntRange(range: Range<Int>) -> Range<String.Index> {
    assert(false, "we shouldn't be using this")
    let s = advance(startIndex, range.startIndex)
    let e = advance(startIndex, range.endIndex)
    return Range<String.Index>(start: s, end: e)
  }

}

// MARK: - Operators

/** predicates */
prefix operator ∀ {}
public prefix func ∀(predicate: String) -> NSPredicate! { return NSPredicate(format: predicate) }
public prefix func ∀(predicate: (String, [AnyObject]?)) -> NSPredicate! {
  return NSPredicate(format: predicate.0, argumentArray: predicate.1)
}

/** func for an operator that creates a string by repeating a string multiple times */
public func *(lhs: String, var rhs: Int) -> String { var s = ""; while rhs-- > 0 { s += lhs }; return s }
