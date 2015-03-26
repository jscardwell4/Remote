// Playground - noun: a place where people can play

import Foundation
//import MoonKit

public class ModelIndex: RawRepresentable, StringLiteralConvertible {
  private(set) public var rawValue: String
  public required init?(rawValue: String) { self.rawValue = rawValue }
  public init(_ value: String) { rawValue = value }
  public required init(stringLiteral value: String) { rawValue = value }
  public required init(extendedGraphemeClusterLiteral value: String) { rawValue = value }
  public required init(unicodeScalarLiteral value: String) { rawValue = value }
}

// MARK: - PathModelIndex
/**
A simple structure that serves as a glorified file path for use as an index.

i.e. 'Sony/AV Receiver/Volume Up' would be an index for the code named 'Volume Up'
in the code set named 'AV Receiver' for the manufacturer named 'Sony'
*/
@objc public final class PathModelIndex: ModelIndex {

  private func transformComponents(transform: (inout [String]) -> Void) {
    var components = rawValue.pathComponents
    transform(&components)
    rawValue = join("/", components)
  }
  private func modifyComponents(modify: (inout [String]) -> String) -> String {
    var components = rawValue.pathComponents
    let result = modify(&components)
    rawValue = join("/", components)
    return result
  }

  public var isEmpty: Bool { return rawValue.pathComponents.isEmpty }
  public var count: Int { return rawValue.pathComponents.count }
  public var first: String? { return rawValue.pathComponents.first }
  public var last: String? { return rawValue.pathComponents.last }


  public func append(component: String) { rawValue += "/" + component }
  public func removeLast() -> String {
    return modifyComponents({ (inout components: [String]) -> String in components.removeLast() })
  }
  public func insert(component: String, atIndex i: Int) {
    transformComponents({(inout components:[String]) -> Void in components.insert(component, atIndex: i)})
  }
  public func removeAtIndex(index: Int) -> String {
    return modifyComponents({ (inout components: [String]) -> String in components.removeAtIndex(index) })
  }
  public func replaceRange(subRange: Range<Int>, with newElements: [String]) {
    transformComponents({(inout components:[String]) -> Void in components.replaceRange(subRange, with: newElements)})
  }
  public func splice(newElements: [String], atIndex i: Int) {
    transformComponents({(inout components:[String]) -> Void in components.splice(newElements, atIndex: i)})
  }
  public func removeRange(subRange: Range<Int>) {
    transformComponents({(inout components:[String]) -> Void in components.removeRange(subRange)})
  }
}

// MARK: StringInterpolationConvertible
extension PathModelIndex: StringInterpolationConvertible {
  public convenience init(stringInterpolation strings: PathModelIndex...) {
    self.init("/".join(reduce(strings, [String](), { $0 + $1.rawValue.pathComponents })))
  }
  public convenience init<T>(stringInterpolationSegment expr: T) {
    let exprString = toString(expr)
    self.init(exprString != "/" ? exprString : "")
  }
}

// MARK: Printable, DebugPrintable
extension PathModelIndex: Printable, DebugPrintable {
  public var description: String { return rawValue }
  public var debugDescription: String { return rawValue.pathComponents.debugDescription }
}

// MARK: Sliceable
extension PathModelIndex: Sliceable {
  public subscript(bounds: Range<Int>) -> PathModelIndex { return PathModelIndex("/".join(rawValue.pathComponents[bounds])) }
}

// MARK: MutableCollectionType
extension PathModelIndex: MutableCollectionType {
  public var startIndex: Int { return rawValue.pathComponents.startIndex }
  public var endIndex: Int { return rawValue.pathComponents.endIndex }
  public subscript(i: Int) -> String {
    get { return rawValue.pathComponents[i] }
    set { transformComponents { (inout components: [String]) -> Void in components[i] = newValue} }
  }
}

// MARK: SequenceType
extension PathModelIndex: SequenceType {
  public func generate() -> IndexingGenerator<Array<String>> { return rawValue.pathComponents.generate() }
}

// MARK: Equatable
extension PathModelIndex: Equatable {}
public func ==(lhs: PathModelIndex, rhs: PathModelIndex) -> Bool { return lhs.rawValue == rhs.rawValue }

// MARK: Support for other operations
public func +(lhs: PathModelIndex, rhs: PathModelIndex) -> PathModelIndex {
  return PathModelIndex("/".join(lhs.rawValue.pathComponents + rhs.rawValue.pathComponents))
}
public func +=(inout lhs: PathModelIndex, rhs: PathModelIndex) {
  lhs.rawValue = join("/", lhs.rawValue.pathComponents + rhs.rawValue.pathComponents)
}

public final class UUIDModelIndex: ModelIndex, StringInterpolationConvertible {
  public required init?(rawValue: String) {
    super.init(rawValue: rawValue)
    if !(rawValue ~= "[A-F0-9]{8}-(?:[A-F0-9]{4}-){3}[A-Z0-9]{12}") { return nil }
  }

  public required init(stringLiteral value: String) {
    super.init(stringLiteral: value)
  }

  public required init(extendedGraphemeClusterLiteral value: String) {
      super.init(extendedGraphemeClusterLiteral: value)
  }

  public required init(unicodeScalarLiteral value: String) {
      super.init(unicodeScalarLiteral: value)
  }

  public required init(stringInterpolation strings: UUIDModelIndex...) {
    super.init(reduce(strings, "", { $0 + $1.rawValue}))
  }
  public required init<T>(stringInterpolationSegment expr: T) {
    super.init(toString(expr))
  }
}
