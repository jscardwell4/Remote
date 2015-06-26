//
//  RegularExpression.swift
//  MSKit
//
//  Created by Jason Cardwell on 3/24/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//
// Adapted from GitHub Gist 'mattt / regex.swift'

import Foundation

public struct RegularExpression {
  public var pattern: String? { return regex?.pattern }
  public var options: NSRegularExpressionOptions? { return regex?.options }

  public let regex: NSRegularExpression?

  /**
  initWithPattern:options:

  - parameter pattern: String
  - parameter options: NSRegularExpressionOptions = nil
  */
  public init(pattern: String, options: NSRegularExpressionOptions = NSRegularExpressionOptions(rawValue: 0)) {
    do {
      regex = try NSRegularExpression(pattern: pattern, options: options)
    } catch  {
      regex = nil
    }
  }

  /**
  match:options:

  - parameter string: String
  - parameter options: NSMatchingOptions = nil

  - returns: Bool
  */
  public func match(string: String, options: NSMatchingOptions = NSMatchingOptions(rawValue: 0)) -> Bool {
    return (regex?.numberOfMatchesInString(string,
                                   options: options,
                                     range: NSRange(0 ..< string.utf16.count)) ?? 0) != 0
  }
}

extension RegularExpression: StringLiteralConvertible {
  public init(stringLiteral value: String) { self = RegularExpression(pattern: value) }
  public init(extendedGraphemeClusterLiteral value: String) { self = RegularExpression(pattern: value) }
  public init(unicodeScalarLiteral value: String) { self = RegularExpression(pattern: value) }
}

public protocol RegularExpressionMatchable { func match(regex: RegularExpression) -> Bool }
