//
//  String+MoonKitAdditions.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/15/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

public extension String {

  public static let Space:       String = " "
  public static let Newline:     String = "\n"
  public static let Tab:         String = "\t"
  public static let CommaSpace:  String = ", "
  public static let Quote:       String = "'"
  public static let DoubleQuote: String = "\""

  public var length: Int { return countElements(self) }

  public var dashcaseString: String {
    if isDashcase { return self }
    else if isCamelcase {
      var s = String(self[startIndex])
      for c in String(dropFirst(self)).unicodeScalars {
        switch c.value {
          case 65...90: s += "-"; s += String(UnicodeScalar(c.value + 32))
          default: s.append(c)
        }
      }
      return s
    } else { return String(map(self){$0 == " " ? "-" : $0}).lowercaseString }
  }
  public var titlecaseString: String {
    if isTitlecase { return self }
    else if isDashcase { return String(map(self){$0 == "-" ? " " : $0}).capitalizedString }
    else if isCamelcase {
      var s = String(self[startIndex]).uppercaseString
      for c in String(dropFirst(self)).unicodeScalars {
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
    else if isTitlecase { return String(self[startIndex]).lowercaseString + String(filter(dropFirst(self)){$0 != " "}) }
    else if isDashcase {
      var s = String(self[startIndex]).lowercaseString
      var previousCharacterWasDash = false
      for c in String(dropFirst(self)).unicodeScalars {
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
  public var isCamelcase: Bool { return ~/"^\\p{Ll}+(\\p{Lu}+\\p{Ll}*)*$" ~= self }
  public var isDashcase: Bool { return ~/"^\\p{Ll}+(-\\p{Ll}*)*$" ~= self }
  public var isTitlecase: Bool { return ~/"^\\p{Lu}\\p{Ll}*(\\P{L}+\\p{Lu}\\p{Ll}*)*$" ~= self }

  /**
  join:

  :param: strings String...

  :returns: String
  */
  public func join(strings: String...) -> String {
    return join(strings)
  }

  /**
  initWithContentsOfFile:error:

  :param: contentsOfFile String
  :param: error NSErrorPointer = nil
  */
  public init?(contentsOfFile: String, error: NSErrorPointer = nil) {
    if let string = NSString(contentsOfFile: contentsOfFile, encoding: NSUTF8StringEncoding, error: error) {
      self = string as String
    } else { return nil }
  }


  /**
  substringFromRange:

  :param: range Range<Int>

  :returns: String
  */
  public func substringFromRange(range: Range<Int>) -> String {
    return self[range]
  }

  /**
  subscript:

  :param: i Int

  :returns: Character
  */
  public subscript (i: Int) -> Character {
    let index: String.Index = advance(i < 0 ? self.endIndex : self.startIndex, i)
    return self[index]
  }

  /**
  subscript:

  :param: r Range<Int>

  :returns: String
  */
  public subscript (r: Range<Int>) -> String {
    let rangeStart: String.Index = advance(startIndex, r.startIndex)
    let rangeEnd:   String.Index = advance(r.endIndex < 0 ? endIndex : startIndex, r.endIndex)
    let range: Range<String.Index> = Range<String.Index>(start: rangeStart, end: rangeEnd)
    return self[range]
  }


  public subscript (r: Range<UInt>) -> String {
    let rangeStart: String.Index = advance(startIndex, Int(r.startIndex))
    let rangeEnd:   String.Index = advance(startIndex, Int(distance(r.startIndex, r.endIndex)))
    let range: Range<String.Index> = Range<String.Index>(start: rangeStart, end: rangeEnd)
    return self[range]
  }

  /**
  subscript:

  :param: r NSRange

  :returns: String
  */
  public subscript (r: NSRange) -> String {
    let rangeStart: String.Index = advance(startIndex, r.location)
    let rangeEnd:   String.Index = advance(startIndex, r.location + r.length)
    let range: Range<String.Index> = Range<String.Index>(start: rangeStart, end: rangeEnd)
    return self[range]
  }

  /**
  matchFirst:

  :param: pattern String
  :returns: [String?]
  */
  public func matchFirst(pattern: String) -> [String?] { return matchFirst(~/pattern) }

  /**
  matchesRegEx:

  :param: regex NSRegularExpression

  :returns: Bool
  */
  public func matchesRegEx(regex: NSRegularExpression) -> Bool {
    return regex.numberOfMatchesInString(self, options: nil, range: NSRange(location: 0,  length: countElements(self))) > 0
  }

  /**
  substringFromFirstMatchForRegEx:

  :param: regex NSRegularExpression

  :returns: String?
  */
  public func substringFromFirstMatchForRegEx(regex: NSRegularExpression) -> String? {
    var matchString: String?
    let range = NSRange(location: 0, length: countElements(self))
    if let match = regex.firstMatchInString(self, options: nil, range: range) {
      let matchRange = match.rangeAtIndex(0)
      precondition(matchRange.location != NSNotFound, "didn't expect a match object with no overall match range")
      matchString = self[matchRange]
    }
    return matchString
  }

  public var indices: Range<String.Index> { return Swift.indices(self) }

  /**
  stringByReplacingMatchesForRegEx:withTemplate:

  :param: regex NSRegularExpression
  :param: template String

  :returns: String
  */
  public func stringByReplacingMatchesForRegEx(regex: NSRegularExpression, withTemplate template: String) -> String {
    return regex.stringByReplacingMatchesInString(self,
                                          options: nil,
                                            range: NSRange(location: 0, length: characterCount),
                                     withTemplate: template)
  }

  public var characterCount: Int { return countElements(self) }

  /**
  substringForCapture:inFirstMatchFor:

  :param: capture Int
  :param: regex NSRegularExpression

  :returns: String?
  */
  public func substringForCapture(capture: Int, inFirstMatchFor regex: NSRegularExpression) -> String? {
    let captures = matchFirst(regex)
    return capture >= 0 && capture <= regex.numberOfCaptureGroups ? captures[capture - 1] : nil
  }

  /**
  matchingSubstringsForRegEx:

  :param: regex NSRegularExpression

  :returns: [String]
  */
  public func matchingSubstringsForRegEx(regex: NSRegularExpression) -> [String] {
    var substrings: [String] = []
    let range = NSRange(location: 0, length: countElements(self))
    if let matches = regex.matchesInString(self, options: nil, range: range) as? [NSTextCheckingResult] {
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

  :param: capture Int
  :param: pattern String

  :returns: [Range<Int>?]
  */
  public func rangesForCapture(capture: Int, byMatching pattern: String) -> [Range<Int>?] {
    var ranges: [Range<Int>?] = []
    if let regex = ~/pattern { ranges = rangesForCapture(capture, byMatching: regex) }
    return ranges
  }

  /**
  rangeForCapture:inFirstMatchFor:

  :param: capture Int
  :param: regex NSRegularExpression

  :returns: Range<Int>?
  */
  public func rangeForCapture(capture: Int, inFirstMatchFor regex: NSRegularExpression) -> Range<Int>? {
    var range: Range<Int>?
    if let match = regex.firstMatchInString(self, options: nil, range: NSRange(location: 0, length: countElements(self))) {
      if capture >= 0 && capture <= regex.numberOfCaptureGroups {
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

  :param: capture Int
  :param: regex NSRegularExpression

  :returns: [Range<Int>?]
  */
  public func rangesForCapture(capture: Int, byMatching regex: NSRegularExpression) -> [Range<Int>?] {
    var ranges: [Range<Int>?] = []
    let r = NSRange(location: 0, length: countElements(self))
    if let matches = regex.matchesInString(self, options: nil, range: r) as? [NSTextCheckingResult] {
      for match in matches {
        var range: Range<Int>?
        if capture >= 0 && capture <= regex.numberOfCaptureGroups {
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

  :returns: NSRegularExpression?
  */
  public func toRegEx() -> NSRegularExpression? {
    var error: NSError? = nil
    let regex = NSRegularExpression(pattern: self, options: nil, error: &error)
    MSHandleError(error, message: "failed to create regular expression object")
    return regex
  }

  /**
  matchFirst:

  :param: regex NSRegularExpression
  :returns: [String?]
  */
  public func matchFirst(regex: NSRegularExpression) -> [String?] {
    let r = NSRange(location: 0, length: length)
  	let match: NSTextCheckingResult? = regex.firstMatchInString(self, options: nil, range: r)
  	var captures: [String?] = []
  	for i in 1...regex.numberOfCaptureGroups {
      if let range = match?.rangeAtIndex(i) { captures.append(range.location != NSNotFound ? self[range] : nil) }
      else { captures.append(nil) }
  	}

    return captures
  }

  /**
  indexRangeFromIntRange:

  :param: range Range<Int>

  :returns: Range<String
  */
  public func indexRangeFromIntRange(range: Range<Int>) -> Range<String.Index> {
    let s = advance(startIndex, range.startIndex)
    let e = advance(startIndex, range.endIndex)
    return Range<String.Index>(start: s, end: e)
  }

}

public func enumerateMatches(pattern: String,
                             string: String,
                             block: (NSTextCheckingResult!, NSMatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void)
{
  if let regex = ~/pattern {
    regex.enumerateMatchesInString(string, options: nil, range: NSRange(location: 0, length: string.length), usingBlock: block)
  }
}

/** predicates */
prefix operator ∀ {}
public prefix func ∀(predicate: String) -> NSPredicate! { return NSPredicate(format: predicate) }
public prefix func ∀(predicate: (String, [AnyObject]?)) -> NSPredicate! {
  return NSPredicate(format: predicate.0, argumentArray: predicate.1)
}

/** pattern matching operator */
public func ~=(lhs: String, rhs: NSRegularExpression) -> Bool { return rhs ~= lhs }
public func ~=(lhs: NSRegularExpression, rhs: String) -> Bool { return rhs.matchesRegEx(lhs) }

infix operator /~ { associativity left precedence 140 }
infix operator /≈ { associativity left precedence 140 }

/** func for an operator that returns the first matching substring for a pattern */
public func /~(lhs: String, rhs: NSRegularExpression) -> String? { return rhs /~ lhs }
public func /~(lhs: NSRegularExpression, rhs: String) -> String? { return rhs.substringFromFirstMatchForRegEx(lhs) }

/** func for an operator that returns an array of matching substrings for a pattern */
public func /≈(lhs: String, rhs: NSRegularExpression) -> [String] { return rhs /≈ lhs }
public func /≈(lhs: NSRegularExpression, rhs: String) -> [String] { return rhs.matchingSubstringsForRegEx(lhs) }

infix operator /…~ { associativity left precedence 140 }
infix operator /…≈ { associativity left precedence 140 }

//infix operator |≈| { associativity left precedence 140 }

/** func for an operator that returns the range of the first match in a string for a pattern */
public func /…~(lhs: String, rhs: NSRegularExpression) -> Range<Int>? { return rhs /…~ lhs }
public func /…~(lhs: NSRegularExpression, rhs: String) -> Range<Int>? { return lhs /…~ (rhs, 0) }

/** func for an operator that returns the range of the specified capture for the first match in a string for a pattern */
public func /…~(lhs: (String, Int), rhs: NSRegularExpression) -> Range<Int>? { return rhs /…~ lhs }
public func /…~(lhs: NSRegularExpression, rhs: (String, Int)) -> Range<Int>? {
  return rhs.0.rangeForCapture(rhs.1, inFirstMatchFor: lhs)
}

/** func for an operator that returns the ranges of all matches in a string for a pattern */
public func /…≈(lhs: String, rhs: NSRegularExpression) -> [Range<Int>?] { return rhs /…≈ lhs }
public func /…≈(lhs: NSRegularExpression, rhs: String) -> [Range<Int>?] { return lhs /…≈ (rhs, 0) }

/** func for an operator that returns the ranges of the specified capture for all matches in a string for a pattern */
public func /…≈(lhs: (String, Int), rhs: NSRegularExpression) -> [Range<Int>?] { return rhs /…≈ lhs }
public func /…≈(lhs: NSRegularExpression, rhs: (String, Int)) -> [Range<Int>?] {
  return rhs.0.rangesForCapture(rhs.1, byMatching: lhs)
}


/** func for an operator that returns the specified capture for the first match in a string for a pattern */
public func /~(lhs: (String, Int), rhs: NSRegularExpression) -> String? { return rhs /~ lhs }
public func /~(lhs: NSRegularExpression, rhs: (String, Int)) -> String? {
  return rhs.0.substringForCapture(rhs.1, inFirstMatchFor: lhs)
}

/** func for an operator that creates a string by repeating a string multiple times */
public func *(lhs: String, var rhs: Int) -> String { var s = ""; while rhs-- > 0 { s += lhs }; return s }

prefix operator ~/ {}

/** func for an operator that creates a regular expression from a string */
public prefix func ~/(pattern: String) -> NSRegularExpression! { return pattern.toRegEx()! }

infix operator +⁈ { associativity left precedence 140 }

/** functions for combining a string with an optional string */
public func +⁈(lhs:String, rhs:String?) -> String? { if let r = rhs { return lhs + r } else { return nil } }
public func +⁈(lhs:String, rhs:String) -> String? { return lhs + rhs }
public func +⁈(lhs:String?, rhs:String?) -> String? { if let l = lhs { if let r = rhs { return l + r } }; return nil }

