//
//  Generic.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/5/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

@inline(__always) prefix func ⩨ <T : _UnsignedIntegerType, U: _SignedIntegerType>   (x: T) -> U { return numericCast(x) }
@inline(__always) prefix func ⩨ <T : _SignedIntegerType,   U: _UnsignedIntegerType> (x: T) -> U { return numericCast(x) }
@inline(__always) prefix func ⩨ <T : _UnsignedIntegerType, U: _UnsignedIntegerType> (x: T) -> U { return numericCast(x) }
@inline(__always) prefix func ⩨ <T : _SignedIntegerType,   U: _SignedIntegerType>   (x: T) -> U { return numericCast(x) }

public func sequence<T>(v: (T,T)) -> SequenceOf<T> { return SequenceOf([v.0, v.1]) }
public func sequence<T>(v: (T,T,T)) -> SequenceOf<T> { return SequenceOf([v.0, v.1, v.2]) }
public func sequence<T>(v: (T,T,T,T)) -> SequenceOf<T> { return SequenceOf([v.0, v.1, v.2, v.3]) }

public func disperse2<S:SequenceType,T where S.Generator.Element == T>(s: S) -> (T, T) {
  let array = Array(s)
  return (array[0], array[1])
}
public func disperse3<S:SequenceType,T where S.Generator.Element == T>(s: S) -> (T, T, T) {
  let array = Array(s)
  return (array[0], array[1], array[2])
}
public func disperse4<S:SequenceType,T where S.Generator.Element == T>(s: S) -> (T, T, T, T) {
  let array = Array(s)
  return (array[0], array[1], array[2], array[3])
}

public func typeCast<T,U>(t: T, u: U.Type) -> U? { return t as? U }
public func typeCast<T,U>(t: T?, u: U.Type) -> U? { return t != nil ? typeCast(t!, u) : nil }

public func compressed<S:SequenceType, T where S.Generator.Element == Optional<T>>(source: S) -> [T] {
  return compressed(Array(source))
}
public func compressedMap<S:SequenceType, T, U where S.Generator.Element == T>(source: S, transform: (T) -> U?) -> [U] {
  return compressedMap(Array(source), transform)
}
public func compressedMap<S:SequenceType, T, U where S.Generator.Element == T>(source: S?, transform: (T) -> U?) -> [U]? {
  if let s = source { return compressedMap(s, transform) as [U] } else { return nil }
}

/**
createIdentifier:suffix:

:param: object Any
:param: suffix String? = nil

:returns: String
*/
public func createIdentifier(object: Any, _ suffix: String? = nil) -> String {
  return createIdentifier(object, suffix == nil ? nil : [suffix!])
}

/**
createIdentifier:suffix:

:param: object Any
:param: suffix [String]? = nil

:returns: String
*/
public func createIdentifier(object: Any, _ suffix: [String]? = nil) -> String {
  let identifier = _stdlib_getDemangledTypeName(object)
  return suffix == nil ? identifier : "-".join([identifier] + suffix!)
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
function for recursively reducing a property of an element that contains child elements of its kind

:param: initial U The initial value for the reduction
:param: subitems (T) -> [T] Closure for producing child elements of the item
:param: combine (U, T) -> Closure for producing the reduction for the item without recursing
:param: item T The initial item

:returns: U The result of the reduction
*/
public func recursiveReduce<T, U>(initial: U, subitems: (T) -> [T], combine: (U, T) -> U, item: T) -> U {
  var body: ((U, (T) -> [T], (U,T) -> U, T) -> U)!
  body = { (i: U, s: (T) -> [T], c: (U,T) -> U, x: T) -> U in reduce(s(x), c(i, x)){body($0.0, s, c, $0.1)} }
  return body(initial, subitems, combine, item)
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
findFirst:predicate:

:param: domain C
:param: predicate (C.Generator.Element) -> Bool

:returns: (C.Generator.Element)?
*/
public func findFirst<C: CollectionType>(domain: C?, predicate: (C.Generator.Element) -> Bool) -> (C.Generator.Element)? {
  if let collection = domain { for element in collection { if predicate(element) { return element } } }
  return nil
}

/**
length:

:param: interval ClosedInterval<T>

:returns: T.Stride
*/
public func length<T:Strideable>(interval: ClosedInterval<T>) -> T.Stride { return interval.start.distanceTo(interval.end) }

/**
spliced:newElements:atIndex:

:param: x C
:param: newElements S
:param: i C.Index

:returns: C
*/
public func spliced<C : RangeReplaceableCollectionType, S : CollectionType
                   where C.Generator.Element == S.Generator.Element>(x: C, newElements: S, atIndex i: C.Index) -> C
{
  var xPrime = x
  splice(&xPrime, newElements, atIndex: i)
  return xPrime
}

public func removedAtIndex<C : RangeReplaceableCollectionType>(x: C, index: C.Index) -> C {
  var xPrime = x
  removeAtIndex(&xPrime, index)
  return xPrime
}


/**
The function is a simple wrapper around `reduce` that ignores the actual reduction as a way to visit every element

:param: sequence S
:param: block (S.Generator.Element) -> Void
*/
public func apply<S:SequenceType>(sequence: S, block: (S.Generator.Element) -> Void) { reduce(sequence, Void()){block($0.1)} }

/**
A function that simply calls `apply` and then returns the sequence

:param: sequence S
:param: block (S.Generator.Element) -> Void

:returns: S
*/
public func chainApply<S:SequenceType>(sequence: S, block: (S.Generator.Element) -> Void) -> S {
  apply(sequence, block); return sequence
}

/** Operator function for the `apply` function */
public func ➤<S:SequenceType>(lhs: S, rhs: (S.Generator.Element) -> Void) { apply(lhs, rhs) }
public func ➤<T>(lhs: T, rhs: (T) -> Void) { rhs(lhs) }

/** Operator function for the `chainApply` function */
public func ➤|<S:SequenceType>(lhs: S, rhs: (S.Generator.Element) -> Void) -> S { return chainApply(lhs, rhs) }
public func ➤|<T>(lhs: T, rhs: (T) -> Void) -> T { rhs(lhs); return lhs }

public func enumeratingMap<S : SequenceType, T>(source: S, transform: (Int,S.Generator.Element) -> T) -> [T] {
  var mapped: [T] = []
  for (i, element) in enumerate(source) { mapped.append(transform(i, element)) }
  return mapped
}

/**
unique<T:Equatable>:

:param: seq S

:returns: [T]
*/
public func uniqued<S:SequenceType where S.Generator.Element:Equatable>(seq:S) -> [S.Generator.Element] {
  var u: [S.Generator.Element] = []
  for e in seq { if e ∉ u { u.append(e) } }
  return u
}

/**
Returns true if `lhs` is nil or `rhs` evaluates to true

:param: lhs Optional<T>
:param: rhs @autoclosure () -> Bool

:returns: Bool
*/
public func ∅||<T>(lhs: Optional<T>, @autoclosure rhs: () -> Bool) -> Bool {
  return lhs == nil || rhs()
}


/**
Prefix operator that extracts the first two elements of an array and returns as a tuple

:param: array [T]
:returns: (T, T)
*/
//public prefix func ⇇<C: CollectionType where C.Index: IntegerLiteralConvertible> (x:[C])
//  -> (C.Generator.Element, C.Generator.Element)
//{
//  return (x[0], x[1])
//}

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
  return filter(uniqued(lhs ∪ rhs)) {$0 ∈ lhs && $0 ∈ rhs}
}

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

/**
toString:

:param: x T?

:returns: String
*/
public func toString<T>(x: T?) -> String {
  if let xx = x {
    return toString(xx)
  } else {
    return "nil"
  }
}

/**
setOption:s:

:param: o T
:param: s T

:returns: T
*/
public func setOption<T:RawOptionSetType>(o: T, s: T) -> T { return o | s }

/**
unsetOption:s:

:param: o T
:param: s T

:returns: T
*/
public func unsetOption<T:RawOptionSetType>(o: T, s: T) -> T { return s & ~o }

/**
isOptionSet:s:

:param: o T
:param: s T

:returns: Bool
*/
public func isOptionSet<T:RawOptionSetType>(o: T, s: T) -> Bool { return o & s != nil }

/**
toggleOption:s:

:param: o T
:param: s T

:returns: T
*/
public func toggleOption<T:RawOptionSetType>(o: T, s: T) -> T { return isOptionSet(o, s) ? unsetOption(o, s) : setOption(o, s) }


public func ∪<T:RawOptionSetType>(lhs: T, rhs: T) -> T { return setOption(rhs, lhs) }
public func ∪=<T:RawOptionSetType>(inout lhs: T, rhs: T) { lhs = lhs ∪ rhs }


public func ∖<T:RawOptionSetType>(lhs: T, rhs: T) -> T { return unsetOption(rhs, lhs) }
public func ∖=<T:RawOptionSetType>(inout lhs: T, rhs: T) { lhs = lhs ∖ rhs }

public func +(lhs: Range<Int>, rhs: Int) -> Range<Int> { return lhs.startIndex + rhs ..< lhs.endIndex + rhs }
