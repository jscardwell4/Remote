//
//  Generic.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/5/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

public func typeCast<T,U>(t: T, u: U.Type) -> U? { return t as? U }
public func typeCast<T,U>(t: T?, u: U.Type) -> U? { return t != nil ? typeCast(t!, u) : nil }

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
toString:

:param: x T?

:returns: String
*/
public func toString<T>(x: T?) -> String { if let xx = x { return toString(xx) } else { return "nil" } }


public func +(lhs: Range<Int>, rhs: Int) -> Range<Int> { return lhs.startIndex + rhs ..< lhs.endIndex + rhs }


/**
The Box class is used to box values and as a workaround to the limitations with generics in the compiler. 
From "Functional Programming in Swift", www.objc.io
*/
public class Box<T> { public let unbox: T; public init(_ value: T) { unbox = value } }


