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

  :param: pattern String
  :param: options NSRegularExpressionOptions = nil
  */
  public init(pattern: String, options: NSRegularExpressionOptions = nil, error: NSErrorPointer = nil) {
    regex = NSRegularExpression(pattern: pattern, options: options, error: error)
  }

  /**
  match:options:

  :param: string String
  :param: options NSMatchingOptions = nil

  :returns: Bool
  */
  public func match(string: String, options: NSMatchingOptions = nil) -> Bool {
    return (regex?.numberOfMatchesInString(string,
                                   options: options,
                                     range: NSRange(0 ..< count(string.utf16))) ?? 0) != 0
  }
}

extension RegularExpression: StringLiteralConvertible {
  public init(stringLiteral value: String) { self = RegularExpression(pattern: value) }
  public init(extendedGraphemeClusterLiteral value: String) { self = RegularExpression(pattern: value) }
  public init(unicodeScalarLiteral value: String) { self = RegularExpression(pattern: value) }
}

public protocol RegularExpressionMatchable { func match(regex: RegularExpression) -> Bool }
