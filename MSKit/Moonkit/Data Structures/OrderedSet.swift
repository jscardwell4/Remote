//
//  OrderedSet.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/28/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation

public struct OrderedSet<T:Equatable> : MutableCollectionType, Sliceable {

  private var storage: [T] { didSet { unique(&storage) } }

  public typealias Element = T

  public var startIndex: Int { return storage.startIndex }
  public var endIndex: Int { return storage.endIndex }

  /**
  subscript:

  :param: index Int

  :returns: T
  */
  public subscript (index: Int) -> T {
    get { return storage[index] }
    set { if !contains(storage, newValue) { storage[index] = newValue } }
  }

  /**
  generate

  :returns: IndexingGenerator<[T]>
  */
  public func generate() -> IndexingGenerator<[T]> { return storage.generate() }

  public typealias SubSlice = Slice<T>

  /**
  subscript:

  :param: subRange Range<Int>

  :returns: Slice<T>
  */
  public subscript (subRange: Range<Int>) -> Slice<T> { return storage[subRange] }

  /**
  init:

  :param: buffer _ArrayBuffer<T>
  */
  public init(_ buffer: _ArrayBuffer<T>) { storage = [T](buffer) }


  /** init */
  public init() { storage = [] }

  public init(array: [T]) { storage = array }

  /**
  init:

  :param: s S
  */
  public init<S : SequenceType where S.Generator.Element == T>(_ s: S) { storage = [T](s) }

  public var count: Int { return storage.count }
  public var capacity: Int { return storage.capacity }
  public var isEmpty: Bool { return storage.isEmpty }
  public var first: T? { return storage.first }
  public var last: T? { return storage.last }

  public var arrayValue: [T] { return storage }

  /**
  reserveCapacity:

  :param: minimumCapacity Int
  */
  public mutating func reserveCapacity(minimumCapacity: Int) { storage.reserveCapacity(minimumCapacity) }

  /**
  append:

  :param: newElement T
  */
  public mutating func append(newElement: T) { if storage ∌ newElement { storage.append(newElement) } }

  /**
  extend:

  :param: elements S
  */
  public mutating func extend<S : SequenceType where S.Generator.Element == T>(elements: S) {
    storage.extend(elements.generate()⭆.filter { self.storage ∌ $0 })
  }

  /**
  removeLast

  :returns: T
  */
  public mutating func removeLast() -> T { return storage.removeLast() }

  /**
  insert:atIndex:

  :param: newElement T
  :param: i Int
  */
  public mutating func insert(newElement: T, atIndex i: Int) {
    if storage ∌ newElement { storage.insert(newElement, atIndex: i) }
  }

  /**
  removeAtIndex:

  :param: index Int

  :returns: T
  */
  public mutating func removeAtIndex(index: Int) -> T { return storage.removeAtIndex(index) }

  /**
  removeAll:

  :param: keepCapacity Bool = false
  */
  public mutating func removeAll(keepCapacity: Bool = false) { storage.removeAll(keepCapacity: keepCapacity) }

  /**
  join:

  :param: elements S

  :returns: [T]
  */
  public func join<S : SequenceType where S.Generator.Element == T>(elements: S) -> [T] { return storage.join(elements) }

  /**
  reduce:combine:

  :param: initial U
  :param: combine (U, T) -> U

  :returns: U
  */
  public func reduce<U>(initial: U, combine: (U, T) -> U) -> U {
    return storage.reduce(initial, combine: combine)
  }

  /**
  sort:

  :param: isOrderedBefore  (T, T) -> Bool
  */
  public mutating func sort(isOrderedBefore:  (T, T) -> Bool) {
    storage.sort(isOrderedBefore)
  }

  /**
  sorted:

  :param: isOrderedBefore (T, T) -> Bool

  :returns: [T]
  */
  public func sorted(isOrderedBefore: (T, T) -> Bool) -> [T] {
    return storage.sorted(isOrderedBefore)
  }

  /**
  map:

  :param: transform (T) -> U

  :returns: [U]
  */
  public func map<U>(transform: (T) -> U) -> [U] { return storage.map(transform) }

  /**
  reverse

  :returns: [T]
  */
  public func reverse() -> [T] { return storage.reverse() }

  /**
  filter:

  :param: includeElement (T) -> Bool

  :returns: [T]
  */
  public func filter(includeElement: (T) -> Bool) -> OrderedSet<T>{ return OrderedSet<T>(storage.filter(includeElement)) }

  /**
  replaceRange:with:

  :param: subRange Range<Int>
  :param: elements C
  */
  public mutating func replaceRange<C : CollectionType where C.Generator.Element == T>(subRange: Range<Int>, with elements: C) {
    storage.replaceRange(subRange, with: elements)
    unique(&storage)
  }

  /**
  splice:atIndex:

  :param: elements S
  :param: i Int
  */
  public mutating func splice<S : CollectionType where S.Generator.Element == T>(elements: S, atIndex i: Int) {
    storage.splice(elements, atIndex: i)
    unique(&storage)
  }

  /**
  removeRange:

  :param: subRange Range<Int>
  */
  public mutating func removeRange(subRange: Range<Int>) { storage.removeRange(subRange) }


}

extension OrderedSet : ArrayLiteralConvertible {

  /**
  init:

  :param: elements T...
  */
  public init(arrayLiteral elements: T...) { storage = elements }

}

extension OrderedSet : Printable, DebugPrintable {
  public var description: String { return storage.description }
  public var debugDescription: String { return storage.debugDescription }
}

/**
subscript:rhs:

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>

:returns: OrderedSet<T>
*/
public func +<T:Equatable>(lhs: OrderedSet<T>, rhs: OrderedSet<T>) -> OrderedSet<T> {
  return OrderedSet<T>(lhs.storage + rhs.storage)
}

/**
subscript:rhs:

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
*/
public func +=<T:Equatable>(inout lhs: OrderedSet<T>, rhs: OrderedSet<T>) { lhs.extend(rhs.storage) }

/**
Union set operator

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
:returns: OrderedSet<T>
*/
public func ∪<T:Equatable>(lhs: OrderedSet<T>, rhs: OrderedSet<T>) -> OrderedSet<T> { var u = lhs; u += rhs; return u }

/**
Minus set operator

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
:returns: OrderedSet<T>
*/
public func ∖<T:Equatable>(lhs: OrderedSet<T>, rhs: OrderedSet<T>) -> OrderedSet<T> {
  return OrderedSet<T>(lhs.filter { $0 ∉ rhs })
}

/**
Intersection set operator

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
:returns: OrderedSet<T>
*/
public func ∩<T:Equatable>(lhs: OrderedSet<T>, rhs: OrderedSet<T>) -> OrderedSet<T> {
  return (lhs ∪ rhs).filter{$0 ∈ lhs && $0 ∈ rhs}
}

/**
Union set operator which stores result in lhs

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
*/
public func ∪=<T:Equatable>(inout lhs: OrderedSet<T>, rhs: OrderedSet<T>) { lhs += rhs }

/**
Minus set operator which stores result in lhs

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
*/
public func ∖=<T:Equatable>(inout lhs: OrderedSet<T>, rhs: OrderedSet<T>) { lhs = lhs.filter { $0 ∉ rhs } }

/**
Intersection set operator which stores result in lhs

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
*/
public func ∩=<T:Equatable>(inout lhs: OrderedSet<T>, rhs: OrderedSet<T>) { lhs = (lhs ∪ rhs).filter {$0 ∈ lhs && $0 ∈ rhs} }

/**
Returns true if lhs is a subset of rhs

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
:returns: Bool
*/
public func ⊂<T:Equatable>(lhs: OrderedSet<T>, rhs: OrderedSet<T>) -> Bool { return lhs.filter {$0 ∉ rhs}.isEmpty }

/**
Returns true if lhs is not a subset of rhs

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
:returns: Bool
*/
public func ⊄<T:Equatable>(lhs: OrderedSet<T>, rhs: OrderedSet<T>) -> Bool { return !(lhs ⊂ rhs) }

/**
Returns true if rhs is a subset of lhs

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
:returns: Bool
*/
public func ⊃<T:Equatable>(lhs: OrderedSet<T>, rhs: OrderedSet<T>) -> Bool { return rhs ⊂ lhs }

/**
Returns true if rhs is not a subset of lhs

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
:returns: Bool
*/
public func ⊅<T:Equatable>(lhs: OrderedSet<T>, rhs: OrderedSet<T>) -> Bool { return !(lhs ⊃ rhs) }

/**
Returns true if rhs contains lhs

:param: lhs T
:param: rhs T
:returns: Bool
*/
public func ∈<T:Equatable>(lhs: T, rhs: OrderedSet<T>) -> Bool { return contains(rhs, lhs) }
public func ∈<T:Equatable>(lhs: T?, rhs: OrderedSet<T>) -> Bool { return lhs != nil && contains(rhs, lhs!) }

/**
Returns true if lhs contains rhs

:param: lhs T
:param: rhs T
:returns: Bool
*/
public func ∋<T:Equatable>(lhs: OrderedSet<T>, rhs: T) -> Bool { return rhs ∈ lhs }

/**
Returns true if rhs does not contain lhs

:param: lhs T
:param: rhs T
:returns: Bool
*/
public func ∉<T:Equatable>(lhs: T, rhs: OrderedSet<T>) -> Bool { return !(lhs ∈ rhs) }

/**
Returns true if lhs does not contain rhs

:param: lhs T
:param: rhs T
:returns: Bool
*/
public func ∌<T:Equatable>(lhs: OrderedSet<T>, rhs: T) -> Bool { return !(lhs ∋ rhs) }
