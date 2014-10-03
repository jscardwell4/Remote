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
  matchFirst:

  :param: regex NSRegularExpression
  :returns: [String?]
  */
  public func matchFirst(regex: NSRegularExpression) -> [String?] {
    let r = NSRange(location: 0, length: length)
  	let match: NSTextCheckingResult? = regex.firstMatchInString(self, options: nil, range: r)
  	var captures: [String?] = [String?](count: regex.numberOfCaptureGroups + 1, repeatedValue: nil)
  	for i in 0...regex.numberOfCaptureGroups {
      if let range = match?.rangeAtIndex(i) {
        if range.location != NSNotFound { captures[i] = self[range] }
      }
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

/** pattern matching operator */
public func ~=(lhs: NSRegularExpression, rhs: String) -> Bool {
  return lhs.numberOfMatchesInString(rhs,
                             options: nil,
                               range: NSRange(location: 0,  length: (rhs as NSString).length)) > 0
}
//public func ~=(lhs: String, rhs: NSRegularExpression) -> Bool { return rhs ~= lhs }

infix operator /~ { associativity left precedence 140 }
infix operator /≈ { associativity left precedence 140 }

/** func for an operator that returns the first matching substring for a pattern */
//public func /~(lhs: String, rhs: NSRegularExpression) -> String? { return rhs /~ lhs }
public func /~(lhs: NSRegularExpression, rhs: String) -> String? {
  var matchString: String?
  let range = NSRange(location: 0, length: rhs.length)
  if let match = lhs.firstMatchInString(rhs, options: nil, range: range) {
    let matchRange = match.rangeAtIndex(0)
    precondition(matchRange.location != NSNotFound, "didn't expect a match object with no overall match range")
    matchString = rhs[matchRange]
  }
  return matchString
}

/** func for an operator that returns an array of matching substrings for a pattern */
//public func /≈(lhs: String, rhs: NSRegularExpression) -> [String] { return rhs /≈ lhs }
public func /≈(lhs: NSRegularExpression, rhs: String) -> [String] {
  var substrings: [String] = []
  let range = NSRange(location: 0, length: rhs.length)
  if let matches = lhs.matchesInString(rhs, options: nil, range: range) as? [NSTextCheckingResult] {
    for match in matches {
      let matchRange = match.rangeAtIndex(0)
      precondition(matchRange.location != NSNotFound, "didn't expect a match object with no overall match range")
      let substring = rhs[matchRange]
      substrings.append(substring)
    }
  }
  return substrings
}

infix operator /…~ { associativity left precedence 140 }
infix operator /…≈ { associativity left precedence 140 }

//infix operator |≈| { associativity left precedence 140 }

/** func for an operator that returns the range of the first match in a string for a pattern */
//public func /…~(lhs: String, rhs: NSRegularExpression) -> Range<Int>? { return rhs /…~ lhs }
public func /…~(lhs: NSRegularExpression, rhs: String) -> Range<Int>? { return lhs /…~ (rhs, 0) }

/** func for an operator that returns the range of the specified capture for the first match in a string for a pattern */
//public func /…~(lhs: (String, Int), rhs: NSRegularExpression) -> Range<Int>? { return rhs /…~ lhs }
public func /…~(lhs: NSRegularExpression, rhs: (String, Int)) -> Range<Int>? {
  var range: Range<Int>?
  if let match = lhs.firstMatchInString(rhs.0, options: nil, range: NSRange(location: 0, length: rhs.0.length)) {
    if rhs.1 >= 0 && rhs.1 <= lhs.numberOfCaptureGroups {
      let matchRange = match.rangeAtIndex(rhs.1)
      if matchRange.location != NSNotFound {
        range = matchRange.location..<NSMaxRange(matchRange)
      }
    }
  }
  return range
}

/** func for an operator that returns the ranges of all matches in a string for a pattern */
//public func /…≈(lhs: String, rhs: NSRegularExpression) -> [Range<Int>?] { return rhs /…≈ lhs }
public func /…≈(lhs: NSRegularExpression, rhs: String) -> [Range<Int>?] { return lhs /…≈ (rhs, 0) }

/** func for an operator that returns the ranges of the specified capture for all matches in a string for a pattern */
//public func /…≈(lhs: (String, Int), rhs: NSRegularExpression) -> [Range<Int>?] { return rhs /…≈ lhs }
public func /…≈(lhs: NSRegularExpression, rhs: (String, Int)) -> [Range<Int>?] {
  var ranges: [Range<Int>?] = []
  if let matches = lhs.matchesInString(rhs.0, options: nil, range: NSRange(location: 0, length: rhs.0.length)) as? [NSTextCheckingResult] {
    for match in matches {
      var range: Range<Int>?
      if rhs.1 >= 0 && rhs.1 <= lhs.numberOfCaptureGroups {
        let matchRange = match.rangeAtIndex(rhs.1)
        if matchRange.location != NSNotFound {
          range = matchRange.location..<NSMaxRange(matchRange)
        }
      }
      ranges.append(range)
    }
  }
  return ranges
}


/** func for an operator that returns the specified capture for the first match in a string for a pattern */
//public func /~(lhs: (String, Int), rhs: NSRegularExpression) -> String? { return rhs /~ lhs }
public func /~(lhs: NSRegularExpression, rhs: (String, Int)) -> String? {
  let captures = rhs.0.matchFirst(lhs)
  return rhs.1 >= 0 && rhs.1 <= lhs.numberOfCaptureGroups ? captures[rhs.1] : nil
}

/** func for an operator that creates a string by repeating a string multiple times */
public func *(lhs: String, var rhs: Int) -> String { var s = ""; while rhs-- > 0 { s += lhs }; return s }

prefix operator ~/ {}

/** func for an operator that creates a regular expression from a string */
public prefix func ~/(pattern: String) -> NSRegularExpression! {
  var error: NSError? = nil
  let regex = NSRegularExpression(pattern: pattern, options: nil, error: &error)
  MSHandleError(error, message: "failed to create regular expression object")
  return regex
}

infix operator +⁈ { associativity left precedence 140 }

/** functions for combining a string with an optional string */
public func +⁈(lhs:String, rhs:String?) -> String? { if let r = rhs { return lhs + r } else { return nil } }
public func +⁈(lhs:String, rhs:String) -> String? { return lhs + rhs }
public func +⁈(lhs:String?, rhs:String?) -> String? { if let l = lhs { if let r = rhs { return l + r } }; return nil }

