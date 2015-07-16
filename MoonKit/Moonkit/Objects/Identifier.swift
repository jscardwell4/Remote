//
//  Identifier.swift
//  MoonKit
//
//  Created by Jason Cardwell on 7/16/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation


public struct Identifier: MutableSliceable {
  public private(set) var tags: [Tag] = [] { didSet { tags = filteredTags(tags) } }

  public var string: String { return Identifier.tagSeparator.join(tags) }

  public typealias Tag = String
  public static let tagSeparator = "-"

  public var startIndex: Int { return 0 }
  public var endIndex: Int { return tags.count }

  public subscript(idx: Int) -> Tag {
    get { return tags[idx] }
    set { tags[idx] = filteredTag(newValue) }
  }
  public subscript(bounds: Range<Int>) -> ArraySlice<Tag> {
    get { return tags[bounds] }
    set { tags[bounds] = ArraySlice(filteredTags(newValue)) }
  }

  /**
  filteredTag:

  - parameter tag: Tag

  - returns: Tag
  */
  private func filteredTag(tag: Tag) -> Tag { return tag.subbed(Identifier.tagSeparator, "\(Identifier.tagSeparator)") }

  /**
  filteredTags:

  - parameter tags: C

  - returns: [Tag]
  */
  private func filteredTags<C:CollectionType where C.Generator.Element == Tag>(tags: C) -> [Tag] {
    return tags.map { self.filteredTag($0) }
  }

  private init(withTags t: [Tag]) {
    self.init()
    tags = filteredTags(t)
  }

  public init() {}

  /**
  initialize with the type name of an object

  - parameter object: Any
  */
  public init(_ object: Any) { self.init(withTags: [typeName(object)]) }

  /**
  initialize with the type name of an object and a list of strings

  - parameter object: Any
  - parameter tags: Tag ...
  */
  public init(_ object: Any, _ tags: Tag ...) { self.init(withTags: [typeName(object)] + tags) }

  /**
  initialize from a list of strings

  - parameter tags: Tag ...
  */
  public init(_ tags: Tag ...) { self.init(withTags: tags) }

  /**
  initialize from a string

  - parameter string: String
  */
  public init(_ string: String) { self.init(withTags: Identifier.tagSeparator.split(string)) }

}

extension Identifier: ArrayLiteralConvertible {

  /**
  initialize from an array literal of strings

  - parameter elements: Tag
  */
  public init(arrayLiteral elements: Tag ...) { self.init(withTags: elements) }

}

extension Identifier: StringLiteralConvertible {

  /**
  initialize from a literal string

  - parameter value: String
  */
  public init(stringLiteral value: String) { self.init(withTags: Identifier.tagSeparator.split(value)) }

  /**
  initialize from a literal string

  - parameter value: String
  */
  public init(extendedGraphemeClusterLiteral value: String) { self.init(withTags: Identifier.tagSeparator.split(value)) }

  /**
  initialize from a literal string

  - parameter value: String
  */
  public init(unicodeScalarLiteral value: String) { self.init(withTags: Identifier.tagSeparator.split(value)) }

}

extension Identifier: Comparable {}
public func ==(lhs: Identifier, rhs: Identifier) -> Bool { return lhs.string == rhs.string }
public func <(lhs: Identifier, rhs: Identifier) -> Bool { return lhs.string < rhs.string }
