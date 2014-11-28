//
//  Set.swift
//  Remote
//
//  Created by Jason Cardwell on 11/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

public struct Set<T: Hashable>: Equatable {

  public typealias Element = T

  private var storage: [T: Bool] = [:]

  public var count: Int { return storage.count }

  public var isEmpty: Bool { return storage.isEmpty }

  public var array: [T] { return Array(storage.keys) }

  /**
  contains:

  :param: element T

  :returns: Bool
  */
  public func contains(element: T) -> Bool { return storage[element] ?? false }

  /**
  remove:

  :param: element T
  */
  public mutating func remove(element: T) { storage[element] = nil }

  /** init */
  public init() {}

  /**
  initWithMinimumCapacity:

  :param: minimumCapacity Int
  */
  public init(minimumCapacity: Int) { storage = [T: Bool](minimumCapacity: minimumCapacity) }

  /**
  init:

  :param: s S
  */
  public init<S : SequenceType where S.Generator.Element == T>(_ s: S) { extend(s) }

  /**
  append:

  :param: newElement T
  */
  public mutating func append(newElement: T) { storage[newElement] = true }

  /**
  extend:

  :param: elements S
  */
  public mutating func extend<S : SequenceType where S.Generator.Element == T>(elements: S) { apply(elements){self.append($0)} }

  /**
  removeAll:

  :param: keepCapacity Bool = false
  */
  public mutating func removeAll(keepCapacity: Bool = false) { storage.removeAll(keepCapacity: keepCapacity) }

  /**
  reduce:combine:

  :param: initial U
  :param: combine (U, T) -> U

  :returns: U
  */
  public func reduce<U>(initial: U, combine: (U, T) -> U) -> U { return array.reduce(initial, combine: combine) }

  /**
  sorted:

  :param: isOrderedBefore (T, T) -> Bool

  :returns: [T]
  */
  public func sorted(isOrderedBefore: (T, T) -> Bool) -> [T] { return array.sorted(isOrderedBefore) }

  /**
  map:

  :param: transform (T) -> U

  :returns: [U]
  */
  public func map<U: Equatable>(transform: (T) -> U) -> [U] { return array.map(transform) }

  /**
  filter:

  :param: includeElement (T) -> Bool

  :returns: [T]
  */
  public func filter(includeElement: (T) -> Bool) -> Set<T> { return Set<T>(array.filter(includeElement)) }

}
extension Set : ArrayLiteralConvertible {

  /**
  init:

  :param: elements T...
  */
  public init(arrayLiteral elements: T...) { extend(elements) }

}

extension Set: SequenceType {
  /**
  generate

  :returns: IndexingGenerator<[T]>
  */
  public func generate() -> IndexingGenerator<[T]> { return array.generate() }

}

extension Set : Printable, DebugPrintable {
    public var description: String { return array.description }
    public var debugDescription: String {  return array.debugDescription }
}

/**
subscript:rhs:

:param: lhs Set<T>
:param: rhs Set<T>

:returns: Bool
*/
public func ==<T>(lhs: Set<T>, rhs: Set<T>) -> Bool { return lhs.storage == rhs.storage }

/**
Union set operator

:param: lhs Set<T>
:param: rhs Set<T>

:returns: Set<T>
*/
public func ∪<T:Hashable>(lhs:Set<T>, rhs:Set<T>) -> Set<T> { return Set(lhs.array + rhs.array) }

/**
Minus set operator

:param: lhs Set<T>
:param: rhs Set<T>

:returns: Set<T>
*/
public func ∖<T:Hashable>(lhs:Set<T>, rhs:Set<T>) -> Set<T> { return lhs.filter { $0 ∉ rhs } }

/**
Intersection set operator

:param: lhs Set<T>
:param: rhs Set<T>

:returns: Set<T>
*/
public func ∩<T:Hashable>(lhs:Set<T>, rhs:Set<T>) -> Set<T> { return lhs.filter{$0 ∈ rhs} ∪ rhs.filter{$0 ∈ lhs} }

/**
Union set operator which stores result in lhs

:param: lhs Set<T>
:param: rhs Set<T>
*/
public func ∪=<T:Hashable>(inout lhs:Set<T>, rhs:Set<T>) { lhs.extend(rhs) }

/**
Minus set operator which stores result in lhs

:param: lhs Set<T>
:param: rhs Set<T>
*/
public func ∖=<T:Hashable>(inout lhs:Set<T>, rhs:Set<T>) { lhs = lhs.filter { $0 ∉ rhs } }

/**
Intersection set operator which stores result in lhs

:param: lhs Set<T>
:param: rhs Set<T>

:returns: Set<T>
*/
public func ∩=<T:Hashable>(inout lhs:Set<T>, rhs:Set<T>) { lhs = lhs ∖ rhs }

/**
Returns true if lhs is a subset of rhs

:param: lhs Set<T>
:param: rhs Set<T>

:returns: Bool
*/
public func ⊂<T:Hashable>(lhs:Set<T>, rhs:Set<T>) -> Bool { return lhs.filter {$0 ∉ rhs}.isEmpty }

/**
Returns true if lhs is not a subset of rhs

:param: lhs Set<T>
:param: rhs Set<T>

:returns: Bool
*/
public func ⊄<T:Hashable>(lhs:Set<T>, rhs:Set<T>) -> Bool { return !(lhs ⊂ rhs) }

/**
Returns true if rhs is a subset of lhs

:param: lhs Set<T>
:param: rhs Set<T>

:returns: Bool
*/
public func ⊃<T:Hashable>(lhs:Set<T>, rhs:Set<T>) -> Bool { return rhs ⊂ lhs }

/**
Returns true if rhs is not a subset of lhs

:param: lhs Set<T>
:param: rhs Set<T>

:returns: Bool
*/
public func ⊅<T:Hashable>(lhs:Set<T>, rhs:Set<T>) -> Bool { return !(rhs ⊃ lhs) }

/**
Returns true if rhs contains lhs

:param: lhs T
:param: rhs Set<T>
:returns: Bool
*/
public func ∈<T:Hashable>(lhs:T, rhs:Set<T>) -> Bool { return rhs.contains(lhs) }

/**
∈ function for an optional element

:param: lhs T?
:param: rhs Set<T>
:returns: Bool
*/
public func ∈<T:Hashable>(lhs:T?, rhs:Set<T>) -> Bool { return lhs != nil && lhs! ∈ rhs }

/**
Returns true if lhs contains rhs

:param: lhs Set<T>
:param: rhs T
:returns: Bool
*/
public func ∋<T:Hashable>(lhs:Set<T>, rhs:T) -> Bool { return rhs ∈ lhs }

/**
Returns true if rhs does not contain lhs

:param: lhs T
:param: rhs Set<T>
:returns: Bool
*/
public func ∉<T:Hashable>(lhs:T, rhs:Set<T>) -> Bool { return !(lhs ∈ rhs) }

/**
Returns true if lhs does not contain rhs

:param: lhs Set<T>
:param: rhs T
:returns: Bool
*/
public func ∌<T:Hashable>(lhs:Set<T>, rhs:T) -> Bool { return !(lhs ∋ rhs) }

