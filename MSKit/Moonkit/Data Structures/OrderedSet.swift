//
//  OrderedSet.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/28/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation

public struct OrderedSet<T:Equatable> : MutableCollectionType, Sliceable {

  private var storage: [T] {
    didSet {
      var s: [T] = []
      for e in storage { if !contains(s, e) { s.append(e) } }
      storage = s
    }
  }

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
  public init(_ buffer: _ArrayBuffer<T>) { storage = uniqued([T](buffer)) }


  /** init */
  public init() { storage = [] }

  /**
  init:

  :param: s S
  */
  public init<S : SequenceType where S.Generator.Element == T>(_ s: S) { storage = uniqued([T](s)) }

  public var count: Int      { return storage.count    }
  public var capacity: Int   { return storage.capacity }
  public var isEmpty: Bool   { return storage.isEmpty  }
  public var first: T?       { return storage.first    }
  public var last: T?        { return storage.last     }
  public var array: [T]      { return storage          }
  public var bridgedValue: NSOrderedSet? { return NSOrderedSet(array: storage._bridgeToObjectiveC()) }
  public var NSArrayValue: NSArray? {
    var elements: [NSObject] = []
    for element in storage {
      if let e = element as? NSObject {
        elements.append(e)
      }
    }
    return elements.count == storage.count ? NSArray(array: elements) : nil
  }

  public var NSSetValue: NSSet? { if let array = NSArrayValue { return NSSet(array: array) } else { return nil } }

  /**
  reserveCapacity:

  :param: minimumCapacity Int
  */
  public mutating func reserveCapacity(minimumCapacity: Int) { storage.reserveCapacity(minimumCapacity) }

  /**
  append:

  :param: newElement T
  */
  public mutating func append(newElement: T) { if !contains(storage, newElement) { storage.append(newElement) } }

  /**
  extend:

  :param: elements S
  */
  public mutating func extend<S : SequenceType where S.Generator.Element == T>(elements: S) {
    storage.extend(Array(elements).filter { !contains(self.storage, $0) })
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
    if !contains(storage, newElement) { storage.insert(newElement, atIndex: i) }
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
  public func reduce<U>(initial: U, combine: (U, T) -> U) -> U { return storage.reduce(initial, combine: combine) }

  /**
  sort:

  :param: isOrderedBefore  (T, T) -> Bool
  */
  public mutating func sort(isOrderedBefore:  (T, T) -> Bool) { storage.sort(isOrderedBefore) }

  /**
  sorted:

  :param: isOrderedBefore (T, T) -> Bool

  :returns: [T]
  */
  public func sorted(isOrderedBefore: (T, T) -> Bool) -> OrderedSet<T> { return OrderedSet(storage.sorted(isOrderedBefore)) }

  /**
  map:

  :param: transform (T) -> U

  :returns: [U]
  */
  public func map<U: Equatable>(transform: (T) -> U) -> OrderedSet<U> { return OrderedSet<U>(storage.map(transform)) }

  /**
  reverse

  :returns: [T]
  */
  public func reverse() -> OrderedSet<T> { return OrderedSet(storage.reverse()) }

  /**
  filter:

  :param: includeElement (T) -> Bool

  :returns: [T]
  */
  public func filter(includeElement: (T) -> Bool) -> OrderedSet<T> { return OrderedSet<T>(storage.filter(includeElement)) }

  /**
  replaceRange:with:

  :param: subRange Range<Int>
  :param: elements C
  */
  public mutating func replaceRange<C : CollectionType where C.Generator.Element == T>(subRange: Range<Int>, with elements: C) {
    var s = storage
    s.replaceRange(subRange, with: elements)
    storage = s
  }

  /**
  splice:atIndex:

  :param: elements S
  :param: i Int
  */
  public mutating func splice<S : CollectionType where S.Generator.Element == T>(elements: S, atIndex i: Int) {
    var s = storage
    s.splice(elements, atIndex: i)
    storage = s
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

extension OrderedSet : Equatable {}

/**
subscript:rhs:

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>

:returns: Bool
*/
public func ==<T>(lhs: OrderedSet<T>, rhs: OrderedSet<T>) -> Bool { return lhs.storage == rhs.storage }

/**
subscript:rhs:

:param: lhs OrderedSet<T>
:param: rhs S

:returns: OrderedSet<T>
*/
public func +<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs: OrderedSet<T>, rhs: S) -> OrderedSet<T> {
  var orderedSet = lhs
  orderedSet.extend(rhs)
  return orderedSet
}

/**
subscript:rhs:

:param: lhs OrderedSet<T>
:param: rhs S
*/
public func +=<T:Equatable, S:SequenceType where S.Generator.Element == T>(inout lhs: OrderedSet<T>, rhs: S) { lhs.extend(rhs) }

/**
Union set operator

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
:returns: OrderedSet<T>
*/
public func ∪<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs: OrderedSet<T>, rhs: S) -> OrderedSet<T> {
  return lhs + rhs
}

/**
Union set operator which stores result in lhs

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
*/
public func ∪=<T:Equatable, S:SequenceType where S.Generator.Element == T>(inout lhs: OrderedSet<T>, rhs: S) { lhs += rhs }

/**
Minus set operator

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
:returns: OrderedSet<T>
*/
public func ∖<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs: OrderedSet<T>, rhs: S) -> OrderedSet<T> {
  return OrderedSet<T>(lhs.filter { $0 ∉ rhs })
}

/**
Minus set operator which stores result in lhs

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
*/
public func ∖=<T:Equatable, S:SequenceType where S.Generator.Element == T>(inout lhs: OrderedSet<T>, rhs: S) {
  lhs = lhs.filter { $0 ∉ rhs }
}

/**
Intersection set operator

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
:returns: OrderedSet<T>
*/
public func ∩<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs: OrderedSet<T>, rhs: S) -> OrderedSet<T> {
  return (lhs ∪ rhs).filter{$0 ∈ lhs && $0 ∈ rhs}
}


/**
Intersection set operator which stores result in lhs

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
*/
public func ∩=<T:Equatable, S:SequenceType where S.Generator.Element == T>(inout lhs: OrderedSet<T>, rhs: S) { lhs = lhs ∩ rhs }

/**
Returns true if lhs is a subset of rhs

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
:returns: Bool
*/
public func ⊂<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs: OrderedSet<T>, rhs: S) -> Bool { return lhs.filter {$0 ∉ rhs}.isEmpty }

/**
Returns true if lhs is not a subset of rhs

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
:returns: Bool
*/
public func ⊄<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs: OrderedSet<T>, rhs: S) -> Bool { return !(lhs ⊂ rhs) }

/**
Returns true if rhs is a subset of lhs

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
:returns: Bool
*/
public func ⊃<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs: OrderedSet<T>, rhs: S) -> Bool { return Array(rhs) ⊂ lhs.array }

/**
Returns true if rhs is not a subset of lhs

:param: lhs OrderedSet<T>
:param: rhs OrderedSet<T>
:returns: Bool
*/
public func ⊅<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs: OrderedSet<T>, rhs: S) -> Bool { return !(lhs ⊃ rhs) }

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
