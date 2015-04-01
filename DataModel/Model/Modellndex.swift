//
//  ModelIndex.swift
//  Remote
//
//  Created by Jason Cardwell on 3/24/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit

/**
A simple structure that serves as a glorified file path for use as an index.

i.e. 'Sony/AV Receiver/Volume Up' would be an index for the code named 'Volume Up'
in the code set named 'AV Receiver' for the manufacturer named 'Sony'
*/
@objc public class ModelIndex: NSObject, RawRepresentable {

  private(set) public var rawValue: String

  private class func isValidRawValue(rawValue: String) -> Bool { return true }

  /**
  initWithRawValue:

  :param: rawValue String
  */
  public required init?(rawValue: String) {
    self.rawValue = rawValue
    super.init()
    if !self.dynamicType.isValidRawValue(rawValue) { return nil }
  }

  /**
  init:

  :param: value String
  */
  public convenience init?(_ value: String) { self.init(rawValue: value) }

  /**
  initWithJSONValue:

  :param: JSONValue String
  */
  public convenience required init?(JSONValue: String) { self.init(rawValue: JSONValue) }

}

// MARK: JSONValueConvertible
extension ModelIndex: JSONValueConvertible {
  public var JSONValue: String { return rawValue }
}

// MARK: JSONExport
extension ModelIndex: JSONExport {
  public var JSONObject: AnyObject { return JSONValue }
  public var JSONString: String { return JSONObject.JSONString }
}
extension ModelIndex: JSONExport {}

// MARK: Equatable
extension ModelIndex: Equatable {}
/**
Equatable support function

:param: lhs ModelIndex
:param: rhs ModelIndex

:returns: Bool
*/
public func ==(lhs: ModelIndex, rhs: ModelIndex) -> Bool { return lhs.rawValue == rhs.rawValue }

// MARK: - PathIndex

/**
A simple structure that serves as a glorified file path for use as an index.

i.e. 'Sony/AV Receiver/Volume Up' would be an index for the code named 'Volume Up'
in the code set named 'AV Receiver' for the manufacturer named 'Sony'
*/
@objc public final class PathIndex: ModelIndex {

  /**
  transformComponents:

  :param: transform (inout [String]) -> Void
  */
  private func transformComponents(transform: (inout [String]) -> Void) {
    var components = pathComponents
    transform(&components)
    rawValue = join("/", components)
  }

  /**
  modifyComponents:

  :param: modify (inout [String]) -> String

  :returns: String
  */
  private func modifyComponents(modify: (inout [String]) -> String) -> String {
    var components = pathComponents
    let result = modify(&components)
    rawValue = join("/", components)
    return result
  }

  public var pathComponents: [String] { return rawValue.pathComponents }
  public var isEmpty: Bool { return pathComponents.isEmpty }
  public var count: Int { return pathComponents.count }
  public var first: String? { return pathComponents.first }
  public var last: String? { return pathComponents.last }

  /**
  initWithArray:

  :param: array [String]
  */
  public convenience init?(array: [String]) {
    self.init("/".join(array.filter({!$0.isEmpty})))
  }

  /**
  append:

  :param: component String
  */
  public func append(component: String) { rawValue += "/" + component }

  /**
  removeLast

  :returns: String
  */
  public func removeLast() -> String {
    return modifyComponents({(inout components: [String]) -> String in components.removeLast()})
  }

  /**
  insert:atIndex:

  :param: component String
  :param: i Int
  */
  public func insert(component: String, atIndex i: Int) {
    transformComponents({(inout components:[String]) -> Void in components.insert(component, atIndex: i)})
  }

  /**
  removeAtIndex:

  :param: index Int

  :returns: String
  */
  public func removeAtIndex(index: Int) -> String {
    return modifyComponents({ (inout components: [String]) -> String in components.removeAtIndex(index) })
  }

  /**
  replaceRange:with:

  :param: subRange Range<Int>
  :param: newElements [String]
  */
  public func replaceRange(subRange: Range<Int>, with newElements: [String]) {
    transformComponents({
      (inout components:[String]) -> Void in
      components.replaceRange(subRange, with: newElements)
    })
  }

  /**
  splice:atIndex:

  :param: newElements [String]
  :param: i Int
  */
  public func splice(newElements: [String], atIndex i: Int) {
    transformComponents({
      (inout components: [String]) -> Void in
      components.splice(newElements, atIndex: i)
    })
  }

  /**
  removeRange:

  :param: subRange Range<Int>
  */
  public func removeRange(subRange: Range<Int>) {
    transformComponents({(inout components:[String]) -> Void in components.removeRange(subRange)})
  }

}

// MARK: Printable, DebugPrintable
extension PathIndex: Printable, DebugPrintable {
  public override var description: String { return rawValue }
  public  override var debugDescription: String { return pathComponents.debugDescription }
}

// MARK: Sliceable
extension PathIndex: Sliceable {
  /**
  subscript:

  :param: bounds Range<Int>

  :returns: PathIndex
  */
  public subscript(bounds: Range<Int>) -> PathIndex { return PathIndex("/".join(pathComponents[bounds]))! }
}

// MARK: MutableCollectionType
extension PathIndex: MutableCollectionType {

  public var startIndex: Int { return pathComponents.startIndex }
  public var endIndex: Int { return pathComponents.endIndex }

  /**
  subscript:

  :param: i Int

  :returns: String
  */
  public subscript(i: Int) -> String {
    get { return pathComponents[i] }
    set { transformComponents { (inout components: [String]) -> Void in components[i] = newValue} }
  }

}

// MARK: SequenceType
extension PathIndex: SequenceType {
  /**
  generate

  :returns: IndexingGenerator<Array<String>>
  */
  public func generate() -> IndexingGenerator<Array<String>> { return pathComponents.generate() }
}

// MARK: Support for other operations
/**
Addition binary operator for two `PathIndex` objects

:param: lhs PathIndex
:param: rhs PathIndex

:returns: PathIndex
*/
public func +(lhs: PathIndex, rhs: PathIndex) -> PathIndex {
  return PathIndex("/".join(lhs.pathComponents + rhs.pathComponents))!
}

/**
Addtion binary operator for a `PathIndex` and a `String`

:param: lhs PathIndex
:param: rhs String

:returns: PathIndex
*/
public func +(lhs: PathIndex, rhs: String) -> PathIndex {
  if let rhsAsIndex = PathIndex(rhs) { return lhs + rhsAsIndex } else { return lhs }
}

/**
Addition unary operator for two `PathIndex` objects

:param: lhs PathIndex
:param: rhs PathIndex
*/
public func +=(inout lhs: PathIndex, rhs: PathIndex) {
  lhs.rawValue = join("/", lhs.pathComponents + rhs.pathComponents)
}

/**
Addition unary operator for a `PathIndex` and a `String`

:param: lhs PathIndex
:param: rhs String
*/
public func +=(inout lhs: PathIndex, rhs: String) { if let rhsAsIndex = PathIndex(rhs) { lhs += rhsAsIndex } }

// MARK: - UUIDIndex

public final class UUIDIndex: ModelIndex {

  /**
  isValidRawValue:

  :param: rawValue String

  :returns: Bool
  */
  override public class func isValidRawValue(rawValue: String) -> Bool {
    return rawValue ~= "[A-F0-9]{8}-(?:[A-F0-9]{4}-){3}[A-Z0-9]{12}"
  }

}
