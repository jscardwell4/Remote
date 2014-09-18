//
//  String+MoonKitAdditions.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/15/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

extension String {

  /**
  extendWith:

  :param: string String
  :returns: String
  */
  func extendWith(string: String) -> String { return self + string }


  /**
  matchFirst:

  :param: pattern String
  :returns: [String?]
  */
  func matchFirst(pattern: String) -> [String?] { return matchFirst(~/pattern) }


  /**
  matchFirst:

  :param: regex NSRegularExpression
  :returns: [String?]
  */
  func matchFirst(regex: NSRegularExpression) -> [String?] {

  	let match: NSTextCheckingResult? = regex.firstMatchInString(self,
                                                        options: nil,
                                                          range:NSRange(location: 0,
                                                         length: (self as NSString).length))
  	var captures: [String?] = [String?](count: regex.numberOfCaptureGroups, repeatedValue: nil)
  	for i in 0..<regex.numberOfCaptureGroups {
      if let range = match?.rangeAtIndex(i) {
        if range.location != NSNotFound {
          captures[i] = (self as NSString).substringWithRange(range)
        }
      }
  	}
    return captures
  }

}

// pattern matching operator
func ~=(lhs: NSRegularExpression, rhs: String) -> Bool {
  return lhs.numberOfMatchesInString(rhs,
                             options: nil,
                               range: NSRange(location: 0,  length: (rhs as NSString).length)) > 0
}
func ~=(lhs: String, rhs: NSRegularExpression) -> Bool { return rhs ~= lhs }


prefix operator ~/ {}

prefix func ~/(pattern: String) -> NSRegularExpression! {
  var error: NSError? = nil
  let regex = NSRegularExpression(pattern: pattern, options: nil, error: &error)
  if error != nil { printError(error!, message: "failed to create regular expression object") }
  return regex
}

infix operator +⁈ { associativity left precedence 140 }

func +⁈(lhs:String, rhs:String?) -> String? { if let r = rhs { return lhs + r } else { return nil } }
func +⁈(lhs:String, rhs:String) -> String? { return lhs + rhs }
func +⁈(lhs:String?, rhs:String?) -> String? { if let l = lhs { if let r = rhs { return l + r } }; return nil }

