//
//  ModelIndex.swift
//  Remote
//
//  Created by Jason Cardwell on 4/16/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit

@objc public class ModelIndex: RawRepresentable, JSONValueConvertible, JSONValueInitializable, StringValueConvertible, CustomStringConvertible {
  public let pathIndex: PathIndex?
  public let uuidIndex: UUIDIndex?
  public init(_ index: PathIndex) { pathIndex = index; uuidIndex = nil }
  public init(_ index: UUIDIndex) { pathIndex = nil; uuidIndex = index }
  public convenience required init(rawValue: String) { self.init(rawValue) }
  public convenience init(_ string: String) {
    if let uuidIndex = UUIDIndex(rawValue: string) { self.init(uuidIndex) }
    else { let pathIndex = PathIndex(rawValue: string); self.init(pathIndex) }
  }
  public var stringValue: String { return rawValue }
  public var rawValue: String { return uuidIndex != nil ? uuidIndex!.rawValue : pathIndex?.rawValue ?? "" }
  public var jsonValue: JSONValue { return rawValue.jsonValue }
  public convenience required init?(_ jsonValue: JSONValue?) {
    if let s = String(jsonValue) {
      self.init(s)
    } else {
      self.init("")
      return nil
    }
  }
  public var description: String { return rawValue }
}

/**
A simple structure that serves as a glorified file path for use as an index.

i.e. 'Sony/AV Receiver/Volume Up' would be an index for the code named 'Volume Up'
in the code set named 'AV Receiver' for the manufacturer named 'Sony'
*/

// MARK: - PathIndex

/**
A simple structure that serves as a glorified file path for use as an index.

i.e. 'Sony/AV Receiver/Volume Up' would be an index for the code named 'Volume Up'
in the code set named 'AV Receiver' for the manufacturer named 'Sony'
*/
public struct PathIndex: RawRepresentable {

  private(set) public var rawValue: String

  public init(_ value: String) { rawValue = value }
  public init(rawValue: String) { self.rawValue = rawValue }

  /**
  transformComponents:

  - parameter transform: (inout [String]) -> Void
  */
  private mutating func transformComponents(transform: (inout [String]) -> Void) {
    var components = pathComponents
    transform(&components)
    rawValue = "/".join(components)
  }

  /**
  modifyComponents:

  - parameter modify: (inout [String]) -> String

  - returns: String
  */
  private mutating func modifyComponents(modify: (inout [String]) -> String) -> String {
    var components = pathComponents
    let result = modify(&components)
    rawValue = "/".join(components)
    return result
  }

  public var pathComponents: [String] { return rawValue.pathComponents }
  public var isEmpty: Bool { return pathComponents.isEmpty }
  public var count: Int { return pathComponents.count }
  public var first: String? { return pathComponents.first }
  public var last: String? { return pathComponents.last }

  /**
  initWithArray:

  - parameter array: [String]
  */
  public init?(array: [String]) {
    self.init("/".join(array.filter({!$0.isEmpty})))
  }

  /**
  append:

  - parameter component: String
  */
  public mutating func append(component: String) { rawValue += "/" + component }

  /**
  removeLast

  - returns: String
  */
  public mutating func removeLast() -> String {
    return modifyComponents({(inout components: [String]) -> String in components.removeLast()})
  }

  /**
  insert:atIndex:

  - parameter component: String
  - parameter i: Int
  */
  public mutating func insert(component: String, atIndex i: Int) {
    transformComponents({(inout components:[String]) -> Void in components.insert(component, atIndex: i)})
  }

  /**
  removeAtIndex:

  - parameter index: Int

  - returns: String
  */
  public mutating func removeAtIndex(index: Int) -> String {
    return modifyComponents({ (inout components: [String]) -> String in components.removeAtIndex(index) })
  }

  /**
  replaceRange:with:

  - parameter subRange: Range<Int>
  - parameter newElements: [String]
  */
  public mutating func replaceRange(subRange: Range<Int>, with newElements: [String]) {
    transformComponents({
      (inout components:[String]) -> Void in
      components.replaceRange(subRange, with: newElements)
    })
  }

  /**
  splice:atIndex:

  - parameter newElements: [String]
  - parameter i: Int
  */
  public mutating func splice(newElements: [String], atIndex i: Int) {
    transformComponents({
      (inout components: [String]) -> Void in
      components.splice(newElements, atIndex: i)
    })
  }

  /**
  removeRange:

  - parameter subRange: Range<Int>
  */
  public mutating func removeRange(subRange: Range<Int>) {
    transformComponents({(inout components:[String]) -> Void in components.removeRange(subRange)})
  }

}

// MARK: Printable, DebugPrintable
extension PathIndex: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { return rawValue }
  public var debugDescription: String { return pathComponents.debugDescription }
}

// MARK: Sliceable
extension PathIndex: Sliceable {
  /**
  subscript:

  - parameter bounds: Range<Int>

  - returns: PathIndex
  */
  public subscript(bounds: Range<Int>) -> PathIndex { return PathIndex("/".join(pathComponents[bounds])) }
}

// MARK: MutableCollectionType
extension PathIndex: CollectionType, MutableCollectionType {

  public var startIndex: Int { return pathComponents.startIndex }
  public var endIndex: Int { return pathComponents.endIndex }

  /**
  subscript:

  - parameter i: Int

  - returns: String
  */
  public subscript(i: Int) -> String {
    get { return pathComponents[i] }
    mutating set { transformComponents { (inout components: [String]) -> Void in components[i] = newValue} }
  }

}

// MARK: SequenceType
extension PathIndex: SequenceType {
  /**
  generate

  - returns: IndexingGenerator<Array<String>>
  */
  public func generate() -> IndexingGenerator<Array<String>> { return pathComponents.generate() }
}

// MARK: Support for other operations
/**
Addition binary operator for two `PathIndex` objects

- parameter lhs: PathIndex
- parameter rhs: PathIndex

- returns: PathIndex
*/
public func +(lhs: PathIndex, rhs: PathIndex) -> PathIndex {
  return PathIndex("/".join(lhs.pathComponents + rhs.pathComponents))
}

/**
Addtion binary operator for a `PathIndex` and a `String`

- parameter lhs: PathIndex
- parameter rhs: String

- returns: PathIndex
*/
public func +(lhs: PathIndex, rhs: String) -> PathIndex {
  return lhs + PathIndex(rhs)
}

/**
Addition binary operator for an optional `PathIndex` with a non-optional `PathIndex`

- parameter lhs: PathIndex?
- parameter rhs: PathIndex

- returns: PathIndex
*/
public func +(lhs: PathIndex?, rhs: PathIndex) -> PathIndex {
  return lhs == nil ? rhs : lhs! + rhs
}

/**
Addition binary operator for an optional `PathIndex` with and a `String`

- parameter lhs: PathIndex
- parameter rhs: String

- returns: PathIndex
*/
public func +(lhs: PathIndex?, rhs: String) -> PathIndex {
  return lhs + PathIndex(rhs)
}

/**
Addition unary operator for two `PathIndex` objects

- parameter lhs: PathIndex
- parameter rhs: PathIndex
*/
public func +=(inout lhs: PathIndex, rhs: PathIndex) {
  lhs.rawValue = "/".join(lhs.pathComponents + rhs.pathComponents)
}

/**
Addition unary operator for a `PathIndex` and a `String`

- parameter lhs: PathIndex
- parameter rhs: String
*/
public func +=(inout lhs: PathIndex, rhs: String) { lhs += PathIndex(rhs) }

// MARK: JSONValueConvertible
extension PathIndex: JSONValueConvertible {
  public var jsonValue: JSONValue { return rawValue.jsonValue }
}

// MARK: Hashable
extension PathIndex: Hashable { public var hashValue: Int { return rawValue.hashValue } }

// MARK: Equatable
extension PathIndex: Equatable {}
/**
Equatable support function

- parameter lhs: ModelIndex
- parameter rhs: ModelIndex

- returns: Bool
*/
public func ==(lhs: PathIndex, rhs: PathIndex) -> Bool { return lhs.rawValue == rhs.rawValue }

// MARK: - UUIDIndex

public struct UUIDIndex: RawRepresentable {


  private(set) public var rawValue: String

  public init?(_ value: String?) { if value != nil { self.init(rawValue: value!) } else { return nil } }

  public init?(rawValue: String) {
    if UUIDIndex.isValidRawValue(rawValue) { self.rawValue = rawValue }
    else { return nil }
  }

  /**
  isValidRawValue:

  - parameter rawValue: String

  - returns: Bool
  */
  static func isValidRawValue(rawValue: String) -> Bool {
    return rawValue ~= "[A-F0-9]{8}-(?:[A-F0-9]{4}-){3}[A-Z0-9]{12}"
  }
  
}

// MARK: Printable
extension UUIDIndex: CustomStringConvertible {
  public var description: String { return rawValue }
}

// MARK: JSONValueConvertible
extension UUIDIndex: JSONValueConvertible {
  public var jsonValue: JSONValue { return rawValue.jsonValue }
}

// MARK: Hashable
extension UUIDIndex: Hashable { public var hashValue: Int { return rawValue.hashValue } }

// MARK: Equatable
extension UUIDIndex: Equatable {}
/**
Equatable support function

- parameter lhs: ModelIndex
- parameter rhs: ModelIndex

- returns: Bool
*/
public func ==(lhs: UUIDIndex, rhs: UUIDIndex) -> Bool { return lhs.rawValue == rhs.rawValue }
