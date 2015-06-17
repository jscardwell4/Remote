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

  public var length: Int { return self.characters.count }

  public var dashcaseString: String {
    if isDashcase { return self }
    else if isCamelcase {
      var s = ""
      var offset = 0
      for range in compressed(rangesForCapture(0, byMatching: ~/"[a-z][A-Z]")) {
        s += self[offset...range.startIndex] + "-" + self[range.startIndex + 1...range.endIndex]
        offset = range.endIndex + 1
      }
      s += self[offset..<length]
      return s.lowercaseString
    } else { return camelcaseString.dashcaseString }
  }

  public var titlecaseString: String {
    if isTitlecase { return self }
    else if isDashcase { return String(self.characters.map{$0 == "-" ? " " : $0}).capitalizedString }
    else if isCamelcase {
      var s = String(self[startIndex]).uppercaseString
      for c in String(String(dropFirst(self.characters))).unicodeScalars {
        switch c.value {
          case 65...90: s += " "; s.append(c)
          default: s.append(c)
        }
      }
      return s
    } else {
      return capitalizedString
    }
  }

  public var camelcaseString: String {
    if isCamelcase { return self }
    else if isTitlecase { return String(self[startIndex]).lowercaseString + String(String(dropFirst(self.characters)).filter{$0 != " "}) }
    else if isDashcase {
      var s = String(self[startIndex]).lowercaseString
      var previousCharacterWasDash = false
      for c in String(String(dropFirst(self.characters))).unicodeScalars {
        switch c.value {
          case 45: previousCharacterWasDash = true
          default:
            if previousCharacterWasDash {
              s += String(c).uppercaseString
              previousCharacterWasDash = false
            } else {
              s += String(c).lowercaseString
            }
        }
      }
      return s
    } else {
      return capitalizedString
    }
  }

  public var isQuoted: Bool { return hasPrefix("\"") && hasSuffix("\"") }
  public var quoted: String { return isQuoted ? self : "\"\(self)\"" }
  public var unquoted: String { return isQuoted ? self[1..<length - 1] : self }

  public var isCamelcase: Bool { return ~/"^\\p{Ll}+((?:\\p{Lu}|[0-9])+\\p{Ll}*)*$" ~= self }
  public var isDashcase: Bool { return ~/"^\\p{Ll}+(-\\p{Ll}*)*$" ~= self }
  public var isTitlecase: Bool { return ~/"^(?:\\p{Lu}\\p{Ll}*)*$" ~= self }

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

  public var forwardSlashEncoded: String { return subbed("/", "%2F") }
  public var forwardSlashDecoded: String { return subbed("%2F", "/").subbed("%2f", "/") }

  public func indentedBy(indent: Int) -> String {
    let spacer = " " * indent
    return spacer + "\n\(spacer)".join("\n".split(self))
  }

  /**
  join:

  - parameter strings: String...

  - returns: String
  */
  public func join(strings: String...) -> String { return join(strings) }

  /**
  sandwhich:

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

  public var pathStack: Stack<String> { return Stack(Array(pathComponents.reverse())) }
  public var keypathStack: Stack<String> { return Stack(Array(".".split(self).reverse())) }

  // MARK: - Initializers

  public init(_ f: Float, precision: Int = -1) { self = String(Double(f)) }

  public init(_ d: Double, precision: Int = -1) {

    switch precision {
    case Int.min ... -1:
      self = toString(d)
    case 0:
      self = toString(Int(d))
    default:
      let string = toString(d)
      if let decimal = string.characters.indexOf(".".characters) {
        self = ".".join(string[..<decimal], String(prefix(string[advance(decimal, 1)..<].characters, precision)))
      } else { self = string }
    }
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

  // MARK: - Regular Expressions

  /**
  sub:replacement:

  - parameter target: String
  - parameter replacement: String

  - returns: String
  */
  public func subbed(target: String, _ replacement: String) -> String {
    return stringByReplacingOccurrencesOfString(target,
                                     withString: replacement,
                                        options: [],
                                          range: startIndex..<endIndex)
  }

  /**
  sub:replacement:

  - parameter target: String
  - parameter replacement: String
  */
  public mutating func sub(target: String, _ replacement: String) {
    if let range = rangeForCapture(0, inFirstMatchFor: ~/target) {
      replaceRange(range, with: replacement)
    }
  }

  /**
  substringFromRange:

  - parameter range: Range<Int>

  - returns: String
  */
  public func substringFromRange(range: Range<Int>) -> String { return self[range] }

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
  subscript:

  - parameter r: Range<Int>

  - returns: String
  */
  public subscript (r: Range<Int>) -> String {
    get { return self[indexRangeFromIntRange(r)] }
    mutating set { replaceRange(r, with: newValue) }
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

  /**
  matchFirst:

  - parameter pattern: String
  - returns: [String?]
  */
  public func matchFirst(pattern: String) -> [String?] { return matchFirst(~/pattern) }

  /**
  matchesRegEx:

  - parameter regex: NSRegularExpression

  - returns: Bool
  */
  public func matchesRegEx(regex: RegularExpression) -> Bool {
    return match(regex)
  }

  /**
  matchesRegEx:

  - parameter regex: String

  - returns: Bool
  */
  public func matchesRegEx(regex: String) -> Bool { return matchesRegEx(~/regex) }

  /**
  substringFromFirstMatchForRegEx:

  - parameter regex: NSRegularExpression

  - returns: String?
  */
  public func substringFromFirstMatchForRegEx(regex: RegularExpression) -> String? {
    var matchString: String?
    let range = NSRange(location: 0, length: self.characters.count)
    if let match = regex.regex?.firstMatchInString(self, options: [], range: range) {
      let matchRange = match.rangeAtIndex(0)
      precondition(matchRange.location != NSNotFound, "didn't expect a match object with no overall match range")
      matchString = self[matchRange]
    }
    return matchString
  }

  public var indices: Range<String.Index> { return Swift.indices(self) }

  /**
  stringByReplacingMatchesForRegEx:withTemplate:

  - parameter regex: NSRegularExpression
  - parameter template: String

  - returns: String
  */
  public func stringByReplacingMatchesForRegEx(regex: RegularExpression, withTemplate template: String) -> String {
    return regex.regex?.stringByReplacingMatchesInString(self,
                                          options: [],
                                            range: NSRange(location: 0, length: characterCount),
                                     withTemplate: template) ?? self
  }

  /**
  replaceMatchesForRegEx:withTemplate:

  - parameter regex: NSRegularExpression
  - parameter template: String

  - returns: String
  */
  public mutating func replaceMatchesForRegEx(regex: RegularExpression, withTemplate template: String) {
    self = stringByReplacingMatchesForRegEx(regex, withTemplate: template)
  }

  public var characterCount: Int { return self.characters.count }

  /**
  substringForCapture:inFirstMatchFor:

  - parameter capture: Int
  - parameter regex: NSRegularExpression

  - returns: String?
  */
  public func substringForCapture(capture: Int, inFirstMatchFor regex: RegularExpression) -> String? {
    let captures = matchFirst(regex)
    return capture >= 0 && capture <= (regex.regex?.numberOfCaptureGroups ?? -1) ? captures[capture - 1] : nil
  }

  /**
  matchingSubstringsForRegEx:

  - parameter regex: NSRegularExpression

  - returns: [String]
  */
  public func matchingSubstringsForRegEx(regex: RegularExpression) -> [String] {
    var substrings: [String] = []
    let range = NSRange(location: 0, length: self.characters.count)
    if let matches = regex.regex?.matchesInString(self, options: [], range: range) as? [NSTextCheckingResult] {
      for match in matches {
        let matchRange = match.rangeAtIndex(0)
        precondition(matchRange.location != NSNotFound, "didn't expect a match object with no overall match range")
        let substring = self[matchRange]
        substrings.append(substring)
      }
    }
    return substrings
  }

  /**
  rangesForCapture:byMatching:

  - parameter capture: Int
  - parameter pattern: String

  - returns: [Range<Int>?]
  */
  public func rangesForCapture(capture: Int, byMatching pattern: String) -> [Range<Int>?] {
    return rangesForCapture(capture, byMatching: ~/pattern)
  }

  /**
  rangeForCapture:inFirstMatchFor:

  - parameter capture: Int
  - parameter regex: NSRegularExpression

  - returns: Range<Int>?
  */
  public func rangeForCapture(capture: Int, inFirstMatchFor regex: RegularExpression) -> Range<Int>? {
    var range: Range<Int>?
    if let match = regex.regex?.firstMatchInString(self, options: [], range: NSRange(location: 0, length: self.characters.count)) {
      if capture >= 0 && capture <= regex.regex!.numberOfCaptureGroups {
        let matchRange = match.rangeAtIndex(capture)
        if matchRange.location != NSNotFound {
          range = matchRange.location..<NSMaxRange(matchRange)
        }
      }
    }
    return range
  }

  /**
  rangesForCapture:byMatching:

  - parameter capture: Int
  - parameter regex: NSRegularExpression

  - returns: [Range<Int>?]
  */
  public func rangesForCapture(capture: Int, byMatching regex: RegularExpression) -> [Range<Int>?] {
    var ranges: [Range<Int>?] = []
    let r = NSRange(location: 0, length: self.characters.count)
    if let matches = regex.regex?.matchesInString(self, options: [], range: r) as? [NSTextCheckingResult] {
      for match in matches {
        var range: Range<Int>?
        if capture >= 0 && capture <= regex.regex!.numberOfCaptureGroups {
          let matchRange = match.rangeAtIndex(capture)
          if matchRange.location != NSNotFound {
            range = matchRange.location..<NSMaxRange(matchRange)
          }
        }
        ranges.append(range)
      }
    }
    return ranges
  }

  /**
  toRegEx

  - returns: NSRegularExpression?
  */
  public func toRegEx() -> RegularExpression {
    var error: NSError? = nil
    let regex = RegularExpression(pattern: self.characters.count > 0 ? self : "(?:)", options: [], error: &error)
    #if os(iOS)
      MSHandleError(error, message: "failed to create regular expression object")
    #endif
    return regex
  }

  /**
  matchFirst:

  - parameter regex: NSRegularExpression
  - returns: [String?]
  */
  public func matchFirst(regex: RegularExpression) -> [String?] {
  	var captures: [String?] = []
    if let match: NSTextCheckingResult? = regex.regex?.firstMatchInString(self, options: [], range: NSRange(0..<length)) {
      for i in 1...regex.regex!.numberOfCaptureGroups {
        if let range = match?.rangeAtIndex(i) { captures.append(range.location != NSNotFound ? self[range] : nil) }
        else { captures.append(nil) }
      }
    }

    return captures
  }

  /**
  matchAll:

  - parameter regex: RegularExpression

  - returns: [[String?]]
  */
  public func matchAll(regex: RegularExpression) -> [[String?]] {
    var result: [[String?]] = []
    if let matches = regex.regex?.matchesInString(self, options: [], range: NSRange(0..<length)) as? [NSTextCheckingResult],
      captureCount = regex.regex?.numberOfCaptureGroups
    {
      for match in matches {
        var matchCaptures: [String?] = []
        for i in 1...captureCount {
          let range = match.rangeAtIndex(i)
          let substring: String? = range.location == NSNotFound ? nil : self[range]
          matchCaptures.append(substring)
        }
        result.append(matchCaptures)
      }
    }

    return result
  }


  /**
  indexRangeFromIntRange:

  - parameter range: Range<Int>

  - returns: Range<String
  */
  public func indexRangeFromIntRange(range: Range<Int>) -> Range<String.Index> {
    let s = advance(startIndex, range.startIndex)
    let e = advance(startIndex, range.endIndex)
    return Range<String.Index>(start: s, end: e)
  }

}

// MARK: - RegularExpressionMatchable

 extension String: RegularExpressionMatchable {
  public func match(regex: RegularExpression) -> Bool { return regex.match(self) }
}

public func enumerateMatches(pattern: String,
                             string: String,
                             block: (NSTextCheckingResult!, NSMatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void)
{
  (~/pattern).regex?.enumerateMatchesInString(string, options: [], range: NSRange(0..<string.length), usingBlock: block)
}

// MARK: - Operators

/** predicates */
prefix operator ∀ {}
public prefix func ∀(predicate: String) -> NSPredicate! { return NSPredicate(format: predicate) }
public prefix func ∀(predicate: (String, [AnyObject]?)) -> NSPredicate! {
  return NSPredicate(format: predicate.0, argumentArray: predicate.1)
}

/** pattern matching operator */
public func ~=(lhs: String, rhs: RegularExpression) -> Bool { return rhs ~= lhs }
public func ~=(lhs: RegularExpression, rhs: String) -> Bool { return rhs.matchesRegEx(lhs) }
public func ~=(lhs: String, rhs: String) -> Bool { return lhs.matchesRegEx(rhs) }

infix operator /~ { associativity left precedence 140 }
infix operator /≈ { associativity left precedence 140 }

/** func for an operator that returns the first matching substring for a pattern */
public func /~(lhs: String, rhs: RegularExpression) -> String? { return rhs /~ lhs }
public func /~(lhs: RegularExpression, rhs: String) -> String? { return rhs.substringFromFirstMatchForRegEx(lhs) }

/** func for an operator that returns an array of matching substrings for a pattern */
public func /≈(lhs: String, rhs: RegularExpression) -> [String] { return rhs /≈ lhs }
public func /≈(lhs: RegularExpression, rhs: String) -> [String] { return rhs.matchingSubstringsForRegEx(lhs) }

infix operator /…~ { associativity left precedence 140 }
infix operator /…≈ { associativity left precedence 140 }

//infix operator |≈| { associativity left precedence 140 }

/** func for an operator that returns the range of the first match in a string for a pattern */
public func /…~(lhs: String, rhs: RegularExpression) -> Range<Int>? { return rhs /…~ lhs }
public func /…~(lhs: RegularExpression, rhs: String) -> Range<Int>? { return lhs /…~ (rhs, 0) }

/** func for an operator that returns the range of the specified capture for the first match in a string for a pattern */
public func /…~(lhs: (String, Int), rhs: RegularExpression) -> Range<Int>? { return rhs /…~ lhs }
public func /…~(lhs: RegularExpression, rhs: (String, Int)) -> Range<Int>? {
  return rhs.0.rangeForCapture(rhs.1, inFirstMatchFor: lhs)
}

/** func for an operator that returns the ranges of all matches in a string for a pattern */
public func /…≈(lhs: String, rhs: RegularExpression) -> [Range<Int>?] { return rhs /…≈ lhs }
public func /…≈(lhs: RegularExpression, rhs: String) -> [Range<Int>?] { return lhs /…≈ (rhs, 0) }

/** func for an operator that returns the ranges of the specified capture for all matches in a string for a pattern */
public func /…≈(lhs: (String, Int), rhs: RegularExpression) -> [Range<Int>?] { return rhs /…≈ lhs }
public func /…≈(lhs: RegularExpression, rhs: (String, Int)) -> [Range<Int>?] {
  return rhs.0.rangesForCapture(rhs.1, byMatching: lhs)
}


/** func for an operator that returns the specified capture for the first match in a string for a pattern */
public func /~(lhs: (String, Int), rhs: RegularExpression) -> String? { return rhs /~ lhs }
public func /~(lhs: RegularExpression, rhs: (String, Int)) -> String? {
  return rhs.0.substringForCapture(rhs.1, inFirstMatchFor: lhs)
}

/** func for an operator that creates a string by repeating a string multiple times */
public func *(lhs: String, var rhs: Int) -> String { var s = ""; while rhs-- > 0 { s += lhs }; return s }

prefix operator ~/ {}

/** func for an operator that creates a regular expression from a string */
public prefix func ~/(pattern: String) -> RegularExpression { return RegularExpression(pattern: pattern) }

infix operator +⁈ { associativity left precedence 140 }

/** functions for combining a string with an optional string */
public func +⁈(lhs:String, rhs:String?) -> String? { if let r = rhs { return lhs + r } else { return nil } }
public func +⁈(lhs:String, rhs:String) -> String? { return lhs + rhs }
public func +⁈(lhs:String?, rhs:String?) -> String? { if let l = lhs { if let r = rhs { return l + r } }; return nil }

