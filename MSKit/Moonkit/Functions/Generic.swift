//
//  Generic.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/5/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

// extension Float: Divisible, IntegerDivisible, Summable {}
// public func /(lhs: Float, rhs: Int) -> Float { return lhs / Float(rhs)}
// extension Double: Divisible, IntegerDivisible, Summable {}
// public func /(lhs: Double, rhs: Int) -> Double { return lhs / Double(rhs)}
// extension CGFloat: Divisible, IntegerDivisible, Summable {}
// public func /(lhs: CGFloat, rhs: Int) -> CGFloat { return lhs / CGFloat(rhs)}
// extension Int: Divisible, IntegerDivisible, Summable {}
// public func /(lhs: Int, rhs: Int) -> Int { return lhs / Int(rhs)}
// extension Int8: Divisible, IntegerDivisible, Summable {}
// public func /(lhs: Int8, rhs: Int) -> Int8 { return lhs / Int8(rhs)}
// extension Int16: Divisible, IntegerDivisible, Summable {}
// public func /(lhs: Int16, rhs: Int) -> Int16 { return lhs / Int16(rhs)}
// extension Int32: Divisible, IntegerDivisible, Summable {}
// public func /(lhs: Int32, rhs: Int) -> Int32 { return lhs / Int32(rhs)}
// extension Int64: Divisible, IntegerDivisible, Summable {}
// public func /(lhs: Int64, rhs: Int) -> Int64 { return lhs / Int64(rhs)}
// extension UInt: Divisible, IntegerDivisible, Summable {}
// public func /(lhs: UInt, rhs: Int) -> UInt { return lhs / UInt(rhs)}
// extension UInt8: Divisible, IntegerDivisible, Summable {}
// public func /(lhs: UInt8, rhs: Int) -> UInt8 { return lhs / UInt8(rhs)}
// extension UInt16: Divisible, IntegerDivisible, Summable {}
// public func /(lhs: UInt16, rhs: Int) -> UInt16 { return lhs / UInt16(rhs)}
// extension UInt32: Divisible, IntegerDivisible, Summable {}
// public func /(lhs: UInt32, rhs: Int) -> UInt32 { return lhs / UInt32(rhs)}
// extension UInt64: Divisible, IntegerDivisible, Summable {}
// public func /(lhs: UInt64, rhs: Int) -> UInt64 { return lhs / UInt64(rhs)}

/**
sum:

:param: items [T]

:returns: T?
*/
public func sum<T:Summable>(items: [T]) -> T? {
  if items.count == 0 { return nil }
  var result = items.first!
  if items.count > 1 {
    for item in items[1..<items.count] {
      result = result + item
    }
  }
  return result
}

/**
average:

:param: items [T]

:returns: T?
*/
public func average<T:Summable where T:IntegerDivisible>(items: [T]) -> T? {
  if items.count == 0 { return nil }
  else if items.count == 1 { return items.first }
  else if let s = sum(items) {
    return s / items.count
  } else {
    return nil
  }
}

public func map<K,V,U>(dict: [K:V], block: (K, V) -> U) -> [K:U] {
  var result: [K:U] = [:]
  for (key, value) in dict { result[key] = block(key, value) }
  return result
}

/**
advance:amount:

:param: range Range<T>
:param: amount T.Distance
*/
public func advance<T: ForwardIndexType>(inout range: Range<T>, amount: T.Distance) {
  let d = distance(range.startIndex, range.endIndex)
  let start: T = advance(range.startIndex, amount)
  let end: T = advance(range.startIndex, amount + d)
  range = Range<T>(start: start, end: end)
}

/**
join:elements:

:param: seperator T
:param: elements [T]

:returns: [T]
*/
public func join<T>(seperator: T, elements: [T]) -> [T] {
  if elements.count > 1 {
    var joinedElements: [T] = []
    for element in elements[0..<(elements.count - 1)] {
      joinedElements.append(element)
      joinedElements.append(seperator)
    }
    joinedElements.append(elements.last!)
    return joinedElements
  } else {
    return elements
  }
}

/**
advance:amount:

:param: range Range<T>
:param: amount T.Distance

:returns: Range<T>
*/
public func advance<T: ForwardIndexType>(range: Range<T>, amount: T.Distance) -> Range<T> {
  return Range<T>(start: advance(range.startIndex, amount), end: advance(range.endIndex, amount))
}

/**
find:value:

:param: domain C
:param: value C.Generator.Element?

:returns: C.Index?
*/
public func find<C: CollectionType where C.Generator.Element: Equatable>(domain: C, value: C.Generator.Element?) -> C.Index? {
  if let v = value { return find(domain, v) } else { return nil }
}

/**
length:

:param: interval ClosedInterval<T>

:returns: T.Stride
*/
public func length<T:Strideable>(interval: ClosedInterval<T>) -> T.Stride { return interval.start.distanceTo(interval.end) }

public postfix func ‽<T>(lhs: [Optional<T>]) -> [T] { return lhs.filter{$0 != nil}.map{$0!} }

/**
compressed:

:param: array [Optional<T>]

:returns: [T]
*/
public func compressed<T>(array:[Optional<T>]) -> [T] { return array.filter{$0 != nil}.map{$0!} }

/**
flattened:

:param: array [[T]]

:returns: [T]
*/
public func flattened<T>(array:[[T]]) -> [T] { var a: [T] = []; for s in array { a += s}; return a }

/**
The function is a simple wrapper around `reduce` that ignores the actual reduction as a way to visit every element

:param: sequence S
:param: block (S.Generator.Element) -> Void
*/
public func apply<S:SequenceType>(sequence: S, block: (S.Generator.Element) -> Void) { reduce(sequence, Void()){block($0.1)} }

/**
unique<T:Equatable>:

:param: seq S

:returns: [T]
*/
public func unique<S:SequenceType where S.Generator.Element:Equatable>(seq:S) -> [S.Generator.Element] {
  var u: [S.Generator.Element] = []
  for e in seq { if e ∉ u { u.append(e) } }
  return u
}

/**
unique<T:Equatable>:

:param: array [T]
*/
public func unique<T:Equatable>(inout array:[T]) { array = unique(array) }


/**
Returns true if `lhs` is nil or `rhs` evaluates to true

:param: lhs Optional<T>
:param: rhs @autoclosure () -> Bool

:returns: Bool
*/
public func ∅||<T>(lhs: Optional<T>, rhs: @autoclosure () -> Bool) -> Bool {
  return lhs == nil || rhs()
}


/**
Prefix operator that extracts the first two elements of an array and returns as a tuple

:param: array [T]
:returns: (T, T)
*/
public prefix func ⇇<T>(array:[T]) -> (T, T) { return (array[0], array[1]) }

/**
Function for extracting first two elements of rhs into lhs

:param: lhs (T, T)
:param: rhs [T]
*/
public func ⥢<T>(inout lhs:(T, T), rhs:[T]) { lhs = (rhs[0], rhs[1]) }

/**
Union set operator

:param: lhs [T]
:param: rhs [T]
:returns: [T]
*/
public func ∪<T, S0:SequenceType, S1:SequenceType where S0.Generator.Element == T, S1.Generator.Element == T>
  (lhs:S0, rhs:S1) -> [T]
{
  var u = Array(lhs)
  u += Array(rhs)
  return u
}

/**
Minus set operator

:param: lhs [T]
:param: rhs [T]
:returns: [T]
*/
public func ∖<T:Equatable, S0:SequenceType, S1:SequenceType where S0.Generator.Element == T, S1.Generator.Element == T>
  (lhs:S0, rhs:S1) -> [T]
{
  return filter(lhs) { $0 ∉ rhs }
}

/**
Intersection set operator

:param: lhs [T]
:param: rhs [T]
:returns: [T]
*/
public func ∩<T:Equatable, S0:SequenceType, S1:SequenceType where S0.Generator.Element == T, S1.Generator.Element == T>
  (lhs:S0, rhs:S1) -> [T]
{
  return filter(unique(lhs ∪ rhs)) {$0 ∈ lhs && $0 ∈ rhs}
}

/**
Union set operator which stores result in lhs

:param: lhs [T]
:param: rhs [T]
*/
public func ∪=<T>(inout lhs:[T], rhs:[T]) { lhs += rhs }

/**
Minus set operator which stores result in lhs

:param: lhs [T]
:param: rhs [T]
:returns: [T]
*/
public func ∖=<T:Equatable>(inout lhs:[T], rhs:[T]) -> [T] { lhs = lhs.filter { $0 ∉ rhs }; return lhs }

/**
Intersection set operator which stores result in lhs

:param: lhs [T]
:param: rhs [T]
:returns: [T]
*/
public func ∩=<T:Equatable>(inout lhs:[T], rhs:[T]) { lhs = unique(lhs ∪ rhs).filter {$0 ∈ lhs && $0 ∈ rhs} }

/**
Returns true if lhs is a subset of rhs

:param: lhs [T]
:param: rhs [T]
:returns: Bool
*/
public func ⊂<T:Equatable>(lhs:[T], rhs:[T]) -> Bool { return lhs.filter {$0 ∉ rhs}.isEmpty }

/**
Returns true if lhs is not a subset of rhs

:param: lhs [T]
:param: rhs [T]
:returns: Bool
*/
public func ⊄<T:Equatable>(lhs:[T], rhs:[T]) -> Bool { return !(lhs ⊂ rhs) }

/**
Returns true if rhs is a subset of lhs

:param: lhs [T]
:param: rhs [T]
:returns: Bool
*/
public func ⊃<T:Equatable>(lhs:[T], rhs:[T]) -> Bool { return rhs ⊂ lhs }

/**
Returns true if rhs is not a subset of lhs

:param: lhs [T]
:param: rhs [T]
:returns: Bool
*/
public func ⊅<T:Equatable>(lhs:[T], rhs:[T]) -> Bool { return !(lhs ⊃ rhs) }

/**
Postfix operator that turns a generator into its generated array

:param: generator T
:returns: [T.Element]
*/
public postfix func ⭆<T where T:GeneratorType>(var generator: T) -> [T.Element] {
  var result: [T.Element] = []
  var done = false
  while !done { if let e = generator.next() { result += [e] } else { done = true } }
  return result
}

public func collect<T where T:GeneratorType>(generator: T) -> [T.Element] {
  return generator⭆
}

public func collectFrom<C:CollectionType, S:SequenceType where C.Index == S.Generator.Element>(source: C, indexes: S)
  -> [C.Generator.Element]
{
  var result: [C.Generator.Element] = []
  for idx in indexes { result.append(source[idx]) }
  return result
}

/**
Returns true if rhs is equal to lhs or if rhs is nil

:param: lhs T
:param: rhs T!
:returns: Bool
*/
public func ⩢ <T:Equatable>(lhs: T, rhs: T!) -> Bool { return rhs == nil || lhs == rhs }

/**
Returns true if rhs contains lhs

:param: lhs T
:param: rhs S
:returns: Bool
*/
public func ∈<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs:T, rhs:S) -> Bool {
  return contains(rhs, lhs)
}

/**
Returns true if rhs contains lhs

:param: lhs T?
:param: rhs S
:returns: Bool
*/
public func ∈<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs:T?, rhs:S) -> Bool {
  return lhs != nil && contains(rhs, lhs!)
}

/**
Returns true if rhs contains lhs

:param: lhs T
:param: rhs U
:returns: Bool
*/
public func ∈ <T, U where U:IntervalType, T == U.Bound>(lhs:T, rhs:U) -> Bool { return rhs.contains(lhs) }

/**
Returns true if lhs contains rhs

:param: lhs T
:param: rhs T
:returns: Bool
*/
public func ∋<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs:S, rhs:T) -> Bool { return rhs ∈ lhs }
public func ∋ <T, U where U:IntervalType, T == U.Bound>(lhs:U, rhs:T) -> Bool { return lhs.contains(rhs) }

/**
Returns true if rhs does not contain lhs

:param: lhs T
:param: rhs T
:returns: Bool
*/
public func ∉<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs:T, rhs:S) -> Bool { return !(lhs ∈ rhs) }
public func ∉ <T, U where U:IntervalType, T == U.Bound>(lhs:T, rhs:U) -> Bool { return !(lhs ∈ rhs) }

/**
Returns true if lhs does not contain rhs

:param: lhs T
:param: rhs T
:returns: Bool
*/
public func ∌ <T, U:IntervalType where T == U.Bound>(lhs:U, rhs:T) -> Bool { return !(lhs ∋ rhs) }
public func ∌<T:Equatable, S:SequenceType where S.Generator.Element == T>(lhs:S, rhs:T) -> Bool { return !(lhs ∋ rhs) }

