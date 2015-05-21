//
//  MappingOperations.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/12/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

// MARK: - Removing nil values from a sequence

/**
compressed:

:param: source S

:returns: [T]
*/
public func compressed<S:SequenceType, T where S.Generator.Element == Optional<T>>(source: S) -> [T] {
  return filter(source, {$0 != nil}).map({$0!})
}

/**
compressed:

:param: source S

:returns: [T]
*/
public func compressed<S:SequenceType, T where S.Generator.Element == T, T:NilLiteralConvertible>(source: S) -> [T] {
  return filter(source, {$0 != nil})
}

/**
compressedMap:transform:

:param: source S
:param: transform (T) -> U?

:returns: [U]
*/
public func compressedMap<S:SequenceType, T, U where S.Generator.Element == T>(source: S, transform: (T) -> U?) -> [U] {
  return map(source, transform) >>> compressed
}

/**
compressedMap:transform:

:param: source S?
:param: transform (T) -> U?

:returns: [U]?
*/
public func compressedMap<S:SequenceType, T, U where S.Generator.Element == T>(source: S?, transform: (T) -> U?) -> [U]? {
  return source >?> transform >?> compressedMap
}

// MARK: - Uniqueing

/**
uniqued:

:param: seq S

:returns: [T]
*/
public func uniqued<T:Hashable, S:SequenceType where S.Generator.Element == T>(seq: S) -> [T] {
  return Array(Set(seq))
}

/**
uniqued:

:param: seq S

:returns: [T]
*/
public func uniqued<T:Equatable, S:SequenceType where S.Generator.Element == T>(seq: S) -> [T] {
  var result: [T] = []
  for element in seq { if element ∉ result { result.append(element) } }
  return result
}

/**
unique<T:Equatable>:

:param: array [T]
*/
//public func unique<T:Equatable>(inout array:[T]) { array = uniqued(array) }


// MARK: - Reducing

/**
Flattens a sequence into an array of a single type, non-T types are dropped

:param: sequence S

:returns: [T]
*/
public func flattened<S:SequenceType, T>(sequence: S) -> [T] {
  var flattenObjCTypes: ([NSObject] -> [T])!
  flattenObjCTypes = {
    x in
    var result: [T] = []
    for e in x {
      if let eO = e as? [NSObject] {
        result.extend(flattenObjCTypes(eO))
      }
      else if let eT = e as? T { result.append(eT) }
    }
    return result
  }

  var flattenSwiftTypes: (MirrorType -> [T])!
  flattenSwiftTypes = {
    mirror in
    let valueMirror = reflect(mirror.value)
    var result: [T] = []
    if mirror.count > 0 {
      for i in 0..<mirror.count {
        let elementMirror = mirror[i].1
        let elementValue = elementMirror.value
        if let v = elementValue as? T where elementMirror.count == 0 { result.append(v) }
        else if elementMirror.count > 0 {
          result.extend(flattenSwiftTypes(elementMirror))
        } else if elementMirror is Swift._ObjCMirror {
          if let objectArray = elementValue as? [NSObject] {
            result.extend(flattenObjCTypes(objectArray))
          }
        }// else if let v = elementValue as? T { result.append(v) }
      }
    }
    return result
  }
  var result: [T] = []
  for element in sequence {
    let mirror = reflect(element)
    if let e = element as? T where mirror.count == 0 { result.append(e) }
    else { result.extend(flattenSwiftTypes(reflect(element))) }
  }
  return result
}

/**
flattenedMap:transform:

:param: source S
:param: transform (T) -> U

:returns: [V]
*/
public func flattenedMap<S:SequenceType, T, U, V where S.Generator.Element == T>(source: S, transform: (T) -> U) -> [V] {
  return source >>> transform >>> map >>> flattened
}

/**
flattenedCompressedMap:transform:

:param: source S
:param: transform (T) -> U?

:returns: [V]
*/
public func flattenedCompressedMap<S:SequenceType, T, U, V
  where S.Generator.Element == T>(source: S, transform: (T) -> U?) -> [V]
{
  return source >>> transform >>> compressedMap >>> flattened
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

// MARK: - Enumerating

public func enumeratingMap<S: SequenceType, T>(source: S, transform: (Int, S.Generator.Element) -> T) -> [T] {
  return map(enumerate(source), transform)
}
