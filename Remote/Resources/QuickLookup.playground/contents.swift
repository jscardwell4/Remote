// Playground - noun: a place where people can play

import Foundation
import CoreData

struct Index: StringLiteralConvertible, RawRepresentable, MutableCollectionType, Sliceable, Printable, DebugPrintable,
  _DestructorSafeContainer, StringInterpolationConvertible
{
  private(set) var rawValue: String {
    get { return join("/", components) }
    set { components = newValue.pathComponents }
  }

  private var components: [String] = []
  init(_ value: String) { components = value.pathComponents; rawValue = value }
  init(rawValue: String) { self = Index(rawValue) }
  init(stringLiteral value: String) { self = Index(value) }
  init(extendedGraphemeClusterLiteral value: String) { self = Index(value) }
  init(unicodeScalarLiteral value: String) { self = Index(value) }
  init(stringInterpolation strings: Index...) {
    components = reduce(strings, [String](), { $0 + $1.components })
  }
  init<T>(stringInterpolationSegment expr: T) {
    println(expr)
    let exprString = toString(expr)
    if exprString != "/" { rawValue = exprString }
  }
  var isEmpty: Bool { return components.isEmpty }
  var count: Int { return components.count }
  var first: String? { return components.first }
  var last: String? { return components.last }

  func generate() -> IndexingGenerator<Array<String>> { return components.generate() }
  var startIndex: Int { return components.startIndex }
  var endIndex: Int { return components.endIndex }
  subscript(i: Int) -> String { get { return components[i] } set { components[i] = newValue } }
  subscript(bounds: Range<Int>) -> Array<String>.SubSlice { return components[bounds] }
  mutating func append(component: String) { components.append(component) }
  mutating func removeLast() -> String { return components.removeLast() }
  mutating func insert(component: String, atIndex i: Int) { components.insert(component, atIndex: i) }
  mutating func removeAtIndex(index: Int) -> String { return components.removeAtIndex(index) }
  var description: String { return components.description }
  var debugDescription: String { return components.debugDescription }
  mutating func replaceRange(subRange: Range<Int>, with newElements: [String]) {
    components.replaceRange(subRange, with: newElements)
  }
  mutating func splice(newElements: [String], atIndex i: Int) { components.splice(newElements, atIndex: i) }
  mutating func removeRange(subRange: Range<Int>) { components.removeRange(subRange) }
}

var idx: Index = "Sony/AV Receiver/Volume Up"
idx.first
idx.last
idx[1]
idx.removeLast()
idx
let s1 = "Sony"
let s2 = "AV Receiver"
let s3 = "Volume Up"
let idx2: Index = "\(s1)/\(s2)/\(s3)"