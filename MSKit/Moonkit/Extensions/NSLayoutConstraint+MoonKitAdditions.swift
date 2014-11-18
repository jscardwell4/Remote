//
//  NSLayoutConstraint+MoonKitAdditions.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/7/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

/**
createIdentifier:suffix:

:param: object Any
:param: suffix String? = nil

:returns: String
*/
public func createIdentifier(object: Any, _ suffix: String? = nil) -> String {
  return createIdentifier(object, suffix == nil ? nil : [suffix!])
}

/**
createIdentifier:suffix:

:param: object Any
:param: suffix [String]? = nil

:returns: String
*/
public func createIdentifier(object: Any, _ suffix: [String]? = nil) -> String {
  let identifier = _stdlib_getDemangledTypeName(object)
  return suffix == nil ? identifier : "-".join([identifier] + suffix!)
}

extension NSLayoutConstraint {

  /**
  dictionaryFromFormat:

  :param: format String

  :returns: [String:String]
  */
  public class func dictionaryFromFormat(format: String) -> [String:String] {
    let name = "[a-zA-Z_][-_a-zA-Z0-9]*"
    let attribute = "[a-z]+[A-Z]?"
    let priority = "[0-9]{1,4}"
    let metric = "(?:\(name))|(?:[-0-9]+\\.?[0-9]*)"
    let regex = ("(?:'([^']+)'[ ]+)?" +                   // identifier
                 "(\(name))\\.(\(attribute))" +           // first item and attribute
                 "[ ]+([=≤≥]+)" +                         // relation
                 "(?:[ ]+(\(name))\\.(\(attribute)))?" +  // second item and attribute
                 "(?:[ ]+[x*][ ]+(\(metric)))?" +         // multiplier if present
                 "(?:[ ]+([+-])?[ ]*(\(metric)))?" +      // constant if present
                 "(?:[ ]+@(\(priority)))?")               // priority if present
    let keys = ["identifier",
                "firstItem",
                "firstAttribute",
                "relation",
                "secondItem",
                "secondAttribute",
                "multiplier",
                "constantOperator",
                "constant",
                "priority"]
    var result: [String:String] = [:]
    for (key, value) in format.dictionaryOfCapturedStringsByMatchingFirstOccurrenceOfRegex(regex, keys: keys) {
      if let k = key as? String {
        if let v = value as? String {
          result[k] = v
        }
      }
    }
    return result
  }

}

extension NSLayoutAttribute {

  /**
  initWithPseudoname:

  :param: pseudoname String
  */
  public init(pseudoname: String?) {
    switch (pseudoname ?? "nil") {
      case "left":                 self = .Left
      case "right":                self = .Right
      case "top":                  self = .Top
      case "bottom":               self = .Bottom
      case "leading":              self = .Leading
      case "trailing":             self = .Trailing
      case "width":                self = .Width
      case "height":               self = .Height
      case "centerX":              self = .CenterX
      case "centerY":              self = .CenterY
      case "baseline":             self = .Baseline
      case "firstBaseline":        self = .FirstBaseline
      case "leftMargin":           self = .LeftMargin
      case "rightMargin":          self = .RightMargin
      case "topMargin":            self = .TopMargin
      case "bottomMargin":         self = .BottomMargin
      case "leadingMargin":        self = .LeadingMargin
      case "trailingMargin":       self = .TrailingMargin
      case "centerXWithinMargins": self = .CenterXWithinMargins
      case "centerYWithinMargins": self = .CenterYWithinMargins
      default:                     self = .NotAnAttribute
    }
  }

}

extension NSLayoutRelation {

  /**
  initWithPseudoname:

  :param: pseudoname String?
  */
  public init(pseudoname: String?) {
    switch (pseudoname ?? "=") {
      case "≤": self = .LessThanOrEqual
      case "≥": self = .GreaterThanOrEqual
      default:  self = .Equal
    }
  }

}
