// Playground - noun: a place where people can play

import Foundation
/**
A simple structure that serves as a glorified file path for use as an index.

i.e. 'Sony/AV Receiver/Volume Up' would be an index for the code named 'Volume Up'
in the code set named 'AV Receiver' for the manufacturer named 'Sony'
*/
@objc public final class ModelIndex {
  private var components: [String] = []
  public init(_ value: String) { components = value.pathComponents }
}

// MARK: Array like behavior
extension ModelIndex {

  public var isEmpty: Bool { return components.isEmpty }
  public var count: Int { return components.count }
  public var first: String? { return components.first }
  public var last: String? { return components.last }

  public func append(component: String) { components.append(component) }
  public func removeLast() -> String { return components.removeLast() }
  public func insert(component: String, atIndex i: Int) { components.insert(component, atIndex: i) }
  public func removeAtIndex(index: Int) -> String { return components.removeAtIndex(index) }
  public func replaceRange(subRange: Range<Int>, with newElements: [String]) {
    components.replaceRange(subRange, with: newElements)
  }
  public func splice(newElements: [String], atIndex i: Int) { components.splice(newElements, atIndex: i) }
  public func removeRange(subRange: Range<Int>) { components.removeRange(subRange) }
}

// MARK: RawRepresentable
extension ModelIndex: RawRepresentable {
  private(set) public var rawValue: String { get { return join("/", components) } set { components = newValue.pathComponents } }
  public convenience init(rawValue: String) { self.init(rawValue) }
}

// MARK: StringLiteralConvertible
extension ModelIndex: StringLiteralConvertible {
  public convenience init(stringLiteral value: String) { self.init(value) }
  public convenience init(extendedGraphemeClusterLiteral value: String) { self.init(value) }
  public convenience init(unicodeScalarLiteral value: String) { self.init(value) }
}

// MARK: StringInterpolationConvertible
extension ModelIndex: StringInterpolationConvertible {
  public convenience init(stringInterpolation strings: ModelIndex...) {
    self.init("/".join(reduce(strings, [String](), { $0 + $1.components })))
  }
  public convenience init<T>(stringInterpolationSegment expr: T) {
    let exprString = toString(expr)
    self.init(exprString != "/" ? exprString : "")
  }
}

// MARK: Printable, DebugPrintable
extension ModelIndex: Printable, DebugPrintable {
  public var description: String { return rawValue }
  public var debugDescription: String { return components.debugDescription }
}

// MARK: Sliceable
extension ModelIndex: Sliceable {
  public subscript(bounds: Range<Int>) -> ModelIndex { return ModelIndex("/".join(components[bounds])) }
}

// MARK: MutableCollectionType
extension ModelIndex: MutableCollectionType {
  public var startIndex: Int { return components.startIndex }
  public var endIndex: Int { return components.endIndex }
  public subscript(i: Int) -> String { get { return components[i] } set { components[i] = newValue } }
}

// MARK: SequenceType
extension ModelIndex: SequenceType {
  public func generate() -> IndexingGenerator<Array<String>> { return components.generate() }
}

// MARK: Equatable
extension ModelIndex: Equatable {}
public func ==(lhs: ModelIndex, rhs: ModelIndex) -> Bool { return lhs.rawValue == rhs.rawValue }

// MARK: Support for other operations
public func +(lhs: ModelIndex, rhs: ModelIndex) -> ModelIndex { return ModelIndex("/".join(lhs.components + rhs.components)) }
public func +=(inout lhs: ModelIndex, rhs: ModelIndex) { lhs.components.extend(rhs.components) }
